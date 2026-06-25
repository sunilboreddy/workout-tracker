# Tracking Mode

- Starting a workout narrows the app to show only that workout's exercises (warm-up/main/cardio/cool-down sections) until the session ends.
- An **End** action is always visible and reachable while tracking.
- If the user reloads the page mid-workout, their in-progress session and any sets already logged are not lost.
- Ending a workout with zero logged sets must not create a history entry.
- Ending a workout with at least one logged set must save it to the existing workout history.

*(Implementation note: how session state is persisted and resumed is deferred to `docs/design/`.)*

**Tracked in:** Requirements #4, Design #9

## CR: Full-screen focus mode (hide hero/header during tracking)

Real-device use revealed the original requirement was under-specified: tracking mode narrows the tab/content area, but the app's hero header (title + stat cards, shown above the tabs on every other screen) stays visible above the workout the whole time. Users want tracking mode to feel like a dedicated, focused screen — exercises and rest timer only, no surrounding app chrome — not a tab among tabs.

- While a workout is being tracked, the hero header must not be shown. Only the plan title, End action, exercises, and rest timer should be visible.
- Ending the workout restores the header exactly as before, with no change to that behavior.

**Tracked in:** reported directly by the user with real-device screenshots.
