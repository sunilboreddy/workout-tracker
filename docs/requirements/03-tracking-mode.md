# Tracking Mode

- Starting a workout narrows the app to show only that workout's exercises (warm-up/main/cardio/cool-down sections) until the session ends.
- An **End** action is always visible and reachable while tracking.
- If the user reloads the page mid-workout, their in-progress session and any sets already logged are not lost.
- Ending a workout with zero logged sets must not create a history entry.
- Ending a workout with at least one logged set must save it to the existing workout history.

*(Implementation note: how session state is persisted and resumed is deferred to `docs/design/`.)*
