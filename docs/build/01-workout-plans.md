# Build: Workout Plans

Follows: `docs/design/01-workout-plans.md`

## What was built

- `loadWorkoutPlans()` / `saveWorkoutPlans(plans)` against the new `workoutPlans` localStorage key, matching the existing read-modify-write pattern used for `workouts`.
- A `SEED_PLANS` constant holding the 3 plan objects converted from the old hardcoded `#3day` markup (Day 1/2/3), seeded into `workoutPlans` on first load when the key is absent.
- `#newPlanModal`: name field + 4 fixed section blocks (Warm-up/Main Workout/Cardio Finisher/Cool-down), each with dynamic exercise rows via `addPlanExercise(sectionIndex)` / `removePlanExercise(sectionIndex, rowId)`.
- `savePlan()` (push for create, replace-in-place for edit via `editingPlanId`), `editPlan(id)` (reopens the modal pre-filled), `deletePlan(id)` (confirm + remove), `toggleFavorite(id)`.
- The old `#3day`/`#4day`/`#5day` markup, tabs, and CSS were removed in the same change as the seeding logic.

## Deviations from design

- The old static splits had a 5th day-section ("Core Circuit"/"Core - Anti-rotation"/"Core Finisher") that doesn't map to the plan model's 4 fixed sections. Those exercises were folded into **Main Workout** rather than dropped, since core work there is logged the same way as the rest of the main lift.
- `SEED_PLANS` is a literal JS array transcribed from the old markup at build time, rather than code that parses the DOM at runtime — the design's "build 3 plan objects from the current hardcoded markup" step happens once, by hand, as part of writing this commit; there's no DOM-scraping function in the shipped code (matching the design's note that this is a one-time conversion, not a runtime branch).

## Verification

Verified with an automated jsdom harness driving the real `index.html` against real localStorage (not just code review):
- First load seeds exactly 3 plans with 4 sections each, correct titles/order.
- Creating a plan via `savePlan()` persists across a simulated reload; favoriting persists across reload; deleting removes the plan and leaves `workouts` untouched.

**Tracked in:** Design #7, Build #12 (sub-issues #17–#21).
