# Plumbline clauses v0.6.0

The standard in [General App Architecture.md](General%20App%20Architecture.md), as checkable clauses. Every app reports against this list in `governance/conformance.md`, and the daily run works through it.

**Rules for this file.** A clause id is permanent and never reused; a retired clause stays here, marked retired. Adding a clause is a minor version; changing what a clause requires or removing one is a major version.

**Columns**

- **Answers:** the obligation requirements the clause meets, by id from [../obligations/](../obligations/), or `practice` where the clause is Plumbline's own good practice with no legal source, or `practice: SRC-…` where a recognised source in [../sources/](../sources/README.md) informs it (from v0.6.0). **Every obligation is unverified** until counsel confirms it (v0.5.0).
- **Applies:** `all`, or the condition under which the clause applies (for example, only apps with outside users).
- **Check:** how anyone, or the daily run, can tell whether the app meets it.
- **Fix:** who may close a gap, as defined in [AUTONOMY.md](../AUTONOMY.md). `Do` the run may make the change on a branch and show it. `Ask` the run proposes and waits for the operator's yes. `Operator` only the operator can do it, or the board where named (GitHub settings, secrets, approvals, board matters).
- **Priority:** `P1` foundations, closed first; `P2` the governed operating system; `P3` maturity.

## GOV: Governance chain and versioned text

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| GOV-1 | The app has a governance record: folders for mandate, appetite, framework, policies, controls and the obligations register; jobs in the jobs register; procedures in the database (PRC-1) with readable copies (PRC-8). Amended in v0.6.0 (DEC-005) | practice | all | Folders exist in `governance/` or a linked governance repository | Do (drafts) | P1 |
| GOV-2 | Every governance document has a complete header: id, level, version, status, owner, approver, parents, effective date, next review | practice | all | `check:governance` | Do | P1 |
| GOV-3 | Clause ids are unique and never reused, including retired clauses | practice | all | `check:governance` | Do | P1 |
| GOV-4 | `check:governance` runs on every pull request and blocks the merge when it fails | practice | all | CI workflow contains it | Do | P1 |
| GOV-5 | A technology policy at level 3 adopts a Plumbline version and lists the approved exceptions | OBL-OROC.1 | all | `governance/policies/` holds it, status approved | Do (draft); Operator (approval by the board) | P1 |
| GOV-6 | Level 1 (risk appetite) and level 2 (risk framework, or the domain standard or charter) exist, however short | practice | all | Documents exist; an empty level states why | Do (draft) | P2 |
| GOV-7 | The obligations register lists each outside rule with status, trigger, owner and last-verified date | All library entries (the register cites them) | all | `governance/obligations/` | Do (draft) | P2 |
| GOV-8 | Thresholds, periods and limits are parameters in approved clauses, not constants in code | practice | all | Code review against the clause list | Ask | P2 |
| GOV-9 | Every change to governance text has a recorded approval by that level's approver before merge | practice | all | Approvals in the evidence log or pull request reviews | Operator | P2 |
| GOV-10 | A change to a clause marks everything that cites it for review | practice | all | Impact list in the change's pull request | Do | P3 |

## JOB: The jobs register

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| JOB-1 | A jobs register exists, each job with id, performer, trigger, desired outcome, source clauses, regulated flag, level and flag | practice | all | `governance/jobs/register.md` | Do (draft) | P1 |
| JOB-2 | Every feature declares the job id it serves | practice | all | Route or module metadata, or a comment, names a register id | Do | P2 |
| JOB-3 | The boundary is written down: events coming in, deliverables going out | practice | all | Section in the mandate or register | Do (draft) | P3 |
| JOB-4 | The destination (year-3 picture) names which jobs must reach Assist or Agent, and which stay with people | practice | all | Section in the mandate | Do (draft) | P3 |
| JOB-5 | Every job names its menu home: a governance page, a phase of the machine (lead generation, lead activation, product delivery), or a function across the machine (risk, compliance, finance, people, technology). Added v0.4.0 | practice | all | "Menu home" column in the register | Do | P1 |

## PRC: Procedures (added v0.6.0)

The job owner accepts procedure changes; the CRCO co-signs for regulated jobs.

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| PRC-1 | **Procedures live in a versioned table.** Tables `procedures`, `procedure_versions` and `procedure_steps` hold every procedure. An accepted version is never edited; a change makes a new version. Each step has a permanent id (`J23-P1.3`), its job and order, who does it (role, the app, a named agent, an outside system), where it happens (route, function, outside platform, or manual), its mode (manual, assisted, agent), the clauses it carries out with versions, the controls it satisfies, the evidence it writes, and its flag | practice | all | Migration; versions immutable (a test tries to update one) | Ask | P1 |
| PRC-2 | **Steps come from the system.** Code that performs a step declares its step id; each gateway declares the steps that happen in its outside platform; the job owner enters manual steps. A step id in code with no row, or a row no code or person performs, is a defect | practice | all | Step-id scan in CI against the table | Do | P2 |
| PRC-3 | **A system change drafts the procedure change.** When a change touches a step id, the nightly run drafts the new procedure version in plain words, with a before and after per step and a link to the code change | practice | all | Draft versions linked to pull requests | Do (draft) | P2 |
| PRC-4 | **The job owner accepts; the CRCO co-signs regulated jobs.** A draft version takes effect when the job owner accepts it, and, for a job marked regulated in the register, when the CRCO also signs. Rejections are logged with a reason | OBL-AMLR.3, OBL-OROC.1 | all | Approval records in the evidence log | Ask | P1 |
| PRC-5 | **Flags follow accepted procedures.** A flag cannot move to `shadow` or `live` unless the procedure version that describes the flagged behaviour has been accepted. Code may merge and stay off | OBL-AIGN.4 | all | Flag change refused without an accepted version (database rule and test) | Ask | P1 |
| PRC-6 | **The system never moves policy.** Each draft version is checked against the clauses its steps cite. If it fits, it goes to the job owner. If it needs a rule no policy states, it becomes a policy proposal to the CRCO and board. If it breaks a policy, it is blocked and flagged to the operator and CRCO | practice | all | Policy-fit result on every draft | Do (check) | P1 |
| PRC-7 | **Evidence cites the procedure, and drift is detected.** Every evidence entry records the procedure version and step in force. The health check compares what happened with the accepted procedure (steps skipped, out of order, or done by hand that should be automated) and shows drift to the job owner and CRCO | OBL-AIGN.1 | all | Evidence fields; drift section in the health check | Ask | P3 |
| PRC-8 | **A readable copy of each accepted version.** Each accepted version is published as a page in the governance repository and into the app's Claude project, so there is a git history, Claude reads the approved version, and a regulator can be handed a document | practice | all | Pages match the table | Do | P2 |

## LIF: Lifecycle and flags

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| LIF-1 | Feature flags live in the app's database, per job and level, with states `off`, `shadow`, `live` and an audience | OBL-AIGN.8 | all | Migration and table exist | Ask | P2 |
| LIF-2 | New jobs ship behind a flag set to `off` | practice | all | Review of recent features | Do | P2 |
| LIF-3 | Every flag change is written to the evidence log; turning a flag off is always allowed to its owner | OBL-AIGN.8 | all | Trigger or function on the flags table | Ask | P2 |
| LIF-4 | Moving a job up a level has a gate record: criteria set in advance, results, who signed | OBL-AIGN.5, OBL-AIGN.7, OBL-SBOX.1 | when any job is past Record | Gate records in the evidence log or `governance/jobs/` | Do (draft); Operator (sign) | P3 |

## HLT: Health diagnosis

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| HLT-1 | The structure check finds orphans, missing owners, broken references and lapsed reviews | practice | all | `check:governance` covers them | Do | P2 |
| HLT-2 | A code-alignment check compares the clause and job ids in code with the governance record | practice | all | Script in CI | Do | P3 |
| HLT-3 | The app's Architecture page or doc shows its health and its Plumbline conformance | practice | all | Page or section exists | Do | P3 |

## IAM: Identity and access

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| IAM-1 | Staff sign in with Google, restricted to the company domain by checking the hosted-domain claim on the server | OBL-PIPA.3 | when the app has staff users | Server code checks `hd` | Ask | P1 |
| IAM-2 | Outsiders are invite-only: sign-ups disabled, email link and OTP, terms acceptance logged with its version | OBL-PIPA.3 | when the app has outside users | Auth settings and invite flow | Ask | P1 |
| IAM-3 | Access is decided by database functions (`has_area()` or similar), and a trigger stops anyone granting access to themselves | OBL-PIPA.3 | all | Functions and trigger exist, with tests | Ask | P1 |
| IAM-4 | Approvals and the sensitive zone require multi-factor sign-in | OBL-PIPA.3 | when the app has approvals or a sensitive zone | Auth configuration | Ask | P2 |
| IAM-5 | Sensitive tables grant select only; writes go through security-definer functions | OBL-PIPA.3 | when the app has sensitive data | Grants in migrations | Ask | P2 |
| IAM-6 | Each audience has its own routes and row-level policies; an outside session cannot reach a staff route | OBL-PIPA.3 | when the app has more than one audience | Route guards and RLS tests | Ask | P1 |
| IAM-7 | **Roles are governed, access follows roles.** A role register in `governance/` defines each role (director, CRCO, MLRO, job owner, operator, analyst, outsider types), the jobs it performs and the access areas it carries. People get access only by being assigned a role; no access area is granted to a person directly. The menu shows only what a person's roles allow | OBL-PIPA.3, OBL-AMLR.3 | all | Role register; `user_roles` and `role_areas` tables; RLS reads roles | Ask | P1 |
| IAM-8 | **Who assigns which role is set by policy.** The access policy names the assigner for each role: the board appoints directors and control functions (CRCO, MLRO); the CRCO or an authorised person assigns operational roles. Every assignment records who assigned it, why and until when; incompatible roles cannot be held together (for example inviter and approver of the same thing); assignments are reviewed on a cycle and expire if not re-confirmed | OBL-OROC.1, OBL-PIPA.3 | all | Policy parameters; trigger refusing self-assignment and incompatible pairs; review records | Ask | P1 |

## DAT: Data, zones and evidence

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| DAT-1 | Every table has row-level security on, default deny, with explicit grants | OBL-PIPA.3 | all | Migrations; a test that lists tables without RLS | Ask | P1 |
| DAT-2 | Every access rule has a test, listed by exact name in the controls register | OBL-PIPA.3 | all | Tests exist and are listed | Do | P1 |
| DAT-3 | `evidence_log` exists, append-only (update and delete forbidden by database rules), with the required fields | OBL-AIGN.1, OBL-AIGN.8, OBL-AMLR.2 | all | Migration and a test that tries to update | Ask | P1 |
| DAT-4 | Evidence entries hold references, never copies of personal data or private text | OBL-PIPA.6 | all | Review of writes to `evidence_log` | Ask | P2 |
| DAT-5 | Regulated or sensitive data sits in its own Supabase project, reached only through server functions | OBL-PIPA.3 | when the app has regulated or sensitive data | Two projects in config | Operator | P2 |
| DAT-6 | The service-role key and other secrets never reach browser code | OBL-PIPA.3 | all | Search client bundles and `VITE_`/`NEXT_PUBLIC_` variables | Ask | P1 |
| DAT-7 | **A lawful basis per feature.** Every feature that uses personal information records its purpose and lawful basis in a register, and the privacy officer is named in governance | OBL-PIPA.1, OBL-PIPA.2 | all | Register in `governance/`; JOB cards cite it | Do (draft) | P1 |
| DAT-8 | **Overseas transfer assessments.** Every vendor that stores or processes personal information outside Bermuda has a transfer assessment on file, reviewed when the vendor, region or use changes | OBL-PIPA.5 | all | Assessment linked from the outsourcing register | Do (draft); Operator (sign) | P2 |
| DAT-9 | **Breach procedure.** A personal-information breach procedure is written, linked to the incidents job, and rehearsed yearly; the privacy officer decides on notification | OBL-PIPA.4 | all | Procedure and rehearsal record | Do (draft) | P2 |
| DAT-10 | **Retention as parameters.** Each record class has a retention period set as a parameter in an approved policy (AML records at the period the Regulations set, to be confirmed by counsel) and enforced by the database | OBL-PIPA.6, OBL-AMLR.2 | all | Policy parameters and scheduled job | Ask | P2 |

## DEL: Environments and delivery

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| DEL-1 | A test Supabase project with a synthetic seed exists; the seed refuses to run on a database with real accounts | OBL-PIPA.3 | all | Seed file and its guard | Ask | P1 |
| DEL-2 | Every schema change is a new migration in git; applied migrations are never edited | practice | all | `git log` on `supabase/migrations` | Do (report); Ask (fix) | P1 |
| DEL-3 | CI runs type check, lint, unit tests, RLS tests, `check:governance` and build on every pull request | practice | all | Workflow file | Do | P1 |
| DEL-4 | `main` is protected: no direct pushes, required checks, deploys only from `main` | practice | all | GitHub branch protection | Operator | P1 |
| DEL-5 | `CLAUDE.md` (and `AGENTS.md` where used) points to Plumbline and states its working rules | practice | all | File contains the Plumbline line | Do | P1 |
| DEL-6 | No secrets in the repository; `.env*` files are ignored | OBL-PIPA.3 | all | Secret scan of the tree and history | Ask; Operator (rotation) | P1 |
| DEL-7 | Real data exists only in production; any exception is written down, time-boxed and deleted at cutover | OBL-PIPA.3, OBL-AIGN.7 | all | Environment config and decisions | Ask | P1 |
| DEL-8 | Rollback is written down: code by redeploy, behaviour by flag, data by forward migration | practice | all | Section in the architecture doc | Do | P3 |
| DEL-9 | Dependencies are locked, and new versions wait a day before use (`bunfig.toml` or equivalent) | practice | all | Lockfile and setting | Do | P3 |
| DEL-10 | Sensitive-zone changes go out in dated releases with notes, test evidence and sign-off | OBL-AIGN.4 | when the app has a sensitive zone | Release notes | Operator | P2 |

## DOC: Architecture kept current

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| DOC-1 | An architecture document exists, follows the Plumbline outline, and names the Plumbline version | practice | all | File and version line | Do | P1 |
| DOC-2 | `governance/conformance.md` exists and is no more than 30 days behind the latest minor version | practice | all | File and its version | Do | P1 |
| DOC-3 | Changes to pages, data, access or a decision update the architecture document in the same commit | practice | all | Recent commits | Do | P2 |

## STK: Stack, vendors and continuity

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| STK-1 | Every vendor has an outsourcing register entry: role, data held, location, terms, exit plan, materiality | OBL-OROC.3, OBL-OROC.4, OBL-OROC.5, OBL-PIPA.5, OBL-AIGN.10, OBL-CDA.1 | all | Register in `governance/` | Do (draft) | P2 |
| STK-2 | Databases are backed up nightly to storage the entity controls, and a restore has been tested | OBL-OROC.6 | all | Backup job and a restore record | Operator | P2 |
| STK-3 | The app uses the Plumbline stack (TanStack Start, Supabase, Resend; Vercel or Cloudflare), or records an exception | practice | all | `package.json` and config | Operator (exception) | P3 |
| STK-4 | **Important business services.** Each app's important business services are named with impact tolerances, and recovery is tested against them | OBL-OROC.2, OBL-OROC.6 | all | Section in the architecture doc; test record | Do (draft) | P2 |
| STK-5 | **Ownership and control of IP.** Repositories, models and data are owned by the entity; provider terms fix ownership of model output; decisions about the entity's IP are made by its people in Bermuda | OBL-CDA.1, OBL-ESA.1 | all | Outsourcing register terms; repository ownership | Operator | P3 |

## INT: Outside systems

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| INT-1 | Each outside system is reached through one server gateway that checks access, holds the secret, logs calls and records health | OBL-AIGN.6 | when the app calls outside systems | Code review | Ask | P2 |
| INT-2 | Syncs are snapshots run by a scheduler that cannot overlap, with a health record per run | practice | when the app syncs data | Code and tables | Ask | P3 |
| INT-3 | The app reads the minimal slice; any write-back is a recorded decision | OBL-PIPA.6 | when the app reads another entity's data | Decisions record | Ask | P2 |
| INT-4 | **Agents act only where authorised.** An agent or browser tool acts in another system only with that system's authorisation and within its terms, and every action is logged | OBL-CMA.1 | when agents act in other systems | Gateway logs; approved-tools list | Ask | P2 |

## AGT: Models and agents

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| AGT-1 | Every model call goes through one gateway that records provider, model, version and prompt version | OBL-AIGN.8, OBL-AIGN.9 | when the app calls a model | Code review | Ask | P2 |
| AGT-2 | Agent limits (tools, data, spend, actions) are enforced in code, not prompts | OBL-AIGN.6 | when the app runs agents | Code review | Ask | P2 |
| AGT-3 | An agent registry lists each agent's model, tools, scopes, limits, owner and steps | OBL-AIGN.1 | when the app runs agents | Registry exists | Do (draft) | P3 |
| AGT-4 | **Perimeter check.** Every agent tool, automated action and product feature is mapped against the licensing perimeter before it ships. Anything that would be licensable activity the entity does not hold a licence for is blocked in code, not in a prompt. The CRCO signs the map | OBL-PERIM.1, OBL-PERIM.2, OBL-PERIM.3, OBL-PERIM.4, OBL-PERIM.5, OBL-PERIM.6, OBL-PERIM.7, OBL-PERIM.8, OBL-PERIM.9, OBL-AIGN.6 | all | Perimeter map in `governance/`; tests that blocked actions are refused | Ask | P1 |
| AGT-5 | **AI use-case inventory.** Every use of AI is recorded: in-app agents and model calls, AI inside vendors' tools (screening, KYC), and workbench tools that hold company data. Each entry has a materiality tier, owner, human-oversight design and change log. The inventory is generated from the agent registry and the outsourcing register, not kept by hand | OBL-AIGN.1, OBL-AIGN.2, OBL-AIGN.3, OBL-AIGN.10, OBL-AIGN.11, OBL-SBOX.1 | all | Inventory page or file, generated | Do (draft) | P2 |
| AGT-6 | **Material AI changes are managed.** A change to the model, provider, data, prompts, retrieval, permissions, integration or autonomy of a material use case has a change record and passes its test set before release. Switching to a pre-tested fallback provider under an approved plan is a routine change | OBL-AIGN.4, OBL-AIGN.9 | when the app has a material AI use case | Change records in the evidence log | Ask | P2 |
| AGT-7 | **Fairness in decisions about people.** Any AI-assisted decision about a person (matching, screening, eligibility, pricing) is tested for unfair outcomes on Human Rights Act grounds before going live and after each material change, and a named person makes the decision | OBL-HRA.1, OBL-AIGN.5 | when AI assists decisions about people | Test record and decision point | Ask | P2 |
| AGT-8 | **No AI overclaiming.** Product copy, decks, disclosures and regulator correspondence describe AI as it is (built, in shadow, or planned) | OBL-CPA.1, OBL-AIGN.12 | all | Review of public text | Ask | P3 |
| AGT-9 | **Agents do not bind the entity alone.** No agent forms, accepts or varies a contract, or sends a binding commitment, without a named person's approval. Deeds are never executed electronically by an agent | OBL-ETA.1, OBL-ETA.2 | when agents act externally | Decision points and tests | Ask | P2 |

## UIX: The app shell and role views (added v0.3.0)

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| UIX-1 | Every page shows the entity and the environment; production is marked unmistakably | practice | all | Shell component | Do | P1 |
| UIX-2 | Each person has one "My actions" inbox in the same place in every app: approvals, re-signs, gate sign-offs, asks, items due | practice | all | Shell component and query | Ask | P2 |
| UIX-3 | The app is a CRUD admin layout with the main menu on the left (never across the top), in three bands in this order: **Governance** (overview, board, policies, jobs register, procedures, changes and approvals, improvements, evidence log); **The machine**, the phases in order (1 lead generation, 2 lead activation, 3 product delivery), each holding its jobs' pages; **Across the machine**, functions that run through every phase (risk, compliance, finance, people, technology). Each list page has a filter, a New action and a row that opens a record drawer; each record shows its governance and its history. Amended in v0.4.0 (DEC-003) and v0.6.0 (DEC-005) | practice | all | Navigation config and page layout | Ask | P1 |
| UIX-4 | Every work page has a governance strip rendered from data: job id, level, flag state, procedure version in force, clauses with versions, control status, risk, last evidence. Amended in v0.6.0 (DEC-005) | practice | all | Strip component reads the governance record | Ask | P2 |
| UIX-5 | Role views open on that role's decisions and queues: board (decisions, position against appetite, what matured), CRCO (queues, maturity proposals, KRIs), operator (portfolio, asks, triaged feedback). Every item links to its evidence | OBL-OROC.1 | all | Routes and access areas per role | Ask | P2 |
| UIX-6 | Where a person must decide, the page names who and waits; an automated decision shows the clause that made it | OBL-AIGN.5, OBL-AMLR.3, OBL-POCA.1, OBL-SANC.2 | all | Review of decision points | Ask | P2 |
| UIX-7 | A footer shows the Plumbline version, policy effective date, build and flag date, so a screenshot is evidence | practice | all | Shell component | Do | P3 |
| UIX-8 | When evidence supports it, the app proposes maturity to the CRCO: a lower residual rating, a numeric appetite limit, a job moving up a level. Accepted changes appear to the board as "matured", for noting or decision | practice | all | Maturity proposals in the CRCO view and board pack | Ask | P3 |

## FBK: In-app feedback (added v0.3.0)

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| FBK-1 | An "Improve this" control on every page takes five types (broke, confusing, missing, feels risky, idea) and attaches the page's context automatically: page, job, clauses and versions, flag, role, entity, build, Plumbline version | practice | all | Component on the shell | Ask | P2 |
| FBK-2 | Feedback is stored in a `feedback` table with RLS: its text is never edited, status changes are logged to the evidence log, and the submitter gets an id at once | practice | all | Migration and tests | Ask | P2 |
| FBK-3 | The nightly run triages new feedback: merges duplicates, classifies it as app fix, procedure, policy or risk, or idea, links it to job, clause and risk, and routes it by the chain. Feedback tagged risky reaches the CRCO in the next run | practice | all | Daily report section | Do | P2 |
| FBK-4 | The submitter is told the outcome, and the feedback links to the change it caused | practice | all | Status and link fields | Ask | P3 |
| FBK-5 | Feedback counts and themes appear in the CRCO view and the quarterly board pack | practice | all | Views and pack | Ask | P3 |
| FBK-6 | The app publishes a nightly de-identified feedback export: id, type, text with names, emails and record identifiers removed, role (not person), entity, page context, status. It is served by one read-only endpoint that opens only with a per-app key whose hash alone is stored, and returns nothing else. The export is the only way the nightly run sees feedback | OBL-PIPA.6 | all | Endpoint, its redaction tests and key handling | Ask | P2 |

## MOD: Modules (apply only when the app uses the pattern)

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| MOD-1 | Outsiders see only frozen, numbered versions; the log records who saw which version under which terms | OBL-CPA.1 | when the app publishes to outsiders | Schema and logging | Ask | P2 |
| MOD-2 | Calculation and rules engines are pure modules pinned by tests to the reference they replace | practice | when the app has an engine | Tests exist | Do | P2 |
| MOD-3 | Private workspaces are unreadable by every operator role, proved by RLS tests | OBL-PIPA.3 | when the app has private workspaces | Tests exist | Ask | P1 |
| MOD-4 | Sealed ballots are hidden until close and checked against hashes logged when cast | practice | when the app has ballots | Tests exist | Ask | P2 |
| MOD-5 | A device or kiosk reads one read-only function that returns exactly what it shows | practice | when the app has a device zone | Function and grants | Ask | P2 |
| MOD-6 | **Screening systems.** Customer due diligence, ongoing monitoring and sanctions screening run through a gateway; every result is evidence; matches and suspicions go to the MLRO, who decides; a sanctions match triggers the freeze-and-report procedure | OBL-AMLR.1, OBL-AMLR.3, OBL-POCA.1, OBL-ATFA.1, OBL-SANC.1, OBL-SANC.2, OBL-AIGN.11 | when the app onboards or screens people or companies | Gateway, evidence entries, decision points | Ask | P1 |
