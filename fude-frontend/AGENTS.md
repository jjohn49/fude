# Repository Guidelines

## Project Structure & Module Organization
- `fude-frontend/` — main iOS app source (SwiftUI).
- `fude-frontend/Views/` — feature UI (Dashboard, Food, Fitness, Profile, Auth, Components).
- `fude-frontend/ViewModels/` — view models and state.
- `fude-frontend/Models/` — data models.
- `fude-frontend/Services/` — networking, auth, storage, and integrations.
- `fude-frontend/Utilities/` — helpers, extensions, constants.
- `fude-frontend/Assets.xcassets/` — images, colors, app icon.
- `fude-frontendTests/` — unit tests.
- `fude-frontendUITests/` — UI tests.
- `UI_DESIGN.md` — product design direction and UI guidance.
- `PLAN.md` — phases, feature backlog, bugs.
- `fude-frontend.xcodeproj` — Xcode project.

## Build, Test, and Development Commands
- Open the project: `open fude-frontend.xcodeproj` (recommended for local dev).
- Build from CLI (Debug):
  - `xcodebuild -project fude-frontend.xcodeproj -scheme fude-frontend -configuration Debug build`
- Run unit tests (Simulator):
  - `xcodebuild -project fude-frontend.xcodeproj -scheme fude-frontend -destination 'platform=iOS Simulator,name=iPhone 15' test`

## Coding Style & Naming Conventions
- Indentation: 4 spaces.
- Swift naming: `PascalCase` for types, `camelCase` for properties/functions.
- File names should match primary types (e.g., `DashboardView.swift`).
- Favor small, composable SwiftUI views and keep view models focused.
- No repo-wide formatter/linter is configured; follow Swift API Design Guidelines.
- Primary audience is U.S.-based: use imperial units (lbs, oz, miles), U.S. spelling (e.g., "favorite"), and American-centric defaults where appropriate.

## Testing Guidelines
- Frameworks: XCTest + XCUITest.
- Naming: `SomethingTests.swift` in `fude-frontendTests/`, UI tests in `fude-frontendUITests/`.
- Add tests for new model logic, services, and critical view model behavior.

## Commit & Pull Request Guidelines
- Commit messages are short and descriptive (no enforced convention). Keep them in present tense when possible (e.g., `Add macro ring drilldown`).
- PRs should include:
  - A clear description of changes and rationale.
  - Testing notes (what you ran, or why not).
  - UI changes: before/after screenshots or simulator captures.

## Design & Product Notes
- Follow `UI_DESIGN.md` for visual direction, interactions, and feature intent.
- Many product decisions, do/don'ts, and UI patterns are outlined there; treat it as the primary design spec.
- Keep changes aligned with the app's analytical, high-contrast, dark-first UI.
- Major don'ts from `UI_DESIGN.md`:
- No emojis.
- Avoid AI-looking UI; keep it sharp, intentional, and human-designed.
- Borderless layout (no card outlines or table grid lines).
- Avoid stock iOS look; add purposeful visual personality.
- Planning, features, and bugs live in `PLAN.md`; keep it current when scope changes.

## Security & Configuration Tips
- Privacy is the top priority for this product.
- Handle sensitive data via `KeychainService` and respect local-only storage expectations.
- Update `PrivacyInfo.xcprivacy` if new data collection or access is introduced.

---

## Current Implementation State (Feb 2026)

### Completed Phases
- **Phase 1** (Dark-First Foundation) — complete.
- **Phase 2** (Custom Navigation & Tab Chrome) — complete.
- **Phase 3** (Macro Rings: Core Visuals, ring center metric) — complete.

### What Has Been Built

**Auth & Onboarding**
- Local-only auth: first launch asks for a name, session stored in Keychain (`KeychainService`).
- `AuthGateView` guards content; `AuthViewModel` manages state.
- Biometric lock (Face ID / Touch ID) toggle in Profile, handled by `BiometricService`.

**Dashboard**
- Concentric `ActivityRingsView` (Calories, Protein, Carbs, Fat — outermost to innermost).
- Ring center ZStack overlay in `DashboardView.heroCard`: shows remaining kcal (white) or over-goal (red).
- `RingLegendRow` below rings: color dot, label, progress bar, value text.
- `WeeklyInsightsView` bar chart — calorie intake for past 7 days.
- Water tracking widget: tap-to-add buttons (150/250/330/500ml), progress bar.
- `UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24)` hero card — sharp top (flush with nav bar), rounded bottom.
- Nav bar `toolbarBackground(Color.fudePerformanceBackground)` + `toolbarColorScheme(.dark)` — seamless with hero.
- Inline nav title shows time-of-day greeting + first name: `"Good morning, Hugh"`.

**Food**
- `FoodSearchView` — text search + barcode scanner modes, Recent/Favourites quick-access tabs.
  - Search results: "Your Foods" section (SwiftData cache) + "All Foods" section (network), deduplicated by `externalID`.
  - `FoodSearchViewModel.localResultCount` tracks the section split.
- `AddFoodEntryView` — `QuantityUnit` picker (Servings/Grams/lbs), unit-aware quick buttons, serving info caption.
- `EditFoodEntryView` — same `QuantityUnit` picker; `.onAppear` converts stored grams to servings.
- `FoodLogView` — date strip nav (prev/next), meal-grouped entries with `MacroPill` chips, `DayTotalsRow` footer with macro progress bars and remaining/over calories.
- `FoodDetailView` — full nutrition panel for a cached `FoodItem`.

**Profile**
- `ProfileView` — Account (name), Daily Goals (with Edit Goals button), Body Weight, Security (biometric toggle), Data (Reset App).
- `GoalsEditorView` — edit calorie/protein/carb/fat targets.
- `BodyWeightLogView` — log body weight entries with date; list of past entries.

**Fitness**
- `WorkoutListView` — list of logged workouts with type chips (placeholder for Phase 5+).
- `WorkoutDetailView` — detail view for a workout entry.

**Models**
- `UserProfile` — display name, macro targets, biometric lock flag. SwiftData.
- `DailyLog` — date, cached totals (calories/protein/carbs/fat/water). `recalculateTotals()` must be called after every entry change.
- `FoodEntry` — quantity in grams, meal name, notes, snapshot macros (denormalised at log time for historical accuracy), relationship to `DailyLog` and `FoodItem`.
- `FoodItem` — external ID, name, brand, macros per 100g, `servingSizeGrams`, `servingSizeDescription`, `cachedAt`.
- `BodyWeightEntry` — date + weight (kg). SwiftData.

**Services**
- `OpenFoodFactsService` — barcode lookup via OFF API (no key). Parses `servingSizeGrams` from serving_size string using Swift Regex.
- `FoodProxyService` — USDA text search via Go backend (API key kept server-side). `USDAFoodDTO` includes `servingSize` + `servingSizeUnit`.
- `BiometricService` — Face ID / Touch ID prompt.
- `KeychainService` — `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` for all items.

---

## Component Library (Views/Components/)

| Component | File | Notes |
|-----------|------|-------|
| `TopBarTitle` | `TopBarTitle.swift` | Inline nav bar title: `.title3.rounded.semibold`, 0.6pt kerning |
| `TopBarIconButton` | `TopBarIconButton.swift` | Icon-only toolbar button with `.fudeAccentPrimary` tint |
| `TopBarTextButton` | `TopBarTextButton.swift` | Text (+ optional SF symbol) toolbar button |
| `SectionHeader` | `SectionHeader.swift` | All-caps caption section label with accent underline |
| `KeyValueRow` | `KeyValueRow.swift` | Label + right-aligned value, optional monospaced value |
| `FudePrimaryButtonStyle` | `FudeButtonStyles.swift` | Filled capsule, `.fudeAccentPrimary` bg, black text |
| `FudeGhostButtonStyle` | `FudeButtonStyles.swift` | Ghost pill, tint-coloured text + `tint.opacity(0.12)` bg |
| `FudeToggleStyle` | `FudeToggleStyle.swift` | Custom toggle: accent-colored thumb |
| `EmptyStateView` | `EmptyStateView.swift` | Centered icon + title + message |
| `LoadingStateView` | `LoadingStateView.swift` | Centered spinner + message |

---

## Design Token Usage

All screens use the tokens defined in `Utilities/Extensions/Color+Fude.swift`:

```
Color.fudeBackground          // outermost app background (alias for fudePerformanceBackground)
Color.fudeSurface             // card/section backgrounds (alias for fudePerformanceSurface)
Color.fudePerformanceBackground  // #0E0F11 — darkest
Color.fudePerformanceSurface     // #17191C — cards
Color.fudeAccentPrimary          // bright cyan — primary actions, ring fills, tab selection
Color.fudeCalorieRing            // calorie ring fill
Color.fudeProtein                // protein ring/bar fill (blue)
Color.fudeCarbs                  // carbs ring/bar fill (yellow)
Color.fudeFat                    // fat ring/bar fill (salmon)
```

Toolbar pattern (all NavigationStack views):
```swift
.toolbarBackground(.visible, for: .navigationBar)
.toolbarBackground(Color.fudePerformanceBackground, for: .navigationBar)
.toolbarColorScheme(.dark, for: .navigationBar)
```

Sheet views add `.preferredColorScheme(.dark)`.

---

## Key Architectural Patterns

### QuantityUnit (food entry quantity)
`enum QuantityUnit: String, CaseIterable` is defined at module level (non-private) in `AddFoodEntryView.swift`. Both `AddFoodEntryView` and `EditFoodEntryView` reference it from the same module. Cases: `.servings` (default), `.grams`, `.lbs`. `quantityInGrams` converts to grams using `foodItem.servingSizeGrams`.

### FoodSearchViewModel section tracking
`FoodSearchViewModel.localResultCount: Int` holds the count of SwiftData-cached items at the front of the results array. `FoodSearchView` uses this to split `.results(let items)` into "Your Foods" (first `localResultCount` items) and "All Foods" (remainder). No section headers are shown when there's no split.

### DailyLog totals
`DailyLog.recalculateTotals()` **must** be called after every `FoodEntry` insert, edit, or delete. The macro snapshot fields on `FoodEntry` are denormalised at log time for historical accuracy.

### Custom tab bar
`MainTabView` uses `.safeAreaInset(edge: .bottom)` to render a custom dark tab bar, replacing the stock iOS tab bar entirely. This avoids white-flash issues on tab switches.

### Hero card shape
`UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24)` — top corners are sharp so the card flushes with the nav bar. Bottom corners are 24pt rounded. Never add `.padding(.horizontal)` to the hero card.

### Ring center overlay
The calorie ring center text is a `ZStack` overlay directly in `DashboardView.heroCard` — not part of `ActivityRingsView`'s API. `ActivityRingsView` only draws rings; center content is composed by the parent.

### PBXFileSystemSynchronizedRootGroup
New Swift files are auto-picked up by Xcode. No `.pbxproj` edits needed when adding files.
