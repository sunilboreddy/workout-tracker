# Native SwiftUI App

## Why

The current iOS app is the web app (`index.html`) wrapped in Capacitor (`11-ios-app.md`). It runs, but it is a web page inside a native shell: it doesn't feel like an iPhone app, relies on browser storage that the OS can evict (see `10-data-backup.md`), and needs plugin shims for haptics, sharing and file picking. The user wants to move to a fully native SwiftUI app and have Swift be the app going forward.

## What's needed

- A native iOS app, built entirely in SwiftUI, that reaches **full feature parity** with the current web app:
  - Workout plans: create, edit, delete, favorite; the three seeded plans exist on first launch (`01-workout-plans.md`).
  - Workout list with favorites filter, expand-to-view, and a Start action (`02-workout-list-selection.md`).
  - Tracking mode as a focused full-screen experience that survives the app being closed mid-workout, and saves to history only if at least one set was logged (`03-tracking-mode.md`).
  - Per-set logging of reps (required) and weight (optional), with edit and delete of logged sets (`04-set-logging.md`, `08-per-set-weight.md`).
  - Rest timer with 30/60/90s presets and a custom duration, one active at a time, with sound and haptic feedback on completion (`05-rest-timer.md`).
  - Import Plan from pasted JSON with the same format and inline validation errors (`07-import-plan.md`).
  - Workout history and progress stats: total workouts, this week, best pull-ups, best push-ups; manual "Log Workout"; delete a workout; both old and new history entry shapes display correctly (`08-per-set-weight.md`).
  - Progressions reference content (universal protocol and the squat, pull-up, push-up progressions).
  - Data backup: export all data to a file the user controls and import it back without ever discarding data already on the device; offer restore when there is no history (`10-data-backup.md`).
  - The Neon Sport look: near-black background, neon lime accent, hot pink for destructive actions (`09-theme.md`).
- A home-screen app icon in the Neon Sport palette, distinct from the generic dumbbell/barbell icons common in the fitness-app category, and legible down to the smallest iOS icon sizes (Settings/Spotlight).
- The existing JSON backup file format must be accepted, so data from the web/Capacitor app can be brought across into the native app.
- Data lives in app-owned storage that the OS does not evict like browser storage.
- Runs on iPhone, iOS 17 or later.
- Haptic feedback is native (real device only); the app must still work normally where haptics are unavailable (Simulator).

## Out of scope for this change

- Signing, TestFlight and App Store distribution (needs an Apple Developer account).
- Cloud sync, accounts, background/automatic backup.
- iPad-specific layouts, widgets, Apple Watch, HealthKit.
- Removing the web app and Capacitor project. They stay until the native app is confirmed at parity; removal is a separate follow-up.

**Tracked in:** requested directly by the user ("lets go swift ui", "complete swift henceforth", minimum iOS 17).
