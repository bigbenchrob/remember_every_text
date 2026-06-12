---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./02-db-working.md
  - ./03-db-address-book.md
  - ./04-db-chat.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `db-import` - Retained Archive Metadata Storage (`macos_import.db`)

## Overview

`db-import` is the retained `macos_import.db` storage name. Fresh graph-era
files now contain only archive-source metadata and schema migration records.
Existing user data folders may still contain historical legacy ledger tables
from earlier versions, and diagnostics/reset code must tolerate those files.

> Current conformance note (2026-06-08): ordinary graph-era import work uses
> `macos_import_ss.db` via source-scoped import providers. Do not add new
> product-facing behavior to `macos_import.db`. Its retained role is
> archive-source metadata, read-only diagnostics of historical files, and reset
> cleanup.

- **Alias**: `db-import`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`
- **Primary Consumers**: Historical archive-source metadata repository, database health diagnostics, reset cleanup

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `macos_import.db`
| Provisioning | Created on demand by `retainedArchiveMetadataStoreProvider`, which constructs the concrete retained metadata storage adapter behind the central DB boundary |
| Backups | External/operational backup if configured; not owned by the import database provider |

Always let the provider create and open the file; manual SQLite clients will lock it while the app runs.

## Provider Access

- **Semantic Riverpod entry point**: `retainedArchiveMetadataStoreProvider`
- **Concrete storage adapter**: `RetainedArchiveMetadataDatabase`
- **Definition**: `lib/essentials/db/feature_level_providers.dart`
- **Provider type**: `Future<RetainedArchiveMetadataStore>`
- **Adapter type**: Sqflite-backed

Access pattern:

```dart
final metadataStore = await ref.watch(
  retainedArchiveMetadataStoreProvider.future,
);
```

Do not instantiate `RetainedArchiveMetadataDatabase` manually outside the
central DB provider. Archive-source metadata callers should use the semantic
retained metadata store provider. Reset/storage cleanup may invalidate or close
the store provider when it already exists, but must not recreate ordinary
retained import behavior.

## Schema

`db-import` is a plain Sqflite database; schema definitions live alongside the retained archive metadata adapter. Key reference:

- `lib/essentials/db/infrastructure/data_sources/local/import/retained_archive_metadata_database.dart` — Sqflite adapter and retained metadata schema bootstrap.

Fresh graph-era files create only:

| Table | Purpose |
| --- | --- |
| `schema_migrations` | Records retained helper schema upgrades. |
| `historical_archive_sources` | User-registered historical Messages folder metadata and preflight results. |

Existing user folders may still contain older tables such as `messages`,
`attachments`, `recovered_unlinked_messages`, or `import_batches`. Treat them as
historical retained compatibility inventory. Do not build new ordinary features
on those tables.

## Typical Use Cases

- Persist and display registered historical archive-source metadata.
- Inspect old `macos_import.db` files read-only during diagnostics.
- Delete the retained file during full derived-data reset.

Because historical user files may still contain old ledger tables, diagnostics
should report what exists without treating those tables as active app truth.

## Related Rules & Contracts

- **Provider-only access**: Archive metadata callers obtain connections via
  `retainedArchiveMetadataStoreProvider`. Direct connections create locking
  issues and bypass the retained-storage boundary.
- **No active import semantics**: Source identity, rich text, reactions,
  recovered/orphan evidence, and attachment topology now belong to
  `macos_import_ss.db` and `working_ss.db`, not fresh retained
  `macos_import.db`.

## Cross-References

- `10-group-import-working.md` — Historical retained import/working contract.
- `02-db-working.md` — Retained projection database status.
- `../55-READERS-INTEGRATORS-ORCHESTRATORS/81-LEGACY-STORAGE-RETENTION-REGISTER.md` — Current retained storage status.
