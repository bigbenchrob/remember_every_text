---
tier: project
scope: source-scoped-graph-migration
status: policy-review
last_reviewed: 2026-06-20
depends_on:
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md
  - 81-LEGACY-STORAGE-RETENTION-REGISTER.md
  - 82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
---

# 83 - Legacy Database Retirement Assessment

## Purpose

This document records the current retirement-oriented assessment of:

- `macos_import.db`
- `working.db`

It applies the explicit policy decision that these files are transitional
compatibility storage only. They are not permanent reference databases and
should not remain architectural components of MessageLens.

The target end state remains:

```text
chat.db / AddressBook
→ macos_import_ss.db
→ working_ss.db
→ graph read models
→ Message Evidence Spine
→ overlay intent
```

with no ordinary application behavior depending on retained:

```text
macos_import.db
working.db
```

## Policy Decision

`macos_import.db` and `working.db` are retained transitional compatibility
storage, not permanent system-of-record storage.

They may remain temporarily during final retirement work, but only for named
storage, metadata, diagnostic, or migration purposes. They should not be used
to justify new features, ordinary app reads, ordinary app writes, or graph-era
identity decisions.

Because there is no external installed user base, and because a full backup of
the current Application Support folder exists, retirement decisions should now
optimize for:

- architectural correctness
- future maintainability
- archive/recovery integrity
- explicit data-retention choices

rather than indefinite backward compatibility.

## Core Interpretation

Historical message text is not the fragile asset. Authoritative message rows
remain recoverable from:

- live `chat.db`
- historical `chat.db` backups
- AddressBook source data where applicable

The fragile asset is attachment reachability. Attachment recovery depends on:

```text
graph identity
→ source identity
→ archive/recovery location
→ attachment retrieval
```

not on:

```text
graph identity
→ retained macos_import.db / working.db
```

Therefore, retained database retirement is safe only when attachment archive
and recovery identity can be explained without consulting retained legacy
projection tables.

## Current Active-Code Dependency Assessment

As of this review, active Dart references to retained database files/providers
are narrow and intentionally guarded by architecture tests.

### Central Filename Constants

Current files:

- `lib/essentials/db/feature_level_providers.dart`

Current usage:

- declares `retainedArchiveMetadataDatabaseFileName = 'macos_import.db'`
- declares `retainedHistoricalReferenceDatabaseFileName = 'working.db'`
- constructs the retained archive metadata store provider

Classification:

3. Diagnostic/support and transitional metadata boundary.

Retirement direction:

- keep constants only while reset/maintenance and retained metadata storage
  still need to locate/delete old files.
- eventually replace with an explicit retired-file cleanup inventory or remove
  after the app no longer creates or inspects these files.

Deletion readiness:

- not immediate, because reset still deletes retained file base names.
- safe after reset no longer needs to target these files, or after cleanup has
  a one-time retired-file removal path.

### Retained Archive Metadata Store Provider

Current files:

- `lib/essentials/db/feature_level_providers.dart`
- `lib/features/settings/feature_level_providers.dart`
- `lib/essentials/onboarding/application/message_data_reset_service.dart`

Current usage:

- settings Historical Archives source metadata reads/writes
- reset closes and invalidates retained metadata before deleting derived data

Classification:

2. Can be migrated to graph/source-scoped identity.

This is not ordinary evidence behavior. It is archive-source workflow metadata.
It should move out of `macos_import.db` because the file name now implies
legacy import authority that no longer exists.

Retirement direction:

- move archive-source metadata into a source-scoped or overlay-adjacent
  graph-era store.
- candidate target: a dedicated archive-source metadata table in the overlay DB
  if it represents user/workflow intent, or in `macos_import_ss.db` if it is
  source registry/import provenance.
- keep the semantic split explicit:
  - selected/known archive folders and workflow status are user/workflow
    metadata.
  - source identity/provenance belongs in `macos_import_ss.db.source_registry`.

Deletion readiness:

- blocked until Historical Archives source metadata no longer reads/writes
  `macos_import.db`.

### Reset / Derived Data Cleanup

Current file:

- `lib/essentials/onboarding/application/message_data_reset_service.dart`

Current usage:

- includes `macos_import.db` and `working.db` in
  `derivedMessageDataDatabaseBaseNames`
- closes retained archive metadata store before reset
- deletes retained DB base files along with source-scoped import and graph DBs

Classification:

3. Diagnostic/support/reset cleanup.

This does not make retained databases app authority. It is a cleanup path for
files that may still exist in the data folder.

Retirement direction:

- keep until retained file creation stops and old file cleanup policy is
  settled.
- later replace with a retired-file cleanup list that can delete old files
  without treating them as active derived databases.

Deletion readiness:

- safe after archive-source metadata moves out of `macos_import.db`.
- `working.db` can likely move first from "derived data base name" to
  "retired file cleanup target" because active code has no provider for it.

### Architecture Tripwires

Current file:

- `test/architecture/forbidden_imports_test.dart`

Current usage:

- protects retained metadata/provider access lists
- protects retained filename literal access lists
- prevents retired import/migration execution paths from returning
- prevents new ordinary `working.db` / `macos_import.db` access

Classification:

3. Diagnostic/test-only guardrail.

Retirement direction:

- keep while retirement is in progress.
- update as dependencies are removed so allowed lists shrink toward zero.
- after retained DB retirement completes, replace with stronger tests that
  assert the old filenames/providers do not appear in active code at all.

Deletion readiness:

- not a blocker. This is a safety tool for deletion.

## Database-Specific Assessment

### macos_import.db

Current role:

- retained archive-source metadata storage
- existing-file compatibility for older local data folders
- reset cleanup target
- diagnostic/support-bundle context

Not current role:

- ordinary source import ledger
- Historical Archives import execution path
- message/contact/chat/handle/attachment source facts
- graph projection source
- rollback insurance

Classification summary:

- Must remain temporarily for archive/recovery integrity: no direct ordinary
  evidence need identified.
- Can be migrated: Historical Archives source metadata.
- Diagnostic-only: schema/file inventory and support context.
- Historical-only: old ledger/projection tables in pre-existing files.
- Safe deletion candidate: old import/projection execution schema and any fresh
  creation of old tables has already been retired.

Retirement blockers:

1. Historical Archives source metadata still uses
   `retainedArchiveMetadataStoreProvider`.
2. Reset still treats `macos_import.db` as a derived data file.
3. Support diagnostics may still describe retained metadata file existence.

Recommended disposition:

- migrate active archive-source metadata out of `macos_import.db`.
- stop creating fresh `macos_import.db` for active workflow state.
- retain a one-time cleanup/export path for existing local metadata if needed.
- after migration, demote the filename to a retired-file cleanup target.

### working.db

Current role:

- retained historical/reference file if present in old data folders
- reset cleanup target
- possible diagnostic/file-inventory context

Not current role:

- ordinary message evidence source
- contact identity source
- conversation source
- search source
- live update target
- archive import/projection execution target
- attachment retrieval source of truth

Classification summary:

- Must remain temporarily for archive/recovery integrity: no active code need
  identified.
- Can be migrated: no current application dependency identified.
- Diagnostic-only: retained file existence / historical inventory.
- Historical-only: old tables in existing local backup/data folder.
- Safe deletion candidate: stronger candidate than `macos_import.db`, because
  active code has no current working DB provider.

Retirement blockers:

1. Conservative storage policy still lists `working.db` as retained historical
   reference storage.
2. Reset still deletes it as a derived data base name.
3. Any remaining support documentation must be updated so `working.db` is not
   implied to be a recovery authority.

Recommended disposition:

- treat `working.db` as the first legacy DB eligible for explicit retirement.
- convert references from "retained historical reference database" to
  "retired file cleanup target" once final dependency scan confirms no active
  reader.
- do not build new graph-era recovery logic that consults `working.db`.

## Archive / Recovery Risk Assessment

Retiring retained databases is unsafe only if any archive/recovery path still
requires a value that cannot be derived from graph/source-scoped identity.

Risks to verify before deletion:

1. Attachment archive lookup still has any hidden dependency on retained
   import attachment IDs rather than source-scoped attachment identity or an
   explicit compatibility key.
2. Historical archive source metadata is stored only in `macos_import.db` and
   would be lost without migration or explicit discard.
3. Support diagnostics still use retained DB schema assumptions to determine
   archive health.
4. Reset/maintenance expects retained providers to exist and would fail if the
   files/providers disappear.

Non-risks under the new policy:

- ordinary message text loss
- ordinary search loss
- ordinary contact/conversation evidence loss
- live incremental update loss
- user-name/favourite/manual-link loss, because those are overlay intent

## Recommended Retirement Sequence

### Phase 1: Freeze the Policy in Docs and Tests

Goal:

- make "transitional compatibility storage only" explicit.

Work:

- reference this assessment from the retention register.
- tighten wording where docs imply `macos_import.db` / `working.db` are
  long-term reference databases.
- keep active architecture tripwires.

Done means:

- future agents cannot interpret retained DBs as permanent architecture.

### Phase 2: Migrate Historical Archive Source Metadata

Goal:

- remove the last active `macos_import.db` workflow dependency.

Work:

- decide the new home for archive-source metadata:
  - overlay DB for user/workflow metadata
  - `macos_import_ss.db.source_registry` for source identity/provenance
- migrate or intentionally discard existing local metadata.
- update settings providers to stop reading `retainedArchiveMetadataStoreProvider`.

Done means:

- `lib/features/settings/feature_level_providers.dart` no longer watches
  `retainedArchiveMetadataStoreProvider`.

Implementation status:

- Satisfied for active Historical Archives workflow metadata. The public
  settings provider now composes `HistoricalArchiveSourcesRepository` from
  `overlayDatabaseProvider`, and the repository stores source metadata in the
  overlay settings key `historical_archive_sources/v1`.
- The old `macos_import.db.historical_archive_sources` table may still exist in
  retained files, but it is no longer the active metadata authority. Its
  remaining disposition is cleanup/export/discard policy, not production
  workflow support.
- The central `retainedArchiveMetadataStoreProvider` has been removed. Reset
  still deletes retained `macos_import.db` files when present, but it no longer
  opens a retained metadata database to do so.
- The old retained metadata database wrapper and store interface have also been
  removed from production source. Remaining `macos_import.db` references are
  filename cleanup, diagnostics, or historical documentation references rather
  than active database-provider authority.

### Phase 3: Demote Retained Files to Cleanup Targets

Goal:

- remove retained DB provider authority.

Work:

- remove or replace `retainedArchiveMetadataStoreProvider`.
- keep old filenames only in a retired-file cleanup list if needed.
- update reset service so it deletes old files without opening retained DBs.

Done means:

- no active provider constructs a retained `macos_import.db`.
- no active code opens `working.db`.
- architecture tripwire allowed lists for retained providers shrink to zero.

Implementation status:

- Satisfied for provider authority. Active provider scans are guarded by
  architecture tests: retained metadata provider usage and retained metadata
  database imports now have empty production allow-lists.

### Phase 4: Archive Attachment Compatibility Audit

Goal:

- prove attachment retrieval does not need retained DBs.

Work:

- trace attachment evidence from `message_ss_id` / `attachment_ss_id` to:
  - source row identity
  - source attachment path hint
  - archive compatibility key if still needed
  - current attachment archive file
- identify any remaining retained import attachment ID language.

Done means:

- attachment retrieval can be explained without retained `macos_import.db` or
  `working.db`.

### Phase 5: Retire / Delete / Ignore Old Files

Goal:

- complete retirement safely.

Work:

- choose final local policy:
  - delete old files during reset only
  - provide explicit "remove retired legacy databases" maintenance action
  - leave old files inert but unreferenced
- because there is no installed base and backup exists, deletion can be
  aggressive after Phases 2-4 are complete.

Done means:

- `macos_import.db` and `working.db` are no longer created, opened, or required
  by active code.
- any remaining mentions are historical docs or explicit retired-file cleanup
  notes.

## Current Readiness Judgment

The project is ready to move from retained compatibility storage toward
explicit retirement planning.

However, it is not yet ready for blind deletion because:

1. `macos_import.db` still stores active Historical Archives source metadata.
2. reset/maintenance still opens and invalidates retained metadata.
3. attachment archive compatibility should receive one final source-scoped
   trace audit before removing retained-file safety language.

`working.db` is closer to retirement than `macos_import.db`.

`macos_import.db` should be retired after archive-source metadata moves to a
graph-era home.

## Bottom Line

Under the new policy, neither retained legacy database should be treated as a
permanent reference database.

The remaining work is finite and practical:

```text
migrate archive-source metadata
→ demote old filenames to cleanup-only
→ verify attachment archive identity path
→ remove retained providers
→ delete or ignore inert old files
```

The key safety principle is:

```text
Preserve attachment reachability, not legacy database shape.
```
