# Design: Tracking Mode

Implements: `docs/requirements/03-tracking-mode.md`

## Session data shape

```js
// localStorage key: activeSession (single object, or absent)
{
  planId: 1718900000000,
  planName: "Day 1 – Upper Body + Core",
  startedAt: 1718900000000,
  loggedSets: {
    // keyed by exercise name; only present once at least one set is logged
    "Chest Press Machine": { weight: 45, reps: [12, 11, 10] }
  }
}
```

A **snapshot** of the plan's sections/exercises is *not* duplicated into the session — tracking mode reads the live plan via `planId` lookup into `workoutPlans`. (Editing a plan mid-session is an edge case the user is unlikely to hit; not worth the duplication complexity.)

## Start

`window.startWorkout(planId)`:
1. Writes a fresh `activeSession` object (empty `loggedSets`) to localStorage.
2. Calls `enterTrackingView()`.

## Tracking view

`enterTrackingView()`:
- Adds a body-level class (e.g. `tracking-active`) that hides the tab bar and all `.workout-split` panels via CSS, and shows a new `#trackingView` element instead. The `.hero` day/date header stays visible (it's outside the elements being hidden).
- `#trackingView` renders: plan name as title, then each section from the looked-up plan (warm-up/cool-down shown read-only exactly like the plan-detail view; main workout/cardio shown with logging controls per `04-set-logging.md`).
- A persistent **End** button is fixed at the top or bottom of `#trackingView`.

## Resume after refresh

On app load, `loadWorkoutPlans()`/`loadWorkoutHistory()` init code also checks `localStorage.getItem('activeSession')`. If present, call `enterTrackingView()` immediately instead of showing the normal tab UI — restoring exactly where the user left off, since `loggedSets` already reflects everything saved so far.

## End

`window.endWorkout()`:
1. Read `activeSession`.
2. If `loggedSets` has no entries → discard: `localStorage.removeItem('activeSession')`.
3. Else → build a `workouts`-shaped entry: `{ id: Date.now(), type: planName, date: <today, same format as existing Add Workout modal>, exercises: Object.entries(loggedSets).map(([name, {weight, reps}]) => ({ name, weight, sets: reps })) }`, `unshift()` it into the existing `workouts` array (same read-modify-write as today), then remove `activeSession`.
4. Exit tracking view (remove the body class), re-render `#workouts` and `#tracker` (so the new history entry / stats show up immediately if the user switches tabs).

## Verification

Start a plan, log a set, refresh the page — tracking view reappears with that set still shown. End with sets logged — confirm a new entry appears in the Tracker tab history and stats update. Start a plan and End immediately with nothing logged — confirm no history entry was created.

**Tracked in:** Design #9, Build #14
