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
