# TSUGINO — PROVIDER_FEASIBILITY_AUDIT.md

**Phase:** 0 — Project Bootstrap + Feasibility Baseline
**Status:** Provisional — catalog and license-text verification complete; Toei payload verified from one snapshot (B1/B2, 2026-09-18); repeated sampling and commercial confirmation pending
**Date:** 2026-09-17 (payload evidence added 2026-09-18)
**Baseline:** `main` == `origin/main` == `9867038` (parent `24cd610`), branch `phase/00-bootstrap-feasibility`
**Platform:** iPhone only, iOS 18.0 minimum (DEC-044, DEC-045)

## 1. Purpose

`ROADMAP.md` Phase 0 requires a **provider feasibility audit** and an **initial data-source/license registry** before domain implementation expands. This document is that artifact.

For each external dependency candidate it records:

- what TSUGINO would use it for,
- what has been confirmed and **at which evidence level**,
- what remains pending and which action closes it,
- the commercial-use verdict for TSUGINO,
- the inputs to the Phase 0 Decision Gate.

This is a **Phase 0 working artifact**, subordinate to the eight living documents (`PRODUCT.md`, `FEATURES.md`, `DESIGN.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `ROADMAP.md`, `RULES.md`, `AGENTS.md`). If a finding here changes product truth, the relevant living document is updated and a decision recorded (DEC-035, DEC-036, Rule 43, Rule 44). This file does not override any of them.

### 1.1 What this audit does NOT do

- It does not authorize production use of any dataset by itself (Rule 40, DEC-037); a registry row must reach `production-eligible` first (§9).
- It does not select the production route-search provider — **DEC-004 remains `Provisional`.**
- It does not add any provider integration, SDK, network code, or dependency.
- It does not treat catalog presence, or a permissive license, as proof of payload quality (§2).
- It is not legal advice. Where a clause requires legal judgment (notably §6.4 JR East), it says so.

---

## 2. Evidence Model

Every claim carries exactly one of the following statuses.

| Status | Meaning | Promotes via |
|---|---|---|
| **VERIFIED_CATALOG** | Confirmed on the official ODPT data catalog (`ckan.odpt.org`): the dataset exists, its resources/entity types are listed, and a license label is attached. Says nothing about payload quality. | A3 |
| **VERIFIED_LICENSE_TEXT** | Confirmed in the official license/guideline/rules text itself (sources in §3): commercial use, term, attribution, deletion, or other restrictions. | — (re-check on license change) |
| **PENDING_PAYLOAD_VERIFICATION** | Authenticated real payloads not yet inspected for referential integrity (static ↔ realtime join), freshness cadence, and actual coverage. | A3 |
| **VERIFIED_PAYLOAD** | An authenticated official payload was captured and inspected outside the repository against the canonical schema: structure, identifier uniqueness, and the stated referential joins held for the captured snapshot(s). Always qualified with the number of snapshots. Says nothing about refresh cadence, uptime, SLA, commercial terms, or behaviour under disruption unless those were separately observed. | — (re-verify on feed/schema change; repeated sampling widens the qualifier) |
| **PENDING_COMMERCIAL_CONFIRMATION** | Pricing, SLA, App Store consumer-app use, caching/re-display, contract termination not yet confirmed with a commercial provider. | A2 |
| **UNAVAILABLE_IN_AUDITED_CATALOG** | Capability **not found** in the official catalog as audited on the date above. *Not* a claim that the capability, or a public API, does not exist. | A1 re-check / A6 |

Additional markers where none applies: **UNKNOWN**, **N/A**.

### 2.1 Commercial-use verdict categories

Each operator/dataset row in §7 and §9 receives exactly one verdict:

| Verdict | Meaning |
|---|---|
| **production-license-viable** | A **legal/license** judgment only: the license text (VERIFIED_LICENSE_TEXT) permits use in a distributed, for-profit or non-profit consumer app, subject to the obligations recorded. It says nothing about technical capability or payload quality; the row always adds a capability qualifier — *full realtime*, *alerts only*, *static only*, or *capability-limited* — read from the audited catalog. |
| **Challenge-entry only / production-blocked** | Usable **only** as part of an explicit Challenge entry/submission (S3 Art. 4(1), 4(7)). TSUGINO does not use this data for evaluation, fixture generation, or adapter development unless it explicitly enters the Challenge; if it does, the Challenge conditions, public free-availability condition, 2027-03-12 end date, and deletion obligation apply. It cannot become a production dependency without a separate commercial agreement. This is **not** a general internal-research permission. |
| **pending operator-direct or commercial agreement** | Use requires a contract or operator-direct terms not yet confirmed. |
| **unknown because official terms were not verified** | No official terms were read for this row. |

"A license label is attached" and "TSUGINO may use it in production" are **never** treated as equivalent; the verdict is derived only from license text.

### 2.2 Audit basis (2026-09-17)

- **Catalog:** `https://ckan.odpt.org` dataset pages for every Group A operator (§4.1), read for license label and resource list. No `acl:consumerKey` was used; no `api.odpt.org` / `api-challenge.odpt.org` endpoint was called.
- **License text:** the four official sources named in §3 plus the ODPT Center Use Rules and Developer Guideline, which the `/terms` overview links and which the Basic License incorporates by reference (Art. 1(12), Art. 3(1)).
- **Not performed:** API payload capture, provider commercial contact, legal review.

### 2.3 Payload basis (2026-09-18, Toei only — B1/B2)

- **B1 transport:** the four official Toei resources named in §4.1 row 1 (GTFS Static; GTFS-RT TripUpdate, VehiclePosition, Alert) were acquired once from `api.odpt.org` with the developer token held in the macOS Keychain. GTFS Static was served through a validated HTTPS redirect to ODPT-operated Azure Blob storage; the ODPT credential was not sent to that host. `api-challenge.odpt.org` was not contacted.
- **B2 decode:** the three GTFS-RT payloads were decoded against the canonical `gtfs-realtime.proto` (GTFS-Realtime 2.0) using temporary external research tooling only; nothing entered the repository. Findings are recorded in §6.1, §8.1, §9, §12.
- **Retained:** aggregate counts, hashes, and field-presence facts only. No credential, signed URL, raw record, identifier, coordinate, payload, or scratch path is recorded here.

---

## 3. License Text Verification Record

Statements in this section are **VERIFIED_LICENSE_TEXT**, read directly from the official text on 2026-09-17. Article numbers refer to the English text; both the Basic License (Art. 18(2)) and the Challenge Limited License (Art. 18(2)) state that the **Japanese text governs**, so any legal conclusion must be re-checked against the Japanese.

### 3.1 Sources read

| # | Document | URL | Version / dates on the document |
|---|---|---|---|
| S1 | ODPT terms overview (規約・ガイドライン) | https://developer.odpt.org/terms | current page |
| S2 | Public Transportation Open Data **Basic License** (公共交通オープンデータ基本ライセンス) | https://developer.odpt.org/terms/data_basic_license.html | EN: established 2019-05-31, revised 2019-08-30, 2021-06-01. JP (governing): additionally revised 2022-02-24 |
| S3 | Public Transportation Open Data **Challenge Limited License** (公共交通オープンデータチャレンジ限定ライセンス) + Specific Usage Conditions | https://developer.odpt.org/challenge_license | established 2026-07-01, revised 2026-08-28; JR East Specific Usage Conditions established 2026-08-06 |
| S4 | **CC BY 4.0** legal code | https://creativecommons.org/licenses/by/4.0/legalcode | Version 4.0 |
| S5 | ODPT **Center Use Rules** (公共交通オープンデータセンター利用規約) — linked from S1, incorporated by S2 | https://developer.odpt.org/terms/center_use_rules.html | current page |
| S6 | ODPT **Developer Guideline** (公共交通オープンデータ開発者ガイドライン) — linked from S1, incorporated by S2 Art. 1(12) | https://developer.odpt.org/terms/data_basic_use_guideline.html | current page |

Note on retrieval: `developer.odpt.org` is a client-rendered application; the text was read from the page's delivered content, not from a server-rendered HTML body. Quotations below are from the English text as delivered.

### 3.2 ODPT Basic License (S2) — findings

| Requirement checked | Status | Where | Finding |
|---|---|---|---|
| Developer registration required | VERIFIED_LICENSE_TEXT | S2 Art. 14(1); S1; S5 Art. 3–4 | "Data Users will disclose and register their Account Information to the Center before using the Basic License Data and Others." S1 states Basic-License data requires user registration on the developer site (CC0/CC BY/ODC/ODbL data does not). |
| Commercial and non-commercial use allowed | VERIFIED_LICENSE_TEXT | S2 Art. 4(7) | "Data Users may use these Basic License Data for-profit or nonprofit by following the Basic License and the Guideline." |
| Dataset-specific conditions may override | VERIFIED_LICENSE_TEXT | S2 Art. 5(1) | Specific Terms of Use apply in addition; "if there is any difference between the Specific Terms of Use and this License, the Specific Terms of Use shall prevail." |
| Raw / reconstructable redistribution restricted | VERIFIED_LICENSE_TEXT | S2 Art. 8(4)(1) | Prohibited without prior written approval: to "release, redistribute, publicly transmit, or assign Basic License Data and Others, duplicates of these data, and derivatives of these data (derivative data is created … in a manner so that the whole or most of the original data can be restored) … in a form reusable by a third party." Also Art. 4(2)(3): not display the data "anywhere other than in the Deliverable." |
| Accuracy / availability not guaranteed | VERIFIED_LICENSE_TEXT | S2 Art. 9(2)(1)–(3), 9(5) | Provided "as is"; no liability for damage; no warranty of uninterrupted use, merchantability, fitness; no obligation to provide support or upgrades. Art. 4(5): "The Center may modify the Basic License Data at any time." |
| Terms / provision may change or terminate | VERIFIED_LICENSE_TEXT | S2 Art. 13(2)–(4) | Center "may change, suspend, or discontinue the provision … and terminate the application of this Permission … at any time regardless of the reason"; on termination Data User "shall cease to use … and delete the Basic License Data and Others in their possession"; terms may change without prior consent (material changes after notice and a reasonable period). |
| App operator must provide its own support contact | VERIFIED_LICENSE_TEXT | S2 Art. 10(3); S6 §3.1(3) | Data Users "shall state … their contact information to be used in inquiries regarding the content or operation of such Deliverables" and make efforts so inquiries "will not be sent directly to the Public Transportation Data Provider." Guideline requires the developer's e-mail address and a notice that accuracy/integrity are not guaranteed. |
| Access token must not be embedded in a distributable client | **Not stated in this form.** | S5 Art. 5(1)(5) | The Center Use Rules require Data Users "to manage the access token … with due care so that it may not be disclosed to a third party." An explicit prohibition on embedding the token in a distributed client is **not present** in S1–S6. **Classification: security architecture requirement** derived from S5 Art. 5(1)(5) (ARCH §43, Rule 42) — not a license claim. |
| Freshness / caching obligations (Guideline) | VERIFIED_LICENSE_TEXT | S6 §2.1–§2.2 | Dynamic data: display `dc:date`, refresh at `odpt:frequency`, do not use data outside `dct:valid`, do not display out-of-date dynamic data. Static data: display obtained date/time; update within one week after the Center notifies a data update unless specific terms say otherwise. Art. 4(2)(4): update Deliverables "immediately" when data is updated. |
| Source notice | VERIFIED_LICENSE_TEXT | S6 §3.1 | App must notify users that the data source is the Public Transportation Open Data Center, based on operator data, accuracy not guaranteed, and give the developer contact. |
| Access frequency | VERIFIED_LICENSE_TEXT | S5 Art. 4(4) | "The Center may decide at its own discretion the restrictions on the numbers of Data Users' access frequency." Numeric limits are **not** in the text → PENDING_PAYLOAD_VERIFICATION. |

### 3.3 Challenge Limited License (S3) — findings

| Requirement checked | Status | Where | Finding |
|---|---|---|---|
| Challenge entry / submission requirement | VERIFIED_LICENSE_TEXT | S3 Art. 4(1), 4(7); S1 | Use is for creating Derived Works and "submit entries to the organizers of the Challenge". "If the organizers … determine that a Data User's purpose for using Limited License Data is for purposes other than submitting an entry to the Challenge, then the Center may terminate that Data User's use … and take legal action." Art. 4(7): corporate services may use the data, "However, it is mandatory to submit an entry to the Challenge". S1: usable "on the premise of submitting a work to the Challenge". |
| Free public availability during the Challenge | VERIFIED_LICENSE_TEXT | S3 Art. 4(7); Entry Rules | "…make available functions that anyone can use free of charge during the Challenge period." Entry Rules: an application/web service "shall be made available for anyone to use free of charge during the Challenge contest period." |
| Current permission end date | VERIFIED_LICENSE_TEXT | S3 Art. 13(2) | "The Authorization shall terminate on March 12, 2027." (JP: 本許諾は、2027年3月12日に終了いたします。) The Center may also change, suspend, or discontinue at any time. |
| Cease use and delete after termination | VERIFIED_LICENSE_TEXT | S3 Art. 13(3) | "Upon termination of the Authorization, Data Users shall immediately cease use of the Limited License Data, Etc. and shall delete the Limited License Data, Etc." The text contains **no exception** to this clause; any continuation would require an agreement outside this license, which the license itself does not provide for. |
| Redistribution restriction | VERIFIED_LICENSE_TEXT | S3 Art. 8(4) | Same reconstructable-data redistribution prohibition as Basic License, except with prior written consent of the Center or as the Specific Usage Conditions state. |
| Unsuitable as a durable production dependency | Conclusion from the above | S3 Art. 4(1), 4(7), 13(2)–(3) | Fixed end date, mandatory Challenge entry, mandatory free functions, deletion on termination. **Verdict: Challenge-entry only / production-blocked.** Art. 4(1) does not permit use for internal evaluation, fixtures, or adapter work without a Challenge entry. |
| Fixture retention | VERIFIED_LICENSE_TEXT | S3 Art. 13(3) | Captured payloads are copies of Limited License Data and fall under the deletion obligation. **Challenge-licensed operators cannot be durable fixture sources** (DEC-032). |

### 3.4 JR East Specific Usage Conditions (S3, appended) — findings

Recorded in the scope of the official text only; no interpretation is added.

| Clause (established 2026-08-06) | Finding (EN text as delivered) |
|---|---|
| Art. 1(1) | "Data users shall not use Derived Works generated based on the data provided by East Japan Railway Company for the development or improvement of services that compete with the services offered by East Japan Railway Company." |
| Art. 1(2) | Patent/design applications based on JR East data must be notified to the Council (subject and application number). |
| Art. 1(3) | Data users shall not exercise IP rights on inventions generated from JR East data against East Japan Railway Company. |
| Art. 1(4) | Clauses (1)–(3) "shall remain in effect even after the contest has ended." |

**Open question requiring human/legal judgment (not resolved here):** whether a journey-companion app falls within "services that compete with the services offered by East Japan Railway Company." This audit records the clause; it does not decide it. Until decided, JR East data is treated as **unusable for TSUGINO** beyond the Challenge verdict above.

### 3.5 CC BY 4.0 (S4) — findings

| Requirement checked | Status | Where | Finding |
|---|---|---|---|
| Commercial reuse allowed | VERIFIED_LICENSE_TEXT | S4 §2(a)(1) | Grant is "a worldwide, royalty-free, non-sublicensable, non-exclusive, irrevocable license" to "reproduce and Share the Licensed Material, in whole or in part; and produce, reproduce, and Share Adapted Material." The legal code contains **no NonCommercial limitation** (the term does not appear); commercial reuse is therefore permitted by the unrestricted grant. |
| Attribution required | VERIFIED_LICENSE_TEXT | S4 §3(a)(1) | If Shared, must retain creator identification, copyright notice, license notice, warranty-disclaimer notice, URI/hyperlink to the material where practicable; indicate modifications; indicate CC BY 4.0 with text or link. §3(a)(2): may be satisfied "in any reasonable manner based on the medium, means, and context". ODPT's FAQ (S1 site) gives a credit format: "[Provider name], [Content name], Creative Commons License Attribution 4.0 International (https://creativecommons.org/licenses/by/4.0/deed.en)". |
| Modification / adaptation allowed | VERIFIED_LICENSE_TEXT | S4 §2(a)(1)(B), §3(a)(1)(B), §3(b) | "produce, reproduce, and Share Adapted Material"; must indicate modification; Adapter's License must not prevent recipients from complying with CC BY 4.0. |
| No additional restrictions | VERIFIED_LICENSE_TEXT | S4 §2(a)(5)(C) | "You may not offer or impose any additional or different terms or conditions on, or apply any Effective Technological Measures to, the Licensed Material if doing so restricts exercise of the Licensed Rights by any recipient." |

**Practical consequence:** CC BY 4.0 data (Toei) does **not** require ODPT registration for the license itself (S1), but the ODPT API still requires an access token (S5) — the API access rules and the data license are separate layers.

---

## 4. Tokyo Metropolitan Operator Set — Coverage Boundary

"Tokyo metropolitan operator set" in this audit means exactly Groups A and B below. Statements about "Tokyo coverage" refer to Group A unless stated otherwise.

### 4.1 Group A — present in the audited ODPT rail catalog

Catalog-level capability and license label per operator. **Presence, resources, and label: VERIFIED_CATALOG. Payload: PENDING_PAYLOAD_VERIFICATION for every row except Toei, whose static and GTFS-RT payloads are VERIFIED_PAYLOAD (one snapshot, §2.3, §6.1).** Verdict per §2.1.

| # | Operator | Static (catalog resources) | Realtime (catalog resources) | License label (catalog) | Commercial-use verdict |
|---|---|---|---|---|---|
| 1 | **Toei** (東京都交通局) | GTFS/GTFS-JP, GTFS-Pathways, Train timetable (JSON), fare — GTFS Static **VERIFIED_PAYLOAD (1 snapshot)** | GTFS-RT **VehiclePosition, TripUpdate, Alert** — TripUpdate/VehiclePosition **VERIFIED_PAYLOAD (1 snapshot)**; Alert header-only in that snapshot | **CC BY 4.0** | **production-license-viable, full realtime** (attribution, §3.5) — a legal/capability classification, not a provider selection |
| 2 | **Tokyo Metro** | GTFS/GTFS-JP, station, route, station timetable, train timetable, fare (JSON) | GTFS-RT **Alert**; Train status (JSON). TripUpdate / VehiclePosition: **UNAVAILABLE_IN_AUDITED_CATALOG** | **Basic License** | **production-license-viable, alerts only** (Basic License obligations, §3.2) |
| 3 | JR East (Tokyo area) | GTFS/GTFS-JP | GTFS-RT vehicle, trip_update ("some lines"; served from `api-challenge.odpt.org`) | **Challenge Limited** + JR East Specific Usage Conditions | **Challenge-entry only / production-blocked** (+ §3.4 open question) |
| 4 | Keio | GTFS/GTFS-JP | GTFS-RT Alert, VehiclePosition, TripUpdate | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 5 | Odakyu | station, route, station timetable, passenger survey (JSON) | none found — UNAVAILABLE_IN_AUDITED_CATALOG | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 6 | Seibu | station, route, fare, station timetable, passenger survey (JSON) | Train status (JSON) only | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 7 | Tobu | GTFS/GTFS-JP | GTFS-RT Alert, VehiclePosition, TripUpdate | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 8 | Tokyu | station, route, station timetable, fare, passenger survey (JSON) | Train status (JSON) only | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 9 | Keikyu | station, route, station timetable, fare, passenger survey (JSON) | Train location (JSON), Train status (JSON) | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 10 | Sotetsu | GTFS/GTFS-JP | none found — UNAVAILABLE_IN_AUDITED_CATALOG | **Challenge Limited** | **Challenge-entry only / production-blocked** |
| 11 | TWR — Rinkai Line | GTFS/GTFS-JP | GTFS-RT **Alert** only | **Basic License** | **production-license-viable, alerts only** |
| 12 | Tsukuba Express / MIR | GTFS/GTFS-JP | GTFS-RT **Alert** only | **Basic License** | **production-license-viable, alerts only** |
| 13 | Tama Monorail | GTFS/GTFS-JP | GTFS-RT **Alert** only | **Basic License** | **production-license-viable, alerts only** |
| 14 | Yurikamome | station, route, station timetable, fare (JSON); images | none found — UNAVAILABLE_IN_AUDITED_CATALOG | **Basic License** | **production-license-viable, static only** |
| 15 | Yokohama Municipal Subway | GTFS/GTFS-JP (multiple dated versions) | GTFS-RT **vehicle, trip_update, alert** | **Basic License** | **production-license-viable, full realtime** — but **fixture-only scope** (§6.3), outside Tokyo core |

Reading of the table for TSUGINO's Tokyo-core goal:

- **Trip-level realtime under a production-license-viable label** exists in the catalog for **Toei only** (Tokyo core) and **Yokohama Municipal Subway** (outside core). Toei is therefore the sole Tokyo-core full-realtime proof candidate; no other operator is read as full realtime.
- **Basic-License operators** other than Toei/Yokohama offer **Alerts and/or schedule only** → degraded mode (FEATURES §10.3, DEC-024).
- The private-railway group (Keio, Odakyu, Seibu, Tobu, Tokyu, Keikyu, Sotetsu) and JR East are **Challenge-entry only / production-blocked** → not available to TSUGINO for production, evaluation, fixtures, or adapter development unless TSUGINO explicitly enters the Challenge (§3.3, §7).

### 4.2 Group B — Tokyo-area operators **not present in the audited ODPT catalog**

Status for every row: **UNAVAILABLE_IN_AUDITED_CATALOG**; verdict: **pending operator-direct or commercial agreement**. This does **not** assert that these operators lack a public API or open data; each needs operator-direct investigation (A6).

| Operator | Relevance |
|---|---|
| Keisei Electric Railway | Narita Airport access; NE corridor |
| Hokuso Railway | Narita corridor (with Keisei) |
| Tokyo Monorail | Haneda Airport access |
| Saitama Rapid Railway | through-service partner of Tokyo Metro Namboku Line |
| Toyo Rapid Railway | through-service partner of Tokyo Metro Tozai Line |
| Yokohama Minatomirai Railway | through-service partner of Tokyu Toyoko Line |
| Yokohama Seaside Line | Yokohama AGT |
| Chiba Urban Monorail | Chiba |
| Shonan Monorail | Kanagawa |
| Enoshima Electric Railway | Kanagawa |
| JR Central (Tokaido Shinkansen, Tokyo–Shin-Yokohama) | inter-city; likely out of v1 scope |

Through-service partners matter for DEC-009 (continuity across operator boundaries); a partner segment without data degrades a through-running journey at the boundary. Design input for Phase 4/5, not a Phase 0 blocker.

---

## 5. What TSUGINO Needs From Providers

Derived from `PRODUCT.md` §9–§12, `FEATURES.md` §2–§5, §10, `ARCHITECTURE.md` §8–§14, §51.

| Need | Why | Owner in architecture |
|---|---|---|
| **N1. Route search** | DEC-003/DEC-004 | `RouteSearching` → `Data/RouteProviders/<SelectedProvider>` |
| **N2. Static railway topology** | DEC-029 | `RailwayDataRepository`, `Data/GTFS/Static`, `Data/ODPT` |
| **N3. Realtime trip state** (delay, progression, cancellation, alerts) | DEC-005 | `RealtimeTripProviding` → `Data/ODPT`, `Data/GTFS/Realtime` |
| **N4. Trip identity** joining selected train ↔ realtime trip | DEC-007/DEC-008 | `TrainCandidateResolver`, mapping tables |
| **N5. Localized names** JP / EN / KO | DEC-041/DEC-042, Rule 26 | `LocalizedRailName` |
| **N6. Transfer / boarding guidance** (conditional) | DEC-019 | `TransferGuidanceProviding` |
| **N7. License clarity** | DEC-037, Rule 40 | registry §9 |

**N4 remains the highest-risk need.** Catalog presence of a TripUpdate feed (Toei) and a permissive license do not prove that GTFS `trip_id` in the static feed joins deterministically to `trip_id` in TripUpdate, nor that the join survives through-service and timetable revisions. **Status after B2 (2026-09-18):** the Toei static ↔ TripUpdate ↔ VehiclePosition `trip_id` join is VERIFIED_PAYLOAD for **one snapshot** (§6.1). Every other N4 claim — repeated observations, route-provider ↔ GTFS identity (§10), through-service, timetable revisions, other operators — remains PENDING_PAYLOAD_VERIFICATION.

---

## 6. Proof Candidates Designated for Phase 0 Verification

Verification targets, not production scope decisions. DEC-001 and DEC-004 unchanged.

### 6.1 Toei — full-realtime feasibility proof candidate

| Item | Status |
|---|---|
| Static GTFS + GTFS-Pathways + train timetable | VERIFIED_CATALOG |
| GTFS-RT TripUpdate + VehiclePosition + Alert | VERIFIED_CATALOG |
| License: CC BY 4.0 — commercial use, attribution, adaptation, no downstream restrictions | VERIFIED_LICENSE_TEXT (§3.5) |
| API access token + due-care obligation (Center Use Rules) | VERIFIED_LICENSE_TEXT (§3.2) |
| Static ↔ realtime `trip_id` integrity, join key | **VERIFIED_PAYLOAD (1 snapshot, 2026-09-18)** — see B1/B2 record below |
| Freshness cadence, uptime, coverage over time | PENDING_PAYLOAD_VERIFICATION (single-snapshot freshness observed only) |
| Rate limits (numeric) | PENDING_PAYLOAD_VERIFICATION |
| **Verdict** | **production-license-viable, full realtime**; the Phase 0 candidate for proving the full-realtime path (static → trip identity → TripUpdate → optional VehiclePosition → Alert → `RealtimeSnapshot`). **B2 outcome: PASS WITH LIMITATIONS.** This is not a provider selection; DEC-004 remains Provisional. |

#### 6.1.1 B1/B2 payload record (one snapshot, 2026-09-18)

Transport and static GTFS (B1):

| Item | Observation |
|---|---|
| Resources acquired | GTFS Static; GTFS-RT TripUpdate, VehiclePosition, Alert — all from the official `api.odpt.org` resources listed on `ckan.odpt.org` (§2.3) |
| Static delivery | HTTPS redirect from `api.odpt.org` to ODPT-operated Azure Blob storage, validated before following; ODPT credential not sent to Azure |
| Static ZIP | 779,674 bytes; SHA-256 `f10d03cd951565379e5c397cf9043d0db58b5030b670c29f7c56ac43fe3efbe2`; valid ZIP, all CRCs pass; 11 UTF-8 text files |
| Row counts | routes 6 · trips 5,600 · stops 149 · stop_times 122,798 · calendar 4 · calendar_dates 39 · translations 404 · fare_attributes 11 · fare_rules 11,271 (+ agency 1, feed_info 1) |
| Internal integrity | route, trip, and stop IDs unique; every trip's `route_id` resolves; every stop_times `trip_id` and `stop_id` resolves; `stop_sequence` contiguous from 1 for all 5,600 trips |

GTFS-RT semantics (B2, canonical GTFS-Realtime 2.0 schema):

| Item | TripUpdate | VehiclePosition | Alert |
|---|---|---|---|
| Header | 2.0, FULL_DATASET, timestamp present | 2.0, FULL_DATASET, timestamp present | 2.0, FULL_DATASET, timestamp present |
| Entities | 116 | 116 | 0 (valid header-only feed) |
| Duplicate / deleted / mixed-type / unknown-field entities | 0 / 0 / 0 / 0 | 0 / 0 / 0 / 0 | 0 |
| `trip_id` present, unique, matched to static `trips.txt` | 116/116 (100%) | 116/116 (100%) | — |
| `route_id`, `direction_id` in the trip descriptor | absent; recoverable from static for 116/116 | absent; recoverable from static for 116/116 | — |
| Stop context | 3,200 stop-time updates; `stop_id` absent from all; `stop_sequence` present and resolvable via static `stop_times.txt` for 3,200/3,200 | `stop_id` absent; `current_stop_sequence` present and resolvable for 116/116 | — |
| Other fields | explicit `delay` absent (arrival/departure carried as absolute times); 13 stop-time updates SKIPPED | vehicle descriptor ID present and unique 116/116; timestamp 116/116; lat/lon present, bearing absent; all `current_status` = `STOPPED_AT` | — |
| Routes represented | 5 of 6 static routes; **route 5 absent** | same 5; route 5 absent | — |
| Service | all 116 trips on the active service for the snapshot date | same | — |

Cross-feed join (TripUpdate ↔ VehiclePosition): exact `trip_id` join **116/116, one-to-one, zero collisions**. In this snapshot the entity ID and the vehicle descriptor ID happened to equal `trip_id`; **entity ID must not be treated as a designed cross-feed join key**, and no independent fallback join key was demonstrated for the case where `trip_id` is missing.

Freshness (single-snapshot observation only — not cadence, uptime, or SLA evidence): feed header age at retrieval 29 s (TripUpdate, VehiclePosition) and 24 s (Alert); VehiclePosition entity timestamp age min 34 s / median 37 s / max 46 s; no future timestamps; none older than 60 s.

Alert: the zero-entity payload was structurally valid. "No active alerts at that instant" is a plausible interpretation only; incident content shape and multilingual coverage were not observed.

Limitations (all preserved as open): one snapshot only; route 5 absent although static scheduled trips exist for it; no repeated cadence, uptime, or availability study; no independent fallback key if `trip_id` is absent; all VehiclePositions `STOPPED_AT` is unexplained; actual Alert incident content unobserved; through-service continuity not assessed; Tokyo Metro alerts-only degraded path not tested; JP/EN/KO name coverage not analyzed (A4); commercial and operational terms pending; no production decoder dependency selected (RK-11).

### 6.2 Tokyo Metro — partial / degraded-mode proof candidate

| Item | Status |
|---|---|
| Static GTFS + station/route/timetables/fare JSON | VERIFIED_CATALOG |
| GTFS-RT Alert + Train status JSON | VERIFIED_CATALOG |
| GTFS-RT TripUpdate / VehiclePosition | UNAVAILABLE_IN_AUDITED_CATALOG |
| License: Basic License — registration, for-profit OK, specific terms prevail, no redistribution, as-is, may terminate, own contact, guideline freshness rules | VERIFIED_LICENSE_TEXT (§3.2) |
| Payload integrity / coverage | PENDING_PAYLOAD_VERIFICATION |
| **Verdict** | **production-license-viable, alerts only**; the Phase 0 candidate for proving the **schedule-fallback / alerts-only degraded mode** (FEATURES §10.3, DEC-024, DEC-038, Rule 11). If TripUpdate/VehiclePosition appear later, status is upgraded — the current status is not a claim of non-existence. |

### 6.3 Yokohama Municipal Subway — secondary full-realtime **fixture** candidate

| Item | Status |
|---|---|
| Static GTFS (multiple dated versions) | VERIFIED_CATALOG |
| GTFS-RT vehicle + trip_update + alert | VERIFIED_CATALOG |
| License: Basic License | VERIFIED_LICENSE_TEXT (§3.2) — note Art. 8(4) redistribution ban and Art. 13(3) deletion-on-termination apply to retained fixtures; fixtures must stay internal and be deletable |
| Payload | PENDING_PAYLOAD_VERIFICATION |
| **Scope** | Fixture source only (DEC-032, Rule 31). **Does not replace or extend the Tokyo-core production scope**; inclusion in any release requires a separate roadmap/decision change. |

### 6.4 Not designated

Challenge-entry only / production-blocked operators (JR East, Keio, Tobu, Sotetsu, Odakyu, Seibu, Tokyu, Keikyu) are **not** Phase 0 proof or fixture candidates: Art. 4(1) requires Challenge entry, Art. 13(3) requires deletion, and for JR East §3.4 adds an unresolved competition clause.

---

## 7. Challenge-Only and Time-Limited Data — Rule

- Challenge Limited License data **must not** be a Release or production dependency (DEC-037, Rule 40; S3 Art. 4(1), 4(7), 13(2)–(3)).
- Under the license text, use for any purpose other than a Challenge entry is not permitted (S3 Art. 4(1)). Therefore **TSUGINO does not use Challenge-entry-only data for evaluation, fixture generation, or adapter development unless the project explicitly decides to enter the Challenge**; any such decision is recorded in `DECISIONS.md` together with the Challenge conditions, the public free-availability condition, the end date 2027-03-12, and the deletion obligation. Even with an entry, the data cannot become a production dependency without a separate commercial agreement.
- Captured Challenge payloads cannot be retained as fixtures past termination (S3 Art. 13(3)).
- Production configuration (`AppConfiguration`, ARCH §43) may reference only registry rows whose status is `production-eligible` (§9.1).
- Access tokens for any tier are handled per the security architecture requirement in §3.2 (not embedded in a distributable client; secure configuration, Rule 42).

---

## 8. Realtime and Static Data Candidates — Format Notes

### 8.1 ODPT as the platform

| Item | Status |
|---|---|
| Rail datasets for Group A exist with license labels | VERIFIED_CATALOG (§4.1) |
| Realtime rail data on ODPT is distributed as **GTFS-RT protobuf** (TripUpdate / VehiclePosition / Alert) for GTFS-based operators, plus operator JSON (train status, train location) for some Challenge operators | VERIFIED_CATALOG |
| Realtime position model is trip-progress / stop-sequence based (GTFS-RT TripUpdate) — GPS-free journey tracking possible (DEC-006) | VERIFIED_PAYLOAD (Toei, 1 snapshot): TripUpdate stop-time updates and VehiclePosition `current_stop_sequence` populated and resolvable to static stops (§6.1.1); field population under disruption PENDING_PAYLOAD_VERIFICATION |
| Station titles JP/EN (GTFS `stops.txt` translations, or ODPT JSON `odpt:stationTitle`); KO coverage | PENDING_PAYLOAD_VERIFICATION (A4) |
| Access token required for API (all tiers) | VERIFIED_LICENSE_TEXT (S1, S5) |

### 8.2 GTFS / GTFS-RT as the first adapter format

Given §4.1, the only production-license-viable trip-level realtime in Tokyo core (Toei) is **GTFS-RT**, not ODPT-native JSON. This **changes the leaning recorded in the previous revision**: the first realtime adapter should target **GTFS static + GTFS-RT**, with ODPT JSON (train status, station titles) as a secondary adapter. `RealtimeSnapshot` (ARCH §8.2) already isolates this. Consequence for Phase 4: a protobuf decoder is needed **without third-party dependency** in Phase 0 (dependency-free baseline) — Phase 4 may revisit under Rule 34 / AGENTS §31 with justification. B2 demonstrated that the Toei feeds decode cleanly against the canonical schema with temporary external research tooling (RK-11); the production decoder design and any dependency decision remain open.

### 8.3 Operator-direct open data

| Item | Status |
|---|---|
| Station facility / layout data (GTFS-Pathways for Toei; images/station maps for Yurikamome, TWR) | VERIFIED_CATALOG (presence) |
| Recommended-car / door-position data from any operator | UNAVAILABLE_IN_AUDITED_CATALOG |

---

## 9. Initial Data-Source / License Registry

Required by `ROADMAP.md` Phase 0, DEC-037, Rule 40. Fields follow `FEATURES.md` §14.

| ID | Provider / Dataset | Use | Catalog | License label | License terms | Payload | Commercial (pricing/SLA/caching/App Store contract) | Term / expiration | Verdict (§2.1) | Registry status | Evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|
| DS-01 | ODPT — Toei rail static (GTFS, GTFS-Pathways, train timetable) | N2, N5 | VERIFIED_CATALOG | CC BY 4.0 | VERIFIED_LICENSE_TEXT (§3.5) | **VERIFIED_PAYLOAD (GTFS Static structure, 1 snapshot 2026-09-18, §6.1.1)**; GTFS-Pathways and train timetable JSON still PENDING_PAYLOAD_VERIFICATION | N/A (open data); API token due-care | none in license (irrevocable); ODPT provision may change (S5) | production-license-viable, static only (Toei static datasets) | Not yet production-eligible (repeated sampling, attribution/notice implementation pending) | ckan.odpt.org `train-toei`, `r_train_timetable-toei`; S4; 2026-09-17; B1 2026-09-18 |
| DS-02 | ODPT — Toei GTFS-RT TripUpdate + VehiclePosition + Alert | N3, N4 | VERIFIED_CATALOG | CC BY 4.0 | VERIFIED_LICENSE_TEXT (§3.5) | **VERIFIED_PAYLOAD (TripUpdate/VehiclePosition `trip_id` integrity and cross-feed join, 1 snapshot 2026-09-18, §6.1.1)**; Alert content, cadence, coverage over time PENDING_PAYLOAD_VERIFICATION | N/A | as DS-01 | production-license-viable, full realtime | Not yet production-eligible (repeated sampling, route-5 coverage, Alert observation pending) | `r_train_gtfs_rt-odpt_train-toei`; 2026-09-17; B2 2026-09-18 |
| DS-03 | ODPT — Tokyo Metro rail static (GTFS, station, route, timetables, fare) | N2, N5 | VERIFIED_CATALOG | Basic License | VERIFIED_LICENSE_TEXT (§3.2) | PENDING_PAYLOAD_VERIFICATION | N/A; registration; guideline freshness | may be terminated at any time (Art. 13(2)); delete on termination | production-license-viable, static only | Not yet production-eligible | `train-tokyometro`, `r_station-tokyometro`; 2026-09-17 |
| DS-04 | ODPT — Tokyo Metro GTFS-RT Alert + Train status JSON | N3 (alerts) | VERIFIED_CATALOG | Basic License | VERIFIED_LICENSE_TEXT | PENDING_PAYLOAD_VERIFICATION | N/A | as DS-03 | production-license-viable, alerts only | Not yet production-eligible | `r_train_gtfs_rt-odpt_train-tokyometro`, `r_train_status-tokyometro` |
| DS-05 | ODPT — Tokyo Metro TripUpdate / VehiclePosition | N3, N4 | UNAVAILABLE_IN_AUDITED_CATALOG | — | — | — | — | — | — | Not found; re-check A1 | 2026-09-17 |
| DS-06 | ODPT — JR East GTFS + GTFS-RT (vehicle, trip_update) | N2, N3 | VERIFIED_CATALOG | Challenge Limited + JR East Specific Usage Conditions | VERIFIED_LICENSE_TEXT (§3.3, §3.4) | not applicable (not to be fetched, §7) | N/A | **ends 2027-03-12**; delete | Challenge-entry only / production-blocked | **Excluded** from production, evaluation, fixtures, adapter work; §3.4 open question | `jreast_tokyo_area`, `odpt_jreast_tokyo_area`; S3 |
| DS-07 | ODPT — Keio, Tobu (GTFS + GTFS-RT Alert/VP/TU); Sotetsu (GTFS); Odakyu, Seibu, Tokyu, Keikyu (JSON static / status / location) | N2, N3 | VERIFIED_CATALOG | Challenge Limited | VERIFIED_LICENSE_TEXT (§3.3) | not applicable (§7) | N/A | ends 2027-03-12; delete | Challenge-entry only / production-blocked | **Excluded** from production, evaluation, fixtures, adapter work | per-operator dataset pages; S3 |
| DS-08 | ODPT — TWR, MIR, Tama Monorail (GTFS + GTFS-RT Alert); Yurikamome (JSON static) | N2, N3 (alerts) | VERIFIED_CATALOG | Basic License | VERIFIED_LICENSE_TEXT (§3.2) | PENDING_PAYLOAD_VERIFICATION | N/A | may be terminated; delete | production-license-viable, alerts only (TWR, MIR, Tama Monorail) / static only (Yurikamome) | Not yet production-eligible | per-operator dataset pages |
| DS-09 | ODPT — Yokohama Municipal Subway GTFS + GTFS-RT vehicle/trip_update/alert | fixture (§6.3) | VERIFIED_CATALOG | Basic License | VERIFIED_LICENSE_TEXT (§3.2) | PENDING_PAYLOAD_VERIFICATION | N/A | may be terminated; delete (fixtures included) | production-license-viable, full realtime | Fixture-only candidate; not production scope | `yokohama_municipal_train`, `r_train_gtfs_rt-yokohamamunicipal` |
| DS-10 | Group B operators (§4.2) | N2, N3 possible | UNAVAILABLE_IN_AUDITED_CATALOG | — | not verified | — | — | — | pending operator-direct or commercial agreement | Operator-direct investigation (A6) | — |
| DS-11 | Ekispert Web Service | N1 | N/A (commercial) | contract | PENDING_COMMERCIAL_CONFIRMATION | PENDING_PAYLOAD_VERIFICATION | PENDING_COMMERCIAL_CONFIRMATION | contract | pending operator-direct or commercial agreement | Candidate only (DEC-004) | — |
| DS-12 | NAVITIME API | N1 (maybe N6) | N/A (commercial) | contract | PENDING_COMMERCIAL_CONFIRMATION | PENDING_PAYLOAD_VERIFICATION | PENDING_COMMERCIAL_CONFIRMATION | contract | pending operator-direct or commercial agreement | Candidate only (DEC-004) | — |
| DS-13 | Jorudan route-search API | N1 | N/A (commercial) | contract | PENDING_COMMERCIAL_CONFIRMATION | PENDING_PAYLOAD_VERIFICATION | PENDING_COMMERCIAL_CONFIRMATION | contract | pending operator-direct or commercial agreement | Candidate only (DEC-004) | — |
| DS-14 | Official railway line colors / line symbols | DesignSystem tokens (DEC-018) | ODPT image datasets exist (Basic License) for some operators; brand rules per operator | Basic License / operator-specific image conditions (e.g. Tokyo Metro image data conditions referenced in S2 Specific Terms) | partially — image-use conditions not read | N/A | N/A | — | unknown because official terms were not verified (image conditions) | Research (A7) | S2 Specific Terms list |
| DS-15 | TSUGINO canonical localized names (JP/EN/KO) | N5 | N/A | TSUGINO-owned | must not reproduce reconstructable licensed data (S2 Art. 8(4)) | N/A | N/A | N/A | N/A | Internal | — |
| DS-16 | TSUGINO curated transfer guidance | N6 | N/A | TSUGINO-owned | provenance + confidence per entry (ARCH §14) | N/A | N/A | N/A | N/A | Internal | — |

### 9.1 Registry rules

- A row becomes **`production-eligible`** only when: verdict is *production-license-viable* (any capability qualifier), payload is VERIFIED_PAYLOAD across repeated snapshots (A3; a single snapshot is not sufficient), attribution/notice/contact obligations are implemented, and — for commercial providers — commercial terms are confirmed. Each step carries a dated evidence entry.
- Adding a provider under `Data/` requires a row here first (AGENTS §32).
- Challenge-entry only / production-blocked rows are never production-eligible under the current license.
- When the registry becomes production-relevant (Phase 3/4) it is promoted to a maintained location decided then and reflected in `ARCHITECTURE.md`.

---

## 10. Route-Search Provider Candidates (N1)

DEC-004 names Jorudan, NAVITIME, Ekispert. **None is selected; DEC-004 stays Provisional.** All are commercial; production use requires a contract. **Every cell stays PENDING** — pricing, SLA, App Store consumer-app use, caching, re-display, and termination conditions are PENDING_COMMERCIAL_CONFIRMATION as instructed.

| Criterion | Ekispert Web Service | NAVITIME API | Jorudan |
|---|---|---|---|
| Route search with legs, transfers, times | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION |
| Train identity joinable to GTFS `trip_id` / ODPT realtime (N4) | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION |
| Through-service continuity (DEC-009) | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION |
| EN / KO names | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION |
| Own station ID scheme → mapping (DEC-021) | assumed yes | assumed yes | assumed yes |
| Evaluation / trial access | PENDING_COMMERCIAL_CONFIRMATION | PENDING_COMMERCIAL_CONFIRMATION | PENDING_COMMERCIAL_CONFIRMATION |
| Pricing, SLA, App Store use, caching, re-display, termination | PENDING_COMMERCIAL_CONFIRMATION | PENDING_COMMERCIAL_CONFIRMATION | PENDING_COMMERCIAL_CONFIRMATION |
| Transfer / boarding-car guidance content (N6) | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION | PENDING_PAYLOAD_VERIFICATION |

Evaluation criteria (ranked): N4 join quality against Toei GTFS-RT; through-service representation; station-ID mapping stability; license/commercial terms; cost; EN/KO coverage; evaluation access. In-house routing remains out of MVP scope (PRODUCT §9, DEC-004).

---

## 11. Transfer / Boarding Guidance Data (N6)

| Source | Status |
|---|---|
| Open recommended-car / door dataset | UNAVAILABLE_IN_AUDITED_CATALOG |
| GTFS-Pathways (Toei) / station maps (Yurikamome, TWR images) — usable to *derive* facility guidance | VERIFIED_CATALOG (presence); PENDING_PAYLOAD_VERIFICATION |
| Commercial route-provider guidance content | PENDING_PAYLOAD_VERIFICATION / PENDING_COMMERCIAL_CONFIRMATION |
| TSUGINO-curated dataset (DS-16) | product decision (PRODUCT §12) |

Consistent with DEC-019 / FEATURES §17. No change to current documents.

---

## 12. Risk Summary

| ID | Risk | Impact | Evidence status | Mitigation in docs | Closes via |
|---|---|---|---|---|---|
| RK-1 | Route provider and Toei GTFS-RT share no deterministic join key (N4) | Core promise weakened | **Partially reduced:** Toei static ↔ TripUpdate ↔ VehiclePosition `trip_id` join VERIFIED_PAYLOAD (1 snapshot, §6.1.1). **Still open:** route-provider ↔ GTFS `trip_id` identity (§10), repeated observations, uncovered route 5, missing-`trip_id` fallback, other providers, degraded/fallback behaviour — PENDING_PAYLOAD_VERIFICATION | selected trip stored separately (ARCH §11); recovery (DEC-031) | A2, A3 (repeated sampling) |
| RK-2 | **Private railways + JR East are Challenge-entry only / production-blocked** → unavailable for production; Tokyo-core trip-level realtime = Toei only | Launch coverage materially narrower than "Tokyo" implies | VERIFIED_CATALOG + VERIFIED_LICENSE_TEXT | DEC-001 "as many as reliably supported"; capability model (DEC-022); degraded modes | Product decision at Decision Gate; A6 for operator-direct |
| RK-3 | Tokyo Metro has no trip-level realtime in the audited catalog | Largest subway operator in degraded mode | UNAVAILABLE_IN_AUDITED_CATALOG | FEATURES §10.3, DEC-024 | A1 re-check; §6.2 proof |
| RK-4 | Challenge data leaks into production/fixtures; or evaluation use without Challenge entry | License breach (S3 Art. 4(1), 13(3)) | VERIFIED_LICENSE_TEXT | §7 rule; DEC-037; Rule 40 | registry discipline |
| RK-5 | Basic License termination at any time (Art. 13(2)) / data change (Art. 4(5)) | Degradation without notice | VERIFIED_LICENSE_TEXT | graceful degradation (ARCH §52); versioned static data (DEC-029) | architecture |
| RK-6 | Guideline freshness rules (`dct:valid`, `odpt:frequency`, 1-week static update) constrain caching design | Cache TTLs must follow feed metadata | VERIFIED_LICENSE_TEXT | per-category TTL (ARCH §18); freshness (DEC-024) | Phase 4 design |
| RK-7 | Route provider forbids caching / re-display | Network cost | PENDING_COMMERCIAL_CONFIRMATION | ARCH §18 tolerates "no cache" | A2 |
| RK-8 | Through service split by provider or unsupported at Group B / Challenge boundary | DEC-009 violation | PENDING / Group B | adapter continuity (Phase 3) | A3, A6 |
| RK-9 | Korean names absent from feeds | Extra dataset work | PENDING_PAYLOAD_VERIFICATION | canonical localization (DEC-042) | A4 |
| RK-10 | Numeric rate limits unknown (S5 Art. 4(4) discretionary) | Refresh cadence risk | PENDING_PAYLOAD_VERIFICATION (B1 made one request per resource; no limit behaviour observed) | `RealtimeRefreshPolicy` (ARCH §20) | A1, A3 |
| RK-11 | GTFS-RT protobuf decoding needed without dependency | Implementation cost | design constraint — **decoding feasibility demonstrated** (B2): the Toei feeds decode against the canonical schema with no unknown fields using temporary external research tooling. This does not endorse a handwritten parser in the app; the production decoder design and dependency decision remain open | Rule 14, Rule 34 | Phase 4 |
| RK-12 | No car/door dataset | Feature omitted at most stations | UNAVAILABLE_IN_AUDITED_CATALOG | DEC-019 | accepted |

---

## 13. Verification Actions Before the Phase 0 Decision Gate

These are verification actions, not implementation: no code, SDK, or dependency enters the app target, and Challenge-entry-only data is not touched (§7). Inspection tooling stays outside the repository unless explicitly approved.

| # | Action | Closes | Output |
|---|---|---|---|
| A1 | Register ODPT developer account (Basic License tier only; **no Challenge token**); confirm S1–S6 unchanged; record any Specific Terms attached to DS-03/04/08/09; re-check catalog for Tokyo Metro TU/VP | RK-3, RK-10 (portal-side); DS-05 | §4.1, §9 updated |
| A2 | Obtain evaluation access to ≥2 of DS-11..13; confirm pricing, SLA, App Store consumer use, caching, re-display, termination | PENDING_COMMERCIAL_CONFIRMATION; RK-7 | §10 filled |
| A3 | **N4 join test on Toei (CC BY 4.0):** capture static GTFS + GTFS-RT TripUpdate/VehiclePosition/Alert for ~10 routes incl. one 直通 pattern, one express pattern, one Toei↔Tokyo Metro transfer; verify `trip_id` referential integrity, freshness (`header.timestamp`), coverage, rate behavior. Repeat static + Alert on Tokyo Metro (Basic License; degraded path). Optionally full path on Yokohama Municipal Subway (Basic License) for a second fixture set, kept internal and deletable. **Progress (2026-09-18):** Toei single-snapshot capture and join proof done (B1/B2, §6.1.1) — PASS WITH LIMITATIONS. **Remaining:** repeated temporal sampling (cadence, coverage, route 5), real Alert observation when available, 直通/through-service assessment, Tokyo Metro degraded path, Yokohama optional | PENDING_PAYLOAD_VERIFICATION for DS-01..04, 09; RK-1 | findings + fixtures (documentation, not app code) |
| A4 | Sample station names for Toei / Tokyo Metro / Basic-License operators; measure JP/EN/KO coverage | RK-9 | coverage table |
| A5 | Confirm whether any provider exposes car/door/transfer-time data with a license permitting display | RK-12 | §11 note |
| A6 | Operator-direct investigation for Group B and for the Challenge-licensed private railways' own developer programs (if any) | DS-10; RK-2 | rows updated; none moved to "no API" without evidence |
| A7 | Read operator image/line-color usage conditions (e.g. Tokyo Metro image data conditions in S2 Specific Terms) | DS-14 | note for Phase 7 tokens |

---

## 14. Decision Gate Inputs (ROADMAP Phase 0)

| Gate item | Position | Blocking? |
|---|---|---|
| Deployment target | **Decided: iOS 18.0 minimum, iPhone only (DEC-045, DEC-044)** | No |
| Primary route-search provider direction | **Open** — DEC-004 Provisional; requires A2 + A3 | Yes — before Phase 3 |
| Primary realtime provider direction | **ODPT platform, GTFS static + GTFS-RT as first adapter format**; Toei = full-realtime proof (**single-snapshot join proof passed with limitations, §6.1.1**); Tokyo Metro = degraded proof (untested). Production direction still requires the remaining A3 work; no provider is selected | Yes — before Phase 4 |
| Canonical ID strategy | Decided (DEC-021, Rule 9) | No |
| Licensing viability for initial Tokyo scope | **License text verified (§3).** Production-license-viable: Toei (CC BY 4.0, full realtime); Tokyo Metro / TWR / MIR / Tama Monorail (Basic License, alerts only); Yurikamome (Basic License, static only); Yokohama (Basic License, full realtime, fixture-only scope). **Challenge-entry only / production-blocked:** JR East and the seven Challenge-licensed private railways. **Product decision needed:** whether a Toei-full-realtime + Metro-degraded launch scope is acceptable (RK-2) | Yes — product decision |

The Xcode bootstrap (Track A of `PHASE_0_SCOPE_LOCK.md`) does not depend on the open items. Phase 0 *exit* requires the remaining A3 work and the RK-2 product decision.

---

## 15. Conflicts With Living Documents

Checked against all eight living documents. **No conflict found.** Observations that may warrant *future* document changes (not made here):

- `PRODUCT.md` §6 / DEC-001 "as many Tokyo-area lines as can be supported reliably through legally usable … data" already accommodates RK-2, but `PRODUCT.md` §23 lists "JR East production-grade support" as long-term direction only — consistent. If the Decision Gate narrows the launch scope to Toei + Basic-License operators, `ROADMAP.md` Phase 14 test matrix and `PRODUCT.md` §19 should be re-read for implied JR East / private-railway coverage.
- `ARCHITECTURE.md` §8.3 example shows "ODPT JSON → DTO → Adapter"; §8.2 finding that Tokyo trip-level realtime is GTFS-RT protobuf is compatible (both are named in §8.1), but Phase 4 should list GTFS-RT first.
- iPhone-only / iOS 18.0, DEC-004 Provisional, no dependency, DEC-006, DEC-041/042, DEC-019, FEATURES §14/§17: all consistent.

---

## 16. Maintenance

- Update in place when A1–A7 produce evidence; record evidence + date (B1/B2 Toei payload evidence recorded 2026-09-18, §2.3, §6.1.1).
- Re-verify S1–S6 if ODPT announces changes (S2 Art. 13(4), S3 Art. 13(4)); re-check the Challenge end date if the Challenge is extended.
- When a provider direction is decided, record it in `DECISIONS.md` and revise `PRODUCT.md` §9–§10 / `ROADMAP.md` Phase 3–4 if scope changes.
- Do not create versioned or dated copies of this file.
