---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-04-21
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

# `db-import` — macOS Import Ledger (`macos_import.db`)

## Overview

`db-import` stores source-derived data extracted from macOS Messages (`db-chat`) and AddressBook (`db-address-book`). It preserves source identifiers and batch provenance, acting as the bridge between the raw Apple databases and the app-facing projection in `db-working`.

Current caveat: this ledger is importer-owned, not manually immutable. Incremental import preserves prior imported rows and adds new rows by high-water marks; full/reimport paths may clear and rebuild source-derived ledger tables through `ClearLedgerImporter` / `SqfliteImportDatabase.clearAllData()`. Do not describe this database as append-only unless referring only to import-batch provenance.

- **Alias**: `db-import`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`
- **Primary Consumers**: Import orchestrator, migration orchestrator, analytics/debug tooling

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `macos_import.db`
| Provisioning | Created on demand by `sqfliteImportDatabaseProvider` (see below) |
| Backups | External/operational backup if configured; not owned by the import database provider |

Always let the provider create and open the file; manual SQLite clients will lock it while the app runs.

## Provider Access

- **Riverpod entry point**: `sqfliteImportDatabaseProvider`
- **Definition**: `lib/essentials/db/feature_level_providers.dart`
- **Type**: `Future<SqfliteImportDatabase>` (Sqflite-backed)

Access pattern:

```dart
final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
```

Do not instantiate `SqfliteImportDatabase` manually; the provider handles directory creation, debug settings, and graceful shutdown.

## Schema & Drift Definitions

`db-import` is a plain Sqflite database; schema definitions live alongside the import infrastructure. Key references:

- `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart` — Sqflite helper and schema bootstrap.
- `_AGENT_INSTRUCTIONS/agent-per-project/20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Canonical table/column descriptions.

Core tables include:

| Table | Purpose |
| --- | --- |
| `import_batches` | Audit log for each import run (timestamps, versions, paths). |
| `source_files` / `import_logs` | Source file provenance and structured import diagnostics. |
| `contacts` | AddressBook contacts with original `Z_PK`, organization flags, names. |
| `contact_phone_email` | Normalised phone/email rows keyed by `ZOWNER`. |
| `contact_to_chat_handle` | AddressBook/contact-channel matches to chat handles. |
| `handles` | Raw chat handles from `db-chat`; retains original ROWIDs. |
| `chats` | Chat metadata from Messages. |
| `chat_to_handle` | Membership mapping directly from Messages source data. |
| `messages` / `chat_to_message` | Thread-linked message payloads and chat-message joins. |
| `recovered_unlinked_messages` | Source `message` rows that are not linked through `chat_message_join`. |
| `attachments` / `message_attachments` / `recovered_unlinked_message_attachments` | Attachment metadata and normal/recovered message attachment joins. |
| `reactions` / `message_links` | Parsed tapbacks and extracted URL spans. |

## Typical Use Cases

- Inspect the latest import batch metadata before running migrations.
- Verify a particular contact/handle exists in the ledger before debugging projection issues.
- Diff raw source rows against the working projection to confirm migration invariants.

Because `db-import` records batches, source files, import logs, and source identifiers, it provides a reliable diagnostic trail without risking mutation of the UI-facing projection. Do not rely on data tables being append-only across full/reimport flows.

## Related Rules & Contracts

- **Source identity must remain traceable**: Source ROWIDs, GUIDs, and AddressBook `Z_PK` values must remain available through import and projection. Some working tables canonicalize identity relationships, but they must not erase source traceability. See `10-group-import-working.md` for the full contract.
- **Provider-only access**: Always obtain connections via `sqfliteImportDatabaseProvider`; direct connections create locking issues.
- **Importer-owned derivation only**: `db-import` captures source-derived data plus import diagnostics and limited derived metadata such as rich-text extraction, recovered-unlinked classification, reactions, and URL spans. App-level UI behavior and user intent do not belong here.

## Cross-References

- `10-group-import-working.md` — How `db-import` feeds `db-working`.
- `02-db-working.md` — Projection database consuming this ledger.
- `../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md` — Pipeline that populates `db-import`.
- `../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md` — Pipeline that reads from `db-import`.
