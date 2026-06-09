---
tier: feature
scope: architecture-plan
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: historical-record
links:
  - ./SPIKE_RETROSPECTIVE.md
  - ./CHECKLIST.md
  - ../../10-DATABASES/10-group-import-working.md
  - ../../20-DATA-IMPORT-MIGRATION/01-overview.md
tests: []
feature: historical-messages-merge-redux
status: historical-plan-superseded-by-source-scoped-graph-recovery
created: 2026-04-29
---

# V2 Architecture Plan — Historical Messages Merge

## Current Conformance Note (2026-06-06)

This plan is preserved as historical architecture research. Its strongest
lesson remains binding: historical archive data is a second source, not a
parallel presentation or projection architecture. However, the canonical
pipeline has changed since this plan was written.

Current target:

```text
historical source
  -> source-scoped import/provenance
  -> conversation graph projection
  -> Message Evidence Spine
```

The old `db-import` -> migration -> `working.db` visibility language below is
retained for historical accuracy only. New archive/recovery work should follow
the source-scoped graph identity plans and deterministic recovery docs, using
retained legacy projection only as an explicitly named archive/recovery
compatibility bridge.

This document turns the spike retrospective into a v2 architecture plan.

It is intentionally an architecture document, not an implementation plan.

## Core Guardrail

Historical archive import must enter the same canonical import-to-working pipeline as live `chat.db` data, with source provenance added, not a parallel custom projection system.

Archive rows must be written into the existing canonical import ledger in `db-import` with provenance metadata. A parallel archive-import database is not permitted in v2.

That rule drives the rest of this plan.

- Archive data is a second source, not a second projection architecture.
- The importer owns source-to-ledger transformation.
- The migration orchestrator owns ledger-to-working projection.
- UI visibility still depends on `working.db`, not on any archive staging database.

## Why V1 Failed

The spike proved that historical messages are worth preserving and can be useful in the normal MessageLens experience.

It also proved that a bespoke archive staging-plus-projection path becomes brittle when it diverges from the canonical pipeline in any of these ways:

- schema shape differs materially from the import ledger
- timestamp conversion happens outside the centralized date rules
- projection accounting is mixed together with staging accounting
- archive-specific transaction logic reimplements working projection behavior
- UI state tries to represent success before canonical projection is complete

V2 therefore treats archive merge as a canonical ingestion problem, not as a special replay service.

## Existing Architecture Summary

The stable MessageLens data path is:

```text
source dbs
  -> import orchestrator
  -> db-import ledger
  -> migration orchestrator
  -> working.db
  -> provider/UI surfaces
```

The architectural intent for v2 is to preserve that shape.

- Live `chat.db` remains one source of Messages data.
- Historical archive `chat.db` becomes another source of Messages data.
- Both sources must normalize into the same canonical ledger contract.
- The migration layer must continue projecting from canonical ledger tables into canonical working tables.
- Search/index rebuilds remain a post-migration concern.

The main difference in v2 is provenance, not pipeline shape.

## Durable Historical Archive Import Surface

### Rule

Historical archive import must be implemented as a durable Settings choice with a visible step-by-step control surface, not as a one-shot transient action.

This is both a UX requirement and an implementation guardrail.

### Why

The spike failed partly because the import experience collapsed too much state into one button and one ambiguous result. That made it difficult for both the user and the developer to tell whether the system was:

- still in preflight
- importing into the canonical ledger
- migrating into `working.db`
- rebuilding indexes and support tables
- or actually finished and visible in normal app surfaces

V2 must make those boundaries visible from the start.

### User-Visible Contract

The user must be able to see:

- what archive sources are known
- what folder was selected
- what preflight detected
- whether import has begun
- whether ledger ingestion succeeded
- whether migration into `working.db` succeeded
- whether historical messages are now app-visible

### Settings Placement

The durable entry point is:

`Settings -> Support -> Historical Archives`

This must be a stable Settings menu choice, not an ephemeral support action.

### Sidebar Contract

The sidebar should provide stable explanatory and status context.

It should show one or more info cards explaining:

- older Messages folders may contain message records that are not present in the current Mac `chat.db`
- MessageLens can import those records into its canonical message ledger
- once imported and migrated, those messages become part of the normal MessageLens timeline, search, and heatmap
- archive import is additive and does not replace current message data

Below the info cards, the sidebar should show known archive sources, if any, including:

- source label
- date range
- message count
- import status
- last imported date and time

The sidebar should also expose the durable action:

- `Add an Archive Folder`

### Center Panel Workflow Surface

The center panel owns the workflow controls and visible step sequence.

#### Panel 1: Choose Messages Folder

Controls:

- `Choose Messages Folder...`

After selection, the panel should continue showing:

- folder path
- whether `chat.db` was found
- whether `Attachments/` was found
- source label or proposed archive name

#### Panel 2: Preflight Summary

This panel exists before selection but remains empty or disabled until folder selection completes.

After folder selection, it should show read-only evidence such as:

- total messages
- total chats
- total handles
- total attachments or attachment joins when available
- earliest message date
- latest message date
- rows with missing GUIDs
- likely duplicates already in ledger
- likely new rows

#### Panel 3: Begin Import

Control:

- `Begin Import`

This control is enabled only after valid preflight.

It must remain disabled when:

- no `chat.db` is present
- preflight failed
- another import, migration, or reset operation owns the execution gate

#### Panel 4: Progress

Progress must be rendered as explicit phases aligned with the canonical pipeline:

1. Reading archive source
2. Normalizing records into canonical ledger format
3. Writing archive rows to `db-import`
4. Running full canonical migration
5. Rebuilding indexes, search, and heatmap support tables
6. Refreshing app-visible data
7. Complete

Each phase should expose one of:

- waiting
- running
- succeeded
- failed
- skipped, when applicable

Progress must distinguish:

- ledger import progress
- migration progress
- index rebuild progress
- UI refresh completion

#### Panel 5: Result Summary

After completion, the surface should show:

- archive source label
- folder path
- staged or imported rows
- projected rows
- skipped or deduplicated rows
- failed rows
- earliest and latest message date
- whether messages are now visible in normal app surfaces

User-facing success must only be shown if canonical migration and required rebuild steps completed.

### Architectural Guardrail

The UI must not perform import logic.

The UI displays workflow state from a durable workflow model.

The service layer owns:

- preflight
- ledger ingestion
- migration trigger
- progress reporting
- final accounting

The center panel is a deterministic observer and controller, not an importer.

### Implementation Ordering Guardrail

This durable workflow surface must be implemented before the full archive import behavior is wired.

The ordering requirement is explicit because the surface itself is part of the safety model. It provides a visible way to validate each phase boundary before real archive ingestion and migration behavior is turned on.

The intended delivery order is:

1. durable Settings menu entry and stable sidebar or center panel shell
2. folder picker and selected-folder display
3. preflight-only analysis
4. known archives model and source list
5. progress-state model with fake or no-op phases for UI validation
6. real ledger import phase
7. full migration phase
8. final result accounting

### Key Rule

No more invisible one-button imports.

Every step must expose enough state that both the user and the developer can tell where the workflow is:

- before import
- during import
- after ledger import
- after migration
- after app visibility refresh

## Assumptions

1. Historical archive import will remain a user-initiated or explicitly orchestrated action rather than a background poll like live `chat.db` import.
2. Historical source data may differ from the current live source in timestamp encoding, handle normalization, join completeness, and attachment availability.
3. The app must be able to reset and rebuild `working.db` without losing previously imported historical rows.
4. Provenance must be queryable for diagnostics and future product features, but it must not fork the canonical migration path.
5. Incremental live sync and explicit archive import may coexist over time, so concurrency and maintenance rules must be explicit before coding begins.

## Hard Invariants

1. Archive import must not write directly into `working.db` outside the canonical migration path.
2. Archive import must not create a second custom projector that bypasses the normal migrator stack.
3. Archive import rows must be written into the existing canonical import ledger in `db-import`, not a parallel archive database.
4. Archive import rows must be represented in ledger tables that mirror the canonical import schema closely enough that existing migrator responsibilities still make sense.
5. All timestamps in the canonical ledger must be stored as Unix epoch seconds as `INTEGER`, with source-specific timestamp formats normalized at import time.
6. GUID-based deduplication must occur at canonical ledger insertion. Migration must treat the ledger as already deduplicated and must not reapply dedupe logic.
7. Migration must not read directly from attached or external databases. All archive data must be fully materialized into the canonical ledger before migration begins.
8. At no point may partial ledger ingestion or partial migration leave providers reading inconsistent `working.db` state. Migration must be atomic with respect to `working.db` visibility.
9. Archive import must trigger a full migration cycle through the canonical migration orchestrator.
10. Staging success must never be reported as timeline success.
11. A record present in canonical ledger scope must remain replayable into `working.db` after reset or full rebuild.
12. No provider or UI workaround may read directly from archive staging storage in order to show historical messages.
13. Provenance metadata may refine meaning, but it must not break ID preservation or the importer-owned versus migrator-owned separation.
14. Historical archive import must be exposed through a durable Settings workflow surface, not a transient one-button action.
15. The UI must observe and control workflow state through a durable model; it must not perform archive import logic itself.

## Architectural Direction

### Pipeline Contract

V2 should treat historical import as a canonical source-ingestion path:

```text
live chat.db ----------┐
                       ├-> import orchestrator / source-normalization
historical chat.db ----┘
                            -> canonical ledger tables
                            -> migration orchestrator
                            -> working.db
                            -> indexes / providers / UI
```

The important constraint is that source differences are resolved at import time into a ledger-compatible shape, not later by a custom archive-only projection routine.

### Source Roles

- `chat.db` remains the live source of ongoing Messages data.
- historical archive `chat.db` becomes a second source of Messages history.
- both sources emit canonical ledger rows plus provenance metadata.
- `db-import` remains the importer-owned ledger boundary.
- `working.db` remains the disposable, rebuildable projection boundary.
- archive import writes into the existing canonical import ledger, then triggers a full canonical migration cycle.

## Canonical Archive Import Schema

### Rule

Historical archive data must land in a schema that mirrors the canonical import ledger wherever possible.

The preferred contract is not “archive staging tables that later get translated into import tables.” The preferred contract is “archive rows imported into ledger-shaped tables with canonical column meaning.”

In v2, this means archive rows are written into the existing `db-import` ledger. A separate archive-import database is forbidden.

### Schema Shape

V2 archive import must preserve the existing ledger table families for messages data:

- messages
- chats
- handles
- chat membership / chat-to-handle joins
- attachments and attachment joins
- recovered-unlinked message path where source joins are missing
- batch metadata tables

Archive-specific needs should be expressed as additive metadata rather than a parallel semantic schema.

Allowed additions:

- source provenance fields
- source-database identity fields where the canonical ledger does not already capture enough traceability
- archive batch metadata that distinguishes archive import runs from live import runs
- normalization diagnostics fields if they are necessary for audit and replay

Disallowed direction:

- archive-only message tables whose shape no longer matches canonical ledger expectations
- archive-specific chat/message schemas that require archive-only migrators just to reach normal working tables
- importer outputs that force the migration layer to branch on “archive mode” for core message projection semantics

### Storage Option Decision Rule

V2 must use the existing import database with provenance-aware ledger rows.

This decision is locked for four reasons:

- the canonical ledger already exists there
- existing migrators already expect that ledger shape
- forbidding a parallel archive database avoids cross-database attach or detach complexity during migration
- replay and rebuild behavior stays anchored to one canonical ledger instead of two coordinated ledgers

The architectural requirement is therefore explicit:

> the migration layer must consume canonical ledger semantics from `db-import`, not spike-specific archive semantics from a parallel store.

## Date Representation Rules

### Rule

All timestamps in the canonical ledger must be stored as Unix epoch seconds as `INTEGER`. Source-specific timestamp formats must be normalized at import time.

### Required Policy

- importer code may parse source timestamp encodings
- importer code must normalize them into Unix epoch seconds before ledger insertion
- canonical conversion logic must remain centralized in the shared date-conversion utilities
- presentation-oriented ISO string formatting must not happen during archive source ingestion
- migration and working projection should consume Unix epoch seconds just as live import does

### Why

The spike became brittle when archive-specific code converted timestamps early into strings and then kept compensating for those choices downstream.

V2 should make timestamp handling boring.

- one canonical internal representation
- one canonical timestamp type: Unix epoch seconds stored as `INTEGER`
- one conversion boundary
- one place to extend support for older Apple timestamp variants

## Dedupe Contract

### Rule

GUID-based deduplication must occur at the canonical ledger insertion boundary. Migration must treat the ledger as already deduplicated and must not reapply dedupe logic.

### Required Dedupe Semantics

- dedupe key for messages is message GUID
- dedupe happens when source rows are inserted into `db-import`
- dedupe decisions must record enough provenance to explain why a candidate row was accepted or skipped
- migration consumes the ledger as canonical input and must not run a second archive-specific dedupe pass

### Why

The ledger is the correct place to decide whether a source row becomes part of canonical truth. Repeating dedupe during migration would recreate the same split-brain semantics that made the spike brittle.

## Provenance Model

### Rule

Provenance must be additive metadata attached to canonical rows, not a reason to fork the pipeline.

### Required Provenance Semantics

At minimum, every imported row that originates from archive ingestion must be traceable by:

- source kind: live or archive
- source database identity or source label
- import batch identity
- source-native identifiers already preserved by the canonical ledger

### Provenance Purpose

Provenance exists to answer questions like:

- did this row come from the live source or a historical source?
- which archive source did it come from?
- which import batch staged it?
- if a row is deduplicated or skipped, what source claimed it?

### Provenance Constraints

- provenance must not require a separate archive-only message model in `working.db`
- provenance must not break existing GUID and ID preservation rules
- provenance must support dedupe and audits without altering the meaning of canonical business tables
- provenance should be available to diagnostics, future filtering, and audits, but normal UI rendering should still read standard working tables

## Migration Input Boundary

### Rule

Migration must not read directly from attached or external databases. All source data must be fully materialized into the canonical ledger before migration begins.

### Required Boundary

- source database reads belong to import
- migration reads canonical ledger tables in `db-import`
- archive source files must not be attached to `working.db` during migration
- migration must not depend on cross-database attach or detach lifecycles to project archive rows

### Why

This boundary removes the class of SQLite locking and lifecycle bugs caused by migration-time dependence on external attached databases.

## Reset And Rebuild Replay Behavior

### Rule

Historical rows must survive as ledger truth so `working.db` can be rebuilt from scratch without re-reading the archive source database at render time.

### Required Behavior

- resetting or rebuilding `working.db` must not discard previously imported historical rows if the archive ledger still contains them
- full migration must be able to replay both live and archive-derived ledger rows into `working.db`
- archive visibility in the app must therefore depend on ledger durability, not on a one-off projection side effect
- if the app offers destructive clearing of archive data, that operation must be explicit and separate from normal projection rebuilds

### Architectural Consequence

The replay boundary is the ledger, not the source archive file and not a bespoke staging cache.

That means v2 should be designed so a future `Reset message data` flow can truthfully preserve or remove archive history based on ledger retention policy rather than hidden spike-specific side effects.

## Projection Accounting

### Rule

Accounting must distinguish import success from projection success.

### Required Counters

Every archive run must be able to report, at minimum:

- staged rows
- projected rows
- skipped rows
- failed rows
- deduplicated rows
- recovered-unlinked preserved rows when applicable

### Required Phase Separation

The architecture must treat these as separate boundaries:

1. source scan/read
2. canonical ledger import
3. migration into `working.db`
4. index rebuild / post-migration refresh
5. UI success emission

### Reporting Contract

- “imported” means canonical ledger ingestion succeeded
- “visible in app” means migration and required rebuild steps succeeded
- UI state must not collapse those two meanings into one result message

## Working Visibility Atomicity

### Rule

At no point may partial ledger ingestion or partial migration leave the system in a state where providers read inconsistent `working.db` data. Migration must be atomic with respect to `working.db` visibility.

### Required Visibility Contract

- canonical ledger ingestion may complete before migration, but that alone must not imply app-visible success
- provider-visible `working.db` changes must only become available after the migration cycle reaches a consistent post-migration state
- if migration fails, the system must surface failure rather than leaving providers to observe a half-projected state
- index rebuild and refresh steps required for stable provider reads are part of the same visibility contract

## Single-Flight And Maintenance-Lock Rules

### Rule

Archive import must use the same orchestration discipline as other import and migration work.

### Required Concurrency Model

- only one archive import for a given source may run at a time
- archive import must participate in the same execution gate model used by the broader import or migration pipeline
- if live import, migration, reset, or maintenance work already owns the execution gate, archive import must fail fast or queue explicitly rather than entering a partial state
- successful archive ledger import must trigger a full migration cycle through the canonical migration orchestrator
- archive rows must not be projected independently of the normal migration flow

### Maintenance Lock Semantics

- the maintenance lock exists to protect canonical DB work, not to hide inconsistent architecture
- lock duration must match the actual canonical import plus migration critical section
- lock ownership must be released deterministically on both success and failure
- contact picker and heatmap unavailability during maintenance should be a bounded, truthful state rather than a symptom of a hung custom archive transaction

### Guardrail

Single-flight and maintenance locking are orchestration rules around the canonical pipeline. They are not substitutes for getting the ledger and migration architecture right.

## Tests Required Before Implementation

Implementation should not begin until the v2 design is backed by explicit tests for the architectural contracts.

### Contract Tests

1. Archive source rows normalize into canonical ledger-shaped rows without requiring archive-only migration semantics.
2. Historical timestamp variants normalize into Unix epoch seconds as `INTEGER`, matching the live path.
3. Provenance metadata is attached deterministically and survives migration/replay.
4. GUID dedupe occurs at ledger insertion and behaves identically regardless of whether the candidate duplicate came from live import or archive import.
5. Migration consumes canonical ledger rows without reapplying dedupe logic.

### Workflow Surface Tests

1. The `Settings -> Support -> Historical Archives` entry exists as a durable navigation choice before real archive import wiring begins.
2. The sidebar renders explanatory cards plus known archive sources without requiring a live import run.
3. The center panel shows folder-selection, preflight, progress, and result sections as stable workflow surfaces.
4. The `Begin Import` control remains disabled until valid preflight succeeds and no other operation owns the execution gate.
5. Fake or no-op progress phases can be exercised independently so the UI state model is validated before real import and migration logic is connected.

### Replay And Rebuild Tests

1. Full rebuild from ledger reproduces archive-backed rows in `working.db` after the working projection is cleared.
2. Resetting `working.db` without clearing archive ledger data preserves future replay of historical messages.
3. Explicit archive-clear flows remove replay eligibility only when the ledger rows are intentionally removed.

### Projection Accounting Tests

1. Staged versus projected counts remain separate in success and failure cases.
2. A migration failure after ledger import does not report archive messages as visible in the UI.
3. Index rebuild failure is distinguishable from ledger import success and migration success.
4. Archive import triggers a full migration cycle rather than an archive-only projection shortcut.

### Concurrency And Locking Tests

1. Repeated archive-import triggers coalesce or reject cleanly under single-flight rules.
2. Archive import cannot race live import, reset, or full migration into a dirty partial state.
3. Maintenance lock is released on success, migration failure, and cancellation paths.
4. Migration does not read from attached or external databases when archive rows are present.

### UI Contract Tests

1. Providers and UI do not read archive staging storage directly.
2. Historical messages become visible only through canonical `working.db` projection.
3. User-facing result copy distinguishes canonical import success from app-visible projection success.
4. Workflow progress distinguishes ledger ingestion, migration, index rebuild, and app-refresh completion.
5. User-facing success is impossible before migration and required rebuild steps complete.

## Open Design Decisions For Sign-Off

These decisions still need explicit approval before coding begins.

1. What is the minimum provenance field set needed for audit, dedupe, and future UI filtering?
2. Which archive source-identity fields must be preserved even after canonical normalization?
3. Which reset flows preserve archive ledger rows by default, and which flows explicitly clear them?
4. What user-facing language should distinguish ledger import success from timeline visibility success?
5. What exact durable archive-source metadata should be shown in the sidebar list when an archive has been added but not yet re-imported recently?

## Bottom Line

V2 should not repair the spike by writing a better custom archive projector.

V2 should remove the custom archive projector from the design entirely.

Historical archive import becomes stable only if it is modeled as canonical source ingestion with provenance, followed by the same ledger-to-working migration path that already governs live Messages data.
