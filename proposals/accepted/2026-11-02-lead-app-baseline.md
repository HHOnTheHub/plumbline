# Proposal: the lead app builds the baseline (Plumbline v0.7.0)

Nov 2, 2026 · Proposed for the maintainer · Version: **minor** (a new run step and report section; no clause changed)

## Why

Until now, the run has measured apps against Plumbline and pulled them towards it. That is the wrong direction for the code and practice that make up the baseline. The best version of a control, a screen pattern or a database rule is found by building it for real in one app, used by real people, under a real board. Plumbline should record what has been proven there, not invent it ahead of use and push it out.

So each operator names one **lead app**: the app where shared practice is built and proven first. Plumbline's baseline (the kit, and the clauses where practice is ahead of them) is promoted *up* from the lead app. The operator's other apps take the kit and the standard from Plumbline, so they get what the lead app proved without seeing anything about it.

The kit already started this way: kit v0.1 was rewritten from one app's foundations. What is missing is the habit of noticing, every night, when the lead app has improved past the baseline.

## Change 1: a lead app in the apps list

`OPS/apps.yaml` gains two fields on one app:

- `lead: true`: this app is where the baseline is built. At most one per operator.
- `promoted_through: <commit>`: the lead app commit the current baseline was last promoted from. The run measures drift from here. The operator moves it forward when a promotion merges.

The lead app is still measured against the standard like every other app. Being the lead does not exempt it from any clause.

## Change 2: a new run step, 2.8 "Promotion candidates"

For the lead app only, the run looks at what merged to its default branch since `promoted_through`, and asks of each change: does it make the baseline better?

- **The kit.** A change to something a kit module covers (parameters, evidence log, identity and roles, flags, procedures, and later modules) that fixes a bug, closes a gap, tightens a rule or adds a test.
- **New shared code.** A pattern any regulated app would need, built and working in the lead app.
- **The standard.** A practice the lead app has proven that no clause asks for yet, or a clause the lead app had to work around.

Each candidate is a file in `OPS/promotions/<date>-<short-name>.md`: what changed, the lead app commit, why it is better, whether it is generic or specific to the organisation, what the generic version would look like, and what would have to be rewritten or removed for a public repository. The report lists new candidates under **Promotion candidates**, and each becomes an ask.

**The run never writes to Plumbline.** On the operator's yes, the promotion is made in a separate interactive session, by the promotion checklist in [PUBLIC-SAFETY.md](../../PUBLIC-SAFETY.md): rewritten, fictional fixtures, no history carried over, scanned, and reviewed in a pull request. A standard change still goes through a proposal. The maintainer merges.

## Change 3: the promotion rule

PUBLIC-SAFETY.md rule 1 ("needed twice") and the kit's rule ("promoted when a second app needs it") gain a third way in: **proven in the lead app**, in use there with its tests passing. A second app needing it is no longer the only trigger.

## What does not change

- The run still never writes to Plumbline, never pushes without a yes, and never merges.
- Nothing from a private app reaches this repository except by rewriting.
- Other apps are still measured against the standard, and still adopt kit versions when they choose.
- No clause changes. Apps need do nothing.
