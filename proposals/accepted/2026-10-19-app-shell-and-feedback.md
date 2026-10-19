# Proposal: the app shell and in-app feedback (Plumbline v0.3.0)

Oct 19, 2026 · Proposed for the maintainer · Version: **minor** (13 clauses added, nothing removed) · Prototype: [prototypes/governed-app-experience.html](../prototypes/governed-app-experience.html)

## Why

Governance lives in documents today, and the people who own it (directors, the CRCO, job owners) cannot see it in the apps. v0.3 makes every app show its governance where the work happens, gives each role a view that opens on its decisions, and captures user feedback with its context, so the nightly run can turn it into governed improvements. It also makes the apps tell the CRCO and board when the risk framework or policies themselves have matured.

## Change: two new clause groups in `standard/clauses.md`

### UIX: The app shell and role views

| Id | Clause | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- |
| UIX-1 | Every page shows the entity and the environment; production is marked unmistakably | all | Shell component | Do | P1 |
| UIX-2 | Each person has one "My actions" inbox in the same place in every app: approvals, re-signs, gate sign-offs, asks, items due | all | Shell component and query | Ask | P2 |
| UIX-3 | The sidebar has three zones in this order: Work (jobs, named with register ids), Governance (overview, chain, jobs, risks, controls, obligations, changes, evidence, feedback), System (Plumbline, flags, agents, vendors) | all | Navigation config | Ask | P2 |
| UIX-4 | Every work page has a governance strip rendered from data: job id, level, flag state, clauses with versions, control status, risk, last evidence | all | Strip component reads the governance record | Ask | P2 |
| UIX-5 | Role views open on that role's decisions and queues: board (decisions, position against appetite, what matured), CRCO (queues, maturity proposals, KRIs), operator (portfolio, asks, triaged feedback). Every item links to its evidence | all | Routes and access areas per role | Ask | P2 |
| UIX-6 | Where a person must decide, the page names who and waits; an automated decision shows the clause that made it | all | Review of decision points | Ask | P2 |
| UIX-7 | A footer shows the Plumbline version, policy effective date, build and flag date, so a screenshot is evidence | all | Shell component | Do | P3 |
| UIX-8 | When evidence supports it, the app proposes maturity to the CRCO: a lower residual rating, a numeric appetite limit, a job moving up a level. Accepted changes appear to the board as "matured", for noting or decision | all | Maturity proposals in the CRCO view and board pack | Ask | P3 |

### FBK: In-app feedback

| Id | Clause | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- |
| FBK-1 | An "Improve this" control on every page takes five types (broke, confusing, missing, feels risky, idea) and attaches the page's context automatically: page, job, clauses and versions, flag, role, entity, build, Plumbline version | all | Component on the shell | Ask | P2 |
| FBK-2 | Feedback is stored in a `feedback` table with RLS: its text is never edited, status changes are logged to the evidence log, and the submitter gets an id at once | all | Migration and tests | Ask | P2 |
| FBK-3 | The nightly run triages new feedback: merges duplicates, classifies it as app fix, procedure, policy or risk, or idea, links it to job, clause and risk, and routes it by the chain. Feedback tagged risky reaches the CRCO in the next run | all | Daily report section | Do | P2 |
| FBK-4 | The submitter is told the outcome, and the feedback links to the change it caused | all | Status and link fields | Ask | P3 |
| FBK-5 | Feedback counts and themes appear in the CRCO view and the quarterly board pack | all | Views and pack | Ask | P3 |

## Change: RUN.md

Add to step 2, after "Assess": **Triage feedback.** Read new rows in each app's `feedback` table (read-only, through the app's server function or a read-only database role on the test copy, never production keys in the run), classify and route them as FBK-3 says, and list them in the report under a new "Feedback" section. Feedback that names a possible breach goes under Urgent.

Open point: the run must not read production data (AUTONOMY.md). Feedback lives in production. Options: (a) the app exports new feedback nightly to the governance record without personal data, and the run reads that; (b) an explicit, narrow exception in AUTONOMY.md for the `feedback` table only. Recommendation: (a).

## Impact

Every app gains 13 clauses, all gaps today. The shell is built once as a shared component, which is the first piece of the shared package proposed in v0.2, so each app adopts it rather than rebuilding it.

## Decision needed

Maintainer: accept as v0.3.0, and choose (a) or (b) for feedback access. Each board notes it through its technology policy at the next quarterly report.
