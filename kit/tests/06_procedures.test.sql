-- Kit module: procedures. PRC-1, PRC-4, PRC-5: versioned, never edited once accepted; the owner accepts,
-- the risk owner co-signs regulated ones; a flag goes up only when an accepted procedure names it.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('lead@example.com', 'test_lead') as lead,
  tests.make_user('lead2@example.com', 'test_lead') as lead2,
  tests.make_user('officer@example.com', 'test_officer') as officer,
  tests.make_user('member@example.com', 'test_member') as member;
grant select on u to authenticated;

insert into public.feature_flags (key, job_id, level, description) values ('t05.record', 'T05', 'record', 'Test');

-- Create and draft.
select tests.act_as((select member from u));
select throws_ok($$select public.create_procedure('T05-P1', 'T05', 'Screen a client', 'admin_settings', true)$$, 'P0001',
  'You need Admin settings access to create a procedure.', 'only Admin settings creates a procedure');
select tests.act_as((select lead from u));
select lives_ok($$select public.create_procedure('T05-P1', 'T05', 'Screen a client', 'admin_settings', true)$$,
  'Admin settings creates a regulated procedure');
select is(public.draft_procedure_version('T05-P1', 'First draft',
  '[{"id":"T05-P1.1","what":"Run the checks","who":"The app","location":"app","mode":"assisted","flag_key":"t05.record","clause_refs":["AML-4.2"]}]'),
  1, 'a draft becomes version 1');

-- PRC-5: no accepted procedure, no switching on.
select throws_ok($$select public.switch_on('t05.record', 'live', null, 'Checked', 'Fine')$$, 'P0001',
  'Turning a switch up needs an accepted procedure that describes it (Plumbline PRC-5).',
  'a switch cannot go up before its procedure is accepted');

-- PRC-4: nobody accepts their own draft; regulated needs a co-sign by someone else with the risk area.
select throws_ok($$select public.accept_procedure_version('T05-P1', 1)$$, 'P0001',
  'Nobody accepts their own draft (Plumbline PRC-4).', 'the drafter cannot accept');
select tests.act_as((select member from u));
select throws_ok($$select public.accept_procedure_version('T05-P1', 1)$$, 'P0001', null,
  'someone without the owner area cannot accept');
select tests.act_as((select lead2 from u));
select is(public.accept_procedure_version('T05-P1', 1), 'awaiting co-sign', 'the owner accepts; a regulated one waits for a co-sign');
select throws_ok($$select public.cosign_procedure_version('T05-P1', 1)$$, 'P0001',
  'Only the risk owner co-signs a regulated procedure (Plumbline PRC-4).', 'only the risk area co-signs');
select tests.act_as((select officer from u));
select is(public.cosign_procedure_version('T05-P1', 1), 'accepted', 'the risk owner co-signs and it takes effect');

-- Accepted versions never change.
select tests.act_as_postgres();
select throws_ok($$update public.procedure_versions set summary = 'edited' where procedure_id = 'T05-P1' and version = 1$$, 'P0001',
  null, 'an accepted version is never edited');
select throws_ok($$update public.procedure_steps set what = 'edited' where procedure_id = 'T05-P1'$$, 'P0001',
  null, 'its steps are never edited');

-- Now the switch can go up.
select tests.act_as((select lead from u));
select is((select state from public.switch_on('t05.record', 'live', null, 'Checked on test', 'Fine')), 'live',
  'with an accepted procedure the switch goes live');

-- A new version supersedes the last; a rejection needs a reason.
select is(public.draft_procedure_version('T05-P1', 'Refresh every 6 months',
  '[{"id":"T05-P1.1","what":"Run the checks every 6 months","who":"The app","location":"app","mode":"assisted","flag_key":"t05.record"}]'),
  2, 'a change makes version 2');
select tests.act_as((select officer from u));
select throws_ok($$select public.reject_procedure_version('T05-P1', 2, '  ')$$, 'P0001',
  'A rejection needs a reason (Plumbline PRC-4).', 'a rejection needs a reason');
select tests.act_as((select lead2 from u));
select is(public.accept_procedure_version('T05-P1', 2), 'awaiting co-sign', 'version 2 accepted by the owner');
select tests.act_as((select officer from u));
select is(public.cosign_procedure_version('T05-P1', 2), 'accepted', 'and co-signed');
select tests.act_as_postgres();
select is((select status from public.procedure_versions where procedure_id = 'T05-P1' and version = 1), 'superseded',
  'the previous version is superseded');
select is((select jsonb_object_agg(action, n) from (select action, count(*)::int n from public.evidence_log
            where action like 'procedure:%' and after ->> 'procedure_id' = 'T05-P1' group by action) x),
  '{"procedure:created": 1, "procedure:drafted": 2, "procedure:accepted": 2, "procedure:cosigned": 2}'::jsonb,
  'every step is evidenced');

select * from finish();
rollback;
