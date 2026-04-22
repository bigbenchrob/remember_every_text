---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-04-21
source_of_truth: doc
links:
      - ./02-import-migration-schema-reference.md
      - ./10-import-orchestrator.md
      - ./11-rust-message-extractor.md
      - ./20-migration-orchestrator.md
      - ./30-incremental-mode-flag.md
      - ../10-DATABASES/00-all-databases-accessed.md
tests: []
---

# Import ⟶ Migration Overview

This folder documents the end-to-end data pipeline that keeps MessageLens in sync with the macOS Messages and AddressBook sources. Use it as the starting point whenever you touch ledger ingestion, projection, archive coordination, search rebuilds, or the Rust helper binary.

## 🔥 Automatic Background Sync

**Imports are triggered automatically** — the app polls `chat.db` every **15 seconds** and runs import + migration when new messages are detected.

| Component | Purpose |
|-----------|---------|
| `ChatDbChangeMonitor` | Polls `MAX(ROWID)` from `chat.db`, triggers import on change |
| `ImportOrchestrator` | Runs table importers to stage new data in `macos_import.db` |
| `MigrationOrchestrator` | Projects ledger data into `working.db` (incremental mode) |
| `messageDataVersionProvider` | Bumped after successful incremental migration so UI providers refresh without closing Drift connections |
| `AttachmentArchiveService` | Archives new imported attachment batches before incremental migration and performs periodic maintenance sweeps |

**Result:** New messages appear in the UI within ~15-20 seconds of arrival without user action.

See `10-import-orchestrator.md` for detailed auto-polling documentation.

## High-Level Flow

```
chat.db + AddressBook.sqlite
            │
    ┌───────┴───────┐
    │ ChatDbChange  │ ← polls every 15s
    │    Monitor    │
    └───────┬───────┘
            │ (triggers on ROWID change)
            ▼
      ImportOrchestrator
            │ (per-table importers)
            ▼
     macos_import.db (ledger)
            │
            ▼
 attachment archive coordination
            │
            ▼
     MigrationOrchestrator
            │ (per-table migrators)
            ▼
      working.db (projection)
            │
            ▼
 overlay merge providers
```

- **Import phase** pulls raw data out of the system databases and stages it in `macos_import.db` without mutating the originals. Each table importer owns validation, copying, and post-flight checks for a single ledger table or tight table cluster.
- **Archive coordination** belongs to the attachment feature, not the importer or migrator. The automatic path archives the imported batch before incremental migration; full onboarding/manual migration launches `archiveAllAvailable()` after successful migration.
- **Migration phase** reads the ledger and constructs the UI-facing projection in `working.db`, preserving every identifier emitted by import. Migrators are sequenced so dependency ordering is enforced automatically.
- **Search/index rebuild** runs after orchestrated migration: working message indexes are rebuilt, triggers are recreated, then the search index orchestrator rebuilds search data.
- **Overlay providers** merge user overrides at runtime; they are documented in `../10-DATABASES/05-db-overlay.md` and operate strictly after projection.

## Responsibilities

| Concern | Owner | Document |
| --- | --- | --- |
| Table import sequencing, validation, logging | `ImportOrchestrator` | `10-import-orchestrator.md` |
| Rich text extraction for attributed bodies | Rust helper binary | `11-rust-message-extractor.md` |
| Projection + canonical ID preservation | `MigrationOrchestrator` | `20-migration-orchestrator.md` |
| Incremental mode for automatic sync | Migrators + MigrationContext | `30-incremental-mode-flag.md` |
| Schema expectations for both databases | Drift + Sqflite schema | `02-import-migration-schema-reference.md` |
| Attachment archive + deterministic recovery | Attachments feature + onboarding/archive docs | `../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md`, `../25-ONBOARDING-AND-ARCHIVE/50-deterministic-recovery.md` |

## Audit Logs

Every full or incremental pipeline run now writes two filesystem audit reports alongside the runtime databases:

- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log`
- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log`

Use these as the first stop when diagnosing import or projection anomalies. They capture:

- Source row counts from macOS `chat.db` and AddressBook
- Destination row counts in `macos_import.db` and `working.db`
- Rich-text extraction stats such as `messages.richTextApplied`
- Message text-presence counts before and after migration
- Source-vs-destination deltas that explain intentional JOIN-driven exclusions

## Current Source Reality: Chat-Orphan Messages

macOS `chat.db` can contain `message` rows that have no corresponding row in `chat_message_join`.

MessageLens now treats these source orphans as a first-class recovery path instead of silently leaving them outside the app's message model.

Current pipeline behavior:

- chat-linked source rows continue to flow into the normal `messages` ledger/projection path
- source orphan rows are preserved in dedicated recovered ledger tables
- recovered rich text and recovered attachment joins are preserved on that separate path
- migration projects them into dedicated recovered working-db tables rather than inventing a normal `chat_id`

Audit logs therefore now show both:

- the source orphan count from `chat.db`
- the preserved recovered-row count in ledger/projection tables

This distinction matters: a source-vs-thread-linked delta is no longer automatically equivalent to app-side invisibility.

## Recovered Context Reconstruction

The app's recovered browsing path deliberately separates **confirmed recovered rows** from **inferred nearby context**.

- confirmed rows are matched by surviving sender identity
- some outbound orphan rows preserve timing/content but lose handle identity
- contact-scoped recovered browsing can conservatively include nearby outgoing no-handle rows as best-guess context

This is an app-side recovery heuristic, not a claim that the source database proved original thread membership. Its purpose is to restore human-readable conversation meaning when Apple's visible thread graph no longer does.

## Operational Guardrails

- **Never bypass orchestrators.** Manual SQL shortcuts risk breaking the ID contracts that downstream providers rely on.
- **Do not edit ledger tables manually.** Full/reimport paths may clear and rebuild import ledger tables through `ClearLedgerImporter`; incremental paths preserve prior imported rows and add new source rows by high-water marks.
- **Run migration after every successful import batch.** Projection is disposable; rebuilding is cheaper than debugging drift.
- **Keep the Rust extractor available.** Without `extract_messages_limited` the majority of messages land without bodies, crippling search and UI rendering.
- **Use the correct migration mode for the entry point.** `ChatDbChangeMonitor` always calls `HandlesMigrationService.run(incrementalMode: true)` after a successful incremental import. Full onboarding/manual rebuild paths use `startMigration()` through the import control view model.
- **Do not invalidate the working DB connection after incremental migration.** The monitor bumps `messageDataVersionProvider`; Drift streams and provider refreshes must not be forced by closing `driftWorkingDatabaseProvider`.

## Runbook Snapshot

| Action | Command / Trigger | Notes |
| --- | --- | --- |
| **Automatic sync** | Always running | `ChatDbChangeMonitor` polls every 15s; no user action required. |
| Manual full import + migration | `flutter run` -> Import control panel | Only needed for initial setup or recovery. |
| Headless import | No current documented supported command | Use the app control panels unless a maintained tool is added. Older references to `tool/import.dart` are legacy. |
| Inspect latest batch | `sqlite3 macos_import.db 'SELECT * FROM import_batches ORDER BY started_at DESC LIMIT 1;'` | Confirms source paths, batch IDs, and row counts. |
| Inspect latest audit logs | Open `import_log` / `migrate_log` in app-support directory | Use before inspecting tables manually; logs already summarize row deltas, text counts, and extractor health. |
| Rerun migration only | `HandlesMigrationService` via maintained UI/provider entry point | Pass `incrementalMode` deliberately; automatic sync uses `true`, full rebuilds use `false`. |
| Force full migration | Set `incrementalMode: false` explicitly | Clears migrator target tables and rebuilds from the ledger. See `30-incremental-mode-flag.md`. |

## Related Reading

- `../10-DATABASES/10-group-import-working.md` - Contract binding import and projection.
- `../10-DATABASES/03-db-address-book.md` and `../10-DATABASES/04-db-chat.md` - Source database expectations.
- `../10-DATABASES/11-contact-to-chat-linking.md` - Verification path for participant linkage after migration.
