# Design: Rest Timer

Implements: `docs/requirements/05-rest-timer.md`

## Trigger

Immediately after `logSet()` succeeds (see `04-set-logging.md`), a small timer control appears inline below that exercise (or in a shared single timer slot at the top/bottom of `#trackingView` — one timer can only ever apply to one exercise at a time, so a single shared slot is simpler than per-exercise instances): buttons **30s / 60s / 90s** + a custom number input + **Start**.

## Countdown

`window.startRestTimer(seconds)`:
1. If a timer is already running, `clearInterval()` it first — only one active timer at a time (starting a new one always replaces the old one).
2. Store `remaining = seconds`, render `mm:ss`, and `setInterval(() => { remaining--; render; if (remaining <= 0) finishRestTimer(); }, 1000)`.
3. Timer state lives in a plain JS variable (not localStorage/`activeSession`) — per requirements it doesn't need to survive navigating away or a refresh.

## Completion

`finishRestTimer()`:
- `clearInterval()`, reset the UI back to the preset/custom picker.
- **Sound**: short beep via the Web Audio API (`AudioContext` + `OscillatorNode`, no external audio file/dependency needed) — wrapped in `try/catch` since some browsers require a prior user gesture to create an `AudioContext` (already satisfied here since the timer was started by a tap).
- **Vibration**: `if (navigator.vibrate) navigator.vibrate(200);` — no-op on unsupported devices/browsers (e.g. iOS Safari), which is an accepted graceful-degradation per requirements.

## Verification

Start a 30s timer, confirm countdown displays and decrements every second. Start another timer before the first finishes — confirm only the new one continues (no double-beep at the end). Let one run to completion — confirm a beep and (on a supporting device) vibration fire once.

**Tracked in:** Design #11, Build #16

## Follow-up fix: page zooms/shifts when tapping the custom seconds field

Implements the follow-up fix in `docs/requirements/05-rest-timer.md`. Same root cause as `04-set-logging.md`'s follow-up fix: `.rest-custom-input` sets no explicit `font-size`, so it falls back to the browser's small default control font (under 16px), triggering mobile auto-zoom on focus. Fix: give `.rest-custom-input` an explicit `font-size: 1rem` (16px).

**Tracked in:** Reported directly by the user with screenshots during day-to-day use of tracking mode.
