# Plumbline

A governance-first engineering standard for building business apps to the grade a licensed firm needs, whether or not yours is licensed. Every app is measured against it the way a builder checks a wall against a plumb line: one fixed reference, checked often.

**Current version: v0.6.1** (see [CHANGELOG.md](CHANGELOG.md)). Written for small organisations building with Claude Code, Supabase and TanStack Start, with a Bermuda obligations library. Maintained by Hannes Heyns ([@HHOnTheHub](https://github.com/HHOnTheHub)).

> **Not legal advice.** The [obligations library](obligations/) is an unverified research map of Bermuda laws, BMA codes and guidance. Every entry is marked `unverified` until your own counsel confirms it against the consolidated text. Do not rely on it as if counsel had checked it.

## The idea in one paragraph

Each organisation's board and risk owner set the rules. Every app traces what it does back to those rules: jobs before features, one chain of authority from mandate to evidence, policies as versioned text with parameters the app reads, features that ship switched off behind flags, an append-only evidence log, and access enforced by the database. A nightly run measures each app against the standard's clauses, makes small safe improvements on branches, asks before anything larger, and reports to the operator, the CRCO and the board what changed and what matured.

## What is here

| Path | What it is |
| --- | --- |
| [standard/General App Architecture.md](standard/General%20App%20Architecture.md) | The standard, explained: why and how every app is built |
| [standard/clauses.md](standard/clauses.md) | The same standard as 99 checkable clauses with permanent ids, each naming the obligations it answers |
| [obligations/](obligations/) | Bermuda laws, BMA codes and guidance that bind how systems are built. **All unverified** |
| [sources/](sources/README.md) | Practice sources (NIST, ISO, OWASP, IIA, COSO, Salim Ismail): advice, not law |
| [examples/harbour-advisory/](examples/harbour-advisory/README.md) | A fictional firm applying Plumbline: its menu, a conformance excerpt, a procedure |
| [prototypes/governed-app-experience.html](prototypes/governed-app-experience.html) | A clickable prototype of the standard app shell, with fictional data |
| [RUN.md](RUN.md) | The nightly run, step by step |
| [AUTONOMY.md](AUTONOMY.md) | What the run may do alone, what it must ask, and what it never does |
| [apps.example.yaml](apps.example.yaml) | The shape of the private list of apps an operator keeps |
| [templates/](templates/) | Files an app copies in: conformance, technology policy |
| [plugins/plumbline/](plugins/plumbline/) | A Claude Code plugin with the Plumbline skills |
| [decisions/](decisions/) | Why the standard is the way it is |
| [proposals/](proposals/) | Changes considered, accepted or declined |
| [kit/](kit/README.md) | Shared code that implements the clauses (own version track, `kit-vX.Y.Z`). Empty for now |
| [PUBLIC-SAFETY.md](PUBLIC-SAFETY.md) | What may never enter this public repository, and the checks that enforce it |

## Using it

**Public standard, private operations.** This repository holds only the standard. Each organisation that uses it keeps a private folder of its own (called `OPS` in [RUN.md](RUN.md)) with its list of apps, nightly reports and private decisions. Never commit those here: a report lists each app's security gaps.

Each app carries three things:

1. `governance/conformance.md`, from [templates/conformance.md](templates/conformance.md): the Plumbline version the app pins, and a status for every clause (met, partial, gap, not applicable, or exception with approver and expiry).
2. A technology policy in the app's governance, from [templates/technology-policy.md](templates/technology-policy.md): how the organisation's board adopts a Plumbline version and approves exceptions.
3. A line in its `CLAUDE.md`: *This app follows Plumbline (https://github.com/HHOnTheHub/plumbline), version in `governance/conformance.md`. Read `standard/clauses.md` before changing governance, access, data or delivery.*

Pin a tag (for example `v0.6.1`), not `main`.

## How Plumbline changes

```
Lesson in any app ──▶ issue or pull request (see CONTRIBUTING.md) ──▶ the maintainer decides
   ──▶ standard and clauses updated, CHANGELOG entry, decision record, new tag
   ──▶ apps that pin the new version update their conformance
```

| Version | When | What apps must do |
| --- | --- | --- |
| Patch | Wording only | Nothing |
| Minor | A clause added or a check sharpened | Update conformance within 30 days |
| Major | What a clause requires changes, or a clause is removed | The organisation's board adopts it before the app moves to it |

Plumbline follows its own rules: clause ids are permanent and never reused, every change has a changelog entry and a decision record, and an automated run can only propose changes, never make them.

## Contributing

Suggestions are welcome: see [CONTRIBUTING.md](CONTRIBUTING.md) and [PUBLIC-SAFETY.md](PUBLIC-SAFETY.md). Keep anything that identifies your organisation, its people or its systems' weaknesses out of issues and pull requests.

## Licence

Documents are licensed under [CC BY 4.0](LICENSE-docs.md); the plugin and any code under [Apache-2.0](LICENSE). Use and adapt it, with credit.
