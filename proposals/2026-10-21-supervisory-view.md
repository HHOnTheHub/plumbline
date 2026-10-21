# Proposal: a supervisory view, ready for embedded supervision (v0.7.0)

Oct 21, 2026 · Proposed for the maintainer · Version: **minor** (7 clauses added, nothing changed or removed) · Prototype: Governance → Regulator view, and the "Regulator (preview)" role, in [prototypes/governed-app-experience.html](../prototypes/governed-app-experience.html)

## Why

Regulators are moving from after-the-fact reports towards supervision built into the systems firms run on: requirements expressed in machine-readable form, monitored continuously, with assurance the regulator can verify rather than take on trust. The idea is usually called **embedded supervision** (Auer, BIS Working Paper 811, 2019), and regulators have started piloting it, mostly for digital-asset platforms.

A Plumbline app already holds most of what a supervisor needs: policies as versioned text with parameters, an append-only evidence log with the rule version in force, risk ratings against appetite, KRIs with limits, an AI use-case inventory and an outsourcing register. What is missing is a safe way to let a regulator **see** it: a read-only view, proof the record has not been altered, a machine-readable export, and rules about what is shared and when.

This proposal adds those as clauses, so an organisation can build the view, use it internally first, and offer it to its regulator as a pilot when it is ready. It never requires giving a regulator access.

## Principles

1. **Same records, no special report.** The regulator reads the records the firm runs on, not a document compiled for them.
2. **Read-only and scoped.** The regulator can look, never change, and sees only what the agreed scope allows.
3. **Aggregates by default, detail on request.** Client-level records are shared only through a logged request the firm's risk owner answers, under its confidentiality and data-protection policies.
4. **Verify, don't trust.** The regulator can check for itself that the evidence log is intact.
5. **Both sides see the access.** Every regulator visit is logged and shown to the board and risk owner.
6. **Inside first.** The board and risk owner use the view on real data before anyone outside does.
7. **No access without terms.** Access starts only as a pilot under written terms, approved by the board with counsel's advice, ideally through the regulator's own innovation or sandbox route.

## New clauses: SUP

| Id | Clause | Answers | Applies | Check | Fix | Priority |
| --- | --- | --- | --- | --- | --- | --- |
| SUP-1 | **A read-only supervisory view.** The app has a regulator role with its own routes and row-level policies: read-only, scoped to what the pilot terms allow, separate from every staff route. It shows position against appetite, KRIs, policies in force and changes, AI use cases, outsourcing, incidents and notifications, evidence integrity, requests and its own access log | OBL-AIGN.1, OBL-OROC.1 | all (built; switched off until SUP-7) | Routes, RLS tests proving the role cannot write or reach staff data | Ask | P3 |
| SUP-2 | **A verifiable evidence log.** Each evidence entry carries the hash of the previous entry; a checkpoint with a root hash is sealed every night; the regulator (when a pilot runs) receives each root, so it can recompute the chain and detect any change | OBL-AIGN.8, OBL-AMLR.2 | all | Hash column and checkpoint job; a test that altering an entry breaks verification | Ask | P2 |
| SUP-3 | **A machine-readable export.** Policies with clause ids, versions and parameters; the risk register and KRIs with limits; the AI use-case inventory; the outsourcing register; incidents; conformance. One documented JSON format, versioned | OBL-AIGN.1 | all | Export endpoint and schema file | Ask | P3 |
| SUP-4 | **Aggregates by default; detail by request.** The view shows aggregates and metadata. Client-level or personal records are shared only through a request the risk owner approves, logged on both sides | OBL-PIPA.1, OBL-PIPA.3, OBL-PIPA.6 | all | Request workflow; RLS keeps personal data out of the regulator role | Ask | P2 |
| SUP-5 | **A notification feed.** Defined events (KRI breach, control failure, incident, material AI change, material outsourcing change) are sent to the regulator under a written notification policy with parameters for what and how fast | OBL-OROC.5, OBL-AIGN.4 | when a pilot runs | Notification policy; feed records in the evidence log | Ask | P3 |
| SUP-6 | **Inside first.** The board and risk owner use the supervisory view on real data, as the regulator would see it, before any regulator access is considered | practice | all | Preview mode and its use recorded | Do | P3 |
| SUP-7 | **Access only under written terms.** Regulator access starts only as a pilot with written terms (scope, period, data, notification rules, exit), approved by the board with counsel's advice; it is reviewed at least yearly | OBL-OROC.1, OBL-SBOX.1 | when access is offered | Board resolution and terms on file | Operator | P3 |

## In the app

- **Governance → Regulator view** (staff): what the regulator would see, readiness against SUP-1 to SUP-7, and the path to a pilot. A button previews the view as the regulator.
- **Regulator role**: its own left menu, "Supervisory view", with Overview, Risk and KRIs, Governance and changes, AI use cases, Outsourcing, Incidents, Evidence integrity, Requests and Access log. A banner says it is a preview until a pilot starts.

## Path to a pilot

| Stage | What happens | Gate |
| --- | --- | --- |
| 1 Internal preview | Board and risk owner use the view on real data | The board is comfortable with what it shows |
| 2 Counsel and board | Confidentiality, data protection and outsourcing reviewed; scope and notification rules written | Board resolution |
| 3 Demonstration | The regulator sees the view on fictional data | The regulator wants to go further |
| 4 Pilot | Read-only access through the regulator's innovation or sandbox route, limited scope and period | Written pilot terms |
| 5 Standing access | The view becomes part of how the firm is supervised | Agreed with the regulator; reviewed yearly |

## Impact

106 clauses in total. All P2 or P3: no app must build this before its foundations. SUP-2 and SUP-4 are worth doing early because they strengthen the evidence log and personal-data handling whether or not a regulator ever looks.

## Decision needed

Maintainer: accept as v0.7.0.
