---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: interactions
status: draft
last_updated: 2025-11-06
---

# Interactions & Navigation — Chat Handles

> Current conformance note (2026-04-21): manual linking is no longer a TBD standalone panel. Current user-facing handle review uses handles sidebar cassettes and `MessagesSpec.handleLens(...)`; settings/manual-linking surfaces live under `lib/features/handles/application/settings_cassette_spec/`.

## Primary Entry Points
- Handle review via handles sidebar cassettes.
- Handle Lens via `MessagesSpec.handleLens(handleId: ...)`.
- Manual linking/settings cassettes under `handles/application/settings_cassette_spec/`.
- Import diagnostics tooling when handle normalization fails.

## User Flows
1. **View unmatched handles** → surfaces orphaned handles requiring contact association.
2. **Link handle to participant** → writes overlay override, triggers index rebuild.
3. **Unlink handle** → removes override, re-projects participant roster.

## Cross-Feature Touchpoints
- Chats feature subscribes to roster updates after manual link.
- Messages feature resolves display name after overrides.
- Search feature must refresh handle indexes after changes.

## Navigation Guardrails
- All entry points should be described via dedicated ViewSpecs once the UI is formalized.
- Avoid hard-coded navigation; use `panelsViewStateProvider` + feature coordinators.

## Outstanding Decisions
- Finalize ViewSpec naming (e.g., `ViewSpec.manualHandleLinking`).
- Determine how to surface handle diagnostics in search/global datasets.
