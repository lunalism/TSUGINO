# TSUGINO — PROVIDER_FEASIBILITY_AUDIT.md

**Phase:** 0 — Project Bootstrap + Feasibility Baseline
**Status:** Provisional — catalog and license-text verification complete; Toei payload verified from seven snapshots during one evening (B1/B2 single snapshot + B3 six-snapshot short temporal study, 2026-09-18); static route/localization audit complete (B4, offline, 2026-09-18: JA/EN names complete, Korean absent); official-documentation audit complete (B5, 2026-09-18: Liner explicitly excluded from TripUpdate/VehiclePosition, included in Alerts); Tokyo Metro degraded path audited (B6A catalog, B6B first payload observation, B6C persistent recapture + `odpt:Railway` mapping, 2026-09-18: **PASS WITH LIMITATIONS** — static GTFS, Railway, and TrainInformation VERIFIED_PAYLOAD from retained snapshots; no TripUpdate/VehiclePosition found in the audited catalog); longer-window sampling and commercial confirmation pending
**Date:** 2026-09-17 (Toei payload evidence added 2026-09-18; Tokyo Metro payload evidence added 2026-09-18)
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

### 2.3 Payload and documentation basis (2026-09-18, Toei only — B1/B2/B3/B4/B5)

- **B1 transport:** the four official Toei resources named in §4.1 row 1 (GTFS Static; GTFS-RT TripUpdate, VehiclePosition, Alert) were acquired once from `api.odpt.org` with the developer token held in the macOS Keychain. GTFS Static was served through a validated HTTPS redirect to ODPT-operated Azure Blob storage; the ODPT credential was not sent to that host. `api-challenge.odpt.org` was not contacted.
- **B2 decode:** the three GTFS-RT payloads were decoded against the canonical `gtfs-realtime.proto` (GTFS-Realtime 2.0) using temporary external research tooling only; nothing entered the repository. Findings are recorded in §6.1, §8.1, §9, §12.
- **B3 short temporal study:** six further observation sets (TripUpdate, VehiclePosition, Alert each) at ≈5-minute intervals over ≈25 minutes, 19:15–19:40 JST Friday weekday service — exactly 18 requests, all HTTP 200, no retries, no redirects, no static re-download, no transport/decoding/structural errors. Together with B2 this gives **seven snapshots from one evening**; it is not continuous monitoring, multi-day evidence, or an uptime study. Findings in §6.1.2.
- **B4 offline static audit:** the already-verified static ZIP (SHA-256 `f10d03cd951565379e5c397cf9043d0db58b5030b670c29f7c56ac43fe3efbe2`) was analysed with the Python standard library only — no network, no credential access, no new payload, no repository artifact — to identify sanitized route R5 and to inventory `translations.txt` localization coverage. Findings in §6.1.3, §8.1, §9 (DS-01), §12 (RK-9).
- **B5 official-documentation audit:** public, unauthenticated inspection of official pages only — 15 GET requests to `ckan.odpt.org`, `developer.odpt.org`, `www.kotsu.metro.tokyo.jp`; no authentication, credential access, API/payload request, redirect, retry, or Challenge access. `developer.odpt.org` and the Toei site returned client-rendered shells to plain HTTP, so the decisive evidence is the official ODPT catalog dataset/resource pages (VERIFIED_CATALOG). Findings in §6.1.4, §4.1, §9, §12 (RK-13).
- **Retained:** aggregate counts, hashes, and field-presence facts only. No credential, signed URL, raw record, identifier, coordinate, payload, or scratch path is recorded here.

### 2.4 Tokyo Metro payload and catalog basis (2026-09-18 — B6A/B6B/B6C)

- **B6A official catalog audit:** 26 public, unauthenticated GET requests (`ckan.odpt.org` ×25; one Tokyo Metro corporate page returned HTTP 403 to plain HTTP and is a limitation, not evidence). All ten Tokyo Metro datasets carry the Basic License label. The realtime dataset lists exactly one resource — GTFS-RT **Alert**; catalog-wide searches for TripUpdate / VehiclePosition / 列車ロケーション returned no Tokyo Metro entry (VERIFIED_CATALOG for presence; `UNAVAILABLE_IN_AUDITED_CATALOG` for TU/VP — not a claim of non-existence). The image dataset carries Specific Terms of Use (A7).
- **B6B first authenticated observation:** GTFS-RT Alert, `odpt:TrainInformation`, and the static GTFS archive (validated HTTPS redirect from `api.odpt.org` to ODPT-operated Azure Blob storage; ODPT credential not sent to that host) were each acquired once from the official resources and analysed offline. The static archive hash and aggregate findings were recorded; the B6B Alert and status **raw files were transient and were not retained**. The B6B Alert observation (one decoded entity) is therefore recorded in §6.2.2 as bounded observed evidence with an explicit retention limitation, not as reproducible payload evidence.
- **B6C persistent recapture + Railway mapping audit:** exactly **five** authorized requests, no retries, no redirects followed automatically — `odpt:Railway` (operator filter), `odpt:TrainInformation` (operator filter), GTFS-RT Alert, the static GTFS ODPT request (HTTP 302, `Location` validated in memory against scheme/host/port/path/signed-query/no-credential rules before use), and one separate signed-URL Azure download without the ODPT credential, Authorization, cookies, or Referer. The static archive reproduced the B6B archive **bit-for-bit** (same SHA-256). The four public payloads are retained **outside the repository** in an owner-only persistent research directory (directory 700, files 600) together with sanitized headers, a stdlib-only analysis script, and aggregate output; no credential, authenticated URL, signed URL, SAS parameter, raw redirect header, redirect body, cookie, or Authorization data is retained anywhere. The Alert was decoded against a hand-encoded field map of the canonical GTFS-Realtime 2.0 schema (the `.proto` file was not re-fetched); this is temporary research tooling, not a decoder decision (RK-11).
- **Retained here:** retrieval dates, public query-free host/path identities, aggregate counts, hashes, and evidence classifications only. No local path, credential, authenticated or signed URL, raw record, incident text, coordinate, or identifier dump is recorded.

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

Catalog-level capability and license label per operator. **Presence, resources, and label: VERIFIED_CATALOG. Payload: PENDING_PAYLOAD_VERIFICATION for every row except Toei (static and GTFS-RT payloads VERIFIED_PAYLOAD, §2.3, §6.1) and Tokyo Metro (static GTFS, `odpt:Railway`, and `odpt:TrainInformation` VERIFIED_PAYLOAD from one retained snapshot each; Alert transport/framing verified, entity semantics limited — §2.4, §6.2).** Verdict per §2.1.

| # | Operator | Static (catalog resources) | Realtime (catalog resources) | License label (catalog) | Commercial-use verdict |
|---|---|---|---|---|---|
| 1 | **Toei** (東京都交通局) | GTFS/GTFS-JP (subway, tram, Liner), GTFS-Pathways, Train timetable (JSON), fare — GTFS Static **VERIFIED_PAYLOAD (1 static snapshot; structure, JA/EN localization, no Korean — §6.1.3)** | GTFS-RT **TripUpdate + VehiclePosition: Toei Subway and Tokyo Sakura Tram only — Nippori-Toneri Liner explicitly excluded (VERIFIED_CATALOG, §6.1.4)** — subway/tram **VERIFIED_PAYLOAD (7 snapshots, one evening)**; GTFS-RT **Alert: subway, tram, and Liner** (VERIFIED_CATALOG; payloads header-only in all snapshots); Train status JSON (subway, tram, Liner; catalog-listed); Train location JSON (subway, tram; Liner not named) | **CC BY 4.0** | **production-license-viable — trip-level realtime for Toei Subway and Tokyo Sakura Tram; alerts/status-level for the Nippori-Toneri Liner** (attribution, §3.5) — a legal/capability classification per service, not a provider selection |
| 2 | **Tokyo Metro** | GTFS/GTFS-JP — **VERIFIED_PAYLOAD (1 retained archive, B6B/B6C: 9 routes, 9,544 trips, 185 stop rows / 144 canonical names, JA/EN complete, Korean absent — §6.2.2)**; route JSON (`odpt:Railway`) — **VERIFIED_PAYLOAD (1 retained snapshot: 10 records, line codes G M H T C Y Z N F Mb, Korean titles 9/10 — §6.2.2)**; station, station timetable, train timetable, fare (JSON) — VERIFIED_CATALOG | GTFS-RT **Alert** — transport/framing **VERIFIED_PAYLOAD (retained B6C snapshot header-only; one earlier B6B entity observed, raw file not retained — §6.2.2)**; Train status JSON (`odpt:TrainInformation`) — **VERIFIED_PAYLOAD (1 retained snapshot; line-level status, 10/10 Railway IDs resolve; Japanese-only text)**. TripUpdate / VehiclePosition: **UNAVAILABLE_IN_AUDITED_CATALOG** (re-checked by B6A) | **Basic License** | **production-license-viable, alerts only** (Basic License obligations, §3.2) — degraded path **PASS WITH LIMITATIONS** (§6.2.6); a capability classification, not a provider selection |
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

- **Trip-level realtime under a production-license-viable label** exists in the catalog for **Toei only** (Tokyo core) and **Yokohama Municipal Subway** (outside core). Within Toei it is service-qualified: **Toei Subway and Tokyo Sakura Tram** are the audited Tokyo-core trip-level realtime proof path; the **Nippori-Toneri Liner** is an alerts/status-level degraded case under the currently audited official resources (§6.1.4). Toei capability must be modeled per service (DEC-022) rather than inferred from the operator as a whole; no other operator is read as trip-level realtime.
- **Basic-License operators** other than Toei/Yokohama offer **Alerts and/or schedule only** → degraded mode (FEATURES §10.3, DEC-024). For Tokyo Metro this degraded path (static schedule + line-level status + Alert, no TripUpdate/VehiclePosition) is payload-supported with limitations (§6.2); status and Alert are not vehicle progress, and the model is the per-service honest degraded mode of DEC-046 — Tokyo Metro is a different operator from the Nippori-Toneri Liner and shares only the capability pattern.
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

### 6.1 Toei — trip-level realtime feasibility proof candidate (Subway and Tokyo Sakura Tram; Liner alerts/status-level)

| Item | Status |
|---|---|
| Static GTFS + GTFS-Pathways + train timetable | VERIFIED_CATALOG |
| GTFS-RT TripUpdate + VehiclePosition — Toei Subway and Tokyo Sakura Tram; Nippori-Toneri Liner **explicitly excluded** | VERIFIED_CATALOG (§6.1.4) |
| GTFS-RT Alert — Toei Subway, Tokyo Sakura Tram, and Nippori-Toneri Liner | VERIFIED_CATALOG (§6.1.4); Liner Alert identifiers/semantics PENDING_PAYLOAD_VERIFICATION (all observed Alert payloads were empty) |
| License: CC BY 4.0 — commercial use, attribution, adaptation, no downstream restrictions | VERIFIED_LICENSE_TEXT (§3.5) |
| API access token + due-care obligation (Center Use Rules) | VERIFIED_LICENSE_TEXT (§3.2) |
| Static ↔ realtime `trip_id` integrity, join key | **VERIFIED_PAYLOAD (7 snapshots, one evening, 2026-09-18: B2 ×1 + B3 ×6 at ≈5-min spacing)** — see §6.1.1 and §6.1.2 |
| Static route identity and JA/EN/KO localization structure | **VERIFIED_PAYLOAD (1 static snapshot, B4, §6.1.3)** — JA and EN complete and deterministic; **Korean absent** |
| Realtime coverage of the Nippori-Toneri Liner (R5) | TripUpdate/VehiclePosition: **EXPLICITLY EXCLUDED** by the official resource descriptions (VERIFIED_CATALOG, §6.1.4) — the observed 0/7 is the expected result under that scope, not a payload defect. Alert/status JSON: catalog-listed for the Liner; payload semantics PENDING_PAYLOAD_VERIFICATION |
| Freshness cadence, uptime, coverage over time | PENDING_PAYLOAD_VERIFICATION (short-window freshness observed only: seven snapshots over ≈55 minutes of one evening; no multi-day, overnight, rush-hour, or long-duration study) |
| Rate limits (numeric) | PENDING_PAYLOAD_VERIFICATION |
| **Verdict** | **production-license-viable**; **Toei Subway and Tokyo Sakura Tram** are the Phase 0 candidates for proving the trip-level realtime path (static → trip identity → TripUpdate → optional VehiclePosition → Alert → `RealtimeSnapshot`); the **Nippori-Toneri Liner** is static + Alert/status-level only under the audited resources. **B2 outcome: PASS WITH LIMITATIONS. B3 outcome: PASS WITH LIMITATIONS** (§6.1.2). **B4 outcome: PASS WITH LIMITATIONS** (§6.1.3). **B5 outcome: EXPLICITLY EXCLUDED** (Liner in TU/VP, §6.1.4). This is not a provider selection; DEC-004 remains Provisional. |

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

Limitations (as recorded after B2; see §6.1.2 for what B3 reduced or preserved): one snapshot only; route 5 absent although static scheduled trips exist for it; no repeated cadence, uptime, or availability study; no independent fallback key if `trip_id` is absent; all VehiclePositions `STOPPED_AT` is unexplained; actual Alert incident content unobserved; through-service continuity not assessed; Tokyo Metro alerts-only degraded path not tested; JP/EN/KO name coverage not analyzed (A4); commercial and operational terms pending; no production decoder dependency selected (RK-11).

#### 6.1.2 B3 short temporal study (six snapshots, 2026-09-18, 19:15–19:40 JST)

Scope: six observation sets at ≈5-minute intervals (actual 299.7–300.5 s), each fetching TripUpdate, VehiclePosition, and Alert once; 18/18 requests HTTP 200; no retries, redirects, static re-download, or transport/decoding/structural errors. Static references were checked against the B1-verified archive. B2 + B3 = seven snapshots from one evening.

Header and transport stability (all six observations):

| Item | Observation |
|---|---|
| Version / incrementality / header timestamp | 2.0 / FULL_DATASET / present in every feed |
| Header timestamps between observations | advanced on 5/5 transitions for all three feeds; none unchanged, none backward |
| Payload hashes between observations | changed on 5/5 transitions |
| Future-dated headers / headers older than 60 s | 0 / 0 |
| Duplicate entity IDs / deleted / mixed or unknown types / unknown fields | 0 / 0 / 0 / 0 |
| Header age at retrieval | TripUpdate and VehiclePosition min 25 s · median 30 s · max 33 s; Alert 27 / 27 / 28 s |
| VehiclePosition entity age | minimum of minima 37 s · median of snapshot medians 40 s · maximum of maxima 53 s; 0 older than 60 s; 0 future |
| Entity vs. header timestamps | entity timestamps trailed the feed header by ≈7–10 s — an observed publication characteristic, not a guaranteed cadence |

Entity and static-reference integrity (totals across the six snapshots):

| Item | Observation |
|---|---|
| Entities | TripUpdate 620 · VehiclePosition 620 · StopTimeUpdates 17,156 |
| Static `trips.txt` match | 100% in every snapshot for both feeds; 0 unresolved trip references |
| StopTimeUpdate `stop_sequence` → static stop | 100% in every snapshot; VehiclePosition `current_stop_sequence` → static stop 100%; 0 unresolved stop references |
| Field behaviour (unchanged from B2) | `trip_id` present 100%; realtime `route_id`/`direction_id` absent, recoverable from static for 100%; StopTimeUpdate `stop_id` absent, `stop_sequence` present 100%; explicit trip/StopTimeUpdate `delay` absent; vehicle descriptor ID present and unique 100%; VehiclePosition timestamp present 100%, `stop_id` absent, `current_stop_sequence` present 100%, lat/lon present 100%, bearing absent; all matched trips on the active weekday service |

Cross-feed join stability: exact TripUpdate ↔ VehiclePosition `trip_id` join **100% in both directions in every snapshot**, one-to-one 100%, 0 collisions, 0 TripUpdate-only, 0 VehiclePosition-only. Per-snapshot entity counts fell from 107 to 101 across the window while every snapshot kept a complete cross-feed match. Between successive snapshots 10–12 trips were added, 9–14 removed, 90–93 retained — clean observed set churn consistent with trips entering and leaving the active set; not a formal lifecycle guarantee. Entity ID and vehicle descriptor ID equalled `trip_id` for all 620 entities: **coincidental observed behaviour — entity ID is not a designed cross-feed join key, and no independent fallback key was demonstrated for the case where `trip_id` is absent.**

Route coverage: sanitized static routes R1, R2, R3, R4, R6 appeared in 6/6 snapshots; **R5 appeared in 0/6**. The cause is unknown; this does not show that R5 is unsupported, omitted from the feed, or incapable of realtime reporting. Route-coverage investigation stays open.

Vehicle `current_status` per snapshot: `STOPPED_AT` 106, 104, 103, 102, 103, 101; `IN_TRANSIT_TO` 1 (first observation only); `INCOMING_AT` 0; missing 0. This corrects the B2 wording: the field is **not constant** (one `IN_TRANSIT_TO` value was observed) but the distribution remained overwhelmingly `STOPPED_AT`; the reason is unexplained. A station-centric or provider-specific publication model is a hypothesis only, not a conclusion.

Alerts: 0 entities in all six observations; every payload a valid header-only feed with normally advancing header timestamps; no selector, informed-entity, active-period, cause, effect, or translation content observed. This records only that no Alert entities were present at those six instants — not absence of disruption, and not verified incident semantics, multilingual content, or Alert-to-route matching.

**B3 result: PASS WITH LIMITATIONS.** All six observation sets succeeded; cross-feed joins and static resolution remained complete; timestamps advanced normally; freshness stayed within the observed range; trip-set churn was clean; no structural inconsistency occurred.

Limitations after B3 — *reduced:* "one snapshot only" (now seven from one evening; structure and 100% joins identical across all); short-window freshness consistency observed. *Preserved:* six observations over ≈25 minutes only, all seven snapshots from one evening; no multi-day, overnight, rush-hour comparison, or long-duration study; R5 absent; no independent fallback join key; Alert content unobserved; VehiclePosition status overwhelmingly `STOPPED_AT`; through-service continuity not assessed; Tokyo Metro degraded behaviour not tested; JP/EN/KO name coverage not analyzed (closed by B4, §6.1.3); commercial terms pending; production decoder/dependency decision open; explicit delay fields absent; no SLA, uptime, or production-operations claim. *Newly observed:* `current_status` is not constant; entity timestamps trail headers by ≈7–10 s.

#### 6.1.3 B4 offline static audit — route identity, R5, localization (one static snapshot, 2026-09-18)

Basis: the verified static ZIP only (§2.3); Python standard library; no network, credential, new payload, or repository artifact. **B4 result: PASS WITH LIMITATIONS.**

Route identity (deterministic mapping used by B2/B3: `routes.txt` file order):

| Label | Japanese `route_long_name` | English (`translations.txt`) | Korean in feed | GTFS `route_type` |
|---|---|---|---|---|
| R1 | 浅草線 | Asakusa Line | absent | 1 — Subway |
| R2 | 三田線 | Mita Line | absent | 1 — Subway |
| R3 | 新宿線 | Shinjuku Line | absent | 1 — Subway |
| R4 | 大江戸線 | Oedo Line | absent | 1 — Subway |
| R5 | 日暮里・舎人ライナー | Nippori-Toneri Liner | absent | 2 — Rail |
| R6 | 東京さくらトラム（都電荒川線） | Tokyo Sakura Tram (Arakawa Line) | absent | 0 — Tram |

`route_short_name` is blank for all six; JA and EN long names exist for 6/6, Korean for 0/6; `route_color` present for the four subway routes only (R5, R6 none); `route_text_color` absent for all six. Missing colours and short names are presentation/supplement needs, not provider-rejection grounds.

R5 schedule investigation — **NOT SCHEDULE-EXPLAINED.** R5 is the Nippori-Toneri Liner. On 2026-09-18 (service `0`, no `calendar_dates` exception that day): 519 active trips, static service 05:08–24:58 JST; trips overlapping the B2 instant (≈18:46 JST): **11**; overlapping the B3 window (≈19:15–19:40 JST): **23**; starting within ±30 min of the B3 window: 40; 13 stops; stop-time sequences complete and contiguous for every trip; no static structural defect distinguishes R5 from R1–R4/R6. R5 appeared in **0/7** observed realtime snapshots. Its absence therefore cannot be explained by a lack of scheduled service during the observation windows; this does **not** prove that the provider permanently excludes or does not support the line, and the reason remains unresolved. Unverified hypotheses only (none selected): realtime publication scope may exclude or separately handle the Liner; mode-specific feed behaviour; a different trip lifecycle/update policy; static/realtime identifier mismatch; another service characteristic not represented by the generic analysis. R6 (tram) did appear in realtime, so the evidence does not support a generic "non-subway routes are excluded" explanation. **Resolved by B5 (§6.1.4):** the official TripUpdate/VehiclePosition resource descriptions explicitly exclude the Liner, so the 0/7 result is expected under documented scope and is no longer an unexplained omission; the B4 classification remains correct as a *schedule* finding.

`translations.txt` structure: 404 rows; languages Japanese 202 / English 202 / **Korean 0**; tables agency, routes, stops, trips; fields `agency_name`, `route_long_name`, `stop_name`, `trip_headsign`; keyed by `table_name`/`field_name`/`field_value`/`language`/`translation` (no record-ID columns); duplicate keys 0, conflicting duplicates 0, empty translations 0, unresolved translation targets 0; every Japanese translation row duplicates its Japanese source value; feed and agency source language Japanese. These facts establish *presence* and *deterministic resolution*; they are distinct from complete language coverage, from suitability as canonical display text, and from sufficiency for search aliases.

Localization coverage:

| Field | Japanese | English (provider translation) | Korean | JA+EN+KO complete |
|---|---|---|---|---|
| Route long names | 6/6 | 6/6 | 0/6 | 0/6 |
| Canonical station names (141 distinct) | 141/141 (100%) | 141/141 (100%) | 0/141 (0%) | 0/141 |
| Agency name | present | present | absent | — |
| Distinct trip headsigns | 54/54 | 54/54 | 0/54 | 0/54 |
| `stop_headsign` | unused | — | — | — |

Station structure: 149 `stops.txt` rows, every row `location_type = 0`; no parent-station rows, no `parent_station` references, no platform codes; 141 distinct passenger-facing names — 133 occur once, 8 occur twice because they are cross-line interchange stations (三田, 大門, 蔵前, 神保町, 春日, 新宿, 森下, 熊野前). The duplicate names resolve to the same English translation within this Toei snapshot, but canonical station identity must not be based solely on display-name equality across operators.

Canonical-localization interpretation (consistent with DEC-041, DEC-042, ARCHITECTURE §5.1/§5.2/§39.1/§40): (1) Toei may supply source inputs for canonical Japanese and English display names; (2) Toei cannot supply Korean display names from this audited static feed; (3) TSUGINO must own and maintain Korean route names, Korean station names, Korean trip-headsign equivalents where the product requires them, Korean search aliases, Japanese reading aliases, romanization variants, line codes and short-name supplements, common-name aliases, and cross-operator canonical station identity; (4) provider Japanese and English strings remain inputs, not the sole source of truth; (5) provider English may be accepted as initial canonical display text only after project-side style review; (6) search aliases remain project-owned even where provider display translations are accepted; (7) Korean localization must be created and reviewed during implementation as a project-owned static dataset or equivalent controlled resource; (8) this audit does not create that dataset and invents no translations. Normalization needs: merge the eight Toei cross-line duplicates into project-owned canonical stations with per-line provider identifiers as aliases; do not merge stations across operators by name alone; retain Unicode normalization at ingestion; establish a style policy for English hyphenation and capitalization; represent 東京さくらトラム（都電荒川線） with an explicit primary-name and alias policy; distinguish exact station names from substring-related names during search; add project-owned line codes because `route_short_name` is empty. **B4 confirms rather than contradicts DEC-041, DEC-042, and the canonical-localization architecture.**

Limitations: one static snapshot; GTFS-Pathways and the JSON timetable datasets not inspected; English display suitability pending style review; cross-operator canonical identity untested (no Tokyo Metro static captured); R5 realtime scope — resolved by documentation in §6.1.4 (product handling still open, RK-13); Korean dataset not yet created.

#### 6.1.4 B5 official-documentation audit — Nippori-Toneri Liner realtime scope (2026-09-18)

Basis: public, unauthenticated official pages only (§2.3). **B5 primary result: `EXPLICITLY EXCLUDED`** — applying only to the Nippori-Toneri Liner in the current Toei GTFS-RT **TripUpdate** and **VehiclePosition** resources. It does not mean the Liner is unsupported by Toei or ODPT in general.

Official sources (sanitized public catalog URLs, no query strings):

| Source | Official title | Scope wording (evidence strength) |
|---|---|---|
| `https://ckan.odpt.org/dataset/train-toei` | 東京都交通局 鉄道関連情報 / Train information of Bureau of Transportation, Tokyo Metropolitan Government | Static GTFS explicitly covers 都営地下鉄, 東京さくらトラム（都電荒川線）, 日暮里・舎人ライナー (explicit) |
| `https://ckan.odpt.org/dataset/r_train_gtfs_rt-odpt_train-toei` | 東京都交通局 鉄道関連リアルタイム情報 / Train realtime information of Bureau of Transportation, Tokyo Metropolitan Government | Dataset-level text names all three services; per-resource text below is decisive |
| …/resource/`0e63c9af-98b8-4d88-a9d6-10dd96dbd9c4` (TripUpdate) | 鉄道関連リアルタイム情報(TripUpdate) | Japanese description: covers Toei Subway and Tokyo Sakura Tram — 「なお、日暮里・舎人ライナーは含まれません。」 (*"Note: the Nippori-Toneri Liner is not included."*) (**explicit exclusion**) |
| …/resource/`ab773be1-aab7-47f2-8cd7-1ddbd9d8c8b9` (VehiclePosition) | 鉄道関連リアルタイム情報(VehiclePosition) | Same explicit Liner exclusion sentence (**explicit exclusion**) |
| …/resource/`135dfdac-1d1c-4609-b7f2-57146d6ce059` (Alert) | 鉄道関連リアルタイム情報(Alert) | Covers 都営地下鉄, 東京さくらトラム（都電荒川線）, 日暮里・舎人ライナー (**explicit inclusion**) |
| `https://ckan.odpt.org/dataset/r_train_location-toei` | 東京都交通局 列車ロケーション情報 (JSON `odpt:Train`) | Names subway and tram (and excludes the Mita Line Meguro–Shirokane-Takanawa section); does **not** name the Liner (**implied** exclusion only) |
| `https://ckan.odpt.org/dataset/r_train_status-toei` | 東京都交通局 運行情報 (train status JSON) | Explicitly includes the Liner; payload semantics unverified; **not trip-level progress** |
| `https://ckan.odpt.org/dataset/r_train_timetable-toei` | 東京都交通局 列車時刻表 (timetable JSON) | Explicitly includes the Liner; payload unverified; **static, not realtime** |

Separate-feed search: the catalog's own search for 日暮里・舎人ライナー / Nippori-Toneri / GTFS-RT toei returned only the general Toei datasets; **no separate Liner trip-level realtime dataset was found in the audited official public catalog/pages** (absence from search is not proof that none exists). The endpoint names `toei_odpt_train_*` are not defined anywhere inspected; scope is defined by the resource descriptions, not the names, and GTFS `route_type = 2` carries no realtime implication.

Documentation-quality observation: the explicit exclusion sentence appears only in the Japanese half of the TripUpdate/VehiclePosition descriptions and is absent from the English half. The Japanese official text is valid source evidence; English-only readers would not see the exclusion.

Per-service capability (canonical interpretation for this audit):

| Toei service | Static GTFS | TripUpdate | VehiclePosition | Alert | Status / timetable JSON |
|---|---|---|---|---|---|
| Toei Subway (浅草線・三田線・新宿線・大江戸線) | available — VERIFIED_PAYLOAD | available — VERIFIED_PAYLOAD (7 snapshots, one evening) | available — VERIFIED_PAYLOAD (7 snapshots) | included — VERIFIED_CATALOG; payload semantics PENDING_PAYLOAD_VERIFICATION (observed feeds empty) | catalog-listed — VERIFIED_CATALOG; payload unverified |
| Tokyo Sakura Tram (都電荒川線) | available — VERIFIED_PAYLOAD | available — VERIFIED_PAYLOAD | available — VERIFIED_PAYLOAD | included — VERIFIED_CATALOG; semantics pending | catalog-listed — VERIFIED_CATALOG; payload unverified |
| Nippori-Toneri Liner | available — VERIFIED_PAYLOAD (928 static trips) | **explicitly excluded** — VERIFIED_CATALOG | **explicitly excluded** — VERIFIED_CATALOG | **explicitly included** — VERIFIED_CATALOG; Liner identifiers/semantics PENDING_PAYLOAD_VERIFICATION | explicitly catalog-listed — VERIFIED_CATALOG; payload unverified; status is not vehicle progress, timetable is not realtime |

Relationship to B4: B4's `NOT SCHEDULE-EXPLAINED` remains correct — the static schedule did not explain the absence (11 and 23 scheduled Liner trips overlapped the observations). B5 explains it through official resource scope; the 0/7 TripUpdate/VehiclePosition result is therefore expected, not a payload defect and no longer an unexplained omission.

Product-interpretation boundaries (no product-scope decision is made here): this is provider/service capability handling under DEC-022 — no device detection or feature disabling is involved; the app must never present synthetic vehicle progress for the Liner; if the Liner remains in product scope, the safe current model is schedule plus status/Alert-level information; missing TripUpdate/VehiclePosition must be represented as an unavailable capability, not as stale or empty live progress. Product scope was subsequently decided by DEC-046 (2026-09-18): the Liner is in v1 scope in honest degraded mode; this is an accepted product inclusion, not a provider selection, and it does not promote any payload evidence.

Limitations: `developer.odpt.org` documentation and Toei's own pages could not be read via plain HTTP (client-rendered); catalog wording may change without notice (S5 Art. 13); Liner Alert/status payloads were not observed; the `odpt:Train` JSON scope was not checked empirically.

### 6.2 Tokyo Metro — degraded-mode proof (schedule + line-level status + Alert; no trip-level realtime)

| Item | Status |
|---|---|
| Static GTFS | **VERIFIED_PAYLOAD (1 retained archive, B6B observed + B6C reproduced bit-for-bit, §6.2.2)** |
| `odpt:Railway` route JSON | **VERIFIED_PAYLOAD (1 retained snapshot, B6C, §6.2.2)** |
| `odpt:TrainInformation` status JSON | **VERIFIED_PAYLOAD (1 retained snapshot, B6C — line-level status only, §6.2.2)** |
| GTFS-RT Alert | transport and framing **VERIFIED_PAYLOAD (retained B6C snapshot: valid GTFS-RT 2.0 FULL_DATASET header, zero entities)**; entity semantics: one B6B entity observed, raw payload not retained — PENDING_PAYLOAD_VERIFICATION for cause/effect variety, active periods, language behaviour across incidents, and coverage (§6.2.2) |
| Station, station timetable, train timetable, fare JSON | VERIFIED_CATALOG (B6A); payload PENDING_PAYLOAD_VERIFICATION |
| GTFS-RT TripUpdate / VehiclePosition | **UNAVAILABLE_IN_AUDITED_CATALOG** (B6A re-check, §6.2.1) — a capability limitation, not a transport failure; not a claim of non-existence |
| License: Basic License — registration, for-profit OK, specific terms prevail, no redistribution, as-is, may terminate, own contact, guideline freshness rules | VERIFIED_LICENSE_TEXT (§3.2); image dataset carries Specific Terms (A7) |
| Static route ↔ Railway ↔ TrainInformation ↔ Alert mapping | **PASS WITH LIMITATIONS** (§6.2.3–§6.2.5): TrainInformation → Railway direct 10/10; static → Railway derivable 9/9 from official fields; Alert → static direct in one non-retained observation; `MarunouchiBranch` partially supported |
| Freshness cadence, uptime, incident coverage, rate limits | PENDING_PAYLOAD_VERIFICATION (single snapshots; normal-operations state only) |
| **Verdict** | **production-license-viable, alerts only**; **B6 outcome: PASS WITH LIMITATIONS** — the schedule-fallback / status-and-alerts degraded mode (FEATURES §10.3, DEC-024, DEC-038, Rule 11; honest degraded-mode model per DEC-046) is payload-supported for Tokyo Metro with the limitations in §6.2.6. Trip-level realtime is **not** established. This is not a provider selection; DEC-004 remains Provisional. If TripUpdate/VehiclePosition appear later, status is upgraded only after catalog/license, payload, join, freshness, and UI-state verification. |

#### 6.2.1 B6A official catalog audit (2026-09-18, unauthenticated)

Basis §2.4. Publisher 東京メトロ / Tokyo Metro; Basic License label on all ten datasets (`train-tokyometro` static GTFS; `r_train_gtfs_rt-odpt_train-tokyometro` with the single resource 鉄道関連リアルタイム情報(Alert); `r_train_status-tokyometro` (`odpt:TrainInformation`); `r_station-tokyometro`; `r_route-tokyometro` (`odpt:Railway`); `r_station_timetable-tokyometro`; `r_train_timetable-tokyometro`; `r_fare-tokyometro`; `r_image-tokyometro` (Specific Terms of Use bundled); `r_passenger_survey-tokyometro`). Public payload paths (query-free): `api.odpt.org` `/api/v4/files/TokyoMetro/data/TokyoMetro-Train-GTFS.zip`, `/api/v4/gtfs/realtime/tokyometro_odpt_train_alert`, `/api/v4/odpt:TrainInformation`, `/api/v4/odpt:Railway`. No dataset states an update frequency, line scope, or supported languages. **TripUpdate, VehiclePosition, and `odpt:Train` location: NOT FOUND IN AUDITED OFFICIAL CATALOG** (catalog-wide searches; rail TU/VP entries exist only for Keio, Tobu, Yokohama Municipal, Toei). No GTFS-Pathways resource (Toei has one; Tokyo Metro does not).

#### 6.2.2 B6B/B6C payload record (retained snapshots 2026-09-18 13:15 UTC unless stated)

Transport (B6C): five requests, five expected responses — Railway HTTP 200 JSON 49,842 B (SHA-256 `90b16083…b97f6c`); TrainInformation HTTP 200 JSON 4,747 B (`af54c548…652e63`); Alert HTTP 200 protobuf 15 B (`c87ad6e0…6f4cc6`); static ODPT request HTTP 302 (not followed automatically; redirect validated) → Azure HTTP 200 ZIP 1,113,444 B (`9a077f8ff182f58e1b26383c4f1d48133015e54b619a9851d9fb33a15f91cc45`, blob last-modified 2026-05-28). No login page, unexpected redirect, or transport error.

Static GTFS (one retained archive; B6B hash reproduced by B6C):

| Item | Observation |
|---|---|
| Archive | valid ZIP, all CRCs pass, 11 UTF-8 `.txt` entries (BOM-tolerant), 1,111,726 B compressed / 8,242,595 B uncompressed; no absolute or `..` paths, executables, non-text, duplicate, or empty entries |
| Files | agency 1 · routes 9 · trips 9,544 · stops 185 · stop_times 172,168 · calendar 2 · calendar_dates 26 · feed_info 1 · translations 494 · fare_attributes 8 · fare_rules 33,938. **Absent:** pathways, levels, transfers, shapes, frequencies |
| `feed_info` | publisher 東京メトロ, `feed_lang ja`, 2026-03-14 → 2026-12-31, version 20260528 |
| Internal integrity | route, trip, and stop IDs unique; 0 unknown route/service/trip/stop references; 26/26 calendar_dates resolve; 9,544/9,544 trips have stop_times with `stop_sequence` starting at 1, contiguous, no duplicates (4,151 non-timepoint rows with blank times, GTFS-legal); trips per route 744–1,533 |
| Routes | all `route_type 1`; `route_long_name` 9/9, `route_short_name` 0/9, `route_color` 9/9 valid, `route_text_color` 0/9 |
| Stations | 185 rows, all `location_type 0`, 0 parent references (flat feed); **144 canonical station names** under the flat-feed grouping rule (112 ×1, 24 ×2, 7 ×3, 1 ×4 — per-line rows at interchanges); `stop_code` 185/185 with a **line-letter + number** shape (letters C F G H M N T Y Z plus `Mb` on three stops) |

`odpt:Railway` (one retained snapshot): 10 records, 10 unique `@id`/`owl:sameAs`, all `odpt:Railway`, all `odpt.Operator:TokyoMetro`. Every record carries `odpt:railwayTitle`, `odpt:lineCode`, `odpt:color`, `odpt:ascendingRailDirection`, `odpt:descendingRailDirection`, and `odpt:stationOrder` (indices 1..n contiguous; all station references in the operator namespace; 0 malformed). Line codes unique: **G M H T C Y Z N F Mb**. Colours valid hex; one duplicate (`Marunouchi` and `MarunouchiBranch` share the same colour). Station-order counts: Ginza 19 · Marunouchi 25 · MarunouchiBranch 4 · Hibiya 22 · Tozai 23 · Chiyoda 20 · Yurakucho 24 · Hanzomon 14 · Namboku 19 · Fukutoshin 16. Title languages: ja 10/10, en 10/10, **ko 9/10**, zh-Hans 9/10, zh-Hant 9/10 (`MarunouchiBranch` has ja/en only); station-order titles carry ja, en, ko, zh-Hans, zh-Hant, and ja-Hrkt in all ten orders. **No parent, branch, part-of, same-as-other, or connection field exists**; the only link-type key is `owl:sameAs` (self identity). The record set is a direct key space for `odpt:TrainInformation`.

`odpt:TrainInformation` (one retained snapshot): 10 records, 10 distinct `odpt:railway` values, operator consistent; keys limited to `@context`, `@id`, `@type`, `dc:date`, `dct:valid`, `odpt:operator`, `odpt:railway`, `odpt:trainInformationText`, `owl:sameAs`. `dc:date` age 43 s at retrieval; `dct:valid` 5 minutes ahead (a validity window, not a cadence guarantee). Text **Japanese-only** (ja 10/10, en 0, ko 0); one identical normal-operations string on all ten lines; `trainInformationStatus`, `Cause`, `Area`, and `timeOfOrigin` absent in this state. **No** train-number, vehicle, from/to-station, position, delay-duration, trip, or stop field → **line-level status, not vehicle progress**; it must never be represented as a current train location or progression.

GTFS-RT Alert: **retained B6C snapshot** — 15 bytes, valid GTFS-Realtime 2.0 header (`FULL_DATASET`, timestamp 33 s old at retrieval), **zero entities**, 0 decode errors, no unknown fields; not HTML/JSON/ZIP. Therefore no cause, effect, selector, active-period, or translation content was observed in the retained snapshot. **Earlier B6B transient observation** (2026-09-18, same day, earlier): a 159-byte payload with **one** decoded Alert entity whose `informed_entity` route selector carried a GTFS `route_id` that resolved **1/1** to the static route 千代田線 (Chiyoda Line); the TrainInformation record for the same line carried a non-normal status at that time, consistent with the Alert; the text observed was Japanese-only. **The raw B6B Alert and status files were not retained**, so this is bounded observed evidence, not reproducible payload evidence. Nothing here establishes cause/effect variety, active-period behaviour, language behaviour across incidents, cadence, uptime, or incident coverage. Alert is not TripUpdate/VehiclePosition and provides no live train progression.

#### 6.2.3 Static GTFS ↔ Railway mapping (B6C, one snapshot each)

No explicit shared cross-identifier exists: `routes.txt` has no `odpt:railway` column and the Railway payload has no GTFS `route_id`. Therefore **no mapping is `DIRECT`**. All nine static routes are **`DERIVABLE_FROM_OFFICIAL_FIELDS`** on concordant official evidence: Railway `odpt:lineCode` == static `stop_code` line-letter prefix (each letter serves exactly one static route), exact Japanese `route_long_name` == `odpt:railwayTitle.ja`, exact English translation == `odpt:railwayTitle.en`, and `route_color` == `odpt:color`. Zero ambiguous, zero unresolved.

| Static route (public `route_long_name`) | Railway public suffix | Line code | Classification |
|---|---|---|---|
| 銀座線 (Ginza Line) | `Ginza` | G | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 丸ノ内線 (Marunouchi Line) | `Marunouchi` (+ `MarunouchiBranch` sub-scope, §6.2.4) | M (+ Mb) | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 日比谷線 (Hibiya Line) | `Hibiya` | H | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 東西線 (Tozai Line) | `Tozai` | T | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 千代田線 (Chiyoda Line) | `Chiyoda` | C | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 有楽町線 (Yurakucho Line) | `Yurakucho` | Y | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 半蔵門線 (Hanzomon Line) | `Hanzomon` | Z | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 南北線 (Namboku Line) | `Namboku` | N | DERIVABLE_FROM_OFFICIAL_FIELDS |
| 副都心線 (Fukutoshin Line) | `Fukutoshin` | F | DERIVABLE_FROM_OFFICIAL_FIELDS |

The derivation is project-owned (mapping table under DEC-021) and must be re-verified on any static or Railway revision; it invents no canonical identifier.

#### 6.2.4 `MarunouchiBranch`

| Question | Finding (official payload evidence) |
|---|---|
| Separate Railway record | **Yes** — public suffix `MarunouchiBranch`, line code **`Mb`**, Japanese title 丸ノ内線支線 and English title Marunouchi Branch Line present; **Korean (and Chinese) Railway-level title absent**; same colour as `Marunouchi`; four-station station order; ascending/descending directions Nakano-sakaue ⇄ Honancho |
| Explicit relationship to `Marunouchi` | **None** — no parent, branch, part-of, or connection field in the Railway payload; the relation is inferable only from the `Mb` ⊃ `M` code family, shared colour, and one shared station title (Nakano-sakaue; branch station IDs are branch-namespaced, so ID overlap is 0) |
| Separate static GTFS route | **No.** The three branch-only stations exist in `stops.txt` with `stop_code` `Mb03`–`Mb05` and, with the interchange (`M06`), are served exclusively by the single static 丸ノ内線 route; 658 of that route's 1,533 trips touch an `Mb` stop (2–23 stops per trip; headsigns include branch and main-line termini), i.e. the static feed models branch stops and branch-touching trips **inside the one Marunouchi route** |
| 9 static routes vs 10 Railway records | **Explained** by this branch representation |
| Normalization to the main Marunouchi product line | **PARTIALLY SUPPORTED — official-field derivation; no explicit provider relationship.** Branch TrainInformation may be attached to the Marunouchi product line via `Mb`→`M`, stop-code scope, and colour, **retaining** `odpt.Railway:TokyoMetro.MarunouchiBranch` as source provenance and the `Mb` stop scope. Whether a branch-only status applies to main-line-only legs is a product rule for a later implementation phase, not a payload fact. The branch must not be collapsed on name similarity alone |

#### 6.2.5 Localization (B6B/B6C)

| Content layer | JA | EN | KO | Ownership / interpretation |
|---|---|---|---|---|
| Static route titles | 9/9 | 9/9 | 0/9 — absent | provider JA/EN inputs; TSUGINO owns reviewed canonical data |
| Static canonical station names (144) | 144/144 | 144/144 | 0/144 — absent | provider JA/EN inputs; TSUGINO owns Korean and aliases |
| Static distinct trip headsigns (93) | 93/93 | 93/93 | 0/93 — absent | Korean project-owned |
| Static agency name | present | present | absent | — |
| Railway titles (10) | 10/10 | 10/10 | **9/10** | Korean is a provider **input** for nine lines; `MarunouchiBranch` missing; review required |
| Railway station-order titles (all ten orders) | observed complete | observed complete | observed complete | provider input; must be reconciled with static station identity before use |
| TrainInformation text | present | absent | absent | dynamic status text Japanese-only in the retained snapshot |
| Alert text | no entity in retained snapshot | unobserved | unobserved | earlier transient incident Japanese-only; broader behaviour pending |

`translations.txt`: 494 rows (ja 247 / en 247 / ko 0), tables agency/routes/stops/trips, field-value keyed; duplicates 0, conflicts 0, empty 0, unresolved sources 0; all `ja` rows equal their source value. Normalization findings: flat hierarchy (no parents/platforms); duplicate per-line station rows at interchanges (32 name groups); provider line-code aliases from `stop_code` letters (and `Mb` for the branch); English ASCII-only, 54 hyphenated names (53 lowercase-after-hyphen, one uppercase — identical in static and Railway station titles); Japanese 0 NFKC-sensitive, 0 whitespace, 0 parentheses, 0 small ヶ / 4 full-size ケ — the cross-operator orthographic variant **市ヶ谷 (Toei) vs 市ケ谷 (Tokyo Metro)** is not unified by NFKC; 27 exact JA+EN cross-operator name-match candidates with Toei (candidates only). Provider strings cannot be the sole cross-operator identity key.

Interpretation (DEC-041, DEC-042, ARCHITECTURE §5.1/§5.2/§39.1/§40): provider Japanese and English are inputs to canonical localization; **static GTFS Korean remains absent**; provider Korean Railway strings may seed project review but do not replace TSUGINO canonical ownership; Korean route/station/headsign canonical data and search aliases remain project-owned; dynamic incident/status translation is a separate, unresolved problem independent of static-title localization; this audit creates no translations. The earlier "no Korean from Tokyo Metro" reading is corrected to this layered statement.

#### 6.2.6 End-to-end degraded-path mapping verdict and limitations

| Link | Classification | Evidence |
|---|---|---|
| TrainInformation `odpt:railway` → Railway record | **DIRECT**, 10/10 (0 missing, 0 duplicate) | retained B6C snapshots |
| Alert `informed_entity.route_id` → static route | **DIRECT** in the one earlier B6B entity observation (1/1); **not re-observed** in the retained zero-entity B6C snapshot | B6B transient (not retained) |
| Static route → Railway record | **DERIVABLE_FROM_OFFICIAL_FIELDS**, 9/9 | §6.2.3 |
| Alert route → TrainInformation railway | **DERIVABLE_FROM_OFFICIAL_FIELDS** (route_id → static route → lineCode/title → Railway ID); no shared direct identifier | §6.2.3 |
| `MarunouchiBranch` → main product line | **PARTIALLY SUPPORTED** | §6.2.4 |
| **Overall** | **PASS WITH LIMITATIONS** — not an unqualified VERIFIED_PAYLOAD for the whole path | |

Bounded product conclusion (evidence only; behaviour is defined by FEATURES §10.3, DEC-022, DEC-024, DEC-038, DEC-046): static route/station/schedule information is available; verified line-level status and Alert information may supplement it **with provenance**; no TripUpdate/VehiclePosition capability is established; no vehicle location, current stop, live progression, or delay precision may be synthesized; schedule must not be presented as realtime; Japanese-only incident text must not be represented as provider-supplied English or Korean; unsupported live affordances degrade independently; a Live Activity may start only when its displayed provenance is truthful. DEC-046 is used as the degraded-mode model only. DEC-004 remains Provisional; no provider is selected.

Limitations: single retained snapshot per feed in a normal-operations state; no disruption-state status/Alert observed with retained evidence; Alert entity semantics rest on one non-retained observation; the Alert–Railway link has no shared identifier; the branch relationship is a derivation; the protobuf decode used a hand-encoded canonical field map; Railway Korean titles unreviewed and absent for the branch; image/line-colour Specific Terms unread (A7); through-service continuity, timetable-revision stability, cadence, uptime, rate limits, and commercial/production terms untested. No SLA, cadence, uptime, incident-completeness, commercial, or production-readiness claim is made.

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
| Realtime position model is trip-progress / stop-sequence based (GTFS-RT TripUpdate) — GPS-free journey tracking possible (DEC-006) | VERIFIED_PAYLOAD (Toei, 7 snapshots, one evening): TripUpdate stop-time updates and VehiclePosition `current_stop_sequence` populated and resolvable to static stops in every snapshot (§6.1.1, §6.1.2); field population under disruption PENDING_PAYLOAD_VERIFICATION |
| Station titles JP/EN (GTFS `stops.txt` translations, or ODPT JSON `odpt:stationTitle`); KO coverage | Toei GTFS: VERIFIED_PAYLOAD (1 static snapshot, §6.1.3) — JA and EN 141/141 canonical station names and 6/6 route names via `translations.txt`; **Korean 0** → project-owned. Tokyo Metro GTFS: VERIFIED_PAYLOAD (1 retained archive, §6.2.5) — JA/EN 144/144 station names, 9/9 route names, 93/93 headsigns; Korean 0. Tokyo Metro ODPT JSON `odpt:Railway` titles and station-order `odpt:stationTitle`: VERIFIED_PAYLOAD (1 retained snapshot) — Korean present for 9/10 railway titles and observed in all station orders; provider input requiring review, not canonical. Other operators: PENDING_PAYLOAD_VERIFICATION (A4) |
| Access token required for API (all tiers) | VERIFIED_LICENSE_TEXT (S1, S5) |

### 8.2 GTFS / GTFS-RT as the first adapter format

Given §4.1, the only production-license-viable trip-level realtime in Tokyo core (Toei) is **GTFS-RT**, not ODPT-native JSON. This **changes the leaning recorded in the previous revision**: the first realtime adapter should target **GTFS static + GTFS-RT**, with ODPT JSON (train status, station titles) as a secondary adapter. `RealtimeSnapshot` (ARCH §8.2) already isolates this. Consequence for Phase 4: a protobuf decoder is needed **without third-party dependency** in Phase 0 (dependency-free baseline) — Phase 4 may revisit under Rule 34 / AGENTS §31 with justification. B2 demonstrated that the Toei feeds decode cleanly against the canonical schema with temporary external research tooling, and B6C decoded the Tokyo Metro Alert header with a hand-encoded canonical field map (RK-11); the production decoder design and any dependency decision remain open. For Tokyo Metro the ODPT JSON layer (`odpt:Railway`, `odpt:TrainInformation`) is not secondary in the same sense: it is the only status source and the direct key space for line-level status (§6.2), so the secondary adapter must be planned alongside the GTFS-RT adapter.

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
| DS-01 | ODPT — Toei rail static (GTFS, GTFS-Pathways, train timetable) | N2, N5 | VERIFIED_CATALOG | CC BY 4.0 | VERIFIED_LICENSE_TEXT (§3.5) | **VERIFIED_PAYLOAD (GTFS Static structure, 1 archive 2026-09-18, §6.1.1; its references resolved from all 7 realtime snapshots, §6.1.2; route identity and JA/EN localization coverage complete, Korean absent, §6.1.3)**; GTFS-Pathways and train timetable JSON still PENDING_PAYLOAD_VERIFICATION | N/A (open data); API token due-care | none in license (irrevocable); ODPT provision may change (S5) | production-license-viable, static only (Toei static datasets) | Not yet production-eligible (longer-window sampling, attribution/notice implementation pending) | ckan.odpt.org `train-toei`, `r_train_timetable-toei`; S4; 2026-09-17; B1 2026-09-18; B3 2026-09-18 |
| DS-02 | ODPT — Toei GTFS-RT TripUpdate + VehiclePosition + Alert | N3, N4 | VERIFIED_CATALOG | CC BY 4.0 | VERIFIED_LICENSE_TEXT (§3.5) | **VERIFIED_PAYLOAD (TripUpdate/VehiclePosition `trip_id` integrity and cross-feed join for Toei Subway and Tokyo Sakura Tram, 7 snapshots during one evening 2026-09-18 — B2 ×1 + B3 ×6 at ≈5-min spacing, §6.1.1, §6.1.2)**; TripUpdate/VehiclePosition scope excludes the Nippori-Toneri Liner and Alert includes it — VERIFIED_CATALOG (B5, §6.1.4); Alert content (incl. Liner identifiers), longer-window cadence, coverage over time PENDING_PAYLOAD_VERIFICATION | N/A | as DS-01 | production-license-viable — trip-level realtime for subway and tram; alerts-level for the Liner | Not yet production-eligible (multi-window sampling, Alert observation, Liner degraded-mode definition pending) | `r_train_gtfs_rt-odpt_train-toei`; 2026-09-17; B2 2026-09-18; B3 2026-09-18; B5 2026-09-18 |
| DS-03 | ODPT — Tokyo Metro rail static (GTFS, station, route, timetables, fare) | N2, N5 | VERIFIED_CATALOG (B6A: all ten datasets, Basic License) | Basic License | VERIFIED_LICENSE_TEXT (§3.2) | **VERIFIED_PAYLOAD (GTFS Static structure, 1 retained archive 2026-09-18 — B6B observed, B6C reproduced bit-for-bit; JA/EN localization complete, Korean absent, §6.2.2, §6.2.5)**; **VERIFIED_PAYLOAD (`odpt:Railway`, 1 retained snapshot: 10 records, line codes incl. `Mb`, Korean titles 9/10, §6.2.2)**; static ↔ Railway mapping DERIVABLE_FROM_OFFICIAL_FIELDS 9/9 (§6.2.3); station, station/train timetable, fare JSON PENDING_PAYLOAD_VERIFICATION | N/A; registration; guideline freshness | may be terminated at any time (Art. 13(2)); delete on termination (retained research payloads included) | production-license-viable, static only | Not yet production-eligible (repeated snapshots, attribution/notice implementation, image Specific Terms pending) | `train-tokyometro`, `r_route-tokyometro`, `r_station-tokyometro`; 2026-09-17; B6A/B6B/B6C 2026-09-18 |
| DS-04 | ODPT — Tokyo Metro GTFS-RT Alert + Train status JSON | N3 (alerts) | VERIFIED_CATALOG (B6A: Alert is the sole realtime resource) | Basic License | VERIFIED_LICENSE_TEXT | **`odpt:TrainInformation` VERIFIED_PAYLOAD (1 retained snapshot: line-level status, 10/10 Railway IDs direct, Japanese-only text; no vehicle/trip/position/delay fields, §6.2.2)**; **Alert transport/framing VERIFIED_PAYLOAD (retained B6C snapshot header-only)**; Alert entity semantics PENDING_PAYLOAD_VERIFICATION — one B6B entity resolved 1/1 to a static route but its raw payload was not retained; disruption-state behaviour, cause/effect variety, active periods, language across incidents, cadence, coverage unobserved | N/A | as DS-03 | production-license-viable, alerts only (status/Alert are not vehicle progress) | Not yet production-eligible (disruption-state sampling, Alert semantics, attribution/notice pending) | `r_train_gtfs_rt-odpt_train-tokyometro`, `r_train_status-tokyometro`; B6B/B6C 2026-09-18 |
| DS-05 | ODPT — Tokyo Metro TripUpdate / VehiclePosition (and `odpt:Train` location) | N3, N4 | UNAVAILABLE_IN_AUDITED_CATALOG (re-checked by B6A catalog-wide search, 2026-09-18) | — | — | — | — | — | — | Not found; capability limitation, not a transport failure; periodic re-check (A1) | 2026-09-17; B6A 2026-09-18 |
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
| RK-1 | Route provider and Toei GTFS-RT share no deterministic join key (N4) | Core promise weakened | **Partially reduced:** Toei static ↔ TripUpdate ↔ VehiclePosition `trip_id` join VERIFIED_PAYLOAD across 7 snapshots of one evening (§6.1.1, §6.1.2) — short-window temporal uncertainty for the exact-`trip_id` path is reduced. **Still open (RK-1 remains open globally):** route-provider ↔ GTFS `trip_id` identity (§10), missing-`trip_id` fallback, route R5, other providers, degraded/fallback behaviour, longer-duration/multi-day behaviour — PENDING_PAYLOAD_VERIFICATION | selected trip stored separately (ARCH §11); recovery (DEC-031) | A2, A3 (multi-window sampling if required by the decision gate) |
| RK-2 | **Private railways + JR East are Challenge-entry only / production-blocked** → unavailable for production; Tokyo-core trip-level realtime = Toei only | Launch coverage materially narrower than "Tokyo" implies | VERIFIED_CATALOG + VERIFIED_LICENSE_TEXT | DEC-001 "as many as reliably supported"; capability model (DEC-022); degraded modes | Product decision at Decision Gate; A6 for operator-direct |
| RK-3 | Tokyo Metro has no trip-level realtime in the audited catalog | Largest subway operator in degraded mode | UNAVAILABLE_IN_AUDITED_CATALOG (B6A re-check). **Degraded path payload-supported — PASS WITH LIMITATIONS (B6B/B6C, §6.2):** static GTFS, `odpt:Railway`, and `odpt:TrainInformation` VERIFIED_PAYLOAD (one retained snapshot each); Alert framing verified, entity semantics from one non-retained observation; no synthetic progression permitted | per-service capability model (DEC-022); degraded mode (FEATURES §10.3, DEC-024, DEC-038); honest degraded-mode model (DEC-046) | A1 periodic re-check; disruption-state sampling (A3); degraded-mode UI in later phases |
| RK-4 | Challenge data leaks into production/fixtures; or evaluation use without Challenge entry | License breach (S3 Art. 4(1), 13(3)) | VERIFIED_LICENSE_TEXT | §7 rule; DEC-037; Rule 40 | registry discipline |
| RK-5 | Basic License termination at any time (Art. 13(2)) / data change (Art. 4(5)) | Degradation without notice | VERIFIED_LICENSE_TEXT | graceful degradation (ARCH §52); versioned static data (DEC-029) | architecture |
| RK-6 | Guideline freshness rules (`dct:valid`, `odpt:frequency`, 1-week static update) constrain caching design | Cache TTLs must follow feed metadata | VERIFIED_LICENSE_TEXT | per-category TTL (ARCH §18); freshness (DEC-024) | Phase 4 design |
| RK-7 | Route provider forbids caching / re-display | Network cost | PENDING_COMMERCIAL_CONFIRMATION | ARCH §18 tolerates "no cache" | A2 |
| RK-8 | Through service split by provider or unsupported at Group B / Challenge boundary | DEC-009 violation | PENDING / Group B | adapter continuity (Phase 3) | A3, A6 |
| RK-9 | Korean names absent from feeds | Extra dataset work | **Confirmed for Toei** — VERIFIED_PAYLOAD (1 static snapshot, §6.1.3): `translations.txt` carries Japanese and English only (route names 6/6, station names 141/141, headsigns 54/54 in JA/EN; Korean 0). Korean canonical display names and Korean search aliases are project-owned per DEC-041/DEC-042; provider JA/EN strings are inputs, not the sole source of truth. **Tokyo Metro (B6B/B6C, §6.2.5): layered** — static GTFS Korean absent (route 0/9, station 0/144, headsign 0/93); `odpt:Railway` Korean titles present 9/10 (branch missing) and station-order titles observed complete → provider inputs requiring review, not canonical; dynamic status text Japanese-only. Other operators: PENDING_PAYLOAD_VERIFICATION | canonical localization (DEC-042); project-owned Korean dataset created and reviewed during implementation | A4 (other operators); implementation phase for the Korean dataset |
| RK-10 | Numeric rate limits unknown (S5 Art. 4(4) discretionary) | Refresh cadence risk | PENDING_PAYLOAD_VERIFICATION (B1 one request per resource; B3 18 requests at ≈5-min spacing — no limit behaviour observed, which says nothing about limits at product refresh rates) | `RealtimeRefreshPolicy` (ARCH §20) | A1, A3 |
| RK-11 | GTFS-RT protobuf decoding needed without dependency | Implementation cost | design constraint — **decoding feasibility demonstrated** (B2, reconfirmed on all 18 B3 payloads): the Toei feeds decode against the canonical schema with no unknown fields using temporary external research tooling. This does not endorse a handwritten parser in the app; the production decoder design and dependency decision remain open. B6C decoded the Tokyo Metro Alert header with a hand-encoded canonical field map (no `.proto` re-fetched) — research tooling only | Rule 14, Rule 34 | Phase 4 |
| RK-12 | No car/door dataset | Feature omitted at most stations | UNAVAILABLE_IN_AUDITED_CATALOG | DEC-019 | accepted |
| RK-13 | Nippori-Toneri Liner has **no trip-level realtime** in the current audited Toei GTFS-RT TripUpdate/VehiclePosition resources — **EXPLICITLY EXCLUDED** by official documentation (B5, §6.1.4); the B4 `NOT SCHEDULE-EXPLAINED` finding and the observed 0/7 are thereby explained (not a payload defect). Liner remains covered by static GTFS, timetable, train status, and GTFS-RT Alert in the catalog | Product-capability / degraded-mode question, not a suspected data defect: one Toei service has schedule + Alert/status information but no TripUpdate/VehiclePosition | VERIFIED_CATALOG (exclusion/inclusion wording); Liner Alert/status payload semantics PENDING_PAYLOAD_VERIFICATION | per-service capability model (DEC-022); degraded mode (FEATURES §10.3); no synthetic progress; unavailable capability shown honestly | **Product scope decided — DEC-046 (2026-09-18): the Liner is in v1 scope in honest degraded mode (accepted product inclusion; not a provider selection).** Open until: (1) degraded-mode UI / Live Activity behaviour is implemented per DEC-046; (2) Liner Alert/status identifiers and semantics are observed or verified; (3) the capability model represents per-service availability honestly |
| RK-14 | Tokyo Metro static route ↔ `odpt:Railway` identity is **derived** (no shared cross-identifier), and `MarunouchiBranch` has no explicit provider parent relation while the static feed models the branch inside the single Marunouchi route (§6.2.3–§6.2.4) | A project-owned mapping table must carry the derivation; a wrong or stale derivation would attach status to the wrong line; branch-only status display scope is undefined | VERIFIED_PAYLOAD (one snapshot each): DERIVABLE_FROM_OFFICIAL_FIELDS 9/9 on lineCode + stop-code prefix + JA/EN titles + colour; branch PARTIALLY SUPPORTED | canonical ID mapping tables (DEC-021, Rule 9); provenance retained per record (`MarunouchiBranch` kept as source ID with `Mb` scope) | re-verify on static/Railway revision; branch/main display-scope product rule in the degraded-mode implementation phase |

---

## 13. Verification Actions Before the Phase 0 Decision Gate

These are verification actions, not implementation: no code, SDK, or dependency enters the app target, and Challenge-entry-only data is not touched (§7). Inspection tooling stays outside the repository unless explicitly approved.

| # | Action | Closes | Output |
|---|---|---|---|
| A1 | Register ODPT developer account (Basic License tier only; **no Challenge token**); confirm S1–S6 unchanged; record any Specific Terms attached to DS-03/04/08/09; re-check catalog for Tokyo Metro TU/VP. **Progress (2026-09-18, B6A):** Tokyo Metro catalog re-checked — TU/VP/`odpt:Train` not found; image dataset Specific Terms noted (A7). **Remaining:** portal-side term check, numeric rate limits, periodic TU/VP re-check | RK-3, RK-10 (portal-side); DS-05 | §4.1, §9 updated |
| A2 | Obtain evaluation access to ≥2 of DS-11..13; confirm pricing, SLA, App Store consumer use, caching, re-display, termination | PENDING_COMMERCIAL_CONFIRMATION; RK-7 | §10 filled |
| A3 | **N4 join test on Toei (CC BY 4.0):** capture static GTFS + GTFS-RT TripUpdate/VehiclePosition/Alert for ~10 routes incl. one 直通 pattern, one express pattern, one Toei↔Tokyo Metro transfer; verify `trip_id` referential integrity, freshness (`header.timestamp`), coverage, rate behavior. Repeat static + Alert on Tokyo Metro (Basic License; degraded path). Optionally full path on Yokohama Municipal Subway (Basic License) for a second fixture set, kept internal and deletable. **Progress (2026-09-18):** Toei single-snapshot capture and join proof done (B1/B2, §6.1.1) — PASS WITH LIMITATIONS; six-snapshot short temporal study done (B3, §6.1.2) — PASS WITH LIMITATIONS. **Remaining:** observe Liner Alert/status identifiers and implement degraded mode per DEC-046 (RK-13 — publication scope resolved by B5, §6.1.4; product scope decided by DEC-046); a later multi-window or multi-day observation if required by the decision gate; real Alert-content observation when naturally available; targeted VehiclePosition `current_status` investigation; 直通/through-service assessment; language-field coverage analysis (A4); commercial confirmation (A2); Yokohama optional. **Tokyo Metro degraded path (2026-09-18, B6A/B6B/B6C, §6.2): PASS WITH LIMITATIONS** — static, Railway, and TrainInformation payload-verified from retained snapshots; static ↔ Railway derivable 9/9; TrainInformation → Railway direct 10/10; Alert framing verified, one non-retained entity observation. **Remaining for Tokyo Metro:** disruption-state Alert/status sampling with retained evidence; Alert semantics and localization across incidents; branch/main display-scope product rule; longer-window cadence/uptime evidence if the gate requires it; through-service continuity | PENDING_PAYLOAD_VERIFICATION for DS-01..04, 09; RK-1 | findings + fixtures (documentation, not app code) |
| A4 | Sample station names for Toei / Tokyo Metro / Basic-License operators; measure JP/EN/KO coverage. **Progress (2026-09-18, B4):** Toei done — JA/EN 141/141 station names, 6/6 route names, 54/54 headsigns; Korean 0 (§6.1.3). **Progress (2026-09-18, B6B/B6C):** Tokyo Metro done — static JA/EN 144/144 station names, 9/9 route names, 93/93 headsigns, Korean 0; `odpt:Railway` Korean titles 9/10 and station-order titles observed (provider input, review required) (§6.2.5); 27 exact JA+EN cross-operator name-match candidates with Toei plus one orthographic variant (市ヶ谷/市ケ谷) — candidates only. **Remaining:** other Basic-License operators; cross-operator canonical station identity test using station codes/topology; reviewed project-owned Korean dataset and aliases | RK-9 | coverage table |
| A5 | Confirm whether any provider exposes car/door/transfer-time data with a license permitting display | RK-12 | §11 note |
| A6 | Operator-direct investigation for Group B and for the Challenge-licensed private railways' own developer programs (if any) | DS-10; RK-2 | rows updated; none moved to "no API" without evidence |
| A7 | Read operator image/line-color usage conditions (e.g. Tokyo Metro image data conditions in S2 Specific Terms; B6A confirmed the `r_image-tokyometro` dataset bundles its own terms PDF — not yet read) | DS-14 | note for Phase 7 tokens |

---

## 14. Decision Gate Inputs (ROADMAP Phase 0)

| Gate item | Position | Blocking? |
|---|---|---|
| Deployment target | **Decided: iOS 18.0 minimum, iPhone only (DEC-045, DEC-044)** | No |
| Primary route-search provider direction | **Open** — DEC-004 Provisional; requires A2 + A3 | Yes — before Phase 3 |
| Primary realtime provider direction | **ODPT platform, GTFS static + GTFS-RT as first adapter format**; Toei Subway + Tokyo Sakura Tram = trip-level realtime proof path (**join proof passed with limitations across seven snapshots of one evening, §6.1.1–§6.1.2**); Nippori-Toneri Liner = alerts/status-level degraded case (**explicitly excluded from TripUpdate/VehiclePosition, §6.1.4**); Tokyo Metro = degraded proof (**PASS WITH LIMITATIONS, §6.2**: static + `odpt:Railway` + `odpt:TrainInformation` payload-verified from retained snapshots, Alert framing verified, no TripUpdate/VehiclePosition in the audited catalog; status/Alert are not vehicle progress). Production direction still requires the remaining A3 work; no provider is selected | Yes — before Phase 4 |
| Canonical ID strategy | Decided (DEC-021, Rule 9) | No |
| Licensing viability for initial Tokyo scope | **License text verified (§3).** Production-license-viable: Toei (CC BY 4.0 — trip-level realtime for Toei Subway and Tokyo Sakura Tram; alerts/status-level for the Nippori-Toneri Liner, §6.1.4); Tokyo Metro / TWR / MIR / Tama Monorail (Basic License, alerts only); Yurikamome (Basic License, static only); Yokohama (Basic License, full realtime, fixture-only scope). **Challenge-entry only / production-blocked:** JR East and the seven Challenge-licensed private railways. **Product decision needed:** whether a Toei-subway/tram-trip-level-realtime + Metro-degraded launch scope is acceptable (RK-2); Liner-degraded inclusion already accepted (DEC-046, RK-13) | Yes — product decision |

The Xcode bootstrap (Track A of `PHASE_0_SCOPE_LOCK.md`) does not depend on the open items. Phase 0 *exit* requires the remaining A3 work and the RK-2 product decision.

---

## 15. Conflicts With Living Documents

Checked against all eight living documents. **No conflict found.** Observations that may warrant *future* document changes (not made here):

- `PRODUCT.md` §6 / DEC-001 "as many Tokyo-area lines as can be supported reliably through legally usable … data" already accommodates RK-2, but `PRODUCT.md` §23 lists "JR East production-grade support" as long-term direction only — consistent. If the Decision Gate narrows the launch scope to Toei + Basic-License operators, `ROADMAP.md` Phase 14 test matrix and `PRODUCT.md` §19 should be re-read for implied JR East / private-railway coverage.
- `ARCHITECTURE.md` §8.3 example shows "ODPT JSON → DTO → Adapter"; §8.2 finding that Tokyo trip-level realtime is GTFS-RT protobuf is compatible (both are named in §8.1), but Phase 4 should list GTFS-RT first.
- iPhone-only / iOS 18.0, DEC-004 Provisional, no dependency, DEC-006, DEC-041/042, DEC-019, FEATURES §14/§17: all consistent.
- `ROADMAP.md` Phase 11 task rationale reads "provider feeds carry no Korean". After B6C this is precise for the audited **static GTFS** feeds (Toei, Tokyo Metro) but not for the Tokyo Metro `odpt:Railway` JSON, which carries Korean titles for 9/10 lines and in station orders (§6.2.5). The task itself (project-owned Korean names and aliases) remains correct under DEC-041/042; a future wording refinement of that parenthetical is warranted (not made here).

---

## 16. Maintenance

- Update in place when A1–A7 produce evidence; record evidence + date (B1/B2 Toei payload evidence recorded 2026-09-18, §2.3, §6.1.1; B3 temporal sampling recorded 2026-09-18, §6.1.2; B4 static route/localization audit recorded 2026-09-18, §6.1.3; B5 official-documentation audit recorded 2026-09-18, §6.1.4; Tokyo Metro B6A catalog audit, B6B first payload observation, and B6C persistent recapture + Railway mapping audit recorded 2026-09-18, §2.4, §6.2).
- Retained Tokyo Metro research payloads live outside the repository under Basic License Art. 8(4)/13(3) obligations; delete them on supersession or termination and never commit them.
- Re-verify S1–S6 if ODPT announces changes (S2 Art. 13(4), S3 Art. 13(4)); re-check the Challenge end date if the Challenge is extended.
- When a provider direction is decided, record it in `DECISIONS.md` and revise `PRODUCT.md` §9–§10 / `ROADMAP.md` Phase 3–4 if scope changes.
- Do not create versioned or dated copies of this file.
