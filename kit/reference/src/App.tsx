import { useCallback, useEffect, useState, type ReactNode } from 'react';
import type { Session } from '@supabase/supabase-js';
import { configured, supabase } from './supabase';

// Example Advisory Ltd: a small left-menu admin app on the Plumbline kit (UIX-3). Every page reads and
// writes through the kit's tables and functions; the database decides what each person may see and do.

type Page = 'overview' | 'procedures' | 'evidence' | 'screening' | 'people' | 'flags';

const MENU: { band: string; hint: string; items: { id: Page | null; label: string; note?: string }[] }[] = [
  { band: 'Governance', hint: 'sets the rules', items: [
    { id: 'overview', label: 'Overview' }, { id: 'procedures', label: 'Procedures' }, { id: 'evidence', label: 'Evidence log' }] },
  { band: 'The machine', hint: 'phases, in order', items: [
    { id: null, label: '1 Lead generation', note: 'no pages yet' },
    { id: 'screening', label: '2 Lead activation · Screening' },
    { id: null, label: '3 Product delivery', note: 'no pages yet' }] },
  { band: 'Across the machine', hint: 'runs through every phase', items: [
    { id: 'people', label: 'People · Roles' }, { id: 'flags', label: 'Technology · Flags' }] },
];

const ACCOUNTS = ['operator@example.com', 'director.a@example.com', 'crco@example.com', 'analyst@example.com'];

export function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [page, setPage] = useState<Page>('overview');

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data } = supabase.auth.onAuthStateChange((_e, s) => setSession(s));
    return () => data.subscription.unsubscribe();
  }, []);

  if (!configured) return <Notice title="Not configured">Copy <code>.env.example</code> to <code>.env.local</code> and fill in the values from <code>supabase status</code>.</Notice>;
  if (!session) return <SignIn />;

  return (
    <div className="app">
      <header className="top">
        <strong>Example Advisory Ltd</strong>
        <span className="env">Local</span>
        <span className="spacer" />
        <span className="muted">{session.user.email}</span>
        <button onClick={() => supabase.auth.signOut()}>Sign out</button>
      </header>
      <div className="body">
        <nav className="side" aria-label="Main menu">
          {MENU.map((b) => (
            <div key={b.band} className="band">
              <div className="band-h"><span className="label">{b.band}</span><span className="hint">{b.hint}</span></div>
              {b.items.map((it) => it.id
                ? <a key={it.label} href="#" className={page === it.id ? 'on' : ''} onClick={(e) => { e.preventDefault(); setPage(it.id!); }}>{it.label}</a>
                : <span key={it.label} className="off">{it.label} <small>{it.note}</small></span>)}
            </div>
          ))}
        </nav>
        <main>
          {page === 'overview' && <Overview />}
          {page === 'procedures' && <Procedures />}
          {page === 'evidence' && <Evidence />}
          {page === 'screening' && <Screening />}
          {page === 'people' && <People />}
          {page === 'flags' && <Flags />}
          <footer className="vfoot">Plumbline kit v0.1.0 · fictional data · every action here is written to the evidence log</footer>
        </main>
      </div>
    </div>
  );
}

function SignIn() {
  const [email, setEmail] = useState(ACCOUNTS[0]);
  const [password, setPassword] = useState('local-only-pass');
  const [error, setError] = useState('');
  return (
    <Notice title="Sign in">
      <p className="muted">Local example accounts. Each has a different role, so each sees different things.</p>
      <form className="form" onSubmit={async (e) => {
        e.preventDefault();
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        setError(error ? error.message : '');
      }}>
        <label htmlFor="email">Account
          <select id="email" value={email} onChange={(e) => setEmail(e.target.value)}>{ACCOUNTS.map((a) => <option key={a}>{a}</option>)}</select>
        </label>
        <label htmlFor="password">Password<input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} /></label>
        <button className="primary" type="submit">Sign in</button>
        {error && <p className="error">{error}</p>}
      </form>
    </Notice>
  );
}

// Data helpers ---------------------------------------------------------------------------------------

function useQuery<T>(load: () => Promise<T>): [T | undefined, string, () => void] {
  const [data, setData] = useState<T>();
  const [error, setError] = useState('');
  const [tick, setTick] = useState(0);
  useEffect(() => { load().then(setData, (e: Error) => setError(e.message)); }, [tick]); // eslint-disable-line react-hooks/exhaustive-deps
  return [data, error, useCallback(() => setTick((t) => t + 1), [])];
}

async function rows<T>(q: PromiseLike<{ data: T[] | null; error: { message: string } | null }>): Promise<T[]> {
  const { data, error } = await q;
  if (error) throw new Error(error.message);
  return data ?? [];
}

async function call(fn: string, args: Record<string, unknown>): Promise<string> {
  const { error } = await supabase.rpc(fn, args);
  return error ? error.message : '';
}

// Pages ------------------------------------------------------------------------------------------------

function Overview() {
  const [me] = useQuery(async () => {
    const [roles, areas, flags] = await Promise.all([
      supabase.rpc('my_roles'), supabase.rpc('my_areas'), supabase.rpc('my_flags')]);
    return { roles: (roles.data ?? []) as string[], areas: (areas.data ?? []) as string[], flags: (flags.data ?? []) as string[] };
  });
  return (
    <Section title="Overview" sub="What your roles give you, decided by the database">
      <div className="tiles">
        <Tile label="Your roles" value={me?.roles.join(', ') || '—'} />
        <Tile label="Your areas" value={me?.areas.join(', ') || '—'} />
        <Tile label="Switches you can use" value={me?.flags.join(', ') || 'none yet'} />
      </div>
      <p className="muted">Try it: accept the screening procedure as the analyst (its owner), co-sign it as the CRCO, then switch screening on as the operator.</p>
    </Section>
  );
}

type Version = { procedure_id: string; version: number; status: string; summary: string; accepted_by: string | null; cosigned_by: string | null };
type Step = { id: string; position: number; what: string; who: string; mode: string; flag_key: string | null; clause_refs: string[] };

function Procedures() {
  const [data, error, reload] = useQuery(async () => ({
    procedures: await rows<{ id: string; title: string; regulated: boolean; owner_area: string }>(supabase.from('procedures').select('id,title,regulated,owner_area').order('id')),
    versions: await rows<Version>(supabase.from('procedure_versions').select('procedure_id,version,status,summary,accepted_by,cosigned_by').order('version')),
    steps: await rows<Step & { procedure_id: string; version: number }>(supabase.from('procedure_steps').select('*').order('position')),
  }));
  const [msg, setMsg] = useState<{ text: string; ok: boolean } | null>(null);
  const act = async (fn: string, args: Record<string, unknown>, done: string) => { const e = await call(fn, args); setMsg(e ? { text: e, ok: false } : { text: done, ok: true }); reload(); };
  if (error) return <Section title="Procedures"><p className="error">{error}</p></Section>;
  return (
    <Section title="Procedures" sub="How each job is done, versioned. The owner accepts; the CRCO co-signs regulated ones (PRC-4)">
      {msg && <p className={msg.ok ? 'toast' : 'refused'} role="status">{msg.text}</p>}
      {data?.procedures.map((p) => (
        <div key={p.id} className="panel">
          <h3>{p.id} · {p.title} {p.regulated && <span className="chip warn">regulated</span>} <span className="chip">owner: {p.owner_area}</span></h3>
          {data.versions.filter((v) => v.procedure_id === p.id).map((v) => (
            <div key={v.version} className="version">
              <div className="row"><b>v{v.version}</b> <span className={`chip ${v.status === 'accepted' ? 'ok' : ''}`}>{v.status}{v.status === 'draft' && v.accepted_by ? ', awaiting co-sign' : ''}</span> <span className="muted">{v.summary}</span></div>
              <table><thead><tr><th>Step</th><th>What</th><th>Who</th><th>Mode</th><th>Switch</th><th>Clauses</th></tr></thead>
                <tbody>{data.steps.filter((s) => s.procedure_id === p.id && s.version === v.version).map((s) => (
                  <tr key={s.id}><td className="mono">{s.id}</td><td>{s.what}</td><td>{s.who}</td><td>{s.mode}</td><td className="mono">{s.flag_key ?? '—'}</td><td className="mono">{s.clause_refs.join(', ')}</td></tr>))}
                </tbody></table>
              {v.status === 'draft' && (
                <div className="btns">
                  {!v.accepted_by && <button className="primary" onClick={() => act('accept_procedure_version', { _procedure_id: p.id, _version: v.version }, 'Accepted · logged')}>Accept</button>}
                  {v.accepted_by && p.regulated && <button className="primary" onClick={() => act('cosign_procedure_version', { _procedure_id: p.id, _version: v.version }, 'Co-signed · logged')}>Co-sign</button>}
                  <button onClick={() => { const r = prompt('Reason for rejecting'); if (r !== null) act('reject_procedure_version', { _procedure_id: p.id, _version: v.version, _reason: r }, 'Rejected · logged'); }}>Reject</button>
                </div>)}
            </div>))}
        </div>))}
    </Section>
  );
}

type Entry = { id: string; at: string; actor_type: string; action: string; job_id: string | null; flag_key: string | null; clause_refs: string[] };

function Evidence() {
  const [data, error] = useQuery(() => rows<Entry>(supabase.from('evidence_log').select('id,at,actor_type,action,job_id,flag_key,clause_refs').order('at', { ascending: false }).limit(50)));
  return (
    <Section title="Evidence log" sub="Append-only. Readable with Admin settings or Risk and compliance (DAT-3)">
      {error && <p className="error">{error}</p>}
      {data && data.length === 0 && <p className="muted">Nothing to show: your roles don't include reading the evidence log.</p>}
      {data && data.length > 0 && (
        <table><thead><tr><th>When</th><th>Who</th><th>What</th><th>Job</th><th>Switch</th><th>Clauses</th></tr></thead>
          <tbody>{data.map((e) => <tr key={e.id}><td className="mono">{new Date(e.at).toLocaleString()}</td><td>{e.actor_type}</td><td className="mono">{e.action}</td><td>{e.job_id ?? '—'}</td><td className="mono">{e.flag_key ?? '—'}</td><td className="mono">{e.clause_refs.join(', ')}</td></tr>)}</tbody></table>)}
    </Section>
  );
}

function Screening() {
  const [data] = useQuery(async () => {
    const [allowed, flag, ver] = await Promise.all([
      supabase.rpc('flag_allows', { _key: 'c01.record' }),
      supabase.from('feature_flags').select('state').eq('key', 'c01.record').maybeSingle(),
      supabase.from('procedure_versions').select('version').eq('procedure_id', 'C01-P1').eq('status', 'accepted').maybeSingle(),
    ]);
    return { allowed: Boolean(allowed.data), state: flag.data?.state as string | undefined, version: ver.data?.version as number | undefined };
  });
  return (
    <Section title="Screening" sub="Lead activation · job C01">
      <div className="gstrip">
        <span className="chip">Job <b>C01</b> Screen a new client</span>
        <span className="chip">Level: record</span>
        <span className={`chip ${data?.state === 'live' ? 'ok' : data?.state === 'shadow' ? 'warn' : ''}`}>Switch {data?.state ?? '…'}</span>
        <span className="chip">Procedure C01-P1 {data?.version ? `v${data.version}` : 'not yet accepted'}</span>
        <span className="mono">Carries out AML-3.2, AML-4.2, AML-4.4</span>
      </div>
      {data?.allowed
        ? <div className="panel"><p>The screening queue would be here. You can see it because switch <span className="mono">c01.record</span> allows you.</p></div>
        : <div className="panel"><p className="muted">This job isn't switched on for you yet. Its procedure must be accepted (and co-signed), then someone with Admin settings switches it on with a gate record (LIF-4, PRC-5).</p></div>}
    </Section>
  );
}

function People() {
  const [data, error] = useQuery(async () => ({
    people: await rows<{ id: string; full_name: string; email: string; active: boolean }>(supabase.from('profiles').select('id,full_name,email,active').order('email')),
    assignments: await rows<{ user_id: string; role_key: string; until: string; revoked_at: string | null; reason: string }>(supabase.from('role_assignments').select('user_id,role_key,until,revoked_at,reason')),
  }));
  return (
    <Section title="People and roles" sub="Access follows governed roles; nobody assigns their own (IAM-7, IAM-8)">
      {error && <p className="error">{error}</p>}
      <table><thead><tr><th>Person</th><th>Roles (until)</th><th>Active</th></tr></thead>
        <tbody>{data?.people.map((p) => (
          <tr key={p.id}><td>{p.full_name}<div className="muted">{p.email}</div></td>
            <td>{data.assignments.filter((a) => a.user_id === p.id && !a.revoked_at).map((a) => `${a.role_key} (${a.until})`).join(', ') || <span className="muted">not visible to you</span>}</td>
            <td>{p.active ? 'yes' : 'no'}</td></tr>))}</tbody></table>
    </Section>
  );
}

type Flag = { key: string; job_id: string; level: string; state: string; description: string; requires_licence: string | null };

function Flags() {
  const [data, error, reload] = useQuery(() => rows<Flag>(supabase.from('feature_flags').select('key,job_id,level,state,description,requires_licence').order('key')));
  const [msg, setMsg] = useState<{ text: string; ok: boolean } | null>(null);
  const [checked, setChecked] = useState('Tried it on the example data');
  const [result, setResult] = useState('Works as the procedure describes');
  const act = async (fn: string, args: Record<string, unknown>, done: string) => { const e = await call(fn, args); setMsg(e ? { text: e, ok: false } : { text: done, ok: true }); reload(); };
  return (
    <Section title="Flags" sub="Off is always allowed; on needs a gate record and an accepted procedure (LIF-1 to LIF-4, PRC-5)">
      {error && <p className="error">{error}</p>}
      {msg && <p className={msg.ok ? 'toast' : 'refused'} role="status">{msg.text}</p>}
      <div className="form inline">
        <label htmlFor="checked">What you checked<input id="checked" value={checked} onChange={(e) => setChecked(e.target.value)} /></label>
        <label htmlFor="result">The result<input id="result" value={result} onChange={(e) => setResult(e.target.value)} /></label>
      </div>
      <table><thead><tr><th>Switch</th><th>Job</th><th>State</th><th>Description</th><th /></tr></thead>
        <tbody>{data?.map((f) => (
          <tr key={f.key}><td className="mono">{f.key}</td><td>{f.job_id}</td><td><span className={`chip ${f.state === 'live' ? 'ok' : f.state === 'shadow' ? 'warn' : ''}`}>{f.state}</span></td><td>{f.description}</td>
            <td className="btns">
              {f.state !== 'live' && <button className="primary" onClick={() => act('switch_on', { _key: f.key, _state: 'live', _users: null, _checked: checked, _result: result }, 'Switched on · gate recorded · logged')}>Switch on</button>}
              {f.state !== 'off' && <button onClick={() => act('set_flag_state', { _key: f.key, _state: 'off' }, 'Switched off · logged')}>Switch off</button>}
            </td></tr>))}</tbody></table>
    </Section>
  );
}

// Layout pieces ---------------------------------------------------------------------------------------

function Section({ title, sub, children }: { title: string; sub?: string; children: ReactNode }) {
  return <section className="page"><h1>{title}</h1>{sub && <p className="muted">{sub}</p>}{children}</section>;
}
function Tile({ label, value }: { label: string; value: string }) {
  return <div className="panel tile"><span className="label">{label}</span><span className="num">{value}</span></div>;
}
function Notice({ title, children }: { title: string; children: ReactNode }) {
  return <div className="notice panel"><h1>{title}</h1>{children}</div>;
}
