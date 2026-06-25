# Build: Tracking Mode

Follows: `docs/design/03-tracking-mode.md`

## What was built

- `loadActiveSession()` / `saveActiveSession(session)` against the new `activeSession` localStorage key (single object, not an array). Shape: `{ planId, startedAt, loggedSets }` — `planName` was dropped from the stored session since it's derivable from the live plan lookup (`planId` → `workoutPlans`), avoiding a stale duplicate.
- `window.startWorkout(planId)`: writes a fresh `activeSession` with empty `loggedSets`, then calls `enterTrackingView()`.
- `enterTrackingView()`: adds `tracking-active` to `<body>`, which (via CSS) hides `.tabs` and all `.workout-split` panels while showing `#trackingView`. Renders the plan name, an always-visible **End** button in a sticky `.tracking-end-bar`, then each section read-only (warm-up/cool-down) or with logging controls (main/cardio — see `04-set-logging.md`).
- Resume-on-load: `DOMContentLoaded` checks `loadActiveSession()` before deciding whether to call `enterTrackingView()` or `renderWorkoutList()`.
- `window.endWorkout()`: discards the session if `loggedSets` is empty; otherwise builds a `workouts`-shaped entry (`{ id: Date.now(), type: <plan name>, date: today, exercises }`) and `unshift()`s it into the existing `workouts` array, then removes `activeSession`, exits tracking view, and re-renders both `#workouts` and the Tracker tab's history/stats.

## Deviations from design

- The session no longer stores `planName` (design's sample shape included it) — `enterTrackingView()` and `endWorkout()` both look the plan up live by `planId` anyway, so persisting the name would just be a stale-able duplicate. If a plan is renamed mid-session, the saved history entry now reflects the renamed plan rather than the name at start time; this is a closer fit to the "no snapshot duplication" philosophy already in the design (which explicitly skips snapshotting plan sections for the same reason).

## Verification

Verified end-to-end with the jsdom harness against real localStorage (not just code review):
- `startWorkout()` sets `tracking-active` on `<body>` and writes a correctly-shaped `activeSession`.
- Logging a set, then constructing a brand-new DOM instance seeded with the dumped localStorage (simulating a hard refresh), re-enters tracking view automatically and shows the previously logged set.
- `endWorkout()` with logged sets clears `activeSession`, removes `tracking-active`, and creates exactly one `workouts` history entry with correct weight/sets.
- `endWorkout()` immediately after `startWorkout()` with nothing logged creates zero history entries and still clears `activeSession`.
- `.hero` header confirmed visible (non-`none` computed `display`) while `tracking-active` is set.

**Tracked in:** Design #9, Build #14 (sub-issues #26–#29).

## CR: Full-screen focus mode

Implements the CR in `docs/design/03-tracking-mode.md`.

### What was built

- `index.html`'s `/* TRACKING VIEW */` CSS block gained `.hero` as a third selector alongside the existing `.tabs`/`.content > .workout-split` rule, so it's hidden under `body.tracking-active` too: `body.tracking-active .tabs, body.tracking-active .content > .workout-split, body.tracking-active .hero { display: none; }`. No JS or markup changes — `tracking-active` was already toggled correctly.

### Deviations from design

- None.

### Verification

Served the patched `index.html` locally and drove it with Playwright:
- `window.startWorkout(1)` → `getComputedStyle` confirms `.hero` and `.tabs` both compute to `display: none`; a screenshot shows only the plan title, End button, and Warm-up exercises full-width from the top of the screen.
- `window.endWorkout()` → `.hero` and `.tabs` immediately compute back to `block`/`flex`, confirming the toggle still correctly restores the header/tabs on End.
- Visual spot-check: switching to `#tracker`/`#progression` outside tracking mode is unaffected (hero still shows the stat cards as before).

**Tracked in:** reported directly by the user with real-device screenshots.
