# PIPELINE DEBUGGING PROTOCOL

## Purpose

This document defines the required step-by-step process for diagnosing and fixing pipeline issues.

Agents MUST follow this protocol.

Do not skip steps.
Do not jump directly to fixes.
Do not modify data before understanding the failure.

---

## 1. Guiding Principles

- The system is invariant-driven
- Most bugs are invariant violations
- Symptoms are not root causes
- Data is evidence, not something to “fix”

---

## 2. High-Level Flow

1. Observe the symptom
2. Classify the failure mode
3. Identify violated invariant
4. Locate the responsible layer
5. Gather evidence (read-only)
6. Form hypothesis
7. Confirm hypothesis
8. Implement minimal fix
9. Add regression test

---

## 3. Step 1 — Observe the Symptom

Examples:

- migration failed
- UI missing data
- duplicate data visible
- system appears idle
- repeated failure loop

Record:

- exact error message
- logs
- timestamps
- triggering action (startup, poll, import)

---

## 4. Step 2 — Classify Failure Mode

Use:

PIPELINE-FAILURE-MODES.md

Select one or more:

- ledger incompleteness
- projection inconsistency (stale / missing / duplicate)
- cursor false no-op
- trigger/orchestration failure
- authority boundary violation
- silent tolerance failure
- recovery gap

Do NOT proceed without classification.

---

## 5. Step 3 — Identify Violated Invariant

Use:

PIPELINE-INVARIANTS-CORE.md

Examples:

- projection must match source set
- working.db is derived only
- migration is sole writer
- cursor is not sufficient signal

State explicitly:

> “Invariant violated: …”

---

## 6. Step 4 — Locate the Layer

Determine where the problem originates:

- source (chat.db)
- ledger (macos_import.db)
- migration
- projection (working.db)
- orchestration / monitor
- UI

Do not guess—verify with evidence.

---

## 7. Step 5 — Gather Evidence (READ-ONLY)

This is the most important step.

### 7.1 Database Inspection

Use SQL only. No writes.

Typical checks:

- row counts (working vs source)
- MAX(rowid) vs imported cursor
- anti-joins to find orphans
- duplicate detection queries
- null/invalid identity checks

### 7.2 Logs

Look for:

- startup decisions
- monitor activity
- migration start/stop
- validator failures

### 7.3 Code Path Tracing

Identify:

- where decisions are made
- where migration runs
- where validation occurs

---

## 8. Step 6 — Form Hypothesis

Example:

- “working.db contains stale rows not present in ledger”
- “startup incorrectly concluded no work due to cursor equality”
- “migration inserts but does not delete”

Hypothesis MUST:

- explain all observed symptoms
- map to a known failure mode

---

## 9. Step 7 — Confirm Hypothesis

Confirm using additional read-only checks:

- targeted SQL queries
- reproducing condition
- verifying mismatch

Do not proceed to fix until confirmed.

---

## 10. Step 8 — Implement Fix

Rules:

- fix logic, not data
- preserve invariants
- keep change minimal and localized

Typical fix locations:

- migrator logic
- trigger/monitor logic
- validator logic (strengthening only)

DO NOT:

- delete data as a “solution”
- weaken validation
- add fallback paths

---

## 11. Step 9 — Add Regression Test

Every fix MUST include a test that:

- reproduces the failure condition
- verifies correct behavior after fix

Examples:

- stale row removed during migration
- equal cursor + count mismatch triggers import
- duplicates prevented

---

## 12. Emergency Data Intervention (Rare)

Allowed only when:

- user is blocked
- root cause is already understood
- fix is being implemented separately

Examples:

- deleting a single stale projection row

Requirements:

- must not touch macos_import.db
- must be documented
- must not replace proper fix

---

## 13. Anti-Patterns

Agents MUST NOT:

- jump to fixes without classification
- modify DB before understanding issue
- weaken validators
- introduce new data paths
- rely on “seems to work” behavior

---

## 14. Example (Real Case)

Symptom:

- ATTACHMENTS_ROW_MISMATCH (+1 row)

Classification:

- projection inconsistency (stale row)

Invariant violated:

- projection must match authoritative source set

Evidence:

- working.attachments contained row not present in import ledger

Root cause:

- incremental migration did not delete stale rows

Fix:

- add stale-row cleanup to migrator

---

## 15. Key Insight

Debugging is not:

> “fix the bug”

It is:

> “identify the violated invariant and restore it”

---

END
