---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-07-20
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: interactions
status: current
last_updated: 2026-07-20
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
- Search/evidence scopes observe graph identity plus overlay intent rather than rebuilding retired working indexes.

## Navigation Guardrails
- Entry points should flow through current ViewSpec/sidebar spec coordinators.
- Avoid hard-coded navigation; use sidebar/panel spec state and feature coordinators.

## Unfamiliar-Source Investigation Compatibility

Unfamiliar-source evidence is subordinate to the investigation episode that
created it. Handles owns an opaque investigation identity; sidebar flow stores
the current identity and the identity from which a handle selection originated.

Changing any investigation-defining control begins a new episode:

- Identify / Numeric IDs;
- Phone / Email / Business;
- Active / Dismissed.

A successful source dismissal also begins a new episode when the dismissed
source owns the effective center evidence. Handles first persists the
overlay-owned disposition. The Messages-owned handle-lens interaction then
advances investigation provenance; it does not issue an imperative center-panel
clear. Failed dismissal leaves the current investigation and evidence intact.

The selected handle may remain stored, but its center presentation is effective
only while its originating identity equals the current identity. The cassette
widgets do not clear panels, and Messages does not interpret Handles controls.
The effective center projection becomes absent by compatibility, applying the
Mechanical Impossibility Principle to sidebar/center flow state.

Disposition changes update the already-loaded active or dismissed projection
at source granularity. They must not invalidate the visible database-wide
aggregation and replace the entire cassette list with a loading state. The
repository remains the restart authority, while targeted projection updates
keep a completed one-source action visually continuous.

## Outstanding Decisions
- Determine how to surface handle diagnostics in search/global datasets.
