-- Kit module: evidence log. DAT-3, DAT-4, DAT-10: append-only for every role; who acted is stamped by the
-- database; readable by Admin settings and Risk and compliance only; one retention exception.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('admin@example.com', 'system_administrator') as admin,
  tests.make_user('lead@example.com', 'test_lead') as lead,
  tests.make_user('officer@example.com', 'test_officer') as officer,
  tests.make_user('member@example.com', 'test_member') as member;
grant select on u to authenticated;

create temp table e as select public.log_evidence('test:written', 'C01', 'test', null, null,
  '{"note": "kit test"}', null, null, array['DAT-3']) as id;
grant select on e to authenticated;

select is((select actor_type from public.evidence_log where id = (select id from e)), 'system',
  'an entry with no signed-in person is the system''s');
select is((select clause_refs from public.evidence_log where id = (select id from e)), array['DAT-3'],
  'the clauses in force are recorded');

-- Append-only, for every role.
select throws_ok($$update public.evidence_log set action = 'x' where id = (select id from e)$$, 'P0001',
  'The evidence log is append-only: entries cannot be changed or removed (Plumbline DAT-3).',
  'even postgres cannot change an entry');
select throws_ok($$delete from public.evidence_log where id = (select id from e)$$, 'P0001', null,
  'even postgres cannot remove an entry');
select throws_ok($$truncate public.evidence_log$$, 'P0001', null, 'nobody truncates the log');

-- Reading and writing from the app.
select tests.act_as((select member from u));
select is((select count(*)::int from public.evidence_log), 0, 'a member without Admin settings reads nothing');
select throws_ok($$insert into public.evidence_log (action) values ('forged')$$, '42501', null,
  'nobody writes the log directly from the app');
select throws_ok($$select public.log_evidence('forged')$$, '42501', null, 'nor through log_evidence');
select tests.act_as((select lead from u));
select ok((select count(*) from public.evidence_log where id = (select id from e)) = 1, 'Admin settings reads the log');
select tests.act_as((select officer from u));
select ok((select count(*) from public.evidence_log where id = (select id from e)) = 1, 'Risk and compliance reads the log');

-- Identity events are evidenced, without the email address (DAT-4).
select tests.act_as_postgres();
select ok(exists (select 1 from public.evidence_log where action = 'invitation:accepted'
                  and actor_id = (select member from u)), 'accepting an invitation is evidenced');
select ok(not exists (select 1 from public.evidence_log where action like 'invitation:%'
                      and (before::text like '%@%' or after::text like '%@%')), 'invitation entries hold no email address');

-- Retention: counts only, until switched on; then removes only what is past its period.
insert into public.evidence_log (action, at, actor_type) values ('test:old', now() - interval '10 years', 'system');
select is((public.apply_retention() ->> 'enforced')::boolean, false, 'retention counts when not enforced');
select ok(exists (select 1 from public.evidence_log where action = 'test:old'), 'nothing is removed when not enforced');
update public.parameters set value = 'true' where key = 'retention.enforced';
select is((public.apply_retention() ->> 'enforced')::boolean, true, 'retention runs when enforced');
select ok(not exists (select 1 from public.evidence_log where action = 'test:old'), 'an entry past its period is removed');
select ok(exists (select 1 from public.evidence_log where id = (select id from e)), 'a recent entry stays');
select throws_ok($$delete from public.evidence_log where id = (select id from e)$$, 'P0001', null,
  'outside the retention job, nothing is removed even when retention is on');

select * from finish();
rollback;
