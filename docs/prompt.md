# Build Kickoff Prompt

Use this prompt to start a session that implements the workout-plan-selection / tracking-mode / rest-timer feature.

---

> Implement the workout-plan-selection, tracking-mode, and rest-timer feature in `index.html` on branch `claude/workout-tracking-requirements-9na07d`.
>
> Read `CLAUDE.md` for architecture/conventions, then `docs/requirements/01`–`05` and `docs/design/01`–`05` in order. Check GitHub for the open Build issues and their sub-issues to see current task state.
>
> Build the 5 capabilities in that same 01–05 order — each depends on the data/UI the previous one introduces (plans → list/start → tracking session → set logging → rest timer).
>
> For each capability: implement its sub-issues, test manually in-browser against the design doc's Verification section, close issues as you go, then write `docs/build/0X-*.md` as a real changelog (what was built, deviations from the design, gotchas) — not a pre-written task list.
>
> Done when the static `#3day`/`#4day`/`#5day` tabs are fully replaced by the data-driven `#workouts` flow, all issues are closed, and existing workout history/stats still work unmodified.
