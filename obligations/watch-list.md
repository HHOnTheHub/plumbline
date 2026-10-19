# Obligations watch list


| Date | Item | What the nightly run does |
| --- | --- | --- |
| 30 Oct 2026 | BMA AI consultation closes; final guidance note to follow | From this date, flag monthly that OBL-AIGN needs re-mapping once the final note is out |
| To confirm | Commencement of the Computer Misuse Act 2024 and Cybersecurity Act 2024; CNII designations | Flag OBL-CMA and OBL-CYBA as unverified in every report until counsel confirms |
| To confirm | Whether the Operational Resilience and Outsourcing Code binds a CSP and investment business licensee | Flag OBL-OROC for any corporate service provider or investment business licensee until counsel confirms |
| Each entry | `next_check` date passed | List the entry under "Needs the operator" for the CRCO and counsel |

## Watched source: the BMA documents centre

`https://www.bma.bm/documents-centre/` (added v0.6.0). The nightly run reads the first one or two listing pages for items uploaded since the last report and logs every item in the operator's private `OPS/bma-log.md`.

| Keep | Note for the CRCO | Ignore |
| --- | --- | --- |
| Codes, rules, guidance notes, consultation papers and policy statements in AML/ATF, corporate service providers, investment business, fintech and AI, cyber, operational resilience and outsourcing | Public warnings | Statistics, return templates, discount rates, press releases. Sanctions updates go to the screening systems (MOD-6), not here |

A kept item gets one line in the report (title, date, one-line summary, the obligation it may touch). A new code, final guidance note or consultation paper also becomes a draft proposal for the CRCO and counsel. The run never edits an obligation.
