// End-to-end smoke test of the reference app's data path, through the same API the browser uses.
// Run after `supabase start` (or `supabase db reset`) in this folder, with SUPABASE_URL and SUPABASE_KEY
// set from `supabase status`. It changes the local database: reset it afterwards.
//
// The story: the screening job (C01) cannot be switched on until its regulated procedure is accepted by
// its owner and co-signed by the CRCO; then the operator switches it on and the analyst can use it.
import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL ?? 'http://127.0.0.1:55321';
const key = process.env.SUPABASE_KEY;
if (!key) { console.error('Set SUPABASE_KEY to the publishable (or anon) key from `supabase status`.'); process.exit(2); }

let failed = 0;
const check = (ok, what) => { console.log(`${ok ? 'ok    ' : 'FAILED'} ${what}`); if (!ok) failed++; };

async function as(email) {
  const client = createClient(url, key, { auth: { persistSession: false } });
  const { error } = await client.auth.signInWithPassword({ email, password: 'local-only-pass' });
  if (error) throw new Error(`${email}: ${error.message}`);
  return client;
}

const operator = await as('operator@example.com');
const analyst = await as('analyst@example.com');
const crco = await as('crco@example.com');
const director = await as('director.a@example.com');

let r = await operator.rpc('switch_on', { _key: 'c01.record', _state: 'live', _users: null, _checked: 'Smoke test', _result: 'Fine' });
check(r.error?.message.includes('PRC-5'), 'the switch cannot go on before its procedure is accepted');

r = await director.rpc('accept_procedure_version', { _procedure_id: 'C01-P1', _version: 1 });
check(Boolean(r.error), 'a director (not the owner area) cannot accept the procedure');

r = await analyst.rpc('accept_procedure_version', { _procedure_id: 'C01-P1', _version: 1 });
check(!r.error && r.data === 'awaiting co-sign', 'the owner accepts; the regulated procedure waits for a co-sign');

r = await analyst.rpc('cosign_procedure_version', { _procedure_id: 'C01-P1', _version: 1 });
check(Boolean(r.error), 'the accepter cannot also co-sign');

r = await crco.rpc('cosign_procedure_version', { _procedure_id: 'C01-P1', _version: 1 });
check(!r.error && r.data === 'accepted', 'the CRCO co-signs and the procedure takes effect');

r = await analyst.rpc('switch_on', { _key: 'c01.record', _state: 'live', _users: null, _checked: 'x', _result: 'y' });
check(Boolean(r.error), 'the analyst cannot switch it on (no Admin settings)');

r = await operator.rpc('switch_on', { _key: 'c01.record', _state: 'live', _users: null, _checked: 'Smoke test on example data', _result: 'Works as C01-P1 v1 describes' });
check(!r.error && r.data?.state === 'live', 'the operator switches it on with a gate record');

r = await analyst.rpc('flag_allows', { _key: 'c01.record' });
check(r.data === true, 'now the analyst can use screening');

r = await analyst.from('evidence_log').select('id');
check(!r.error && r.data.length === 0, 'the analyst cannot read the evidence log');

r = await crco.from('evidence_log').select('action').in('action', ['procedure:accepted', 'procedure:cosigned', 'gate:recorded', 'flag:changed']);
const actions = new Set((r.data ?? []).map((e) => e.action));
check(['procedure:accepted', 'procedure:cosigned', 'gate:recorded', 'flag:changed'].every((a) => actions.has(a)),
  'the CRCO sees every step in the evidence log');

r = await operator.from('evidence_log').delete().neq('action', '');
check(Boolean(r.error), 'nobody can delete evidence through the API');

console.log(failed ? `\n${failed} check(s) failed` : '\nAll smoke checks passed');
process.exit(failed ? 1 : 0);
