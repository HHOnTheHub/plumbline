-- Kit module: flags. LIF-1 to LIF-4, AGT-4: off is always allowed; up needs a gate, an accepted procedure
-- and, for licensed work, the licence; every change is evidenced; shadow reaches only its audience.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('lead@example.com', 'test_lead') as lead,
  tests.make_user('member@example.com', 'test_member') as member;
grant select on u to authenticated;

insert into public.feature_flags (key, job_id, level, description, requires_licence) values
  ('t01.record', 'T01', 'record', 'Test job, record level', null),
  ('t02.assist', 'T02', 'assist', 'Test job needing a licence', 'test_licence');
-- An accepted procedure that names both switches (PRC-5), so the gate and licence rules can be tested.
insert into public.procedures (id, job_id, title, owner_area) values ('T01-P1', 'T01', 'Test', 'general'), ('T02-P1', 'T02', 'Test', 'general');
insert into public.procedure_versions (procedure_id, version, summary) values ('T01-P1', 1, 'test'), ('T02-P1', 1, 'test');
insert into public.procedure_steps (procedure_id, version, id, position, what, who, location, mode, flag_key) values
  ('T01-P1', 1, 'T01-P1.1', 1, 'Do it', 'The app', 'app', 'assisted', 't01.record'),
  ('T02-P1', 1, 'T02-P1.1', 1, 'Do it', 'The app', 'app', 'assisted', 't02.assist');
update public.procedure_versions set status = 'accepted' where procedure_id in ('T01-P1', 'T02-P1');

select is((select state from public.feature_flags where key = 't01.record'), 'off', 'a new switch ships off (LIF-2)');

-- Who may change a switch.
select tests.act_as((select member from u));
select throws_ok($$select public.set_flag_state('t01.record', 'off')$$, 'P0001',
  'You need Admin settings access to change a switch.', 'without Admin settings, no change');
select throws_ok($$update public.feature_flags set state = 'live' where key = 't01.record'$$, '42501', null,
  'nobody writes the table directly');

-- Up needs a gate (LIF-4).
select tests.act_as((select lead from u));
select throws_ok($$select public.set_flag_state('t01.record', 'live')$$, 'P0001',
  'Turning a switch up needs a gate record for it (Plumbline LIF-4).', 'no gate, no switching on');
select is((select state from public.switch_on('t01.record', 'shadow', array[(select member from u)], 'Tried it on test data', 'Works')),
  'shadow', 'with a gate record and an accepted procedure it goes to shadow for named people');

-- Shadow reaches only its audience.
select ok(not public.flag_allows('t01.record'), 'shadow hides from people outside its audience');
select tests.act_as((select member from u));
select ok(public.flag_allows('t01.record'), 'shadow allows its audience');
select ok('t01.record' = any (array(select public.my_flags())), 'my_flags lists what the person can use');

-- The kill switch.
select tests.act_as((select lead from u));
select lives_ok($$select public.set_flag_state('t01.record', 'off')$$, 'off is always allowed to Admin settings');
select ok(not (select public.flag_allows('t01.record')), 'off allows nobody');

-- Licensed work stays off until the licence is granted (AGT-4).
select throws_ok($$select public.switch_on('t02.assist', 'live', null, 'Checked', 'Fine')$$, 'P0001',
  'This switch serves licensed work and stays off until the licence is granted (Plumbline AGT-4).',
  'a licensed switch cannot go up before the licence');
select tests.act_as_postgres();
insert into public.parameters (key, value, clause, description)
values ('licence.test_licence.granted', 'true', 'AGT-4', 'Test licence');
select tests.act_as((select lead from u));
select is((select state from public.switch_on('t02.assist', 'live', null, 'Checked', 'Fine')), 'live',
  'once the licence is granted, it can go live');

-- Every change is evidence; identity never changes.
select tests.act_as_postgres();
select ok((select count(*) from public.evidence_log where action = 'flag:changed' and flag_key = 't01.record'
           and actor_id = (select lead from u)) = 2, 'each change is written to the evidence log with who made it');
select ok(exists (select 1 from public.evidence_log where action = 'gate:recorded' and flag_key = 't02.assist'),
  'switching on records the gate');
select throws_ok($$update public.feature_flags set level = 'agent' where key = 't01.record'$$, 'P0001', null,
  'a switch''s job and level never change');

select * from finish();
rollback;
