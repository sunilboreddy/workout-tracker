# Build: Edit/Delete a Logged Set

Follows: `docs/design/08-edit-logged-sets.md`

## What was built

- `renderSetChips(safeName, reps)`: shared helper producing the chip markup (label + remove button) used both on initial tracking-view render and after any set mutation — replaces the inline `.map()` that used to live in two places.
- `window.editLoggedSet(exerciseName, index)`: `prompt()`-based edit, validates the result as a positive integer before writing back to `loggedSets[exerciseName].reps[index]` and persisting via `saveActiveSession`.
- `window.deleteLoggedSet(exerciseName, index)`: `splice`s the given index out of `reps` and persists.
- `renderSetChipsInto(exerciseName, reps)`: re-renders just the `#trackSets-*` container after either operation, reused by `logSet()` too (replacing its previous inline chip-string `.map()`).
- CSS: `.set-log-chip` changed from a single `<span>` to a flex container holding `.set-log-chip-label` (hover-highlighted to signal it's clickable) and `.set-log-chip-remove`.

## Deviations from design

- None significant.

## Verification

Verified with the jsdom harness against real localStorage: logged 2 sets (10, 8 reps), edited set 1 to 15 reps (`[15, 8]`), then deleted index 0 (`[8]`) — array and re-rendered chip markup matched expectations at each step. Full existing regression suite (32 prior assertions) still passes unmodified.

**Tracked in:** Design #13, Build #18. PR #43.
