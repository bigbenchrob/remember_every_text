# PIPELINE INVARIANTS — CORE

## Purpose

This document defines the non-negotiable invariants governing the MessageLens
data pipeline.

All agent work MUST respect these invariants.

If a task appears to require violating any invariant, STOP and surface the
conflict instead of implementing a workaround.

---

## 1. Canonical App-Facing Pipeline

```text
source (chat.db / attachments / AddressBook)
→ source-scoped import ledger (macos_import_ss.db)
→ conversation graph projection (working_ss.db)
→ Message Evidence Spine / graph readers
→ provider merge with user_overlays.db
→ UI
```

Retired `macos_import.db` and `working.db` files are cleanup/reference storage
for explicit diagnostics and historical interpretation. They are not ordinary
app-facing message evidence authority, and new archive/recovery workflows must
explain reachability through graph/source-scoped identity plus overlay archive
records rather than through retired database shape.

---

## 2. Authority Boundaries

### 2.1 `macos_import_ss.db` — Source-Scoped Import Ledger

- Single ordinary ingestion boundary for external source facts.
- Importers write only source facts and provenance.
- `ss_id` is deterministic source-scoped row identity for source-derived rows.
- GUIDs and Apple paths are metadata/bridge fields, not canonical identity.

Agents MUST NOT:

- bypass the source-scoped import ledger for ordinary graph data.
- read directly from `chat.db` for UI purposes.
- treat GUIDs or raw Apple ROWIDs as global app identity.
- duplicate ingestion logic in feature or presentation code.

### 2.2 `working_ss.db` — Conversation Graph Projection

- Fully derived from source-scoped import facts.
- Disposable and rebuildable.
- Written only by graph projection/build services.
- Relationships use canonical `ss_id` endpoints.

Agents MUST NOT:

- write to `working_ss.db` outside graph projection/build logic.
- treat `working_ss.db` as durable user intent.
- patch graph rows to fix logic errors.
- reintroduce GUID-based canonical relationship identity.

### 2.3 `user_overlays.db` — Durable User Intent

- Owns user-chosen names, favourites, tags, dismissals, manual links,
  archive metadata, and similar durable intent.
- Projection/import must not consult overlay state.
- Read providers merge graph + overlay at the boundary where display or user
  intent is needed; overlay wins on conflict.

Agents MUST NOT:

- write user intent into graph or retired projection/storage tables.
- restore overlay intent by snapshotting it into projection data.
- make import/projection behavior depend on overlay choices.

### 2.4 UI Layer

- Reads through typed graph/evidence/overlay providers.
- Must never read directly from `chat.db`, `macos_import_ss.db`, retained
  import/working DBs, or raw SQLite connections.
- Must not decide graph semantics, reconstruct topology imperatively, or repair
  data.

---

## 3. Graph Projection Rules

- Source-scoped import is the path from external source facts to the ledger.
- Graph projection is the path from ledger facts to app-facing graph rows.
- Projection must be deterministic.
- Projection must be idempotent and safe to re-run.
- Relationships in the working graph use `ss_id` endpoints.

### 3.1 Projection Consistency

After graph projection:

- projected graph tables must match their source-scoped authoritative source
  sets according to documented projection rules.
- no extra rows.
- no missing rows.
- no silent tolerance.

---

## 4. Message Evidence Spine Invariants

Message-bearing surfaces must use the Message Evidence Spine.

- Each surface produces a typed `MessageEvidenceScope`.
- Timeline-like scopes preserve the full logical selected message universe.
- Skeletons coordinate heatmaps, temporal jumps, search matches, and viewport
  orientation.
- Row bodies, media, and attachment evidence hydrate near the viewport.
- Limits apply to hydration windows, not selected scope size.

Hard rule:

> Pagination is not timeline navigation.

Source-specific scopes are allowed. Source-specific evidence renderers are not.

---

## 5. Attachment Projection And Archive Invariants

For graph attachments:

- source attachment facts stay in source-scoped import.
- graph attachment rows and `message_to_attachment` edges are derived source
  projection.
- archive metadata lives only in `user_overlays.db`.
- Apple attachment paths are source path hints and ingestion inputs, not
  durable availability or identity.

Graph projection MUST:

- preserve attachment records even when files are unavailable.
- project canonical `message_ss_id` / `attachment_ss_id` relationships when
  source topology exists.
- never write archive metadata into `working_ss.db`.

---

## 6. Incremental Source Trigger Rules

### 6.1 Primary Trigger

- `chat.db.message` `MAX(ROWID)` increases.

### 6.2 Completeness Signal

If:

- source cursor appears current

AND

- source/import/graph counts indicate missing coverage

Then:

→ source-scoped graph state is suspect
→ trigger or request an explicit graph rebuild/reconciliation path

Agents MUST NOT:

- rely solely on `MAX(ROWID)`.
- assume equal cursor implies completeness.

---

## 7. Recovery / Restoration Behavior

Restored app data folders may contain:

- stale `working_ss.db` graph projections.
- incomplete `macos_import_ss.db` relative to live `chat.db`.
- retained historical cleanup DBs that do not match current graph state.
- overlay archive/user-intent data that must be preserved.

System MUST:

- detect stale source-scoped graph state.
- rebuild/reconcile graph projection when needed.
- preserve overlay user intent and archive metadata.
- keep retained historical cleanup paths explicitly named.

Agents MUST NOT:

- assume restored data is consistent.
- suppress inconsistencies.
- silently proceed in inconsistent state.

---

## 8. Projection Reconciliation

Graph projection must remain consistent even when:

- no new source data exists.
- source-scoped ledger changes underneath existing graph projection.
- restored snapshots are used.
- archive/recovery workflows register or inspect retained storage evidence.

Reconciliation occurs through graph build/projection services, not through UI
repair logic.

Agents MAY introduce additional consistency triggers, BUT MUST NOT:

- weaken invariants.
- introduce partial tolerance.
- patch projection data as a substitute for fixing projection logic.

---

## 9. Forbidden Patterns

Agents MUST NOT introduce:

- direct UI reads from `chat.db`.
- writes to `working_ss.db` outside graph projection/build.
- writes to retired `working.db` / `macos_import.db` files.
- duplicate sources of truth.
- silent fallback logic.
- best-effort projection logic.
- validator suppression.
- data patching as a substitute for logic correctness.
- source-specific message renderers that bypass the evidence spine.

---

## 10. Required Behavior When Invariants Are Threatened

If a task appears to require:

- bypassing source-scoped import.
- modifying projection directly.
- weakening validation.
- ignoring inconsistency.
- using legacy identity as ordinary app authority.

Agent MUST:

1. STOP
2. Explain the invariant conflict
3. Propose an architecture-consistent solution

---

## 11. Definition Of Healthy System

System is healthy when:

- `macos_import_ss.db` reflects source facts required by current graph
  projection.
- `working_ss.db` matches graph projection rules.
- graph relationships use canonical `ss_id` endpoints.
- overlay user intent is preserved and merged at read time.
- message evidence surfaces use the shared evidence spine.
- retained historical databases are unused by ordinary app reads and
  explicitly classified as storage-retention or diagnostic reference evidence.
- no hidden inconsistencies exist.

---

## 12. Notes For Agents

This system is:

- invariant-driven
- graph-driven
- spec-driven
- correctness-first

Correctness ALWAYS takes precedence over:

- convenience
- performance shortcuts
- partial functionality

---

END
