# Design: Per-Set Weight

Implements: `docs/requirements/08-per-set-weight.md`

## Data model change

`activeSession.loggedSets[exerciseName]` changes from `{ weight, reps: [...] }` to `{ reps: [...], weights: [...] }` — a `weights` array parallel to `reps`, one entry per logged set (`null` if left blank for that set). The old single `weight` field is dropped from new sessions; there's nothing to migrate since `activeSession` is transient (cleared on `endWorkout()`), not historical data.

The exercise-level weight input above the set list (`trackWeight-*`, `updateExerciseWeight()`) is removed. Weight is entered alongside reps, per set, in the same "+ Add Set" row.

### History (`workouts`) shape

`endWorkout()` now maps each exercise to `{ name, sets: reps, weights }` instead of `{ name, weight, sets }`. Old history entries already in `localStorage` keep their `{ name, weight, sets }` shape untouched — nothing rewrites past data. Both shapes coexist in the `workouts` array going forward; rendering code must handle both (see below).

`updateProgressStats()` is unaffected: it only reads `ex.sets` (reps) via `.reduce((a,b) => a+b, 0)` for pull-up/push-up totals, never `ex.weight`. No change needed there.

## UI per loggable exercise (tracking mode)

`renderTrackingExercise()` drops the standalone weight input. The "+ Add Set" row gets two inputs instead of one:
- Weight (kg, optional, numeric) — `trackSetWeight-{cssSafe}`
- Reps (required, numeric) — `trackReps-{cssSafe}` (unchanged id)

`renderSetChips(safeName, reps, weights)` renders each chip as `Set N: X reps` if that set's weight is `null`/empty, or `Set N: X reps @ Ykg` if a weight was given — so sets within the same exercise can mix (e.g. bodyweight warm-up set, then weighted sets).

## Save flow

`window.submitLogSet(exerciseName)` reads both the weight and reps inputs and calls `window.logSet(exerciseName, reps, weight)`.

`window.logSet(exerciseName, reps, weight)`:
1. Read `activeSession`.
2. If `loggedSets[exerciseName]` doesn't exist, create `{ reps: [], weights: [] }`.
3. Push `reps` onto `.reps` and `weight` (or `null`) onto `.weights` — same index in both arrays.
4. Persist, re-render that exercise's chip list, trigger rest-timer prompt — unchanged.

## CR carry-over: editing a logged set

`window.editLoggedSet(exerciseName, index)` changes from a single reps-only `prompt()` to two sequential prompts — first reps (pre-filled with current value), then weight (pre-filled with current value, blank if `null`). This matches the app's existing minimal-native-dialog convention (no new modal). Cancelling either prompt (`null`) aborts the whole edit without changing either value, so a user can't end up with reps updated but weight unintentionally cleared.

`window.deleteLoggedSet(exerciseName, index)` now `splice`s the same index out of both `.reps` and `.weights`, keeping them aligned.

## Tracker tab (history) rendering

`loadWorkoutHistory()`'s per-exercise block changes to:
- If `ex.weights` is present (new-shape entry): render each set as its own line/chip-style — `Set N: X reps @ Ykg` (or `Set N: X reps` if that entry's weight is `null`) — plus the existing `(NN total)` reps summary.
- Else (`ex.weight`/old-shape entry, or a manually-added workout via the Add Workout modal): keep today's rendering exactly as-is — `${ex.weight}kg` line + `ex.sets.join(', ')`.

This is a per-exercise branch, not a global flag, since `workouts` can contain a mix of old and new entries, and even a single workout can mix manually-added exercises (old shape) with tracking-mode ones (new shape).

## Out of scope

The manual "Add Workout" modal (`addExercise()`/`addSet()`/`workoutForm` submit handler) keeps producing old-shape `{ name, weight, sets }` entries unchanged, per requirements.

## Verification

- Log a set on an exercise with weight 50 and reps 10, then a second set with weight 55 and reps 8: confirm both chips render with their own weight, `activeSession.loggedSets[name]` has `weights: [50, 55]`, `reps: [10, 8]`.
- Edit set 1 to weight 52, reps 11: confirm both arrays update at index 0 only.
- Delete set 1: confirm both arrays shrink and chip renumbering still works (carried over from the existing CR).
- End the workout: confirm the saved `workouts` entry has `{ name, sets: [...], weights: [...] }` and no `weight` field.
- Reload the Tracker tab: confirm the new entry shows per-set weight, and any pre-existing old-shape entries still render exactly as before.
- Log a pull-up/push-up exercise with varying weight (or none) and confirm `updateProgressStats()`'s best-total stat still computes correctly from `ex.sets`.

**Tracked in:** Design #8 (follow-up to Design #10 / `04-set-logging.md`).
