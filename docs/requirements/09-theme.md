# Visual Theme — Neon Sport

- The app currently uses a single dark theme (teal/cyan accents on a near-black background). The user wants a new look: a near-black background with a vivid neon lime accent, in the style of a reference mockup ("05 — Neon Sport") they provided.
- This is a palette change only — no layout, no new screens, no change to existing tab structure (`#workouts`, `#tracker`, `#progression`), no change to any data model or behavior.
- Primary highlight color (stat values, active tab, "Start" buttons, day-card accent bars, chips) becomes neon lime.
- Destructive/secondary actions (delete workout, end workout/session, favorite star) keep a distinct, clearly different color from the primary lime so they don't read as "go" actions — the reference mockup didn't define this role, so the user chose a hot pink/red for it.
- Existing accessibility-motivated choices (e.g. 16px minimum input font-size, see `04-set-logging.md`/`05-rest-timer.md` follow-up fixes) are unaffected by this change.

*(Implementation note: exact color values and which CSS custom properties they map to are deferred to `docs/design/`.)*

**Tracked in:** Requested directly by the user, referencing a "Neon Sport" mockup image and the CSS color values they wanted used.
