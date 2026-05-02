Historical Archive Import – V3 Seed

Status

DO NOT IMPLEMENT.

This document defines the conceptual foundation for the next iteration.

⸻

Core Problem

We need to merge historical message archives into the system while preserving:

- correctness
- deduplication
- source traceability
- stable projection

⸻

Unresolved Questions (Must Be Answered First)

1. Message Identity

Is a message:

- uniquely identified by GUID across all sources?
- or can the same GUID exist in multiple sources independently?

⸻

2. Provenance Model

Choose ONE:

Option A: Canonical Row Model

- one row per GUID
- sources overwrite/merge into same row

Option B: Observation Model (preferred direction)

- multiple source observations per message
- canonical message derived from observations

⸻

3. Deduplication Rules

- what defines “same message”?
- GUID only?
- fallback heuristics?

⸻

4. Deletion Semantics

- can a single archive be removed independently?
- what happens to shared messages?

⸻

Constraints

- No change to migration orchestrator unless strictly necessary
- Archive import must not break live pipeline
- Import must be interruptible and restartable
- UI must never see partial projection

⸻

V3 Approach (High-Level)

1. Register archive source
2. Preflight analysis (no writes)
3. Import into ledger (provenance-safe)
4. Run standard migration
5. UI sees results only after completion

⸻

Next Step

The agent will later produce:

- PROVENANCE_MODEL.md
- DEDUPLICATION_RULES.md

No implementation until those are complete.
