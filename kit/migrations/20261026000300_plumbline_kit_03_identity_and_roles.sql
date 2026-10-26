-- Plumbline kit 0.1.0 · module: identity, roles and access areas
-- Clauses: IAM-1 (only the organisation's Google Workspace accounts, checked on the server), IAM-3
-- (access decided by database functions; nobody grants access to themselves), IAM-4 (multi-factor),
-- IAM-5 (writes through security-definer functions), IAM-7 (access follows governed roles), IAM-8
-- (who assigns which role, with reason, review date and incompatible pairs).
--
--   access_areas            what a role can reach; the kit seeds general, admin_settings, risk_compliance
--   roles                   the role register: rank, whether the board appoints it, whether its holders
--                           may assign operational roles, whether it reaches every area
--   role_areas              each role's access areas
--   role_incompatibilities  pairs nobody holds together
--   role_assignments        who holds which role: assigned_by, reason, since, until, revoked_*
--   profiles, invitations   people, and the invitation that lets each one sign up
--
-- A person's access is the union of their active roles' areas; nothing is granted to a person directly.
-- An assignment lapses at its `until` date unless re-confirmed, except the last System administrator,
-- so nobody is locked out. Board-appointed roles are recorded only by a System administrator;
-- operational roles by the holder of any role that assigns_operational. Nobody assigns, re-confirms or
-- removes their own role. A guard trigger enforces this on every write path; an audit trigger writes
-- the evidence.
--
-- The app seeds its own areas, roles, role_areas and incompatibilities in its own migration. The kit
-- seeds only what its functions need.

-- Areas and roles ---------------------------------------------------------------------------------

create table public.access_areas (
  key text primary key check (key ~ '^[a-z_]+$'),
  label text not null,
  description text not null default ''
);
insert into public.access_areas (key, label, description) values
  ('general', 'General', 'Everyone signed in with an active role'),
  ('admin_settings', 'Admin settings', 'People, roles, switches and procedures'),
  ('risk_compliance', 'Risk and compliance', 'The risk owner''s work: co-signs, controls, obligations');

create table public.roles (
  key text primary key check (key ~ '^[a-z_]+$'),
  label text not null,
  rank integer not null check (rank between 1 and 4),
  board_appointed boolean not null default false,
  assigns_operational boolean not null default false,
  all_areas boolean not null default false,
  description text not null default ''
);
insert into public.roles (key, label, rank, board_appointed, assigns_operational, all_areas, description) values
  ('system_administrator', 'System administrator', 4, true, true, true, 'Builds and runs the app; reaches every area');

create table public.role_areas (
  role_key text not null references public.roles (key),
  area_key text not null references public.access_areas (key),
  primary key (role_key, area_key)
);

create table public.role_incompatibilities (
  role_a text not null references public.roles (key),
  role_b text not null references public.roles (key),
  reason text not null,
  primary key (role_a, role_b),
  check (role_a < role_b)
);

-- People ------------------------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key,
  full_name text,
  email text not null unique check (email = lower(email)),
  active boolean not null default true,
  start_date date not null default current_date,
  deactivated_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  email text not null check (email = lower(email)),
  role_key text not null references public.roles (key),
  invited_by uuid,
  invited_at timestamptz not null default now(),
  accepted_at timestamptz,
  revoked_at timestamptz
);
create unique index invitations_live_email_idx on public.invitations (email)
  where accepted_at is null and revoked_at is null;

create table public.role_assignments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id),
  role_key text not null references public.roles (key),
  assigned_by uuid,
  reason text not null check (length(trim(reason)) > 0),
  since date not null default current_date,
  until date not null,
  revoked_at timestamptz,
  revoked_by uuid,
  revoke_reason text,
  check (until >= since),
  check (revoked_at is null or length(trim(coalesce(revoke_reason, ''))) > 0)
);
create unique index role_assignments_one_active on public.role_assignments (user_id, role_key)
  where revoked_at is null;

-- Access functions --------------------------------------------------------------------------------

-- A session counts only with a second factor (aal2), unless the organisation has switched the
-- requirement off. No signed-in person (the service role, postgres) always counts.
create function public.mfa_ok() returns boolean
language sql stable security definer set search_path = '' as $$
  select auth.uid() is null
      or not public.param_bool('identity.require_mfa')
      or coalesce(auth.jwt() ->> 'aal', '') = 'aal2'
$$;

-- Which assignments give access right now. Lapsed at `until`, except the last System administrator.
create function public.assignment_active(_a public.role_assignments) returns boolean
language sql stable security definer set search_path = '' as $$
  select _a.revoked_at is null
     and exists (select 1 from public.profiles p where p.id = _a.user_id and p.active)
     and (_a.until >= current_date
          or (_a.role_key = 'system_administrator' and not exists (
                select 1 from public.role_assignments o join public.profiles p on p.id = o.user_id
                where o.role_key = 'system_administrator' and o.id <> _a.id and o.revoked_at is null
                  and o.until >= current_date and p.active)))
$$;

create function public.my_roles() returns setof text
language sql stable security definer set search_path = '' as $$
  select a.role_key from public.role_assignments a
  where public.mfa_ok() and a.user_id = auth.uid() and public.assignment_active(a)
  order by a.role_key
$$;

create function public.has_role(_role text) returns boolean
language sql stable security definer set search_path = '' as $$
  select public.mfa_ok() and exists (
    select 1 from public.role_assignments a
    where a.user_id = auth.uid() and a.role_key = _role and public.assignment_active(a))
$$;

create function public.my_rank() returns integer
language sql stable security definer set search_path = '' as $$
  select case when public.mfa_ok() then coalesce(max(r.rank), 0) else 0 end
  from public.role_assignments a join public.roles r on r.key = a.role_key
  where a.user_id = auth.uid() and public.assignment_active(a)
$$;

create function public.has_area(_area text) returns boolean
language sql stable security definer set search_path = '' as $$
  select public.mfa_ok() and exists (
    select 1 from public.role_assignments a
    join public.roles r on r.key = a.role_key
    left join public.role_areas ra on ra.role_key = a.role_key and ra.area_key = _area
    where a.user_id = auth.uid() and public.assignment_active(a)
      and (ra.area_key is not null or (r.all_areas and exists (select 1 from public.access_areas x where x.key = _area))))
$$;

create function public.my_areas() returns setof text
language sql stable security definer set search_path = '' as $$
  select x.key from public.access_areas x where public.has_area(x.key) order by x.key
$$;

-- IAM-1: Google sign-in only from the organisation's Workspace domain, when one is set.
create function public.workspace_domain() returns text
language sql stable security definer set search_path = '' as $$
  select nullif(public.param_text('identity.workspace_domain'), '')
$$;

create function public.check_identity_domain() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_domain text := public.workspace_domain();
begin
  if v_domain is null then
    return new;
  end if;
  if new.provider = 'google'
     and coalesce(new.identity_data -> 'custom_claims' ->> 'hd', '') <> v_domain then
    raise exception 'Only % Google Workspace accounts can sign in (Plumbline IAM-1).', v_domain;
  end if;
  if lower(coalesce(new.identity_data ->> 'email', '')) not like '%@' || v_domain then
    raise exception 'Only % accounts can sign in (Plumbline IAM-1).', v_domain;
  end if;
  return new;
end;
$$;
create trigger check_identity_domain before insert on auth.identities
  for each row execute function public.check_identity_domain();

-- Assignment rules --------------------------------------------------------------------------------

-- The rules hold whichever path writes. The service role and postgres (no signed-in person) bypass the
-- assigner rules but not the data rules.
create function public.role_assignments_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_actor uuid := auth.uid();
  v_board boolean;
begin
  if tg_op = 'DELETE' then
    raise exception 'Role assignments are never deleted; remove a role instead (Plumbline IAM-8).';
  end if;
  if tg_op = 'UPDATE' and (new.user_id <> old.user_id or new.role_key <> old.role_key
                           or new.assigned_by is distinct from old.assigned_by or new.since <> old.since
                           or new.reason <> old.reason) then
    raise exception 'An assignment''s person, role, assigner, reason and start never change.';
  end if;
  if tg_op = 'UPDATE' and old.revoked_at is not null then
    raise exception 'A removed role stays removed; assign it again instead.';
  end if;
  if new.revoked_at is null and exists (
    select 1 from public.role_incompatibilities i
    join public.role_assignments o on o.user_id = new.user_id and o.revoked_at is null and o.id <> new.id
    where (i.role_a = new.role_key and i.role_b = o.role_key) or (i.role_b = new.role_key and i.role_a = o.role_key)
  ) then
    raise exception 'These two roles cannot be held by the same person (Plumbline IAM-8).';
  end if;
  if tg_op = 'UPDATE' and new.revoked_at is not null and new.role_key = 'system_administrator' and not exists (
    select 1 from public.role_assignments o join public.profiles p on p.id = o.user_id
    where o.role_key = 'system_administrator' and o.id <> new.id and o.revoked_at is null
      and o.until >= current_date and p.active
  ) then
    raise exception 'The last System administrator cannot be removed.';
  end if;
  if v_actor is not null then
    if new.user_id = v_actor then
      raise exception 'Nobody assigns, re-confirms or removes their own role (Plumbline IAM-3).';
    end if;
    select board_appointed into v_board from public.roles where key = new.role_key;
    if v_board and not public.has_role('system_administrator') then
      raise exception 'Only a System administrator records a board-appointed role (Plumbline IAM-8).';
    end if;
    if not v_board and not exists (
      select 1 from public.role_assignments a join public.roles r on r.key = a.role_key
      where a.user_id = v_actor and r.assigns_operational and public.assignment_active(a) and public.mfa_ok()
    ) then
      raise exception 'Your roles do not allow assigning this role (Plumbline IAM-8).';
    end if;
  end if;
  if tg_op = 'INSERT' then
    new.assigned_by := coalesce(v_actor, new.assigned_by);
  elsif new.revoked_at is not null and old.revoked_at is null then
    new.revoked_by := coalesce(v_actor, new.revoked_by);
    new.revoked_at := now();
  end if;
  return new;
end;
$$;
create trigger role_assignments_guard before insert or update or delete on public.role_assignments
  for each row execute function public.role_assignments_guard();

create function public.role_assignments_audit() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    perform public.log_evidence('role:assigned', null, 'user', new.user_id, null,
      jsonb_build_object('role', new.role_key, 'reason', new.reason, 'since', new.since, 'until', new.until),
      null, null, array['IAM-8']);
  elsif new.revoked_at is not null and old.revoked_at is null then
    perform public.log_evidence('role:revoked', null, 'user', new.user_id,
      jsonb_build_object('role', old.role_key), jsonb_build_object('role', new.role_key, 'reason', new.revoke_reason),
      null, null, array['IAM-8']);
  elsif new.until <> old.until then
    perform public.log_evidence('role:reconfirmed', null, 'user', new.user_id,
      jsonb_build_object('role', old.role_key, 'until', old.until),
      jsonb_build_object('role', new.role_key, 'until', new.until), null, null, array['IAM-8']);
  end if;
  return new;
end;
$$;
create trigger role_assignments_audit after insert or update on public.role_assignments
  for each row execute function public.role_assignments_audit();

-- Write paths for people --------------------------------------------------------------------------

create function public.assign_role(_user_id uuid, _role text, _reason text, _until date default null)
returns public.role_assignments
language plpgsql security definer set search_path = '' as $$
declare
  v public.role_assignments;
begin
  if not exists (select 1 from public.profiles where id = _user_id and active) then
    raise exception 'That person does not exist or is deactivated.';
  end if;
  insert into public.role_assignments (user_id, role_key, reason, until)
  values (_user_id, _role, _reason, coalesce(_until, public.review_until()))
  returning * into v;
  return v;
end;
$$;

create function public.revoke_role(_assignment_id uuid, _reason text) returns public.role_assignments
language plpgsql security definer set search_path = '' as $$
declare
  v public.role_assignments;
begin
  update public.role_assignments set revoked_at = now(), revoke_reason = _reason
   where id = _assignment_id and revoked_at is null returning * into v;
  if v.id is null then raise exception 'That role is not currently held.'; end if;
  return v;
end;
$$;

create function public.reconfirm_role(_assignment_id uuid, _until date default null)
returns public.role_assignments
language plpgsql security definer set search_path = '' as $$
declare
  v public.role_assignments;
begin
  update public.role_assignments set until = coalesce(_until, public.review_until())
   where id = _assignment_id and revoked_at is null returning * into v;
  if v.id is null then raise exception 'That role is not currently held.'; end if;
  return v;
end;
$$;

-- Sign-up turns a pending invitation into a profile and a role assignment. No invitation, no account.
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_email text := lower(new.email);
  v_inv public.invitations;
begin
  select * into v_inv from public.invitations
  where email = v_email and accepted_at is null and revoked_at is null
  order by invited_at desc limit 1;
  if v_inv.id is null then
    raise exception 'This account is not on the invitation list.';
  end if;
  insert into public.profiles (id, full_name, email, active, start_date)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', v_email),
          v_email, true, (now() at time zone coalesce(public.param_text('app.timezone'), 'UTC'))::date);
  insert into public.role_assignments (user_id, role_key, assigned_by, reason, until)
  values (new.id, v_inv.role_key, v_inv.invited_by, 'Invitation accepted', public.review_until());
  update public.invitations set accepted_at = now() where id = v_inv.id;
  perform public.log_evidence('invitation:accepted', null, 'invitation', v_inv.id,
    jsonb_build_object('role', v_inv.role_key, 'accepted_at', null),
    jsonb_build_object('role', v_inv.role_key, 'accepted_at', now(), 'user_id', new.id), new.id, null, array['IAM-2']);
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create function public.admin_invite(_email text, _role text) returns public.invitations
language plpgsql security definer set search_path = '' as $$
declare
  v_email text := lower(trim(_email));
  v_board boolean;
  v_domain text := public.workspace_domain();
  v_inv public.invitations;
begin
  if not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to send invitations.';
  end if;
  select board_appointed into v_board from public.roles where key = _role;
  if v_board is null then raise exception 'Unknown role "%".', _role; end if;
  if v_board and not public.has_role('system_administrator') then
    raise exception 'Only a System administrator invites someone into a board-appointed role (Plumbline IAM-8).';
  end if;
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    raise exception 'That does not look like a valid email address.';
  end if;
  if v_domain is not null and v_email not like '%@' || v_domain then
    raise exception 'Invitations are only for @% addresses (Plumbline IAM-1).', v_domain;
  end if;
  if exists (select 1 from public.profiles where email = v_email) then
    raise exception 'That email already belongs to an existing person.';
  end if;
  if exists (select 1 from public.invitations where email = v_email and accepted_at is null and revoked_at is null) then
    raise exception 'There is already a pending invitation for that email.';
  end if;
  insert into public.invitations (email, role_key, invited_by)
  values (v_email, _role, auth.uid())
  returning * into v_inv;
  perform public.log_evidence('invitation:created', null, 'invitation', v_inv.id, null,
    jsonb_build_object('role', _role), null, null, array['IAM-2']);
  return v_inv;
end;
$$;

create function public.admin_revoke_invitation(_id uuid) returns public.invitations
language plpgsql security definer set search_path = '' as $$
declare
  v_before public.invitations;
  v_after public.invitations;
begin
  if not public.has_area('admin_settings') then
    raise exception 'You need Admin settings access to revoke invitations.';
  end if;
  select * into v_before from public.invitations where id = _id;
  if v_before.id is null then raise exception 'That invitation no longer exists.'; end if;
  if (select board_appointed from public.roles where key = v_before.role_key)
     and not public.has_role('system_administrator') then
    raise exception 'Only a System administrator revokes an invitation into a board-appointed role.';
  end if;
  if v_before.accepted_at is not null then raise exception 'That invitation has already been accepted.'; end if;
  if v_before.revoked_at is not null then raise exception 'That invitation is already revoked.'; end if;
  update public.invitations set revoked_at = now() where id = _id returning * into v_after;
  perform public.log_evidence('invitation:revoked', null, 'invitation', _id,
    jsonb_build_object('role', v_before.role_key, 'revoked_at', null),
    jsonb_build_object('role', v_after.role_key, 'revoked_at', v_after.revoked_at), null, null, array['IAM-2']);
  return v_after;
end;
$$;

create function public.admin_deactivate_user(_user_id uuid) returns public.profiles
language plpgsql security definer set search_path = '' as $$
declare
  v_before public.profiles;
  v_after public.profiles;
begin
  if not public.has_role('system_administrator') then
    raise exception 'Only a System administrator may deactivate people.';
  end if;
  if _user_id = auth.uid() then
    raise exception 'You cannot deactivate yourself.';
  end if;
  select * into v_before from public.profiles where id = _user_id;
  if v_before.id is null then raise exception 'That person does not exist.'; end if;
  if not v_before.active then raise exception 'That person is already deactivated.'; end if;
  update public.role_assignments set revoked_at = now(), revoke_reason = 'Deactivated'
   where user_id = _user_id and revoked_at is null;
  update public.profiles set active = false, deactivated_at = now() where id = _user_id returning * into v_after;
  perform public.log_evidence('person:deactivated', null, 'user', _user_id,
    jsonb_build_object('active', true), jsonb_build_object('active', false, 'deactivated_at', v_after.deactivated_at),
    null, null, array['IAM-8']);
  return v_after;
end;
$$;

create function public.admin_reactivate_user(_user_id uuid, _role text) returns public.profiles
language plpgsql security definer set search_path = '' as $$
declare
  v_before public.profiles;
  v_after public.profiles;
begin
  if not public.has_role('system_administrator') then
    raise exception 'Only a System administrator may reactivate people.';
  end if;
  select * into v_before from public.profiles where id = _user_id;
  if v_before.id is null then raise exception 'That person does not exist.'; end if;
  if v_before.active then raise exception 'That person is already active.'; end if;
  update public.profiles set active = true, deactivated_at = null where id = _user_id returning * into v_after;
  insert into public.role_assignments (user_id, role_key, reason, until)
  values (_user_id, _role, 'Reactivated', public.review_until());
  perform public.log_evidence('person:reactivated', null, 'user', _user_id,
    jsonb_build_object('active', false), jsonb_build_object('active', true, 'role', _role),
    null, null, array['IAM-8']);
  return v_after;
end;
$$;

-- Retention (DAT-10): counts what is past its period; removes evidence only when switched on.
create function public.apply_retention() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_enforced boolean := public.param_bool('retention.enforced');
  v_evidence int;
  v_staff int;
  v_result jsonb;
begin
  select count(*) into v_evidence from public.evidence_log
   where at < now() - make_interval(years => public.param_int('retention.evidence_years'));
  select count(*) into v_staff from public.profiles
   where not active and deactivated_at < now() - make_interval(days => public.param_int('retention.former_staff_days'));
  if v_enforced then
    perform set_config('app.retention_run', 'on', true);
    delete from public.evidence_log
     where at < now() - make_interval(years => public.param_int('retention.evidence_years'));
    perform set_config('app.retention_run', 'off', true);
  end if;
  v_result := jsonb_build_object('enforced', v_enforced, 'evidence_entries', v_evidence,
    'former_staff_accounts', v_staff, 'former_staff_removed', 0);
  perform public.log_evidence(case when v_enforced then 'retention:applied' else 'retention:counted' end,
    null, 'system', null, null, v_result, null, null, array['DAT-10']);
  return v_result;
end;
$$;

-- Row-level security: read through policies, write only through the functions above --------------

alter table public.access_areas enable row level security;
alter table public.roles enable row level security;
alter table public.role_areas enable row level security;
alter table public.role_incompatibilities enable row level security;
alter table public.role_assignments enable row level security;
alter table public.profiles enable row level security;
alter table public.invitations enable row level security;

revoke all on public.access_areas, public.roles, public.role_areas, public.role_incompatibilities,
  public.role_assignments, public.profiles, public.invitations from public, anon, authenticated;
grant select on public.access_areas, public.roles, public.role_areas, public.role_incompatibilities,
  public.role_assignments, public.profiles, public.invitations to authenticated;
grant all on public.access_areas, public.roles, public.role_areas, public.role_incompatibilities,
  public.profiles, public.invitations to service_role;
grant select, insert, update on public.role_assignments to service_role;

create policy "access_areas readable with general" on public.access_areas
  for select to authenticated using (public.has_area('general'));
create policy "roles readable with general" on public.roles
  for select to authenticated using (public.has_area('general'));
create policy "role_areas readable with general" on public.role_areas
  for select to authenticated using (public.has_area('general'));
create policy "role_incompatibilities readable with general" on public.role_incompatibilities
  for select to authenticated using (public.has_area('general'));
create policy "role_assignments own or admin_settings" on public.role_assignments
  for select to authenticated using (user_id = auth.uid() or public.has_area('admin_settings'));
create policy "profiles own or general" on public.profiles
  for select to authenticated using (id = auth.uid() or public.has_area('general'));
create policy "invitations admin_settings" on public.invitations
  for select to authenticated using (public.has_area('admin_settings'));

-- The earlier modules' read policies, now that has_area exists.
create policy "parameters readable with general" on public.parameters
  for select to authenticated using (public.has_area('general'));
create policy "evidence_log readable with admin_settings or risk_compliance" on public.evidence_log
  for select to authenticated using (public.has_area('admin_settings') or public.has_area('risk_compliance'));

revoke all on function public.mfa_ok(), public.assignment_active(public.role_assignments), public.my_roles(),
  public.has_role(text), public.my_rank(), public.has_area(text), public.my_areas(), public.workspace_domain(),
  public.check_identity_domain(), public.role_assignments_guard(), public.role_assignments_audit(),
  public.assign_role(uuid, text, text, date), public.revoke_role(uuid, text), public.reconfirm_role(uuid, date),
  public.handle_new_user(), public.admin_invite(text, text), public.admin_revoke_invitation(uuid),
  public.admin_deactivate_user(uuid), public.admin_reactivate_user(uuid, text), public.apply_retention()
  from public, anon;
revoke all on function public.check_identity_domain(), public.role_assignments_guard(),
  public.role_assignments_audit(), public.handle_new_user(), public.apply_retention(),
  public.assignment_active(public.role_assignments) from authenticated;
grant execute on function public.mfa_ok(), public.my_roles(), public.has_role(text), public.my_rank(),
  public.has_area(text), public.my_areas(), public.workspace_domain(), public.assign_role(uuid, text, text, date),
  public.revoke_role(uuid, text), public.reconfirm_role(uuid, date), public.admin_invite(text, text),
  public.admin_revoke_invitation(uuid), public.admin_deactivate_user(uuid), public.admin_reactivate_user(uuid, text)
  to authenticated;
grant execute on function public.mfa_ok(), public.my_roles(), public.has_role(text), public.my_rank(),
  public.has_area(text), public.my_areas(), public.workspace_domain(), public.apply_retention() to service_role;
