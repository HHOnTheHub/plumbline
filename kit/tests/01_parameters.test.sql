-- Kit module: parameters. GOV-8, DAT-10: values the database works to, each naming its clause; read by
-- people with General access; written only by migrations.
begin;
\ir helpers/setup.psql
select no_plan();

create temp table u as select
  tests.make_user('lead@example.com', 'test_lead') as lead,
  tests.make_user('member@example.com', 'test_member') as member;
grant select on u to authenticated;

select is(public.param_int('roles.review_months'), 6, 'the kit default review period is 6 months');
select is(public.param_bool('retention.enforced'), false, 'retention only counts until it is switched on');
select is(public.param_text('procedures.cosign_area'), 'risk_compliance', 'text parameters read as text');
select is(public.param_text('identity.workspace_domain'), null, 'a null parameter reads as null');
select is(public.review_until(), (current_date + interval '6 months')::date, 'review_until follows the parameter');
select is((select count(*)::int from public.parameters where clause !~ '^[A-Z]{2,4}-[0-9]+'), 0,
  'every parameter names the clause that sets it');

select tests.act_as((select member from u));
select ok((select count(*) from public.parameters) > 0, 'someone with General access reads the parameters');
select throws_ok($$update public.parameters set value = '1' where key = 'roles.review_months'$$, '42501', null,
  'nobody changes a parameter from the app');

select tests.act_as_anon();
select throws_ok($$select count(*) from public.parameters$$, '42501', null, 'a visitor reads nothing');

select tests.act_as_postgres();
select * from finish();
rollback;
