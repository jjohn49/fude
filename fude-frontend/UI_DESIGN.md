# Fude — UI Design System

> **Location:** `fude-frontend/UI_DESIGN.md`
> Reference document for all design decisions, visual language, component specs, and planned improvements.
> Update this file whenever a design choice is made, changed, or resolved.
> Intended audience: any Claude session or developer working inside the Xcode project.

---

## Status (Feb 2026)

This document defines the visual system and interaction specs. Planning, phases, features, and bugs live in `PLAN.md`.

**Implemented (current state):**
- Phase 1 (Dark-First Foundation) — complete. All core screens use performance tokens, borderless layout, monospaced metric typography.
- Phase 2 (Custom Navigation & Tab Chrome) — complete. Custom tab bar via `safeAreaInset`, dark nav bars on all NavigationStacks, `TopBarTitle` inline titles, `TopBarIconButton`/`TopBarTextButton` toolbar items.
- Phase 3 (Macro Rings: Core Visuals) — complete. Concentric `ActivityRingsView` (Calories/Protein/Carbs/Fat). Ring center ZStack overlay in `DashboardView.heroCard` shows remaining kcal (white) / over-goal (red).
- `WeeklyInsightsView` bar chart on Dashboard.
- `DayTotalsRow` footer with macro progress bars and remaining/over calories in `FoodLogView`.
- Water tracking widget on Dashboard (tap-to-add buttons + progress bar).
- Body weight log (`BodyWeightLogView`) accessible from Profile.
- Food search: Recent + Favourites quick-access tabs; two-section results ("Your Foods" / "All Foods") when SwiftData cache exists alongside network results.
- Quantity unit picker (Servings/Grams/lbs) in `AddFoodEntryView` and `EditFoodEntryView`. Servings is the default; `servingSizeGrams` drives the conversion.
- Serving size parsing from OpenFoodFacts `serving_size` strings and USDA `servingSize`/`servingSizeUnit` fields.
- Full component library: `TopBarTitle`, `TopBarIconButton`, `TopBarTextButton`, `SectionHeader`, `KeyValueRow`, `FudePrimaryButtonStyle`, `FudeGhostButtonStyle`, `FudeToggleStyle`, `EmptyStateView`, `LoadingStateView`.

**Upgrade path items still pending:**
- Swipeable horizontal date selector in FoodLogView (replaces chevrons).
- Food search bottom-sheet redesign (currently a full-screen modal).
- Phase 4: macro ring → 7-day trend chart drilldown.
- Phase 5+: Workout tab map view, lifting tracker, HealthKit (blocked on paid dev account).

---

## I. Athletic Performance Direction (Strava / Apple Fitness / NRC inspired)

**Intent:** metrics-first, energetic, premium athletic feel without losing Fude clarity. The UI should read like a performance dashboard: big numbers, tight grouping, and confident contrast. No photography, no user photos, no custom fonts.
**Primary stance:** dark-mode-first, very high contrast, borderless surfaces, analytical and quantitative at the core.

**Core cues:**
- Data-as-hero: large numerals and ring progress visuals lead each screen.
- Energetic cards: subtle gradients and soft glow on hero cards only.
- High contrast: clear separation between background, surface, and data.
- Motion with purpose: ring sweeps, achievement pulses, card rise-in.

**Modes:**
- **Primary mode:** dark-first, high-contrast surfaces throughout the app.
- **Performance mode:** darkest, highest-contrast surfaces for Workout + Analytics (reinforced).

---

## II. Design Language — "Athletic Performance Minimalism"

Clean geometry, generous whitespace, strong numeric hierarchy. Scientific enough for accurate data; athletic enough to open after a hard workout. Borderless surfaces, no heavy outlines. Allow soft depth and subtle glow in hero areas.
Bold, full-width layouts with minimal side margins. Avoid the “stock iOS app” feel by adding controlled funk: asymmetric cards, confident typography scale, and distinctive ring/metric compositions.

**Funk without chaos (guidance):**
- Use asymmetry intentionally (e.g., oversized ring on left, stacked metrics on right).
- Crop rings at the edge of the screen to feel bold and in-motion.
- Let one “hero” number dominate each screen.
- Keep shapes simple but scale them aggressively.
- Use contrast and motion, not decoration, to create personality.

---

## III. Color Palette

**Decision: keep the existing macro palette defined in `Color+Fude.swift`. Do not reassign macro colors.**
Changing now would require touching every view. The current assignment is already consistent and readable.

### Brand & UI Tokens

| Token | Hex | Usage |
|-------|-----|-------|
| `fudeAccent` | `#E8682A` | Primary CTAs, ring fill, active states |
| `fudeBackground` | `systemGroupedBackground` | App background — adaptive light/dark |
| `fudeSurface` | `secondarySystemBackground` | Card/section backgrounds |
| `fudeLabel` | `label` | Primary text (system adaptive) |
| `fudeSecondary` | `secondaryLabel` | Subtitles, timestamps, captions |
| `fudeTertiary` | `tertiaryLabel` | De-emphasised metadata |
| `fudeGreen` | `#34A853` | Goals met, positive deltas |
| `fudeRed` | `systemRed` | Over-target, warnings, negative deltas |

### Performance Tokens (new)

| Token | Value | Usage |
|-------|-------|-------|
| `fudePerformanceBackground` | `#0E0F11` | Workout + Analytics backgrounds |
| `fudePerformanceSurface` | `#17191C` | Workout + Analytics cards |
| `fudePerformanceGlow` | `fudeAccent` @ 15–25% | Subtle glow for hero rings/cards |

**Gradient rule:** You may apply radial/linear gradients that blend `fudeAccent` with `fudePerformanceBackground` on hero rings or primary cards. Do not change macro colors; gradients are overlays only.
**Borderless rule:** Avoid visible borders and dividers; rely on spacing, contrast, and glow for separation.

### Macro Tokens (established — do not change)

| Token | Hex | Macro |
|-------|-----|-------|
| `fudeProtein` | `#4A8FE0` | Protein — blue |
| `fudeCarbs` | `#F0C518` | Carbohydrates — yellow |
| `fudeFat` | `#E87060` | Fat — salmon/orange-red |
| `fudeFiber` | `#34C87A` | Fiber — green |
| `fudeCalorieRing` | `#E87060` | Calorie ring fill |
| `fudeElectrolyte` | `#7B5EA7` | Electrolytes (workout cards) — purple |

### Workout Accent Tokens

| Token | Value | Usage |
|-------|-------|-------|
| Strength | `fudeProtein` (blue) | Strength training cards |
| Running | `#34C87A` (green) | Running cards |
| Burn ring | `#EF476F` (coral) | HealthKit calories burned ring (future) |

---

## IV. Typography

Font family: **SF Pro** (system default on iOS — do not specify a custom font unless a brand decision is made).

| Role | Style | Notes |
|------|-------|-------|
| Page title | `.largeTitle.bold()` | Navigation titles |
| Section header | `.headline` | Card titles, section labels |
| Body | `.body` | List items, descriptions |
| Data numbers | `.monospacedDigit()` | All numeric values — prevents layout shift |
| Captions | `.caption` + `.secondary` | Timestamps, units, metadata |
| Stat values | `.title2.bold().monospacedDigit()` | MacroStatCards, ring center |

**Rule:** Never hardcode a point size. Use semantic styles + Dynamic Type.
**Performance rule:** Hero metrics (ring center, workout timer) may use `.largeTitle` or `.title` and `.rounded()` for athletic warmth. Keep `.monospacedDigit()`.

---

## V. Spacing & Shape

**Grid:** 8pt base unit. All padding multiples of 8.

| Property | Value |
|----------|-------|
| Outer horizontal margins | `8–12pt` (favor near edge-to-edge) |
| Between cards | `16pt` |
| Inner card padding | `12–16pt` |
| Hero card padding | `16–20pt` |
| Primary card corner radius | `16pt` |
| Hero card corner radius | `20–24pt` |
| Button corner radius | `Capsule()` for primary pills; `12pt` for secondary |
| Form input radius | `10pt` |
| Shadows | Avoided generally — allow a soft, diffused shadow on hero cards only |
| Borders | Avoided; prefer separation via spacing and contrast |
| Width emphasis | Prefer full-width cards; avoid narrow columns or small tiles |

---

## VI. Screen-by-Screen Design Vision

---

### 1. Dashboard

**Current state (implemented):**
- `ActivityRingsView` — concentric rings: Calories (outer), Protein, Carbs, Fat (inner). Spring-animated on appear with 80ms stagger.
- Ring center overlay (ZStack in `DashboardView.heroCard`): large bold remaining-kcal number (white) + "remaining" caption; turns red with "over" when negative.
- `RingLegendRow` below rings: color dot, label, thin progress bar, "X / Y" value text.
- `WeeklyInsightsView` bar chart below rings.
- Water widget: tap-to-add buttons (150/250/330/500ml), capsule progress bar.
- Hero card: full-bleed, `UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24)`, gradient background from `fudePerformanceBackground` to `fudePerformanceSurface`. No horizontal padding — flushes with nav bar.
- Inline nav bar: `toolbarBackground(fudePerformanceBackground)`, `toolbarColorScheme(.dark)`. Title = time-of-day greeting + first name.

**Upgrade path — "Aura Rings" (implemented above, remaining items):**
- **Burn ring (future):** HealthKit-dependent outer ring showing calories burned. Not shown until Phase 8.
- **MacroBarView:** Replaced by `RingLegendRow` bars inside the hero card. No standalone MacroBarView on the dashboard.

**Micronutrients expand view (future/backlog):**
- A collapsible card below the rings that expands to show micronutrient totals.
- Default collapsed: top 3 micronutrients + disclosure indicator.
- Expanded: clean list with amounts and % daily value.
- Keep it analytical and dense, but readable.

```
┌─────────────────────────────────────────┐
│ Good morning, Alex            [avatar]  │
├─────────────────────────────────────────┤
│                                         │
│          ╭──────────────╮               │
│        ╭─┤   640 kcal   ├─╮            │
│        │ │  remaining   │ │            │
│        ╰─┤              ├─╯            │
│          ╰──────────────╯               │
│     Outer: consumed  Inner: burned      │
│                                         │
│  [Protein card] [Carbs card] [Fat card] │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  Weekly Insights (bar chart)    │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  Today's Timeline               │    │
│  │  8:00  Breakfast  450 kcal      │    │
│  │  12:30 Gym session  320 burned  │    │
│  │  13:15 Lunch  620 kcal          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ╔═══════════════════════════════════╗  │
│  ║        + Log Food                ║  │
│  ╚═══════════════════════════════════╝  │
└─────────────────────────────────────────┘
```

**Dashboard timeline (future feature):**
A chronological feed of today's food events and workout events in one scrollable list. Food and workout events appear interleaved by time of day. This replaces or extends the current static sections.

**Athlete summary strip (new):**
A compact horizontal row under the rings showing 2–3 key metrics (e.g., streak, calories burned, steps). Use icon + number + short label. This gives an immediate "performance glance" similar to fitness apps.

**Insights + recommendations (new):**
Add a short, data-driven insights section that ties training load to nutrition guidance.
- Example: If weekly running volume is high, recommend increased carbs.
- Example: If a workout was logged today, suggest protein intake within ~5 hours of lifting.
- Keep copy factual and analytical (no emojis, no casual tone).

**Rings → trends drilldown (new):**
Tapping the macro rings expands them into a weekly trend view.
- Animated “unravel” from rings into a line chart in the **same hero canvas** (no separate top chart card).
- Shows Calories, Protein, Carbs, and Fat as four lines.
- Default range: last 7 days.
- Keep labels minimal and numeric (analytical, not decorative).
 - **Motion direction:** ring cluster spins, then rings unwrap sequentially into their corresponding trend lines.
 - **Staging:** per-ring stagger in outer→inner order; each line draws left→right after its ring unwrap starts.
 - **Transition feel:** confident and fluid, no bounce.
 - **Reverse interaction:** tapping the same hero canvas (or "Back to Rings") reverses the morph back to concentric rings.
 - **Supporting panel:** micronutrient details (fiber/sugar/sodium) expand below the ring legend in `MacroTrendDrilldownView`.

**Post-workout recovery window (anabolic window, new):**
A dashboard widget that appears after a logged workout (HealthKit future). It includes a countdown + two progress bars tracking post-workout intake.
- **Countdown duration (practical):** 4 hours from workout end.
  - Rationale: encourages timely intake while acknowledging that the physiological response is longer-lived.
- **Two tracked macros:** Protein and Carbs (most relevant for recovery and glycogen repletion).
- **Workout-type targeting (default, configurable):**
  - **Resistance-focused sessions:** Protein is primary.
    - **Protein target:** 0.25–0.4 g/kg body weight (or 20–40 g if weight unknown).
    - **Carb target (secondary, product default):** 0.5 g/kg over the 4-hour window.
  - **Endurance-focused sessions (run/cycle):** Carbs are primary.
    - **Carb target:** 0.6–1.0 g/kg within 30 minutes post-exercise, then repeat every 2 hours for the first 4–6 hours (use the 4-hour window for the dashboard timer).
    - **Protein target:** 0.25–0.4 g/kg body weight (or 20–40 g if weight unknown).
- **Progress bars:** show grams consumed since workout end vs target.
- **Copy tone:** “Recovery window” instead of “anabolic window” to avoid myth framing.

**Recovery window decision table (workout-type logic):**

| Workout type | Primary macro | Protein target | Carb target | Progress bars shown |
|--------------|---------------|----------------|------------|---------------------|
| Resistance (lift) | Protein | 0.25–0.4 g/kg (or 20–40 g) | 0.5 g/kg (secondary) | Protein + Carbs |
| Endurance (run/cycle) | Carbs | 0.25–0.4 g/kg (or 20–40 g) | 0.6–1.0 g/kg within 30 min, then repeat every 2 hours (4–6 hours) | Carbs + Protein |

**Mixed workout rule (fallback):**
- If the session mixes strength + endurance, choose the primary macro by dominant activity:
  - If endurance duration is ≥ 60% of total workout time, treat as endurance (carbs primary).
  - If strength duration/sets are ≥ 60% of total workout time, treat as resistance (protein primary).
- If dominance is unclear, default to Protein primary and show both bars.

**Avatar/greeting:**
- Show initials avatar (first letter of display name) — no photos
- Greeting text personalised: "Good morning, [name]"
- Do NOT add a camera/photo picker — out of scope

**Cut from dashboard:**
- ❌ "Start Workout" quick action card — dead UI until session tracking exists. Replace with a "Today's goal" or water widget
- ❌ User photo avatar — initials only

**Water placement:** Water tracking is secondary. If present, it should be a small, low-visual-weight widget, never the primary hero card.

---

### 2. Food Log / Diary

**Current state (implemented):**
- Prev/next chevron date navigation in nav bar.
- Meal-grouped entries with `MacroPill` chips (color-coded macros per entry).
- `DayTotalsRow` footer: macro progress bars + remaining/over calories.
- Context-menu delete on entries. Tap-to-edit via `EditFoodEntryView`.
- `FoodSearchView`: text search + barcode scanner. Recent/Favourites quick tabs. Two-section search results ("Your Foods" from SwiftData cache, "All Foods" from network). Full-screen modal.
- `AddFoodEntryView` / `EditFoodEntryView`: `QuantityUnit` segmented picker (Servings default / Grams / lbs). Unit-aware quick buttons. Serving info caption ("1 serving = Xg"). Edit view converts stored grams back to servings on open.

**Upgrade: swipeable horizontal date selector (replaces chevrons)**

The current chevrons work but feel like pagination. Replace with a horizontal strip of day chips that the user can scroll/swipe, matching the "Diary" pattern from popular calorie apps.

```
┌──────────────────────────────────────────┐
│  < Oct  [M13][T14][W15][T16][F17][S18] > │
│                        ^^^^ today        │
├──────────────────────────────────────────┤
│  Breakfast                      523 kcal │
│    Oats 80g          P12  C52  F3  317k  │
│    Banana 120g       P1   C27  F0  107k  │
│  Lunch                          712 kcal │
│    ...                                   │
├──────────────────────────────────────────┤
│  Total: 1,235 / 2,000 kcal               │
│  [protein bar][carb bar][fat bar]         │
│  640 kcal remaining    ✓                 │
└──────────────────────────────────────────┘
```

**Date selector spec:**
- 7 day chips visible, centred on today
- Each chip: day letter + date number (e.g. "F\n17")
- Selected chip: filled orange pill
- Scroll left for older dates (no limit), scroll right capped at today
- Swipe gesture on the list body also advances the date (push-style animation)

**Food search — bottom sheet redesign (high priority):**

Replace the current full-screen modal with a 90% bottom sheet. Add tabs at the top of the search results:

```
╭──────────────────────────────────────╮
│  ○ Search foods…          [barcode]  │
│  ─────────────────────────────────── │
│  [Recent]  [Favourites]  [Custom]    │
│  ─────────────────────────────────── │
│  > Oats 80g               317 kcal  │
│  > Chicken breast 150g    248 kcal  │
│  > Banana 120g            107 kcal  │
╰──────────────────────────────────────╯
```

- **Recent tab (default):** Last 10 unique food items logged, most recent first. Two-tap logging.
- **Favourites tab:** Items the user has manually starred or auto-promoted (logged 5+ times).
- **Custom tab:** Future — user-defined foods.
- **Barcode:** Floating FAB or tab, opens `BarcodeScannerView`.

**Entry editing (future):**
- Tap a logged entry row → edit sheet to change quantity, meal, notes
- Currently only swipe-to-delete is implemented

---

### 3. Active Workout Session (future)

This is a large standalone feature. Design it as a dark-mode context regardless of system setting (`.colorScheme(.dark)` on the workout session view).

**Design principles for workout screen:**
- Touch targets: minimum 56×56pt (sweaty fingers)
- High contrast: white text on `#121212` background
- No small text anywhere visible during an active set
- Performance accents: strong, single-color progress indicators or highlights per set
- Primary numbers should feel bold and athletic (large, clear, monospaced)

**Lifting tracker (new):**
Users can add exercises, sets, reps, and weight used per set. This is the core for strength training.
- Exercise list is ordered and sequential (the session is a timeline).
- Each exercise includes a set table with weight + reps fields per set.
- Allow quick-add sets and copy previous set values.
- Capture set timestamps to support future heart-rate/effort analysis per exercise.

**Workout data model hints (future):**
- `WorkoutSession` → ordered `ExerciseBlock[]`
- `ExerciseBlock` → `ExerciseRef`, `Set[]`, `startAt`, `endAt`
- `Set` → `weight`, `reps`, `completedAt`
- Link `Set.completedAt` to heart-rate samples to compute effort by exercise segment
 - For endurance sessions, store `routePolyline`, `startLocation`, `endLocation`

**Future recommendations (not yet implemented):**
- Suggest workout additions based on gaps (e.g., lack of pulling volume).
- Suggest target weights or progression when the user consistently exceeds reps.
- Keep tone analytical, avoid coaching hype.

**Workout tab structure (new):**
- Two primary views with a segmented switch:
  - **Map view (run mode focus):** full-bleed map showing recent routes. Long-term goal: overlay all routes in history on a single map.
  - **List view:** chronological list of workouts (runs + lifts).
- Tapping the map routes to a Workout Summary page (future, HealthKit): time, calories burned, miles, geolocation, route preview.
- Weight training requires its own UI within the list/detail flow (sets, reps, volume, PRs).

**Workout Summary (future, HealthKit):**
Shown when a route or workout is selected. This is a data-first summary, not a story card.
- **Primary metrics:** total time, total distance (miles), calories burned.
- **Secondary metrics:** average pace, elevation gain, average heart rate (if available).
- **Route panel:** map thumbnail with route polyline + start/end markers.
- **Location:** city/region label derived from geolocation.
- **Notes:** no imagery, no emojis, no social sharing UI in MVP.

**HealthKit data dependencies (future):**
- Active energy burned
- Workout duration
- Distance walking/running
- Route polyline (workout route)
- Workout type and timestamps
- Heart rate (average)
- Elevation gain (if available)
- Workout geolocation summary (city/region)

**Set tracker layout:**

```
●  Pull Day Vol. 1          00:45:12
─────────────────────────────────────
     BARBELL DEADLIFT
     Last session: 100kg × 5 × 3    ← progressive overload reference

  Set  │  Prev   │  kg   │  Reps  │  ✓
  ───────────────────────────────────
  1    │  100×5  │ [100] │  [5]   │  ✓ (done, coral bg)
  2    │  100×5  │ [100] │  [ ]   │  ○ (active row)
  3    │  100×5  │ [   ] │  [ ]   │  ○
─────────────────────────────────────
  ╔═══════════════════════════════╗
  ║      + Add Set                ║
  ╚═══════════════════════════════╝

╭──── Rest  01:12  ─────────────────╮
│ Last: 100kg × 5    [-15s]  [+15s] │
│              [Skip Rest]          │
╰────────────────────────────────────╯

  ╔═══════════════════════════════╗
  ║   Finish Workout   (coral)    ║
  ╚═══════════════════════════════╝
```

**Custom numeric keypad:**
- Oversized keys (min 56pt), dark background
- Shows when tapping kg or reps input
- Pre-fills from previous session's value for that exercise
- Not the standard iOS keyboard

**Progressive overload reference (critical feature):**
- Every exercise card shows the most recent logged session's weights/reps
- Format: "Last session: [weight]kg × [reps] × [sets], [n days] ago"
- If user beats their last session, show a subtle animation/haptic

**Cut from workout screen:**
- ❌ Video exercise previews — requires a content library. Cut from MVP.
- ❌ Muscle group stacked bar chart — requires exercise tagging. Backlog.

---

### 4. Analytics / Progress

**Layout:**

```
[Nutrition ●]  [ Training  ]     [7d ▾]
─────────────────────────────────────────
Nutrition view:
  Weight trend (line chart, 30 days)
  Daily calorie intake (bar chart, this week)
    → Bars over goal: red
    → Bars at/under goal: green/orange

Training view:
  Workout heatmap (GitHub-style grid, current month)
    → Darker = more volume
  Volume chart (total kg lifted per week)
  Streak counter: 14 days
```

**Time range selector:**
- Pill toggle: 7d / 30d / 3mo
- Applies to all charts on the current tab
- Without this, training progress graphs are meaningless

**Weight log entry point:**
The analytics weight chart requires data input. Add a weight logging widget — either a persistent card on the Dashboard ("Log today's weight") or a prompt inside the Analytics view when no data exists.

**Cut from analytics:**
- ❌ Stacked bar chart by muscle group — requires exercise muscle group tagging. Future.

---

### 5. Profile

**Current:** Goals editor (calories, protein, carbs, fat) + Face ID toggle.

**Future additions:** See `PLAN.md`.

---

## VII. Micro-Interactions & Haptics

| Trigger | Feedback |
|---------|----------|
| Check off a workout set | `.light` haptic tap |
| Food entry logged successfully | `.soft` haptic |
| Daily calorie goal reached | Success vibration (`.notificationOccurred(.success)`) |
| Streak milestone | Success vibration + brief animation |
| Calorie ring animates on load | 0→current fill, 800ms ease-out cubic bezier |
| Date navigation swipe | Push animation (content slides left/right) — not fade |
| Over goal warning | Ring and remaining text turn `fudeRed` |
| Food added | Rings animate to new macro totals with a smooth fill and subtle glow ramp |
| Macro target hit | Brief pulse on the specific macro ring (calories/protein/carbs/fat) |

**Motion spec examples (fluid, dark-first):**
- **Ring fill on food add:** `550ms`, cubic-bezier(0.22, 1.0, 0.36, 1.0). Animate each macro ring from previous value to new value; ramp glow during first 120ms.
- **Macro target hit pulse:** `220ms`, ease-out. Ring stroke thickens + 6% scale pulse, then returns.
- **Dashboard card rise-in:** `300ms`, cubic-bezier(0.2, 0.9, 0.2, 1.0). Fade 0→1 and translate `8pt` upward.
- **Ring sweep on load:** `800ms`, cubic-bezier(0.16, 1.0, 0.3, 1.0). Sweep 0→current value; stagger macro rings by `60ms`.
- **Rings → trend morph (in-place):** `~1050ms` expand, timing-curve `(0.18, 0.84, 0.24, 1.0)`. Sequence: spin ring cluster → unwrap each ring with stagger (`~120ms`) → draw each line in order.
- **Trend → rings reverse:** `~700ms` collapse using the same interaction surface; reverse the unwrap/line draw sequence back to concentric rings.
- **Insight chip highlight:** `180ms`, ease-out. Background gradient ramps to `fudeAccent` at 15% then returns.

Respect `@Environment(\.accessibilityReduceMotion)` — disable all non-essential animations when enabled.

---

## VIII. Accessibility

- All icon-only buttons must have `.accessibilityLabel`

---

## IX. Do / Don't (Athletic Performance, Dark-First)

**Do:**
- Keep the UI borderless; use spacing and contrast to separate content.
- Make metrics the hero: large numbers, rings, and concise labels.
- Use macro rings (Calories, Protein, Carbs, Fat) as the primary dashboard visualization.
- Keep analytics dense but scannable; prioritize quantitative clarity.
- Keep water tracking visibly secondary.
- Use high-contrast dark surfaces with bright, controlled accents.
- Keep surfaces clean and intentional to avoid an auto-generated look.
- Give the Workout tab a map-first view for running routes, with a list view as the secondary mode.

**Don't:**
- Don’t introduce visible borders, heavy dividers, or card outlines.
- Don’t push water tracking as a primary hero element.
- Don’t use emoji anywhere in the UI or design docs.
- Don’t add decorative fluff, random gradients, or inconsistent spacing.
- Don’t add photo avatars, illustrations, or “AI-styled” ornamental elements.

---

## X. Security & Privacy (Non-Negotiable)

This app is privacy-first. We do not store user data on external servers and do not plan to do so without explicit consent. All data is stored locally on the user’s device and accessed via Apple privacy APIs (e.g., HealthKit). Any future sync or sharing must be opt-in, clearly explained, and reversible.
- Minimum tap target: **44×44pt** (workout screens: 56×56pt)
- Color never the sole conveyor of information — macros use color + text label
- Dynamic Type: no hardcoded font sizes
- VoiceOver: calorie ring reads "X of Y calories consumed, Z remaining"
- Workout set rows read as "Set N, [weight] kilograms, [reps] reps, [done/pending]"

---

Planning, open decisions, and backlog live in `PLAN.md`.
