# Build: Native SwiftUI App

Follows: `docs/design/12-swiftui-app.md`

## What was built

- `WorkoutTracker/project.yml` — XcodeGen spec: app target (iOS 17, Swift language mode 5, portrait iPhone, generated Info.plist) plus a hosted unit-test target. The `.xcodeproj` is generated and git-ignored.
- Logic layer (`WorkoutTracker/App/`): `Models.swift` (Codable types with tolerant number decoding), `SeedPlans.swift` (the three seeded plans, transcribed from `index.html`), `PlanImport.swift`, `Stats.swift`, `Backup.swift`, `AppStore.swift` (`@Observable`, JSON files in Application Support, all mutations), `RestTimer.swift`, `Haptics.swift`, `Theme.swift`, `ProgressionData.swift`.
- Views (`WorkoutTracker/App/Views/`): `ContentView` (hero + tabs, tracking as a full-screen cover), `WorkoutsView`/`PlanCard`, `PlanEditorView`, `ImportPlanView`, `TrackingView` (+ `ExerciseTrackingCard`, `RestTimerBar`), `TrackerView` (stats, history, export via `ShareLink`, import via `.fileImporter`, empty-state restore), `LogWorkoutView`, `ProgressionsView`.
- Tests (`WorkoutTracker/Tests/`): models/tolerant decoding, plan import validation, stats, store behaviour (seeding, favorites, set logging alignment, end-session rules, relaunch persistence, backup merge/idempotence/malformed input, export→import round trip), rest timer (replace, finish-once, stop).
- `.github/workflows/swiftui-build.yml` — macOS CI: install XcodeGen, generate project, build, run the unit tests on an iPhone simulator.

## Deviations from design

- Ending a workout asks for confirmation (the web app ended immediately). A native tap target near the top of the screen is easy to hit by accident; the confirm states how many sets will be saved, or that nothing will be saved.
- History is displayed newest-first by date then id, rather than raw array order, so imported backups don't appear out of order.
- Workout dates use the local calendar day; the web app used the UTC day.
- Manual "Log Workout" uses one reps field per set rather than the web's free-form rows; the saved shape is the same old-shape entry.

## Verification

- **Not yet compiled or run.** The authoring environment has no Swift toolchain (download blocked), so correctness so far rests on code review. Verification is delegated to the `SwiftUI Build & Test` CI job; results are recorded below once it has run.
- Still to be checked by the user in the Simulator: walk each tab, tracking flow with rest timer, export share sheet, import file picker, importing a backup exported from the web app. Haptics need a real device.

## Not done / follow-ups

- Capacitor project (`ios/`, `www/`, `package.json`) and `index.html` remain until parity is confirmed; removal is a separate change.
- App icon, signing, TestFlight (needs Apple Developer account).

**Tracked in:** requested directly by the user.
