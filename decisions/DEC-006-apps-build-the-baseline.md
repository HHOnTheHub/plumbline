# DEC-006: The apps build the baseline

Nov 2, 2026 · Decided by the maintainer when this change merges · Proposal: [proposals/accepted/2026-11-02-apps-build-the-baseline.md](../proposals/accepted/2026-11-02-apps-build-the-baseline.md)

**Decision.** Plumbline's baseline is promoted up from the operator's apps, not pushed down into them. Every night the run looks at what merged in each contributing app since its `promoted_through` commit, writes promotion candidates into `OPS/promotions/`, and asks the operator about each. On a yes, the promotion is rewritten into Plumbline in a separate session, through the promotion checklist and a pull request. "Proven in one of the operator's apps" joins "needed twice" as a reason to promote.

**Plumbline is the only channel between apps.** The run never carries anything from one app into another. An app learns from another only through Plumbline, after the rewrite, so organisations share what works without seeing anything about each other.

**Why.** The baseline should record what has worked for real, under a real board, rather than what was designed ahead of use.

**What stays the same.** The run never writes to Plumbline and never merges. Nothing reaches this public repository except by rewriting. Every app is measured against the standard as before.
