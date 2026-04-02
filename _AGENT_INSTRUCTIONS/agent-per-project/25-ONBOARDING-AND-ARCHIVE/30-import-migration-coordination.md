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
| Attachment archiving (post-migration) | attachments feature | `lib/features/attachments/` |

**Rule:** Onboarding calls `startImportAndMigration()` which triggers the
import orchestrator, then the migration orchestrator, then the archive service.
It does not implement any of those pipelines.

## Pipeline Sequence

```
OnboardingGate.startImportAndMigration()
  │
  ├─ 1. Import Phase
  │   └─ ImportOrchestrator.run()
  │       Topological order (Kahn's algorithm):
  │       prepare_sources → handles → chats → messages →
  │       attachments → message_attachments → contacts →
  │       message_rich_text (Rust FFI) → reactions →
  │       contact_channels → chat_to_handle →
  │       contact_to_chat_handle → clear_ledger
  │
  │       Each importer: validatePrereqs → copy → postValidate
  │       Source: ~/Library/Messages/chat.db (FDA-gated)
  │       Target: ./macos_import.db
  │
  ├─ 2. Migration Phase
  │   └─ MigrationOrchestrator.run()
  │       Topological order:
  │       handles (dedup) → participants → chats → messages →
  │       attachments → reactions → message_read_marks →
  │       reaction_counts → app_settings → read_state →
  │       handle_to_participant → projection_state
  │
  │       Each migrator: validatePrereqs → copy → postValidate
  │       Source: ./macos_import.db
  │       Target: ./working.db
  │
  │       attachment_migrator triggers archive copy for each
  │       migrated attachment (if archive mode enabled)
  │
  ├─ 3. Archive Phase
  │   └─ AttachmentArchiveService.archiveAllAvailable()
  │       Bulk-copies all locally available image attachments
  │       into content-addressable storage
  │       Source: ~/Library/Messages/Attachments/
  │       Target: ./attachment_archive/
  │       Metadata: overlay DB archived_attachments table
  │
  └─ 4. Completion
      └─ OnboardingGate sets status = complete
          Persists result to overlay DB
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
3. The same pipeline runs, but the overlay skips the FDA gate and welcome preamble
4. Existing working DB data is rebuilt from scratch (migration is a full projection)
5. Archive rows in overlay are additive — existing entries survive

## Auto-Sync Integration

After initial onboarding completes, `ChatDbChangeMonitor` takes over:

- Polls `~/Library/Messages/chat.db` modification timestamp every 15 seconds
- On change: runs incremental import + migration
- Archive service processes newly available attachments
- No user interaction required

See [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) for
details.
