# Proposal: procedures as a governed table, practice sources, and the BMA watch (Plumbline v0.6.0)

Oct 19, 2026 · Proposed for the maintainer · Version: **minor by exception** (8 clauses added; GOV-1, UIX-3 and UIX-4 amended in place; nothing removed)

## Why

**Procedures.** Hand-written procedures drift from what the app actually does from the day they are written. The maintainer's model: policies say what must be true for each job; the app, with the platforms it integrates, is how the job is done and keeps improving; the procedure is read back from the system, kept as a versioned table, and every system change that alters a procedure goes for review before it reaches users.

**Practice sources.** Recognised standards and thinkers (NIST, ISO, OWASP, the IIA, Salim Ismail) should inform the standard as they evolve, without becoming requirements just by being read.

**The BMA watch.** The BMA publishes codes, guidance notes and consultation papers in its [documents centre](https://www.bma.bm/documents-centre/). A new one can change an obligation; the run should notice, not a person trawling 9,278 documents.

## Change 1: procedures

### How the levels divide

| Level | Says | Changes when | Approved by |
| --- | --- | --- | --- |
| Policy | What must be true, with parameters | The business decides | Board |
| Job | What must get done, and the outcome | The mandate changes | Job owner |
| Procedure | How the job is done today, step by step, across the app, other platforms and people | The system improves | Job owner; the CRCO co-signs for regulated jobs (decided by the maintainer, Oct 19, 2026) |

### New clauses: PRC

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

### Amended clauses

- **GOV-1:** "a folder per level" becomes: mandate, appetite, framework, policies, controls and the obligations register as folders; **jobs in the register file; procedures in the database (PRC-1), with readable copies (PRC-8)**.
- **UIX-3:** the Governance band gains **Procedures** after Jobs register.
- **UIX-4:** the governance strip on every work page also shows **the procedure version in force** (for example `J23-P1 v1.4`).

**Why amend in place.** Changing a clause's requirement is a major version under Plumbline's rules. DEC-003 allowed an exception while no app or board has adopted a version, and none has. This proposal uses that exception, and it is the last time: once v0.6.0 is accepted, Plumbline treats the exception as spent, and the first app conformance file should pin v0.6.0 or later.

### In the app

- **Governance → Procedures:** a list per job; a record shows its steps, version history and a side-by-side comparison.
- **Home for the job owner and the CRCO:** a "Procedure changes" queue. The CRCO sees only regulated jobs.

## Change 2: practice sources

A new folder, `sources/`, separate from `obligations/`. Obligations are the law; sources are advice.

| Rule | |
| --- | --- |
| What an entry holds | Id, title, version (to confirm), the clause groups it informs, owner, last reviewed |
| What it can do | Produce proposals only. It never adds a requirement by being read |
| How the Answers column shows it | `practice: SRC-NIST-AIRMF`, never an `OBL-` id, so the board sees law, recognised standard, and own choice apart |
| Cadence | Reviewed quarterly by the nightly run's first run of the quarter: has a new version been published? At most three proposals a quarter |
| The test for a proposal | It cites the specific passage **and** names a gap in a real app it would close. A proposal with no gap is declined |
| Adding a source | Itself a proposal the maintainer decides |

**First list (versions to confirm):**

| Id | Source | Informs |
| --- | --- | --- |
| SRC-NIST-AIRMF | NIST AI Risk Management Framework, with its generative AI profile | AGT clauses, AI inventory, material AI changes |
| SRC-ISO42001 | ISO/IEC 42001, AI management systems | How AI governance sits in the chain |
| SRC-ISO27001 | ISO/IEC 27001, information security | IAM, DAT, STK, incidents |
| SRC-OWASP-LLM | OWASP Top 10 for LLM applications | Agent envelopes, gateways, prompt injection |
| SRC-OWASP-ASVS | OWASP Application Security Verification Standard | Web app security checks |
| SRC-IIA-3L | IIA Three Lines Model | Board, CRCO, operator and job-owner roles |
| SRC-COSO-ERM | COSO Enterprise Risk Management | Risk appetite and framework (levels 1 and 2) |
| SRC-EXO | Salim Ismail, *Exponential Organizations* and his AI-native playbook | Mandate, destination, job design, the levels of help. **Strategy only: never a clause** |

## Change 3: the BMA watch

- **Watched source** in `obligations/watch-list.md`: the BMA documents centre, `https://www.bma.bm/documents-centre/`.
- **Filter.** Keep regulatory and legislative documents (codes, rules, guidance notes, consultation papers, policy statements) in AML/ATF, corporate service providers, investment business, fintech and AI, cyber, and operational resilience and outsourcing. Note public warnings for the CRCO. Ignore statistics, return templates, discount rates and press releases.
- **Sanctions updates do not go to Plumbline.** They change who is listed, not how apps are built; the screening systems take them in (MOD-6).
- **Nightly check.** Read the first one or two listing pages for items uploaded since the last report; open a PDF only when it passes the filter; one line per item in the report (title, date, one-line summary, the obligation it may touch).
- **Proposals, never edits.** A new code, final guidance note or consultation paper becomes a draft proposal for the CRCO and counsel. The final BMA AI guidance note will arrive this way.
- **A log.** `obligations/bma-log.md`, written by the run and never edited: every item seen, with date, title, link and whether it passed the filter.

## Changes to RUN.md and AUTONOMY.md

- **RUN.md step 2:** after assessing an app, scan its code changes since the last run for step ids and draft procedure versions (PRC-3, PRC-6).
- **RUN.md step 1:** the BMA check and log.
- **RUN.md step 7:** the quarterly practice-sources review.
- **Report:** new sections "Procedure changes" (per app: drafts waiting, policy-fit result, who must accept) and "BMA" (new items that passed the filter).
- **AUTONOMY.md:** the run may draft procedure versions and write `bma-log.md`; it may never accept a procedure version, add a practice source, or move a flag.

## Impact

- 99 clauses in total. P1 among the new ones: PRC-1, PRC-4, PRC-5, PRC-6.
- The amendment exception is spent from v0.6.0 on.

## Decision needed

Maintainer: accept as v0.6.0.
