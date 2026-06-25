# Build: Visual Theme — Neon Sport

Follows: `docs/design/08-theme.md`

## What was built

- Remapped the 10 `:root` custom properties (`index.html:15-27`) to the Neon Sport palette per the design doc's mapping table. No other CSS rules, markup, or script changes — the existing var()-driven stylesheet picked up the new palette everywhere automatically (121 usages across stat cards, tabs, day cards, buttons, chips, etc.).
- `--accent-primary` and `--accent-secondary` both set to `#c4f600` (same lime), since the reference mockup uses a single accent color for every highlight role.
- `--accent-warm` set to `#ff3b6b` (hot pink/red, user's choice) to keep destructive/secondary actions (delete workout, end workout, favorite star) visually distinct from the primary lime.

## Deviations from design

- None. Implemented exactly the mapping table in the design doc.

## Verification

Served the patched `index.html` locally and checked with Playwright:
- `#workouts` tab: stat values, active tab pill, "Start" buttons, and day-card layout render in the neon lime against the near-black background, matching the reference mockup.
- Confirmed via `getComputedStyle` that the "Delete" button on a day card renders `#ff3b6b`, clearly distinct from the lime accent.
- No layout shift — this was a pure color swap, so the existing 16px-input fix (`04-set-logging.md`/`05-rest-timer.md`) is unaffected.

**Tracked in:** Design `08-theme.md`.
