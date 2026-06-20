# Set Logging

- While tracking, the user can log one or more sets per exercise: weight (optional) and reps (required).
- The user can log more sets than the plan prescribes (e.g. an extra set beyond "3x12").
- The user can see what they've logged so far for the current session without leaving the tracking view.
- Logged data must remain compatible with the existing workout history and progress stats (total workouts, this week, best pull-ups, best push-ups) so nothing in the current Tracker tab breaks.

*(Implementation note: exact save format is deferred to `docs/design/`, constrained by compatibility with the existing workout history feature.)*

**Tracked in:** Requirements #5, Design #10
