# Build: Data Backup (Export/Import)

Follows: `docs/design/10-data-backup.md`

## What was built

- `.backup-actions` row added to the `#tracker` panel, between the existing tracker header and the progress stats: "Export Data" / "Import Data" buttons (reusing the existing `.add-workout-btn` style) plus a hidden `#importDataInput` (`<input type="file" accept="application/json">`).
- `window.exportWorkoutData()`: builds `{ workouts, workoutPlans, exportedAt }` from the two localStorage keys, downloads it via `Blob` + `URL.createObjectURL` + a programmatically-clicked `<a download="workout-backup-YYYY-MM-DD.json">`.
- `window.importWorkoutData()`: just clicks the hidden `#importDataInput`.
- `window.handleImportFile(event)`: reads the selected file via `FileReader`, `JSON.parse`s it (alerting and aborting on malformed JSON), then for both `workouts` and `workoutPlans` filters the incoming array down to ids not already present locally and `concat()`s the rest — merge, never replace. Re-renders `loadWorkoutHistory()` / `updateProgressStats()` / `renderWorkoutList()` and shows an `alert()` with the count actually added (post-dedup).
- `loadWorkoutHistory()`'s empty state gained one extra line — a "Restore from backup" link calling `importWorkoutData()` — shown identically whenever `workouts` is empty, since the app can't distinguish first-use from data loss.

## Deviations from design

- None significant.

## Verification

Served the patched `index.html` locally and drove it with Playwright against real localStorage:
- Seeded one workout, called `exportWorkoutData()` with `URL.createObjectURL` intercepted to read the `Blob` back — confirmed the downloaded JSON's `workouts`/`workoutPlans` exactly match localStorage, plus a valid `exportedAt`.
- Cleared `workouts`/`workoutPlans`, dispatched a `change` event on `#importDataInput` with a synthetic two-workout backup file — confirmed both workouts were restored and the alert reported "Restored 2 workout(s) and 0 plan(s)."
- Imported a second file containing one already-present id (1001) and one new id (3003) — confirmed only the new workout was added (no duplicate of 1001), alert reported "Restored 1 workout(s)."
- Cleared `workouts` and called `loadWorkoutHistory()` directly — confirmed the empty state now renders the "Restore from backup" link wired to `importWorkoutData()`.
- Screenshot of the Tracker tab confirms the Export/Import buttons render correctly alongside the existing "+ Log Workout" button.

**Tracked in:** reported directly by the user.
