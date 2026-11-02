-- Plumbline kit 0.1.0 · module: feature flags, gates and switching on
-- Clauses: LIF-1 (flags in the database per job and level, states off/shadow/live, an audience), LIF-2
-- (new jobs ship off), LIF-3 (every change evidenced; off always allowed to the owner), LIF-4 (moving
-- up needs a gate record), AGT-4 (licensed work stays off until the licence is granted).
--
-- One guard trigger enforces the rules on every write path:
--   - turning a flag off (or down) is always allowed to anyone with Admin settings: the kill switch;
--   - turning one up needs a gate record for that flag in the evidence log;
--   - a flag marked `requires_licence` cannot go up until the parameter licence.<name>.granted is true;
--   - (from the procedures module) turning one up needs an accepted procedure that names it.
-- Every change is written to the evidence log as 'flag:changed'.
--
-- Each environment has its own database, so its own flags; there is no environment column. The browser
-- reads flags only through flag_allows() and my_flags(), and writes them only through set_flag_state(),
-- record_gate() and switch_on().
--
-- An app moving existing live features onto flags can record a 'gate:grandfathered' evidence entry for
-- each, with the reason; the guard accepts it as the flag's gate.

create table public.feature_flags (
  key text primary key check (key ~ '^[a-z0-9_]+\.(record|assist|agent)$'),
  job_id text not null check (length(job_id) > 0),
  level text not null check (level in ('record', 'assist', 'agent')),
  state text not null default 'off' check (state in ('off', 'shadow', 'live')),
  audience jsonb not null default '{}'::jsonb,
  owner_area text not null default 'admin_settings' references public.access_areas (key),
  requires_licence text check (requires_licence ~ '^[a-z_]+$'),
  gate_ref uuid,
  description text not null,
  updated_by uuid,
  updated_at timestamptz not null default now(),
  check (key like '%.' || level)
);

alter table public.feature_flags enable row level security;
revoke all on public.feature_flags from public, anon, authenticated;
grant select on public.feature_flags to authenticated;
grant select, insert, update on public.feature_flags to service_role;
create policy "feature_flags readable with general" on public.feature_flags
  for select to authenticated using (public.has_area('general'));

create function public.flag_rank(_state text) returns integer
language sql immutable set search_path = '' as $$
  select case _state when 'off' then 0 when 'shadow' then 1 when 'live' then 2 end
$$;

create function public.feature_flags_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_old int := 0;
begin
  if tg_op = 'UPDATE' then
    if new.key <> old.key or new.job_id <> old.job_id or new.level <> old.level then
      raise exception 'A switch''s key, job and level never change.';
    end if;
    v_old := public.flag_rank(old.state);
  end if;
  if auth.uid() is not null and not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to change a switch.';
  end if;
  if public.flag_rank(new.state) > v_old then
    if new.gate_ref is null or not exists (
      select 1 from public.evidence_log e
      where e.id = new.gate_ref and e.flag_key = new.key
        and e.action in ('gate:recorded', 'gate:grandfathered')
    ) then
      raise exception 'Turning a switch up needs a gate record for it (Plumbline LIF-4).';
    end if;
    if new.requires_licence is not null and not public.param_bool('licence.' || new.requires_licence || '.granted') then
      raise exception 'This switch serves licensed work and stays off until the licence is granted (Plumbline AGT-4).';
    end if;
  end if;
  new.updated_by := auth.uid();
  new.updated_at := now();
  return new;
end;
$$;
create trigger feature_flags_guard before insert or update on public.feature_flags
  for each row execute function public.feature_flags_guard();

create function public.feature_flags_log() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' or new.state is distinct from old.state or new.audience is distinct from old.audience then
    perform public.log_evidence('flag:changed', new.job_id, 'feature_flag', null,
      case when tg_op = 'INSERT' then null
           else jsonb_build_object('state', old.state, 'audience', old.audience) end,
      jsonb_build_object('state', new.state, 'audience', new.audience, 'level', new.level, 'gate_ref', new.gate_ref),
      auth.uid(), null, array['LIF-3'], new.key, new.state);
  end if;
  return new;
end;
$$;
create trigger feature_flags_log after insert or update on public.feature_flags
  for each row execute function public.feature_flags_log();

-- The state a flag is in, for server code (a scheduled job reads it with no signed-in person).
create function public.flag_state(_key text) returns text
language sql stable security definer set search_path = '' as $$
  select state from public.feature_flags where key = _key
$$;

-- Whether the signed-in person may use what a flag guards: live for everyone with access, shadow only
-- for its audience (named users, access areas or roles), off for nobody.
create function public.flag_allows(_key text) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((
    select case f.state
      when 'live' then public.has_area('general')
      when 'shadow' then public.mfa_ok() and (
        coalesce(auth.uid()::text in (select jsonb_array_elements_text(f.audience -> 'users')), false)
        or exists (select 1 from jsonb_array_elements_text(f.audience -> 'areas') a where public.has_area(a))
        or exists (select 1 from jsonb_array_elements_text(f.audience -> 'roles') r where public.has_role(r)))
      else false end
    from public.feature_flags f where f.key = _key), false)
$$;

create function public.my_flags() returns setof text
language sql stable security definer set search_path = '' as $$
  select key from public.feature_flags where public.flag_allows(key) order by key
$$;

-- A gate record: the criteria set in advance and the results, signed by whoever records it (LIF-4).
create function public.record_gate(_key text, _stage text, _criteria jsonb, _results jsonb)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_job text;
begin
  if not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to record a gate.';
  end if;
  if _stage not in ('sandbox', 'shadow', 'live', 'agent') then
    raise exception 'Unknown gate stage "%".', _stage;
  end if;
  select job_id into v_job from public.feature_flags where key = _key;
  if v_job is null then
    raise exception 'There is no switch "%".', _key;
  end if;
  return public.log_evidence('gate:recorded', v_job, 'feature_flag', null, null,
    jsonb_build_object('stage', _stage, 'criteria', _criteria, 'results', _results),
    auth.uid(), null, array['LIF-4'], _key, null);
end;
$$;

-- The write path for people. The guard trigger enforces the rules either way.
create function public.set_flag_state(_key text, _state text, _gate_ref uuid default null)
returns public.feature_flags
language plpgsql security definer set search_path = '' as $$
declare
  v_flag public.feature_flags;
begin
  if not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to change a switch.';
  end if;
  update public.feature_flags set state = _state, gate_ref = coalesce(_gate_ref, gate_ref)
   where key = _key
  returning * into v_flag;
  if v_flag.key is null then
    raise exception 'There is no switch "%".', _key;
  end if;
  return v_flag;
end;
$$;

-- Switching on in one step: record what was checked and the result as the gate, then move the switch
-- to shadow for named people or live for everyone with access.
create function public.switch_on(_key text, _state text, _users uuid[], _checked text, _result text)
returns public.feature_flags
language plpgsql security definer set search_path = '' as $$
declare
  v_gate uuid;
  v_flag public.feature_flags;
begin
  if not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to switch something on.';
  end if;
  if _state not in ('shadow', 'live') then raise exception 'Switch on to shadow or live.'; end if;
  if nullif(btrim(_checked), '') is null or nullif(btrim(_result), '') is null then
    raise exception 'Say what you checked and the result: that is the gate record.';
  end if;
  if _state = 'shadow' and coalesce(array_length(_users, 1), 0) = 0 then
    raise exception 'Shadow needs at least one person to try it.';
  end if;
  if _state = 'shadow' and exists (select 1 from unnest(_users) u where not exists (
    select 1 from public.profiles p where p.id = u and p.active)) then
    raise exception 'Everyone in the shadow audience must be an active person.';
  end if;
  v_gate := public.record_gate(_key, _state, jsonb_build_object('checked', btrim(_checked)),
    jsonb_build_object('result', btrim(_result)));
  update public.feature_flags
     set state = _state, gate_ref = v_gate,
         audience = case when _state = 'shadow' then jsonb_build_object('users', to_jsonb(_users)) else audience end
   where key = _key
  returning * into v_flag;
  return v_flag;
end;
$$;

revoke all on function public.flag_state(text), public.flag_allows(text), public.my_flags(),
  public.record_gate(text, text, jsonb, jsonb), public.set_flag_state(text, text, uuid),
  public.switch_on(text, text, uuid[], text, text), public.feature_flags_guard(), public.feature_flags_log()
  from public, anon;
revoke all on function public.feature_flags_guard(), public.feature_flags_log() from authenticated;
grant execute on function public.flag_allows(text), public.my_flags(), public.record_gate(text, text, jsonb, jsonb),
  public.set_flag_state(text, text, uuid), public.switch_on(text, text, uuid[], text, text) to authenticated;
grant execute on function public.flag_state(text), public.flag_allows(text), public.my_flags() to service_role;
