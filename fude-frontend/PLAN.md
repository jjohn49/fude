# Planning & Phases

This repository tracks product and implementation planning in this file. Use it as the source of truth for phases, features, and bugs. UI direction, visuals, and motion specs live in `UI_DESIGN.md`. Component library, architecture patterns, and build context live in `AGENTS.md`.

## Phase 1 — Dark-First Foundation ✅ Complete
- Apply dark-first defaults across core screens (Dashboard, Food, Workout, Profile).
- Replace light surfaces with performance tokens where appropriate.
- Enforce borderless layout (no card outlines or table dividers).
- Normalize typography for metrics (monospaced digits, large hero values).
- Reduce side margins; push content near edge-to-edge for a bold, analytical feel.

## Phase 2 — Custom Navigation & Tab Chrome ✅ Complete
- Replace stock iOS chrome with custom visual styling for navigation bars, toolbars, and tab bars.
- Standardize title typography (inline + large) to feel bold and athletic.
- Apply consistent accent color for primary actions and tab selection.
- Ensure no white flashes on tab switches or button taps.
- **Implemented:** Custom tab bar via `safeAreaInset`, `TopBarTitle`/`TopBarIconButton`/`TopBarTextButton` components, `toolbarBackground(fudePerformanceBackground)` + `toolbarColorScheme(.dark)` on all NavigationStacks.

## Phase 3 — Macro Rings: Core Visuals ✅ Complete
- Macro rings (Calories, Protein, Carbs, Fat) become the primary dashboard hero.
- Each ring has clear labels and a strong center metric for immediate scan.
- Rings should read as quantitative instruments, not decorative graphics.
- Keep water tracking secondary and visually de-emphasized.
- **Implemented:** `ActivityRingsView` (concentric, spring-animated). Ring center ZStack overlay in `DashboardView.heroCard`: remaining kcal (white) / over-goal (red). `RingLegendRow` with per-macro progress bars. Water widget de-emphasised below hero card.

## Phase 4 — Macro Rings: Drilldowns & Trends ✅ Complete
- Tap ring cluster to “unravel” into a 7‑day line chart of calories + macros.
- Preserve macro color mapping in the trend chart.
- Include a micronutrients expansion section in the drilldown panel.
- **Implemented:** `DashboardView` ring cluster toggles a `RingTrendMorphView` in the same hero canvas area (no separate chart card). Tapping rings triggers a staged spin→unravel animation into a 7-day multi-line trend (Calories/Protein/Carbs/Fat), preserves macro color tokens, and includes an expandable micronutrients section (`MacroTrendDrilldownView`) below the legend (fiber/sugar/sodium) computed from logged entries.
- **Animation behavior:** expand transition is sequential (rings spin, then each ring unwraps into its corresponding trend line with per-ring staggering). Collapse uses the same surface tap/back action and reverses back to concentric rings.

## Phase 5 — Workout Tab: Map + List
- Two‑mode Workout tab: map-first view and list view of all workouts.
- Map view supports route overlays and tap‑through to workout summary.
- Map interactions: tap a route to focus, pinch to zoom, minimal controls.
- Prepare an “all routes” history map that aggregates paths over time.
- List view shows time, duration, distance, calories, and workout type chips.
- Include a UI for weight training alongside endurance runs.
- Workout summary card shows duration, distance, calories, pace, and location.

## Phase 6 — Lifting Tracker & Sequential Logging
- Lifting tracker supports exercises, sets, reps, weight, and order.
- Sequential logging is required for lifting workouts to align HR/effort per set.
- Per‑set timestamps enable future analytics and recovery insights.
- Prepare data model for recommendations (load, volume, progression).
- Workout list filters for strength vs endurance.

## Phase 7 — Recovery Window + Insights Engine
- Dashboard shows post‑workout recovery timer and macro progress bars.
- Workout type determines primary/secondary macro targets:
  - Resistance: Protein primary, Carbs secondary.
  - Endurance: Carbs primary, Protein secondary.
- Anabolic window behavior:
  - 4‑hour countdown from workout end.
  - Two progress bars (primary + secondary macro only).
  - Track intake since workout end; reset per workout.
  - Neutral nudge if window expires before targets are met.
- Insights panel surfaces weekly volume, trends, and nutrition nudges.

## Phase 8 — HealthKit & Privacy-First Data Hooks
- Integrate HealthKit for workouts, timestamps, calories burned, and routes.
- Expand workout summary model to include geolocation and route polylines.
- Privacy messaging is visible in onboarding and settings.
- **Blocked:** HealthKit integration requires a paid Apple Developer account.
- **Interim:** use mock data to validate UI and analytics flows.

## Phase 9 — Motion Polish & High-Impact Micro-Interactions
- Fluid ring fills on food add and macro progress updates.
- Staggered dashboard card entrances and subtle glow ramps.
- Motion must feel athletic and technical, not playful.
- Respect Reduce Motion while preserving state clarity.

## Feature Backlog (Priority Ordered)

| Priority | Feature | Description | Depends on | Status |
|----------|---------|-------------|------------|--------|
| 1 | Swipeable date selector | Replace chevrons in FoodLogView with horizontal scroll strip | Nothing | Pending |
| 2 | Remaining calories in ring center | `target - consumed` in ring center | Nothing | ✅ Done |
| 3 | Water tracking | Daily tap counter on Dashboard | `waterMl` field on `DailyLog` | ✅ Done |
| 4 | Bodyweight logging | Date + weight entries, powers analytics chart | `BodyWeightEntry` model | ✅ Done |
| 5 | Recent foods tab in search | Default tab showing last 10 logged items | Query `FoodEntry` sorted by `loggedAt` | ✅ Done |
| 6 | Meal favourites | Auto-promoted foods logged 5+ times | Frequency query on `FoodItem` | ✅ Done |
| 7 | Entry tap-to-edit | Tap a logged entry to change qty/meal | `EditFoodEntryView` | ✅ Done |
| 7a | Serving unit picker | Servings/Grams/lbs in Add + Edit food views | `QuantityUnit` enum, `FoodItem.servingSizeGrams` | ✅ Done |
| 7b | Local-first search results | SwiftData cache shown immediately; network results in "All Foods" section | `FoodSearchViewModel.localResultCount` | ✅ Done |
| 8 | Phase 4 — ring drilldown | Tap rings to expand into 7-day trend chart | Nothing | ✅ Done |
| 9 | Workout session tracking | Active workout with set/rep logging | New `WorkoutSession` + `ExerciseSet` models | Phase 5+ |
| 10 | Exercise library | Searchable exercise list with muscle group tags | New `Exercise` model | Phase 6 |
| 11 | Progressive overload display | Show last session's numbers when logging a new set | Depends on 9+10 | Phase 6 |
| 12 | Workout templates | Save and re-load a workout structure | Depends on 9+10 | Phase 6 |
| 13 | Analytics weight chart | Line chart of bodyweight over time | Depends on 4 (done) | Pending |
| 14 | Analytics training heatmap | GitHub-style workout calendar | Depends on 9 | Phase 5+ |
| 15 | Nutrition day adjustment | Adjusted macro targets on workout days | Depends on 9 | Phase 7 |
| 16 | HealthKit integration | Real workout sync, burn ring | Paid developer account | Phase 8 |

## Features Deliberately Cut

| Feature | Reason |
|---------|--------|
| User photo avatar | Local-only app, no external photos needed. Initials only. |
| Video exercise previews | Requires a content library or external API. Out of scope for MVP. |
| "Start Workout" dashboard card | Dead UI until workout session tracking exists (priority 8). |
| Stacked bar chart by muscle group | Requires exercise tagging (priority 9). Backlog. |
| Macro color reassignment | Existing palette consistent throughout codebase. Cost > benefit. |

## Components Inventory

| Component | File | Status |
|-----------|------|--------|
| `ActivityRingsView` | `Views/Dashboard/ActivityRingsView.swift` | ✅ Implemented — concentric rings, spring-animated |
| `WeeklyInsightsView` | `Views/Dashboard/WeeklyInsightsView.swift` | ✅ Implemented |
| `MacroTrendDrilldownView` | `Views/Dashboard/MacroTrendDrilldownView.swift` | ✅ Implemented |
| `RingTrendMorphView` | `Views/Dashboard/RingTrendMorphView.swift` | ✅ Implemented — in-place rings→line-chart morph animation |
| `TopBarTitle` | `Views/Components/TopBarTitle.swift` | ✅ Implemented |
| `TopBarIconButton` | `Views/Components/TopBarIconButton.swift` | ✅ Implemented |
| `TopBarTextButton` | `Views/Components/TopBarTextButton.swift` | ✅ Implemented |
| `SectionHeader` | `Views/Components/SectionHeader.swift` | ✅ Implemented |
| `KeyValueRow` | `Views/Components/KeyValueRow.swift` | ✅ Implemented |
| `FudePrimaryButtonStyle` | `Views/Components/FudeButtonStyles.swift` | ✅ Implemented |
| `FudeGhostButtonStyle` | `Views/Components/FudeButtonStyles.swift` | ✅ Implemented |
| `FudeToggleStyle` | `Views/Components/FudeToggleStyle.swift` | ✅ Implemented |
| `EmptyStateView` | `Views/Components/EmptyStateView.swift` | ✅ Implemented |
| `LoadingStateView` | `Views/Components/LoadingStateView.swift` | ✅ Implemented |
| `DayTotalsRow` | `Views/Food/FoodLogView.swift` | ✅ Implemented |
| `BodyWeightLogView` | `Views/Profile/BodyWeightLogView.swift` | ✅ Implemented |
| `EditFoodEntryView` | `Views/Food/EditFoodEntryView.swift` | ✅ Implemented |
| `DateStripSelector` | `Views/Food/FoodLogView.swift` | Planned (replaces chevrons — backlog #1) |
| `WorkoutSessionView` | `Views/Fitness/` | Phase 5+ |
| `SetTrackerView` | `Views/Fitness/` | Phase 5+ |
| `RestTimerDrawer` | `Views/Fitness/` | Phase 5+ |

## Open Decisions

- **Concentric ring implementation** — adopt the Aura Rings pattern (outer=food, inner=burn)? Decide whether the inner ring shows before HealthKit ships.
- **Design theme final choice** — Minimal Warm (A) vs Militaristic (B) vs Liquid Glass (C). Currently tracking A.
- **Dark mode** — Option A and C support it adaptively. Option B is dark-first. If staying with A, test dark mode appearance before shipping.
- **Water tracking model** — add a field to `DailyLog` (simpler) or a separate `WaterEntry` model (more flexible)?
- **Bodyweight model** — separate `BodyWeightEntry` model with `date + kg` fields, stored in SwiftData.
- **Food entry editing** — tap to edit quantity/meal, or delete-and-re-log?
- **Weekly chart depth** — calories only, or toggle to show protein/carbs/fat bars?
- **Net calories** — once HealthKit is live, should ring center show net (consumed − burned) or remaining (goal − consumed)?

## Bugs & Issues

- **Tab bar/toolbar flashing** — custom `safeAreaInset` tab bar should eliminate the stock tab bar flash. If NavigationStack push/pop transitions still flash, investigate `Color.fudePerformanceBackground.ignoresSafeArea()` placement inside each tab's root view.
- **Profile screen vertical lines** — `.scrollIndicators(.hidden)` and `.scrollContentBackground(.hidden)` have been added to `ProfileView`. Still unresolved if visible in simulator; likely a nested `NavigationStack` or `List` scroll indicator rendering issue.
- **Food log entry deletion missing in custom UI** — `Views/Food/FoodLogView.swift` currently has no delete affordance in the non-stock list layout. Restore delete functionality (previously available in the old list-based iteration) while preserving the current custom visual style.
- **Auth screen giant white bar** — auth/onboarding screen shows a large white bar occupying roughly half the screen, breaking the dark-first visual baseline and layout.

## Constraints
- HealthKit integration is blocked until a paid Apple Developer account is available.
- Privacy-first posture is mandatory; no external storage without explicit consent.

## Where To Update
- Update phase definitions or sequencing here first.
- Update UI-specific specs, visuals, and motion details in `UI_DESIGN.md`.
