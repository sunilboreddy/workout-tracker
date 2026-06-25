# Requirements — Workout Plan Selection, Tracking Mode & Rest Timer

Status: Draft v1
Source: User narrative + 3 reference workout plan images (Day 1/2/3 upper/lower/full-body split).

These documents describe **what** the app needs to do and **why** — not how it will be built. Implementation choices belong in `docs/design/`, which will reference these files once written.

## Files

1. [01-workout-plans.md](./01-workout-plans.md) — creating, editing, favoriting, and deleting workout plans
2. [02-workout-list-selection.md](./02-workout-list-selection.md) — the header, the workout list, and selecting a workout
3. [03-tracking-mode.md](./03-tracking-mode.md) — starting/ending a focused tracking session
4. [04-set-logging.md](./04-set-logging.md) — logging weight/reps per set while tracking
5. [05-rest-timer.md](./05-rest-timer.md) — the rest timer between sets
6. [06-open-questions.md](./06-open-questions.md) — anything still undecided
7. [07-import-plan.md](./07-import-plan.md) — creating a plan by pasting Claude-generated JSON instead of manual entry
8. [08-per-set-weight.md](./08-per-set-weight.md) — tracking weight per logged set instead of once per exercise
9. [09-theme.md](./09-theme.md) — the Neon Sport visual color theme
10. [10-data-backup.md](./10-data-backup.md) — exporting/importing workout data as a JSON backup file

Note: editing/deleting a logged set is a CR against [04-set-logging.md](./04-set-logging.md), not a separate file — see the "CR" section there. The full-screen focus mode during tracking is a CR against [03-tracking-mode.md](./03-tracking-mode.md), also not a separate file.

Design (`docs/design/`) and build (`docs/build/`) docs come later, each referencing the requirement files above.
