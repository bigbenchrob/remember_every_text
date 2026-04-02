# Re-Import and Ongoing Sync

## Purpose

After initial onboarding completes, MessageLens stays current with the user's
Messages data through automatic polling and supports explicit re-import for
recovery scenarios.

## Auto-Sync: ChatDbChangeMonitor

### Mechanism

`ChatDbChangeMonitor` polls `~/Library/Messages/chat.db` every 15 seconds by
checking the file's modification timestamp.

**Location:** `lib/essentials/db_importers/application/monitor/`

### On Change Detected

1. Run incremental import (only new/changed rows)
2. Run incremental migration (project changes to working DB)
3. Run `archiveAllAvailable()` for any newly available attachments
4. Providers that watch the working DB update reactively

### User Experience

- New messages appear in the app within ~15–20 seconds of arrival in macOS Messages
- No user action required
- No visible indicator during sync (seamless background operation)

### Constraints

- Requires FDA to remain granted (monitored continuously)
- If `chat.db` is locked by another process, the poll retries on the next cycle
- The monitor starts after initial onboarding completes (not during first import)

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
  │   └─ Full import pipeline runs (same as first run)
  │   └─ Skips FDA gate (already granted)
  │   └─ No welcome preamble in overlay
  │
  ├─ status = reimportMigrating
  │   └─ Full migration pipeline runs
  │   └─ Working DB is rebuilt from scratch
  │   └─ archiveAllAvailable() runs after migration
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

- Re-import rebuilds `import.db` and `working.db` from scratch
- Overlay DB rows (archive metadata, user preferences, favorites, etc.)
  survive re-import because overlay is never touched by migration
- Archive files on disk are preserved — `archiveAllAvailable()` is additive
  and idempotent

## Archive Maintenance During Sync

Each auto-sync cycle maintains the living archive:

1. **New attachments:** Files that arrived since the last sync are archived
   if they are locally available and not already in the archive.

2. **Evicted files:** If a file was archived previously and Apple has since
   evicted the original, the archive copy remains valid. The resolution
   provider will find it via the overlay lookup.

3. **Re-downloaded files:** If Apple re-downloads a previously evicted file
   (e.g., user opened it in Messages.app), the Messages path becomes valid
   again. The resolution provider finds it at Step 1, and the archive copy
   also remains as a safety net.

## Relationship to Onboarding

| Phase | Sync mechanism | Archive behavior |
|-------|---------------|-----------------|
| First run | OnboardingGate → full import + migration | `archiveAllAvailable()` — bulk initial archive |
| Normal use | ChatDbChangeMonitor every 15 seconds | Incremental archive of new attachments |
| Re-import | Manual trigger from Settings | Full rebuild + `archiveAllAvailable()` |
| Historical recovery | User-initiated from Settings | Deterministic snapshot → archive |

## File Inventory

| File | Role |
|------|------|
| `lib/essentials/db_importers/application/monitor/chat_db_change_monitor.dart` | Poll-based auto-sync |
| `lib/essentials/db_importers/presentation/view_model/db_import_control_provider.dart` | Import progress and control |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | `startReimport()` trigger |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | `archiveAllAvailable()` |
