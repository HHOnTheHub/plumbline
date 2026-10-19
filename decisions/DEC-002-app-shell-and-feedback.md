# DEC-002: The app shell and in-app feedback join the standard; the run reads feedback only through a de-identified export

Oct 19, 2026 · Decided by the maintainer · Proposal: [proposals/accepted/2026-10-19-app-shell-and-feedback.md](../proposals/accepted/2026-10-19-app-shell-and-feedback.md)

**Decision.** Plumbline v0.3.0 adds the UIX clauses (the shared app shell, role views, maturity signals) and the FBK clauses (in-app feedback). Of the two options for how the nightly run sees feedback, option (a) is chosen: each app publishes a nightly de-identified export, and the run reads only that.

**Why (a).** The run must not read production data. A de-identified export keeps that rule intact except for one narrow, testable door: one endpoint, one read-only key per app, its hash alone stored in the app, the key itself in the Mac's keychain. The redaction is tested in the app (FBK-6), and the run stops if it ever sees a name, email or record identifier.

**What changed.** 14 clauses added (UIX-1 to UIX-8, FBK-1 to FBK-6). FBK-6 was not in the proposal as written; it is how option (a) is specified. RUN.md gains step 2.6 and a Feedback section in the report. AUTONOMY.md names the export as the one exception to "never read production data".

**For the boards.** Minor version: each board notes it at its next quarterly report through its technology policy.
