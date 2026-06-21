# Build: Import Plan

Follows: `docs/design/07-import-plan.md`

## What was built

- `#importPlanModal` markup: textarea (`#importPlanJson`), error slot (`#importPlanError`), Import button — separate from the existing `#newPlanModal`.
- `window.openImportPlanModal()` / `window.closeImportPlanModal()`: clear the textarea/error and toggle the modal's `active` class, same pattern as the New Plan modal.
- `window.importPlan()`: parses and validates the pasted JSON exactly per the design's 6-step save flow — `JSON.parse` wrapped in try/catch, `name`/`sections` presence checks, `PLAN_SECTION_TYPES.map()` to pull matching exercises out of `data.sections` by title (missing sections → `[]`), per-exercise filtering on a non-empty `name`. Pushes the resulting plan onto `workoutPlans` via the existing `loadWorkoutPlans()`/`saveWorkoutPlans()` pair — no new storage key.
- **⬇ Import Plan** button added to the `#workouts` toolbar next to **+ New Plan**.

## Deviations from design

- None. Implemented exactly as designed.

## Verification

Verified with the jsdom harness against real localStorage:
- Valid JSON with exercises only in `Main Workout` and `Warm-up` creates a plan where those two sections have the expected exercises and `Cardio Finisher`/`Cool-down` are empty arrays (not missing/undefined).
- Invalid JSON (`"not json"`) shows `"Invalid JSON: ..."` in `#importPlanError` and does not touch `workoutPlans`.
- JSON missing `name` shows a `name`-specific error.
- A successful import closes the modal (`#importPlanModal` loses `.active`).
- Full existing regression suite (32 prior assertions across plans/tracking/rest-timer) still passes unmodified.

**Tracked in:** Design #12, Build #17. PR #42.
