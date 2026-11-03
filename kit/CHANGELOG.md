# Kit changelog

Newest first. Tags: `kit-vX.Y.Z`. The kit's version is separate from the standard's.

## kit-v0.1.1 · Nov 2, 2026

- **Fix (PRC-4): a co-sign needs the risk area held, not reached.** In v0.1.0 a role with `all_areas` (the System administrator) could co-sign a regulated procedure, because the co-sign checked `has_area`. The co-signer must now hold a role mapped to `procedures.cosign_area` in `role_areas`. New function `holds_area(area)`; `cosign_procedure_version` uses it. Rejecting a draft is unchanged.
- New migration `20261102000100_plumbline_kit_05_procedures_cosign_held.sql`; apps on v0.1.0 run `plumbline-kit migrations` again to pick it up.
- 109 database tests (3 new: the System administrator reaches but does not hold the risk area, and cannot co-sign).

## kit-v0.1.0 · Oct 26, 2026

First release: five modules as Supabase migrations, promoted from a production app and rewritten generically.

- **01 Parameters** (GOV-8, DAT-10)
- **02 Evidence log** (DAT-3, DAT-4, DAT-10)
- **03 Identity, roles and access areas** (IAM-1, IAM-3, IAM-4, IAM-5, IAM-7, IAM-8)
- **04 Flags, gates and switching on** (LIF-1 to LIF-4, AGT-4)
- **05 Procedures** (PRC-1, PRC-4, PRC-5)

106 database tests (pgTAP) and an 11-check end-to-end smoke test, run in CI against the Example Advisory reference app.
