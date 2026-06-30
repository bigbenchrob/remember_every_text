---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: historical-record
links:
  - ./V2_ARCHITECTURE_PLAN.md
  - ./IMPLEMENTATION_PLAN.md
  - ./SPIKE_RETROSPECTIVE.md
tests: []
feature: historical-messages-merge-redux
status: historical-checklist-superseded-by-graph-recovery
created: 2026-04-29
---

# Checklist - Historical Messages Merge Redux

## Current Conformance Note (2026-06-06)

This checklist records the retained-legacy archive-merge plan and should not be
used as the current execution checklist. Current archive/recovery execution is
tracked through the source-scoped graph migration documents, especially the
archive recovery identity plan and recovered-message graph identity/parity
plans.

The durable lessons still apply: archive import must be observable, idempotent,
atomic at the app-visible boundary, and never rendered directly from a private
staging database.

## Current Snapshot - 2026-04-29

Completed so far:

- Durable `Settings -> Support -> Historical Archives` entry is live.
- Historical Archives center-panel shell is live with folder selection, preflight, begin-import placeholder, progress, result summary, and activity-log sections.
- Folder selection now persists in the workflow model and shows folder path, `chat.db`, `Attachments/`, and proposed source label.
- Preflight is read-only, uses a direct source `chat.db` connection rather than `ATTACH` / `DETACH`, and surfaces source counts plus GUID-based dry-run estimates against `working.db`.
- Execution-gate and maintenance-lock state are wired into the workflow shell so blocked and busy states are visible instead of appearing frozen.
- The shell now includes both `Clear Selected Folder` and the developer/testing-only `Clear Imported Archive Data for This Source` control, including target preview and confirmation.
- Focused tests now cover route/shell rendering, preflight panel-model behavior, and the destructive-clear confirmation flow.

Next recommended slice:

1. Build the durable known-archives sidebar model and archive-source list, including the stable `Add an Archive Folder` action.
2. Expand preflight evidence to include the remaining missing metadata called out below, especially earliest/latest dates and attachment-related evidence where available.
3. Replace the begin-import placeholder with real canonical ledger ingestion into `db-import`, then trigger the full migration/rebuild cycle.

## Phase 0 - Architecture Lock

- [ ] Confirm the v2 core guardrail: archive import enters the same canonical source -> `db-import` -> migration -> `working.db` pipeline as live data
- [ ] Confirm archive rows will be written into the existing `db-import` ledger and that a parallel archive-import database is forbidden
- [ ] Confirm all canonical ledger timestamps will be Unix epoch seconds stored as `INTEGER`
- [ ] Confirm GUID dedupe occurs at ledger insertion and will not be repeated in migration
- [ ] Confirm migration will not read attached or external databases
- [ ] Confirm archive import triggers a full canonical migration cycle and does not use a custom archive-only projector
- [ ] Confirm migration visibility must be atomic with respect to provider reads from `working.db`

## Phase 1 - Durable Historical Archives Surface

- [x] Add a durable `Settings -> Support -> Historical Archives` entry
- [ ] Add stable sidebar info cards explaining what archive import does and that it is additive
- [ ] Add a durable archive-source list in the sidebar for known archives
- [ ] Show source label, date range, message count, import status, and last imported date/time for known archives
- [ ] Add the stable `Add an Archive Folder` action in the sidebar
- [x] Add the center-panel shell with visible sections for folder selection, preflight, begin import, progress, and result summary

## Phase 2 - Folder Selection And Archive Source Model

- [x] Add folder picker support for choosing a historical Messages folder
- [x] Persist selected-folder state in the durable workflow model
- [x] Show folder path, `chat.db` presence, `Attachments/` presence, and proposed source label after selection
- [ ] Introduce a durable known-archives model that can represent previously added archive sources before re-import occurs
- [x] Ensure the UI remains an observer/controller only and performs no import work directly

## Phase 3 - Preflight-Only Analysis

- [x] Implement preflight analysis without writing rows into `working.db`
- [x] Ensure preflight does not rely on `ATTACH` / `DETACH` database usage and instead uses direct read access or an isolated connection
- [ ] Surface total messages, chats, handles, attachments or joins when available, earliest/latest dates, missing GUID counts, likely duplicates, and likely new rows
- [x] Keep preflight read-only and visibly separate from real ledger ingestion
- [ ] Disable `Begin Import` when no `chat.db` exists, preflight fails, or another import/migration/reset holds the execution gate
- [x] Add tests proving preflight state renders before any real import is wired

## Phase 4 - Progress-State Model Before Real Import

- [x] Create a durable workflow state model for archive import progress
- [x] Represent the canonical phases: reading source, normalizing to ledger format, writing to `db-import`, full migration, index rebuild, app-visible refresh, complete
- [x] Represent per-phase states: waiting, running, succeeded, failed, skipped
- [x] Add fake or no-op progress transitions so the workflow UI can be validated without real import logic
- [ ] Ensure long-running phases report progress without blocking UI interaction outside the maintenance-lock scope
- [ ] Verify the UI can distinguish ledger import progress, migration progress, index rebuild progress, and app-refresh completion

## Phase 4.5 - Optional Dry Run Import

- [ ] Consider a dry-run path that simulates ledger insertion, dedupe, and projected counts without committing canonical ledger rows
- [ ] If added, keep dry-run analysis explicitly separate from real ledger ingestion and migration triggers
- [ ] Use dry-run output only as evidence and debugging support, never as a substitute for canonical result accounting

## Phase 5 - Canonical Ledger Ingestion

- [ ] Normalize historical source rows into the existing canonical `db-import` schema
- [ ] Ensure ledger ingestion is atomic per batch so partial ledger writes do not persist on failure
- [ ] Produce a unique `import_batch_id` for every archive import run and apply it to all ledger rows from that run
- [ ] Add provenance metadata on canonical ledger rows without creating archive-only message semantics
- [ ] Convert source-specific timestamps to Unix epoch seconds as `INTEGER` before ledger insertion
- [ ] Apply GUID dedupe at ledger insertion using message GUID as the dedupe key
- [ ] Guarantee idempotent re-import so importing the same source twice does not duplicate or mutate existing canonical ledger rows
- [ ] Record enough provenance and accounting data to explain accepted, skipped, deduplicated, and failed rows
- [ ] Ensure all source data is fully materialized into `db-import` before migration begins

## Phase 6 - Full Canonical Migration

- [ ] Trigger a full migration cycle through the canonical migration orchestrator after successful archive ledger ingestion
- [ ] Ensure migration reads only canonical ledger tables from `db-import`
- [ ] Ensure migration does not read attached or external archive databases
- [ ] Preserve replay semantics so full rebuild can reproduce archive-backed rows from ledger truth
- [ ] Ensure migration is restartable from a clean state without requiring manual database intervention
- [ ] Keep provider-visible `working.db` state atomic so partial migration does not leak into normal app surfaces

## Phase 7 - Index Rebuild And Visibility Refresh

- [ ] Rebuild indexes, search data, and heatmap support tables through the canonical post-migration flow
- [ ] Refresh app-visible data only after migration and required rebuild steps complete
- [ ] Ensure user-visible success is impossible before canonical migration and rebuild complete
- [ ] Surface whether historical messages are now visible in normal app surfaces

## Phase 8 - Result Accounting

- [ ] Show result summary with source label, folder path, staged/imported rows, projected rows, skipped/deduplicated rows, failed rows, and earliest/latest dates
- [ ] Keep ledger-ingestion success distinct from app-visible projection success
- [ ] Ensure failure states explain whether the failure happened during preflight, ledger ingestion, migration, index rebuild, or final refresh
- [ ] Preserve durable result history for known archive sources where appropriate

## Phase 9 - Concurrency And Locking

- [ ] Apply single-flight rules so repeated archive-import requests coalesce or reject cleanly
- [x] Share the execution-gate model with live import, migration, reset, and maintenance work
- [ ] Ensure maintenance lock duration matches the true canonical critical section
- [ ] Release execution gate and maintenance lock deterministically on success, failure, and cancellation
- [ ] Ensure long-running phases keep reporting progress without freezing unrelated UI outside maintenance-lock scope
- [x] Verify the durable workflow surface reports blocked or gated states truthfully rather than appearing frozen

## Phase 10 - Verification And Regression Coverage

- [x] Add tests for durable navigation and workflow-shell rendering before real archive ingestion is enabled
- [x] Add preflight tests proving the center panel reports evidence without performing import
- [ ] Add ledger tests for canonical schema normalization, Unix timestamp conversion, provenance, and GUID dedupe
- [ ] Add ledger tests proving atomic per-batch ingestion, unique `import_batch_id`, and idempotent re-import behavior
- [ ] Add migration tests proving archive rows replay through the normal full migration flow
- [ ] Add tests proving migration never reads attached or external databases
- [ ] Add tests proving migration can restart cleanly after failure without manual DB intervention
- [ ] Add tests proving partial migration state is not visible to providers
- [ ] Add result-accounting tests proving staged vs projected vs skipped vs failed counts remain distinct
- [ ] Add progress-model tests proving long-running phases remain observable without freezing unrelated UI state outside maintenance-lock scope
- [ ] Add UI tests proving success is shown only after canonical migration and required rebuild steps complete
