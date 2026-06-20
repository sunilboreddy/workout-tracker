# Design: Workout Plans

Implements: `docs/requirements/01-workout-plans.md`

## Data shape

```js
// localStorage key: workoutPlans  (array)
{
  id: 1718900000000,            // Date.now() at creation
  name: "Day 1 – Upper Body + Core",
  favorite: false,
  sections: [
    {
      title: "Warm-up",
      icon: "🔥",
      loggable: false,          // read-only reference, no set logging in tracking mode
      exercises: [
        { name: "5 min treadmill walk", prescribed: "" }
      ]
    },
    {
      title: "Main Workout",
      icon: "💪",
      loggable: true,           // exercises here get weight/set logging in tracking mode
      exercises: [
        { name: "Chest Press Machine", prescribed: "3x12" }
      ]
    },
    { title: "Cardio Finisher", icon: "🏃", loggable: true,  exercises: [...] },
    { title: "Cool-down",       icon: "🧘", loggable: false, exercises: [...] }
  ]
}
```

`loggable` is fixed per section type: Warm-up/Cool-down = `false`, Main Workout/Cardio Finisher = `true`. The New Plan form always creates these 4 sections in this order; the user adds exercises into whichever ones apply.

## One-time seeding/migration

On app load, `loadWorkoutPlans()` checks `localStorage.getItem('workoutPlans')`. If missing:
1. Build 3 plan objects from the current hardcoded `#3day` markup (Day 1/2/3 — the content currently inside `.day-card`s), each becoming one plan with the 4 sections above.
2. Save them as the initial `workoutPlans` array.
3. The old `#3day`/`#4day`/`#5day` tab buttons and panels are deleted from the HTML in this change (not hidden, not conditionally rendered) — the migration is one-time, not a runtime branch.

After this, `workoutPlans` is the single source of truth; seeded plans are ordinary plans (editable, deletable, favoritable) — no `builtIn` flag, matching the "no source tagging" requirement.

## Create / Edit / Delete / Favorite

- **New Plan modal** (`#newPlanModal`, opened via `openNewPlanModal()`): name field + 4 fixed section blocks, each with an "+ Add Exercise" row (name input + prescribed-text input), mirroring the existing `addExercise()`/`removeExercise()` dynamic-row pattern from the Add Workout modal (new functions: `addPlanExercise(sectionIndex)`, `removePlanExercise(sectionIndex, rowId)`). Save via `savePlan()` does a read-modify-write on `workoutPlans` (push for create, splice-replace for edit — `editingPlanId` tracks which).
- **Edit**: reopens the same modal pre-filled, via `editPlan(id)`.
- **Delete**: `deletePlan(id)` removes it from `workoutPlans` after a confirm step (reuse the existing delete-confirmation style used by `deleteWorkout`).
- **Favorite**: `toggleFavorite(id)` flips the `favorite` boolean and re-saves; no duplication of the plan object.

## Verification

Create a plan, refresh the page, confirm it persists. Mark it favorite, confirm the flag persists. Delete it, confirm it's gone and `workouts` history is untouched.

**Tracked in:** Design #7, Build #12
