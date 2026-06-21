# Build: Set Logging

Follows: `docs/design/04-set-logging.md`

## What was built

- `renderTrackingExercise(ex, loggable, session)`: for loggable exercises (Main Workout/Cardio Finisher sections), renders a weight input (`updateExerciseWeight`), a running `.set-log-list` of `.set-log-chip` entries (one per logged rep count, in logged order), and a `+ Add Set` row (`logSet`/`submitLogSet`) that appends to that list immediately on submit. Non-loggable sections (Warm-up/Cool-down) render read-only, unchanged from `03-tracking-mode.md`.
- `window.logSet(exerciseName, reps)` / `window.submitLogSet(exerciseName)`: push the new rep count into `session.loggedSets[exerciseName].reps`, persist via `saveActiveSession`, and re-render just that exercise's chip list so the UI updates without a full view re-render.
- `window.updateExerciseWeight(exerciseName, value)`: writes `session.loggedSets[exerciseName].weight` and persists, independent of set logging.
- `endWorkout()` (from `03-tracking-mode.md`) maps each `loggedSets` entry into the existing `workouts` exercise shape (`{ name, weight, sets: [reps...] }`), preserving logged order — this is what makes the saved entry indistinguishable from one created via the old manual Add Workout flow.

## Deviations from design

- None significant. `cssSafe(name)` (used to derive DOM ids per exercise from its name) was checked against exercise names that are similar but not identical (e.g. "Pull-ups" vs "Pull-up Negatives") and does not collide, since it's a full slugify of the whole name rather than a truncation.

## Verification

Verified with the jsdom harness against real localStorage:
- Logging a set immediately updates `activeSession.loggedSets[name].reps` and renders a matching `.set-log-chip`.
- After a simulated refresh mid-session, the previously logged chip is still rendered (resume path from tracking mode correctly carries set-logging state).
- Logging 3 sets (12, 11, 10 reps) with a weight, then `endWorkout()`, produces a `workouts` history entry with `weight === 45` and `sets === [12, 11, 10]` in logged order — exact match to the existing manual-entry shape.
- Tracking-mode-logged sets remain compatible with existing derived stats: logging 8 then 7 reps on a "Pull-ups" exercise and ending the workout updates the Tracker tab's "best pull-ups" stat to `15`, confirming `updateProgressStats()`'s substring-based exercise matching works unmodified against tracking-mode-produced history entries.

**Tracked in:** Design #10, Build #15 (sub-issues #30–#32).
