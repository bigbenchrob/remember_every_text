# PIPELINE INVARIANTS — CORE

## Purpose

This document defines the non-negotiable invariants governing the MessageLens data pipeline.

All agent work MUST respect these invariants.

If a task appears to require violating any invariant, STOP and surface the conflict instead of implementing a workaround.

---

## 1. Canonical Pipeline

source (chat.db / attachments / address book)

→ canonical ledger (macos_import.db)

→ migration orchestrator

→ working projection (working.db)

→ UI

---

## 2. Authority Boundaries

### 2.1 macos_import.db (Canonical Ledger)

- Single ingestion boundary for all external data

- All importers write ONLY to this database

- Contains authoritative representation of:
  - messages

  - attachments

  - joins

  - provenance

Agents MUST NOT:

- bypass this database

- read directly from chat.db for UI purposes

- duplicate ingestion logic elsewhere

---

### 2.2 working.db (Projection)

- Fully derived from macos_import.db

- Disposable at any time

- Written ONLY by migration

Agents MUST NOT:

- write to working.db outside migration

- treat working.db as authoritative

- "patch" working.db to fix logic errors

---

### 2.3 UI Layer

- Reads ONLY from working.db

- Must never read from:
  - chat.db

  - macos_import.db

---

## 3. Migration Rules

- Migration is the ONLY path from ledger → projection

- Migration must be deterministic

- Migration must be safe to re-run

### 3.1 Projection Consistency

After migration:

- projected tables MUST exactly match their authoritative source sets

- no extra rows

- no missing rows

- no silent tolerance

---

## 4. Validators

Validators enforce projection correctness.

Agents MUST:

- preserve validators

- strengthen validators if needed

- NEVER weaken or bypass validators to make code "work"

---

## 5. Attachment Projection Invariant

For working.attachments:

- each row corresponds to a valid (message_guid, import_attachment_id) pair

- that pair MUST exist in the authoritative import join set

Migration MUST:

- insert missing rows

- remove duplicate rows

- remove stale rows (rows not present in authoritative source set)

---

## 6. Incremental Import Trigger Rules

### 6.1 Primary Trigger

- chat.db MAX(ROWID) increases

### 6.2 Secondary Trigger (Recovery Path)

If:

- MAX(ROWID) matches imported max source_rowid

AND

- importable message count > imported message count

Then:

→ ledger is stale

→ MUST trigger reimport (forceFullReimport)

Agents MUST NOT:

- rely solely on MAX(ROWID)

- assume equal cursor implies completeness

---

## 7. Recovery / Restoration Behavior

Restored app data folders may contain:

- stale working.db projections

- incomplete macos_import.db relative to live chat.db

System MUST:

- detect stale ledger state

- trigger reimport when needed

- reconcile projection via migration

Agents MUST NOT:

- assume restored data is consistent

- suppress inconsistencies

- silently proceed in inconsistent state

---

## 8. Projection Reconciliation

Projection must remain consistent even when:

- no new source data exists

- ledger changes underneath existing projection

- restored snapshots are used

Reconciliation currently occurs:

- during migration

Agents MAY introduce:

- additional consistency triggers

BUT MUST NOT:

- weaken invariants

- introduce partial tolerance

---

## 9. Forbidden Patterns

Agents MUST NOT introduce:

- direct UI reads from chat.db

- writes to working.db outside migration

- duplicate sources of truth

- silent fallback logic

- "best effort" projection logic

- validator suppression

- data patching as a substitute for logic correctness

---

## 10. Required Behavior When Invariants Are Threatened

If a task appears to require:

- bypassing ledger

- modifying projection directly

- weakening validation

- ignoring inconsistency

Agent MUST:

1. STOP

2. Explain the invariant conflict

3. Propose an architecture-consistent solution

---

## 11. Definition of Healthy System

System is healthy when:

- macos_import.db fully reflects source data

- working.db exactly matches projection rules

- all validators pass strictly

- UI reads only from working.db

- no hidden inconsistencies exist

---

## 12. Notes for Agents

This system is:

- invariant-driven

- spec-driven

- correctness-first

Correctness ALWAYS takes precedence over:

- convenience

- performance shortcuts

- partial functionality

---

END
