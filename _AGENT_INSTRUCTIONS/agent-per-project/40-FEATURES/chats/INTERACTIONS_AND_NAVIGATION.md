---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./CHARTER.md
	- ../messages/INTERACTIONS_AND_NAVIGATION.md
tests: []
feature: chats
doc_type: interactions
status: current
last_updated: 2026-06-14
---

# Interactions & Navigation — Chats

> Current conformance note (2026-06-14): user-facing chat navigation is now
> conversation-first and graph-backed. The feature should not reintroduce a
> separate legacy chat-list panel or a chat-specific message renderer.

## Primary Entry Points
- Conversations sidebar signatures built from `working_ss.db` topology.
- Contact-derived conversation lists that reuse the same conversation signature
  card and route into the shared message evidence surface.
- Search/result-context routes that select graph message evidence scopes rather
  than legacy chat/message ids.

## User Flows
1. **Launch → Conversations** — restores the persisted top-menu/sidebar state
   and shows graph conversation signatures.
2. **Select Conversation** — updates sidebar flow/selected conversation state;
   the center panel derives a `MessageEvidenceScope` for the conversation.
3. **Toggle Favourite** — writes global conversation favourite intent to the
   overlay database; graph projection remains source-derived.
4. **Inspect Messages** — renders through the shared Message Evidence Spine,
   including full-scope skeleton navigation and visible-row hydration.

## Cross-Feature Touchpoints
- Messages owns evidence scopes, headers, search-within-scope, and row
  rendering.
- Contacts can select conversations involving a contact, but still routes into
  the same conversation signature and evidence rendering contracts.
- Search links to graph evidence scopes and bounded result contexts.
- Chat handles provide participant topology and sender identity through graph
  readers and the display identity resolver.

## Navigation Guardrails
- Sidebar/context state owns selection; widgets do not push or clear center
  content imperatively.
- Conversation signature facts are computed outside widgets; widgets render
  typed data plus callbacks.
- Message evidence presentation is shared. Do not create chat-specific message
  rows, headers, attachment renderers, or pagination paths.

## Outstanding Decisions
- Whether the diagnostic conversation browser remains useful after the sidebar
  signature flow fully covers inspection needs.
- Future multi-window/split-view policy for conversation selection.
