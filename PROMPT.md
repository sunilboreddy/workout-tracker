# Starting prompt for a local Claude Code session

Paste this, or just tell Claude Code: "Follow PROMPT.md".

---

This repo is moving from a single-file web app to a native SwiftUI iOS app in `WorkoutTracker/`. Read `CLAUDE.md` first, then `docs/requirements/12-swiftui-app.md`, `docs/design/12-swiftui-app.md` and `docs/build/12-swiftui-app.md`.

State of play: the SwiftUI app has been written but never run on a Mac. CI (macOS) compiled it and ran 33 unit tests; one test had a timing bug that has since been fixed. Nothing has been checked visually in the Simulator yet.

## First, tell me what you find (no code changes yet)

1. Install tooling if missing: `brew install xcodegen xcbeautify`.
2. Generate the project (`cd WorkoutTracker && xcodegen`), pick an installed simulator with `xcrun simctl list devices available`, and run the build and tests using the command in `CLAUDE.md`. Report pass/fail.
3. Check CI on the branch is green too.

## Then, verify in the Simulator

Build, install and launch the app, take screenshots, and check each screen against the requirements docs:

- Workouts tab: three seeded plans, favorites filter, expand, New Plan, Edit, Delete, Import Plan (valid JSON and the error messages).
- Tracking: Start a plan, the full-screen focus view, add sets with weight and reps, edit and delete a set, rest timer presets and custom seconds, End (with and without sets logged).
- Tracker tab: stats, history showing per-set weights, Log Workout, delete workout, empty-state "Restore from backup".
- Export Data (share sheet) and Import Data (file picker). Export a backup from the old web app and confirm it imports, including old-style entries with one weight per exercise. Importing twice must not duplicate anything.
- Progressions tab content.
- Close and relaunch the app mid-workout: the session must still be there.

Fix any layout or behaviour problems you find. Haptics only work on a real device, so just confirm nothing crashes in the Simulator.

## Working rules

- Follow the docs chain in `CLAUDE.md` (requirements, design, build, then code) and record results in the Verification section of `docs/build/12-swiftui-app.md`.
- Never hand-edit the Xcode project; re-run `xcodegen` after adding or renaming files.
- Add or update XCTest tests with every logic change, and run them after each change.
- Work in small steps and commit often.
- When the PR is merged, delete the feature branch.
- Ask me before making the repo private.
- Leave the legacy web app and Capacitor project alone until I say the SwiftUI app is good enough to replace them.
