# Plumbline obligations library (draft for v0.5.0)

Oct 19, 2026 · Drafted for the maintainer · **Every entry is unverified.** Nothing here is legal advice. Each entry stays `verification: unverified` until Bermuda counsel confirms it against the consolidated text, and the CRCO of each entity confirms whether and how it applies to that entity.

**Source.** A research register of 58 Bermuda instruments compiled in October 2026 (the Bermuda Hard-Boundaries Register for AI-Native Entities, not published), and the BMA's public Consultation Paper on the Responsible Use of Artificial Intelligence in Financial Services in Bermuda (14 Aug 2026) for paragraph references to the draft guidance note. Paragraph references are written `GN` (Part B, the draft guidance note) and `CP` (Part A, the consultation paper). No section numbers of statutes are given: none were in the sources, and counsel adds them on verification.

**Scope.** Only the instruments that bind how systems are built and run. Corporate, tax, employment and immigration instruments from the register stay in each entity's own obligations register.

**Applies:** `all` every Bermuda entity · `regulated` BMA-licensed entities · `perimeter` defines what an entity without the licence must never do. Under DEC-001, Plumbline applies `regulated` obligations to every app as good practice; the column still says what is legally binding, so the board pack can show the difference.

**On acceptance**, each entry below becomes one file in `obligations/<ID>.md` with this header, and each entity's obligations register (GOV-7) cites these ids.

```
id: OBL-XXXX
title: <short title>
kind: statute | regulations | BMA code | BMA guidance (draft) | BMA guidance
in_force: <as stated in the source; to confirm>
applies: all | regulated | perimeter
verification: unverified
verified_by: —
verified_on: —
owner: <entity CRCO>; counsel verifies
source: <register entry; consolidated text on bermudalaws.bm>
next_check: <date>
```

Requirement ids (`OBL-PIPA.1`) are permanent, like clause ids. "Answered by" names the Plumbline clauses that meet the requirement; clauses marked *new* are proposed in this version.

---

## OBL-PIPA · Personal Information Protection Act 2016

`kind: statute` · `in_force: fully in force 1 Jan 2025 (source)` · `applies: all` · `verification: unverified` · Register #9

The register notes that PIPA prevails over other laws except the Human Rights Act, and that it governs every model input containing personal data.

| Req | What it requires of systems (paraphrased from the source; to confirm) | Answered by |
| --- | --- | --- |
| OBL-PIPA.1 | Personal information is used only for a lawful, stated purpose | DAT-7 *new* |
| OBL-PIPA.2 | A privacy officer is named | DAT-7 *new* |
| OBL-PIPA.3 | Proportionate safeguards protect personal information | DAT-1, DAT-2, DAT-5, DAT-6, IAM-1 to IAM-6, DEL-1, DEL-6, DEL-7 |
| OBL-PIPA.4 | Breaches are handled and reported as the Act requires | DAT-9 *new*, LIF-3 |
| OBL-PIPA.5 | Transfers of personal information overseas meet the Act's transfer rules (Supabase, hosting and model providers all sit outside Bermuda) | DAT-8 *new*, STK-1 |
| OBL-PIPA.6 | No more personal information is used or kept than the purpose needs | DAT-4, DAT-10 *new*, INT-3, FBK-6 |

## OBL-AIGN · BMA Guidance Note on the Responsible Use of AI (draft)

`kind: BMA guidance (draft)` · `in_force: draft published 14 Aug 2026; consultation closes 30 Oct 2026; final note to follow` · `applies: regulated (adopted voluntarily by every app under DEC-001)` · `verification: unverified` · Register #18

The source says the note creates no new obligations and no AI approval regime; it explains how existing requirements apply to AI. **Watch:** re-map every row when the final note is published.

| Req | What it expects (from the paragraphs the response cites; to confirm against the final note) | Answered by |
| --- | --- | --- |
| OBL-AIGN.1 | An inventory of AI use cases, which may live in existing registers, with records kept (GN 30 to 35, 115) | AGT-5 *new*, AGT-3, DAT-3 |
| OBL-AIGN.2 | Productivity tools are distinguished from use cases recorded on their own (GN 33, 36) | AGT-5 *new* |
| OBL-AIGN.3 | Use cases are tiered by materiality, proportionately (GN 9, 12, 27; Annex C indicators) | AGT-5 *new* |
| OBL-AIGN.4 | Changes to model, data, provider, configuration, prompts, retrieval, permissions, integration, use or autonomy of a material use case are managed (GN 38, 55) | AGT-6 *new*, DEL-10 |
| OBL-AIGN.5 | Human oversight is meaningful; it need not mean reviewing every output (GN 57, 61) | UIX-6, AGT-7 *new*, LIF-4 |
| OBL-AIGN.6 | Agents have tool and permission limits; higher-impact actions do not rely on prompts alone (GN 72 to 76, 74) | AGT-2, AGT-4 *new*, INT-1 |
| OBL-AIGN.7 | Agentic use is tested in a constrained environment before scaling (GN 73) | LIF-4, DEL-7 |
| OBL-AIGN.8 | Kill switches and logs exist | LIF-1, LIF-3, AGT-1, DAT-3 |
| OBL-AIGN.9 | Concentration risk in providers is managed; alternative models or providers are a resilience option (GN 84, 94; CP 27) | AGT-1, AGT-6 *new* |
| OBL-AIGN.10 | Use of AI providers and AI inside vendors' tools is handled under outsourcing (GN 7, 33, 87 to 94; CP 44) | STK-1, AGT-5 *new* |
| OBL-AIGN.11 | AI in compliance and onboarding tools is recorded and tested by the firm (GN 102 to 104) | AGT-5 *new*, MOD-6 *new* |
| OBL-AIGN.12 | No "AI washing": claims about AI match what is real (GN 100) | AGT-8 *new* |

## OBL-OROC · Operational Resilience and Outsourcing Code (BMA, Sept 2025)

`kind: BMA code` · `in_force: issued Sept 2025; insurers comply by 31 Mar 2028 (source)` · `applies: regulated` · `verification: unverified` · Register #17

**Open for counsel:** it is not yet confirmed how far this Code applies to a corporate service provider and investment business licensee.

| Req | What it requires (paraphrased; to confirm) | Answered by |
| --- | --- | --- |
| OBL-OROC.1 | The board owns operational resilience | GOV-5, UIX-5 |
| OBL-OROC.2 | Important business services are identified, with impact tolerances | STK-4 *new* |
| OBL-OROC.3 | Outsourcing has written agreements | STK-1 |
| OBL-OROC.4 | Outsourcing has exit plans | STK-1 |
| OBL-OROC.5 | Material outsourcing is notified to the BMA in advance, as the Code requires (as consulted; confirm final terms) | STK-1 |
| OBL-OROC.6 | Resilience is tested, including recovery | STK-2, STK-4 *new* |

## OBL-POCA · Proceeds of Crime Act 1997

`kind: statute` · `applies: all` · `verification: unverified` · Register #6

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-POCA.1 | Suspicion of money laundering is reported; systems surface suspicion to a person who decides | MOD-6 *new*, UIX-6 |

## OBL-AMLR · Proceeds of Crime (AML/ATF) Regulations 2008, with BMA AML/ATF guidance notes

`kind: regulations` · `applies: regulated` · `verification: unverified` · Register #7 and Layer C

| Req | What it requires (paraphrased; to confirm) | Answered by |
| --- | --- | --- |
| OBL-AMLR.1 | Customer due diligence and ongoing monitoring | MOD-6 *new* |
| OBL-AMLR.2 | Records are kept for the period the Regulations set | DAT-10 *new*, DAT-3 |
| OBL-AMLR.3 | A named MLRO is accountable; AI supports but never replaces that role | UIX-6, MOD-6 *new* |

## OBL-ATFA · Anti-Terrorism (Financial and Other Measures) Act 2004

`kind: statute` · `applies: all` · `verification: unverified` · Layer C

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-ATFA.1 | Terrorist-financing suspicion is reported | MOD-6 *new* |

## OBL-SANC · International Sanctions Act 2003, International Sanctions Regulations 2013, FSIU guidance

`kind: statute and regulations` · `applies: all` · `verification: unverified` · Register #8 and Layer C

| Req | What it requires (paraphrased; to confirm) | Answered by |
| --- | --- | --- |
| OBL-SANC.1 | Screen against the UK Sanctions List and the Bermuda list as they apply in Bermuda | MOD-6 *new* |
| OBL-SANC.2 | Matches are frozen and reported to the Financial Sanctions Implementation Unit | MOD-6 *new*, UIX-6 |

## OBL-PERIM · The regulatory perimeter (licensing statutes)

`kind: statutes` · `applies: perimeter` (and licence conditions for licensees) · `verification: unverified` · Register #13 to #16 and Layer E

Each statute is a licence requirement for a regulated entity and a no-go line for one without that licence. The register's advice: map every agent capability against this list before it ships.

| Req | Statute | Activity that needs a licence (from the source) | Answered by |
| --- | --- | --- | --- |
| OBL-PERIM.1 | Investment Business Act 2003 | Dealing, arranging, managing or advising on investments | AGT-4 *new* |
| OBL-PERIM.2 | Digital Asset Business Act 2018 | Digital asset business in or from Bermuda | AGT-4 *new* |
| OBL-PERIM.3 | Money Service Business Act 2016 | Money transmission, payments, currency exchange | AGT-4 *new* |
| OBL-PERIM.4 | Corporate Service Provider Business Act 2012 | Company formation, registered office, director and secretarial services for others | AGT-4 *new* |
| OBL-PERIM.5 | Banks and Deposit Companies Act 1999 | Taking deposits from the public | AGT-4 *new* |
| OBL-PERIM.6 | Trusts (Regulation of Trust Business) Act 2001 | Acting as a professional trustee | AGT-4 *new* |
| OBL-PERIM.7 | Investment Funds Act 2006 | Operating unauthorised or unregistered funds | AGT-4 *new* |
| OBL-PERIM.8 | Insurance Act 1978 | Insurance and intermediary business | AGT-4 *new* |
| OBL-PERIM.9 | Digital Asset Issuance Act 2020 | Public token offerings | AGT-4 *new* |

## OBL-HRA · Human Rights Act 1981

`kind: statute` · `applies: all` · `verification: unverified` · Layer G

The register notes it applies to AI screening, pricing and decisions, and outranks PIPA. Matching candidates to director roles is one example.

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-HRA.1 | No discrimination in employment or services, including through automated or AI-assisted decisions about people | AGT-7 *new* |

## OBL-ETA · Electronic Transactions Act 1999

`kind: statute` · `applies: all` · `verification: unverified` · Register #10

| Req | What it provides or requires | Answered by |
| --- | --- | --- |
| OBL-ETA.1 | Electronic records, signatures and contracts formed through electronic agent devices have legal effect, so an agent can bind the entity | AGT-9 *new* |
| OBL-ETA.2 | Deeds and wills are excluded | AGT-9 *new* |

## OBL-CMA · Computer Misuse Act 2024

`kind: statute` · `in_force: commencement not confirmed (source)` · `applies: all` · `verification: unverified` · Layer D

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-CMA.1 | No unauthorised access to or interference with computer systems, which covers agents that browse, scrape or act in other systems | INT-4 *new* |

## OBL-CYBA · Cybersecurity Act 2024

`kind: statute` · `in_force: assent 24 Jun 2024; commencement and designations not confirmed (source)` · `applies: all, if designated as critical national information infrastructure` · `verification: unverified` · Layer D

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-CYBA.1 | Designated infrastructure meets the Act's standards. Counsel to confirm whether any entity is or may be designated | (none until designation is known) |

## OBL-CPA · Consumer Protection Act 1999

`kind: statute` · `applies: all` · `verification: unverified` · Layer H

| Req | What it requires | Answered by |
| --- | --- | --- |
| OBL-CPA.1 | No misleading or unfair practices toward consumers, including claims about what an AI product does | AGT-8 *new*, MOD-1 |

## OBL-CDA · Copyright and Designs Act 2004

`kind: statute` · `applies: all` · `verification: unverified` · Layer H

The register notes the Act covers computer-generated works but is untested for generative AI, so ownership of model output should be fixed by contract.

| Req | What it implies for systems | Answered by |
| --- | --- | --- |
| OBL-CDA.1 | Ownership of code, datasets and model output is fixed by contract with each provider | STK-5 *new*, STK-1 |

## OBL-ESA · Economic Substance Act 2018 and Regulations

`kind: statute and regulations` · `in_force: enforced by the CIT Agency since 31 Mar 2026 (source)` · `applies: all, for relevant activities including IP` · `verification: unverified` · Register #5

| Req | What it implies for systems (to confirm) | Answered by |
| --- | --- | --- |
| OBL-ESA.1 | Where an entity holds IP (including its code or models), decisions about it are made and controlled by people in Bermuda | STK-5 *new* |

## OBL-SBOX · General Regulatory Sandbox Guidance Note (2021) and the Innovation Hub

`kind: BMA guidance` · `applies: regulated (optional route)` · `verification: unverified` · Layer F; CP 46

| Req | What it offers | Answered by |
| --- | --- | --- |
| OBL-SBOX.1 | A route to test novel AI use cases under modified requirements; the BMA points novel AI use cases here | LIF-4 (the sandbox stage), AGT-5 *new* |

---

## Watch list

| Date | Item | What the nightly run does |
| --- | --- | --- |
| 30 Oct 2026 | BMA AI consultation closes; final guidance note to follow | From this date, flag monthly that OBL-AIGN needs re-mapping once the final note is out |
| To confirm | Commencement of the Computer Misuse Act 2024 and Cybersecurity Act 2024; CNII designations | Flag OBL-CMA and OBL-CYBA as unverified in every report until counsel confirms |
| To confirm | Whether the Operational Resilience and Outsourcing Code binds a CSP and investment business licensee | Flag OBL-OROC for any corporate service provider or investment business licensee until counsel confirms |
| Each entry | `next_check` date passed | List the entry under "Needs the operator" for the CRCO and counsel |
