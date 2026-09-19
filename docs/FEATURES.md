# TSUGINO — FEATURES.md

## 1. Purpose

This document defines the product features required to deliver the TSUGINO experience described in `PRODUCT.md`.

The feature set is organized around one principle:

> **The user chooses the journey and the specific train; TSUGINO owns the in-trip experience from that point forward.**

Features are grouped into:

- Core MVP
- Conditional MVP
- Post-MVP
- Explicitly Out of Scope

---

## 2. Core MVP Feature Set

### 2.1 Station Search

Users can search for stations by:

- Japanese station name
- English station name
- Korean station name
- canonical aliases where available (see §11.3)

Equivalent Japanese, English, and Korean names resolve to the same canonical station (DEC-041, DEC-042).

The search result should show enough context to distinguish stations with similar names.

Minimum information:

- station name in the resolved app language
- operator
- line(s)
- Japanese / English / Korean labels as the context requires

---

### 2.2 Origin and Destination Selection

Users can choose:

- origin station
- destination station

The app should support reversing origin and destination.

---

### 2.3 Nearby Station Suggestions

When location permission is available, TSUGINO should suggest nearby stations to reduce input effort.

Nearby-station suggestions may show:

- station name
- operator
- line
- approximate distance

Nearby-station detection is not the same as automatic train detection and does not determine which train the user is riding.

---

### 2.4 Recent Journeys

TSUGINO should retain a lightweight list of recent journey selections so frequent trips can be started more quickly.

Recent journeys may include:

- origin
- destination
- preferred route context
- last-used time

Favorites may be deferred to a later release if necessary.

---

### 2.5 Route Search

TSUGINO obtains route candidates through a replaceable route-search provider.

Each route candidate should provide, where available:

- departure time
- arrival time
- total duration
- number of transfers
- participating operators
- participating lines
- journey legs
- scheduled train information
- transfer stations

TSUGINO must not hard-code itself to one provider at the domain level.

---

### 2.6 Route Alternatives

When multiple viable routes exist, the user can review alternatives.

Useful comparison information includes:

- fastest route
- fewer transfers
- departure time
- arrival time
- total journey duration
- fare where available

The UI should avoid overwhelming the user with excessive route detail before selection.

---

## 3. Train Selection

### 3.1 Explicit Train Selection

Before active journey tracking starts, the user explicitly selects the train they intend to board.

This is a core MVP rule.

The train candidate should show, where available:

- line
- service type
- destination / direction
- scheduled departure
- realtime departure
- delay
- train number or trip identifier
- platform information
- final destination

The selected train becomes the authoritative trip reference for the active journey leg.

Journey-selection model (DEC-047): the user selects the **boarding station**, the **intended departure time or scheduled train**, and the **destination or exit station**; TSUGINO then follows the selected journey with the best verified capability tier for that service — **Realtime Journey Tracking** where trip-level realtime is verified, otherwise **Scheduled Journey Guidance**. On a scheduled-tier service the candidate list shows scheduled departures only, labelled as scheduled, with available status/Alert information.

---

### 3.2 Realtime Train Candidates

Train candidates should be reconciled with realtime data when realtime data is available.

The UI should clearly distinguish:

- scheduled data
- realtime-adjusted data
- delayed service
- cancelled service
- unavailable realtime data

---

### 3.3 Multi-leg Train Selection

Journeys with transfers may contain multiple train legs.

TSUGINO should support selection and confirmation of the train for each relevant rail leg.

The product may use either of these flows depending on provider and realtime availability:

- preselect all known trains at journey start, then confirm each upcoming train as needed,
- or select the first train initially and confirm subsequent trains near each transfer.

For every rail leg, TSUGINO should maintain:

- planned trip
- selected trip
- realtime trip state
- boarding station
- alighting station
- transfer relationship to the next leg

A line or operator change must not automatically be treated as a transfer if the same physical train continues as a through service.

---

### 3.4 Train Replacement

If the selected train is:

- cancelled,
- missed,
- materially delayed,
- changed,
- or no longer consistent with the current route,

the user should be able to replace the selected train without rebuilding the entire journey from scratch when possible.

---

### 3.5 Missed Train Recovery

If the user misses the selected train, TSUGINO should preserve the destination and route context and help the user recover.

Recovery may include:

- showing the next viable train
- replacing the selected trip
- updating downstream times
- recalculating the transfer sequence when necessary
- updating Live Activity without forcing a full journey restart

---

### 3.6 Wrong Train / Wrong Direction Recovery

If observed realtime or journey progression is inconsistent with the selected trip, TSUGINO should not silently assume the user is still on the planned train.

The app should surface a clear correction flow, for example:

- confirm the actual train
- select a different train
- correct direction
- rebuild the remaining journey from the current context

TSUGINO should avoid overconfident automatic conclusions when the available data is ambiguous.

---

## 4. Active Journey

### 4.1 Start Journey

A journey can begin after:

- a valid route has been selected,
- and a specific train has been confirmed for the first tracked leg.

Starting a journey creates the active journey state used by:

- the main app
- Live Activity
- Dynamic Island
- notifications

---

### 4.2 Active Journey Persistence and Resume

An active Journey must be persisted locally.

TSUGINO should be able to restore an ongoing journey after:

- the app leaves memory
- the app is terminated by the system
- the user manually reopens the app
- the device temporarily loses network connectivity

On resume, TSUGINO should reconcile the persisted Journey with current realtime data before presenting precise progress.

If the journey can no longer be reconciled safely, the app should enter a recoverable interrupted state rather than inventing progress.

---

### 4.3 Current Journey Leg

The app shows the currently active leg.

Information may include:

- operator
- line
- direction
- service type
- selected train
- boarding station
- alighting station
- scheduled times
- realtime times

---

### 4.4 Current Station

TSUGINO should determine the best-known current station or current progression state using available realtime data.

When exact current-station state is not reliable, the UI must avoid presenting false precision.

---

### 4.5 Next Station

The next scheduled stop for the selected trip should be shown prominently.

This feature must respect the actual stopping pattern of the selected service.

Express, rapid, local, limited-stop, and through-service patterns must not be treated as identical.

---

### 4.6 Remaining Stops

TSUGINO calculates and displays the number of remaining stops to:

- the next transfer,
- or the final destination for the active leg.

The count must be based on the actual stop sequence of the selected trip.

---

### 4.7 Estimated Arrival

The app shows the best-known estimated arrival time using:

1. realtime arrival data when available,
2. realtime delay adjustment when available,
3. scheduled arrival as fallback.

The UI should distinguish fallback estimates from confirmed realtime information when necessary.

---

### 4.8 Delay State

TSUGINO should show meaningful delay state without turning the app into a disruption-news product.

Possible states include:

- on time
- delayed
- significantly delayed
- cancelled
- realtime unavailable

---

### 4.9 Through Service Handling

TSUGINO must support Japanese through-service operations (`直通運転`).

A single physical train may continue across:

- multiple lines
- multiple operators
- different internal route identifiers

A line or operator transition must not automatically create a transfer event.

The Journey model should distinguish:

- physical train continuity
- route/line identity
- operator identity
- actual passenger transfer

---

### 4.10 Service Pattern Changes

The active journey should tolerate supported realtime changes such as:

- short-turn operation
- changed final destination
- skipped or added stops
- temporary termination
- cancellation
- altered stopping pattern

TSUGINO should update the remaining journey when trustworthy realtime data indicates such a change.

---

### 4.11 Manual Journey Correction

Users should have a controlled way to correct an active journey when automatic state becomes inaccurate.

Possible corrections include:

- change selected train
- confirm a different current leg
- reselect current station context
- resync the remaining journey
- choose a replacement route

Manual correction should preserve as much valid journey context as possible.

---

### 4.12 Cancel or End Journey

The user can explicitly:

- cancel the journey
- end tracking early
- change destination
- stop Live Activity

Ending or cancelling a journey must also clean up:

- active Live Activity
- journey-specific notifications
- stale tracked-trip state

---

## 5. Transfer Guidance

### 5.1 Upcoming Transfer

Before a transfer, TSUGINO shows:

- transfer station
- next line
- next operator if relevant
- next train or service when known
- expected transfer time

---

### 5.2 Transfer Approach

As the transfer station approaches, transfer information becomes more prominent.

Example:

> 赤坂見附で銀座線へ乗換  
> Transfer to the Ginza Line at Akasaka-mitsuke

---

### 5.3 Recommended Car Position

Where reliable data exists, TSUGINO may show the recommended train car for a faster or easier transfer.

Example:

> 2号車がおすすめ  
> Car 2 recommended

This feature is conditional on data coverage.

---

### 5.4 Recommended Door Position

Where reliable data exists, TSUGINO may show:

- door position
- left/right side
- nearby stairs
- escalator
- elevator
- transfer corridor

Door-level guidance must not be displayed when confidence is insufficient.

---

### 5.5 Transfer Walking Time

Where reliable data exists, TSUGINO may show estimated transfer walking time.

This value may come from:

- route provider data
- operator station-layout data
- licensed transfer data
- TSUGINO-maintained static data

---

### 5.6 Destination Exit Boarding Position

Where reliable data exists, TSUGINO may recommend a train car or door position that is convenient for the user's intended station exit.

Example:

> 新宿駅 東口へ  
> 8号車がおすすめ

This feature is coverage-dependent and should not be shown when exit-position data is incomplete or unreliable.

---

## 6. Dynamic Island

Dynamic Island is a primary TSUGINO surface.

### 6.1 Compact Presentation

Compact presentation may show:

- line symbol
- remaining stops
- destination
- departure countdown
- transfer countdown

Only the most useful information should be shown.

---

### 6.2 Minimal Presentation

Minimal presentation should use an extremely compact state such as:

- railway symbol
- stop count
- small journey-status indicator

Decoration should be restrained.

---

### 6.3 Expanded Presentation

Expanded Dynamic Island may show:

- current line
- current station
- next station
- destination
- remaining stops
- ETA
- upcoming transfer

The layout should change with journey state.

---

## 7. Lock Screen Live Activity

Lock Screen Live Activity should provide a richer view than Dynamic Island.

Possible content:

- current line
- boarding station
- alighting station
- current / next station
- progress
- remaining stops
- ETA
- delay
- upcoming transfer
- recommended car position when available

Live Activity should remain readable at a glance.

### 7.1 Live Activity Lifecycle

The Live Activity lifecycle must follow the active Journey.

Expected lifecycle:

1. Journey starts → Live Activity starts
2. journey state changes → Live Activity updates
3. selected train changes → Live Activity reconciles
4. transfer begins → Live Activity changes presentation
5. destination approaches → Live Activity emphasizes arrival
6. journey arrives, ends, or is cancelled → Live Activity ends

TSUGINO should prevent stale Live Activities from remaining visible after the journey has ended.

Live Activity presentation must match the leg's verified capability tier (DEC-046, DEC-047): scheduled times are shown as scheduled, status/Alert information with its provenance, and live current-stop or vehicle progression only with verified trip-level realtime. A Scheduled Journey Guidance leg may have a Live Activity that is explicitly labelled as timetable-based (scheduled times, scheduled next stop, clock-based scheduled progress) and never implies physical train position. If no honest presentation is defined for a leg's available capabilities, the Live Activity does not start for that leg. A multi-leg journey may mix tiers; each leg presents its own tier.

---

## 8. Journey-State Presentation

TSUGINO's UI responds to journey state.

Initial conceptual states:

- Planning
- WaitingForDeparture
- Boarding
- OnTrain
- ApproachingTransfer
- Transferring
- WaitingForNextTrain
- ApproachingDestination
- Arrived
- Ended
- Interrupted

Each state defines:

- primary information
- secondary information
- allowed actions
- Dynamic Island content
- Lock Screen content
- notification behavior

---

## 9. Notifications

Notifications should be contextual and sparse.

### 9.1 Departure Approaching

Possible alert before the selected train departs.

---

### 9.2 Transfer Approaching

Alert shortly before the transfer station.

---

### 9.3 Destination Approaching

Alert one or more stops before the destination.

Exact timing should be configurable later if needed.

---

### 9.4 Arrival

Optional arrival confirmation.

---

### 9.5 Journey Problem

Notify or visibly surface when:

- selected train is cancelled
- journey tracking becomes inconsistent
- a major delay affects the selected trip
- realtime tracking is unavailable for an extended period

---

## 10. Realtime Data Features

### 10.1 Trip Update Integration

TSUGINO should consume realtime trip updates where available.

Used for:

- departure adjustments
- arrival adjustments
- stop progression
- delay calculation
- cancellation state

---

### 10.2 Vehicle Position Integration

Vehicle Position data may improve tracking where available.

It is not a universal requirement.

The product must remain functional for supported operators that provide reliable trip updates without exact vehicle coordinates.

---

### 10.3 Realtime Availability State

The app should internally distinguish:

- full realtime support
- partial realtime support
- schedule-only fallback
- unavailable data

The user-facing UI may simplify these states, but must not claim realtime precision when it does not exist.

Availability is evaluated **per service/feed**, not per operator (DEC-022, DEC-046). For a service without verified Trip Update / Vehicle Position capability:

- route search and static journey information remain available;
- scheduled departure/arrival information is shown and **labelled as scheduled**;
- verified service-status and Alert information may supplement it, with its actual provenance;
- live vehicle, current-stop, and progress UI (§4.4, §4.7 realtime estimates, §4.8 realtime delay) requires verified Trip Update / Vehicle Position capability and is otherwise omitted or replaced by an "unavailable" state — never derived from the schedule and presented as live;
- unsupported live affordances degrade independently; the whole service is not removed.

Capability tiers (DEC-047): **Realtime Journey Tracking** (verified trip-level realtime — Toei Subway, Tokyo Sakura Tram); **Scheduled Journey Guidance** (user-selected scheduled journey + timetable + available status/Alert — the nine Tokyo Metro lines and the Nippori-Toneri Liner); **Deferred / Unsupported** (no journey guidance). The scheduled tier may show time to scheduled departure, scheduled departure/arrival, scheduled next stop, a scheduled timeline, clock-based scheduled progress, and disruption notices; it must not claim actual train location, station passage, departure, arrival, elapsed-time-derived delay, onboard confirmation, or realtime progress, and timetable-based animation never represents the physical train. A disruption status/Alert is never overridden or concealed by scheduled progression.

Current concrete cases: the Toei **Nippori-Toneri Liner** follows schedule + status/Alert-level behaviour (its Trip Update and Vehicle Position feeds are officially excluded); **Tokyo Metro** has no Trip Update / Vehicle Position in the audited catalog and launches in the scheduled tier; actual Liner and Tokyo Metro Alert/status semantics across incidents remain pending verification.

---

### 10.4 Realtime Freshness

Realtime data must be evaluated for freshness.

TSUGINO should track, where possible:

- last successful realtime update
- age of the current realtime state
- stale threshold
- feed recovery
- provider failure

A stale feed must not continue to be presented as current realtime information.

Possible user-visible states include:

- Live
- Delayed update
- Realtime temporarily unavailable
- Schedule fallback

---

## 11. Localization

The MVP supports:

- Japanese
- English
- Korean

### 11.1 Language Resolution

TSUGINO resolves the display language as follows:

- device/app language is Japanese → Japanese
- device/app language is Korean → Korean
- all other languages → English

English is the global fallback.

### 11.2 Localized Railway Names

Station, line, and operator names should be available in canonical localized form where possible:

- Japanese
- English
- Korean

The app must not assume every external provider returns all three.

When provider localization is incomplete, TSUGINO should use its own canonical localization dataset or mapping layer.

### 11.3 Station Search Aliases

Station search should resolve equivalent localized names to the same canonical station.

Example:

```text
新宿
Shinjuku
신주쿠
   ↓
StationID: Shinjuku
```

Search should support the active language and may support cross-language aliases where useful.

### 11.4 Localization Scope

Localization must include:

- station names
- line names
- operator names
- route results
- journey status
- transfer instructions
- notifications
- Dynamic Island
- Live Activity
- error states

The UI must be designed for all three languages from the beginning.


### 11.5 Platform Scope

TSUGINO v1 supports iPhone only.

The following are not v1 requirements:

- iPad layouts
- iPad multitasking
- iPad split-view behavior
- iPad-specific navigation
- iPad-specific Live Activity presentation
- iPad QA

Do not add iPad support opportunistically during v1 implementation.

---

## 12. Visual Experience

### 12.1 Pixel Art Environment

Pixel art may appear in:

- home background
- journey background
- station scenes
- platform scenes
- tunnel scenes
- transfer scenes
- decorative illustrations

---

### 12.2 Modern Information Layer

Live railway information must use modern, high-legibility UI.

Requirements:

- clear hierarchy
- system-friendly typography
- line-color recognition
- restrained motion
- no pixel-font dependence for critical information

---

### 12.3 Contextual Backgrounds

Background scenes may change based on journey context:

- waiting on platform
- traveling underground
- traveling above ground
- transfer corridor
- destination approach

This is a visual enhancement and must not block MVP reliability work.

---

## 13. Data Coverage Awareness

Every feature dependent on external data must gracefully handle incomplete coverage.

Examples:

- no realtime feed
- no Vehicle Position
- no car recommendation
- no door recommendation
- no station-layout data

TSUGINO should omit unsupported guidance rather than invent or approximate unsupported facts.

---

## 14. Data and Licensing Features

The project must maintain a source registry for production data.

For each source, track:

- provider
- dataset
- supported lines/operators
- license
- commercial-use status
- attribution requirements
- caching rules
- redistribution restrictions
- expiration
- challenge-only restrictions

A source that is legal only for testing must not silently become a production dependency.

---

## 15. Settings — MVP Minimum

The initial settings surface may include:

- language
- notification permission/status
- Live Activity guidance/status
- data source acknowledgements
- privacy information

Additional settings should be added only when a real user need appears.

---

## 16. Error and Recovery Features

TSUGINO must handle:

- network unavailable
- realtime feed unavailable
- route provider unavailable
- selected train no longer valid
- journey data mismatch
- unsupported line
- unsupported transfer guidance
- Live Activity failure
- notification permission denied

Recovery should favor keeping the current journey usable whenever possible.

---

## 17. Conditional MVP Features

These features should be included in the MVP only when the required data source is sufficiently reliable.

- recommended car
- recommended door
- nearest stair/escalator/elevator
- transfer walking time
- platform number
- destination-side door information
- detailed station-layout guidance
- destination-exit boarding position guidance

The UI architecture should support them even when coverage is partial.

---

## 18. Post-MVP Features

Potential later features include:

- automatic train detection
- Apple Watch companion
- favorite routes and pinned journeys
- commuting shortcuts
- recurring journey suggestions
- automatic rerouting
- disruption-aware alternative route suggestions
- richer station interior guidance
- platform exit guidance
- accessibility-optimized routes
- additional languages
- nationwide Japan expansion
- user-configurable alert timing

---

## 19. Explicitly Out of Scope

The MVP does not include:

- Android
- ticket purchasing
- IC card recharge
- seat reservation
- social features
- public user comments
- crowd-sourced train locations
- advertisements
- guaranteed nationwide coverage
- guaranteed car/door guidance for every station
- perfect automatic train detection

---

## 20. MVP Feature Completion Rule

The MVP is functionally complete when a user can:

1. search an origin and destination,
2. select a route,
3. see relevant train candidates,
4. explicitly select the train they intend to board,
5. start the journey,
6. leave or lock the app,
7. see the current journey state through Dynamic Island or Live Activity,
8. understand the next station,
9. understand remaining stops,
10. receive useful transfer guidance,
11. know when the destination is approaching,
12. recover from a missed or changed train without rebuilding the entire journey when practical,
13. resume an active journey after reopening the app,
14. complete the journey without repeatedly reopening TSUGINO.

Transfer car/door guidance is additive and coverage-dependent; it is not allowed to block core journey tracking when unavailable.
