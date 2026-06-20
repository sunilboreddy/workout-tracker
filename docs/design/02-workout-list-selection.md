# Design: Workout List & Selection

Implements: `docs/requirements/02-workout-list-selection.md`

## Tab structure

Tabs become: `Workouts` (new, `data-tab="workouts"`, default-active), `Tracker` (unchanged), `Progression` (unchanged). `3day`/`4day`/`5day` tab buttons and panels are removed (content migrated per `01-workout-plans.md`).

The existing day/date header markup (`.hero` stats block at the top) is untouched and stays visible above the tab bar regardless of which tab or mode is active — it already renders independently of tab state today, so no structural change is needed there, only confirmation it isn't hidden by the new tracking-mode takeover (see `03-tracking-mode.md`).

## `#workouts` panel

- Renders one card per entry in `workoutPlans` (via `renderWorkoutList()`), reusing the existing `.day-card` / `.day-header` / `.day-content` expand-on-click pattern for viewing detail (`.exercise-name` + `.exercise-details` per exercise, grouped by section with the same icon/title styling as today's day cards).
- Nothing is expanded by default — `.day-content` starts collapsed for every card, same as today's collapsed state, just with no card pre-opened.
- Each card header row adds two controls beside the existing expand toggle:
  - **★ Favorite toggle** — calls `window.toggleFavorite(id)`, filled/outline star reflects `favorite`.
  - **Start button** — calls `window.startWorkout(id)`, stops propagation so it doesn't also trigger the expand toggle.
- **Favorites filter**: a small toggle/chip above the list ("★ Favorites only") filters `workoutPlans` client-side before rendering; persisted in-memory only (not localStorage — it's a view filter, not data).
- **+ New Plan** button at the top of the panel opens the modal from `01-workout-plans.md`.

## Verification

Load the app: `Workouts` tab is active by default, no card expanded. Tap a card to expand/collapse (existing behavior). Tap Start on a card and confirm it enters tracking mode for that plan (see `03-tracking-mode.md`). Toggle the favorites filter and confirm only starred plans show.

**Tracked in:** Design #8, Build #13
