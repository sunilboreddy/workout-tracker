# Data Backup (Export/Import)

Source: user reported losing 2 previously-logged workouts and asked why, then asked for a way to save their data to a file they control.

## Why

The app stores everything in the browser's localStorage with no backend. Browsers can and do evict that storage on their own — most relevantly, Safari's Intelligent Tracking Prevention purges script-writable storage for sites not opened directly in about a week, unless the site is added to the Home Screen. There is no code bug behind this (confirmed: every save path in `index.html` does a read-modify-write, never a blind overwrite, and old/new workout-entry shapes both render correctly) — it's an inherent risk of browser-only storage that the app currently has no defense against.

## What's needed

- A way to get all workout history and workout plans out of the browser into a file the user controls (e.g. saved to the iPhone Files app), independent of browser storage.
- A way to load that file back in later — e.g. after losing data, after an app update, or on a new device — without needing to re-enter everything by hand.
- Restoring must never silently throw away data already on the device.
- Because the app has no way to detect whether a backup file exists out in the Files app, it should proactively offer the restore option whenever there's no workout history to show, rather than assuming "no history" always means "new user."

## Out of scope

- Any kind of automatic, ongoing/background backup — not possible from a backend-less static page; every export and import is a deliberate user action.
- Cloud sync between devices.

**Tracked in:** reported directly by the user.
