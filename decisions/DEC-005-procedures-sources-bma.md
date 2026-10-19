# DEC-005: Procedures as a governed table; practice sources; the BMA watch

Oct 19, 2026 · Decided by the maintainer · Proposal: [proposals/accepted/2026-10-19-procedures-sources-bma.md](../proposals/accepted/2026-10-19-procedures-sources-bma.md)

**Decision.**

1. **Procedures** live in a versioned table in each app's database and are read back from the system: code declares step ids, gateways declare outside steps, job owners enter manual ones. A system change that alters a procedure produces a draft version. **The job owner accepts it; the CRCO co-signs for regulated jobs.** A flag cannot go live until the matching procedure version is accepted. The system never moves policy: a change that needs a new rule becomes a policy proposal, and one that breaks a rule is blocked. Clauses PRC-1 to PRC-8 added; GOV-1, UIX-3 and UIX-4 amended.
2. **Practice sources** (`sources/`): eight recognised standards and thinkers, cited as `practice: SRC-…`, reviewed quarterly, able to produce at most three proposals a quarter, each tied to a real gap. Salim Ismail's work informs strategy only, never a clause.
3. **The BMA watch:** the nightly run checks the BMA documents centre, logs every item in the operator's private `OPS/bma-log.md`, reports only codes, rules, guidance notes, consultation papers and policy statements in relevant sectors, and turns new ones into proposals for the CRCO and counsel. Sanctions updates go to the screening systems, not Plumbline.

**Why the CRCO co-signs only regulated jobs.** So the CRCO reviews what carries regulatory risk (AML, sanctions, personal data, onboarding) and is not buried in changes to routine jobs.

**The amendment exception is spent.** Changing GOV-1, UIX-3 and UIX-4 in place used the exception DEC-003 allowed while no app or board had adopted a version. From v0.6.0 on, any change to what a clause requires is a major version, adopted by each board.
