---
name: conformance-check
description: Check the current app against the Plumbline standard and update governance/conformance.md. Use when asked whether an app meets Plumbline, before a release, or after changes to governance, access, data or delivery.
---

# Plumbline conformance check

1. Find Plumbline: a local checkout, or https://github.com/HHOnTheHub/plumbline at the version named in this app's `CLAUDE.md`.
2. Read the pinned version from `governance/conformance.md` (create it from Plumbline `templates/conformance.md` if missing) and the matching `standard/clauses.md`.
3. For each clause, apply its Check column to this app. Record `met`, `partial`, `gap`, `n/a` (with reason) or `exception` (only if the technology policy approves it), with one line of evidence: a file path, test name or command result.
4. Update `governance/conformance.md` and its `assessed` date. Change nothing else.
5. Summarise for the user: counts by status, the P1 gaps, and exceptions expiring within 30 days.

Follow Plumbline `AUTONOMY.md`: this skill only reads the app and writes the conformance file.
