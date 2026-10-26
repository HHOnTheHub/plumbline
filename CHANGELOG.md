# Changelog

Newest first. Every version names what changed, the clauses touched, and what apps must do.

## v0.6.1 · Oct 19, 2026

- **Renamed from Northstar to Plumbline and published.** Wording only (patch): no clause changed.
- The standard is now public: organisation-specific material (the apps list, reports, the BMA log, per-app plans and source designs) moved to each operator's private `OPS` folder. [RUN.md](RUN.md) and [AUTONOMY.md](AUTONOMY.md) name the two folders. Approvals are written as "the maintainer" (standard changes) and "the operator" (an organisation's own run); the clause Fix value `Hannes` became `Operator`.
- Added a fictional worked example, [Example Advisory](examples/example-advisory/README.md); the prototype uses fictional data.
- Added [CONTRIBUTING.md](CONTRIBUTING.md), issue templates, [apps.example.yaml](apps.example.yaml) and licences (CC BY 4.0 for documents, Apache-2.0 for code).

## v0.6.0 · Oct 19, 2026

- Procedures become a versioned table read back from the system. Added PRC-1 to PRC-8: the table, step ids in code, drafts on system change, **job owner accepts and the CRCO co-signs regulated jobs**, flags gated by accepted procedures, policy fit, evidence citing procedure versions with drift checks, readable copies in git. Amended GOV-1 (procedures in the database), UIX-3 (Procedures in the Governance band) and UIX-4 (procedure version on the governance strip). See [DEC-005](decisions/DEC-005-procedures-sources-bma.md).
- Added the practice-sources register, [sources/](sources/README.md): eight sources, quarterly review, proposals only.
- Added the BMA documents centre as a watched source, with a filter and an append-only log in the operator's private folder (`OPS/bma-log.md`).
- RUN.md: BMA check (step 1.4), procedure drafts (step 2.7), quarterly sources review; report sections "Procedure changes" and "BMA". AUTONOMY.md: the run drafts procedures and logs BMA items; it never accepts a procedure, moves a flag or changes the sources.
- 99 clauses in total. **The amend-in-place exception is now spent:** from here, changing a clause's requirement is a major version.
- **Apps must:** add the PRC clauses to `governance/conformance.md`; the first conformance file should pin v0.6.0 or later.

## v0.5.0 · Oct 19, 2026

- Added the obligations library: [obligations/](obligations/), 16 Bermuda instruments with permanent requirement ids and a watch list. **Every entry is unverified** until counsel confirms it. See [DEC-004](decisions/DEC-004-obligations-library.md).
- Added an **Answers** column to every clause: the obligation requirements it meets, or `practice`.
- Added 16 clauses: AGT-4 to AGT-9, DAT-7 to DAT-10, STK-4, STK-5, INT-4, MOD-6, IAM-7, IAM-8. 91 clauses in total.
- RUN.md reads the library and watch list and reports an Obligations section. AUTONOMY.md forbids the run from editing obligations or marking them verified.
- **Apps must:** add the 16 clauses to `governance/conformance.md` within 30 days. **Entities:** CRCO and counsel begin verification. **Boards:** note at the next quarterly report.

## v0.4.0 · Oct 19, 2026

- UIX-3 amended: every app is a left-menu CRUD admin app with three bands, Governance, The machine (1 lead generation, 2 lead activation, 3 product delivery) and Across the machine (risk, compliance, finance, people, technology). Now P1. Amended in place by exception; see [DEC-003](decisions/DEC-003-left-menu-structure.md).
- JOB-5 added: every job names its menu home.
- Prototype rebuilt as a working left-menu admin app with role-based Home, CRUD list pages, record drawers and in-app feedback.
- 75 clauses in total.
- **Apps must:** add JOB-5 and reassess UIX-3 in `governance/conformance.md`.

## v0.3.0 · Oct 19, 2026

- Added the UIX clauses: the shared app shell, "My actions", the three sidebar zones, the governance strip on every work page, role views for directors, the CRCO and the operator, decision points that name the decider, the version footer, and maturity signals to the CRCO and board (UIX-1 to UIX-8).
- Added the FBK clauses: "Improve this" on every page with context attached, a governed feedback table, nightly triage, closing the loop with the submitter, feedback in CRCO and board views, and a de-identified nightly export the run reads (FBK-1 to FBK-6). See [DEC-002](decisions/DEC-002-app-shell-and-feedback.md).
- RUN.md: feedback triage (step 2.6) and a Feedback section in the report. AUTONOMY.md: the feedback export is the one exception to "never read production data".
- Prototype: [prototypes/governed-app-experience.html](prototypes/governed-app-experience.html).
- **Apps must:** add the 14 clauses to `governance/conformance.md` within 30 days. **Boards:** note at the next quarterly report.

## v0.2.0 · Oct 19, 2026

- The standard is rebased on a licensed firm's architecture: seven-level chain, separate governance text with in-app approvals, shadow gates, two database projects for sensitive work, outsourcing register. See [DEC-001](decisions/DEC-001-regulated-grade-for-every-app.md).
- First clause list: GOV, JOB, LIF, HLT, IAM, DAT, DEL, DOC, STK, INT, AGT, MOD.
- Plumbline created: apps register, autonomy rules, daily run, templates, plugin.
- **Apps must:** add `governance/conformance.md` pinning v0.2.0.

## v0.1.0 · Oct 19, 2026

- First synthesis of the five app architectures, with light, standard and heavy settings. Superseded by v0.2.0 the same day.
