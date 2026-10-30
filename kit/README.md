# Plumbline kit

Shared code that implements Plumbline clauses, so apps install it instead of rebuilding it: the left-menu shell, evidence log, flags, roles, procedures table, gateways and reusable job modules. **Empty for now**; modules arrive through the promotion checklist in [PUBLIC-SAFETY.md](../PUBLIC-SAFETY.md).

## Rules

- **Its own version track.** Kit releases are tagged `kit-vX.Y.Z` with their own [CHANGELOG](CHANGELOG.md). Standard releases stay `vX.Y.Z` (boards adopt those); apps upgrade the kit whenever they like.
- **Each module names the clauses it meets** (for example "evidence log: DAT-3, SUP-2"), so an app's conformance check can count them.
- **Generic only.** Nothing specific to one organisation; parameters instead of hard-coded rules; fictional fixtures (Example Advisory Ltd).
- **No secrets, keys or data.** Those live in each app's environment.
- **Promoted when a second app needs it**, rewritten, never copied from a private repository.
