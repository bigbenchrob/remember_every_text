# PIPELINE FAILURE MODES

## Purpose

This document defines known classes of failure in the MessageLens data pipeline.

Each failure mode represents a violation (or potential violation) of pipeline invariants.

Agents MUST use this document to:

- classify observed issues
- avoid misdiagnosis
- select correct remediation strategies

---

## 1. Failure Mode Classification

All pipeline failures fall into one or more of:

- ledger incompleteness
- projection inconsistency
- trigger/orchestration failure
- identity/deduplication failure
- authority boundary violation

---

## 2. Ledger Incompleteness

### Definition

macos_import.db does not fully reflect source data.

### Example (Observed)

- restored ledger had:
  - MAX(source_rowid) equal to chat.db
  - BUT missing ~10k messages

### Root Cause Pattern

- reliance on cursor equality (MAX ROWID)
- lack of secondary completeness signal

### Detection

- live importable count > imported count
- gaps in message coverage

### Correct Handling

- trigger reimport (forceFullReimport)
- DO NOT trust cursor alone

---

## 3. Projection Inconsistency — Stale Rows

### Definition

working.db contains rows that are not present in authoritative ledger source set.

### Example (Observed)

- working.attachments contained:
  - import_attachment_id = 40395
- no corresponding row existed in macos_import.db

### Root Cause Pattern

- projection built from older ledger snapshot
- ledger later changed
- incremental migration did not remove stale rows

### Detection

- row-count mismatch between working and source set
- anti-join reveals orphan rows

### Correct Handling

- migration MUST delete stale rows
- validator MUST remain strict

---

## 4. Projection Inconsistency — Missing Rows

### Definition

working.db is missing rows that exist in ledger.

### Root Cause Pattern

- incomplete migration
- migration aborted early
- projection not rebuilt after ledger update

### Detection

- working count < expected count
- UI missing data

### Correct Handling

- rerun migration
- ensure migration is idempotent

---

## 5. Projection Inconsistency — Duplicate Rows

### Definition

working.db contains multiple rows representing same logical entity.

### Root Cause Pattern

- deduplication failure
- incorrect join logic
- missing uniqueness constraint

### Detection

- COUNT(\*) > COUNT(DISTINCT identity)
- duplicate (message_guid, import_attachment_id) pairs

### Correct Handling

- enforce uniqueness in migration
- remove duplicates
- add regression tests

---

## 6. Cursor False No-Op

### Definition

system incorrectly concludes “no work needed” based on cursor equality.

### Example (Observed)

- chat.db MAX ROWID == imported MAX(source_rowid)
- BUT ledger missing large number of rows

### Root Cause Pattern

- cursor-only decision logic

### Detection

- count mismatch despite equal cursor

### Correct Handling

- add secondary signal (count comparison)
- trigger recovery import

---

## 7. Trigger / Orchestration Failure

### Definition

correct work exists but is never scheduled or executed.

### Root Cause Pattern

- monitor not initialized
- timer not started
- gating logic incorrectly blocks execution
- silent failure in scheduling path

### Detection

- no logs of migration attempt
- expected triggers do not fire

### Correct Handling

- instrument startup and scheduler paths
- ensure visibility of decisions

---

## 8. Authority Boundary Violation

### Definition

code bypasses canonical data flow.

### Examples

- UI reads from chat.db
- feature writes directly to working.db
- duplicate ingestion paths

### Root Cause Pattern

- convenience shortcuts
- agent-generated “temporary fixes”

### Detection

- unexpected data sources
- inconsistent data across layers

### Correct Handling

- remove violation
- restore pipeline flow

---

## 9. Silent Tolerance Failure

### Definition

system suppresses or ignores inconsistency instead of surfacing it.

### Root Cause Pattern

- weakened validator
- catch-and-ignore exceptions
- fallback logic

### Detection

- inconsistent data without errors
- UI “mostly works” but is wrong

### Correct Handling

- reintroduce strict validation
- fail loudly and early

---

## 10. Projection State Ambiguity

### Definition

projection_state does not accurately represent projection completeness.

### Example (Observed)

- projection_state fields all NULL
- UI still allowed to proceed

### Root Cause Pattern

- projection_state not authoritative
- readiness determined by other signals

### Detection

- mismatch between projection_state and actual DB state

### Correct Handling

- treat projection_state as advisory unless strengthened
- rely on actual data validation

---

## 11. Recovery Gap (No New Data, Still Inconsistent)

### Definition

projection is inconsistent but no new source data exists to trigger migration.

### Example (Observed)

- stale attachment row remained
- incremental migration did not run

### Root Cause Pattern

- migration only triggered by new data
- no reconciliation path

### Detection

- validator would fail if run
- system appears idle

### Correct Handling

- introduce consistency-triggered migration (future)
- OR ensure startup reconciliation

---

## 12. Debugging Protocol (Agent Guidance)

When investigating a pipeline issue:

1. Classify failure mode(s)
2. Identify violated invariant
3. Locate layer:
   - source
   - ledger
   - migration
   - projection
   - UI
4. DO NOT patch data first
5. Fix:
   - migration logic
   - trigger logic
   - validation

---

## 13. Key Insight

Most failures are not random bugs.

They are violations of:

- authority boundaries
- projection consistency
- trigger correctness

Correct diagnosis depends on identifying the class, not the symptom.

---

END
