# Build: Rest Timer

Follows: `docs/design/05-rest-timer.md`

## What was built

- `renderRestTimerSlot()`: renders either the preset picker (`.rest-timer-presets` with 30/60/90s `.rest-preset-btn`s plus a `.rest-custom-input`) or, while a timer is running, a `.rest-timer-countdown` (mm:ss) with a `.rest-cancel-btn` — the slot is a single fixed DOM location shared across exercises rather than one timer per exercise.
- `window.startRestTimer(seconds)` / `window.startCustomRestTimer()`: set `restTimerRemaining`, start a 1s `setInterval` (`restTimerInterval`) calling `renderRestTimerCountdown()`, and update the slot's markup to the countdown view.
- Single-timer enforcement: starting a new timer first calls `clearInterval(restTimerInterval)` on any existing one before starting the new one, so starting a second timer replaces rather than stacks with the first — no double-tick, no double-beep.
- `finishRestTimer()`: fires when the countdown reaches 0 — plays a beep via Web Audio (`AudioContext`/`OscillatorNode`, wrapped in try/catch so it degrades silently if audio is unavailable/blocked), calls `navigator.vibrate()` for haptic feedback, then calls `renderRestTimerSlot()` to reset the slot back to the preset picker.
- `stopRestTimer()`: cancel button path — clears the interval and resets to the preset picker without beeping/vibrating.

## Deviations from design

- None significant. Vibration was implemented exactly as designed (`navigator.vibrate()`, fire-and-forget); the design doc itself notes this is browser/device-dependent, which isn't independently verifiable in the jsdom harness (vibrate was stubbed as a no-op for test purposes).

## Verification

Verified with the jsdom harness (including real `setTimeout`-driven countdown ticking, not just code review):
- Starting a 5s timer renders `00:05` in `.rest-timer-countdown`.
- Starting a second timer (3s) before the first completes replaces the display with `00:03` — confirmed only one timer is ever live.
- Letting the replacement timer run to completion: the slot reverts to `.rest-timer-presets`, and the Web Audio stub's call counter (`__audioCtxCount`) is exactly `1` — confirming the beep fires once for the completed timer and not again for the earlier, replaced one.

**Tracked in:** Design #11, Build #16 (sub-issues #33–#35).
