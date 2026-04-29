---
tier: feature
scope: design
owner: agent-per-project
last_reviewed: 2026-04-28
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./PHASE_1_MINIMAL_SLICE
  - ../../10-DATABASES/INVIOLATE_RULES.md
  - ../../20-DATA-IMPORT-MIGRATION/01-overview.md
tests: []
feature: historical-archive-merge
status: proposed
created: 2026-04-28
---

# Design Notes - Historical Archive Merge

## Core Design Decision

Phase 1 should be **minimal in UI scope but durable in data placement**.

That means:

- the user interaction stays limited to a small Settings -> Support cassette flow
- the merge rule stays strict: add-only, provenance-tracked, GUID-deduped
- the imported history must survive future rebuilds rather than living only in the disposable working projection
- the durable source boundary must be explicit: archive-derived rows live in `db-archive-import`, not in `db-working` alone and not in the live `db-import` polling stream

## Why Direct Working-Only Writes Are Not Safe Enough

The current architecture treats `db-working` as a projection that can be rebuilt from upstream app-owned data.

If Phase 1 writes merged historical rows only into `db-working`, the first full rebuild risks erasing them. That would make the feature appear to work initially while quietly violating its durability promise later.

For that reason, the design should preserve the current pipeline discipline:

- external archive is read-only input
- app-owned durable staging happens in a dedicated archive-import surface upstream of the projection
- `db-working` receives the projected rows plus provenance/batch fields used by the UI
- `db-overlay` remains untouched

## Required Durable Storage Model

Phase 1 should explicitly introduce `db-archive-import` as a parallel durable source path.

Target model:

```text
current_mac chat.db -> db-import -> migration -> working
archive chat.db     -> db-archive-import -> migration -> working
```

Rules:

- archive rows are durable across rebuilds
- archive rows are replayable through migration
- archive rows are distinguishable from `current_mac` at source level
- archive rows are never injected into the live polling stream as if they came from the current machine

This is the minimum acceptable Phase 1 clarification. A direct working-db-only path is unsafe, and co-mingling archive rows into the live import stream would blur source determinism.

## Proposed Phase 1 Flow

```text
Settings Support action
  -> folder selection
  -> validate archive folder
  -> open external chat.db read-only
  -> preflight summary
  -> user confirms merge
  -> add-only staged archive import into db-archive-import
  -> projection into working messages with provenance
  -> existing timeline/search/heatmap update through normal providers
```

## Resolver Responsibilities

`HistoricalArchiveMergeResolver` should own the archive-specific application logic:

1. validate the selected folder
2. locate `chat.db`
3. open external SQLite read-only
4. inspect minimal schema capabilities
5. compute preflight counts and warnings
6. execute the add-only merge into `db-archive-import`
7. log summary metrics
8. return immutable result objects for the UI

The resolver should not:

- write to overlay DB
- perform widget logic
- invent fuzzy identity rules
- hide failed rows behind silent filtering

## Minimal Data Contract

### Preflight

`HistoricalArchivePreflightSummary` should carry:

- `archive_label`
- `archive_path`
- `total_messages`
- `duplicate_messages`
- `new_messages`
- `earliest_date`
- `latest_date`
- `can_import`
- `warnings`

### Import Result

`HistoricalArchiveImportResult` should carry:

- `archive_label`
- `import_batch_id`
- `total_messages_seen`
- `duplicates_skipped`
- `messages_imported`
- `rows_without_guid_count`
- `rows_failed`
- `earliest_imported_date`
- `latest_imported_date`
- `warnings`

## Identity Rule

The only dedupe rule is:

- archive row GUID exists already -> skip
- archive row GUID absent -> insert

No fallback matching by:

- timestamp
- text
- sender
- attachment path
- chat membership

Rows that cannot participate in GUID-based merging should be surfaced as warnings or failed rows rather than merged heuristically.

Rows without usable GUIDs should also be counted explicitly in the result contract so the user can tell the difference between duplicates and unmergeable rows.

For Phase 1 accounting, those rows should increment both:

- `rows_failed`, because they were not imported
- `rows_without_guid_count`, because that is the reason they failed

## Legacy Schema Strategy

Phase 1 should tolerate older `chat.db` layouts by using a minimal extraction set.

Preferred extraction order:

1. `message_guid`
2. message date/timestamp
3. plain text or attributed-body-derived text when available
4. minimal handle/chat references only when required by the existing importer path

Unsupported or missing columns should degrade the summary or imported field completeness, not crash preflight unnecessarily.

## Preflight Performance Shape

Preflight should not require loading the full archive GUID set into memory.

Preferred approach:

1. stream archive message rows from the external database
2. perform indexed existence checks against the app-owned history
3. increment duplicate/new/missing-guid counters as rows are read

This keeps the Phase 1 analysis scalable for large archives while staying consistent with the strict GUID-only rule.

## Attachment Policy For Phase 1

Attachment handling is intentionally non-invasive in the first slice.

Rules:

- detect whether `Attachments/` exists
- show the correct user-facing warning
- do not copy attachment files
- do not block message import because attachments are absent

This keeps the slice focused on proving the additive merge model.

## Candidate Integration Shape

The smallest likely cross-layer path is:

1. `settings_root_resolver.dart` adds `Import Historical Archive` as a transient Troubleshooting action
2. `SettingsTopMenuWidget` dispatches through the existing transient settings action path
3. `SidebarActionDispatcher` replaces the current ephemeral settings projection with the archive-merge cassette flow
4. `SettingsCassetteCoordinator` resolves the archive-merge `SettingsCassetteSpec` states into payloads for the initial, preflight, and result cassettes
5. resolver/service performs folder validation, preflight, and merge orchestration behind those cassettes
6. durable archive rows are staged upstream of `db-working`
7. migration or a focused projection step writes merged rows into working messages with provenance metadata
8. existing providers refresh and existing timeline/search/heatmap surfaces pick up the data without any archive-specific ordering logic

## Why This Entry Point Is Correct

This feature behaves like the existing Support diagnostic/action flows, not like a new persistent settings context.

That makes the existing transient-action machinery the right fit:

- it already supports one-off support actions launched from the Settings top menu
- it already supports replacing the visible settings cassette stack ephemerally
- it already separates menu entry, dispatcher routing, and resolver-owned cassette payloads

Phase 1 should therefore reuse the same support-action path used by `Send logs…` and `Reset message data…`, rather than introducing a new sidebar topology or settings-specific navigation pattern.

## Timeline Authority

Timeline authority must remain untouched.

Phase 1 must not:

- change existing ordering rules
- add archive-specific sorting behavior
- special-case archive rows in timeline/search/heatmap providers

Archive-derived rows should simply participate in the same ordinal model already used by current message data.

## Logging Contract

Log only operational metadata:

- archive path
- archive label
- total messages
- duplicate count
- new count
- import batch ID
- imported count
- failed row count
- earliest/latest dates

Do not log message text.

## Primary Risks

### Projection Drift

If the implementation takes a shortcut around the durable data path, merged history may disappear on the next rebuild.

### Schema Variance

Old archive `chat.db` files may not match the current source schema. Preflight must treat that as a data-shape problem, not as permission failure.

### Scope Expansion

Once folder selection exists, it will be tempting to add rollback, source filters, or attachment copy immediately. Those should stay deferred until the add-only merge path is proven.

## Suggested Implementation Order

1. Lock the durable storage boundary and provenance fields.
2. Implement archive-folder validation and preflight analysis.
3. Implement add-only GUID merge execution and result contract.
4. Add the minimal Settings -> Support cassette flow.
5. Add tests for idempotency, unchanged existing rows, overlay untouched, and legacy-schema tolerance.
