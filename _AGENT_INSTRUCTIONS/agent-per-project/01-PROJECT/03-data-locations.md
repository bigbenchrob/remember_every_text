---
tier: project
scope: data
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: code
links:
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../10-DATABASES/01-db-import.md
  - ../10-DATABASES/02-db-working.md
  - ../10-DATABASES/05-db-overlay.md
  - ../10-DATABASES/06-addressbook-path-resolution.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
tests: []
---

# Data Locations

This page lists runtime paths only. Schema, lifecycle, and access rules belong
in `../10-DATABASES/` and `../20-DATA-IMPORT-MIGRATION/`.

## MessageLens Runtime Data

The production macOS bundle stores runtime app data under:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens/
```

Current app-owned files/directories include:

| Data | Path | Owner |
| --- | --- | --- |
| Import ledger | `macos_import.db` | `sqfliteImportDatabaseProvider`, import pipeline |
| Working projection | `working.db` | `driftWorkingDatabaseProvider`, migration pipeline |
| Overlay database | `user_overlays.db` | `overlayDatabaseProvider`, user-intent services |
| Attachment archive | `attachment_archive/` | Attachment archive service |
| Import audit log | `import_log` | Import audit writer |
| Migration audit log | `migrate_log` | Migration audit writer |

The repository folder may still be named `remember_every_text`; do not confuse
the repo path with runtime storage paths.

## macOS Source Files

| Source | Path | Access rule |
| --- | --- | --- |
| Messages | `~/Library/Messages/chat.db` | Read-only through import/monitor infrastructure. Requires Full Disk Access. |
| AddressBook | `~/Library/Application Support/AddressBook/Sources/<UUID>/AddressBook-v22.abcddb` | Resolve through `getFolderAggregateEitherProvider`; never hardcode the UUID. |
| Messages attachments | `~/Library/Messages/Attachments/...` | Read-only source for attachment archiving/resolution; MessageLens never writes back here. |

## Backup Wording

The database providers do not own a nightly backup system. If a developer or
deployment environment configures external backups, treat that as operational
infrastructure outside the app code.

Do not document `~/sqlite_rmc/backups` as guaranteed app behavior unless code or
deployment automation in this repository owns that behavior.

## Manual SQL Rules

- Shut down the Flutter app and any tooling before opening SQLite files manually.
- Use the centralized providers from app code; direct extra SQLite connections
  can lock files.
- Never manually mutate `macos_import.db`, `working.db`, or `user_overlays.db`
  as a substitute for importer, migrator, or overlay service behavior.

## Schema References

- Import DB: `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart`
- Working DB: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`
- Overlay DB: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
- High-level summaries: `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`
