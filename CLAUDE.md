# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A workout tracking app. It is moving from a single-file web app to a **native SwiftUI iOS app** (`WorkoutTracker/`, iOS 17+). Going forward, new work happens in the SwiftUI app. The web app (`index.html`) and the Capacitor wrapper (`ios/`, `www/`, `package.json`, `capacitor.config.json`) are **legacy**: leave them untouched until the user confirms the SwiftUI app matches them, then remove them in a separate change.

## SwiftUI app (primary)

Layout:
- `WorkoutTracker/project.yml` — XcodeGen spec. The Xcode project is **generated** from it and git-ignored.
- `WorkoutTracker/App/` — app code: models (`Models.swift`), `AppStore.swift` (`@Observable` state + JSON persistence), `PlanImport.swift`, `Stats.swift`, `Backup.swift`, `RestTimer.swift`, `Theme.swift`, `Haptics.swift`, seed/progression data, and `Views/`.
- `WorkoutTracker/Tests/` — XCTest unit tests for the logic layer.

Rules:
- **Never hand-edit the `.xcodeproj`/`.pbxproj`.** After adding, removing or renaming Swift files, or changing targets/settings, edit `project.yml` if needed and re-run `xcodegen` in `WorkoutTracker/`.
- Minimum iOS 17. Swift language mode 5. SwiftUI + the Observation framework (`@Observable`). No third-party dependencies unless asked.
- Keep logic (store, stats, import, backup, timer) in plain, testable Swift; keep views thin. Add or update XCTest tests with every logic change.
- Data is stored as JSON in Application Support. The backup file format is shared with the legacy web app (`workouts`, `workoutPlans`, `exportedAt`); never break it, and keep old-shape history entries (single `weight`) decoding correctly.
- Theme is "Neon Sport" (`Theme.swift`): near-black background, lime accent `#C4F600`, pink `#FF3B6B` for destructive actions.

Commands (run from the repo root):

```bash
brew install xcodegen xcbeautify          # one-time
cd WorkoutTracker && xcodegen && cd ..    # (re)generate the Xcode project
xcrun simctl list devices available       # choose a simulator; don't assume a name
xcodebuild test \
  -project WorkoutTracker/WorkoutTracker.xcodeproj \
  -scheme WorkoutTracker \
  -destination 'platform=iOS Simulator,name=<chosen device>' \
  CODE_SIGNING_ALLOWED=NO | xcbeautify
```

To check UI changes, build, install and launch in the Simulator and look at screenshots (`xcrun simctl boot/install/launch`, `xcrun simctl io booted screenshot <file>`, or any simulator tools available). Haptics only work on a real device.

CI: `.github/workflows/swiftui-build.yml` generates the project, builds and runs the unit tests on macOS on PRs touching `WorkoutTracker/` and on manual runs (Actions tab → Run workflow). It does not run on every push. It should be green before merging.

Not set up yet: code signing, TestFlight/App Store (needs an Apple Developer account).

## Project docs

**Every change to app behaviour (SwiftUI or legacy web) — feature or bug fix, no exceptions — must be traceable through `docs/` in three phases, each referencing the previous:**
- `docs/requirements/` — what we're building/fixing and why, never how. Small capability-focused files with an `index.md` linking them.
- `docs/design/` — how we'll build it (data model, UI flow, code structure). Each design doc references the specific `docs/requirements/*.md` file(s) it implements.
- `docs/build/` — implementation notes/changelog for the build phase. Each build doc references the specific `docs/design/*.md` file(s) it follows.

**Do not write or edit app code before this chain exists for the change.** The order is always requirements → design → build → code:
1. Write or update the requirements doc first — what's broken or wanted, and why.
2. Write or update the design doc next, referencing that requirements doc — how it'll be implemented.
3. Only then touch the code, and write/update the build doc referencing that design doc as you go — a real changelog (what was built, deviations, verification), not a pre-written task list.

This applies to bug fixes too: a one-line fix still gets a short requirements note (what was broken), a short design note (root cause + fix approach) if it's not trivial, and a build note (what changed, how it was verified) — added to the existing capability's docs (e.g. a "Follow-up fix" section) rather than skipped because it's "just a bug." Don't let implementation details leak into requirements docs, and don't skip ahead in the chain even under time pressure.

The SwiftUI app's docs are the `12-swiftui-app.md` files in each folder (earlier numbered files describe the behaviour being carried over).

## Git workflow

- Develop on a feature branch, commit in small reviewable steps, open a PR to `main` when asked.
- **After a PR is merged, delete the feature branch** (local and remote).
- Do not make the repository private without asking the user first: it takes the legacy GitHub Pages site offline and makes macOS CI minutes cost 10x.

## Legacy web app (`index.html`)

A single self-contained HTML file (HTML, CSS in `<style>`, JS in a `<script>`), no build step, no dependencies, served via GitHub Pages. Data is in browser `localStorage` (`workouts`, `workoutPlans`, `activeSession`). Open it directly in a browser to test. Keep everything in that one file and expose `onclick` handlers on `window`. The Capacitor copy in `www/index.html` is generated from it by hand; do not change either unless asked.
