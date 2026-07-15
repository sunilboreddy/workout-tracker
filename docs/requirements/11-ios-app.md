# iOS App (Capacitor)

Source: user request to ship the workout tracker as a real iPhone app without a Mac.

## Why

The web app (GitHub Pages) is actively used, but it lives in a browser tab — subject to Safari storage eviction, not installable from the App Store, and missing native capabilities (haptic feedback, native file access). The user wants a real `.ipa` that can be distributed via TestFlight and eventually the App Store, without requiring a Mac for the build process.

## What's needed

- A native iPhone app that faithfully replicates the existing web app's features.
- The web version on `main` must remain live and untouched — the iOS work is on a separate branch.
- The iOS build must work without a Mac (cloud CI only).
- Native behavior where the web app falls short:
  - Haptic pulse when rest timer ends (currently uses `navigator.vibrate`, which does not work on iOS).
  - Export: downloading a JSON backup must open the native iOS share sheet (the `<a download>` pattern doesn't fire on iOS).
  - Import: picking a JSON file from Files app should use the native file picker.
- All existing functionality (plans, tracking, set logging, rest timer, history, backup) must work identically.

## Out of scope (post-launch)

- Background timer notifications (fires when app is fully closed).
- HealthKit integration.
- Android support (can be added later — same web layer).

**Tracked in:** requested directly by the user.
