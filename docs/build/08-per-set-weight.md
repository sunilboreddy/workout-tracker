# Build: Per-Set Weight

Follows: `docs/design/08-per-set-weight.md`

## What was built

- `renderTrackingExercise()`: removed the standalone exercise-level weight input (`trackWeight-*`/`updateExerciseWeight()`, deleted). The "+ Add Set" row now has two inputs — `trackSetWeight-{cssSafe}` (optional) and `trackReps-{cssSafe}` (required, unchanged id).
- `renderSetChips(safeName, reps, weights)`: now takes a parallel `weights` array and renders `Set N: X reps @ Ykg` when that set has a weight, else `Set N: X reps` — so sets can mix weighted/unweighted within one exercise.
- `window.submitLogSet`/`window.logSet`: read and push weight alongside reps; `session.loggedSets[name]` is now `{ reps: [...], weights: [...] }` (the old single `weight` field is gone from new sessions).
- `window.editLoggedSet`: now does two sequential `prompt()` calls (reps, then weight); cancelling either aborts the whole edit so reps/weight can't end up partially updated.
- `window.deleteLoggedSet`: splices both arrays at the same index.
- `window.endWorkout()`: maps each exercise to `{ name, sets: reps, weights }` instead of `{ name, weight, sets }`.
- `loadWorkoutHistory()`: extracted exercise-row rendering into `renderExerciseLog(ex)`, which branches on `ex.weights` — new-shape entries get a per-set `X reps @ Ykg` line, old-shape entries (manually-added workouts, or anything saved before this change) keep the original single-weight-line rendering untouched.
- `updateProgressStats()`: untouched — it only ever read `ex.sets` (reps), never `ex.weight`.

## Deviations from design

- None. Followed the design doc's data model and rendering-branch approach as specified.

## Verification

jsdom harness against real localStorage:
- Logged two sets on "Farmer's Carry" with different weights (50kg/40 reps, 55kg/38 reps) — `activeSession.loggedSets["Farmer's Carry"]` came back as `{ reps: [40, 38], weights: [50, 55] }`, chips rendered `Set 1: 40 reps @ 50kg` / `Set 2: 38 reps @ 55kg`.
- Edited set 1 via the two-prompt flow (reps → 15, weight → 52): both arrays updated at index 0 only, leaving set 2 untouched.
- Logged a set on a different exercise with no weight entered: stored as `weights: [null]`, rendered as plain `Set 1: 8 reps` (no "@ null kg").
- `endWorkout()` produced `workouts[0].exercises` with `{ name, sets, weights }` and no `weight` field; Tracker tab rendered `15 reps @ 52kg, 38 reps @ 55kg (53 total)`.
- Seeded an old-shape entry directly (`{ name: 'Pull-ups', weight: 0, sets: [10, 9, 8] }`, no `weights` field) — `loadWorkoutHistory()` rendered it with the original single-weight format unchanged, and `updateProgressStats()` still computed "Best Pull-ups: 27" correctly.

Manual smoke test in a real headless Chromium browser (via Playwright), exercising the actual click/dialog path rather than synthetic events:
- Started "Day 3" plan, entered weight 50 + reps 40 on "Farmer's Carry" (an exercise name with an apostrophe, to stress-test the existing string-escaping), tapped "+ Add Set" — chip rendered `Set 1: 40 reps @ 50kg`.
- Tapped the chip label — got a real native `prompt()` for reps, then a second real native `prompt()` for weight, confirming the two-step edit dialog chain works through actual DOM events (not just direct function calls).
- Submitted 35/60 — chip updated to `Set 1: 35 reps @ 60kg`.
- Called `endWorkout()`, switched to the Tracker tab — history showed `35 reps @ 60kg (35 total)`, matching the new per-set format end-to-end in the browser.

**Tracked in:** Build #8 (follow-up to Build #15 / `04-set-logging.md`).
