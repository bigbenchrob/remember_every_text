---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-06-05
links:
  - ./CHARTER.md
  - ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
feature: messages
doc_type: interactions
status: current
last_updated: 2026-06-05
---

# Interactions & Navigation - Messages

Panel entry points are selected by `ViewSpec.messages(MessagesSpec...)` and
sidebar flow state. The messages feature resolves approved message specs into
typed evidence scopes; app-level panel stack ownership remains in essentials.

## Primary Entry Points

- Global messages.
- Contact messages, optionally handle-filtered.
- Conversation messages.
- Handle / unfamiliar-source messages.
- Recovered/orphan message evidence.
- Search result context surfaces.
- Handle Lens surfaces.

## User Flows

1. **Select message scope**
   - Sidebar or ViewSpec produces a typed `MessageEvidenceScope`.
   - Center panel renders shared header + evidence timeline.
2. **Build skeleton**
   - Evidence spine builds full lightweight skeleton for timeline-like scopes.
3. **Hydrate visible evidence**
   - Visible rows hydrate text, sender display, attachments, URL previews, and
     overlay state.
4. **Search within scope**
   - Header search controls update evidence search state.
   - Matching is computed against the selected logical scope, not just visible
     rows.
5. **Jump by heatmap/month**
   - Heatmap selects a month.
   - Evidence view jumps to the skeleton index for that month.
6. **Receive new messages**
   - Graph update invalidates evidence readers.
   - If the user is not at the bottom, preserve reading position and show the
     pending-new-message affordance.

## Cross-Feature Touchpoints

- Contacts feature selects contact scopes and handle filters.
- Conversation/sidebar signature surfaces select conversation scopes.
- Search returns graph evidence scopes.
- Attachments feature resolves archive/media evidence.
- Display identity resolver supplies user-facing contact/participant labels.

## Navigation Guardrails

- Always rely on ViewSpec/sidebar state for center-panel message selection.
- Features do not imperatively clear or push center-panel content.
- Widgets render typed evidence data; they do not query or convert identities.
- Source-specific scopes are allowed; source-specific message renderers are not.

## Outstanding Decisions

- Whether additional semantic overlays belong in headers, badges, or search
  facets.
- When to retire the remaining diagnostic/reference conversation browser.
