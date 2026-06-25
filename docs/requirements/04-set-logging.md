# Set Logging

- While tracking, the user can log one or more sets per exercise: weight (optional) and reps (required).
- The user can log more sets than the plan prescribes (e.g. an extra set beyond "3x12").
- The user can see what they've logged so far for the current session without leaving the tracking view.
- Logged data must remain compatible with the existing workout history and progress stats (total workouts, this week, best pull-ups, best push-ups) so nothing in the current Tracker tab breaks.

*(Implementation note: exact save format is deferred to `docs/design/`, constrained by compatibility with the existing workout history feature.)*

**Tracked in:** Requirements #5, Design #10

## CR: Edit/delete a logged set

- While tracking, after logging a set (reps), the user can correct a mistyped rep count without deleting and re-adding it.
- The user can remove a logged set entirely if it was logged by mistake (e.g. tapped "+ Add Set" twice).
- This only affects in-progress sets during the current tracking session — it does not add editing to past, already-saved workout history (`#tracker` tab), which is out of scope here.
- Weight editing already exists (the weight input is always live, per above) — this CR covers the reps side, which was originally left as a static, unmodifiable list.

**Tracked in:** Issue #45. Raised directly by the user during day-to-day use of tracking mode.

## Follow-up fix: page zooms/shifts when tapping Weight or Reps

- While tracking, tapping into the "Weight (kg)" or "Reps" input for an exercise zooms the whole page in, and the layout is left looking shifted to the right with content cut off at the edge — even after the keyboard closes.
- This must not happen — tapping a logging input should not change the page's zoom level at all.

**Tracked in:** Reported directly by the user with screenshots during day-to-day use of tracking mode.
