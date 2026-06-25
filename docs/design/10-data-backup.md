# Design: Data Backup (Export/Import)

Implements: `docs/requirements/10-data-backup.md`

## Constraint

A static page served from GitHub Pages has no background or continuous file-system access. It cannot silently create a file on first use and keep appending to it, and it has no way to check whether a backup file already exists in the Files app. Every export is therefore a manual, full-snapshot download; every import is a manual file-picker selection. The app also can't distinguish "genuinely new user" from "lost my data" on its own — both look identical (empty `workouts`/`workoutPlans`). The empty-state prompt below is the answer to that: always offer restore when there's nothing to show, rather than trying to detect which case it is.

## File shape

```js
{
  workouts: [...],       // full contents of the `workouts` localStorage array
  workoutPlans: [...],   // full contents of the `workoutPlans` localStorage array
  exportedAt: "2026-06-25T12:00:00.000Z"
}
```

## Export

`window.exportWorkoutData()`, triggered by an "Export Data" button on the Tracker tab (`#tracker`, next to `#workoutHistory`):
1. Read both localStorage keys, build the object above.
2. `new Blob([...], { type: 'application/json' })` → `URL.createObjectURL` → a temporary `<a download="workout-backup-YYYY-MM-DD.json">` clicked programmatically. Standard dependency-free browser download pattern; on iOS Safari this surfaces the native share/save sheet, where "Save to Files" is already one of the built-in options.

## Import

`window.importWorkoutData()` (button) opens a hidden `<input type="file" accept="application/json">` (`#importDataInput`); its `onchange` calls `window.handleImportFile(event)`:
1. `FileReader.readAsText`, `JSON.parse`. Malformed JSON → `alert()` and abort, no localStorage write.
2. **Merge, not replace**: for each of `workouts`/`workoutPlans`, build a `Set` of existing `id`s already in localStorage, filter the incoming array down to ids not already present, `concat()` and write back. This guarantees import can only ever add data, never delete what's already on the device — consistent with the rest of the app's read-modify-write-only persistence pattern.
3. Re-render: `loadWorkoutHistory()`, `updateProgressStats()`, `renderWorkoutList()` (plans list), then a summary `alert()` of how many workouts/plans were actually added (after dedup).

## Empty-state restore prompt

`loadWorkoutHistory()`'s existing empty state (shown when `workouts.length === 0`) gets one added line: a "Restore from backup" link that calls `importWorkoutData()`. Shown identically on first-ever use and on any future data-loss — the app can't tell those apart, so it always offers the option.

## Verification

- Export with data present → downloaded file's `workouts`/`workoutPlans` match localStorage exactly.
- Clear localStorage, import the exported file → history and plans fully restored.
- Import the same file again with existing data present → no duplicates (ids already present are filtered out).
- Import a file with one new + one already-present workout → only the new one is added, confirmed by the resulting count and array contents.

**Tracked in:** reported directly by the user.
