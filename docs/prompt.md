# Build Kickoff Prompt

Use this prompt (verbatim or adapted) to start a session that implements the workout-plan-selection / tracking-mode / rest-timer feature.

---

> Implement the workout-plan-selection, tracking-mode, and rest-timer feature in `index.html` on branch `claude/workout-tracking-requirements-9na07d`.
>
> ## Context
>
> Read `CLAUDE.md` first for the project's architecture and conventions (single self-contained `index.html`, no build step/dependencies, `window.*` globals for inline `onclick` handlers, read-modify-write localStorage pattern). Then read the requirements and design docs for each capability before touching code:
>
> | Capability | Requirements | Design | Build issue | Sub-issues |
> |---|---|---|---|---|
> | Workout Plans | `docs/requirements/01-workout-plans.md` | `docs/design/01-workout-plans.md` | #12 | #17–21 |
> | Workout List & Selection | `docs/requirements/02-workout-list-selection.md` | `docs/design/02-workout-list-selection.md` | #13 | #22–25 |
> | Tracking Mode | `docs/requirements/03-tracking-mode.md` | `docs/design/03-tracking-mode.md` | #14 | #26–29 |
> | Set Logging | `docs/requirements/04-set-logging.md` | `docs/design/04-set-logging.md` | #15 | #30–32 |
> | Rest Timer | `docs/requirements/05-rest-timer.md` | `docs/design/05-rest-timer.md` | #16 | #33–35 |
>
> Each Design issue (#7–11) says "Implements #N" back to its Requirements issue (#2–6); each Build issue says "Implements design #N". Sub-issues carry the concrete implementation tasks.
>
> ## Scope and order
>
> Implement the 5 capabilities **in the table order above** — each depends on the previous:
> 1. **Workout Plans** (#12) first — the `workoutPlans` data model and seed migration everything else reads from.
> 2. **Workout List & Selection** (#13) — the `#workouts` tab that lists and starts plans created in step 1.
> 3. **Tracking Mode** (#14) — the full-screen session view that `startWorkout()` (from step 2) enters.
> 4. **Set Logging** (#15) — the per-exercise logging UI that lives inside the tracking view from step 3.
> 5. **Rest Timer** (#16) — triggered after a set is logged in step 4.
>
> Within each capability, implement its sub-issues in numeric order.
>
> ## Conventions to follow (from `CLAUDE.md`)
>
> - Everything stays in `index.html` — no new files, no build step, no dependencies.
> - New `onclick`-invoked functions must be exposed on `window.*` (inline `onclick=` resolves against globals, not closures).
> - New persisted data goes through the same read-modify-write pattern already used for the `workouts` array.
> - Do not modify `#tracker`, `#progression`, or the existing `workouts` localStorage shape — `loadWorkoutHistory()` and `updateProgressStats()` must keep working unmodified, including the pull-up/push-up substring matching.
>
> ## Per-capability loop
>
> For each capability, in order:
> 1. Read its requirements and design docs.
> 2. Implement its sub-issues in numeric order.
> 3. Close each sub-issue on GitHub once that piece of code is working.
> 4. Manually test in-browser (there is no automated test suite) — use each design doc's "Verification" section as the test script.
> 5. Write `docs/build/0X-*.md`: a real changelog of what was built, any deviations from the design doc and why, and gotchas hit. Reference the design doc it follows and the Build issue number.
> 6. Close the parent Build issue.
>
> ## Definition of done
>
> - The static `#3day`/`#4day`/`#5day` tabs and markup are deleted, replaced entirely by the data-driven `#workouts` flow.
> - All 35 GitHub issues (#2–35) are closed.
> - `docs/build/01` through `05` exist, each a genuine changelog (not a pre-written task list).
> - Existing workout history and progress stats are unaffected — verified by logging a tracking-mode workout and confirming it renders identically to a manually-logged one in the Tracker tab.

---

**Tracked in:** created alongside Build issues #12–16, Design #7–11, Requirements #2–6.
