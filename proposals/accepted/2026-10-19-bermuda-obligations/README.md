# Proposal: Bermuda obligations library, the Answers column and new clauses (Plumbline v0.5.0)

Oct 19, 2026 · Proposed for the maintainer · Version: **minor** (a column and 16 clauses added, nothing removed) · Files: this README and [obligations-library.md](obligations-library.md)

**Every obligation in this proposal is unverified.** It is drawn from a research map, not legal advice. Accepting the proposal adds the structure and the clauses; each obligation entry stays `unverified` until Bermuda counsel confirms it and the entity's CRCO confirms how it applies.

## Why

Plumbline's clauses say how apps are built, but not which law each rule answers. A director, the CRCO or the BMA asking "why does this rule exist?" should get a citation. The Hard-Boundaries Register (58 instruments) and the BMA's draft AI guidance note also show gaps the current 75 clauses do not cover: the regulatory perimeter for agents, an AI use-case inventory that includes vendor and workbench AI, a lawful basis per feature under PIPA, fairness in AI decisions about people, and retention.

## Change 1: an obligations library

A new folder, `obligations/`, with one file per instrument: 16 entries covering PIPA, the AI guidance note, the Outsourcing Code, financial crime and sanctions, the licensing perimeter, the Human Rights Act, electronic transactions, computer misuse, cybersecurity, consumer protection, copyright, economic substance and the sandbox. Drafts are in [obligations-library.md](obligations-library.md), each with permanent requirement ids and the clauses that answer them.

Each entity's obligations register (GOV-7) cites these ids instead of rewriting the law. Corporate, tax, employment and immigration instruments stay in the entity's own register.

**Who owns the library.** This is the one part of Plumbline the maintainer does not approve alone:

| Change | Proposed by | Checked by | Approved or noted by |
| --- | --- | --- | --- |
| Add or change an obligation entry | CRCO of any entity (or the nightly run, as a proposal only) | Counsel | the maintainer accepts into Plumbline; each board notes it |
| Mark an entry verified | Counsel | — | The CRCO records it; the board pack shows the status |
| Change an entry's `applies` for one entity | That entity's CRCO | Counsel | That entity's board, through its technology policy |

## Change 2: an Answers column on every clause

`standard/clauses.md` gains an **Answers** column after Clause. It lists requirement ids from the library, or `practice` where the clause is Plumbline's own good practice with no legal source. Being honest that many clauses are practice is the point: the board can see which rules the law requires and which the entity chose.

| Clause group | Answers (proposed) |
| --- | --- |
| GOV-5 | OBL-OROC.1 |
| GOV-7 | Every OBL entry (the register that cites them) |
| GOV-1 to GOV-4, GOV-6, GOV-8 to GOV-10 | practice |
| JOB-1 to JOB-5 | practice |
| LIF-1, LIF-3 | OBL-AIGN.8 |
| LIF-2 | practice |
| LIF-4 | OBL-AIGN.5, OBL-AIGN.7, OBL-SBOX.1 |
| HLT-1 to HLT-3 | practice |
| IAM-1 to IAM-6 | OBL-PIPA.3 |
| DAT-1, DAT-2, DAT-5, DAT-6 | OBL-PIPA.3 |
| DAT-3 | OBL-AIGN.1, OBL-AIGN.8, OBL-AMLR.2 |
| DAT-4 | OBL-PIPA.6 |
| DEL-1, DEL-6, DEL-7 | OBL-PIPA.3 |
| DEL-7 | also OBL-AIGN.7 |
| DEL-10 | OBL-AIGN.4 |
| DEL-2 to DEL-5, DEL-8, DEL-9 | practice |
| DOC-1 to DOC-3 | practice |
| STK-1 | OBL-OROC.3, OBL-OROC.4, OBL-OROC.5, OBL-PIPA.5, OBL-AIGN.10, OBL-CDA.1 |
| STK-2 | OBL-OROC.6 |
| STK-3 | practice |
| INT-1 | OBL-AIGN.6 |
| INT-2 | practice |
| INT-3 | OBL-PIPA.6 |
| AGT-1 | OBL-AIGN.8, OBL-AIGN.9 |
| AGT-2 | OBL-AIGN.6 |
| AGT-3 | OBL-AIGN.1 |
| UIX-5 | OBL-OROC.1 |
| UIX-6 | OBL-AIGN.5, OBL-AMLR.3, OBL-POCA.1, OBL-SANC.2 |
| UIX-1 to UIX-4, UIX-7, UIX-8 | practice |
| FBK-6 | OBL-PIPA.6 |
| FBK-1 to FBK-5 | practice |
| MOD-1 | OBL-CPA.1 |
| MOD-3 | OBL-PIPA.3 |
| MOD-2, MOD-4, MOD-5 | practice |

`check:governance` gains one check: every id in the Answers column exists in `obligations/`, and every library requirement is answered by at least one clause or listed as an open gap.

## Change 3: new clauses

### Answering the law

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| AGT-4 | **Perimeter check.** Every agent tool, automated action and product feature is mapped against the licensing perimeter before it ships. Anything that would be licensable activity the entity does not hold a licence for is blocked in code, not in a prompt. The CRCO signs the map | OBL-PERIM.1 to .9, OBL-AIGN.6 | all | Perimeter map in `governance/`; tests that blocked actions are refused | Ask | P1 |
| AGT-5 | **AI use-case inventory.** Every use of AI is recorded: in-app agents and model calls, AI inside vendors' tools (screening, KYC), and workbench tools that hold company data. Each entry has a materiality tier, owner, human-oversight design and change log. The inventory is generated from the agent registry and the outsourcing register, not kept by hand | OBL-AIGN.1 to .3, .10, .11, OBL-SBOX.1 | all | Inventory page or file, generated | Do (draft) | P2 |
| AGT-6 | **Material AI changes are managed.** A change to the model, provider, data, prompts, retrieval, permissions, integration or autonomy of a material use case has a change record and passes its test set before release. Switching to a pre-tested fallback provider under an approved plan is a routine change | OBL-AIGN.4, OBL-AIGN.9 | when the app has a material AI use case | Change records in the evidence log | Ask | P2 |
| AGT-7 | **Fairness in decisions about people.** Any AI-assisted decision about a person (matching, screening, eligibility, pricing) is tested for unfair outcomes on Human Rights Act grounds before going live and after each material change, and a named person makes the decision | OBL-HRA.1, OBL-AIGN.5 | when AI assists decisions about people | Test record and decision point | Ask | P2 |
| AGT-8 | **No AI overclaiming.** Product copy, decks, disclosures and regulator correspondence describe AI as it is (built, in shadow, or planned) | OBL-CPA.1, OBL-AIGN.12 | all | Review of public text | Ask | P3 |
| AGT-9 | **Agents do not bind the entity alone.** No agent forms, accepts or varies a contract, or sends a binding commitment, without a named person's approval. Deeds are never executed electronically by an agent | OBL-ETA.1, OBL-ETA.2 | when agents act externally | Decision points and tests | Ask | P2 |
| DAT-7 | **A lawful basis per feature.** Every feature that uses personal information records its purpose and lawful basis in a register, and the privacy officer is named in governance | OBL-PIPA.1, OBL-PIPA.2 | all | Register in `governance/`; JOB cards cite it | Do (draft) | P1 |
| DAT-8 | **Overseas transfer assessments.** Every vendor that stores or processes personal information outside Bermuda has a transfer assessment on file, reviewed when the vendor, region or use changes | OBL-PIPA.5 | all | Assessment linked from the outsourcing register | Do (draft); Operator (sign) | P2 |
| DAT-9 | **Breach procedure.** A personal-information breach procedure is written, linked to the incidents job, and rehearsed yearly; the privacy officer decides on notification | OBL-PIPA.4 | all | Procedure and rehearsal record | Do (draft) | P2 |
| DAT-10 | **Retention as parameters.** Each record class has a retention period set as a parameter in an approved policy (AML records at the period the Regulations set, to be confirmed by counsel) and enforced by the database | OBL-PIPA.6, OBL-AMLR.2 | all | Policy parameters and scheduled job | Ask | P2 |
| STK-4 | **Important business services.** Each app's important business services are named with impact tolerances, and recovery is tested against them | OBL-OROC.2, OBL-OROC.6 | all | Section in the architecture doc; test record | Do (draft) | P2 |
| STK-5 | **Ownership and control of IP.** Repositories, models and data are owned by the entity; provider terms fix ownership of model output; decisions about the entity's IP are made by its people in Bermuda | OBL-CDA.1, OBL-ESA.1 | all | Outsourcing register terms; repository ownership | Maintainer | P3 |
| INT-4 | **Agents act only where authorised.** An agent or browser tool acts in another system only with that system's authorisation and within its terms, and every action is logged | OBL-CMA.1 | when agents act in other systems | Gateway logs; approved-tools list | Ask | P2 |
| MOD-6 | **Screening systems.** Customer due diligence, ongoing monitoring and sanctions screening run through a gateway; every result is evidence; matches and suspicions go to the MLRO, who decides; a sanctions match triggers the freeze-and-report procedure | OBL-AMLR.1, .3, OBL-POCA.1, OBL-ATFA.1, OBL-SANC.1, .2, OBL-AIGN.11 | when the app onboards or screens people or companies | Gateway, evidence entries, decision points | Ask | P1 |

### Role management (added in response to the maintainer's question)

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| IAM-7 | **Roles are governed, access follows roles.** A role register in `governance/` defines each role (director, CRCO, MLRO, job owner, operator, analyst, outsider types), the jobs it performs and the access areas it carries. People get access only by being assigned a role; no access area is granted to a person directly. The menu shows only what a person's roles allow | OBL-PIPA.3, OBL-AMLR.3 | all | Role register; `user_roles` and `role_areas` tables; RLS reads roles | Ask | P1 |
| IAM-8 | **Who assigns which role is set by policy.** The access policy names the assigner for each role: the board appoints directors and control functions (CRCO, MLRO); the CRCO or an authorised person assigns operational roles. Every assignment records who assigned it, why and until when; incompatible roles cannot be held together (for example inviter and approver of the same thing); assignments are reviewed on a cycle and expire if not re-confirmed | OBL-OROC.1, OBL-PIPA.3 | all | Policy parameters; trigger refusing self-assignment and incompatible pairs; review records | Ask | P1 |

IAM-7 and IAM-8 sharpen IAM-3 (access areas, no self-grants); IAM-3 stays as the database rule underneath them.

## Change 4: RUN.md

Add to step 1: read `obligations/` and the watch list. Add to the report: an "Obligations" line per entity (verified, unverified, past `next_check`) and any watch-list date that has passed. The run never edits an obligation; it may propose.

## Impact

- 16 clauses added (91 in total); every app gets new gaps. P1 among them: AGT-4, DAT-7, MOD-6 (for apps that screen), IAM-7, IAM-8.
- The board pack gains a line per entity: obligations verified against unverified, and clauses answering law against practice.
- Counsel's first task is to verify the library, starting with OBL-PIPA, OBL-AIGN, OBL-OROC and OBL-PERIM.

## Decision needed

Maintainer: accept as v0.5.0, with the ownership table above. Then send the library to counsel and each CRCO for verification.
