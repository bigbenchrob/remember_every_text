---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-29
source_of_truth: doc
links:
  - ./V2_ARCHITECTURE_PLAN.md
  - ./SPIKE_RETROSPECTIVE.md
tests: []
feature: historical-messages-merge-redux
status: proposed
created: 2026-04-29
---

# Checklist - Historical Messages Merge Redux

## Phase 0 - Architecture Lock

- [ ] Confirm the v2 core guardrail: archive import enters the same canonical source -> `db-import` -> migration -> `working.db` pipeline as live data
- [ ] Confirm archive rows will be written into the existing `db-import` ledger and that a parallel archive-import database is forbidden
- [ ] Confirm all canonical ledger timestamps will be Unix epoch seconds stored as `INTEGER`
- [ ] Confirm GUID dedupe occurs at ledger insertion and will not be repeated in migration
- [ ] Confirm migration will not read attached or external databases
- [ ] Confirm archive import triggers a full canonical migration cycle and does not use a custom archive-only projector
- [ ] Confirm migration visibility must be atomic with respect to provider reads from `working.db`

## Phase 1 - Durable Historical Archives Surface

- [ ] Add a durable `Settings -> Support -> Historical Archives` entry
- [ ] Add stable sidebar info cards explaining what archive import does and that it is additive
- [ ] Add a durable archive-source list in the sidebar for known archives
- [ ] Show source label, date range, message count, import status, and last imported date/time for known archives
- [ ] Add the stable `Add an Archive Folder` action in the sidebar
- [ ] Add the center-panel shell with visible sections for folder selection, preflight, begin import, progress, and result summary

## Phase 2 - Folder Selection And Archive Source Model

- [ ] Add folder picker support for choosing a historical Messages folder
- [ ] Persist selected-folder state in the durable workflow model
- [ ] Show folder path, `chat.db` presence, `Attachments/` presence, and proposed source label after selection
- [ ] Introduce a durable known-archives model that can represent previously added archive sources before re-import occurs
- [ ] Ensure the UI remains an observer/controller only and performs no import work directly

## Phase 3 - Preflight-Only Analysis

- [ ] Implement preflight analysis without writing rows into `working.db`
- [ ] Surface total messages, chats, handles, attachments or joins when available, earliest/latest dates, missing GUID counts, likely duplicates, and likely new rows
- [ ] Keep preflight read-only and visibly separate from real ledger ingestion
- [ ] Disable `Begin Import` when no `chat.db` exists, preflight fails, or another import/migration/reset holds the execution gate
- [ ] Add tests proving preflight state renders before any real import is wired

## Phase 4 - Progress-State Model Before Real Import

- [ ] Create a durable workflow state model for archive import progress
- [ ] Represent the canonical phases: reading source, normalizing to ledger format, writing to `db-import`, full migration, index rebuild, app-visible refresh, complete
- [ ] Represent per-phase states: waiting, running, succeeded, failed, skipped
- [ ] Add fake or no-op progress transitions so the workflow UI can be validated without real import logic
- [ ] Verify the UI can distinguish ledger import progress, migration progress, index rebuild progress, and app-refresh completion

## Phase 5 - Canonical Ledger Ingestion

- [ ] Normalize historical source rows into the existing canonical `db-import` schema
- [ ] Add provenance metadata on canonical ledger rows without creating archive-only message semantics
- [ ] Convert source-specific timestamps to Unix epoch seconds as `INTEGER` before ledger insertion
- [ ] Apply GUID dedupe at ledger insertion using message GUID as the dedupe key
- [ ] Record enough provenance and accounting data to explain accepted, skipped, deduplicated, and failed rows
- [ ] Ensure all source data is fully materialized into `db-import` before migration begins

## Phase 6 - Full Canonical Migration

- [ ] Trigger a full migration cycle through the canonical migration orchestrator after successful archive ledger ingestion
- [ ] Ensure migration reads only canonical ledger tables from `db-import`
- [ ] Ensure migration does not read attached or external archive databases
- [ ] Preserve replay semantics so full rebuild can reproduce archive-backed rows from ledger truth
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
- [ ] Share the execution-gate model with live import, migration, reset, and maintenance work
- [ ] Ensure maintenance lock duration matches the true canonical critical section
- [ ] Release execution gate and maintenance lock deterministically on success, failure, and cancellation
- [ ] Verify the durable workflow surface reports blocked or gated states truthfully rather than appearing frozen

## Phase 10 - Verification And Regression Coverage

- [ ] Add tests for durable navigation and workflow-shell rendering before real archive ingestion is enabled
- [ ] Add preflight tests proving the center panel reports evidence without performing import
- [ ] Add ledger tests for canonical schema normalization, Unix timestamp conversion, provenance, and GUID dedupe
- [ ] Add migration tests proving archive rows replay through the normal full migration flow
- [ ] Add tests proving migration never reads attached or external databases
- [ ] Add tests proving partial migration state is not visible to providers
- [ ] Add result-accounting tests proving staged vs projected vs skipped vs failed counts remain distinct
- [ ] Add UI tests proving success is shown only after canonical migration and required rebuild steps complete