---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: doc
links:
       - ../01-PROJECT/03-data-locations.md
       - ./03-db-address-book.md
       - ./04-db-chat.md
       - ./05-db-overlay.md
       - ./06-addressbook-path-resolution.md
       - ./07-overlay-database-independence.md
       - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# All Databases Accessed

This is the canonical index for every SQLite database the project touches. Treat it as the jumping-off point before drilling into individual docs.

## 🚨 Read This First

- **Resolve AddressBook paths via providers only.** Use `getFolderAggregateEitherProvider` (documented in `06-addressbook-path-resolution.md`). Never hardcode `/Sources/<UUID>/...`.
- **Do not open SQLite files directly.** Always go through the Riverpod providers declared in `lib/essentials/db/feature_level_providers.dart`. Extra connections will lock the file.
- **Production reads are graph-backed.** Ordinary app data flows through `db-import-ss` and `db-graph-working`; retained `db-import` stores archive-source metadata and retained `db-working` is old file/schema inventory for reset and diagnostics.
- **Overlay remains separate.** User intent lives in `db-overlay` and is merged at read time; no import/projection path may copy overlay intent into graph or working tables.
- **Shut everything down before manual access.** Quit the Flutter app and tooling prior to backups or ad-hoc SQL to avoid WAL/locking surprises.

## Canonical Database Aliases

Use these aliases consistently across docs, code comments, and conversations.

| Alias | Physical File | Primary Purpose | Provider Entry Point | Storage Location |
| --- | --- | --- | --- | --- |
| `db-address-book` | `AddressBook-v22.abcddb` inside the most recent `/Library/Application Support/AddressBook/Sources/<UUID>/` | macOS contact source of truth | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` | Resolved dynamically at runtime |
| `db-chat` | `chat.db` | macOS Messages source ledger | `PathsHelper.messagesDatabasePath` (import pipeline) | `~/Library/Messages/chat.db` |
| `db-import-ss` | `macos_import_ss.db` | Production source-scoped import ledger for Messages + AddressBook facts | `importDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import_ss.db` |
| `db-graph-working` | `working_ss.db` | Production source-scoped conversation graph consumed by graph readers and Message Evidence Spine | `driftConversationGraphDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working_ss.db` |
| `db-import` | `macos_import.db` | Retained archive-source metadata storage; old files may contain historical legacy ledger tables | `sqfliteImportDatabaseProvider` for archive-source metadata only | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db` |
| `db-working` | `working.db` | Retained historical projection file/schema inventory | No central app provider; reset/diagnostics treat as retained file storage | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db` |
| `db-overlay` | `user_overlays.db` | Long-lived user overrides and preferences | `overlayDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/user_overlays.db` |

## Coupled Database Groups

- **`group-source-scoped-graph-db`**: `db-import-ss` and `db-graph-working` are the production source-scoped graph pipeline. Source data lands in the import ledger, then graph projectors translate it into canonical `ss_id` rows and topology.
- **`group-retained-import-working-db`**: `db-import` and `db-working` are retained storage references, not an active pipeline. Fresh `db-import` stores historical archive-source metadata; old retained files may be inspected read-only by diagnostics. Do not use this group for new ordinary app reads.

## Source → Projection Flow

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            ↓
     db-import-ss (source-scoped ledger)
            ↓
     db-graph-working (conversation graph)
            ↕
     db-overlay (user overrides merged by providers)
```

## Provider Access Map

- `db-address-book`: `getFolderAggregateEitherProvider` (features/address_book_folders) → `AddressBookFolderAggregate.mostRecentFolderPath`.
- `db-chat`: retrieved via `PathsHelper` inside import/monitor infrastructure; feature and presentation code must not open it directly.
- `db-import-ss`: `importDatabaseProvider` from `lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`.
- `db-graph-working`: `driftConversationGraphDatabaseProvider` from `lib/essentials/db/feature_level_providers.dart`.
- `db-import`: `sqfliteImportDatabaseProvider` for retained archive-source metadata.
- `db-working`: no central app provider; retained file/schema storage only.
- `db-overlay`: `overlayDatabaseProvider` (generated from `overlayDatabase`).

## When to Touch What

| Need | Database(s) | Notes |
| --- | --- | --- |
| Inspect raw macOS Contacts | `db-address-book` | Only via provider overrides in tooling/tests; ensure Full Disk Access. |
| Inspect raw macOS Messages | `db-chat` | Read-only; consumed by import/monitor infrastructure. |
| Verify production source-scoped import batches or schema diffs | `db-import-ss` | Treat as source-derived and importer-owned; agents must never mutate rows manually. |
| Debug app-visible graph state | `db-graph-working` | Graph projection backing ordinary app reads. Manual edits are overwritten by graph rebuild. |
| Inspect retained archive/recovery compatibility storage | `db-import` / `db-working` | Compatibility only; do not use as the authority for ordinary UI behavior. |
| Review manual overrides (handles, UI prefs) | `db-overlay` | Persistent user customizations. Follow overlay independence rules before editing. |

## Next References

- `03-db-address-book.md` — macOS AddressBook source database.
- `04-db-chat.md` — macOS Messages source database.
- `01-db-import.md` — Retained archive-source metadata and historical ledger details.
- `02-db-working.md` — Retained historical projection file details.
- `05-db-overlay.md` — Persistent user overrides and preferences.
- `06-addressbook-path-resolution.md` — Provider chain for locating the live AddressBook.
- `07-overlay-database-independence.md` — Non-negotiable rule set for overlay/working separation.
- `10-group-import-working.md` — Retained legacy import/working contract and source-scoped graph replacement note.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table schemas for all ledger/projection databases.
