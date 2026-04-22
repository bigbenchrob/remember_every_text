# Import and Migration Coordination

## Purpose

Onboarding orchestrates the startup pipeline but does not own the import or
migration systems. This document describes how the three systems interact.

## Ownership Boundaries

| System | Owner | Location |
|--------|-------|----------|
| Bootstrap gate and user-facing status | Onboarding | `lib/essentials/onboarding/` |
| Table importers and import orchestration | db_importers | `lib/essentials/db_importers/` |
| Table migrators and migration orchestration | db_migrate | `lib/essentials/db_migrate/` |
| Attachment archiving and recovery | attachments feature | `lib/features/attachments/` |

**Rule:** `OnboardingGate` delegates to `DbImportControlViewModel`, which
triggers the import and migration services. Onboarding does not implement
those pipelines.

## Pipeline Sequence

```
OnboardingGate.startImportAndMigration()
  │
  ├─ 1. Import Phase
  │   └─ ImportOrchestrator.run()
  │       Topological order (Kahn's algorithm):
  │       Derived from TableImporter.dependsOn at runtime.
  │       Current importer set:
  │       prepare_sources, clear_ledger, handles, chats,
  │       chat_to_handle, contacts, contact_phone_email,
  │       contact_to_chat_handle, messages, message_rich_text,
  │       chat_to_message, attachments, message_attachments
  │
  │       Each importer: validatePrereqs → copy → postValidate
  │       Source: ~/Library/Messages/chat.db (FDA-gated)
  │       Target: ./macos_import.db
  │
  ├─ 2. Migration Phase
  │   └─ MigrationOrchestrator.run()
  │       Topological order:
  │       Derived from TableMigrator.dependsOn at runtime.
  │       Current migrator set:
  │       handles, chats, chat_to_handle, participants,
  │       handle_to_participant, messages,
  │       recovered_unlinked_messages, attachments,
  │       recovered_unlinked_attachments, reactions,
  │       reaction_counts, message_read_marks, read_state
  │
  │       Each migrator: validatePrereqs → copy → postValidate
  │       Source: ./macos_import.db
  │       Target: ./working.db
  │
  │       Post-orchestrator synthetic steps rebuild working indexes
  │       and search indexes.
  │
  ├─ 3. Archive Maintenance
  │   └─ DbImportControlViewModel launches
  │       AttachmentArchiveService.archiveAllAvailable()
  │       after successful full migration. It is fire-and-forget
  │       and respects the archive-enabled setting.
  │
  └─ 4. Completion
      └─ OnboardingGate sets status = complete
          Import/migration results are persisted by DbImportControlViewModel
          Overlay shows summary
```

## Progress Reporting

The import and migration orchestrators report progress via callbacks that
onboarding maps to its UI:

- Current table name and phase (validating/copying/verifying)
- Row counts per table
- Duration per table
- Overall progress percentage

The `DbImportControlProvider` exposes a `UiStageProgress` list that the
onboarding progress view consumes directly.

## Failure Handling

| Failure | Behavior |
|---------|----------|
| Import table fails validation | Import aborts, result persisted, status → `awaitingUserAction` |
| Import succeeds, migration fails | Migration result persisted, status → `awaitingUserAction` |
| User clicks retry | Full pipeline re-runs from import phase |
| App crashes mid-pipeline | On next launch, failure history detected, user sees retry option |
| Stale partial import/working DB state detected | `OnboardingGate` enters `recoveringFailedAttempt`, resets app-owned DBs, then returns to `awaitingUserAction` |

**Persistence:** Results are stored as JSON in the overlay DB `OverlaySettings`
table, surviving app restarts.

## Database Topology

```
Source (read-only)         App-owned (read/write)        App-owned (user intent)
─────────────────          ──────────────────────        ───────────────────────
~/Library/Messages/        ./macos_import.db             ./user_overlays.db
  chat.db            ───→    (import target)        ───→   (overlay DB)
                               │                           │
~/Library/Application          │                           │
  Support/.../                 ▼                           │
  AddressBook-*        ──→  ./working.db            ◄──────┘
    (contacts)              (migration target)        (merged at read time)
```

**Key:** Import writes to `import.db`. Migration reads `import.db`, writes
`working.db`. Archive service writes to `overlay.db` and the filesystem
archive folder. Providers merge `working + overlay` at read time.

## Re-Import Flow

When a user triggers re-import from Settings:

1. `OnboardingGate.startReimport()` is called
2. Status transitions: `reimporting` → `reimportMigrating` → `reimportComplete`
3. The same import/migration control pipeline runs with reimport-specific overlay status
4. The import ledger is deleted first; full migration rebuilds working tables from the import projection
5. Archive rows in overlay are additive — existing entries survive

## Auto-Sync Integration

After initial onboarding completes, `ChatDbChangeMonitor` keeps the app current:

- Primes from the max imported message ROWID and checks startup catch-up.
- Polls `MAX(ROWID)` in `~/Library/Messages/chat.db` every 15 seconds.
- On change: runs incremental import.
- Archives the imported batch before incremental migration.
- Runs incremental migration and bumps `messageDataVersionProvider` on success.
- Runs a periodic working-attachment sweep every 5 minutes for attachments
  that become locally available later.
- No user interaction required

See [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) for
details.
