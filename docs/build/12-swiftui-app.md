# Build: Native SwiftUI App

Follows: `docs/design/12-swiftui-app.md`

## What was built

- `WorkoutTracker/project.yml` — XcodeGen spec: app target (iOS 17, Swift language mode 5, portrait iPhone, generated Info.plist) plus a hosted unit-test target. The `.xcodeproj` is generated and git-ignored.
- Logic layer (`WorkoutTracker/App/`): `Models.swift` (Codable types with tolerant number decoding), `SeedPlans.swift` (the three seeded plans, transcribed from `index.html`), `PlanImport.swift`, `Stats.swift`, `Backup.swift`, `AppStore.swift` (`@Observable`, JSON files in Application Support, all mutations), `RestTimer.swift`, `Haptics.swift`, `Theme.swift`, `ProgressionData.swift`.
- Views (`WorkoutTracker/App/Views/`): `ContentView` (hero + tabs, tracking as a full-screen cover), `WorkoutsView`/`PlanCard`, `PlanEditorView`, `ImportPlanView`, `TrackingView` (+ `ExerciseTrackingCard`, `RestTimerBar`), `TrackerView` (stats, history, export via `ShareLink`, import via `.fileImporter`, empty-state restore), `LogWorkoutView`, `ProgressionsView`.
- Tests (`WorkoutTracker/Tests/`): models/tolerant decoding, plan import validation, stats, store behaviour (seeding, favorites, set logging alignment, end-session rules, relaunch persistence, backup merge/idempotence/malformed input, export→import round trip), rest timer (replace, finish-once, stop).
- `.github/workflows/swiftui-build.yml` — macOS CI: install XcodeGen, generate project, build, run the unit tests on an iPhone simulator.
- `WorkoutTracker/App/Assets.xcassets/AppIcon.appiconset` — the app icon: a single full-bleed 1024×1024 PNG (lime `#C4F600` ground, near-black `#0F0F12` lightning-bolt mark), rendered with a small CoreGraphics script (no SVG-to-PNG tool was available in the authoring environment). `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` added to `project.yml`.

## Deviations from design

- Ending a workout asks for confirmation (the web app ended immediately). A native tap target near the top of the screen is easy to hit by accident; the confirm states how many sets will be saved, or that nothing will be saved.
- History is displayed newest-first by date then id, rather than raw array order, so imported backups don't appear out of order.
- Workout dates use the local calendar day; the web app used the UTC day.
- Manual "Log Workout" uses one reps field per set rather than the web's free-form rows; the saved shape is the same old-shape entry.

## Verification

- **Compiled and unit-tested locally** (Xcode 27.0 / iOS 27.0 simulator, iPhone 17): `xcodegen` generates cleanly, `xcodebuild test` builds and passes all 33 unit tests. CI (`SwiftUI Build & Test`) is green on the branch.
- **Simulator walkthrough (automated + visual).** The authoring environment has no GUI Simulator window or device-automation tool (e.g. `idb`), so the golden path was driven with a temporary XCUITest suite (not committed — written, run, and removed for this verification pass only) that exercised the real UI end-to-end and captured screenshots at each step, which were then reviewed visually:
  - Workouts tab: 3 seeded plans render correctly; expand shows sections/exercises; Favorites filter and empty-state copy work; New Plan, Edit, Delete, and Import Plan (both the invalid-JSON error path and a valid-JSON import) all work and update the list immediately.
  - Tracking: Start opens the full-screen focus view; per-set logging (weight + reps) works and renders chips correctly; editing a set via the chip's alert updates reps/weight in place; deleting a set works; rest timer 30/60/90s presets and a custom duration both count down and can be cancelled; End shows the confirmation dialog with the correct logged-set count and saves to history.
  - Tracker tab: stats (total, this week, best push-ups) update correctly; history shows per-set weights; manual Log Workout (including the menu-style Workout Type picker) saves and appears in history; deleting a workout works; Export Data and Import Data open their respective system sheets without crashing (full cross-process automation of the share sheet / file picker wasn't exercised, but the underlying export/import logic is covered by `StoreTests`: round-trip, add-only merge, idempotence, malformed-input).
  - Progressions tab renders its static content correctly.
  - **Session survives the app being closed mid-workout**, confirmed with an actual `terminate()` + relaunch (not just a fresh `AppStore` in a unit test): a logged set on an in-progress session was still present after relaunch.
  - Theme (Neon Sport colors, dark appearance) renders as specified throughout.
  - No crashes encountered in the Simulator. Haptics were not exercised (real device only, as expected).
  - No bugs found; no code changes were needed as a result of this pass.
- **App icon** confirmed on an actual Simulator Home Screen (screenshot of the SpringBoard icon grid, not just the asset in isolation): clips correctly to the system squircle, reads clearly against both the wallpaper and neighboring stock icons.

## Not done / follow-ups

- Capacitor project (`ios/`, `www/`, `package.json`) and `index.html` remain until parity is confirmed; removal is a separate change.
- Signing, TestFlight (needs Apple Developer account).

**Tracked in:** requested directly by the user.
