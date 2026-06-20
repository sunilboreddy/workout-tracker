# Workout List & Selection

- The current day and date header remains visible at all times, independent of which plan or workout is selected or active.
- Below the header, all workouts (existing reference splits plus any user-created plans) are listed with nothing pre-expanded or pre-selected.
- Each workout in the list has a **Start** action that begins a tracking session for that workout, distinct from expanding it to view its details (today's expand-to-view behavior is retained).
- Favorited workouts must be easy to find in the list.

*(Implementation note: exact list layout and favorite-filtering UI are deferred to `docs/design/`.)*

**Tracked in:** Requirements #3, Design #8
