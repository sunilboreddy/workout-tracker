# Rest Timer

- After logging a set, the user can start a rest timer without leaving the tracking view.
- Duration is chosen via 30s/60s/90s presets, or a custom value entered by the user.
- Only one timer is meaningfully active at a time.
- On completion, the user is notified via both sound and vibration, degrading gracefully if the browser or device doesn't support one.
- The timer does not need to survive the user leaving the app.

*(Implementation note: countdown UI and notification APIs used are deferred to `docs/design/`.)*

**Tracked in:** Requirements #6, Design #11
