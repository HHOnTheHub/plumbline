-- Plumbline kit 0.1.0 · module: parameters
-- Clauses: GOV-8 (thresholds, periods and limits are parameters in approved clauses, not constants in
-- code), DAT-10 (retention periods as parameters).
--
-- Every value the database works to lives here, naming the clause that sets it. An app changes a value
-- by a migration that follows the policy change, never by editing code. The kit seeds its own defaults;
-- an app overrides them in its own migration with `update public.parameters ...`.
--
-- The read policy is added by the identity module, which defines has_area(). Until then the table is
-- readable only by the service role.

create table public.parameters (
  key text primary key check (key ~ '^[a-z_]+(\.[a-z_]+)+$'),
  value jsonb not null,
  clause text not null check (clause ~ '^[A-Z]{2,4}-[0-9]+(\.[0-9]+)*$'),
  description text not null,
  updated_at timestamptz not null default now()
);
alter table public.parameters enable row level security;
revoke all on public.parameters from public, anon, authenticated;
grant select on public.parameters to authenticated, service_role;

insert into public.parameters (key, value, clause, description) values
  ('app.timezone', '"UTC"', 'GOV-8', 'Time zone for the dates the database stamps (for example a start date)'),
  ('identity.workspace_domain', 'null', 'IAM-1', 'Only Google accounts of this domain sign in and are invited; null turns the check off'),
  ('identity.require_mfa', 'true', 'IAM-4', 'Whether a session needs a second factor (aal2) before it reaches any area'),
  ('roles.review_months', '6', 'IAM-8', 'Months a new or re-confirmed role assignment runs before it lapses'),
  ('roles.warning_days', '30', 'IAM-8', 'Days before an assignment lapses that people are warned'),
  ('retention.enforced', 'false', 'DAT-10', 'Whether the retention job removes records, or only counts them'),
  ('retention.evidence_years', '7', 'DAT-10', 'Years an evidence log entry is kept'),
  ('retention.former_staff_days', '90', 'DAT-10', 'Days a former staff account is kept after deactivation'),
  ('procedures.cosign_area', '"risk_compliance"', 'PRC-4', 'Access area whose holder co-signs a regulated procedure');

create function public.param_int(_key text) returns integer
language sql stable security definer set search_path = '' as $$
  select (value #>> '{}')::integer from public.parameters where key = _key
$$;

create function public.param_bool(_key text) returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((select (value #>> '{}')::boolean from public.parameters where key = _key), false)
$$;

create function public.param_text(_key text) returns text
language sql stable security definer set search_path = '' as $$
  select value #>> '{}' from public.parameters where key = _key
$$;

create function public.review_until() returns date
language sql stable security definer set search_path = '' as $$
  select (current_date + make_interval(months => public.param_int('roles.review_months')))::date
$$;

revoke all on function public.param_int(text), public.param_bool(text), public.param_text(text),
  public.review_until() from public, anon;
grant execute on function public.param_int(text), public.param_bool(text), public.param_text(text),
  public.review_until() to authenticated, service_role;
