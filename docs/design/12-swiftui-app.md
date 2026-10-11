# Design: Native SwiftUI App

Implements: `docs/requirements/12-swiftui-app.md` (and carries forward the behaviour specified in requirements `01`–`10`).

## Project layout

A new top-level folder, `WorkoutTracker/`, holds the native app. The existing `index.html`, `www/`, `ios/` (Capacitor) are untouched for now.

```
WorkoutTracker/
  project.yml                 XcodeGen spec -> generates WorkoutTracker.xcodeproj
  App/
    WorkoutTrackerApp.swift   @main, owns AppStore, injects via .environment
    Models.swift              Codable data types + tolerant decoding
    SeedPlans.swift           the three seeded plans
    PlanImport.swift          pure JSON -> WorkoutPlan parser/validator
    Stats.swift               pure progress-stat functions
    Backup.swift              backup file type + merge-by-id
    AppStore.swift            @Observable store: state, persistence, all mutations
    RestTimer.swift           @Observable countdown (tick-driven, testable)
    Haptics.swift             thin wrappers over UIKit feedback generators
    Theme.swift               Neon Sport colors
    ProgressionData.swift     static progressions reference content
    Views/                    SwiftUI views (below)
  Tests/                      XCTest unit tests for the pure/logic layers
```

The Xcode project is generated with **XcodeGen** (`project.yml`) rather than hand-written, because a `.pbxproj` can't be authored or verified reliably without Xcode. Locally: `brew install xcodegen && cd WorkoutTracker && xcodegen`. CI does the same. The generated `.xcodeproj` is git-ignored.

Targets: `WorkoutTracker` (iOS app, bundle id `com.sunilboreddy.workouttracker`, iOS 17.0, Swift language mode 5, portrait iPhone) and `WorkoutTrackerTests` (unit tests, hosted by the app).

## Data model

All types are `Codable` and mirror the web app's JSON so the existing backup file imports unchanged.

- `Exercise { name, prescribed }`
- `PlanSection { title, icon, loggable, exercises }`
- `WorkoutPlan { id: Int64, name, favorite, sections }` (id was `Date.now()` ms; seeds use 1, 2, 3)
- `LoggedExercise { name, sets: [Int], weights: [Double?]?, weight: Double? }` — new-shape entries carry `weights` (parallel to `sets`); old-shape/manual entries carry a single `weight`. Both shapes coexist (per `08-per-set-weight.md`).
- `Workout { id: Int64, type, date: "yyyy-MM-dd", exercises: [LoggedExercise] }`
- `BackupFile { workouts, workoutPlans, exportedAt }`

**Tolerant decoding.** Numbers in old web data may arrive as numbers, numeric strings, or null (weight inputs). `LoggedExercise` decodes `weight`/`weights`/`sets` through a helper that accepts number, numeric string, or null, and never throws on a single bad value — a malformed value becomes `nil` rather than failing the whole import. `date` is kept as the original string.

The native-only `ActiveSession { planId, startedAt, logged: [String: SetLog] }` with `SetLog { reps: [Int], weights: [Double?] }` is separate; it is not part of the backup format (the web backup doesn't include it either).

## Persistence

`AppStore` persists three JSON files in a store directory (default: Application Support, injectable for tests): `plans.json`, `workouts.json`, `session.json`. Application Support is app-owned storage the OS does not evict. Every mutation does read-modify-write of the in-memory array then an atomic file write, so a crash can't leave a half-written file.

First launch (no `plans.json`) seeds the three `SeedPlans` once, then they are ordinary plans — no built-in flag (same as `01-workout-plans.md`).

`session.json` exists only while a workout is being tracked; it is what makes the session survive the app being closed (`03-tracking-mode.md`). Ending a session deletes it.

## Store behaviour (mirrors web functions)

| Web | Native |
|---|---|
| `savePlan` / `deletePlan` / `toggleFavorite` | `savePlan(_:)` (insert or replace by id), `deletePlan(id:)`, `toggleFavorite(id:)` |
| `importPlan` | `PlanImport.parse(_:) throws -> WorkoutPlan`, then `addPlan` |
| start tracking | `startSession(planId:)` |
| `logSet` / `editLoggedSet` / `deleteLoggedSet` | `logSet(exercise:reps:weight:)`, `editSet(exercise:index:reps:weight:)`, `deleteSet(exercise:index:)` — `reps` and `weights` always stay index-aligned |
| `endWorkout` | `endSession()`: if ≥1 logged set, prepend a `Workout` (type = plan name, date = today, `sets`+`weights`) to history; always clear the session |
| Add Workout modal | `addManualWorkout(type:date:exercises:)` producing old-shape entries (single weight) |
| `deleteWorkout` | `deleteWorkout(id:)` |
| export | `exportData() -> Data` (pretty JSON of `BackupFile`) |
| import data | `importBackup(_ data: Data) throws -> (workouts: Int, plans: Int)` — **merge by id, add-only**; malformed JSON throws before any write |

## Import Plan

`PlanImport.parse` is pure and reproduces the web validation exactly: invalid JSON → `"Invalid JSON: …"`; missing/empty `name` → a name error; `sections` missing or not an object → a sections error. `sections` is keyed by the four fixed titles (Warm-up, Main Workout, Cardio Finisher, Cool-down); a missing section becomes empty; an exercise without a non-empty `name` is dropped; `prescribed` defaults to `""`. Icons and `loggable` flags come from the app's fixed section table, not the imported data. Errors are shown inline in the sheet without dismissing it.

## Stats

`Stats` mirrors `updateProgressStats`: total = history count; this week = workouts dated on/after the start of the current week (Sunday, local midnight); best pull-ups / push-ups = the largest per-exercise sum of `sets` among exercises whose lowercased name contains `pull-up`/`pullup` (or `push-up`/`pushup`/`push up`), `nil` when none (rendered `--`).

## Rest timer

`RestTimer` (`@Observable`) holds `endDate` and `remaining`. `start(seconds:)` replaces any running timer (single timer only). A repeating 0.25s `Timer` calls `tick(now:)`, which recomputes `remaining` from `endDate` (so it stays correct after brief backgrounding) and calls `finish()` at zero. `finish()` fires a success haptic and a system sound once, then resets to idle. `stop()` cancels silently. `tick(now:)` takes the time as a parameter so unit tests drive it without waiting.

## UI structure

- `ContentView`: hero header (title, subtitle, today's weekday/date, the four static stat cards) above a `TabView` with **Workouts**, **Tracker**, **Progressions**.
- `WorkoutsView`: toolbar with Favorites-only filter, New Plan, Import Plan; list of `PlanCard`s (name, favorite star, expandable sections/exercises, **Start**, Edit, Delete with confirmation).
- `PlanEditorView` (sheet): name + the four fixed section blocks, add/remove exercise rows (name + prescribed).
- `ImportPlanView` (sheet): `TextEditor`, inline error text, Import button.
- `TrackingView`: presented with `.fullScreenCover` while `store.session != nil`, so the hero and tabs are not shown (focus mode). Plan title and **End** always visible; loggable sections render `ExerciseTrackingCard`s; non-loggable sections are read-only reference. Each card: prescribed text, logged-set chips (`Set N: X reps @ Ykg`), tap a chip to edit (alert with reps + weight fields), swipe/× to delete, and an add-set row with Weight and Reps fields. Logging a set reveals the `RestTimerBar` (30/60/90 presets + custom seconds, countdown, cancel). Numeric fields use `.keyboardType(.decimalPad)`/`.numberPad`; SwiftUI does not auto-zoom, so the web zoom bugs do not apply.
- `TrackerView`: stat grid, **Log Workout** (sheet), **Export Data** (writes a temp `workout-backup-YYYY-MM-DD.json`, presented with `ShareLink`), **Import Data** (`.fileImporter` for JSON, security-scoped read, result summary alert), history list (per-set weights for new-shape entries; single weight line for old-shape ones; delete with confirmation). Empty state shows a **Restore from backup** button that opens the same importer.
- `ProgressionsView`: static content from `ProgressionData`.

## Theme

`Theme.swift` defines the Neon Sport palette from `09-theme.md` as `Color` constants: background `#0F0F12`, secondary `#141420`, card `#181820`, accent lime `#C4F600`, warm/destructive `#FF3B6B`, text `#FFFFFF` / `#B8BCC4` / `#6B6B76`, border `#23232E`. The app forces dark appearance (`.preferredColorScheme(.dark)`).

## Haptics

`Haptics.success()`, `.impact()`, `.selection()` wrap `UINotificationFeedbackGenerator` / `UIImpactFeedbackGenerator` / `UISelectionFeedbackGenerator`. They are silent no-ops on the Simulator, so nothing needs a guard.

## CI

`.github/workflows/ios-build.yml` is extended: install XcodeGen, generate the project, build the native app for the Simulator, and run `WorkoutTrackerTests` on an available iPhone simulator. The Capacitor build job remains until that project is removed.

## Verification

- Unit tests (run in CI): tolerant decoding of old-shape/new-shape/string-number history; `PlanImport` valid, partial, invalid-JSON, missing-name, missing-sections, nameless-exercise cases; stats incl. old+new shapes and "no pull-ups"; store — seed once, favorite/delete, log/edit/delete keeps `reps`/`weights` aligned, `endSession` with zero sets saves nothing and with sets saves new-shape, session survives re-creating the store from the same directory; backup merge is add-only and idempotent; malformed backup writes nothing; rest timer replace/finish/stop via injected time.
- Manual (user, Simulator): walk the golden path in each tab; confirm export share sheet and import file picker; confirm the backup exported from the web app imports. Haptics need a real device.

**Tracked in:** requested directly by the user.
