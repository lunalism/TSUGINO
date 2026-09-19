# TSUGINO — DESIGN.md

## 1. Purpose

This document defines the visual, interaction, and system-surface design principles for TSUGINO.

TSUGINO is a railway journey companion whose most important experience often happens **outside the main app**.

The product must therefore feel coherent across:

1. Main App
2. Dynamic Island
3. Lock Screen Live Activity
4. Notifications

The central design principle is:

> **Pixel Art Environment + Modern iOS Information UI**

Pixel art creates atmosphere and identity. Live railway information remains clear, modern, restrained, and highly legible.

---

## 2. Design Goal

TSUGINO should feel:

- calm
- precise
- urban
- useful
- warm
- distinctive
- modern
- slightly nostalgic

The app must never feel:

- visually noisy
- game-like at the expense of clarity
- overloaded with railway jargon
- overly decorative
- like a clone of an existing transit app
- dependent on pixel fonts for critical information

The ideal user reaction is:

> “This feels charming, but I can understand my trip instantly.”

---

## 3. Core Design Principles

### 3.1 Information First

Transit information always takes precedence over decoration.

Critical information includes:

- current line
- current station
- next station
- destination
- remaining stops
- ETA
- transfer
- delay
- boarding position

These must remain readable under all supported themes and states.

### 3.2 Glanceable

The user should understand the most important state within one or two seconds.

Primary information must not require scrolling, interpretation, or reading long sentences.

### 3.3 Calm, Not Empty

TSUGINO should feel spacious and composed, but not sterile.

Use:

- restrained spacing
- clear hierarchy
- soft surfaces
- subtle railway color accents
- contextual pixel art

Avoid:

- excessive cards
- unnecessary separators
- repeated labels
- dense grids
- visual clutter

### 3.4 System-Native Where It Matters

Dynamic Island and Live Activity should feel native to iOS.

TSUGINO may be visually distinctive inside the app, but system surfaces should respect Apple platform conventions for:

- hierarchy
- density
- spacing
- typography
- motion
- touch targets
- content priority

### 3.5 Contextual

The UI should adapt to the user's journey state.

Examples:

- waiting for departure → departure time is primary
- riding → next station and remaining stops are primary
- approaching transfer → transfer instruction is primary
- approaching destination → destination warning is primary
- disrupted journey → recovery action becomes primary

### 3.6 Coverage-Aware

The UI must never imply data confidence that does not exist.

For example:

- if realtime is unavailable, do not present a live badge
- if car guidance is unavailable, omit it
- if current station is uncertain, avoid false precision
- if a journey is stale, visibly downgrade confidence

---

### 3.7 iPhone-Only v1

TSUGINO v1 is designed and validated for iPhone only.

Design work must not be diluted by supporting iPad during v1.

Do not create:

- iPad-specific layouts
- split-view adaptations
- tablet navigation patterns
- tablet-only pixel compositions

Future iPad support should be treated as a new design problem, not as a stretched iPhone layout.

---

## 4. Brand Identity

### 4.1 Product Name

**TSUGINO**

Derived from the Japanese phrase:

> 次の — “next”

The name connects naturally to:

- 次の駅
- 次の電車
- 次の乗換
- 次の一歩

### 4.2 Primary Tagline

> **次の駅を、見逃さない。**

English:

> **Never miss what comes next.**

### 4.3 Brand Personality

TSUGINO is:

- helpful, not chatty
- confident, not loud
- playful, not childish
- warm, not cute for its own sake
- precise, not mechanical

---

## 5. Visual Direction

### 5.1 Core Concept

> **A tiny pixel railway world beneath a modern realtime information layer.**

The app should feel like the user is traveling through a stylized miniature railway environment while receiving clean, precise information.

### 5.2 Visual Balance

Recommended balance:

- Main App: **60% modern UI / 40% pixel atmosphere**
- Lock Screen Live Activity: **85% information / 15% character**
- Dynamic Island: **90% information / 10% character**

The smaller the surface, the less decorative content should appear.

---

## 6. Color System

### 6.1 Base Palette

The core UI should use a restrained neutral foundation.

Suggested semantic roles:

- **Midnight** — primary dark background
- **Ink** — elevated surfaces
- **Soft Ivory** — light neutral surfaces
- **Signal Gray** — secondary text
- **Track Gold** — progress accent
- **Station Mint** — brand accent
- **Warning Amber** — delay / attention
- **Alert Red** — cancellation / critical interruption

Exact color values should be finalized later through visual testing.

### 6.2 Railway Line Colors

Real railway line colors should take priority when representing a line.

Examples:

- Ginza Line → orange
- Marunouchi Line → red
- Yamanote Line → green

Line colors should be used for:

- line badges
- route progress
- key chips
- compact identifiers
- transfer cues

Line colors should not dominate full backgrounds unless readability remains excellent.

### 6.3 Dark Mode

TSUGINO should be designed **dark-first**.

Reasons:

- Dynamic Island naturally integrates with dark surfaces
- transit usage frequently occurs in dim environments
- railway line colors remain vivid
- pixel art can feel atmospheric without becoming distracting

A light appearance may be supported later, but the visual system must first be coherent in dark mode.

---

## 7. Typography

### 7.1 Primary Typeface

Use the iOS system typeface by default.

Reasons:

- Japanese readability
- English readability
- Dynamic Type support
- consistency with Live Activities
- excellent numeric legibility

### 7.2 Hierarchy

Recommended information hierarchy:

**Level 1 — Critical**
- next station
- destination
- remaining stops
- countdown / ETA

**Level 2 — Context**
- line name
- direction
- transfer line
- boarding position

**Level 3 — Supporting**
- operator
- scheduled vs realtime detail
- last updated
- minor status

### 7.3 Pixel Fonts

Pixel fonts must **not** be used for critical transit information.

Pixel fonts may be used only for:

- decorative station signage
- tiny environmental details
- optional illustration labels
- non-critical art elements

---

## 8. Iconography

### 8.1 Style

Use a simple, compact icon style compatible with iOS.

Icons should be:

- geometric
- recognizable at small sizes
- visually quiet
- consistent in stroke weight

### 8.2 Railway-Specific Icons

Likely icons include:

- train
- platform
- transfer
- stairs
- escalator
- elevator
- exit
- alert
- delay
- current location
- destination
- favorite
- recent journey

### 8.3 Pixel Art Icons

Pixel-style icons may be used as decorative brand accents, but system-critical controls should remain modern and crisp.

---

## 9. Pixel Art Direction

### 9.1 Style

Pixel art should feel:

- clean
- low-noise
- urban
- slightly nostalgic
- compact
- warm

Avoid:

- heavy dithering
- excessive animation
- overly game-like palettes
- visual complexity behind text

### 9.2 Environment Types

Pixel art scenes may include:

#### Platform
- station columns
- benches
- signs
- fluorescent lights
- platform edge
- stopped train

#### Tunnel
- dark tunnel
- passing lights
- rails
- subtle motion

#### Above-Ground Ride
- skyline
- river
- bridges
- residential blocks
- sunset or night city lights

#### Transfer Corridor
- stairs
- direction signs
- corridor tiles
- escalators

#### Destination Arrival
- brighter platform lighting
- station signage
- subtle arrival emphasis

### 9.3 State-Based Scenes

Pixel scenes may change based on journey phase:

- WaitingForDeparture → platform
- OnTrain → tunnel / city
- ApproachingTransfer → station / corridor
- Transferring → transfer passage
- ApproachingDestination → destination platform
- Arrived → calm arrival scene

These scenes are decorative and must never be required for understanding the journey.

---

## 10. App Structure

The main app should be simple enough that users can begin a journey quickly.

Proposed top-level structure:

1. Home
2. Route Results
3. Train Selection
4. Active Journey
5. Recent Journeys
6. Settings

Avoid permanent tab bars unless user testing proves they improve navigation.

The product should feel journey-centric rather than feature-centric.

---

## 11. Home Screen

### 11.1 Purpose

Start a journey with minimal friction.

### 11.2 Suggested Layout

Top:
- TSUGINO wordmark
- subtle contextual pixel scene

Primary input:
- origin
- destination
- reverse button

Secondary:
- nearby stations
- recent journeys

Primary action:
- search routes

### 11.3 Home Visual Tone

The Home screen is where TSUGINO can show the strongest pixel identity.

The environment may include:

- a station platform
- an arriving train
- station signage
- ambient motion

The route input must remain visually dominant.

---

## 12. Station Search

Station search should be:

- fast
- forgiving
- usable in Japanese, English, and Korean
- easy to scan

Each result may show:

- station name in the resolved app language
- secondary Japanese name where it aids traveler confidence (§27.4)
- line badges
- operator
- nearby indicator

Avoid overwhelming the user with every line detail when unnecessary.

---

## 13. Route Results

### 13.1 Primary Information

Each route result should emphasize:

- departure time
- arrival time
- total duration
- transfers
- line sequence

### 13.2 Route Result Hierarchy

Primary:
- times
- duration

Secondary:
- line sequence
- transfer count

Tertiary:
- fare
- platform
- service details

### 13.3 Route Result Style

Prefer one strong route card over dense timetable tables.

Alternative routes should feel comparable without becoming visually identical.

---

## 14. Train Selection Screen

This screen is a core product differentiator.

### 14.1 Purpose

Allow the user to explicitly choose the train they intend to board.

### 14.2 Candidate Row

A candidate train may show:

- departure time
- realtime-adjusted time
- destination
- service type
- delay
- platform
- train identity where useful

### 14.3 Selected State

The selected train should feel unmistakable.

Selection should not rely only on color.

Use:

- checkmark
- strong outline
- clear selected label
- concise confirmation action

### 14.4 Primary Action

Suggested action:

> この電車に乗る  
> Ride this train

This action starts or confirms the tracked journey.

---

## 15. Active Journey Screen

The Active Journey screen is the richest in-app surface.

### 15.1 Primary Zone

Show:

- current line
- current station
- next station
- destination
- remaining stops
- ETA

### 15.2 Progress Representation

The journey should use a clean linear progression.

Suggested structure:

Current → Next → Upcoming → Destination

Avoid showing the entire long route if it becomes visually dense.

For long journeys, compress intermediate stations.

### 15.3 Remaining Stops

The remaining stop count should be visually strong.

Example:

> **あと 3駅**

English:

> **3 stops left**

### 15.4 Transfer State

Approaching transfer should visually shift priority.

Example:

> **次は赤坂見附**  
> 銀座線へ乗換

The next action is more important than the old line context.

---

## 16. Dynamic Island

Dynamic Island is a primary TSUGINO interface.

### 16.1 Design Principle

> Show the smallest amount of information that still answers the user's next question.

### 16.2 Minimal State

Possible contents:

- line badge
- stop count
- journey status mark

Example concept:

> `G · 2`

Meaning:

- Ginza Line
- 2 stops remaining

### 16.3 Compact State

Possible contents:

Leading:
- line symbol

Trailing:
- remaining stops or countdown

Examples:

> `G` | `あと2駅`

> `M` | `3 min`

### 16.4 Expanded State

Expanded view may include:

Top:
- line and direction

Center:
- current station → next station

Bottom:
- destination
- remaining stops
- ETA
- transfer cue

Example:

> 丸ノ内線  
> 四谷三丁目 → 四ツ谷  
> 新宿まで あと2駅

### 16.5 Transfer Expanded State

When transfer is approaching:

> まもなく赤坂見附  
> 銀座線へ乗換  
> 2号車がおすすめ

Only show car guidance when reliable.

### 16.6 Destination Expanded State

When destination is near:

> 次は新宿  
> あと1駅

or

> まもなく新宿  
> 降りる準備をしましょう

---

## 17. Lock Screen Live Activity

Lock Screen Live Activity should be more informative than Dynamic Island, while remaining substantially simpler than the main app.

The Lock Screen is primarily a **journey progress surface**, not an animated scene.

### 17.1 Layout Priority

Top:
- line / journey phase

Middle:
- origin-to-destination progress line
- small pixel train position
- current or most recently confirmed station

Bottom:
- destination
- remaining stops
- ETA
- transfer cue

### 17.2 Lock Screen Journey Progress

The Lock Screen should show a simplified journey progression between origin and destination.

Conceptually:

> 渋谷 ─── 🚃 ─── 新宿  
> 現在：原宿  
> あと2駅

The design should communicate:

- where the journey started
- where the journey ends
- approximately how far the train has progressed
- the current or most recently confirmed station
- how many stops remain

For long journeys, intermediate station names should be compressed rather than all displayed simultaneously.

Possible representations include:

- origin + current + destination
- origin + destination with a proportional train marker
- current station + remaining stop count
- current stop index such as `12 / 24駅`

The Lock Screen must remain readable without requiring the user to inspect a full station list.

### 17.3 Pixel Train Progress Indicator

A small pixel-art train may sit on the progress line between origin and destination.

The train should **move discretely when journey progress updates**, rather than attempting continuous high-frame-rate motion.

Its position should be derived from journey progress such as:

- completed stops / total stops
- confirmed current station index
- current leg progress

The pixel train is a visual progress cue, not a claim of precise physical train position.

### 17.4 Lock Screen Motion Rule

The Lock Screen must not depend on continuous animation.

When a station progression update arrives, the UI may briefly animate the pixel train to its new position.

Always-On or reduced-motion contexts must remain fully understandable in a static state.

The Lock Screen experience is:

> **state transition, not continuous simulation.**

### 17.5 Boarding Guidance

When waiting for departure:

- train
- destination
- departure time
- countdown
- platform if available

The progress line may remain at the origin until departure is confirmed.

### 17.6 In-Transit State

While riding, the Lock Screen should emphasize:

- current or last confirmed station
- next station where useful
- destination
- remaining stops
- journey progress
- small pixel train position

This is the default Lock Screen state for most of the journey.

### 17.7 Transfer Guidance

When approaching transfer:

- transfer station
- next line
- recommended car where supported
- walking estimate where supported

The transfer action temporarily becomes more important than the overall origin-to-destination progress.

### 17.8 Arrival State

When arriving:

- destination
- arrival confirmation
- optional exit guidance

The pixel train should visually resolve at the destination end of the progress line.

The Live Activity should then transition to a completed state and end cleanly.

---


## 18. Notifications

Notifications should be rare and useful.

### Priority Events

- departure approaching
- transfer approaching
- destination approaching
- journey disruption
- selected train cancellation

Avoid notifying for every station.

---

## 19. Transfer Guidance Design

### 19.1 Recommended Car

Display only when available.

Format example:

> **2号車がおすすめ**  
> Car 2 recommended

### 19.2 Recommended Door

If confidence is high:

> **右側 3番ドア付近**

English:

> Near door 3 on the right

### 19.3 Stair / Escalator / Elevator

Use clear icons and short labels.

Do not show a schematic unless the data quality is high enough to be useful.

### 19.4 Exit Guidance

If destination exit data exists:

> 新宿駅 東口へ  
> 8号車がおすすめ

This should appear only near destination, not throughout the entire trip.

---

## 20. Realtime Status Design

Realtime quality must be represented honestly.

Suggested states:

### Live
> Live

### Delayed Update
> Updating…

### Schedule Fallback
> Schedule

### Unavailable
> Realtime unavailable

Provenance states must be visually distinct — **live**, **scheduled**, **service status/Alert**, and **unavailable** — so that scheduled information can never masquerade as realtime, and a status/Alert notice is never read as vehicle progress (DEC-038, DEC-046). Under DEC-047 the nine Tokyo Metro lines and the Liner run in the **Scheduled Journey Guidance** tier: their journey timeline, progress indicator, and Live Activity carry the scheduled provenance treatment throughout (no live badge, no live styling), timetable-based motion must read as a schedule position rather than a train being observed, and a disruption status/Alert is surfaced above the scheduled timeline rather than hidden by it. Provisional tier labels (Phase 11 review): リアルタイム追跡 / Realtime Journey Tracking / 실시간 추적 and 時刻表ベース案内 / Scheduled Journey Guidance / 시간표 기반 안내. Final styling and localized copy are defined during implementation.

Avoid overexposing technical provider details to ordinary users.

---

## 21. Error and Recovery Design

Errors should focus on recovery rather than blame.

### Missed Train

> この電車には乗れませんでしたか？  
> 次の電車を選びます

### Wrong Train / Direction

> 選択した電車と移動状況が一致しません

Actions:
- choose current train
- reselect route
- continue with schedule

### Realtime Lost

> リアルタイム情報を一時的に取得できません  
> 時刻表をもとに表示しています

### Journey Interrupted

> 旅程を再確認してください

Actions:
- resync
- choose train
- end journey

---

## 22. Journey Motion System

Motion is an important part of TSUGINO's main-app identity.

The main app may visually express the train's movement through the pixel railway world while keeping live information fully readable.

### 22.1 Motion by Journey State

#### Stopped at Station
- pixel train is stationary
- platform environment is visible
- station name is prominent
- subtle idle environmental motion may occur

#### Departing
- train begins moving
- platform scenery moves away
- transition into tunnel or above-ground scene
- current station changes only when journey state confirms progression

#### Riding
- train remains visually in motion
- tunnel lights, skyline, tracks, or scenery may scroll
- motion creates the feeling of travel without pretending to show exact physical speed

#### Approaching Station
- environmental motion may slow
- station signage or platform elements begin to appear
- next station becomes more prominent

#### Stopped at Next Station
- motion resolves
- station name changes to the newly confirmed station
- next-station information advances
- remaining stop count updates

#### Transferring
- train scene transitions to a corridor, stair, escalator, or station-interior pixel environment

#### Arrived
- motion stops
- destination environment becomes calm and visually resolved

### 22.2 Dynamic Station Name

The main journey screen must update the displayed station name as the selected train progresses.

Example before progression:

> 現在：渋谷  
> 次：原宿

After arrival/progression confirmation:

> 現在：原宿  
> 次：代々木

The station name must be driven by Journey state and trusted realtime progression rather than by decorative animation timing.

Animation must never advance the station name independently of actual journey state.

### 22.3 Continuous Motion Is Main-App Only

The main app may use continuous or looping environmental motion such as:

- scrolling tunnel lights
- moving track elements
- city scenery
- passing platform objects
- subtle train vibration

Dynamic Island should not use continuous decorative motion.

Lock Screen Live Activity should use state-transition motion only.

### 22.4 Motion Fidelity

Motion should represent **travel state**, not exact physical simulation.

Do not imply:

- exact train speed
- exact tunnel position
- exact GPS distance

unless the underlying data actually supports that precision.

The pixel world should communicate:

> “the train is moving”

rather than:

> “the train is exactly here.”

### 22.5 Reduced Motion

When Reduce Motion is enabled:

- remove continuous scenery movement
- keep station and journey-state updates
- use fades or direct state changes
- preserve all critical information

---

## 23. Motion Guidelines

Motion should be subtle and purposeful.

Good uses:

- train departure
- scenery movement in the main app
- train progress movement
- station transition
- transfer phase change
- Live Activity state transition
- route card selection

Avoid:

- bouncing UI
- exaggerated physics
- excessive parallax
- fast decorative loops
- attention-seeking effects during travel
- continuous animation on system surfaces

---


## 24. Haptics

Haptics may reinforce:

- journey start
- train selection
- transfer approaching
- destination approaching
- successful journey completion

Haptics should be sparse.

---

## 25. Accessibility

TSUGINO must support:

- Dynamic Type
- VoiceOver
- sufficient contrast
- non-color-only state indication
- reduced motion
- large touch targets

Critical states such as:

- delay
- cancellation
- next station
- transfer

must never rely on color alone.

---

## 26. Japanese, English, and Korean Layout

The UI must be designed for all three languages from day one.

### 26.1 Language Resolution

The product language follows:

- Japanese device/app language → Japanese UI
- Korean device/app language → Korean UI
- all other languages → English UI

English is the global fallback language.

### 26.2 Japanese

Japanese is the primary local-language experience.

Use concise, transit-native wording.

### 26.3 English

English is both a first-class launch language and the fallback for all unsupported device languages.

Avoid fixed-width assumptions and provide compact short forms for constrained system surfaces.

### 26.4 Korean

Korean is a first-class launch language.

Korean transit copy should remain concise and natural rather than literal.

Examples:

> 2정거장 남음  
> 다음 신주쿠  
> 긴자선 환승  
> 2호차 추천

Station names should follow a consistent Korean localization/transliteration policy.

Where useful for travelers, the original Japanese station name may appear as secondary context inside the main app, but the primary system-surface label should follow the resolved app language.

### 26.5 Shared Layout Rules

Layouts must:

- avoid fixed-width text assumptions
- support truncation only when meaning remains clear
- prioritize station and line identity
- provide short-form system-surface copy
- remain readable with Dynamic Type
- handle long English text without breaking Japanese or Korean hierarchy

Dynamic Island content requires carefully localized short forms in all three languages.

---

## 27. Copy Style

### Japanese

Tone should be:

- concise
- natural
- polite without being formal
- transit-native
- calm

Avoid excessive keigo.

Examples:

> あと2駅  
> 次は新宿  
> 銀座線へ乗換  
> 2号車がおすすめ

### English

Tone should be:

- concise
- direct
- plain
- internationally understandable

Examples:

> 2 stops left  
> Next: Shinjuku  
> Transfer to Ginza Line  
> Car 2 recommended

### Korean

Tone should be:

- concise
- natural
- practical
- easy to understand at a glance
- suitable for travelers unfamiliar with the Japanese railway system

Avoid overly formal wording and avoid unnecessary particles when space is constrained.

Examples:

> 2정거장 남음  
> 다음 신주쿠  
> 긴자선 환승  
> 2호차 추천

For system surfaces, prefer short phrases over complete sentences.

---

### 27.4 Station Name Display

Primary station names follow the resolved app language.

Examples:

Japanese:
> 新宿

Korean:
> 신주쿠

English / fallback:
> Shinjuku

The main app may optionally show a secondary native Japanese label when it improves traveler confidence, but constrained surfaces should avoid duplicate labels unless space clearly permits.

---

## 28. Empty States

Empty states should be useful, not decorative filler.

Examples:

### No Recent Journeys

> 最近の移動はまだありません

### No Realtime Data

> リアルタイム情報は利用できません  
> 時刻表をもとに表示します

### Unsupported Car Guidance

Do not show an empty card. Simply omit the feature.

---

## 29. Loading States

Loading should be fast and quiet.

Use:

- lightweight skeletons
- progress indicators only when necessary
- no full-screen spinner for routine refreshes

Realtime refresh should not visually interrupt the journey.

---

## 30. Design Tokens

A future implementation should centralize:

- spacing
- corner radius
- typography
- color roles
- line colors
- icon sizing
- animation durations
- elevation / materials

Avoid per-screen visual constants.

---

## 31. Pixel Asset System

Pixel art should be built as reusable assets rather than one-off illustrations.

Possible categories:

- station platform modules
- train sprites
- tunnel modules
- skyline modules
- signage
- transfer corridor modules
- environmental props

This enables:

- reuse
- theme variation
- state-based composition
- smaller asset footprint

---

## 32. App Icon Direction

Preferred initial concept:

> **A compact pixel train front on a dark field**

Alternative concepts:

- station sign with `次`
- train + progress line
- abstract railway indicator

The icon should remain readable at small sizes and not depend on text.

---

## 33. Visual Reference Boundary

TSUGINO may learn from reference apps in terms of:

- Live Activity usefulness
- journey state presentation
- route progression

But TSUGINO must develop its own:

- layout
- iconography
- pixel art style
- color system
- brand voice
- information hierarchy

The goal is inspiration, not imitation.

---

## 34. Design Acceptance Criteria

A design is acceptable only if:

1. the next required action is obvious,
2. the user can identify the next station quickly,
3. remaining stops are easy to find,
4. transfer information becomes more prominent at the correct time,
5. realtime confidence is not overstated,
6. Dynamic Island remains legible at a glance,
7. Live Activity remains useful without opening the app,
8. Japanese, English, and Korean all fit without breaking hierarchy,
9. pixel art never reduces information clarity,
10. unsupported data is omitted rather than faked,
11. journey recovery is understandable,
12. dark mode remains visually coherent,
13. the main-app station name advances only from trusted Journey state,
14. main-app motion expresses travel without claiming unsupported physical precision,
15. Lock Screen progress remains understandable without continuous animation.

---

## 35. Product Design North Star

TSUGINO should feel like:

> **a calm realtime railway companion living in a small pixel city.**

The railway data is precise.  
The interface is modern.  
The world around it has character.

That contrast defines the product.
