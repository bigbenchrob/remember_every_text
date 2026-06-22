---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-06-20
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
- **Production reads are graph-backed.** Ordinary app data flows through `db-import-ss` and `db-graph-working`; archive-source metadata now lives in `db-overlay`. Retired `db-import` and `db-working` files are transitional cleanup inventory for reset and diagnostics.
- **Overlay remains separate.** User intent lives in `db-overlay` and is merged at read time; no import/projection path may copy overlay intent into source-scoped graph tables or retired files.
- **Shut everything down before manual access.** Quit the Flutter app and tooling prior to backups or ad-hoc SQL to avoid WAL/locking surprises.

## Canonical Database Aliases

Use these aliases consistently across docs, code comments, and conversations.

| Alias | Physical File | Primary Purpose | Provider Entry Point | Storage Location |
| --- | --- | --- | --- | --- |
| `db-address-book` | `AddressBook-v22.abcddb` inside the most recent `/Library/Application Support/AddressBook/Sources/<UUID>/` | macOS contact source of truth | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` | Resolved dynamically at runtime |
| `db-chat` | `chat.db` | macOS Messages source ledger | `PathsHelper.messagesDatabasePath` (import pipeline) | `~/Library/Messages/chat.db` |
| `db-import-ss` | `macos_import_ss.db` | Production source-scoped import ledger for Messages + AddressBook facts | `importDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import_ss.db` |
| `db-graph-working` | `working_ss.db` | Production source-scoped conversation graph consumed by graph readers and Message Evidence Spine | `driftConversationGraphDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working_ss.db` |
| `db-import` | `macos_import.db` | Retired historical import cleanup file; old files may contain retained ledger tables | No central app provider; reset/diagnostics treat as retired cleanup inventory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db` |
| `db-working` | `working.db` | Retired historical projection file/schema inventory | No central app provider; reset/diagnostics treat as retired cleanup inventory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db` |
| `db-overlay` | `user_overlays.db` | Long-lived user overrides and preferences | `overlayDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/user_overlays.db` |

## Coupled Database Groups

- **`group-source-scoped-graph-db`**: `db-import-ss` and `db-graph-working` are the production source-scoped graph pipeline. Source data lands in the import ledger, then graph projectors translate it into canonical `ss_id` rows and topology.
- **`group-retired-import-working-db`**: `db-import` and `db-working` are retired storage references, not an active pipeline. Old retained files may be inspected read-only by diagnostics or removed by reset cleanup. Do not use this group for new ordinary app reads or archive-source metadata writes.

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
- `db-import`: no central app provider remains; retired transitional cleanup file only.
- `db-working`: no central app provider remains; retired transitional cleanup file only.
- `db-overlay`: `overlayDatabaseProvider` (generated from `overlayDatabase`) for user intent and archive-source metadata.

## When to Touch What

| Need | Database(s) | Notes |
| --- | --- | --- |
| Inspect raw macOS Contacts | `db-address-book` | Only via provider overrides in tooling/tests; ensure Full Disk Access. |
| Inspect raw macOS Messages | `db-chat` | Read-only; consumed by import/monitor infrastructure. |
| Verify production source-scoped import batches or schema diffs | `db-import-ss` | Treat as source-derived and importer-owned; agents must never mutate rows manually. |
| Debug app-visible graph state | `db-graph-working` | Graph projection backing ordinary app reads. Manual edits are overwritten by graph rebuild. |
| Inspect retired historical cleanup storage | `db-import` / `db-working` | Diagnostics/cleanup only; do not use as the authority for ordinary UI behavior or archive-source metadata. |
| Review manual overrides (handles, UI prefs) | `db-overlay` | Persistent user customizations. Follow overlay independence rules before editing. |

## Next References

- `03-db-address-book.md` — macOS AddressBook source database.
- `04-db-chat.md` — macOS Messages source database.
- `01-db-import.md` — Retired import file and historical ledger details.
- `02-db-working.md` — Retired historical projection file details.
- `05-db-overlay.md` — Persistent user overrides and preferences.
- `06-addressbook-path-resolution.md` — Provider chain for locating the live AddressBook.
- `07-overlay-database-independence.md` — Non-negotiable rule set for overlay/working separation.
- `10-group-import-working.md` — Retired import/working contract and source-scoped graph replacement note.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table schemas for all ledger/projection databases.
