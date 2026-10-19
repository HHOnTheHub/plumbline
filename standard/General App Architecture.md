# General App Architecture v0.6

Plumbline v0.6.0 · Hannes Heyns · Checkable clauses: [clauses.md](clauses.md). The architecture of a licensed firm's operating system, generalised so every app is built to that standard. Other app designs contribute patterns on top; none of them lowers the bar.

## Summary

Every app is built as a governed operating system: the owners' decisions sit at the top, and every job the app runs traces back to them. The standard is the one a licensed financial-services firm in Bermuda has to meet, applied to every app whether it is regulated or not. An app that is not regulated keeps every level and every control; its levels are simply thinner.

- **Destination first.** A short picture of the business at year-3 scale, written back from its plan, sets how far each job must be automated by then.
- **Jobs are the stable layer.** A register of the jobs the business must get done, each with a performer, trigger, desired outcome and source clauses. Jobs change only when the mandate changes. How the app does each job is what matures.
- **One chain of authority, seven levels.** Mandate, risk appetite, risk framework, policies, jobs and procedures, controls, evidence, with an obligations register beside it. Nothing exists below without a parent above.
- **Governance changes work like code changes.** Policies, job cards and procedures are versioned text with permanent clause ids, in their own repository. A change is a proposal the named approver accepts inside the app. GitHub refuses any merge without a recorded approval.
- **Every change gets a health diagnosis.** On each proposal, and monthly, the system shows what the change touches below it and where coverage is missing. Rule-based checks block; the AI check advises.
- **Jobs move up levels.** Record, then Assist, then Agent, behind a feature flag, through sandbox, shadow runs and readiness gates. The same flag is the kill switch.
- **One data plane under all jobs.** Jobs share a few records, so a finding is made once and agents can work across jobs.
- **Sensitive work is kept apart.** Regulated or sensitive data sits in its own database project, with barriers between business lines enforced by row-level rules.
- **Evidence by default.** Every decision, by a person or an agent, is written once to an append-only log with the policy version it ran under.
- **Model-agnostic.** Every agent call goes through one model gateway, so providers can be tested against each other on the same work and swapped per task.
- **Every vendor is outsourcing.** Each one gets a register entry with data location, terms and exit plan, approved like any other governance change.

## Origins

Plumbline was distilled in 2026 from the architectures of five real apps built in Bermuda: a licensed firm's operating system, a venture studio's investor raise, a platform where several organisations negotiate one text, a founder-learning app, and a family operating system. The licensed firm's design is the base; the others contribute the [patterns](#patterns) an app adds when its jobs need them. Those designs are not published. Worked examples here use a fictional firm, [Harbour Advisory](../examples/harbour-advisory/README.md).

## Design principles

1. **Jobs before features.** Every feature names the job it serves and the role that performs it, and is judged by that job's desired outcomes. Jobs are designed back from the destination, and a job that can be removed is removed before it is automated.
2. **Top down, always traceable.** Every procedure step cites the policy clause it carries out, and every policy cites the risk appetite or obligation it answers. App code declares the step and clause ids it implements. An orphan is a defect.
3. **Change cascades down and expires what is below.** When a parent changes, its children are marked for review until someone re-signs them. Anything that cannot be re-signed by the effective date carries a logged, time-limited exception.
4. **Two speeds, one mechanism.** Governance changes are slow and signed by the board or its delegate. Code changes are fast and signed by engineering. Both run through versioned proposals with named approvers.
5. **The record is the asset.** The app owns the governance record and the evidence. Outside systems stay the systems of record for what they already hold (relationships, money, documents).
6. **Rules are parameters, not code.** Thresholds, periods and limits are typed parameters in approved clauses. Changing an approved policy changes the app's behaviour, and nothing else can.
7. **Built is not live.** Code ships to production switched off. A job moves up a level only through its gates, and any automation or agent can be switched off in one step.
8. **Evidence by default.** Logging is part of the platform, not something each feature adds. Every entry carries the policy version in force.
9. **Agents act inside an envelope, on any model.** Each agent has named tools, data and limits, enforced in code, and reaches models only through the gateway. It may propose changes above its level but never approve them, and never edits its own tests, thresholds or metrics.
10. **Sensitive work is kept apart.** Regulated or sensitive data and controls are separated from the rest, and barriers between business lines are enforced by the database, so the separation is easy to show an auditor.
11. **Separation of duties.** Nobody approves their own change, grants their own access or checks their own work. Maker and checker are always different people, or a different model.
12. **Draft inside, publish outside.** Anything an outside party sees is a frozen, numbered version, and the log records who saw which version under which terms.
13. **Engines are pure code.** Calculations that decide outcomes are deterministic, tested modules pinned to a reference they must reproduce.

## Destination

Each app starts from where the business should be and works back from its business plan.

| | Today | Year 3 |
| --- | --- | --- |
| Volume | Clients, users, mandates, members today | The plan's own year-3 numbers |
| People | Who holds each accountable role | The same named roles, with the work around them automated |

**What must be true at year 3** is written as four to six statements, for example:

1. Every material decision is made by a named person, on a file the system assembled, and can be evidenced without reconstruction.
2. Recurring checks run continuously, so their volume grows with the business, not with headcount.
3. The owners see the position live, and the periodic pack is generated rather than compiled.
4. Any record can be shown with the policy version it was made under.
5. Agents work across jobs on shared records; people keep the judgement calls.

**What that means for the roadmap:** the recurring jobs that must reach Assist or Agent by year 3 are named, and so are the judgement jobs that stay with people.

## The governance chain

Seven levels, read top down the way a regulator reads a licensee. Each level may be changed only by its named approver, and each change marks everything below it for review.

| Level | What it holds | Approves changes | Maintains | Scheduled review |
| --- | --- | --- | --- | --- |
| 0 Mandate | Licences or legal basis, conditions, the business plan, the destination, the boundary of the app's remit | Board; material changes notified to the regulator where one exists | Chair with counsel | Annual, and on any licence or ownership event |
| 1 Risk appetite | Appetite statements and limits per risk category | Board | Risk owner (Compliance Officer where regulated) | Annual |
| 2 Risk framework | Risk taxonomy, risk register, ratings, key risk indicators. A domain standard sits here too (for example a venture validation method, or a coalition's charter) | Board approves the framework; the risk owner keeps the register | Risk owner | Framework annual, register quarterly |
| 3 Policies | Access, data protection, information security, outsourcing, business continuity, conflicts, communications, the domain's own policies | Board | Policy owner | Annual, or on trigger |
| 4 Jobs and procedures | Job cards (what must get done; stable) and procedures (how; maturing) | Job owner; risk owner as well when regulated | Job owner | When a parent changes, otherwise annual |
| 5 Controls | The checks that prove a policy is followed, each tagged to a step and a named test | Risk owner | Control owner | Tested on a set cycle |
| 6 Evidence | Decisions, approvals, test results, logs | Nobody: written once, never edited | Produced by the workflows | Sampled when controls are tested |

**The obligations register** sits beside the chain: every outside rule that applies (law, licence conditions, regulator guidance, contracts), each with a status, trigger, exceptions, owner and last-verified date. Any level may cite it as the reason a clause exists. In Bermuda, start from the obligations library.

**The obligations library (v0.5).** The outside rules that bind how systems are built (PIPA, the BMA AI guidance note, the Outsourcing Code, financial crime and sanctions, the licensing perimeter, the Human Rights Act and others) are kept once, in Plumbline's [obligations/](../obligations/), with permanent requirement ids. Every clause names the requirements it answers, or says `practice`, so a director or regulator can see which rules the law requires and which the entity chose. Each entity's obligations register cites the library. The CRCO proposes changes, counsel verifies, and every entry stays unverified until counsel has confirmed it. For an entity without a licence, the licensing statutes are a perimeter its agents must be unable to cross (AGT-4).

**An unregulated app keeps all seven levels.** Its risk appetite may be half a page and its framework a short register, but writing them down is what lets every policy cite a parent. A level with nothing in it says so, with the reason, so the gap is a decision rather than an omission.

## The jobs: the stable layer

**The register.** One per app, with its own id prefix (for example `J`, or a letter per app). Ids are never reused. It is read from the business plan, the licence or legal pack, the operating model and any regulator guidance, and corrected by the people who hold each role.

**The job card**, at level 4:

| Field | Meaning |
| --- | --- |
| Id, job | Permanent id; a verb phrase |
| Performer | The role that does it (inside or outside the business), or "the app" for what the system enforces |
| Statement | *When [situation], I want to [motivation], so I can [outcome]* |
| Trigger | What starts it |
| Desired outcomes | How anyone can tell it went well; scored for importance and satisfaction |
| Source clauses | The policy clauses and obligations it answers |
| Regulated | Whether a licence or law governs it |
| Level and flag | Record, Assist or Agent; the flag it ships behind |

**The boundary.** Write down where the business's remit stops. Outside parties' jobs are context. What crosses is a short list of trigger events coming in and deliverables going out, kept in the register.

**One data plane.** Jobs read and write a small set of shared records (people, organisations, engagements, obligations, evidence, and the domain's core objects), so a finding is made once. A fit-and-proper finding on a person, for example, serves admission, refresh and conflicts.

**Remove before automating.** Jobs that exist only because records are kept apart shrink to a check once the records are joined: a reconciliation, a hand-kept calendar, a compiled board pack, separate attestation forms.

## Policies and procedures as versioned text

Every level of the chain lives as plain text in its own private repository (`<org>/governance`), separate from the app's code. Approvers never open GitHub: they read, comment and approve inside the app, which drives GitHub for them.

**Why a separate repository.** The people who approve a policy are not always the people who approve code. A separate repository gets its own approvers, history and access rules, and the app reads it like any other source. (A small team whose policy and code approvers are the same people may prefer a folder; under this standard the repository is the default, and a folder is a logged exception.)

**How a document is written**

- One Markdown file per document, `<ID>-<slug>.md`, in a folder per level: `mandate/`, `appetite/`, `framework/`, `policies/`, `controls/`, `obligations/`, with jobs in the jobs register. Procedures are the exception: they live in the database (below).
- A header: id, level, version, status (draft, approved, effective, retired), owner, approver, parent clauses, effective date, next review date.
- Numbered clauses with permanent ids (`AML-4.2`), never reused.
- Parameters inside clauses (`invite.default_expiry_days = 30`). The app reads only parameters from approved or effective documents.

**Procedures are read back from the system (v0.6).** A policy says what must be true; a job says what must get done; the procedure says how the job is actually done today, across the app, the platforms it integrates with, and people. Procedures live in a versioned table in the app's database: one row per step, with a permanent step id, who does it, where it happens, its mode (manual, assisted, agent), the clauses it carries out, the controls it satisfies, the evidence it writes and its flag. Code declares the step ids it performs, gateways declare the steps in outside platforms, and job owners enter manual steps.

When a code change touches a step, the nightly run drafts the new procedure version in plain words and checks it against policy. If it fits, the job owner accepts it, and the CRCO co-signs for regulated jobs. If it needs a new rule, it becomes a policy proposal; if it breaks one, it is blocked. A flag cannot go live until the procedure version describing it is accepted, so the review decides whether a change reaches users. Every evidence entry cites the procedure version in force, the health check flags drift between what happened and the accepted procedure, and each accepted version is copied into the governance repository as a readable page.

**How a change happens**

1. Someone proposes a change in the app (or Claude Code opens a pull request).
2. The diagnosis runs and attaches its report: what the change touches below it.
3. The named approver reads, comments and approves in the app, with MFA. Board-level changes link to the resolution or minutes.
4. The approval is written to the evidence log.
5. The merge happens; GitHub refuses it without a recorded approval.
6. Everything below that cited a changed clause is marked for review, with a recalibration task for its owner.
7. Anything not re-signed by the effective date carries a logged, time-limited exception.

**Versions:** major when an obligation, appetite or limit changes; minor when a clause or requirement is added or removed; patch for wording. Nobody, Claude included, writes directly to `main`.

**Claude reads the approved version.** On each release, the effective policies, procedures and operating model are published into the app's Claude project, so every Claude session works from what was approved.

## Health diagnosis

One question, on every change and every month: where must the system mature, change or be updated so that what we do still matches what we approved?

| Check | What it finds | How it works | Effect |
| --- | --- | --- | --- |
| Structure | Orphan steps; clauses nothing provides; broken references; missing owners; lapsed reviews; obligations marked as applying with no clause | Rules over the governance repository (`check:governance`) | Blocks the merge until fixed |
| Impact | Every step, control, parameter, test and live feature that depends on a changed clause | Follows parent links downward | Marks each for review; creates a recalibration task |
| Code alignment | Live features linked to a stale, retired or not-yet-effective step | Code declares the ids it implements; the check compares them with the repository | Warns when stale; blocks release when retired |
| Meaning | A procedure that no longer matches its policy | Claude compares the changed clause with each linked procedure and cites both | Advisory only |

**On a schedule** the same checks run monthly and on any logged event (a licence change, a new vendor, an incident, a key departure). They also flag obligations past their last-verified date and items on the regulatory watch list. A standing Governance health page shows open recalibrations, lapsed reviews and gaps per job, and a named person re-signs the monthly snapshot even when nothing changed.

## Roadmap and feature lifecycle

The roadmap is the jobs register in motion: each release moves one job up one level. Until a job's level is live, the job is still done by people, with its records kept where they are today.

**Levels:** Record (the app holds the job and its evidence), Assist (the system prepares, people decide), Agent (agents run routine steps, people approve exceptions). Judgement jobs (approvals, suspicions, admissions, votes) stay at Assist for good.

**Lifecycle gates**

| Stage | What it means | To enter it | Signs |
| --- | --- | --- | --- |
| Built | In production, switched off | Procedure approved; clause links clean; tests pass; evidence wired | Job owner and engineering |
| Sandbox | Synthetic or public data in staging; comparing workflow shapes and models on a test set | Job owner's say-so | Job owner |
| Shadow | Real inputs beside the manual process; outputs stored and compared, never acted on | Data basis recorded under data-protection law; success and kill-or-pivot criteria set in advance | Job owner; risk owner when regulated |
| Live, assisted | The system prepares, people decide | Shadow results meet the criteria | Job owner; risk owner when regulated |
| Agent in envelope | Agents run routine steps; people approve exceptions | Human-labelled test set; envelope defined (tools, data, limits, duration); kill switch tested; materiality assessed; part of a documented release when regulated | Job owner, risk owner, and the MLRO for financial crime |

A job's automation is done when it is reliable, owned, evidenced and improving, not when it reaches the last stage.

**Sequencing**, in order of precedence: gates that must be evidenced before the first client or outside user (at Record level); dependencies (jobs that feed others); destination pressure; opportunity (high importance, poorly met); agent suitability (rule-based, reversible, with real ground truth). Resequencing is a small change request approved by the operating model's owner.

**Feature flags** live in the app's own database: one per job and level, per environment, with three states (`off`, `shadow`, `live`) and an audience (roles, access areas or named pilot users). Every flag change is logged. Turning a flag up needs the gate record; turning it off is always allowed to the owner, the risk owner and super admins. No outside flag service, which keeps one vendor out of the outsourcing register.

## Identity and access

- **Every audience has its own door.** List them (staff, approvers, invited outsiders, member organisations, devices) and give each its own sign-in, routes and row-level policies. An outside session can never reach a staff route.
- **Staff** sign in with Google, restricted to the company domain by checking the hosted-domain claim on the server. MFA is required for the sensitive zone and for every approval.
- **Outsiders are invite-only:** email link plus OTP, sign-ups disabled, an account exists only because an approved invite created it. Joining means accepting a specific version of the terms, and the acceptance is logged. Each invite grants a named package with an expiry, and revocation takes effect at once.
- **Roles are governed; access follows roles (v0.5).** A role register in governance defines each role (director, CRCO, MLRO, job owner, operator, analyst, outsider types), the jobs it performs and the access areas it carries. People get access only by being assigned a role. The access policy names who assigns each role: the board appoints directors and control functions; the CRCO or an authorised person assigns operational roles; an approved invite assigns an outsider's role. Every assignment records who, why and until when; incompatible roles cannot be combined; assignments expire unless re-confirmed at the periodic access review. The left menu shows only what a person's roles allow.
- **Access areas underneath.** `has_area()`, `is_member()` and similar database functions decide access from a person's roles. Nobody can assign a role or area to themselves, enforced by a trigger. Inviter and approver differ by default.
- **Writes go through functions.** Sensitive tables grant select only; writes go through security-definer functions that hold the business rules.
- **Devices get one door.** A screen or kiosk reaches its zone only through one read-only function that returns exactly what it shows.

## Data zones and the evidence log

One app and one sign-in over two databases: one for unregulated or ordinary activity, one for regulated or sensitive work. The sensitive project gives separate keys, access rules and region choice, and the separation is easy to show an auditor. Inside it, business lines that must not see each other sit in separate schemas whose row-level rules enforce the barrier; crossing it needs a logged, approved exception. Sensitive data is reached only through server functions; the browser never holds its keys.

| Zone | Holds | Who reads it |
| --- | --- | --- |
| Ordinary project | Relationship data at the lowest tier, working records, synced snapshots, flags | Staff, by access area |
| Sensitive project | Regulated or sensitive records, one schema per business line behind a barrier | Staff on that side of the barrier, through server functions |
| Published schema | Frozen versions, grants, what outsiders may see | Staff; each outsider only their own grants |
| Private workspaces (where needed) | Work a member keeps from everyone, including the operator | Only that member; no service-role access |
| Audit | `evidence_log`, flag changes, sync runs, ballot hashes | Read-only, by role |

Every table has row-level security on, default deny, with explicit grants and a test for each access rule.

**The evidence log** is append-only, with database rules that forbid update and delete. Each entry holds:

- when, and who acted: a person, an outsider, the system, or an agent with its model and version
- the job and procedure step, and the clause versions in force
- references to the inputs (never copies of personal data or private text), the output and the decision, with the object's version (deck v7, document v3)
- who approved it, and whether the flag was in shadow or live

High-volume activity (views, time on page) goes to a separate events table and is rolled up.

**The agent registry** lists each agent's model, provider, tools, data scopes, limits, owner, the steps it serves and its materiality rating. Any AI inventory a regulator expects is generated from it.

**Documents** stay in their system of record (restricted Drive folders, or a private storage bucket viewed through short-lived signed links with a watermark), with the database holding references.

## Environments and delivery

| Environment | Data | Purpose |
| --- | --- | --- |
| Local | Synthetic seed | Development |
| Preview | Synthetic, per pull request | Reviewing a change |
| Staging | Synthetic, including a sandbox and a scripted end-to-end run | Rehearsal; sandbox experiments |
| Production | The only real data | Running the work; shadow runs, behind flags |

- **Only production holds real data.** Shadow runs happen in production behind a flag, so staging never needs real data and a staging leak is never a breach. Seeds refuse to run on a database with real accounts. Any exception (for example a parity test on read-only CRM data during a migration) is written down, time-boxed and deleted at cutover.
- **Pull request checks:** type checks, lint, unit tests (engines pinned to their references), row-level security tests, the code-alignment check, `check:governance` and a build. A change that fails any of them cannot merge, and the host's deployment checks require them.
- **Migrations in git**, applied per environment by the Supabase CLI from the same files; never edit an applied one; no environment URL hard-coded.
- **Two release speeds.** The ordinary zone deploys on merge. The sensitive zone batches changes into dated releases with notes, test evidence and sign-off, promoted to production by hand.
- **Claude Code works inside the same rules.** It works on branches and opens pull requests; it never merges, holds no production secrets and has no production data access. Each repository carries its rules in `CLAUDE.md` (and `AGENTS.md` for other assistants). An AI agent changing the control system is itself a change to govern.
- **The architecture stays current.** Every change to pages, data, access or a decision updates the architecture document and the app's Architecture page in the same commit.
- **Rollback:** code instantly on the host; behaviour by flag; database changes move forward only, each with a tested plan to reverse it.

## Stack and outsourcing

Each vendor is an outsourcing arrangement, so the vendor list is a governance decision as much as a technical one.

| Component | Role | What it touches | Governance note |
| --- | --- | --- | --- |
| Claude Code | Builds the app and the governance text through pull requests | Code and policy text; no production data | Anthropic as a runtime model provider is a separate decision |
| GitHub | App and governance repositories, branch protection, required approvers, CI | Code, policy text, change history | Holds the authoritative history of every policy change |
| Vercel or Cloudflare Workers | Hosting, preview per change, instant rollback | Processes every request, stores no data | One per app, recorded in the register; function region chosen deliberately |
| Supabase | Two Postgres projects (plus test), Auth, Storage | All app data, including sensitive data | Region drives the data-protection transfer assessment (PIPA in Bermuda) |
| Resend | Invitations, OTP, approval requests | Names and email addresses | Personal data |
| TanStack Start | Framework | | Shared across all apps, so components and patterns carry over |
| HubSpot, Xero, Google Workspace | Systems of record for relationships, money, documents | Unchanged | Reached only through gateways |

**Outsourcing register.** Each vendor gets an entry: data location, contract terms, exit plan, materiality. Material outsourcing is approved by the board under the outsourcing policy, and notified to the regulator where required. Settle the list before going live so it is part of the approved baseline.

**Exit.** Code, schema and governance text live in git, and the databases are backed up nightly to storage the business controls, so no vendor holds anything that cannot be moved.

## Models, tools and outside services

| | Workbench | Production |
| --- | --- | --- |
| What it is | People using AI in their own work: Claude with connectors, other assistants, agent browsers | Agents running steps inside the app's workflows |
| Acts as | The person, with their own sign-ins | A registered agent with its own identity and envelope |
| Rules | An approved-tools list, and a rule per information tier on what may go into which tool | Agent registry, test sets, gated releases, evidence log |
| New tool approved by | Risk owner; added to the outsourcing register when it holds company data | Board, under the outsourcing policy, plus the lifecycle gates |

- **One model gateway.** It records provider, model, version and prompt version in the evidence log; each agent's provider is a setting.
- **Play models against each other.** The same human-labelled test set runs against several providers. The best scorer is used per step and the runner-up becomes a tested fallback, which answers concentration risk. A provider swap sends the job back through its gates.
- **Each provider is outsourcing.** Higher information tiers go only to providers on terms that exclude training and limit retention.
- **One gateway per outside system.** It checks the caller's access, holds the secret server-side, logs every call and records integration health. Syncs are snapshots, not live proxies, run by a scheduler that cannot overlap, with a health record per run. Read the minimal slice (one list, lowest-tier fields, read-only); write-back is a separate decision with the data's owner.
- **Outsourced checks, not outsourced decisions.** Identity, screening and similar providers connect through the gateway; results land in the evidence log and open tasks; the accountable person still decides.

**Workflow shapes** for experiments, each as a registered agent with its own envelope: single agent with tools; fixed pipeline; planner and workers; maker and checker (on a different model); event-driven monitor; human-gated chain; improvement loop (only on proven jobs, against a test set the agent cannot edit). Moving a shape from sandbox to shadow needs its envelope, test set and kill-or-pivot criteria written first. Phase 0 includes a small agent runtime so experiments are not bespoke.

## The app shell, role views and feedback (v0.3)

Governance is embedded in the product, not kept beside it. Every app uses the same shell, so a director, the CRCO or the operator finds the same things in the same place in every entity's app. The clickable concept is [prototypes/governed-app-experience.html](../prototypes/governed-app-experience.html).

**The shell.** Every app is a CRUD admin app with the main menu on the left, never across the top. Entity and environment sit in the top bar, with one "My actions" inbox per person and a role switcher. The left menu has three bands, in this order:

| Band | Holds | Example: Harbour Advisory (fictional) |
| --- | --- | --- |
| Governance | Overview, board, policies, jobs register, changes and approvals, improvements (feedback), evidence log | The same in every app |
| The machine | The phases a customer moves through, numbered in order: 1 lead generation, 2 lead activation, 3 product delivery. Each phase holds its jobs' pages | Contacts, events, campaigns · pipeline, proposals, onboarding · engagements, placements, client service |
| Across the machine | Functions that run through every phase: risk, compliance, finance, people, technology | Risk register, KRIs, incidents · screening, obligations, controls · invoices, budget · team, training, conflicts · Plumbline, flags, agents, vendors |

Every job in the register names its menu home (JOB-5), so the menu is generated from the register and no page exists without a job. List pages have a filter, a New action and rows that open a record drawer with the record's fields, its governance and its history from the evidence log. Every work page carries a governance strip: job, level, flag, the clauses it carries out with their versions, control status, risk, last evidence. A footer with the Plumbline version, policy effective date, build and flag date makes any screenshot evidence.

**Role views.** Each role opens on what the chain says it owns.

| Role | Opens on | Cadence |
| --- | --- | --- |
| Director | Decisions the chain sent up; position against risk appetite; what matured, for noting | Quarterly, and when a decision is due |
| CRCO | Queues: re-signs after a change, control tests, obligations to verify, gate sign-offs, risk-tagged feedback; maturity proposals; KRIs against appetite limits | Monthly, and on any risk-tagged item |
| Job owner | Procedures to update, feedback on their job, gates to prepare | Weekly |
| Operator | Every entity's conformance, last night's run, asks waiting for a yes, triaged feedback | Daily |

**Maturity signals.** When the evidence supports it, the app proposes that the framework itself matures: a lower residual rating after a control has run clean, a first numeric limit for a qualitative appetite statement once there is enough KRI data, a job moving up a level after its shadow run. The CRCO accepts, edits or rejects; accepted changes reach the board as "matured", for noting or, where the chain says so, for decision.

**Feedback.** "Improve this" on every page captures the type and one sentence, with the page's governance context attached automatically. The submitter gets an id at once and hears back when it changes something. Each night the app publishes a de-identified export; the Plumbline run reads only that export, triages each item (app fix, procedure, policy or risk, idea) and routes it by the chain. Feedback that suggests a breach reaches the CRCO in the next run.

## Patterns

These are modules an app adds when its jobs need them. Each sits inside the core above.

| Pattern | Use when | What it adds |
| --- | --- | --- |
| Published versions | Outsiders see documents or figures | Drafts stay inside; outsiders see frozen, numbered versions rendered to PDF (and .pptx or .docx where needed). Offline edits come back as proposals. Disclaimers come from a policy. The log records which version each outsider saw |
| Governed engine | A calculation drives decisions | A model or calculation as a pure TypeScript module over named, versioned parameters. Change sets are proposed, previewed and accepted by another person. Snapshots freeze outputs; published material cites snapshot ids. Pinned to the reference it replaces |
| Data room | Outsiders review files | Private bucket, short-lived signed links, a watermarked viewer, access tiers, download off unless a parameter allows it, per-document view history |
| Multi-party charter | Several organisations decide together | A charter as a level-2 document held in the database and approved by members on joining; thresholds as parameters; a rules engine pinned to a worked example; charter changes frozen while a decision is open |
| Sealed ballots | People vote | Ballots hidden by row-level rules until close; a salted hash logged when cast and checked on reveal |
| Private workspaces | Members keep drafts from everyone, the operator included | Per-member data no operator role can read, proved by row-level security tests on every pull request |
| Domain standard | The app enforces a method | A standard the app enforces (an ordered cascade) held at level 2, with the cascade rules in a security-definer function |
| Device zone | A shared screen or kiosk | A kiosk or screen reading one read-only function; private images resized server-side; quiet hours and a hide control |
| One-way sync out | Events go to outside calendars | The app pushes to an outside calendar through a feed opened by a secret whose hash alone is stored; the app stays the source |

## Build sequence

Every app follows the same shape. Each phase closes with a gate, internal value comes first, and nothing reaches a client or outsider before the outside gate.

| Phase | Delivers | Gate |
| --- | --- | --- |
| 0 Foundations | App and governance repositories; two Supabase projects plus test; hosting; staff sign-in with MFA; access areas and self-grant triggers; evidence log; flags; model and system gateways; agent registry and runtime; CI with every check; `CLAUDE.md`; the mandate, appetite, framework skeleton, obligations register and jobs register; outsourcing register | Only named staff can sign in; RLS tests pass; `governance/` passes the check; every vendor has a register entry |
| 1 Move off the old platform (if any) | The current app rebuilt as it stands, proven on a test environment | Parity check passed; cutover approved. The old app stays live and untouched until then |
| 2 Governance spine | In-app proposals and approvals, diagnosis, health page, staleness | A real policy change runs end to end with its diagnosis |
| 3 to n Jobs by wave | Jobs at Record first, in sequencing order, then up the levels | Each wave's jobs in use and evidenced |
| Outside access | Invites, portal, published versions, revocation | **Before any real client or outsider:** counsel signs off on what they rely on; data owners approve every data flow; a test outsider runs end to end in staging and production |

## Decisions and open questions

| Decision | Options | Recommendation |
| --- | --- | --- |
| Governance location for small teams | Separate repository always; or a folder when approvers of policy and code are the same people | Repository by default; a folder only as a logged exception |
| Shared code | Copy patterns per app; or a shared package (evidence log, flags, access areas, gateways, agent runtime, `check:governance`) | A shared package, built from the first app's Phase 0 |
| Hosting | Vercel; Cloudflare Workers | Allow both, one per app, each in its outsourcing register |

**Open questions**

- [ ] Publish the shared package (shell, evidence log, flags, roles, procedures table, gateways, `check:governance`) as open source beside the standard?
- [ ] A machine-readable export of the clauses and obligations (JSON) for tools to read?
