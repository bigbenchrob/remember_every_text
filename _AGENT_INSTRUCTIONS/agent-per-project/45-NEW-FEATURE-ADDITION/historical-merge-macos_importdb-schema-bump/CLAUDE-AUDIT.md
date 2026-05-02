CLAUDE AUDIT PROMPT (COPYABLE)

You are performing an architecture and implementation audit of a partially completed feature in a macOS Flutter application called MessageLens.

This is a read-only audit task.
You must NOT propose or generate code changes, diffs, or refactors.
You must NOT suggest “try this code” or “replace with this implementation.”

Your role is to:

- analyze
- diagnose
- identify risks
- evaluate architecture decisions
- suggest improvements at the design and system level only

⸻

CONTEXT

MessageLens processes iMessage data through a deterministic pipeline:

source databases (chat.db or historical archive)
→ canonical ledger database (macos_import.db)
→ migration orchestrator
→ projected working database (working.db)
→ UI surfaces (timeline, search, heatmap)

A new feature was implemented:

Historical Archive Import

Goal:
Allow users to import older Messages folders and merge them into the canonical ledger, then rebuild working.db so the data appears seamlessly alongside current messages.

⸻

CURRENT STATE (IMPORTANT)

The feature has gone through multiple iterations and is now in a “functionally working but architecturally fragile” state.

Recent improvements include:

- Canonical ledger is now the only ingestion point (no parallel archive DB allowed)
- Provenance model introduced:
  - ledger_sources
  - import_batches
  - source_id, batch_id on major tables
- Surrogate IDs replaced source ROWIDs
- GUID-based deduplication occurs at ledger insertion boundary
- Archive import now:
  - writes to ledger
  - triggers full canonical migration
  - rebuilds working.db
- Timestamp normalization:
  - ledger uses INTEGER epoch seconds
  - working.db still uses TEXT
- UI workflow introduced:
  - Step 1: choose folder
  - Step 2: preflight (GUID overlap, counts)
  - Step 3: import (modal dialog)

⸻

KNOWN PROBLEMS / PAIN POINTS

These are observed issues you must factor into your analysis:

1. Migration opacity

- Long-running steps (e.g. “Build working messages”) show:
  - indeterminate progress bars
  - no row counts
  - no real progress visibility
- Users cannot distinguish:
  - slow vs hung vs broken

2. UI confusion

- Too many overlapping status surfaces previously
- Now reduced, but modal still:
  - lacks clear progress semantics
  - uses vague step descriptions
- Terminology like “dry run” and “already projected” is confusing

3. Data ambiguity (historical issue)

- Previously had:
  - imported archive rows without provenance
- Now fixed architecturally, but edge-case UX still confusing

4. Cleanup / deletion gaps

- Need ability to:
  - delete failed imports
  - delete per-source imports
- Current controls exist but are unclear / incomplete

5. Performance perception vs reality

- Some steps are actually deterministic and countable
- But implemented in a way that prevents progress reporting

⸻

YOUR TASK

Provide a structured audit with the following sections:

⸻

1. ARCHITECTURAL ASSESSMENT

Evaluate:

- Canonical ledger approach (single ingestion pipeline)
- Provenance model (sources, batches, row-level metadata)
- Separation between:
  - ingestion (ledger)
  - projection (working.db)
- Idempotency and deduplication strategy

Answer:

- What is strong / correct / future-proof
- What is fragile or risky
- Where hidden coupling likely exists

⸻

2. PIPELINE ANALYSIS

Analyze the full pipeline:

source → ledger → migration → working.db

Focus on:

- determinism
- atomicity
- visibility guarantees
- failure handling

Identify:

- weakest stage
- most likely failure modes
- areas where invariants could silently break

⸻

3. MIGRATION DESIGN CRITIQUE

Specifically evaluate:

- “Build working messages” step
- index rebuild steps
- full rebuild strategy vs incremental

Answer:

- Should migration be:
  - chunked?
  - streaming?
  - fully batched?
- Where progress reporting should exist
- Where current design hides important signals

⸻

4. UI / WORKFLOW MODEL CRITIQUE

Evaluate the current 3-step model:

1. Choose folder
2. Review preflight
3. Begin import (modal execution)

Focus on:

- clarity
- determinism
- user mental model

Identify:

- what is still confusing
- what terminology is misleading
- what should be removed vs clarified

⸻

5. PROGRESS & OBSERVABILITY

This is critical.

Assess:

- current progress reporting approach

Answer:

- Which steps are inherently measurable
- Which steps require estimation
- Where progress must be:
  - exact (X / Y)
  - phase-based
  - time-based fallback

Explain:

- why indeterminate progress is harmful here
- what a correct observability model would look like (conceptually, not code)

⸻

6. DATA LIFECYCLE & CLEANUP

Evaluate:

- ability to:
  - re-import
  - delete by source
  - recover from failed imports

Answer:

- what guarantees are currently strong
- what is missing
- what could become dangerous over time

⸻

7. TOP 5 RISKS

List the five most important risks in the current system.

For each:

- describe the risk
- explain why it matters
- describe how it would manifest in real usage

⸻

8. HIGH-LEVEL IMPROVEMENT PLAN

Provide a prioritized, architecture-level plan for improvement.

Constraints:

- no code
- no refactors described in code terms
- no “rewrite everything”

Focus on:

- sequencing
- stabilization
- observability
- user trust

⸻

STYLE REQUIREMENTS

- Be precise, not verbose
- Avoid generic advice
- Tie every point to this system
- Do not repeat the context back unnecessarily
- Do not suggest code

⸻

FINAL NOTE

This system is already functional.

Your goal is not to redesign it from scratch, but to:

- identify where it is brittle
- identify where it is strong
- suggest how to make it robust, understandable, and trustworthy
