-- Plumbline kit 0.1.0 · module: evidence log
-- Clauses: DAT-3 (append-only evidence log with the required fields), DAT-4 (references, never copies
-- of personal data), DAT-10 (one retention exception).
--
-- Each entry records when, who acted (a person, an outsider, the system, or an agent with its model),
-- the job and procedure step, the clause versions in force, the flag and its state, the object and its
-- version, and who approved. Nothing can change or remove an entry: triggers refuse UPDATE, DELETE and
-- TRUNCATE for every role, and no role holds write grants other than INSERT for the service role. The
-- one exception is the retention job deleting entries older than retention.evidence_years, when the
-- organisation has switched retention on.
--
-- Write evidence with public.log_evidence(...) from the database, or an insert with the service role
-- from server code. Never write free text that holds personal data: write ids and references.
--
-- The read policy is added by the identity module.

create table public.evidence_log (
  id uuid primary key default gen_random_uuid(),
  at timestamptz not null default now(),
  actor_id uuid,
  actor_type text not null default 'person' check (actor_type in ('person', 'outsider', 'system', 'agent')),
  agent_model text,
  action text not null check (length(action) > 0),
  job_id text,
  step_id text,
  procedure_version integer,
  clause_refs text[] not null default '{}',
  flag_key text,
  flag_state text check (flag_state in ('off', 'shadow', 'live')),
  target_type text,
  target_id uuid,
  before jsonb,
  after jsonb,
  object_version text,
  approved_by uuid,
  check (actor_type <> 'agent' or agent_model is not null)
);
create index evidence_log_at_idx on public.evidence_log (at desc);
create index evidence_log_job_at_idx on public.evidence_log (job_id, at desc);
create index evidence_log_flag_idx on public.evidence_log (flag_key) where flag_key is not null;
alter table public.evidence_log enable row level security;

-- Who acted is stamped by the database whenever a signed-in person writes, so it cannot be spoofed.
create function public.stamp_evidence() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is not null then
    new.actor_id := auth.uid();
    new.actor_type := 'person';
    new.at := now();
  elsif new.actor_id is null and new.actor_type = 'person' then
    new.actor_type := 'system';
  end if;
  return new;
end;
$$;
create trigger evidence_log_stamp before insert on public.evidence_log
  for each row execute function public.stamp_evidence();

create function public.log_evidence(
  _action text,
  _job_id text default null,
  _target_type text default null,
  _target_id uuid default null,
  _before jsonb default null,
  _after jsonb default null,
  _actor_id uuid default null,
  _step_id text default null,
  _clause_refs text[] default '{}',
  _flag_key text default null,
  _flag_state text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
begin
  insert into public.evidence_log (actor_id, action, job_id, target_type, target_id, before, after,
                                   step_id, clause_refs, flag_key, flag_state)
  values (coalesce(_actor_id, auth.uid()), _action, _job_id, _target_type, _target_id, _before, _after,
          _step_id, coalesce(_clause_refs, '{}'), _flag_key, _flag_state)
  returning id into v_id;
  return v_id;
end;
$$;

-- Nothing changes or removes an entry, except the retention job past the retention period.
create function public.forbid_evidence_change() returns trigger
language plpgsql set search_path = '' as $$
begin
  if tg_op = 'DELETE'
     and current_setting('app.retention_run', true) = 'on'
     and old.at < now() - make_interval(years => public.param_int('retention.evidence_years')) then
    return old;
  end if;
  raise exception 'The evidence log is append-only: entries cannot be changed or removed (Plumbline DAT-3).';
end;
$$;
create trigger evidence_log_no_update_delete before update or delete on public.evidence_log
  for each row execute function public.forbid_evidence_change();
create trigger evidence_log_no_truncate before truncate on public.evidence_log
  for each statement execute function public.forbid_evidence_change();

revoke all on public.evidence_log from public, anon, authenticated, service_role;
grant select on public.evidence_log to authenticated;
grant select, insert on public.evidence_log to service_role;

revoke all on function public.log_evidence(text, text, text, uuid, jsonb, jsonb, uuid, text, text[], text, text),
  public.stamp_evidence(), public.forbid_evidence_change() from public, anon, authenticated;
grant execute on function public.log_evidence(text, text, text, uuid, jsonb, jsonb, uuid, text, text[], text, text)
  to service_role;

select public.log_evidence('kit:evidence-log-created', null, 'system', null, null,
  jsonb_build_object('kit_version', '0.1.0'), null, null, array['DAT-3']);
