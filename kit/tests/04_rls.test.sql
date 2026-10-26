-- Row-level security across the kit's tables (DAT-1, DAT-2, IAM-5): visitors reach nothing; people read
-- only what their areas allow; nobody writes a kit table directly from the app.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('admin@example.com', 'system_administrator') as admin,
  tests.make_user('member@example.com', 'test_member') as member,
  tests.make_user('other@example.com', 'test_member') as other;
grant select on u to authenticated, anon;

-- Every table in public has row-level security on.
select is((select count(*)::int from pg_tables where schemaname = 'public' and not rowsecurity), 0,
  'every table in public has row-level security on');

-- Visitors: no grants at all.
select tests.act_as_anon();
select throws_ok($$select count(*) from public.profiles$$, '42501', null, 'a visitor cannot read profiles');
select throws_ok($$select count(*) from public.role_assignments$$, '42501', null, 'a visitor cannot read role assignments');
select throws_ok($$select count(*) from public.evidence_log$$, '42501', null, 'a visitor cannot read the evidence log');
select throws_ok($$select count(*) from public.feature_flags$$, '42501', null, 'a visitor cannot read flags');
select throws_ok($$select count(*) from public.procedures$$, '42501', null, 'a visitor cannot read procedures');
select throws_ok($$select public.has_area('general')$$, '42501', null, 'a visitor cannot call the access functions');

-- A member reads what General allows, and only their own role assignments.
select tests.act_as((select member from u));
select is((select count(*)::int from public.profiles), 3, 'a member reads the people list');
select is((select count(*)::int from public.role_assignments), 1, 'a member reads only their own role assignments');
select is((select count(*)::int from public.invitations), 0, 'a member reads no invitations');

-- A person without any active role reads only their own profile.
select tests.act_as_postgres();
set local session_replication_role = replica;
update public.role_assignments set since = current_date - 30, until = current_date - 1 where user_id = (select other from u);
set local session_replication_role = origin;
select tests.act_as((select other from u));
select is((select count(*)::int from public.profiles), 1, 'with no active role, only your own profile');
select is((select count(*)::int from public.feature_flags), 0, 'and no flags');

-- Nobody writes the tables directly, not even a System administrator.
select tests.act_as((select admin from u));
select throws_ok($$insert into public.profiles (id, email) values (gen_random_uuid(), 'x@example.com')$$, '42501', null,
  'profiles are not written directly');
select throws_ok($$update public.role_assignments set until = current_date + 365$$, '42501', null,
  'role assignments are not written directly');
select throws_ok($$insert into public.feature_flags (key, job_id, level, description) values ('x.record', 'X', 'record', 'x')$$,
  '42501', null, 'flags are not written directly');
select throws_ok($$insert into public.procedures (id, job_id, title, owner_area) values ('X1-P1', 'X1', 'x', 'general')$$,
  '42501', null, 'procedures are not written directly');
select throws_ok($$update public.parameters set value = 'true' where key = 'retention.enforced'$$, '42501', null,
  'parameters are not written directly');

select tests.act_as_postgres();
select * from finish();
rollback;
