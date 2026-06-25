# Design: Set Logging

Implements: `docs/requirements/04-set-logging.md`

## UI per loggable exercise

For each exercise in a `loggable: true` section, `#trackingView` renders:
- Exercise name + prescribed text (e.g. "3x12") as a subtitle, same styling as today's `.exercise-name`/`.exercise-details`.
- One **weight** input (optional, numeric) — matches the existing Add Workout modal's single-weight-per-exercise model.
- A running list of logged sets for that exercise so far (e.g. "Set 1: 12 reps", "Set 2: 11 reps"), rendered from `activeSession.loggedSets[name].reps`.
- A **+ Add Set** button that prompts for reps (reusing the existing `addSet()` input-row pattern rather than a JS `prompt()`) and appends to the array.

The user can tap "+ Add Set" as many times as they want — there's no cap tied to the plan's prescribed count.

## Save flow

`window.logSet(exerciseName, reps)`:
1. Read `activeSession` from localStorage.
2. If `loggedSets[exerciseName]` doesn't exist yet, create it with the exercise's current weight-input value.
3. Push `reps` onto `loggedSets[exerciseName].reps`.
4. Write `activeSession` back to localStorage immediately (so a refresh mid-session doesn't lose the set — same resume mechanism as `03-tracking-mode.md`).
5. Re-render that exercise's logged-set list.
6. Trigger the rest-timer prompt (`05-rest-timer.md`).

Changing the weight input for an exercise after sets are already logged updates `loggedSets[exerciseName].weight` going forward (single weight value per exercise, consistent with the existing `workouts` data shape — it does not retroactively vary weight per set).

## Compatibility with existing history/stats

The final save (`endWorkout()`, per `03-tracking-mode.md`) produces exactly the same per-exercise shape `{ name, weight, sets: [reps...] }` the existing Add Workout modal already produces, so `loadWorkoutHistory()` and `updateProgressStats()` (including the pull-up/push-up substring matching) work without modification.

## Verification

Log 3 sets for an exercise with different rep counts and a weight value; confirm the running list shows all 3 immediately. End the workout and confirm the Tracker tab shows `"12, 11, 10 reps (33 total)"` style output identical to manually-logged workouts today.

**Tracked in:** Design #10, Build #15

## CR: Edit/delete a logged set

Implements the CR in `docs/requirements/04-set-logging.md`.

### UI

Each `.set-log-chip` (previously a static `<span>`) becomes two elements:
- `.set-log-chip-label` — the existing "Set N: X reps" text, now clickable.
- `.set-log-chip-remove` — a small "×" button.

No new modal. Editing reuses the browser's native `prompt()`, pre-filled with the current value — consistent with the app's existing minimal-native-dialog style (`confirm()` is already used for plan/workout deletion).

### Behavior

- Clicking a chip's label calls `editLoggedSet(exerciseName, index)`: prompts for a new rep count, parses it as a positive integer, and if valid, overwrites `loggedSets[exerciseName].reps[index]`.
- Clicking a chip's "×" calls `deleteLoggedSet(exerciseName, index)`: removes that index from `loggedSets[exerciseName].reps` via `splice`.
- Both persist immediately via `saveActiveSession` (same resume-after-refresh guarantee as initial logging) and re-render just that exercise's chip list — no full tracking-view re-render.
- Cancelling the prompt (returns `null`) or entering a non-positive/non-numeric value leaves the set unchanged.
- Set numbering ("Set 1", "Set 2"...) is always derived from current array position, so deleting set 1 renumbers the remaining sets rather than leaving a gap.

### Compatibility

Only `activeSession.loggedSets` is touched — the same shape `endWorkout()` already maps into the `workouts` history array, so no changes needed to history/stats code.

### Verification

Log 2 sets, edit the first one's reps via prompt, confirm the array and rendered chip update. Delete a set, confirm the array shrinks and remaining sets renumber correctly in the UI.

**Tracked in:** Issue #45.

## Follow-up fix: page zooms/shifts when tapping Weight or Reps

Implements the follow-up fix in `docs/requirements/04-set-logging.md`.

### Root cause

`.log-set-row input` (the "Weight (kg)" / "Reps" inputs rendered by `renderTrackingExercise`) is styled with `font-size: 0.9rem` (14.4px). Mobile Safari and Chrome auto-zoom the page when a focused input's font-size is below 16px, and the viewport meta tag (`index.html:5`) sets no `maximum-scale`, so nothing constrains that zoom. Once zoomed, the browser scrolls to keep the input in view and doesn't reliably reset on blur, leaving the layout looking shifted/cut off — matching the reported screenshots.

`.form-input, .form-select` (used by the Add Workout modal) are already `font-size: 1rem` and don't exhibit the bug, confirming the diagnosis.

### Fix

Raise `.log-set-row input`'s `font-size` to `1rem` (16px). This is the standard, accessibility-friendly fix — preferred over disabling pinch-zoom via the viewport meta tag, which would remove zoom for users who rely on it. No markup or layout changes needed.

**Tracked in:** Reported directly by the user with screenshots during day-to-day use of tracking mode.
