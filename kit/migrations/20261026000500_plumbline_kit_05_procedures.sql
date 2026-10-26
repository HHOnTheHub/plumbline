-- Plumbline kit 0.1.0 · module: procedures
-- Clauses: PRC-1 (procedures in versioned tables; accepted versions never edited), PRC-4 (the job
-- owner accepts; the risk owner co-signs regulated jobs; rejections need a reason), PRC-5 (a flag goes
-- up only when an accepted procedure version names it).
--
--   procedures          one per job and procedure (C01-P1), with its owner area and whether it is regulated
--   procedure_versions  numbered versions: draft, then accepted (or rejected); accepting one supersedes
--                       the last; an accepted, rejected or superseded version never changes
--   procedure_steps     the steps of a version: permanent id (C01-P1.3), who, where, mode, the clauses it
--                       carries out, the controls it satisfies, the evidence it writes, its flag
--
-- Acceptance: someone holding the procedure's owner area (or Admin settings) who did not draft it. A
-- regulated procedure also needs a co-sign by someone holding the area named in the parameter
-- procedures.cosign_area, who is neither the drafter nor the accepter. Every action is evidenced.
--
-- This module also replaces the flags guard, adding PRC-5. Flags whose gate is a 'gate:grandfathered'
-- record are exempt until their procedure is accepted, so a feature that was live before the flag
-- existed can always be switched back on.

create table public.procedures (
  id text primary key check (id ~ '^[A-Z][A-Z0-9]{0,5}-P[0-9]+$'),
  job_id text not null check (length(job_id) > 0),
  title text not null,
  owner_area text not null references public.access_areas (key),
  regulated boolean not null default false,
  created_at timestamptz not null default now(),
  check (id like job_id || '-P%')
);

create table public.procedure_versions (
  procedure_id text not null references public.procedures (id),
  version integer not null check (version > 0),
  status text not null default 'draft' check (status in ('draft', 'accepted', 'rejected', 'superseded')),
  summary text not null,
  change_link text,
  drafted_by uuid,
  drafted_at timestamptz not null default now(),
  accepted_by uuid,
  accepted_at timestamptz,
  cosigned_by uuid,
  cosigned_at timestamptz,
  rejected_by uuid,
  rejected_at timestamptz,
  rejected_reason text,
  primary key (procedure_id, version)
);

create table public.procedure_steps (
  procedure_id text not null,
  version integer not null,
  id text not null check (id ~ '^[A-Z][A-Z0-9]{0,5}-P[0-9]+\.[0-9]+$'),
  position integer not null,
  what text not null,
  who text not null,
  location text not null,
  mode text not null check (mode in ('manual', 'assisted', 'agent')),
  clause_refs text[] not null default '{}',
  controls text[] not null default '{}',
  evidence_actions text[] not null default '{}',
  flag_key text references public.feature_flags (key),
  alias text,
  primary key (procedure_id, version, id),
  foreign key (procedure_id, version) references public.procedure_versions (procedure_id, version),
  check (id like procedure_id || '.%')
);

alter table public.procedures enable row level security;
alter table public.procedure_versions enable row level security;
alter table public.procedure_steps enable row level security;
revoke all on public.procedures, public.procedure_versions, public.procedure_steps from public, anon, authenticated;
grant select on public.procedures, public.procedure_versions, public.procedure_steps to authenticated;
grant select, insert, update on public.procedures, public.procedure_versions, public.procedure_steps to service_role;
create policy "procedures readable with general" on public.procedures
  for select to authenticated using (public.has_area('general'));
create policy "procedure_versions readable with general" on public.procedure_versions
  for select to authenticated using (public.has_area('general'));
create policy "procedure_steps readable with general" on public.procedure_steps
  for select to authenticated using (public.has_area('general'));

-- Accepted, rejected and superseded versions never change, except that accepting a newer version
-- moves the last accepted one to 'superseded' (status only).
create function public.procedure_versions_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE' then
    if old.status <> 'draft' then
      raise exception 'Only a draft procedure version can be removed (Plumbline PRC-1).';
    end if;
    return old;
  end if;
  if old.status = 'draft' then
    return new;
  end if;
  if old.status = 'accepted' and new.status = 'superseded'
     and (to_jsonb(new) - 'status') = (to_jsonb(old) - 'status') then
    return new;
  end if;
  raise exception 'An accepted, rejected or superseded procedure version never changes; draft a new version (Plumbline PRC-1).';
end;
$$;
create trigger procedure_versions_guard before update or delete on public.procedure_versions
  for each row execute function public.procedure_versions_guard();

create function public.procedure_steps_guard() returns trigger
language plpgsql set search_path = '' as $$
declare
  v_status text;
begin
  select status into v_status from public.procedure_versions
   where procedure_id = coalesce(new.procedure_id, old.procedure_id)
     and version = coalesce(new.version, old.version);
  if v_status is distinct from 'draft' then
    raise exception 'Steps can only change while their version is a draft (Plumbline PRC-1).';
  end if;
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
create trigger procedure_steps_guard before insert or update or delete on public.procedure_steps
  for each row execute function public.procedure_steps_guard();

-- Create a procedure for a job (Admin settings).
create function public.create_procedure(_id text, _job_id text, _title text, _owner_area text, _regulated boolean)
returns public.procedures
language plpgsql security definer set search_path = '' as $$
declare
  v public.procedures;
begin
  if auth.uid() is not null and not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to create a procedure.';
  end if;
  insert into public.procedures (id, job_id, title, owner_area, regulated)
  values (_id, _job_id, _title, _owner_area, coalesce(_regulated, false))
  returning * into v;
  perform public.log_evidence('procedure:created', _job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _id, 'regulated', v.regulated), null, null, array['PRC-1']);
  return v;
end;
$$;

-- Draft a new version with its steps (a JSON array of step objects). Used by people with Admin settings
-- or the procedure's owner area, and by a nightly run through the service role (PRC-3).
create function public.draft_procedure_version(_procedure_id text, _summary text, _steps jsonb,
                                               _change_link text default null)
returns integer
language plpgsql security definer set search_path = '' as $$
declare
  v_proc public.procedures;
  v_version integer;
  v_step jsonb;
  v_position integer := 0;
begin
  select * into v_proc from public.procedures where id = _procedure_id;
  if v_proc.id is null then
    raise exception 'There is no procedure "%".', _procedure_id;
  end if;
  if auth.uid() is not null and not (public.has_area('admin_settings') or public.has_area(v_proc.owner_area)) then
    raise exception 'You need Admin settings or the procedure''s own area to draft it.';
  end if;
  if coalesce(trim(_summary), '') = '' then
    raise exception 'A procedure version needs a summary of what changed.';
  end if;
  select coalesce(max(version), 0) + 1 into v_version from public.procedure_versions where procedure_id = _procedure_id;
  insert into public.procedure_versions (procedure_id, version, summary, change_link, drafted_by)
  values (_procedure_id, v_version, _summary, _change_link, auth.uid());
  for v_step in select * from jsonb_array_elements(_steps) loop
    v_position := v_position + 1;
    insert into public.procedure_steps (procedure_id, version, id, position, what, who, location, mode,
                                        clause_refs, controls, evidence_actions, flag_key, alias)
    values (_procedure_id, v_version, v_step ->> 'id', v_position, v_step ->> 'what', v_step ->> 'who',
            v_step ->> 'location', v_step ->> 'mode',
            coalesce(array(select jsonb_array_elements_text(v_step -> 'clause_refs')), '{}'),
            coalesce(array(select jsonb_array_elements_text(v_step -> 'controls')), '{}'),
            coalesce(array(select jsonb_array_elements_text(v_step -> 'evidence_actions')), '{}'),
            v_step ->> 'flag_key', v_step ->> 'alias');
  end loop;
  perform public.log_evidence('procedure:drafted', v_proc.job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _procedure_id, 'version', v_version, 'steps', v_position),
    null, null, array['PRC-3']);
  return v_version;
end;
$$;

create function public.procedure_take_effect(_procedure_id text, _version integer)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  update public.procedure_versions set status = 'superseded'
   where procedure_id = _procedure_id and status = 'accepted';
  update public.procedure_versions set status = 'accepted'
   where procedure_id = _procedure_id and version = _version;
end;
$$;

create function public.accept_procedure_version(_procedure_id text, _version integer)
returns text
language plpgsql security definer set search_path = '' as $$
declare
  v_proc public.procedures;
  v_ver public.procedure_versions;
begin
  select * into v_proc from public.procedures where id = _procedure_id;
  if v_proc.id is null then raise exception 'There is no procedure "%".', _procedure_id; end if;
  if not (public.has_area(v_proc.owner_area) or public.has_area('admin_settings')) then
    raise exception 'Only the procedure''s owner (or Admin settings) accepts it (Plumbline PRC-4).';
  end if;
  select * into v_ver from public.procedure_versions where procedure_id = _procedure_id and version = _version;
  if v_ver.procedure_id is null then raise exception 'There is no such procedure version.'; end if;
  if v_ver.status <> 'draft' then raise exception 'Only a draft can be accepted.'; end if;
  if v_ver.accepted_by is not null then raise exception 'This version is already accepted.'; end if;
  if v_ver.drafted_by = auth.uid() then
    raise exception 'Nobody accepts their own draft (Plumbline PRC-4).';
  end if;
  update public.procedure_versions set accepted_by = auth.uid(), accepted_at = now()
   where procedure_id = _procedure_id and version = _version;
  perform public.log_evidence('procedure:accepted', v_proc.job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _procedure_id, 'version', _version, 'regulated', v_proc.regulated),
    null, null, array['PRC-4']);
  if v_proc.regulated then
    return 'awaiting co-sign';
  end if;
  perform public.procedure_take_effect(_procedure_id, _version);
  return 'accepted';
end;
$$;

create function public.cosign_procedure_version(_procedure_id text, _version integer)
returns text
language plpgsql security definer set search_path = '' as $$
declare
  v_proc public.procedures;
  v_ver public.procedure_versions;
  v_area text := coalesce(public.param_text('procedures.cosign_area'), 'risk_compliance');
begin
  if not public.has_area(v_area) then
    raise exception 'Only the risk owner co-signs a regulated procedure (Plumbline PRC-4).';
  end if;
  select * into v_proc from public.procedures where id = _procedure_id;
  select * into v_ver from public.procedure_versions where procedure_id = _procedure_id and version = _version;
  if v_ver.procedure_id is null then raise exception 'There is no such procedure version.'; end if;
  if not v_proc.regulated then raise exception 'Only a regulated procedure needs a co-sign.'; end if;
  if v_ver.status <> 'draft' or v_ver.accepted_by is null then
    raise exception 'The job owner accepts first; then the co-sign.';
  end if;
  if auth.uid() in (v_ver.drafted_by, v_ver.accepted_by) then
    raise exception 'The co-signer must be someone other than the drafter and the accepter (Plumbline PRC-4).';
  end if;
  update public.procedure_versions set cosigned_by = auth.uid(), cosigned_at = now()
   where procedure_id = _procedure_id and version = _version;
  perform public.procedure_take_effect(_procedure_id, _version);
  perform public.log_evidence('procedure:cosigned', v_proc.job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _procedure_id, 'version', _version), null, null, array['PRC-4']);
  return 'accepted';
end;
$$;

create function public.reject_procedure_version(_procedure_id text, _version integer, _reason text)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_proc public.procedures;
  v_area text := coalesce(public.param_text('procedures.cosign_area'), 'risk_compliance');
begin
  select * into v_proc from public.procedures where id = _procedure_id;
  if v_proc.id is null then raise exception 'There is no procedure "%".', _procedure_id; end if;
  if not (public.has_area(v_proc.owner_area) or public.has_area('admin_settings') or public.has_area(v_area)) then
    raise exception 'Only the procedure''s owner, Admin settings or the risk owner rejects a draft.';
  end if;
  if coalesce(trim(_reason), '') = '' then
    raise exception 'A rejection needs a reason (Plumbline PRC-4).';
  end if;
  update public.procedure_versions
     set status = 'rejected', rejected_by = auth.uid(), rejected_at = now(), rejected_reason = _reason
   where procedure_id = _procedure_id and version = _version and status = 'draft';
  if not found then raise exception 'Only a draft can be rejected.'; end if;
  perform public.log_evidence('procedure:rejected', v_proc.job_id, 'procedure', null, null,
    jsonb_build_object('procedure_id', _procedure_id, 'version', _version, 'reason', _reason),
    null, null, array['PRC-4']);
end;
$$;

-- PRC-5: the flags guard from the flags module, plus: moving up needs an accepted procedure version
-- that names the flag, unless the flag's gate is a grandfather record.
create or replace function public.feature_flags_guard() returns trigger
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
    if not exists (select 1 from public.evidence_log e where e.id = new.gate_ref and e.action = 'gate:grandfathered')
       and not exists (
         select 1 from public.procedure_steps s
         join public.procedure_versions v on v.procedure_id = s.procedure_id and v.version = s.version
         where s.flag_key = new.key and v.status = 'accepted'
       ) then
      raise exception 'Turning a switch up needs an accepted procedure that describes it (Plumbline PRC-5).';
    end if;
  end if;
  new.updated_by := auth.uid();
  new.updated_at := now();
  return new;
end;
$$;

revoke all on function public.create_procedure(text, text, text, text, boolean),
  public.draft_procedure_version(text, text, jsonb, text), public.procedure_take_effect(text, integer),
  public.accept_procedure_version(text, integer), public.cosign_procedure_version(text, integer),
  public.reject_procedure_version(text, integer, text), public.procedure_versions_guard(),
  public.procedure_steps_guard() from public, anon;
revoke all on function public.procedure_take_effect(text, integer), public.procedure_versions_guard(),
  public.procedure_steps_guard() from authenticated;
grant execute on function public.create_procedure(text, text, text, text, boolean),
  public.draft_procedure_version(text, text, jsonb, text), public.accept_procedure_version(text, integer),
  public.cosign_procedure_version(text, integer), public.reject_procedure_version(text, integer, text)
  to authenticated;
grant execute on function public.create_procedure(text, text, text, text, boolean),
  public.draft_procedure_version(text, text, jsonb, text) to service_role;
