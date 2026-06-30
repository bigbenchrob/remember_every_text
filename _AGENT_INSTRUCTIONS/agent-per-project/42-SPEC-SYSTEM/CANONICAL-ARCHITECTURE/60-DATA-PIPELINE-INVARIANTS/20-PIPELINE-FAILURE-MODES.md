# PIPELINE FAILURE MODES

## Purpose

This document defines known classes of failure in the MessageLens data pipeline.

Each failure mode represents a violation, or potential violation, of pipeline
invariants.

Agents MUST use this document to:

- classify observed issues.
- avoid misdiagnosis.
- select correct remediation strategies.

---

## 1. Failure Mode Classification

Pipeline failures fall into one or more of:

- source-scoped ledger incompleteness.
- graph projection inconsistency.
- trigger/orchestration failure.
- identity/deduplication failure.
- evidence spine violation.
- overlay authority violation.
- retired storage leakage.
- silent tolerance failure.

---

## 2. Source-Scoped Ledger Incompleteness

### Definition

`macos_import_ss.db` does not fully reflect source data required by graph
projection.

### Root Cause Pattern

- cursor-only source checks.
- importer stage skipped or failed.
- row-level source facts not preserved.
- rich text or attachment source facts not imported before projection.

### Detection

- source count > import ledger count.
- gaps in source row coverage.
- graph projection missing rows because import facts are absent.

### Correct Handling

- trigger source-scoped import/rebuild.
- inspect importer stage diagnostics.
- do not trust cursor alone.

---

## 3. Graph Projection Inconsistency — Stale Rows

### Definition

`working_ss.db` contains graph rows or edges not present in the authoritative
source-scoped source set under current projection rules.

### Root Cause Pattern

- graph built from older ledger snapshot.
- ledger later changed.
- projector inserted but did not remove/update stale derived rows.

### Detection

- row-count mismatch between graph and source-scoped source set.
- anti-join reveals orphan graph rows or edges.
- graph health endpoint-integrity diagnostics fail.

### Correct Handling

- fix graph projector/rebuild logic.
- keep validators strict.
- do not patch individual graph rows as the real solution.

---

## 4. Graph Projection Inconsistency — Missing Rows

### Definition

`working_ss.db` is missing graph rows or edges that exist in source-scoped
import facts and should project under current rules.

### Root Cause Pattern

- incomplete graph build.
- projector aborted early.
- graph data version/readers refreshed before projection finished.
- topology importer/projector skipped a relationship.

### Detection

- graph count < expected count.
- UI missing evidence that exists in import.
- graph health reports missing endpoint rows or missing topology.

### Correct Handling

- rerun graph build.
- ensure projectors are idempotent and complete.
- add regression tests at importer/projector boundary.

---

## 5. Graph Projection Inconsistency — Duplicate Rows

### Definition

`working_ss.db` contains multiple rows or edges representing the same canonical
graph entity.

### Root Cause Pattern

- incorrect uniqueness constraints.
- GUID treated as canonical identity.
- source-scoped identity not used consistently.
- topology projection inserts duplicate edges.

### Detection

- `COUNT(*) > COUNT(DISTINCT ss_id)` where row identity should be unique.
- duplicate canonical edge pairs.
- duplicate participant/contact/handle aliases under canonical identity.

### Correct Handling

- enforce canonical `ss_id` or endpoint-pair uniqueness.
- fix projector logic.
- add duplicate-edge tests.

---

## 6. Cursor False No-Op

### Definition

The system incorrectly concludes no work is needed based on cursor equality.

### Root Cause Pattern

- `MAX(ROWID)` is current but source-scoped import or graph projection is
  incomplete.
- restored app data folder contains stale derived DBs.

### Detection

- source/import/graph count mismatch despite equal cursor.
- graph readiness says populated but evidence surfaces miss rows.

### Correct Handling

- add or use secondary completeness signals.
- trigger graph rebuild/reconciliation.
- do not weaken readiness checks.

---

## 7. Trigger / Orchestration Failure

### Definition

Correct work exists but is never scheduled or executed.

### Root Cause Pattern

- monitor not initialized.
- timer not started.
- maintenance lock or gate blocks execution incorrectly.
- silent failure in graph build scheduling path.
- graph data-version invalidation omitted after success.

### Detection

- no logs of graph build attempt.
- `ChatDbChangeMonitor` cursor changes but build status remains idle.
- imported/projected counts do not change after source change.

### Correct Handling

- instrument startup and scheduler paths.
- ensure graph build status is visible.
- keep lifecycle ownership in orchestration/application services, not widgets.

---

## 8. Authority Boundary Violation

### Definition

Code bypasses canonical data flow.

### Examples

- UI reads from `chat.db`.
- feature writes directly to `working_ss.db`.
- import/projection reads overlay user intent.
- presentation layer performs graph identity conversion or topology lookup.
- source-specific message renderer bypasses the evidence spine.

### Correct Handling

- remove violation.
- restore source-scoped import -> graph projection -> evidence provider flow.
- move SQL/read logic behind named infrastructure repositories.

---

## 9. Overlay Authority Violation

### Definition

Durable user intent is stored in projection data, or projection/import consults
overlay state.

### Examples

- favourite/name/dismissal fields written into `working_ss.db`.
- graph projection filters rows based on overlay dismissals.
- manual links patched into derived graph tables instead of overlay bridge
  state.

### Correct Handling

- move user intent to overlay.
- merge overlay at read/display boundary.
- keep projection pure.

---

## 10. Evidence Spine Violation

### Definition

A message-bearing surface uses a source-specific renderer, batch/pagination
model, or local hydration path instead of the shared Message Evidence Spine.

### Root Cause Pattern

- quick feature-specific UI implementation.
- latest-N query mistaken for timeline navigation.
- attachment evidence resolved inside widgets.

### Detection

- surface does not produce a typed `MessageEvidenceScope`.
- heatmap/search/jump controls only see hydrated rows.
- row rendering differs by source for no explicit architectural reason.

### Correct Handling

- restore shared evidence scope, skeleton, hydration, and row renderer.
- remember: pagination is not timeline navigation.

---

## 11. Retired Storage Leakage

### Definition

Retired `macos_import.db` / `working.db` storage or old compatibility-era code
becomes ordinary app authority again.

### Root Cause Pattern

- old provider reused because it is convenient.
- recovery/archive bridge not named as an explicit archive/storage bridge.
- diagnostic read promoted into product surface.

### Detection

- ordinary app surface opens retired cleanup/diagnostic DB files.
- documents describe retired projection/storage as a current app path.
- tests depend on legacy row IDs for graph-era evidence.

### Correct Handling

- classify the retired storage path.
- move ordinary reads to graph.
- keep archive/storage bridge named and removal criteria documented.

---

## 12. Silent Tolerance Failure

### Definition

The system suppresses or ignores inconsistency instead of surfacing it.

### Root Cause Pattern

- weakened validator.
- catch-and-ignore exceptions.
- fallback logic that hides missing graph topology.
- UI hides anomalous records.

### Correct Handling

- reintroduce strict validation.
- fail visibly.
- render anomalous evidence with diagnostic state rather than suppressing it.

---

## 13. Debugging Protocol

When investigating a pipeline issue:

1. Classify failure mode(s).
2. Identify violated invariant.
3. Locate layer:
   - source
   - source-scoped ledger
   - graph projection
   - overlay merge
   - evidence spine
   - explicit archive/storage bridge
   - UI
4. Do not patch data first.
5. Fix the responsible logic.

---

## 14. Key Insight

Most failures are not random bugs.

They are violations of:

- authority boundaries
- graph projection consistency
- trigger correctness
- evidence spine convergence
- overlay separation

Correct diagnosis depends on identifying the class, not the symptom.

---

END
