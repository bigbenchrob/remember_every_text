---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: search
doc_type: state-provider-inventory
status: draft
last_updated: 2025-11-06
---

# State & Provider Inventory — Search

> Legacy note (2026-04-21): provider names below are planning names, not current code. Current public providers include `searchServiceProvider`, `searchIndexMetricsRepositoryProvider`, `searchIndexersProvider`, `useFtsSearchByDefaultProvider`, and `searchIndexOrchestratorProvider` from `lib/essentials/search/feature_level_providers.dart`.

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `searchQueryStateProvider` | @riverpod notifier | N/A | Holds active query string, filters, sorting state. | Search UI components.
| `searchResultsProvider` | @riverpod stream | query params | Streams paginated search results. | Result list view, quick jump features.
| `searchIndexStatusProvider` | @riverpod future | N/A | Reports index freshness and rebuild progress. | Settings/diagnostics UI.
| `searchRecentQueriesProvider` | @riverpod future | limit | Returns recent user queries. | UI suggestions, analytics.

## State Objects & Caches
- In-memory query cache keyed by normalized query.
- Index rebuild progress state persisted to overlay or local cache.

## Invalidations & Triggers
- Data imports/migrations trigger index update tasks.
- Manual handle or chat title overrides should invalidate associated index segments.
- Query state changes drive result provider recomputation.

## TODO
- Do not add new search providers under `features/search/application` without first deciding to move search out of `essentials/search`.
- Investigate streaming results for long-running queries.
