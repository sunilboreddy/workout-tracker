# Build: Workout List & Selection

Follows: `docs/design/02-workout-list-selection.md`

## What was built

- Tabs reduced to `Workouts` (new, `data-tab="workouts"`, default-active), `Tracker`, `Progression`.
- `renderWorkoutList()`: one `.day-card` per `workoutPlans` entry, reusing the existing expand-on-click pattern (`.day-header`/`.day-content`/`.exercise-name`/`.exercise-details`), grouped by section with icon/title. Nothing pre-expanded.
- Each card header has a ★/☆ favorite toggle (`toggleFavorite(id)`) and a **Start** button (`startWorkout(id)`), both with `event.stopPropagation()` so they don't trigger the card's expand toggle.
- A "★ Favorites only" chip above the list filters `workoutPlans` in-memory (`favoritesOnly` variable, not persisted) before rendering.
- "+ New Plan" button opens the modal from `01-workout-plans.md`.
- Edit/Delete buttons were also added inside each expanded card (not explicitly required by this design doc, but needed since `editPlan`/`deletePlan` from capability 1 need a UI entry point — placed here since the card is where plans are presented).

## Deviations from design

- None significant. The `.hero` header was confirmed to remain visible and unaffected by the new tab/panel structure (it sits outside `.tabs`/`.content` and isn't touched by the `tracking-active` CSS toggle either).

## Verification

Verified with the same jsdom harness:
- `Workouts` tab is `.active` by default on load.
- `#workoutPlansList` renders exactly one card per seeded plan, none expanded.
- (Favorites filter and Start/expand interactions were exercised manually via the exposed `window.*` functions in the same harness, matching the design's verification steps.)

**Tracked in:** Design #8, Build #13 (sub-issues #19, #22–#25).
