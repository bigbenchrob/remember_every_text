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
- **Persistent app DB instances are centralized.** Long-lived application
  databases must be constructed only through Riverpod providers exported by
  `lib/essentials/db/feature_level_providers.dart`; implementation lives in
  named files under `lib/essentials/db/feature_level_providers/`.
  Infrastructure repositories
  may open source/probe SQLite files directly only for named one-off
  read-only queries, and must close/dispose the connection before returning.
  Extra persistent connections will lock app database files.
- **Path access uses the paths seam.** Code that needs `PathsHelper` should
  import `pathsHelperProvider` from
  `lib/essentials/paths/feature_level_providers.dart`, not the root
  `providers.dart` barrel. The root provider barrel is retired; add or consume
  owned essential seams instead.
- **Physical file identity stays explicit.** Database file names and app
  database paths are centralized in `lib/essentials/db/app_database_files.dart`.
  The mutable Application Support directory primitive lives in
  `lib/essentials/db/database_directory.dart` for bootstrap, lifecycle, reset,
  support, and diagnostics only. Do not re-export or import it through
  `feature_level_providers.dart`; likewise, do not re-export file-name/path
  helpers through that seam. `feature_level_providers.dart` is for provider
  access, not physical file identity convenience.
- **Production reads are graph-backed.** Ordinary app data flows through `db-import-ss` and `db-graph-working`; archive-source metadata now lives in `db-overlay`. Retired `db-import` and `db-working` files are transitional cleanup inventory for reset and diagnostics.
- **Overlay remains separate.** User intent lives in `db-overlay` and is merged at read time; no import/projection path may copy overlay intent into source-scoped graph tables or retired files.
- **Shut everything down before manual access.** Quit the Flutter app and tooling prior to backups or ad-hoc SQL to avoid WAL/locking surprises.

## Canonical Database Aliases

Use these aliases consistently across docs, code comments, and conversations.

| Alias | Physical File | Primary Purpose | Provider Entry Point | Storage Location |
| --- | --- | --- | --- | --- |
| `db-address-book` | `AddressBook-v22.abcddb` inside the most recent `/Library/Application Support/AddressBook/Sources/<UUID>/` | macOS contact source of truth | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` | Resolved dynamically at runtime |
| `db-chat` | `chat.db` | macOS Messages source ledger | `pathsHelperProvider` from `lib/essentials/paths/feature_level_providers.dart` → `PathsHelper.messagesDatabasePath` (import pipeline) | `~/Library/Messages/chat.db` |
| `db-import-ss` | `macos_import_ss.db` | Production source-scoped import ledger for Messages + AddressBook facts | Public access: `sourceScopedImportDatabaseProvider` exported by `lib/essentials/db/feature_level_providers.dart`; physical construction implemented in `persistent_database_providers.dart`; ordinary import semantics: `sourceScopedImportLedgerProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import_ss.db` |
| `db-graph-working` | `working_ss.db` | Production source-scoped conversation graph consumed by graph readers and Message Evidence Spine | `driftConversationGraphDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working_ss.db` |
| `db-import` | `macos_import.db` | Retired import cleanup file; old files may contain historical ledger tables | No central app provider; reset/diagnostics treat as retired cleanup inventory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db` |
| `db-working` | `working.db` | Retired working cleanup file/schema inventory | No central app provider; reset/diagnostics treat as retired cleanup inventory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/working.db` |
| `db-overlay` | `user_overlays.db` | Long-lived user overrides and preferences | `overlayDatabaseProvider` | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/user_overlays.db` |

## Coupled Database Groups

- **`group-source-scoped-graph-db`**: `db-import-ss` and `db-graph-working` are the production source-scoped graph pipeline. Source data lands in the import ledger, then graph projectors translate it into canonical `ss_id` rows and topology.
- **`group-retired-import-working-db`**: `db-import` and `db-working` are retired storage references, not an active pipeline. Old retired files may be inspected read-only by diagnostics or removed by reset cleanup. Do not use this group for new ordinary app reads or archive-source metadata writes.

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
- `db-chat`: retrieved via `pathsHelperProvider` / `PathsHelper` inside
  import/monitor infrastructure; feature and presentation code must not open it
  directly or import the root `providers.dart` barrel just to resolve paths.
- `db-import-ss`: physical provider access is `sourceScopedImportDatabaseProvider` exported from `lib/essentials/db/feature_level_providers.dart`; physical construction is implemented in `lib/essentials/db/feature_level_providers/persistent_database_providers.dart`. Source-scoped import semantics should consume `sourceScopedImportLedgerProvider` unless a graph projection/repository explicitly needs the concrete import database.
- `db-graph-working`: `driftConversationGraphDatabaseProvider` from `lib/essentials/db/feature_level_providers.dart`.
- `db-import`: no central app provider remains; retired transitional cleanup file only.
- `db-working`: no central app provider remains; retired transitional cleanup file only.
- `db-overlay`: `overlayDatabaseProvider` (generated from `overlayDatabase`) for user intent and archive-source metadata.

## Concrete Import-Ledger Provider Access

`sourceScopedImportDatabaseProvider` is a physical DB provider, not a general
feature dependency. Direct access is limited to:

- the central DB provider implementation that constructs it;
- the semantic `sourceScopedImportLedgerProvider` bridge;
- reset, health, and status diagnostics;
- graph projection repository composition, where import-ledger rows are joined
  into the graph projection;
- archive attachment snapshot boundaries that need current source-scoped
  attachment facts.

Ordinary import services, graph readers, feature providers, widgets, and
presentation code should consume semantic ports, repository providers, or
`sourceScopedImportLedgerProvider` instead of reaching for the concrete
physical provider.

## Persistent vs One-Off Database Access

- Persistent DB instances: import ledger, conversation graph, overlay, and any
  future long-lived app database must be physically constructed in named files
  under `lib/essentials/db/feature_level_providers/` and exported by
  `lib/essentials/db/feature_level_providers.dart`.
- One-off source/probe reads: infrastructure repositories may open `chat.db`,
  AddressBook candidates, historical archive `chat.db` files, or retired
  cleanup files for a named read-only query. They must set read-only/query-only
  mode where practical, return typed results, and close/dispose the handle in a
  `finally` block.
- Presentation, application orchestration, feature widgets, and ordinary
  read-model code must never open database files directly.

## When to Touch What

| Need | Database(s) | Notes |
| --- | --- | --- |
| Inspect raw macOS Contacts | `db-address-book` | Only via provider overrides in tooling/tests; ensure Full Disk Access. |
| Inspect raw macOS Messages | `db-chat` | Read-only; consumed by import/monitor infrastructure. |
| Verify production source-scoped import batches or schema diffs | `db-import-ss` | Treat as source-derived and importer-owned; agents must never mutate rows manually. |
| Debug app-visible graph state | `db-graph-working` | Graph projection backing ordinary app reads. Manual edits are overwritten by graph rebuild. |
| Inspect retired cleanup/diagnostic storage | `db-import` / `db-working` | Diagnostics/cleanup only; do not use as the authority for ordinary UI behavior or archive-source metadata. |
| Review manual overrides (handles, UI prefs) | `db-overlay` | Persistent user customizations. Follow overlay independence rules before editing. |

## Next References

- `03-db-address-book.md` — macOS AddressBook source database.
- `04-db-chat.md` — macOS Messages source database.
- `01-db-import.md` — Retired import file and historical ledger details.
- `02-db-working.md` — Retired working cleanup file details.
- `05-db-overlay.md` — Persistent user overrides and preferences.
- `06-addressbook-path-resolution.md` — Provider chain for locating the live AddressBook.
- `07-overlay-database-independence.md` — Non-negotiable rule set for overlay/working separation.
- `10-group-import-working.md` — Retired import/working contract and source-scoped graph replacement note.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table schemas for all ledger/projection databases.
