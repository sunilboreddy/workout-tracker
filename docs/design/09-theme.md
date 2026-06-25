# Design: Visual Theme — Neon Sport

Implements: `docs/requirements/09-theme.md`

## Approach

The entire app already themes itself through ten CSS custom properties on `:root` (`index.html:15-27`) — 121 usages across the stylesheet reference `var(--accent-primary)` etc. rather than hardcoded colors. So this theme change is a `:root` remap only; no other CSS rule, markup, or script changes are needed.

## Mapping

| Variable | Old (current dark theme) | New (Neon Sport) | Used for |
|---|---|---|---|
| `--bg-primary` | `#0a0e14` | `#0f0f12` | page background |
| `--bg-secondary` | `#141921` | `#141420` | secondary panels |
| `--bg-card` | `#1a1f2e` | `#181820` | cards (stat boxes, day cards, exercise rows) |
| `--accent-primary` | `#00f5a0` | `#c4f600` | stat values, active tab, Start buttons, day-card accent bar, chips |
| `--accent-secondary` | `#00d9f5` | `#c4f600` (same as primary) | section titles, gradients, expand-icon, workout-date — the reference mockup uses one accent color for every highlight role, so primary/secondary collapse to the same lime rather than introducing a second hue the mockup never showed |
| `--accent-warm` | `#ff6b35` | `#ff3b6b` | delete/end-workout/favorite-star — kept as a visually distinct hue from the lime per the user's choice, since these are destructive/secondary actions that shouldn't read as "go" |
| `--text-primary` | `#e8eaf0` | `#ffffff` | headings, primary text |
| `--text-secondary` | `#a0a8b8` | `#b8bcc4` | subtitles, prescribed text |
| `--text-muted` | `#6b7280` | `#6b6b76` | inactive tab labels, placeholders |
| `--border` | `#2a3142` | `#23232e` | card/input borders |
| `--shadow` | `rgba(0, 245, 160, 0.1)` | `rgba(196, 246, 0, 0.12)` | glow/shadow tint, kept proportional to the new accent |

## Verification

Serve `index.html` locally, visually compare the `#workouts` tab (stat cards, tab pills, day cards with Start buttons) and the `#tracker` tab (delete-workout button, favorite star) against the reference mockup — confirm primary highlights read as neon lime and destructive actions read as a clearly distinct pink/red. Confirm no layout shift (this is a pure color swap, so the existing 16px-input fix from `04-set-logging.md`/`05-rest-timer.md` is unaffected).

**Tracked in:** Requirements `09-theme.md`.
