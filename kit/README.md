# Plumbline kit

Shared code that implements Plumbline clauses, so apps install it instead of rebuilding it. **v0.1.0** has five database modules as Supabase migrations, with tests, and a reference app that proves they work together.

## Modules

| Module | Migration | Clauses it meets | What an app gets |
| --- | --- | --- | --- |
| 01 Parameters | `…_01_parameters.sql` | GOV-8, DAT-10 | `parameters` table; `param_int`, `param_bool`, `param_text`, `review_until` |
| 02 Evidence log | `…_02_evidence_log.sql` | DAT-3, DAT-4, DAT-10 | Append-only `evidence_log` (no update, delete or truncate for any role); `log_evidence(...)`; actor stamped by the database |
| 03 Identity, roles and areas | `…_03_identity_and_roles.sql` | IAM-1, IAM-3, IAM-4, IAM-5, IAM-7, IAM-8 | Invitation-only sign-up; `access_areas`, `roles`, `role_areas`, `role_incompatibilities`, `role_assignments`; `has_area`, `has_role`, `my_areas`; assign, revoke and re-confirm with review dates; no self-assignment; Workspace-domain and MFA rules as parameters; `apply_retention()` |
| 04 Flags | `…_04_flags.sql` | LIF-1 to LIF-4, AGT-4 | `feature_flags` (off, shadow, live, audience); gate records; `switch_on`, `set_flag_state`, `flag_allows`, `my_flags`; licensed work stays off until the licence parameter is true |
| 05 Procedures | `…_05_procedures.sql` | PRC-1, PRC-4, PRC-5 | Versioned `procedures`, `procedure_versions`, `procedure_steps`; draft, accept (owner, not the drafter), co-sign (risk owner, for regulated), reject with a reason; a flag goes up only when an accepted procedure names it |

Every table has row-level security on; people write only through security-definer functions; every action is evidenced with the clauses it carries out.

## Using it in an app

```bash
npx @hhonthehub/plumbline-kit migrations supabase
```

That copies the kit's migrations into the app's `supabase/migrations`. They have fixed timestamps per kit version, so they sort before the app's own later migrations. Then, in the app's **own** migration:

- add its access areas, roles, role areas and incompatible pairs;
- set its parameters (`update public.parameters set value = ... where key = ...`), such as `identity.workspace_domain`;
- create its flags (off) and procedures.

Copy the tests too (`npx @hhonthehub/plumbline-kit tests supabase`) so the app's CI proves the kit's rules hold in that app. An app moving existing live features onto flags records a `gate:grandfathered` evidence entry for each.

Until the package is published to npm, run the same command from a checkout: `node path/to/plumbline/kit/bin/plumbline-kit.mjs migrations supabase`.

## The reference app

[reference/](reference/) is **Example Advisory Ltd**, a fictional firm: a small left-menu app (Governance, The machine, Across the machine) on the kit, with four local accounts in different roles. CI starts it from scratch on every pull request, runs the 106 database tests and an end-to-end smoke test through the API, and builds the app.

To run it locally (needs Docker and the Supabase CLI):

```bash
cd kit/reference
npm install
npm run sync
supabase start
cp .env.example .env.local    # then paste the publishable key from `supabase status`
npm run dev                   # http://localhost:5181
```

Sign in with `operator@example.com`, `director.a@example.com`, `crco@example.com` or `analyst@example.com` and the local password `local-only-pass`. Try accepting the screening procedure as the analyst, co-signing it as the CRCO, and switching screening on as the operator.

## Rules

- **Its own version track.** Kit releases are tagged `kit-vX.Y.Z` with their own [CHANGELOG](CHANGELOG.md). Standard releases stay `vX.Y.Z` (boards adopt those); apps upgrade the kit whenever they like.
- **Each module names the clauses it meets**, so an app's conformance check can count them.
- **Generic only.** Nothing specific to one organisation; parameters instead of hard-coded rules; fictional fixtures (Example Advisory Ltd).
- **No secrets, keys or data.** Those live in each app's environment.
- **Promoted when a second app needs it**, rewritten, never copied from a private repository (see [PUBLIC-SAFETY.md](../PUBLIC-SAFETY.md)).
