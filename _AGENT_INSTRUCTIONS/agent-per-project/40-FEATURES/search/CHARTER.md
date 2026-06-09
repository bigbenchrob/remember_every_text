---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2026-06-06
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: search
doc_type: charter
status: current
last_updated: 2026-06-06
---

# Feature Charter — Search

> Current conformance note (2026-06-06): search services live under `lib/essentials/search`, not `lib/features/search`. Ordinary search is graph-backed through `SearchService` and `GraphSearchRepository`, returning graph `message_ss_id` evidence scopes.

## Mission
- Deliver unified search across conversations, messages, contacts, handles, saved/tag overlays, and recovered evidence with responsive graph-backed queries.
- Provide extensible query capabilities (text, participants, dates, attachments) while respecting aggregate boundaries.

## Primary Outcomes
- Graph-backed result scopes kept up-to-date with source-scoped graph builds and overlay intent.
- Search UI that supports fast filtering, result previews, and navigation into underlying features.
- Clear APIs for programmatic search (e.g., future automation or integrations).

## Success Metrics
- Query latency P95 under agreed threshold.
- Graph freshness (time between source change and searchable evidence update) within SLA.
- Relevance scores validated via curated test corpus.

## Non-Goals
- Analytics dashboards (belongs elsewhere).
- Navigation architecture beyond search entry points.

## Stakeholders & Dependencies
- Consumes conversation graph message, contact, handle, topology, and overlay projections.
- Publishes results to navigation system and feature panels.

## Open Questions
- Whether future performance work should add graph-native FTS/index acceleration behind the current graph search repository contract.
- How do we prioritize ranking signals (recency vs. message importance)?
