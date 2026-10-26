# Example: Example Advisory Ltd (fictional)

Example Advisory is an invented firm used to show Plumbline applied. It places independent directors on client boards, runs governance reviews and holds a corporate service provider licence. Three directors, a CRCO, an MLRO and an operator run it. Nothing here describes a real company or person.

The [prototype](../../prototypes/governed-app-experience.html) shows its app.

## Its menu (UIX-3)

| Band | Pages |
| --- | --- |
| Governance | Overview · Board · Policies · Jobs register · Procedures · Changes and approvals · Improvements · Evidence log |
| The machine | 1 Lead generation: Contacts, Events, Campaigns · 2 Lead activation: Pipeline, Proposals, Onboarding · 3 Product delivery: Engagements, Placements, Client service |
| Across the machine | Risk: register, KRIs, incidents · Compliance: screening, obligations, controls · Finance: invoices, budget · People: team, training, conflicts · Technology: Plumbline, flags, agents, vendors |

## An excerpt of its jobs register (JOB-1, JOB-5)

| Id | Job | Performer | Menu home | Regulated | Level | Flag |
| --- | --- | --- | --- | --- | --- | --- |
| J02 | Grow the network | Directors | Lead generation | No | Assist | `contacts.assist` live |
| J05 | Qualify an opportunity | Directors | Lead activation | No | Assist | `pipeline.assist` live |
| J29 | Know the client | CRCO | Lead activation | Yes | Assist | `onboarding.assist` live |
| J01 | Fill a seat | Directors | Product delivery | Yes | Record | `placements.record` live |
| J23 | Screen clients and consultants | MLRO | Compliance | Yes | Assist | `screening.assist` live |
| J30 | Ongoing monitoring | MLRO | Compliance | Yes | Agent | `monitoring.agent` shadow |

## A procedure (PRC-1), version 1.4

`J23-P1` Screen a new client · job J23 · regulated, so the CRCO co-signs changes (PRC-4)

| Step | What happens | Who | Where | Mode | Carries out | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| J23-P1.1 | Client record reaches "file complete" in Onboarding | Analyst | App: `onboarding.complete()` | Manual | AML-3.2 v1.3 | `onboarding.complete` |
| J23-P1.2 | Identity, sanctions and PEP checks run at the screening provider | The app | Screening gateway, outside provider | Automated | AML-4.2 v1.3, OBL-SANC.1 | `screening.result` |
| J23-P1.3 | Clear results are prepared for review; possible matches go to the MLRO | The app | App: `screening.route()` | Assisted | AML-4.2.3 | `screening.routed` |
| J23-P1.4 | The MLRO decides on every possible match | MLRO | App: screening queue | Manual | AML-4.4 v1.1, UIX-6 | `screening.decision` |
| J23-P1.5 | High-risk clients are scheduled for re-screening every `screening.refresh_months.high` months | The app | App: scheduled job | Automated | AML-4.2 v1.3 | `screening.scheduled` |

**How v1.4 came about.** Version 1.3 said step 5 ran yearly for every client. User feedback on the screening page ("refresh dates don't match the policy") showed the app still used 12 months after the AML policy set 6 months for high-risk clients. The fix to step 5 changed the procedure; the nightly run drafted v1.4, the MLRO (job owner) accepted it, the CRCO co-signed, and only then did the flag for the new schedule go live.

## An excerpt of its conformance file

```
plumbline: v0.6.0
assessed: 2026-11-03
assessed_by: Plumbline nightly run
technology_policy: governance/policies/TEC-technology.md (status: approved)
```

| Clause | Status | Evidence or note | Exception: approver · expiry |
| --- | --- | --- | --- |
| DAT-1 | met | `supabase/tests/rls.test.mjs` lists every table with RLS on | |
| DAT-3 | met | `evidence_log` migration; test `evidence_log is append-only` | |
| IAM-3 | gap | No trigger yet stops a person granting themselves an access area | |
| PRC-5 | partial | Flags check for an accepted procedure in staging only | |
| STK-2 | exception | Nightly backups to own storage not yet in place | Board · 2026-11-30 |
| MOD-4 | n/a | The app has no ballots | |
| ... | | Every other clause, for the pinned version | |
