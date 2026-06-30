---
tier: feature
scope: testing-monitoring
owner: agent-per-project
last_reviewed: 2026-06-14
links:
	- ./STATE_AND_PROVIDER_INVENTORY.md
	- ./WORK_LOG.md
tests: []
feature: search
doc_type: testing-monitoring
status: current
last_updated: 2026-06-14
---

# Testing & Monitoring — Search

> Current conformance note (2026-06-06): current search is graph-backed through `lib/essentials/search` and the Message Evidence Spine. Tests should target graph `message_ss_id` scopes, full-scope skeleton/search behavior, result-context navigation, and overlay saved/tag search semantics. Do not reintroduce retired `working.db` FTS/index fallback as ordinary search behavior.

## Automated Coverage Targets
- Unit: query parser, ranking heuristics, filter logic.
- Integration: source-scoped graph build/data-version update to queryable graph evidence state.
- Widget: search UI interactions, keyboard shortcuts, result navigation.

## Test Data Requirements
- Curated corpus with known relevance expectations.
- Edge cases: emoji, diacritics, multi-language text, very long messages.
- Datasets representing both sparse and dense chat histories.

## Monitoring & Telemetry
- Query latency metrics with alerting on P95/P99 regressions.
- Graph freshness timestamps, graph build success/failure counts, and search latency against graph scopes.
- Error logging for failed navigation conversions.

## Manual Verification Checklist
- Queries return expected top results for curated corpus.
- Filters (date range, participant) produce consistent subsets.
- Navigation to chat/message from search maintains user context.

## Open Stewardship Items
- Establish baseline performance targets for macOS release hardware.
- Integrate telemetry dashboards once indexing backend is chosen.
