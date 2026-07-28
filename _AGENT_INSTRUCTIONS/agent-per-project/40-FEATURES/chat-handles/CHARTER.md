---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2026-07-27
links:
	- ../chat-handles/DOMAIN_AND_DATA_MAP.md
tests: []
feature: chat-handles
doc_type: charter
status: current
last_updated: 2026-07-20
---

# Feature Charter - Chat Handles

> Current conformance note (2026-06-05): handle identity is source-scoped and graph-backed. Handles are traversal endpoints and metadata; known contact display identity wins for user-facing labels except in explicit handle-scope controls and unfamiliar-source review.

## Mission
- Capture how source handle identities are imported, canonicalized, aliased, and associated with contacts/conversations.
- Document inbound data sources (macOS Messages handles, manual overrides) and the invariants we must preserve.

## Primary Outcomes
- Deterministic source-scoped mapping from Apple handle rows to graph handle identities.
- Canonical handle aliases collapse phone/email/service variants without losing source facts.
- Manual handle/contact links remain overlay-owned user intent.
- Display identity surfaces use the shared resolver so raw handles do not win over known contacts.

## Success Metrics
- Handle normalization and aliasing errors detected by graph health diagnostics.
- Manual override latency between overlay write and graph read-model refresh.
- Regression tests covering canonicalization edge cases.

## Non-Goals
- Contact display identity resolution (owned by contacts/display identity).
- Navigation or UI presentation of handles (covered elsewhere).

## Stakeholders & Dependencies
- Depends on source-scoped import/projection for source data fidelity.
- Provides graph endpoints consumed by conversations, contacts, message evidence, and search features.

## Cross-Feature Presentation Boundary

Handles owns source identity projection and the meaning of source-review
workflows. Its public source-review facade may coordinate Contacts-owned Contact
creation and linking primitives, but callers do not choose Handles persistence,
normalization, workflow ordering, or invalidation semantics.

Messages owns the complete `MessagesSpec.handleLens` ViewSpec presentation and
consumes the Handles-owned per-source payload and workflow facade. Cross-feature
presentation ownership does not permit the rendering feature to reimplement the
collaborating feature's business semantics.

## Open Questions
- How do we stage alternative normalization strategies (e.g., phone formatting) without breaking projections?
- What telemetry do we need to catch drift between import ledger and working projection?
