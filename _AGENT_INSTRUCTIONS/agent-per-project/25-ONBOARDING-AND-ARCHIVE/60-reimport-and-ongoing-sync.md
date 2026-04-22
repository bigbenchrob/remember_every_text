# Re-Import and Ongoing Sync

## Purpose

After initial onboarding completes, MessageLens stays current with the user's
Messages data through automatic polling and supports explicit re-import for
recovery scenarios.

## Auto-Sync: ChatDbChangeMonitor

### Mechanism

`ChatDbChangeMonitor` polls `~/Library/Messages/chat.db` every 15 seconds by
reading source `MAX(ROWID)` from the `message` table. On startup it primes
from the import ledger's max imported message row ID when available, then runs
an immediate catch-up check before periodic polling begins.

**Location:** `lib/essentials/db_importers/application/monitor/`

### On Change Detected

1. Run incremental import.
2. Archive the imported batch with `archiveImportedBatch(batchId:)`.
3. Run incremental migration.
4. Bump `messageDataVersionProvider` so data-dependent providers rebuild.

In parallel with message polling, the monitor also runs a 5-minute attachment
maintenance sweep with `archiveNextWorkingSweepChunk()`.

### User Experience

- New messages appear after the polling/debounce/import/migration cycle
- No user action required
- No visible indicator during normal sync; errors are logged in monitor state

### Constraints

- Requires FDA to remain granted for source reads
- If `chat.db` is locked by another process, the poll retries on the next cycle
- The monitor initializes on macOS and is meaningful after import data exists
- It uses a debounce and in-flight guard so overlapping probes coalesce

## Manual Re-Import

### Trigger

User navigates to Settings and clicks "Re-scan & Import."

### Flow

```
Settings → "Re-scan & Import"
  │
  ├─ OnboardingGate.startReimport()
  │
  ├─ status = reimporting
  │   └─ Full import pipeline runs through DbImportControlViewModel
  │   └─ No separate readiness gate is shown
  │   └─ No welcome preamble in overlay
  │
  ├─ status = reimportMigrating
  │   └─ Full migration pipeline runs
  │   └─ Working tables are rebuilt from the import projection
  │   └─ archiveAllAvailable() is launched after successful migration
  │
  └─ status = reimportComplete
      └─ Summary shown, "Done" button
```

### Why Re-Import?

Common reasons a user might re-import:

- AddressBook updated with new contacts
- Suspected data integrity issue
- Recovery from a partially failed previous import
- After restoring macOS from backup

### Data Safety

- Re-import deletes the import ledger first, then full migration rebuilds
  working tables from the current import projection
- Overlay DB rows (archive metadata, user preferences, favorites, etc.)
  survive re-import because overlay is never touched by migration
- Archive files on disk are preserved — `archiveAllAvailable()` is additive
  and idempotent

## Archive Maintenance During Sync

Each auto-sync cycle maintains the living archive:

1. **New attachments:** Imported-batch files are archived before incremental
   migration when locally available and not already in the archive.

2. **Evicted files:** If a file was archived previously and Apple has since
   evicted the original, the archive copy remains valid. The resolution
   provider will find it via the overlay lookup.

3. **Re-downloaded files:** If Apple re-downloads a previously evicted file
   (e.g., user opened it in Messages.app), the Messages path becomes valid
   again. In archive-enabled mode the resolver can trigger on-demand archive
   ingestion, and the periodic sweep can archive it later.

## Relationship to Onboarding

| Phase | Sync mechanism | Archive behavior |
|-------|---------------|-----------------|
| First run | OnboardingGate → full import + migration | `archiveAllAvailable()` — bulk initial archive |
| Normal use | ChatDbChangeMonitor every 15 seconds plus 5-minute sweep | Imported-batch archive, on-demand archive, and rolling working sweep |
| Re-import | Manual trigger from Settings | Full rebuild + `archiveAllAvailable()` |
| Historical recovery | User-initiated from Settings | Deterministic snapshot → archive |

## File Inventory

| File | Role |
|------|------|
| `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart` | Poll-based auto-sync and attachment sweep |
| `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart` | Import progress and control |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | `startReimport()` trigger |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | `archiveAllAvailable()`, `archiveImportedBatch()`, working sweeps |
