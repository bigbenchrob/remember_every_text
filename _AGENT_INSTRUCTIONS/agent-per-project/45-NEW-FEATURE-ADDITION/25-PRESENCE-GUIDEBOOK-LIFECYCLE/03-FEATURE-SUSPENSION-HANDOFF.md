---
tier: project
scope: presence-guidebook-lifecycle
owner: agent-per-project
last_reviewed: 2026-08-16
source_of_truth: handoff
links:
  - 00-START-HERE.md
  - 01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
  - 02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md
tests: []
---

# Feature 25 Suspension Handoff

> **SUSPENDED — architecture retained; implementation to resume later.**

Feature 25 is parked, not abandoned or superseded. Its accepted architecture,
completed catalog slice, implementation history, and branch remain the durable
checkpoint for future resumption.

## Current Status

Feature 25 has established and accepted that:

- `presence.db` is a replaceable Presence guidebook plus generation-local
  execution state;
- runs, checkpoints, completion, and trace may remain durable within one
  guidebook generation;
- a future guidebook-generation replacement may discard the complete Presence
  database and begin fresh;
- durable human intent belongs to its owning domain rather than being
  preserved merely as Presence geometry;
- runtime `presence.db` should become the sole installed guidebook authority;
  and
- Onboarding and other consumers should provide domain Agents and capabilities
  rather than owning Schedule, Trip, and Step geometry.

## Work Completed

The package entry point and
[architecture audit](01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md)
record the lifecycle decision and conclude that all current `presence.db`
content is safely replaceable at a guidebook-generation boundary.

The first recommended implementation slice is also complete. The
[catalog contract implementation](02-PRESENCE-GUIDEBOOK-CATALOG-CONTRACT-IMPLEMENTATION.md)
provides a deterministic, side-effect-free current guidebook catalog and pure
structural validator. Authored Schedule 6 geometry now originates in generic
Presence, while Onboarding retains executable specialist capability bindings.
Current runtime behavior remains unchanged through the transitional
materialization and `installOrExtendDefinition()` path.

## Intended Work When Resumed

Resume from the completed catalog boundary and accepted architecture. The next
problem is the actual guidebook-generation lifecycle: fresh installation,
installed-generation identity, atomic family-aware replacement, and eventual
removal of competing runtime definition reconciliation. Representation and
serialization remain intentionally undecided.

Do not resume by implementing the old tactical Step 6302 reconciliation or
migration idea. The Step 6302 conflict was evidence that motivated the
replaceable-guidebook lifecycle; it is not the lifecycle itself.

## Reason For Suspension

Feature 25 is temporarily suspended because a higher-priority production-data
recovery task has become urgent:

> Safely recover historical Messages records and preserved archived image
> attachments from a saved March 2026 MessageLens Application Support data
> folder into the current MessageLens production data folder.

The recovery work begins independently from clean `main`. Feature 25 remains
parked on `Ftr.gdbk-lifecycle`, unmerged, and should later resume from this
branch and handoff.
