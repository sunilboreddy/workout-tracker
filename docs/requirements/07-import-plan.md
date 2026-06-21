# Import Plan

- The user can create a plan by pasting a structured text/JSON description instead of manually typing every exercise into the "New Plan" form.
- The intended workflow: the user photographs a physical/written workout plan and sends it to Claude in a chat session, which converts the photo into the structured format; the user then pastes that into the app.
- The app does not perform any OCR/AI parsing itself, and does not call any external API or require an API key — this keeps the app's "single self-contained HTML file, no backend" architecture (`CLAUDE.md`) unchanged. All parsing happens outside the app, in the user's chat with Claude.
- Pasted input that isn't valid, or is missing required fields, must show an inline error rather than silently failing or corrupting existing plans.
- An imported plan must be indistinguishable from a manually-created one afterward — fully trackable, editable, favoritable, deletable, with no separate "imported" code path.

**Tracked in:** Requirements #7, Design #12. Originally explored under Issue #40 (full OCR/AI-in-app was considered and rejected in favor of this lighter approach — see issue discussion).
