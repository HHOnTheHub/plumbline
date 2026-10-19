```
id: TEC
level: 3
version: 0.1.0
status: draft
owner: <standard owner>
approver: <the entity's board>
parents: <mandate clause; risk appetite clause on technology risk>
effective: <date>
next_review: <date + 1 year>
```

# Technology policy

## TEC-1 Adoption of Plumbline

TEC-1.1 This entity builds and runs its systems to the Plumbline engineering and tech-governance standard.

TEC-1.2 The version adopted is `plumbline.version = 0.6.0`. A major version is adopted only by approving a new version of this policy.

TEC-1.3 Minor versions are adopted by the standard owner without a board decision, and reported to the board in the next quarterly report.

## TEC-2 Exceptions

TEC-2.1 A clause the entity does not meet is either a gap with a date to close it, or an exception approved here, with a reason and an expiry no more than 12 months away.

| Clause | Reason | Expiry |
| --- | --- | --- |
| | | |

## TEC-3 Oversight

TEC-3.1 The board receives a technology report each quarter: Plumbline version, conformance, changes made, exceptions to renew, and decisions needed.

TEC-3.2 Automated work on the entity's systems (the Plumbline daily run, Claude Code) follows Plumbline's AUTONOMY rules: it never merges, deploys, approves, or touches production data.

TEC-3.3 `report.cadence_months = 3`
