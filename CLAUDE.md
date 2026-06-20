# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A mobile-friendly workout tracking app implemented as a **single self-contained HTML file** (`index.html`). No build step, no package manager, no dependencies, no backend. All HTML, CSS (in a `<style>` block), and JavaScript (in a `<script>` block at the bottom) live in that one file.

## Running / developing

There is no build or test tooling. To work on this app:
- Open `index.html` directly in a browser, or serve it locally (e.g. `python3 -m http.server`) and visit it.
- Reload the browser after any edit — there is no dev server with hot reload.
- Test changes manually in-browser (mobile viewport recommended, since this is mobile-first).

## Deployment

Static GitHub Pages deploy: push to the repo, enable Pages from the main branch, served at `https://<user>.github.io/workout-tracker`.

## Architecture

Everything is in `index.html`, organized in three parts:

1. **`<style>` (head)** — dark-themed CSS using custom properties (`--bg-primary`, `--accent-primary`, etc.) defined on `:root`. Visual sections include `.hero` (stats header), `.tabs`, `.workout-split` cards, and the add-workout `.modal`.
2. **Body markup** — a tab bar (`.tab[data-tab=...]`) controls which `.workout-split` panel is visible via the `active` class. Panels by id:
   - `#tracker` — workout history + progress stats, populated dynamically by JS.
   - `#3day`, `#4day`, `#5day` — static hardcoded workout split content (day cards).
   - `#progression` — static progression guide content (squats/pull-ups/push-ups).
   The "Add Workout" flow uses `#addWorkoutModal`, with exercise rows dynamically built into `#exercisesContainer`.
3. **`<script>` (bottom)** — all app logic, no modules/classes, plain functions and a few `window.*` globals (needed because they're invoked from inline `onclick=` attributes in generated markup):
   - Tab switching: toggles `.active` on `.tab` and corresponding `.workout-split`.
   - Add-workout modal: `addExercise()` / `removeExercise()` / `addSet()` dynamically build exercise/set input rows with ids like `exercise-{n}`, `exerciseName-{n}`, `set-{n}-{setIndex}`.
   - Persistence: the entire workout log is one array under the `workouts` localStorage key. Each workout: `{ id (timestamp), type, date, exercises: [{ name, weight, sets: [reps...] }] }`. There is no other storage key and no backend — all data is local to the browser.
   - Derived stats (`updateProgressStats`): total workouts, workouts this week, best pull-up/push-up totals — computed by re-scanning the full `workouts` array on every load/save/delete. Exercise matching for pull-ups/push-ups is done via substring checks on lowercased exercise names (e.g. `'pull-up'`, `'pullup'`).
   - `formatDate()` renders relative labels ("Today"/"Yesterday") else a short date.

## Conventions to follow when editing

- Keep everything in `index.html` — don't introduce a build step or split into modules unless explicitly asked.
- New interactive elements created via `innerHTML` template strings that need `onclick` handlers must expose those handlers on `window` (see `window.addExercise`, `window.deleteWorkout`, etc.), since inline `onclick=` resolves against globals, not closures.
- Any new persisted data should go through the same read-modify-write pattern against the `workouts` localStorage array — there's no separate data layer to route through.
