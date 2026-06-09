---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-06-06
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
tests: []
feature: search
doc_type: state-provider-inventory
status: current
last_updated: 2026-06-06
---

# State & Provider Inventory — Search

> Current conformance note (2026-06-06): current public providers are `searchServiceProvider` and `graphSearchRepositoryProvider` from `lib/essentials/search/feature_level_providers.dart`. Planned FTS/index providers are retired as ordinary app architecture unless reintroduced behind the graph repository contract.

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `searchServiceProvider` | `@riverpod` service | graph search scope + query | Facade used by message evidence/search surfaces. | Message Evidence Spine, search result context surfaces. |
| `graphSearchRepositoryProvider` | `@riverpod` repository | graph DB + overlay DB | Executes graph-backed text, saved, and tag searches by `message_ss_id`. | `SearchService`. |

## State Objects & Caches
- `GraphMessageSearchScope`: global, conversation, handle, or contact-canonical-handle scope.
- Graph search result ids keyed by `message_ss_id`.
- Overlay saved/tag matches merged at read time.

## Invalidations & Triggers
- Source-scoped graph builds and graph/message data-version bumps refresh searchable evidence.
- Overlay saved/tag/manual-link changes invalidate relevant evidence/search readers.
- Query state changes recompute graph repository searches for the selected logical scope.

## TODO
- Do not add new search providers under `features/search/application` without first deciding to move search out of `essentials/search`.
- Investigate graph-native acceleration only behind `GraphSearchRepository`, not as a parallel search spine.
