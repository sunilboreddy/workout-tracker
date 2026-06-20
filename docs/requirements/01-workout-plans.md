# Workout Plans

- A workout plan is a named, structured set of exercises (warm-up, main workout, cardio finisher, cool-down) that the user can select, view, edit, or delete.
- Plans can be created in two ways, both producing an equally first-class, selectable plan:
  - **Manual entry** — the user fills in the plan directly in the app.
  - **Digitized from an image** — the user photographs a workout plan (e.g. a gym handout) and transcribes it into the app once. The app does not need to perform OCR or AI parsing of the photo itself.
- Plans are not tagged by source (manual vs. image) — once created, they're indistinguishable.
- No plan is preselected or marked active by default when the app loads.
- A plan can be marked as a **favorite** so the user can find important plans quickly.
- There is no plan duplication feature.

*(Implementation note: storage mechanism and exact data shape are deferred to `docs/design/`.)*
