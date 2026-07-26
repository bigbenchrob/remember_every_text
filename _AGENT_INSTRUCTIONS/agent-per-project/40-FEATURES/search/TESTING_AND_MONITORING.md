---
tier: feature
scope: testing-monitoring
owner: agent-per-project
last_reviewed: 2026-07-18
links:
	- ./STATE_AND_PROVIDER_INVENTORY.md
	- ./WORK_LOG.md
tests: []
feature: search
doc_type: testing-monitoring
status: current
last_updated: 2026-07-18
---

# Testing & Monitoring — Search

> Current conformance note (2026-06-06): current search is graph-backed through `lib/essentials/search` and the Message Evidence Spine. Tests should target graph `message_ss_id` scopes, full-scope skeleton/search behavior, result-context navigation, and overlay saved/tag search semantics. Do not reintroduce retired `working.db` FTS/index fallback as ordinary search behavior.

## Automated Coverage Targets
- Unit: query parser, ranking heuristics, filter logic.
- Integration: source-scoped graph build/data-version update to queryable graph evidence state.
- Widget: search UI interactions, keyboard shortcuts, result navigation.
- Compatibility: stored-versus-effective panel state, query editing, actual
  clear-button behavior, AND/OR changes, month browsing, navigation away/back,
  repeated equal queries, and replacement by another result in the unchanged
  investigation.

Current investigation compatibility coverage is concentrated in:

* `test/features/messages/application/message_evidence/global_messages_investigation_actions_provider_test.dart`
* `test/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget_test.dart`
* `test/features/messages/presentation/widgets/message_evidence/message_evidence_header_test.dart`
* `test/features/messages/presentation/view/global_messages_evidence_view_test.dart`
* `test/essentials/navigation/application/panel_widget_providers_test.dart`

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
- Opening a Conversation excerpt, navigating away, and returning without a
  Search mutation restores the same excerpt.
- Editing or clearing the query, changing AND/OR mode, or browsing a month
  leaves the old excerpt stored but makes it ineffective and closes the end
  sidebar through derived visibility.
- Query A -> B -> A does not revive the excerpt created by the first A.

## Open Stewardship Items
- Establish baseline performance targets for macOS release hardware.
- Integrate telemetry dashboards once indexing backend is chosen.
