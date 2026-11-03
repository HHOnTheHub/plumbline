# Proposal: the apps build the baseline (Plumbline v0.7.0)

Nov 2, 2026 · Proposed for the maintainer · Version: **minor** (a new run step, a new Never rule and a report section; no clause changed)

## Why

Until now, the run has measured apps against Plumbline and pulled them towards it. That is the wrong direction for the code and practice that make up the baseline. The best version of a control, a screen pattern or a database rule is found by building it for real in an app, used by real people, under a real board. Plumbline should record what has been proven in the apps, not invent it ahead of use and push it out.

An operator usually runs apps for several organisations. Each should learn from what the others have proven, and none should ever see anything about the others. So **Plumbline is the only channel between apps**: what one app proves is rewritten generically into Plumbline, and the other apps take it from there.

```
 app A ─┐                                                   ┌─> app A
 app B ─┼─> candidates ─> rewritten, fictional fixtures, ───┼─> app B
 app C ─┘   (OPS, private)  scanned, pull request            └─> app C
                            = Plumbline (public)
```

The kit already started this way: kit v0.1 was rewritten from one app's foundations. What is missing is the habit of noticing, every night, when any app has improved past the baseline.

## Change 1: a drift marker per app

Each app in `OPS/apps.yaml` gains:

- `promoted_through: <commit>`: the app commit up to which its changes have been looked at for promotion. The run looks for improvements after it, and the operator moves it forward as candidates are promoted or declined.
- `contributes: false` (optional): leave an app out of promotion. Every app in `report` or `do` mode contributes unless it says so.

Contributing does not exempt an app from any clause: every app is still measured against the standard.

## Change 2: a new run step, 2.8 "Promotion candidates"

For each contributing app, the run looks at what merged to its default branch since `promoted_through`, and asks of each change: does it make the baseline better?

- **The kit.** A change to something a kit module covers (parameters, evidence log, identity and roles, flags, procedures, and later modules) that fixes a bug, closes a gap, tightens a rule or adds a test.
- **New shared code.** A pattern any regulated app would need, built and working in the app.
- **The standard.** A practice the app has proven that no clause asks for yet, or a clause the app had to work around.

Each candidate is a file in `OPS/promotions/<date>-<app-id>-<short-name>.md`: the app and commit, what changed, why it is better, whether it is generic or specific to the organisation, what the generic version would look like, and what would have to be rewritten or removed for a public repository. When two apps solved the same problem differently, the candidate says which is better and why. The report lists new candidates under **Promotion candidates**, and each becomes an ask.

**The run never writes to Plumbline.** On the operator's yes, the promotion is made in a separate interactive session, by the promotion checklist in [PUBLIC-SAFETY.md](../../PUBLIC-SAFETY.md): rewritten, fictional fixtures, no history carried over, scanned against the operator's private names list, and reviewed in a pull request. A standard change still goes through a proposal. The maintainer merges.

## Change 3: apps never learn from each other directly

New Never rule in AUTONOMY.md: the run never carries code, names, notes or findings from one app into another app, or into another app's report section, branch or ask. A candidate lives only in the operator's private folder until it is promoted; another app gets it only from Plumbline, after the rewrite.

## Change 4: the promotion rule

PUBLIC-SAFETY.md rule 1 ("needed twice") and the kit's rule ("promoted when a second app needs it") gain a third way in: **proven in one of the operator's apps**, in use there with its tests passing.

## What does not change

- The run still never writes to Plumbline, never pushes without a yes, and never merges.
- Nothing from a private app reaches this repository except by rewriting.
- Apps adopt kit versions and standard versions when they choose.
- No clause changes. Apps need do nothing.
