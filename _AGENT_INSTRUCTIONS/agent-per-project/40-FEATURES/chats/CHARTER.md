---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2026-06-05
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chats
doc_type: charter
status: current
last_updated: 2026-06-05
---

# Feature Charter - Chats

> Current conformance note (2026-06-05): MessageLens is now
> conversation-frontmost, but conversation truth lives in
> `essentials/conversation_graph`, not in a legacy `working.db` chat aggregate.
> The chats feature may provide diagnostic/reference browsing and lightweight
> graph adapters, but ordinary conversation navigation and message evidence
> should remain graph-backed and evidence-spine based.

## Mission
- Present conversations as first-class graph entities derived from canonical
  chat/message/handle topology.
- Preserve a coherent route from conversation selection to shared message
  evidence rendering.
- Avoid rebuilding legacy contact-first or GUID-first conversation identity.

## Primary Outcomes
- Accurate conversation summaries: participants, message count, attachment
  count, date range, and latest evidence preview.
- Stable source-scoped conversation identity across sidebar, contact-derived
  lists, search contexts, and favourites.
- Conversation signatures that help users recognize communication structure
  without moving navigation controls into the center panel.

## Success Metrics
- Conversation lists remain graph-backed and responsive after live updates.
- No ordinary conversation read path depends on legacy `working.db`.
- Selected conversations render through the shared Message Evidence Spine.
- Conversation favourites are overlay-owned and appear consistently wherever
  the conversation appears.

## Non-Goals
- Message rendering (covered by messages feature).
- Navigation shell layout (tracked separately).
- Contact identity reconstruction beyond display-label resolution.
- Reintroducing legacy `Chat` aggregates or GUID-based conversation identity.

## Stakeholders & Dependencies
- Depends on source-scoped graph import/projection, handle canonicalization,
  display identity resolution, and overlay favourites.
- Feeds the conversations sidebar, contact-by-conversation lists, search
  contexts, and message evidence headers.

## Open Questions
- Whether the retained diagnostic center-panel conversation browser should be
  fully retired once sidebar signatures cover the remaining inspection use case.
- Which future semantic overlays belong on conversation signatures versus in
  evidence/search result surfaces.
