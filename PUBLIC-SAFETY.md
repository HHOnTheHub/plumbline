# Public safety

This repository is public. Nothing from any organisation's private apps, governance or operations may ever enter it. This page says what is banned, how something from a private app becomes shareable, and the checks that stop a mistake.

## Never in this repository

| Banned | Examples |
| --- | --- |
| Names of real organisations, apps, domains, repositories or GitHub organisations that use Plumbline | Company names, `app.<company>.com`, private repo names |
| Names or details of real people other than the maintainer | Directors, officers, staff, clients, family |
| Client, customer or personal data of any kind | Names, emails, records, files, screenshots with real data |
| Any app's conformance, reports, gaps or security findings | "App X has no RLS test", nightly reports, pen-test notes |
| Secrets and configuration | Keys, tokens, passwords, Supabase project URLs, environment files |
| Private documents and links | Board papers, regulator correspondence, licence applications, consultation responses, links to private docs or artifacts |
| Entity-specific business logic | One firm's screening rules, pricing, models, deal terms |
| Local paths and machine details | `/Users/<name>/…`, keychain item names |

Examples and fixtures use the fictional firm **Harbour Advisory Ltd** and invented people.

## Promoting something from a private app

Code, a clause or a lesson from a private app reaches this repository only through **promotion**, never by copying:

1. **Needed twice.** A second app needs it, or it is clearly generic.
2. **Rewritten, not copied.** Generic names, generic tables, no entity-specific rules. Parameters replace hard-coded values.
3. **Fictional fixtures.** Tests and seeds use Harbour Advisory and invented data only.
4. **No history carried over.** Start a fresh file; never cherry-pick commits from a private repository.
5. **Scanned.** `scripts/public-safety-check.sh` passes, including the operator's private names list (below).
6. **Reviewed in a pull request.** `main` is protected; every change arrives by pull request and is read before merge.

## The checks

| Check | Where | What it catches |
| --- | --- | --- |
| `scripts/public-safety-check.sh` (generic patterns) | Local hook and CI on every pull request | Secrets, tokens, private keys, Supabase project URLs, local user paths, links to private claude.ai artifacts, real-looking email addresses |
| The private names list | Local hook only, from the operator's private folder | Names of the operator's organisations, apps, domains and people. **The list itself is sensitive, so it never enters this repository** |
| Gitleaks | CI on every pull request | Known secret formats across the full history |
| GitHub secret scanning and push protection | GitHub | Secrets at push time |
| Branch protection | GitHub | No direct pushes; changes by pull request only |

**Automated runs.** Plumbline's nightly run never writes to this repository. Any agent working here follows [CLAUDE.md](CLAUDE.md).

## If something slips through

Do not just delete it in a new commit: it stays in the history. Tell the maintainer at once. The fix is to rewrite the history to remove it, force-push once with the maintainer's approval, rotate any secret involved, and ask GitHub to purge cached views if needed.
