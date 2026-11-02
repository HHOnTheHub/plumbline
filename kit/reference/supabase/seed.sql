-- Example Advisory Ltd: the fictional firm the Plumbline kit's reference app runs on.
-- Local development only. Every name is invented; the passwords are local test values, never used
-- anywhere real. Sign in with any address below and the password `local-only-pass`.

-- This organisation's settings (an app sets its own in a migration).
update public.parameters set value = 'false' where key = 'identity.require_mfa';   -- local only: password sign-in, no second factor
update public.parameters set value = '"example.com"' where key = 'identity.workspace_domain';

-- Its areas, roles and the pair nobody holds together.
insert into public.access_areas (key, label, description) values
  ('client_work', 'Client work', 'Onboarding, screening and engagements');

insert into public.roles (key, label, rank, board_appointed, assigns_operational, description) values
  ('director', 'Director', 2, true, false, 'Board member'),
  ('crco', 'Chief Risk and Compliance Officer', 2, true, true, 'Control function, appointed by the board'),
  ('analyst', 'Analyst', 2, false, false, 'Does the client work');
insert into public.role_areas (role_key, area_key) values
  ('director', 'general'),
  ('crco', 'general'), ('crco', 'risk_compliance'),
  ('analyst', 'general'), ('analyst', 'client_work');
insert into public.role_incompatibilities (role_a, role_b, reason) values
  ('crco', 'system_administrator', 'The person who runs the systems is not the person who checks them');

-- People: an invitation each, then the sign-up, which creates the profile and the role assignment.
insert into public.invitations (email, role_key) values
  ('operator@example.com', 'system_administrator'),
  ('director.a@example.com', 'director'),
  ('crco@example.com', 'crco'),
  ('analyst@example.com', 'analyst');

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
                        confirmation_token, recovery_token, email_change_token_new, email_change)
select '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated', email,
       extensions.crypt('local-only-pass', extensions.gen_salt('bf')), now(),
       '{"provider": "email", "providers": ["email"]}', jsonb_build_object('full_name', full_name), now(), now(),
       '', '', '', ''
from (values
  ('a0000000-0000-4000-8000-000000000001'::uuid, 'operator@example.com', 'Operator One'),
  ('a0000000-0000-4000-8000-000000000002'::uuid, 'director.a@example.com', 'Director A'),
  ('a0000000-0000-4000-8000-000000000003'::uuid, 'crco@example.com', 'CRCO'),
  ('a0000000-0000-4000-8000-000000000004'::uuid, 'analyst@example.com', 'Analyst One')
) as p(id, email, full_name);

insert into auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select id::text, id, jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true), 'email', now(), now(), now()
from auth.users where email like '%@example.com';

-- A job's switches and its first procedure, drafted for the owner to accept and the CRCO to co-sign.
insert into public.feature_flags (key, job_id, level, description, owner_area) values
  ('c01.record', 'C01', 'record', 'Screen a new client: record the checks and the decision', 'client_work'),
  ('c01.assist', 'C01', 'assist', 'Screen a new client: prepare clear results for review', 'client_work');

select public.create_procedure('C01-P1', 'C01', 'Screen a new client', 'client_work', true);
select public.draft_procedure_version('C01-P1', 'First draft, for the job owner to accept and the CRCO to co-sign.', '[
  {"id":"C01-P1.1","what":"Mark the client file complete","who":"Analyst","location":"app: Onboarding","mode":"manual","clause_refs":["AML-3.2"]},
  {"id":"C01-P1.2","what":"Run identity, sanctions and PEP checks at the screening provider","who":"The app","location":"screening gateway","mode":"assisted","clause_refs":["AML-4.2","OBL-SANC.1"],"flag_key":"c01.record","evidence_actions":["screening:result"]},
  {"id":"C01-P1.3","what":"Prepare clear results for review; send possible matches to the MLRO","who":"The app","location":"app: Screening","mode":"assisted","clause_refs":["AML-4.2"],"flag_key":"c01.assist"},
  {"id":"C01-P1.4","what":"Decide on every possible match","who":"MLRO","location":"app: Screening","mode":"manual","clause_refs":["AML-4.4","UIX-6"]}
]'::jsonb);
