# Rest Timer

- After logging a set, the user can start a rest timer without leaving the tracking view.
- Duration is chosen via 30s/60s/90s presets, or a custom value entered by the user.
- Only one timer is meaningfully active at a time.
- On completion, the user is notified via both sound and vibration, degrading gracefully if the browser or device doesn't support one.
- The timer does not need to survive the user leaving the app.

*(Implementation note: countdown UI and notification APIs used are deferred to `docs/design/`.)*

**Tracked in:** Requirements #6, Design #11

## Follow-up fix: page zooms/shifts when tapping the custom seconds field

- Tapping the custom rest-duration seconds input zooms the whole page in, same symptom as the set-logging inputs (see `docs/requirements/04-set-logging.md`'s follow-up fix) — the layout ends up shifted/cut off even after the keyboard closes.
- This must not happen — tapping the custom seconds input should not change the page's zoom level.

**Tracked in:** Reported directly by the user with screenshots during day-to-day use of tracking mode.
