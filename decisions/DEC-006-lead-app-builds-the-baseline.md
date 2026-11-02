# DEC-006: The lead app builds the baseline

Nov 2, 2026 · Decided by the maintainer when this change merges · Proposal: [proposals/accepted/2026-11-02-lead-app-baseline.md](../proposals/accepted/2026-11-02-lead-app-baseline.md)

**Decision.** Each operator names one lead app (`lead: true` in `OPS/apps.yaml`). Shared practice is built and proven there first, and Plumbline's baseline is promoted up from it, not pushed down into it. Every night the run looks at what merged in the lead app since `promoted_through`, writes promotion candidates into `OPS/promotions/`, and asks the operator about each. On a yes, the promotion is rewritten into Plumbline in a separate session, through the promotion checklist and a pull request. "Proven in the lead app" joins "needed twice" as a reason to promote.

**Why.** The baseline should record what has worked for real, under a real board, rather than what was designed ahead of use. The lead app is where that happens first; the operator's other apps then inherit it from Plumbline.

**What stays the same.** The run never writes to Plumbline and never merges. Nothing reaches this public repository except by rewriting. The lead app is measured against the standard like any other app.
