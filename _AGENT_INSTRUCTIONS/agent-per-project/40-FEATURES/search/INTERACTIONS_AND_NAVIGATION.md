---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./CHARTER.md
	- ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
feature: search
doc_type: interactions
status: current
last_updated: 2026-06-14
---

# Interactions & Navigation — Search

> Current conformance note (2026-06-14): search is graph-backed through
> `lib/essentials/search` and rendered through the Message Evidence Spine.
> Source-specific search controls may choose scope, but result evidence must
> remain graph `message_ss_id` evidence, not legacy `working.db` ids.

## Primary Entry Points
- Message evidence header search within the selected logical scope.
- Search All Messages / global graph message search.
- Bounded search-result context views that preserve the selected result while
  showing surrounding evidence.

## User Flows
1. **Enter Query** — header/search surfaces update typed search state for the
   selected evidence scope.
2. **Resolve Matches** — graph search returns `message_ss_id` matches for the
   full selected logical scope.
3. **Navigate Result** — result-context routes produce a bounded
   `MessageEvidenceScope`; the center panel renders through shared evidence
   widgets.
4. **Refine Scope** — participant, handle, conversation, saved, or tag filters
   create different graph scopes without creating source-specific renderers.

## Cross-Feature Touchpoints
- Messages: shared evidence header, skeleton, hydration, term highlighting,
  and result-context navigation.
- Conversations/chats: conversation-scoped search and result context.
- Contacts/handles: contact and handle-scoped search through canonical graph
  identity plus display identity resolution.
- Overlay: saved/tag/user-intent search is merged through named graph
  repository boundaries.

## Navigation Guardrails
- Search state belongs in scope/resolver layers; header widgets render controls
  and do not perform search semantics.
- Pagination is not timeline navigation. Timeline-like search scopes preserve
  the full skeleton while hydrating visible rows.
- Do not reintroduce `working.db` FTS/index fallback as ordinary search
  behavior.

## Outstanding Decisions
- Whether a future dedicated search workspace is needed beyond embedded
  evidence-scope search.
- Whether graph-native acceleration is needed behind `GraphSearchRepository`
  after ordinary search latency is measured.
