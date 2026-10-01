# Phase 3 provider evidence gaps against DEC-076

**Owner direction update (2026-10-01, after this research): commercial-provider evaluation/contact is paused.** Assess ODPT-first internal computation before pursuing these candidates; see [internal feasibility](PHASE_3_INTERNAL_ROUTING_FEASIBILITY.md) and DEC-077 (Accepted evaluation priority only). The research and conditional shortlist below are preserved as dated comparison evidence, not the current next-task recommendation. No provider has been selected.

**Date:** 2026-10-01\
**Status:** Public-document assessment added; evaluation remains proposed\
**Original repository-only assessment baseline:** `phase/03-route-search`, HEAD and fetched upstream `f792af2a1c11f8c09d544f46acb764deb9896d88`; clean starting tree; local/fetched main `e8a463d51f14b3cb1027960c63244b694579a71b`.

Current official findings and proposed next steps are in **Official public-document update — 2026-10-01** below. The original repository-only assessment is preserved as dated history. The research began with this document and ROADMAP already modified; fetched refs still match the baseline.

## Historical repository-only scope and reading rules

This assessment compares Ekispert, NAVITIME and Jorudan against Accepted DEC-076.
It adds no decision, provider ranking/selection, access permission or implementation.
Only repository records were read. No external page, account, payload, private
artifact, credential or device was accessed; no test/build was run. Git fetch was
used solely to verify the repository baseline.

The owner's free-app / low-operating-cost preference is an evaluation constraint,
not a new pricing claim, spending authorization or change to product monetization.
A free consumer app does not imply free API use or permission for commercial app
redistribution. Trial/evaluation permission is not production permission.

Statuses apply to **compatibility evidence**, not provider reputation:

- **Verified within stated limits (V):** recorded evidence supports a precisely bounded claim, with date/source limitations. Historical observations are not newly verified current facts.
- **Documented claim only (D):** a recorded claim/assumption lacks demonstrated compatibility. An audit assumption is explicitly identified as such, not attributed to the vendor.
- **Unknown (U):** repository evidence does not establish the requirement. This does not mean the feature is absent.
- **Demonstrated conflict (C):** recorded evidence contradicts a specific requirement. No such commercial-provider conflict is established here.

There is no V commercial-provider compatibility finding in this matrix. Similar
unknown statuses do not establish equivalent features, price or suitability.

## Evidence ledger and accepted constraints

References below are exact repository sections/row labels. They are the evidence
locators used in every provider cell; no external source was revalidated.

| Ref | Repository locator | What the record establishes, and its limit |
|---|---|---|
| E | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) §9, **DS-11** | Ekispert Web Service is a candidate only; payload and commercial confirmation pending; evidence cell is “—”. No API contract or observed route response is established. |
| N | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) §9, **DS-12** | NAVITIME API is a candidate only; same pending statuses and empty evidence locator. “Maybe N6” is not verified guidance coverage. |
| J | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) §9, **DS-13** | Jorudan route-search API is a candidate only; same pending statuses and empty evidence locator. |
| M | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§10**, criterion rows | Route legs/times, recurring identity join, through continuity, EN/KO and guidance are pending payload verification; trial and commercial terms pending. “Own station ID scheme → mapping: assumed yes” is an audit assumption for each candidate, not verified vendor documentation or stability evidence. |
| A2 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§14, A2** | Proposed evaluation access to at least two DS-11–13 candidates and commercial confirmation. This is recorded future work, not permission to open accounts, accept terms or contact providers now. |
| H1 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§2.3, §6.1.1–6.1.3, DS-01/02** | Historical Toei static/realtime joins and language observations: seven realtime snapshots during one evening on 2026-09-18, plus the recorded static snapshot. Supports only those source joins/observations, not a commercial route-provider join, current coverage, disruptions or SLA. |
| H2 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§2.4, §6.2, DS-03/04** | Historical Metro static/Railway/TrainInformation observations and degraded-path limitations. Not commercial route payloads or proof of train-level realtime compatibility. |
| H3 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§3.5–3.6, §3.12** | Recorded ODPT license analysis and open written questions, not commercial-provider rights. ODPT Q3/Q4 and applicable bundling questions stay with their deliverables; no current external terms check here. |
| H4 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§6.5–6.6, §11** | Historical canonical identity assessment; one Pathways snapshot covering twelve Ōedo stations, no cross-station-structure edges or cross-operator transfer proof. Neither same-name identity nor these limited paths prove a required route interchange/walk. |
| H5 | [Feasibility audit](PROVIDER_FEASIBILITY_AUDIT.md) **§6.8 (B11)** | 2026-09-23 analysis of two retained static archives does not establish service type/brand/fare/seating. Passenger-stop status requires per-feed verification; rows/patterns are insufficient. Private artifacts were not reopened for this assessment. |
| B | [ROADMAP](ROADMAP.md), **Phase 2 final audit and Phase 3 planning assessment**; [DECISIONS](DECISIONS.md), **DEC-074/075** | Accepted local provisional foundation: 258 stations, 15 lines, two operators; reviewed canonical names/aliases, mappings, topology and repository behavior. Not production registry adoption, shipping composition or canonical passenger-stop Trip acceptance. |

Accepted constraints from [DECISIONS](DECISIONS.md): DEC-047's launch set is the
13 subway lines plus Tokyo Sakura Tram and Nippori-Toneri Liner, with capability
tiers rather than universal realtime. DEC-004 remains Provisional. DEC-009 governs
through continuity; DEC-020/021 provider isolation/canonical identity; DEC-048 and
RULES Rule 53 prohibit identity/transfer inference from names/proximity. DEC-060/061
separate recurring passenger-stop Trips from topology and service labels;
DEC-062/064 preserve explicit selection/Journey ownership. DEC-068/073 retain
registry and transition controls. DEC-074/075 retain S9, timetable and delivery gates.
DEC-076 §§A–F supplies the request, admission, failure, time and evidence contract.

## Requirement/provider matrix

Each cell gives status and exact ledger locators. The proof statement, missing
proof, smallest resolution action and blocked deliverable in its row apply
**independently to each of the three named providers**; shared wording is used
because the recorded gaps are the same, not because their APIs are assumed equal.
“Not recorded” means the cited registry and comparison provide no supporting
proof; it is not a negative feature claim. Scenarios S1–S6 and questions EQ1–EQ4
below are proposals only.

Blocked-deliverable codes: **R** = real route-only admission/integration;
**T** = verified real TrainCandidate attachment; **G** = later realtime or imported
scheduled guidance; **EVAL** = authorized evaluation; **SHIP** = licensed delivery.
An optional feature gap may block only affected alternatives, not all R. No row
blocks this document or already approved wholly synthetic work.

| Requirement / DEC-076 reference | Ekispert | NAVITIME | Jorudan | Existing proof and missing proof | Smallest scenario/question to resolve | Blocks |
|---|---|---|---|---|---|---|
| Launch-route coverage (§B/C) | U: E, M | U: N, M | U: J, M | Candidate listing only. No verified coverage/product/version for the accepted 15-line launch set, including tram/Liner or unsupported through continuations. B describes our baseline, not theirs. | Public coverage/product list then S1 coverage checklist and S2 boundary route; distinguish train-only, paid add-ons and unsupported interiors. | R for affected routes; launch exit, SHIP |
| Exact station/line IDs and stability (§A2, B) | D/U: E, M | D/U: N, M | D/U: J, M | D only for audit's “assumed yes” station-ID scheme; exact bindings, line granularity, branch aliases, retirement/version policy and stability are U. | S1 exact IDs and distinct same-name endpoints; obtain ID/version/change policy, retain repeat observation across an identified revision. | R; T; production mappings |
| Continuous ride versus train change (§C/D) | U: E, M | U: N, M | U: J, M | §10 explicitly pending. No authoritative semantics for fragment joins or line/operator changes. | S2 plus S3; ask which explicit field/definition asserts stay aboard versus change train. | R for through/transfer alternatives |
| Same-station interchange (§D) | U: E; M guidance | U: N; M guidance | U: J; M guidance | No commercial interchange proof. H4 does not establish every relevant line-pair connection. | S3 same canonical station: itinerary change assertion plus reviewed line-pair interchange source; determine separate evidence ownership. | R for these transfers |
| Directional walking transfer (§D) | U: E; M guidance | U: N; M guidance | U: J; M guidance | No commercial exact-pair pedestrian evidence. H4's limited internal paths cannot be generalized. | S3 distinct station IDs and reverse-direction variant; request source/provenance and permitted use of directional link evidence. | R for these walks; later accessibility remains separate |
| Recurring-run / repeated-stop correspondence (§C/D) | U: E, M train-identity row | U: N, M train-identity row | U: J, M train-identity row | Explicitly pending. H1 joins ODPT sources to one another, not these providers. No reviewed run-key bridge, original visit index or revision compatibility established. | S4: request run-ID meaning/stability, dated-versus-recurring relation, occurrence disambiguation and join rights. Real canonical attachment only after S9. | T, then G; not independently evidenced route-only R |
| Absolute depart-not-before, precision, horizon (§A3–4) | U: E; M times | U: N; M times | U: J; M times | Generic times criterion is pending; absolute encoding, zone/offset, seconds/minute precision, rounding and search horizon not recorded. | S5: bound between minute ticks, equality, date crossing, outside horizon. Ask how to honor inclusive bound without silently changing intent. | R unless compatible intent proven; unsupported intent must fail explicitly |
| Qualified scheduled endpoints and incomplete times (§E) | U: E; M times | U: N; M times | U: J; M times | No date-qualified scheduled/realtime distinction or incomplete-time policy recorded. | S5: schedule provenance/zone/date fields; absent counterpart and missing-context variants from authorized examples. Validate known endpoints before omission, all >= bound, ordered across gaps; no invented date/rollover. | R admission for affected alternatives; not evidence of P3-T1 truth |
| Alternatives / genuine empty / malformed responses (§B) | U: E; M route-search row | U: N; M route-search row | U: J; M route-search row | No verified envelope, independent boundaries, truncation/pagination or zero-result semantics. | S1 alternatives plus S6 empty/shared error/delimited invalid option; request response-cap documentation. Preserve source order and omission accounting. | R and truthful failure behavior |
| Errors, quotas and cancellation (§A5–7, B) | U: E; M SLA | U: N; M SLA | U: J; M SLA | Error codes, limits, retry/billing and client cancellation behavior not recorded. Synthetic tests prove only our boundary. | S6 sanctioned examples/sandbox errors; ask EQ2/EQ4 about quotas and canceled charges. Verify local transport/owned-work cancellation separately; server-side cancellation is not required by DEC-076. Never induce a production outage/rate-limit storm. | R integration resilience; cost assessment, SHIP |
| JA/EN/KO / canonical localization (§C8) | U: E; M EN/KO row | U: N; M EN/KO row | U: J; M EN/KO row | Commercial EN/KO explicitly pending; no JA payload proof either. H1/H2 language observations and B reviewed names do not establish commercial language coverage/rights. | S1 stable IDs across language modes; ask EQ3 on fallback, re-display and using canonical project names. No real translations authored here. | Canonical display compatibility/SHIP; missing provider KO alone need not block R if licensed canonical resolution suffices |
| Evaluation access / permitted research | U: E, A2 | U: N, A2 | U: J, A2 | Trials/terms pending; no recorded authorization to use an account, capture or retain samples. | EQ1 trial eligibility, term, quotas, billing, sample retention and offline fixture rights before requests. | EVAL |
| Pricing / cost model | U: E; M pricing | U: N; M pricing | U: J; M pricing | No verified prices, free allowance, unit of billing, minimums or cancellation charges. | EQ2 compare fixed fee, per-query/result units, overage and hard caps for owner-supplied demand; include any server operations. | Affordable deployment choice; SHIP |
| Commercial use / attribution | U: E; M App Store use | U: N; M App Store use | U: J; M App Store use | No consumer iOS/free-app license, notices/branding, termination or app distribution terms confirmed. H3 cannot transfer rights. | EQ3 free consumer app use, attribution placement/languages, modifications, service interruption and termination. | SHIP; evaluation permission remains separate |
| Storage/cache and derived use | U: E; M caching/re-display | U: N; M caching/re-display | U: J; M caching/re-display | No TTL, deletion, offline/re-display, canonical mapping/derived-value retention, fixture sharing or ODPT combination rights confirmed. | EQ3 distinguish transient normalization, cache, recent journeys, mappings, derived route values and test artifacts; obtain item-specific limits. | EVAL retention, R design, T joins, SHIP |
| Credentials / direct iOS versus server | U: E; M access/terms | U: N; M access/terms | U: J; M access/terms | No verified commercial credential type, client restrictions, SDK requirement, IP allowlist or server requirement. Project credential protection is a constraint, not proof of a required backend. | EQ4 documented auth model, mobile distribution/key exposure policy, restrictions and revocation. Compare direct-client and relay feasibility only after terms/design evidence. | EVAL setup, R composition, operating-cost/SHIP decision |

## Smallest useful proposed evaluation set

First use official public documentation to eliminate avoidable access questions.
Then, only with separate authorization/rights, compare at least two candidates as
A2 proposes. Which two depends on those findings; this document selects none.
Reuse scenarios across requirements to avoid redundant requests. These six bundles
are **not six guaranteed API calls**: exact requests depend on the approved API,
limits and permitted sample reuse. They are not launch-wide coverage proof.

| Scenario | Proposed input/evidence to request | Assessment target and limits |
|---|---|---|
| S1 Direct + identity/localization | A direct ride in the accepted launch set; exact origin/destination and line IDs, bound, alternatives and language variants. Include a distinct same-name endpoint check. Obtain documented coverage for all 15 lines; spot checks must not become universal coverage claims. | Canonical-only route usability, exact mapping, coherent view, stable language-independent identities and envelope structure. No guessed mapping or Trip. |
| S2 Through service | A documented stay-on-board ride with a line change; include an operator boundary if it crosses the support boundary. Confirm explicit continuity and all ridden lines. | One rail ride despite fragments; unsupported interior omits the entire option. Through travel beyond accepted support is a rejection probe, not expansion approval. |
| S3 Genuine transfer | One same-station train change and one distinct-station pedestrian connection, with the exact reverse direction checked separately. | Separate train-change and line-pair/directional connection evidence. Names, coordinates and schedule gaps do not prove a walk or interchange. |
| S4 Identity/occurrence ambiguity | Provider-documented repeated-stop/loop or ambiguous run example, plus a subinterval and incomplete correspondence. Request semantic documentation if no suitable sample is available. | Separate a possible route from verified recurring-run/visit correspondence. Do not fabricate a “real” repeated-stop sample, mint a Trip or pick the first occurrence. Documentary join design can precede S9; real canonical Trip consumption cannot. |
| S5 Time boundaries | Depart bound between provider precision ticks; equality; absolute midnight crossing; outside horizon; scheduled versus realtime fields; a documented single-known-endpoint/missing-context response if available. | Can explicit request intent and all interpretable qualified ridden endpoints satisfy DEC-076 §E? Unqualified time text is not an absolute instant. Do not force unavailable variants or infer calendars. |
| S6 Outcomes/failures | Documented empty response, multiple alternatives, delimited unusable item versus shared malformed envelope, auth/quota/horizon errors, transport interruption and local cancellation. Prefer published samples or a sanctioned sandbox. | Honest failure categories, source accounting and cancellation ownership. Local synthetic negative cases remain synthetic; they cannot establish that a provider emits a particular failure or cancels server work/billing. |

For any future observation, record product/API version, observation date, scenario,
source locator, interpretation authority and retention permission; qualify one-shot
results narrowly. Stability needs documented version policy and repeated evidence,
not two identical responses mistaken for a guarantee. Payloads/credentials remain
outside Git under separately approved retention; permitted aggregate findings can
update this matrix. This task neither creates nor opens that storage.

## Rights and deployment questions

- **EQ1 — Evaluation:** Which product/plan may be evaluated for this intended app? Is account acceptance required; what expires, what costs money, and may responses be retained privately, decoded, compared and used as fixtures? What must be deleted and when?
- **EQ2 — Affordability:** What is the billing unit, minimum, free/trial allowance, quota, overage, hard spending cap and treatment of errors/canceled queries? What costs change with deployment, traffic and a relay? The owner should later supply expected searches per user/day, active-user bands and a monthly maximum; no numbers or current prices are invented here. Compare a zero-cache case if caching is forbidden. Free app distribution alone says nothing about API fees.
- **EQ3 — Rights:** Are production free consumer iOS use, canonical ID mapping, joining to separately licensed ODPT data, derived route values, canonical names, re-display, offline/recent-journey storage and private fixtures permitted? Specify attribution, marks, TTL, geographic/product limits, redistribution, revocation and deletion per artifact. Evaluation and production answers must be separate. No evaluation contract implies bundling or derived-database rights.
- **EQ4 — Credentials/deployment:** What secret/public-client credentials exist, where may they live, may an iOS client call directly, is a server relay mandated or merely an option, and what SDK/IP/rate restrictions apply? Can credentials be protected without embedding a secret in a distributable app? What are revocation, logging/data retention and canceled-request costs? RULES Rules 1/8/9/42 and ARCHITECTURE §43/§53 remain constraints. A server is not authorized or selected by this question.

## Consumer separation and retained gates

| Deliverable | What may be concluded / required next |
|---|---|
| This assessment and public-document comparison | No S9 dependency: no real Trip is consumed. Missing evidence is recorded, not guessed. |
| Real route-only candidate | Requires supported canonical anchors/lines, affirmative complete continuous-ride and transfer evidence, licensed mappings and request/time/error admission. Unresolved train correspondence is allowed; it confers no stop count, selected train or active Journey. Provider choice and bounded integration still need explicit authorization. |
| Real TrainCandidate | Requires P2-S9 first, accepted passenger-stop sequences without times, reviewed recurring-run/occurrence correspondence and coherent dataset identity. Move S9 earlier as soon as a proposed evaluation/integration would consume these canonical Trips, not merely because Phase 3 started. No side-door reconstruction from provider patterns. |
| Later realtime / scheduled guidance | A commercial train join is not established by H1's historical ODPT join. Realtime evidence/Phase 4 and explicit selection/Phase 5 remain separate. Provider scheduled context is not imported timetable truth or current train position. P3-T1 semantic acceptance, import/data compatibility and consumer binding remain prerequisites for imported schedules; S9 precedes real import. |
| Production registry, delivery and publication | DEC-068 §F1, DEC-073 and DEC-074/075 remain intact. Local foundation is not production ID adoption or shipping composition. Preserve applicable ODPT Q3 public mappings, Q4 translations and ODPT bundling/publication gates alongside separately established commercial-provider rights. |
| Expansion | P2-S10/Track A and DEC-058/059 evidence/eligibility remain required before capability/support promotion. A provider's broad catalog or a through-service sample does not expand the accepted launch set. |

## Recommended next bounded task and authorization boundary

Recommend **official public-document comparison only**, across all three candidates,
against the rows above, with a dated clause/source ledger and a proposed shortlist
for a later two-candidate evaluation. Prioritize production free-app rights,
cost/billing caps, retention/derived use and secure client feasibility before
spending on trial payload work. No repository evidence justifies choosing a winner
or rejecting a candidate today. Preserve A2's at-least-two comparison intent;
changing that evaluation breadth would require an explicit owner scope choice.

The exact next authorization requested would be: “Read the three candidates'
official publicly accessible API documentation, product/coverage pages, pricing and
terms for a documentation-only comparison. Record dated citations and unresolved
questions. No login/account creation, acceptance of terms, API queries (including
credential-free payload endpoints), downloads of datasets/SDKs, provider contact,
payment, credential access or implementation.” **Not authorized in this task.**

Later permissions must remain distinct:

| Access class | Separate authorization must name | Does not imply |
|---|---|---|
| Public-document research (recommended next) | Official public sites/document types and documentation-only scope above | Account use, endpoint experiments or contact |
| Evaluation-account access | Chosen candidates/product plans; existing versus new account; owner-approved trial terms, expiry and spending ceiling; credential storage responsibility | Production rights, billable API requests or blanket terms acceptance by an agent |
| Credentialed requests | Approved accounts/endpoints/scenarios, request/rate/monetary caps, allowed fields, retention location/TTL, deletion and permitted reporting; explicit permission to use credentials | Provider contact, publication, real canonical Trip consumption before S9, or deployment |
| Provider contact | Named recipients/channel and exact reviewed questions/messages, including EQ1–EQ4 and permission to send | Account enrollment, agreement acceptance, payment or integration |

Owner decisions proposed for later: authorize the public-document task; define a
monthly operating-cost ceiling/demand bands before paid evaluation; approve any
account/terms/contact scope; decide whether a backend is acceptable only if the
evidence makes that tradeoff concrete; select an integration provider through a
later explicit decision after sufficient evidence. None is accepted here, and no
new architecture, timetable policy or scope expansion is needed to finish this
assessment.

## Official public-document update — 2026-10-01

**Scope lock:** Phase 3; public-document assessment against Accepted DEC-076;
only this document and a minimal ROADMAP update. No contract acceptance or code.
The owner separately authorized this research after the repository-only assessment
above. That assessment and its authorization wording are historical, not the
current access boundary. Official HTML/PDF references were read; no API endpoint,
interactive API tester, account, private artifact or device was accessed. Published
examples are illustrative documentation, not observed responses, current datasets
or canonical Trip evidence. No provider content dataset is copied here.

All sources below were accessed **2026-10-01**. **D** means a published claim,
including published prices/terms, not executed compatibility. **U** means proof
remains missing. **C** below is a narrowly identified documented mismatch with an
assumed plan/use, not a finding that a provider cannot serve TSUGINO under any
contract. No new commercial compatibility **V** is asserted. Undated pages are
identified as such; access today does not make their examples current.

### Official source ledger

These locators supplement E/N/J/M above without refreshing historical ODPT evidence.
Section names identify supporting text even if the vendor later changes layout.

| Ref | Official source; product/version and supporting section | Bounded documented claim / limit |
|---|---|---|
| PE1 | [Plans](https://api-info.ekispert.com/plan/), Ekispert API; undated; plan comparison footnotes 1–2, pricing, contract FAQ | Free returns a result URL; request packs support average-wait search only. Cost details below. Neither is evidence of timetable-based DEC-076 intent. |
| PE2 | [Route search reference](https://docs.ekispert.com/v1/api/search/course/extreme.html), API v1 `search/course/extreme`; request parameters, response and examples | `key`, `viaList`, `date` YYYYMMDD, `time` HHMM, departure search; answer/search counts up to 20. Examples distinguish `onTimetable` and `average`, and show dated offset-bearing `Datetime`, route points, train/walk sections and engine/API versions. Examples do not settle absent-time, horizon, precision or rollover behavior. |
| PE3 | [Station codes](https://docs.ekispert.com/v1/dictionary/station-code/), v1 dictionary “駅コード” | Unique station codes; normally unchanged on renaming. Not an unconditional permanence/retirement policy or TSUGINO mapping. |
| PE4 | [Operation-line codes](https://docs.ekispert.com/v1/dictionary/operation-line-code/), v1 dictionary “運行路線コード” | Codes identify railway operating lines nationally; granularity versus canonical lines remains unevaluated. |
| PE5 | [Station states](https://docs.ekispert.com/v1/dictionary/station-state/), v1 dictionary table | Distinguishes normal, turnback, through-running (`extension`) and pass states. Does not authenticate a particular continuous ride. |
| PE6 | [Train codes](https://docs.ekispert.com/v1/dictionary/code-for-specifying-train/), v1 dictionary, both code families | Route-operation and timetable train codes are mutually incompatible, distinct from operation-line codes, and intended for short-term use rather than database retention. No canonical recurring-run or ODPT join follows. |
| PE7 | [FAQ](https://docs.ekispert.com/v1/faq/), Standard v1; language, timetable, access limits, billing, license display | EN/KO among optional languages. Timetable use needs separate operator licensing/fees. No fixed access limit stated, but concentrated load can be blocked. HTTP-200 requests billed; overage continues with fees. Provider says license display unnecessary; other rightsholder obligations still require review. |
| PE8 | [Standard terms](https://docs.ekispert.com/v1/WebService_TOS.pdf), revised 2025-12-15; Arts 1, 9, 17, 21, 26–27 | Written special terms can prevail. Application implies agreement. Key confidentiality; restrictions on secondary use/resale, railway-time retention/reuse and competing services. See conflict/clarification record below. No free-app or fixture exemption established. |
| PE9 | [Getting started](https://docs.ekispert.com/v1/get-started/guide/index.html), v1 §§1–2 | Access key issued on application; warns against public exposure. No verified distributable-iOS credential scheme or mandatory relay established. |
| PE10 | [API overview](https://docs.ekispert.com/v1/api/index.html), v1 “エラー”, “HTTPステータスコード” | HTTP status plus error envelope; 400/403/404/500 documented. Need route-specific genuine-empty semantics, not an inference from status alone. |
| PE11 | [Transfer means](https://docs.ekispert.com/v1/dictionary/change-means-type/), v1 dictionary | Boarding-position guidance has stairs/platform/passage and other categories. Category names alone do not prove directional station-pair connectivity. |
| PN1 | [API list and pricing](https://api-sdk.navitime.co.jp/api/specs/description/about_navitime_api.html), NAVITIME API 2.0; API list, direct-only options, pricing | Direct contract and marketplace differ; railway timetables/multilingual are direct-contract options. Route(totalnavi) and Transport are separately contracted marketplace products. Cost/access details below. |
| PN2 | [Route(totalnavi)](https://api-sdk.navitime.co.jp/api/specs/api_guide/route_transit.html), API 2.0 docs, `/v1/route_transit`; parameters and RouteSectionItem/Transport/Link/CallingAt | Node/line IDs; departure `start_time` with seconds; average/timetable modes; up to 10 alternatives. `next_transit` omitted for through/no-change/final movement; `walk` sections. Timetable-only `self_id`/`train_id`; calling-at endpoints and links; language-dependent names with Japanese fallback. Not recurring identity or continuity verification. |
| PN3 | [Input/output rules](https://api-sdk.navitime.co.jp/api/specs/description/about_io.html), API 2.0 “日付時刻の形式”, “ID・コード” | Specifies RFC3339 and references IANA time zones; preserve ID digits. Route examples omit offsets: accepted offset forms/default zone and boundary behavior need resolution before absolute admission. |
| PN4 | [Errors](https://api-sdk.navitime.co.jp/api/specs/description/about_error.html), API 2.0 status tables | 401 authentication, 429 rate limit; route-not-found and internal errors both illustrated as 500. HTTP status alone cannot distinguish canonical no-results from failure. Examples are not a stable exhaustive error taxonomy. |
| PN5 | [Direct terms](https://api-sdk.navitime.co.jp/api/specs/description/ntj_tou.html), revised 2022-12-06; Arts 3–6 | Application specifies use and permitted stored data, overriding conflicting general terms. Otherwise caching prohibited; preserve notices; guidance restriction and owned-point endpoint condition. Art 4 describes requests from customer's server; not proof of a mobile exception. |
| PN6 | [RapidAPI terms](https://api-sdk.navitime.co.jp/api/specs/description/rapid_tou.html), revised 2024-12-05; Arts 4–5 | Owned-point endpoint condition, caching prohibition, notice protection and guidance-use restriction. Do not transfer a direct-contract exception to marketplace use. API Hub-specific terms were not separately assessed. |
| PN7 | [Signature authentication](https://api-sdk.navitime.co.jp/api/specs/description/about_signature.html), API 2.0 “署名鍵”, “デジタル署名” | Per-client secret signing key; keep secret and out of requests/public website storage. Source restrictions can replace signatures; generation details supplied during evaluation. Direct-iOS admissibility remains U. |
| PN8 | [Route-slide implementation](https://api-sdk.navitime.co.jp/api/specs/tips/route_slide_impl.html), API 2.0 opening prerequisite; [route-slide reference](https://api-sdk.navitime.co.jp/api/specs/api_guide/route_slide.html), `train_id` parameter | Timetable option required; route-slide consumes a search `self_id` (first when multiple). This is an internal API relationship, not a cross-source or recurring-run correspondence. |
| PJ1 | [Biz API](https://biz.jorudan.co.jp/service/biz_api.html), advertised **Ver.2.0**, product overview/features, pricing/trial | XML/JSON, departure/arrival search, timetable connections and EN/ZH/KO advertised. Cloud engine hosting removes own engine administration, not necessarily an iOS relay. See price below; consumer-app feature pages are not evidence here. |
| PJ2 | [Open API specification](https://biz.jorudan.co.jp/file/norikae_openAPI.pdf), last listed revision 2018-07-04; §§2–3, station/line operations, §12 `sr`, §13 errors | Historical, distinct from Biz Ver.2.0: POST/JSON/access key, name-based station/line operations; `sr` documents date but no departure-time parameter. Sequential result ID is not a run ID. Empty/zero date/time examples and request/key/quota/search errors do not establish modern Biz semantics. |
| PJ3 | [Biz terms](https://biz.jorudan.co.jp/file/Biz_kiyaku_20200201.pdf), revised 2020-02-01; preamble, Arts 2–3, 6 | Japan-use grant under contracted conditions; no unspecified distribution/publication grant. Protect supplied specifications/keys/environment information and copyright notices. API-specific consumer delivery, sample retention/derived rights and overseas development need clarification. |

### Updated requirement/provider matrix

This table is the **current documentary assessment**. The earlier matrix remains
the repository-only starting record. Each cell refers to the precise official
ledger above; no public sample is promoted to payload proof. Resolution scenarios
S1–S6 and questions EQ1–EQ4 retain their definitions above. Block codes retain the
same meanings; optional gaps block only affected alternatives where appropriate.

| Requirement | Ekispert | NAVITIME | Jorudan | Missing proof / smallest resolution / blocked deliverable |
|---|---|---|---|---|
| Launch coverage | D: PE4 national line scheme; U exact set | D: PN2 rail modes; U exact set | D: PJ1 route offering; U exact set | Product-enabled coverage of all 15 accepted lines and boundary continuations. Request exact coverage statement then S1/S2; R/launch exit. A catalog is not expansion acceptance. |
| Exact IDs / coherent mapping | D: PE3–4; U revision joins | D: PN2–3; U stability/retirement | U: PJ1; PJ2 historical name interface only | S1 exact anchors/lines, distinct same-name stations, version/change policy and coherent identified view. Names/coordinates never bind IDs; R/T. |
| Continuous rides / train changes | D: PE5; U complete assertion semantics | D: PN2; U omission interpretation across fragments | U: PJ1; no current response specification | S2/S3: authoritative stay-aboard versus change semantics, not fare continuity or merely missing flags. R for affected alternatives. |
| Same-station interchange | D: PE11 categories; U exact pairs | D: PN2 structure; U interchange provenance | U: PJ1/PJ2 do not settle current pairs | S3 line-pair evidence plus genuine train change; timestamps do not prove feasibility. R. |
| Directional distinct-station walk | D: PE2 walk representation; U pair evidence | D: PN2 walk representation; U pair evidence | U: PJ1 | S3 each direction, exact mapped endpoints, link provenance/rights. Neither proximity nor a general walking capability proves the particular link. R. |
| Run joins / repeated occurrences | D: PE6 short-lived families; U bridge | D: PN2/PN8 internal references; U bridge | U: PJ1/PJ2 | S4 reviewed recurring-run bridge, original occurrences, partial coverage and dataset coherence. No reviewed cross-source correspondence found for any candidate. T/G; P2-S9 before real canonical Trip consumption. |
| Depart-not-before / zone / precision / horizon | D: PE2 minute input; U absolute semantics | D: PN2–3; U offset/default interpretation | D: PJ1 intent advertised; U encoding; PJ2 unsuitable evidence | S5 between precision ticks, equality, outside supported horizon; written zone and horizon definition. Do not round/roll over silently. R; unsupported intent must remain explicit. |
| Qualified endpoints / incomplete times | D: PE2 examples; U complete policy | D: PN2–3 fields; U completeness/qualification | U current Biz; PJ2 historical sentinels only | S5 missing counterpart, cross-midnight, gaps between known events; prove scheduled provenance. Validate every qualified ridden endpoint before pair omission. No Trip unused endpoints, inferred dates, timetable truth or realtime precision. R. |
| Alternatives / genuine empty / omissions | D: PE2/PE10; U empty/admission | D: PN2/PN4; U reliable empty discriminator | D historical PJ2 only; U Biz | S1/S6 genuine empty versus all omitted versus shared-envelope failure; preserve source positions. Need stable semantic classifier, not raw text exposed to users. R. |
| Errors / limits / cancellation | D: PE7/PE10; U cancel billing | D: PN1/PN4; U cancel billing | D historical PJ2; U Biz limits | S6 authorized error examples; clarify quotas/backoff/canceled billing. No provider-side cancellation support established. Local cancellation/owned work remains adapter duty, not server cancellation requirement. R/SHIP cost. |
| Returned JA/EN/KO | D: PE7 option | D: PN1–2 option/fallback | D: PJ1 multilingual claim; U field coverage | S1 stable identities across returned railway-content languages; current coverage/fallback and use of canonical names need rights/semantic proof. UI translation alone is irrelevant. SHIP; optional provider Korean absence need not block R. |
| Evaluation access | D: PE1/PE9 | D: PN1 | D: PJ1 | EQ1 exact product/option entitlement, eligibility, expiry, capture/decode permission. Published trial is not authorization or production grant. EVAL. |
| Price / billing | D: PE1/PE7 | D: PN1 | D: PJ1 quote starting point | EQ2 all-in licensed quote, billing units, hard caps and owner demand; table below is not TSUGINO budget. EVAL/SHIP. |
| Free-app use / attribution | D restrictions: PE7–8; U written permission | D restrictions: PN5–6; U permitted app | D restrictions: PJ3; U API consumer grant | EQ3 explicit free iPhone route/guidance use and marks placement; no implied permission from trial or commercial marketing. SHIP. |
| Storage / cache / derivatives / redistribution | C for unrestricted reuse: PE8 | C for unapproved cache: PN5–6 | U: PJ3 no specific payload license | EQ3 itemized transient normalization, derived candidates/mappings, recent journeys, private fixtures, ODPT joins, TTL/deletion and sharing. Rights preflight before capture. EVAL retention/R design/T/SHIP. |
| Credentials / client versus server | D: PE8–9 confidentiality; U mobile approval | D: PN5/PN7 server/secret context; U mobile exception | D: PJ3 key protection; U current auth/deployment | EQ4 permitted credential placement, server requirement/alternative, logging and operating cost. Cloud-hosted API does not prove safe direct iOS. EVAL/R composition/SHIP. |

No searched source supplies a complete, current, plan-specific answer for all launch
lines, exact search horizon, cross-source run joining or repeated-stop correspondence.
This is a bounded research result, not proof that such documentation or capability
does not exist. Nor do all three need to expose identical DTO fields: independent,
licensed evidence can satisfy DEC-076 without verified train attachment.

### Published costs and evaluation terms — not an affordability verdict

All entries are **D**, as accessed above. No traffic demand, exchange rate or budget
is assumed. Tax treatment and final order terms need confirmation where not explicit.

| Product | Published cost/access | Qualifications |
|---|---|---|
| Ekispert Free / request packs / Standard (PE1) | Free ¥0. Packs: 5,000 requests ¥5,500; 10,000 ¥11,000; 20,000 ¥22,000. Standard: initial fee plus request-tier usage pricing; 90-day free evaluation offered. | Pack tax/expiry not established here. Standard total is quote-dependent; PE7 operator licensing is additional. Cheap plans are not equivalent to licensed timetable search. |
| NAVITIME direct (PN1) | Initial charge plus request-tier quote; access cap starts at 10,000; rate by inquiry; 90-day trial offered. | Timetable/options and actual contract limits need quotation. No comparable public all-in TSUGINO price. |
| NAVITIME marketplace (PN1) | Monthly: Rapid BASIC/API Hub Trial free, cap 500, 50/min; PRO/Basic $200/¥26,000, cap 5,000, 100/min; ULTRA/Standard $300/¥39,000, cap 10,000, 150/min, overage $0.05/¥7. | Separate products can add subscriptions. Direct-only options are not included by inference. Currency is as published; tax and cap/reset details require plan confirmation. |
| Jorudan Biz API Ver.2.0 (PJ1) | Starts at ¥354,000 for 10 concurrent-access licenses; 90-day API loan offered. | Published page does not establish billing period, tax or free-app tariff; commercial use requires consultation. Not a monthly/per-request comparison. |

### Demonstrated mismatches versus unresolved questions

- **C — plan mismatch, not provider rejection:** PE1 Free cannot supply the structured
  itinerary required here; its packs' average-only mode does not prove explicit
  absolute departure intent. Do not silently replace DEC-076 with a linked website
  or an average-time search.
- **C — unapproved retention/use:** PE8 Art 27 prohibits secondary use/resale and
  retention/reuse of railway-time output, and addresses competing route/transfer
  services with prior written-consent requirements. Unrestricted reusable fixtures
  or stored provider-time data conflict with that text. Whether TSUGINO's precise
  normalization, derived values and product can be licensed needs written special
  terms; even evaluation must not presume an exemption. This is a material preflight
  gate, not permission inferred from the trial advertisement.
- **C — unapproved NAVITIME caching:** PN5 Art 5(5) requires specifically permitted
  stored data/uses; PN6 has a cache prohibition. Persistence plans cannot assume
  otherwise. **U:** guidance prohibition applicability, owned-point endpoint condition
  satisfaction, canonical re-display, consumer distribution and direct-iOS exception
  require product-specific clarification. Do not label the entire API incompatible.
- **U — Jorudan current interface/rights:** PJ2's historical interface cannot stand in
  for PJ1 Biz Ver.2.0. Missing time parameters there do not disprove the current
  offering's advertised departure search. PJ3 is not a consumer-mobile distribution
  or payload-retention grant. No provider-wide incompatibility is established.

### Conditional evaluation order and smallest next task

**Recommendation, not provider selection:** Ekispert **Standard with explicitly
licensed timetable access** first for technical evaluation; NAVITIME **direct
contract with railway-timetable option** second. PE2–6 and PN2–3/PN8 give concrete
fields and semantic distinctions to inspect. This ranking is by public-document
inspectability, not proven compatibility, price or rights superiority. Both have
material rights questions. Jorudan remains a candidate; a current API specification
and intended-use terms could change the order. A2's two-candidate comparison remains.
No candidate is ready for an API request under this task's authorization.

The smallest next task is **owner review of a rights/access clarification packet**
for those two exact products, then separately authorized contact if desired:

1. Describe free consumer iPhone route search, canonical display and later Journey
   guidance; ask explicit permitted-use/competitive-service and attribution terms.
2. Request timetable evaluation entitlement and all operator/options fees, currency,
   minimum/period, quota, overage and enforceable spending cap; no budget is invented.
3. Ask permission to decode and transiently normalize responses and retain a small
   private review sample; specify allowed fields, TTL/deletion, derived mappings and
   candidate values, private regression fixtures, ODPT joins and prohibited sharing.
4. Resolve mobile credential placement/server requirement and documentation access;
   obtain current schema, time-zone/precision/horizon and empty-response semantics.

**Smallest later payload evaluation proposal:** after written access/retention terms
and owner authorization, start with S1 direct route plus S5 precision/date-boundary
variants in one accepted launch corridor, route-only. Capture product/data revision,
exact mapped endpoints/lines, continuity evidence and scheduled qualification;
report only permitted findings. This is a feasibility stop/go probe, not launch
coverage or a new canonical Trip. If viable, extend to S2 through service, both S3
transfer forms/directions, S4 identity ambiguity and S6 sanctioned failures, then
repeat comparable scenarios for the second candidate. Public/supplier error examples
can reduce calls; never create load to force a rate failure. S4 initially reviews
provider references only: **P2-S9 moves first if real canonical passenger-stop Trips
would be consumed**, even for evaluation. It does not block this document or the
route-only probe. P3-T1 remains separate.

Owner choices still needed: whether to pursue the conditional order; exact contact
recipients/message approval; trial/account agreement approval; request and monetary
caps; private retention/deletion permission; and, only after evidence, acceptable
server cost/architecture. Public-document authorization granted here does **not**
authorize contact, enrollment, terms acceptance, credentials or requests. Production
selection, registry adoption, shipping rights, ODPT Q3/Q4/publication/bundling and
P2-S10/Track A expansion gates remain unchanged. No scheduled/realtime guidance,
provider compatibility or Phase 3 exit is approved by this research.
