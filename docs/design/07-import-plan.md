# Design: Import Plan

Implements: `docs/requirements/07-import-plan.md`

## UI

A new **⬇ Import Plan** button sits next to **+ New Plan** on the `#workouts` toolbar. It opens a new `#importPlanModal` (separate from `#newPlanModal`) containing:
- A textarea (`#importPlanJson`) for pasting JSON.
- An inline error slot (`#importPlanError`) for validation failures.
- An **Import** button.

## Expected JSON shape

```json
{
  "name": "Day 1 – Upper Body",
  "sections": {
    "Warm-up": [{ "name": "Arm Circles", "prescribed": "30s each side" }],
    "Main Workout": [{ "name": "Bench Press", "prescribed": "3x10" }],
    "Cardio Finisher": [{ "name": "Rowing Machine", "prescribed": "5 min" }],
    "Cool-down": [{ "name": "Chest Stretch", "prescribed": "30s each side" }]
  }
}
```

`sections` is keyed by the existing fixed section titles (`PLAN_SECTION_TYPES`: Warm-up, Main Workout, Cardio Finisher, Cool-down — see `01-workout-plans.md`), not a free-form array. This means Claude (or the user) can omit a section entirely and it's simply empty, rather than needing to match section order/icons/loggability — those are still owned by the app, not the imported data.

## Save flow

`window.importPlan()`:
1. `JSON.parse()` the textarea contents; on failure, show "Invalid JSON: ..." and stop.
2. Validate `name` is a non-empty string and `sections` is an object; on failure, show a specific inline error and stop.
3. Map `PLAN_SECTION_TYPES` to the matching key in `data.sections` (case-sensitive exact title match). Missing/invalid sections become `[]` rather than erroring — partial plans are allowed.
4. Within each section, filter out any exercise entry missing a non-empty `name`; `prescribed` defaults to `''` if absent/non-string.
5. Push a new plan object (`{ id: Date.now(), name, favorite: false, sections }`) onto the same `workoutPlans` array used by `savePlan()` — no separate storage key, no "imported" flag.
6. Close the modal, re-render the plan list.

## Compatibility

The resulting plan object has the exact same shape as one produced by `savePlan()` (`01-workout-plans.md`), so every existing feature — tracking mode, set logging, favoriting, editing, deleting — works on an imported plan without modification.

## Verification

Paste valid JSON with exercises in 2 of the 4 sections; confirm a new plan appears with those exercises in the right sections and the other 2 sections empty (not erroring). Paste invalid JSON and confirm an inline error appears without closing the modal or touching `workoutPlans`. Paste JSON missing `name`; confirm a specific error.

**Tracked in:** Design #12, Build #17.
