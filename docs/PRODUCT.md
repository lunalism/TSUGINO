# TSUGINO — PRODUCT.md

## 1. Product Overview

**TSUGINO** is an iPhone railway journey companion for Japan that keeps the user informed throughout a trip without requiring the app to stay open.

After the user selects a route and the train they intend to board, TSUGINO tracks the journey and presents the most relevant information through:

- the main app,
- Dynamic Island,
- Lock Screen Live Activities,
- and timely notifications.

The primary product experience is:

> Choose the journey once, then keep moving without repeatedly reopening the app.

TSUGINO begins with **Tokyo-area railways** and expands progressively across Japan as reliable and legally usable data becomes available.

The initial product supports **Japanese, English, and Korean**.

---

## 2. Product Vision

> **次の駅を、見逃さない。**  
> Never miss what comes next.

TSUGINO is not intended to become another general-purpose route-planning app.

Its purpose is to remain useful **after the journey has started**.

The app should continuously answer questions such as:

- Where am I now?
- What is the next station?
- How many stops remain?
- When do I need to transfer?
- Which train should I board next?
- Which car or door position is best for a faster transfer?
- How long remains until my destination?

TSUGINO should feel like a calm railway companion that keeps watching the journey while the user does something else.

---

## 3. Problem

Rail passengers frequently need to re-check their journey while traveling.

Common situations include:

- using another app while on the train,
- watching video or listening to music,
- keeping the iPhone locked,
- traveling on unfamiliar lines,
- navigating complex transfers,
- worrying about missing the destination,
- trying to determine the best boarding position for a transfer.

Traditional transit apps often provide excellent route planning, but the user still needs to reopen the app repeatedly to check progress.

TSUGINO solves this by making the journey status continuously glanceable through system surfaces such as Dynamic Island and the Lock Screen.

---

## 4. Product Positioning

TSUGINO is not primarily:

- a map app,
- a railway timetable database,
- a ticketing service,
- or a complete replacement for NAVITIME, Jorudan, Ekispert, or similar route-search products.

Instead, TSUGINO focuses on:

> **Journey Tracking + Live Activity + Transfer Guidance**

Route search may rely on a specialized external provider, while TSUGINO owns the ongoing in-trip experience.

---

## 5. Target Users

### Primary Users

- iPhone users who regularly travel by train in Japan
- commuters and students
- people traveling on unfamiliar routes
- users who frequently use other apps while riding
- users who want clear transfer timing
- users who want to avoid missing their stop

### Secondary Users

- international visitors traveling in Japan
- users making complex multi-line transfers
- users who value Dynamic Island and Live Activities
- users who benefit from boarding-position guidance

---

## 6. Geographic Strategy

### Phase 1: Tokyo First

The first production target is the Tokyo metropolitan railway network.

Rather than limiting the product to only a fixed pair of operators, TSUGINO should support **as many Tokyo-area lines as can be supported reliably through legally usable official, open, or commercial data sources**.

Candidate data sources include:

- ODPT
- GTFS
- GTFS Realtime
- railway operator open data
- licensed commercial route-search APIs
- licensed station and transfer guidance data

### Expansion

After proving the product in Tokyo, support should expand progressively to other Japanese regions.

Expansion must be based on:

- data availability,
- realtime coverage,
- licensing,
- operational reliability,
- and the quality of the end-user experience.

Nationwide coverage is a long-term objective, not an MVP requirement.

---

## 7. Language Strategy

The initial release supports:

- **Japanese**
- **English**
- **Korean**

TSUGINO uses a deterministic language-resolution rule based on the effective device/app language:

- Japanese (`ja`, including regional variants) → Japanese UI
- Korean (`ko`, including regional variants) → Korean UI
- every other language → English UI

English is therefore the global fallback language.

This rule applies consistently to:

- app UI
- station names
- line names
- operator names
- route results
- transfer instructions
- notifications
- Dynamic Island
- Lock Screen Live Activity
- error and recovery states

Japanese is the primary local experience.

English and Korean are first-class supported languages rather than later translation layers.

Station names and other railway labels must not depend entirely on a provider returning all three languages. TSUGINO may maintain canonical localized railway names to guarantee consistent Japanese, English, and Korean display.

Additional languages may be considered later.


## 7.1 Platform Scope

TSUGINO v1 is **iPhone-only**.

iPad is explicitly excluded from:

- v1 product scope
- v1 implementation requirements
- v1 layout support
- v1 QA matrix
- v1 App Store device support

The v1 app should not preserve artificial iPad compatibility merely for future possibility.

iPad may be reconsidered for a future major release such as v2 through a new explicit product and design decision.

---

## 8. Core User Journey

### 8.1 Plan

The user selects:

- origin station,
- destination station,
- desired route,
- and a specific train when relevant.

The user may choose among realtime train candidates such as:

- destination,
- train type,
- departure time,
- train number or trip identifier,
- delay information,
- expected arrival time.

### 8.2 Start Journey

Once the user confirms the train or route, TSUGINO creates an active **Journey**.

### 8.3 Track

During travel, TSUGINO tracks:

- current line,
- current trip,
- current station,
- next station,
- remaining stops,
- estimated arrival,
- realtime delay,
- current journey leg,
- upcoming transfer.

### 8.4 Surface

The journey is shown through:

1. Main App
2. Dynamic Island
3. Lock Screen Live Activity
4. Notifications

### 8.5 Guide

As the user approaches a transfer or destination, TSUGINO increases the prominence of the next required action.

Examples:

> あと2駅  
> 2 stops remaining

> 次は新宿  
> Next: Shinjuku

> 赤坂見附で銀座線へ乗換  
> Transfer to the Ginza Line at Akasaka-mitsuke

---

## 9. Route Search Strategy

TSUGINO should **not build a complete Japanese route-search engine from scratch for the MVP**.

Japanese railway routing includes complexities such as:

- through services,
- express and local stopping patterns,
- timetable-dependent transfers,
- operator boundaries,
- first and last trains,
- paid limited express services,
- realtime delays,
- transfer walking times,
- platform constraints.

A specialized route-search provider should therefore be preferred.

Potential provider categories include:

- Jorudan
- NAVITIME
- Ekispert
- other licensed Japanese transit-routing APIs

TSUGINO's architecture must keep the route-search provider replaceable.

### TSUGINO Responsibility

TSUGINO owns:

- journey representation,
- active-trip state,
- realtime reconciliation,
- remaining-stop calculation,
- transfer progression,
- Live Activity state,
- Dynamic Island presentation,
- notification timing.

### Route Provider Responsibility

The external route provider may supply:

- route candidates,
- timetable-based itinerary,
- transfer sequence,
- scheduled train details,
- departure and arrival estimates,
- fare information if needed.

---

## 10. Realtime Data Strategy

Realtime railway data is a core dependency of TSUGINO.

Preferred data sources include:

- ODPT realtime APIs
- GTFS Realtime
- operator-provided realtime feeds
- licensed commercial realtime sources

TSUGINO should use realtime data to improve:

- actual departure time,
- actual arrival time,
- train progress,
- delay status,
- current trip identification,
- journey state transitions.

Vehicle-position data is valuable but is **not mandatory** if reliable trip updates and stop progression are available.

A viable journey may be tracked using:

- GTFS static data,
- trip identity,
- stop sequence,
- scheduled times,
- GTFS-RT Trip Updates,
- and optional Vehicle Positions.

---

## 11. Train Selection Strategy

The MVP does not require perfect automatic train detection.

### Explicit Train Selection Principle

**Before active journey tracking begins, the user explicitly selects the train they intend to board.**

The preferred initial flow is:

1. user selects origin and destination,
2. route candidates are shown,
3. candidate trains are shown in realtime,
4. user explicitly confirms the train they intend to board,
5. TSUGINO binds the active Journey to that selected trip,
6. TSUGINO tracks that trip until the relevant leg ends or the journey is changed.

This explicit selection is a core MVP product rule. It reduces ambiguity and improves reliability compared with trying to infer the exact train solely from device location.

If the selected train becomes unavailable, cancelled, materially delayed, or inconsistent with observed realtime data, TSUGINO should surface that state and allow the user to choose a replacement train.

Automatic train detection may be explored later, but it must not be required for the MVP to function reliably.

---

## 12. Transfer Convenience Guidance

TSUGINO should support **recommended boarding position guidance** when sufficiently reliable data is available.

Examples include:

- recommended car number,
- recommended door position,
- nearest stairs,
- nearest escalator,
- nearest elevator,
- fastest transfer position,
- expected transfer walking time.

Example:

> 銀座線へ乗換  
> 2号車がおすすめ

> Transfer to the Ginza Line  
> Car 2 recommended

This information may come from:

- commercial route-search APIs,
- operator station-layout data,
- licensed transfer-position datasets,
- or a TSUGINO-maintained static database for selected stations.

### Coverage Rule

This feature must be **coverage-aware**.

TSUGINO must never imply that boarding-position guidance is available or accurate for every station.

When data is unavailable, the feature should simply not appear.

---

## 13. Journey Model

The core product entity is **Journey**.

A Journey contains:

- Origin
- Destination
- Route
- Legs
- Transfers
- Selected Train / Trip
- Current Leg
- Current Station
- Next Station
- Remaining Stops
- Scheduled Departure
- Realtime Departure
- Scheduled Arrival
- Realtime Arrival
- Delay
- Transfer Guidance
- Journey State

---

## 14. Journey States

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

Journey state determines what is shown in the app, Dynamic Island, Lock Screen, and notifications.

---

## 15. Primary Product Surfaces

TSUGINO has three primary visual surfaces.

### 15.1 Main App

Used primarily for:

- route selection,
- train selection,
- journey setup,
- route review,
- transfer details,
- journey controls.

### 15.2 Dynamic Island

Used for immediate glanceable state.

Priority information includes:

- line,
- next station,
- remaining stops,
- departure countdown,
- transfer approach,
- destination approach.

Dynamic Island prioritizes information density and legibility over decoration.

### 15.3 Lock Screen Live Activity

Provides a richer journey view including:

- line and direction,
- boarding and alighting stations,
- remaining stops,
- next station,
- progress,
- ETA,
- transfer information.

Live Activity is a **primary product surface**, not a secondary convenience feature.

---

## 16. Notification Strategy

Notifications should be contextual rather than frequent.

Important moments may include:

- train departure approaching,
- train ready to board,
- transfer approaching,
- one or two stops before destination,
- arrival,
- significant disruption or journey mismatch.

Notifications must avoid becoming noisy.

---

## 17. Visual Identity

TSUGINO combines:

> **Pixel Art Environment + Modern iOS Information UI**

### Pixel Art

Pixel art may represent:

- platforms,
- trains,
- station signs,
- benches,
- tunnels,
- railway tracks,
- transfer corridors,
- city scenery.

Pixel art creates character and atmosphere.

### Information UI

Transit information remains modern, minimal, and highly readable.

Information UI should use:

- clear typography,
- strong hierarchy,
- railway line colors,
- restrained animation,
- minimal visual noise.

Pixel art must never reduce the clarity of live railway information.

---

## 18. Product Principles

### Glanceable

The current journey state should be understood within seconds.

### Passive

After starting a journey, the user should rarely need to reopen the app.

### Reliable

Accuracy and state consistency are more important than decorative richness.

### Calm

The product should reduce travel anxiety rather than add more alerts and clutter.

### Contextual

Only information relevant to the user's current journey phase should be emphasized.

### Characterful

TSUGINO should feel distinct from conventional utility-style transit apps.

### Coverage-Aware

The product must clearly handle cases where realtime, transfer, or boarding-position data is unavailable.

---

## 19. MVP Scope

The MVP targets Tokyo.

The MVP should include, where supported by reliable data:

- Japanese + English + Korean localization
- station search
- origin and destination selection
- route search through an external provider
- route alternatives
- realtime train candidates
- specific train selection
- journey start and end
- current journey leg
- current station
- next station
- remaining stops
- scheduled and realtime timing
- delay state
- transfer guidance
- recommended boarding position where available
- Dynamic Island
- Lock Screen Live Activity
- destination-approach alerts
- transfer-approach alerts
- realtime journey updates

---

## 20. Explicitly Out of Scope for Initial MVP

The initial MVP does not require:

- nationwide railway support
- every railway operator in Japan
- perfect automatic train detection
- proprietary vehicle-level GPS for every operator
- Android
- Apple Watch standalone app
- ticket purchase
- IC card recharge
- seat reservations
- social features
- user-generated transit reports
- advertising systems
- guaranteed boarding-position data for every station

---

## 21. Data and Licensing Principle

Every railway, route, realtime, station-layout, and transfer dataset must have a clearly documented usage basis.

Before production use, TSUGINO must record:

- source,
- owner/operator,
- license,
- allowed use,
- attribution requirements,
- redistribution restrictions,
- commercial-use restrictions,
- caching restrictions,
- expiration or challenge-specific restrictions.

Experimental or challenge-limited data must not silently become a production dependency.

---

## 22. Success Criteria

The MVP is successful if a user can:

1. search a Tokyo-area journey,
2. select an appropriate route,
3. identify and select the intended train,
4. start the journey,
5. leave or lock the app,
6. reliably see the current trip state in Dynamic Island or the Lock Screen,
7. understand the next station and remaining stops,
8. receive useful transfer guidance,
9. know when to prepare to exit,
10. complete the journey without repeatedly reopening the app.

---

## 23. Long-Term Direction

Potential future expansion includes:

- additional Tokyo private railways
- JR East production-grade support
- Kansai
- Chubu
- nationwide Japan coverage
- automatic train detection
- stronger Vehicle Position integration
- Apple Watch companion experience
- multilingual expansion
- personalized alert timing
- favorite and habitual journeys
- automatic commuting suggestions
- disruption-aware rerouting
- accessibility-focused transfer guidance
- platform and exit guidance
- richer station interior navigation

---

## 24. Product Boundary

TSUGINO should continuously protect this boundary:

> **Route planning gets the user onto the journey.  
> TSUGINO owns what happens during the journey.**

The product succeeds not by having the largest timetable database, but by becoming the easiest way to understand **what comes next** while traveling.
