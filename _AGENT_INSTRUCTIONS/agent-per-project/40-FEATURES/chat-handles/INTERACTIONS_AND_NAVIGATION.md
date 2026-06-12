---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-06-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: interactions
status: current
last_updated: 2026-06-06
---

# Interactions & Navigation — Chat Handles

> Current conformance note (2026-06-06): manual linking is no longer a TBD standalone panel. Current user-facing handle review uses handles sidebar cassettes and `MessagesSpec.handleLens(...)`. Manual link actions write overlay intent only; graph/import projection is not repaired or rewritten by widgets.

## Primary Entry Points
- Handle review via handles sidebar cassettes.
- Handle Lens via `MessagesSpec.handleLens(handleId: ...)`.
- Manual linking operations through overlay-owned handle/contact services.
- Import diagnostics tooling when handle normalization fails.

## User Flows
1. **View unmatched handles** → surfaces orphaned handles requiring contact association.
2. **Link handle to contact** → writes overlay override, then invalidates display identity / handle review / message evidence readers.
3. **Unlink handle** → removes overlay override, then invalidates the same read models. It does not re-project graph data.

## Cross-Feature Touchpoints
- Conversation and contact surfaces resolve display identity after overlay changes.
- Messages feature resolves sender/contact labels through the shared display identity resolver.
- Search/evidence scopes observe graph identity plus overlay intent rather than rebuilding retained historical indexes.

## Navigation Guardrails
- Entry points should flow through current ViewSpec/sidebar spec coordinators.
- Avoid hard-coded navigation; use sidebar/panel spec state and feature coordinators.

## Outstanding Decisions
- Determine how to surface handle diagnostics in search/global datasets.
