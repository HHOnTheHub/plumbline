-- Kit module: identity, roles and access areas. IAM-1, IAM-3, IAM-4, IAM-7, IAM-8.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('admin@example.com', 'system_administrator') as admin,
  tests.make_user('lead@example.com', 'test_lead') as lead,
  tests.make_user('member@example.com', 'test_member') as member,
  tests.make_user('other@example.com', 'test_member') as other;
grant select on u to authenticated;

-- Sign-up needs an invitation.
select throws_ok($$insert into auth.users (id, email, aud, role) values (gen_random_uuid(), 'stranger@example.com', 'authenticated', 'authenticated')$$,
  'P0001', 'This account is not on the invitation list.', 'nobody signs up without an invitation');
select is((select role_key from public.role_assignments where user_id = (select member from u)), 'test_member',
  'an accepted invitation becomes a role assignment');
select is((select until from public.role_assignments where user_id = (select member from u)), public.review_until(),
  'the assignment runs for the review period');

-- Access follows roles.
select tests.act_as((select member from u));
select ok(public.has_area('general'), 'a member has General');
select ok(not public.has_area('admin_settings'), 'a member does not have Admin settings');
select is(array(select public.my_areas()), array['general'], 'my_areas lists what the roles allow');
select tests.act_as((select admin from u));
select ok(public.has_area('admin_settings') and public.has_area('risk_compliance'),
  'a System administrator reaches every area');
select ok(not public.has_area('no_such_area'), 'but not an area that does not exist');

-- Multi-factor (IAM-4).
select tests.act_as_aal1((select admin from u));
select ok(not public.has_area('general'), 'without a second factor, nobody reaches any area');
select is(public.my_rank(), 0, 'and has no rank');
select tests.act_as_postgres();
update public.parameters set value = 'false' where key = 'identity.require_mfa';
select tests.act_as_aal1((select admin from u));
select ok(public.has_area('general'), 'when the organisation switches MFA off, one factor is enough');
select tests.act_as_postgres();
update public.parameters set value = 'true' where key = 'identity.require_mfa';

-- Who assigns (IAM-3, IAM-8).
select tests.act_as((select member from u));
select throws_ok(format($$select public.assign_role(%L, 'test_runner', 'help')$$, (select other from u)), 'P0001',
  'Your roles do not allow assigning this role (Plumbline IAM-8).', 'a member cannot assign roles');
select tests.act_as((select lead from u));
select throws_ok(format($$select public.assign_role(%L, 'test_runner', 'more work')$$, (select lead from u)), 'P0001',
  'Nobody assigns, re-confirms or removes their own role (Plumbline IAM-3).', 'nobody assigns a role to themselves');
select lives_ok(format($$select public.assign_role(%L, 'test_runner', 'Runs the weekly checks')$$, (select other from u)),
  'a role that assigns operational roles can assign one');
select throws_ok(format($$select public.assign_role(%L, 'test_officer', 'appointed')$$, (select member from u)), 'P0001',
  'Only a System administrator records a board-appointed role (Plumbline IAM-8).',
  'a board-appointed role is recorded only by a System administrator');
select tests.act_as((select admin from u));
select throws_ok(format($$select public.assign_role(%L, 'test_officer', 'appointed')$$, (select other from u)), 'P0001',
  'These two roles cannot be held by the same person (Plumbline IAM-8).', 'incompatible roles cannot be combined');
select lives_ok(format($$select public.assign_role(%L, 'test_officer', 'Appointed by the board on 1 Nov')$$, (select member from u)),
  'a System administrator records a board appointment');
select ok(exists (select 1 from public.evidence_log where action = 'role:assigned' and target_id = (select member from u)
                  and actor_id = (select admin from u)), 'every assignment is evidenced with who made it');

-- Assignments are never deleted or rewritten.
select tests.act_as_postgres();
select throws_ok(format($$delete from public.role_assignments where user_id = %L$$, (select member from u)), 'P0001',
  'Role assignments are never deleted; remove a role instead (Plumbline IAM-8).', 'assignments are never deleted');
select throws_ok(format($$update public.role_assignments set reason = 'changed' where user_id = %L$$, (select member from u)), 'P0001',
  null, 'an assignment''s reason never changes');

-- Lapsing at the review date, except the last System administrator.
-- Back-date two assignments, as if a review date had passed (triggers off for this one setup step).
set local session_replication_role = replica;
update public.role_assignments set since = current_date - 30, until = current_date - 1
 where user_id in ((select member from u), (select admin from u));
set local session_replication_role = origin;
select tests.act_as((select member from u));
select ok(public.has_area('risk_compliance') = false and public.has_area('general') = false,
  'a lapsed assignment gives no access');
select tests.act_as((select admin from u));
select ok(public.has_area('admin_settings'), 'the last System administrator never lapses, so nobody is locked out');
select tests.act_as_postgres();
select throws_ok(format($$update public.role_assignments set revoked_at = now(), revoke_reason = 'test' where user_id = %L$$, (select admin from u)),
  'P0001', 'The last System administrator cannot be removed.', 'the last System administrator cannot be removed');

-- Deactivating removes every role.
set local session_replication_role = replica;
update public.role_assignments set until = current_date + 30 where user_id = (select admin from u);
set local session_replication_role = origin;
select tests.act_as((select admin from u));
select lives_ok(format($$select public.admin_deactivate_user(%L)$$, (select other from u)), 'a System administrator deactivates a person');
select is((select count(*)::int from public.role_assignments where user_id = (select other from u) and revoked_at is null), 0,
  'a deactivated person holds no role');
select throws_ok(format($$select public.admin_deactivate_user(%L)$$, (select admin from u)), 'P0001',
  'You cannot deactivate yourself.', 'nobody deactivates themselves');

-- The Workspace domain (IAM-1).
select tests.act_as_postgres();
update public.parameters set value = '"example.com"' where key = 'identity.workspace_domain';
select tests.act_as((select admin from u));
select throws_ok($$select public.admin_invite('someone@elsewhere.test', 'test_member')$$, 'P0001',
  'Invitations are only for @example.com addresses (Plumbline IAM-1).', 'invitations stay inside the domain');
select lives_ok($$select public.admin_invite('newcomer@example.com', 'test_member')$$, 'an invitation inside the domain works');
select tests.act_as_postgres();
select throws_ok($$insert into auth.identities (provider_id, user_id, identity_data, provider)
  values ('g-1', (select admin from u), '{"email": "admin@example.com", "custom_claims": {"hd": "elsewhere.test"}}', 'google')$$,
  'P0001', null, 'a Google identity from another Workspace is refused');

select * from finish();
rollback;
