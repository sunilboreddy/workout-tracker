# Design: Edit/Delete a Logged Set

Implements: `docs/requirements/08-edit-logged-sets.md`

## UI

Each `.set-log-chip` (previously a static `<span>`, per `04-set-logging.md`) becomes two elements:
- `.set-log-chip-label` — the existing "Set N: X reps" text, now clickable.
- `.set-log-chip-remove` — a small "×" button.

No new modal. Editing reuses the browser's native `prompt()`, pre-filled with the current value — consistent with the app's existing minimal-native-dialog style (`confirm()` is already used for plan/workout deletion).

## Behavior

- Clicking a chip's label calls `editLoggedSet(exerciseName, index)`: prompts for a new rep count, parses it as a positive integer, and if valid, overwrites `loggedSets[exerciseName].reps[index]`.
- Clicking a chip's "×" calls `deleteLoggedSet(exerciseName, index)`: removes that index from `loggedSets[exerciseName].reps` via `splice`.
- Both persist immediately via `saveActiveSession` (same resume-after-refresh guarantee as initial logging) and re-render just that exercise's chip list — no full tracking-view re-render.
- Cancelling the prompt (returns `null`) or entering a non-positive/non-numeric value leaves the set unchanged.
- Set numbering ("Set 1", "Set 2"...) is always derived from current array position, so deleting set 1 renumbers the remaining sets rather than leaving a gap.

## Compatibility

Only `activeSession.loggedSets` is touched — the same shape `endWorkout()` already maps into the `workouts` history array (`04-set-logging.md`), so no changes needed to history/stats code.

## Verification

Log 2 sets, edit the first one's reps via prompt, confirm the array and rendered chip update. Delete a set, confirm the array shrinks and remaining sets renumber correctly in the UI.

**Tracked in:** Design #13, Build #18.
