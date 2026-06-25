# Design — Workout Plan Selection, Tracking Mode & Rest Timer

Status: Draft v1
References: `docs/requirements/01`–`05`. Project: **Workout Tracker — Smart Tracking**.

These documents describe **how** the requirements get implemented within the existing single-file `index.html` architecture (see `CLAUDE.md`). No build step, no new dependencies — everything is added to the existing `<style>`/body/`<script>` structure.

## Cross-cutting decisions

- **Tabs change from 5 to 3**: `#3day`, `#4day`, `#5day` are removed. A new `#workouts` tab (default-active) replaces them, listing every plan — the old static splits (migrated into plan data, see below) plus any user-created ones — with Start/expand/favorite actions. `#tracker` and `#progression` are unchanged.
- **"Image-based" plan creation has no separate UI.** Per requirements, digitizing a photo just means the user manually fills in the same "New Plan" form while looking at their photo. There is one creation flow, not two.
- **New localStorage key**: `workoutPlans` (array of plan objects, see `01-workout-plans.md`). On first load, if this key doesn't exist, it's seeded once with the 3 existing static splits converted to plan objects, then those tabs/hardcoded markup are deleted from the HTML — i.e. the migration is a one-time data conversion, not a runtime fallback.
- **Existing `workouts` history/stats are untouched** — tracking-mode sessions save into that same array in the same shape, so `loadWorkoutHistory()`/`updateProgressStats()` keep working unmodified.
- **New localStorage key**: `activeSession` (single object, not an array) for the in-progress tracking session, enabling resume-after-refresh.
- **Globals**: all new `onclick`-invoked functions are exposed on `window.*`, following the existing pattern (`window.startWorkout`, `window.endWorkout`, `window.toggleFavorite`, etc.).

## Files

1. [01-workout-plans.md](./01-workout-plans.md) — plan data model, seeding/migration, create/edit/delete/favorite
2. [02-workout-list-selection.md](./02-workout-list-selection.md) — `#workouts` tab layout, list rendering, favorites filter
3. [03-tracking-mode.md](./03-tracking-mode.md) — full-screen tracking view, session persistence/resume, Start/End
4. [04-set-logging.md](./04-set-logging.md) — per-exercise set entry UI and save format
5. [05-rest-timer.md](./05-rest-timer.md) — countdown UI, sound/vibration
6. [07-import-plan.md](./07-import-plan.md) — Import Plan modal, expected JSON shape, validation
7. [08-per-set-weight.md](./08-per-set-weight.md) — `loggedSets`/history data model change to track weight per set
8. [09-theme.md](./09-theme.md) — Neon Sport `:root` color variable remap
9. [10-data-backup.md](./10-data-backup.md) — Export/Import buttons, JSON file shape, merge-by-id semantics

Note: editing/deleting a logged set is a CR against [04-set-logging.md](./04-set-logging.md), not a separate file — see the "CR" section there. The full-screen focus mode during tracking is a CR against [03-tracking-mode.md](./03-tracking-mode.md), also not a separate file.

Build (`docs/build/`) comes next, referencing these files.
