# Per-Set Weight

- Right now, tracking mode logs one weight value for an entire exercise, applied to all sets. The user wants weight tracked **per set**, since weight often changes between sets of the same exercise (e.g. a pyramid: 50kg/55kg/60kg, or dropping weight on a final fatigue set).
- When logging a set during tracking, the user must be able to enter a weight alongside the reps for that specific set, not once per exercise.
- When editing a logged set (the existing edit-a-set capability), the user must be able to correct that set's weight, not just its reps — today only reps are editable.
- On the Tracker tab (workout history), each set's own weight must be visible, not a single weight applied to the whole exercise. Today the history shows one weight per exercise line and all reps below it, which loses the per-set detail once weight varies between sets.
- Existing saved history entries (single weight per exercise) must keep displaying correctly — no data loss or broken rendering for old workouts.
- Out of scope: the manual "Add Workout" modal (used for logging a workout without an active tracking session) keeps its existing single-weight-per-exercise form for now.

**Tracked in:** Requirements #8. Raised by the user; a gap in the original `04-set-logging.md` requirements that wasn't carried into design.
