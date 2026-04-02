# Onboarding and Archive — Evolution Overview

## How We Got Here

The onboarding system in MessageLens has evolved through four distinct phases,
each driven by real-world user problems. This document traces that evolution
and explains why each layer exists.

---

## Phase 1: Simple Bootstrap Gate

**Problem:** First-run users saw a blank app with no data and no guidance.

**Solution:** A startup gate that answered two questions:

1. Can the app read `~/Library/Messages/chat.db`? (Full Disk Access check)
2. Do the app-owned databases (`macos_import.db`, `working.db`) exist and
   contain data?

If either check failed, the app presented a modal overlay with a stepper UI
that guided the user through:

- Granting Full Disk Access in System Settings
- Starting the initial import of Messages and Contacts data
- Waiting for migration to project imported data into the working database

This was implemented as `OnboardingGate` in `lib/essentials/onboarding/`,
rendering an `OnboardingOverlay` that blocked the main app UI until bootstrap
completed.

**Key code:**

| File | Role |
|------|------|
| `onboarding_gate_provider.dart` | State machine tracking 9 lifecycle states |
| `onboarding_overlay.dart` | Full-window blocking overlay |
| `onboarding_progress_view.dart` | Live progress bars during import/migration |
| `database_existence_checker.dart` | Filesystem-only DB presence check |
| `fda_checker.dart` | FDA probe via `File.openSync()` on `chat.db` |

**Architectural rule:** Onboarding coordinates and presents. Import logic
stays in `db_importers`, migration logic stays in `db_migrate`. Onboarding
never owns those pipelines.

---

## Phase 2: Comprehensive Environment Evaluation

**Problem:** Field testers reported being stranded at launch with ambiguous
error states. The two-question gate could not distinguish between:

- FDA missing
- Messages database exists but is empty (this Mac not syncing)
- AddressBook path resolution failing
- Import succeeded but migration failed
- Databases exist but are stale or corrupt
- Pipeline errors masquerading as permission problems

**Solution:** An environment evaluation layer that produces a structured
readiness report before and during bootstrap. The report evaluates:

- Messages database readability and content richness
- AddressBook database readability and path resolution
- Presence and health of import and working databases
- Last import/migration result (persisted in overlay DB)
- Sync plausibility — whether this Mac appears to have meaningful local
  Messages history

This was implemented as `OnboardingEnvironmentReportProvider`, which probes the
environment and classifies the result into user-facing states:

| State | Meaning |
|-------|---------|
| `permissionBlocked` | FDA not granted |
| `sourceUnavailable` | `chat.db` or AddressBook not found |
| `sourceSparseOrUnsynced` | Source exists but has very little data |
| `readyToImport` | Sources healthy, app databases empty |
| `importing` | Import pipeline in progress |
| `importFailed` | Last import attempt failed |
| `migrating` | Migration pipeline in progress |
| `migrationFailed` | Last migration attempt failed |
| `ready` | App databases populated and healthy |

**Enhancement path:** The proposal for an environment readiness center panel
(see `45-NEW-FEATURE-ADDITION/enhanced-onboarding-readiness-panel/`) would
move this from an overlay model to a first-class ViewSpec-driven center-panel
surface. That work is not yet complete.

---

## Phase 3: Living Attachments Archive

**Problem:** A user's Messages Attachments folder shrank from 42 GB to 6 GB
overnight. Apple's storage optimization had silently evicted local attachment
files to iCloud. The database records in `chat.db` still referenced every
attachment, but the files were gone. MessageLens rendered "Image unavailable"
for the majority of image messages.

**Root cause:** macOS treats `~/Library/Messages/Attachments` as a volatile
cache. When Messages in iCloud is active with storage optimization, Apple
evicts files to free disk space. Apple Messages can re-download on demand;
MessageLens cannot.

**Solution:** A MessageLens-managed attachment archive that:

1. **Copies locally available attachment files at import time** into app-owned
   content-addressable storage
2. **Models availability state explicitly** (`available`, `cloudOnly`, `missing`)
   rather than treating missing files as broken
3. **Resolves attachments through a multi-source pipeline** — Messages path
   first, then archive, then cloud-only status
4. **Stores archive metadata in the overlay database** — the working database
   remains a pure projection of `chat.db`

Archive storage uses SHA-256 content addressing:
```
attachment_archive/
└── {first-2-chars-of-hash}/
    └── {full-sha256}.{original-extension}
```

The archive is initialized during the first migration cycle and maintained
automatically on every subsequent import/migration and by the auto-sync
monitor.

See [`40-attachment-archive.md`](40-attachment-archive.md) for full
architectural details.

---

## Phase 4: Deterministic Historical Recovery

**Problem:** The initial attempt to recover files from a Time Machine backup
of the Attachments folder used heuristic matching (path-tail coincidence,
SHA-256 hash comparison). Forensic analysis proved this approach fundamentally
broken:

- Sent-attachment directory conventions (`at_0_` GUID prefix) change between
  historical and current `chat.db`, breaking path-tail matching
- `sha256_hex` is frequently NULL in the working database, disabling
  hash-based matching
- Common filenames (e.g. `IMG_1234.jpeg`) create false-positive ambiguity
- Real-world success rate: ~40%

**Solution:** Replace heuristic matching with a deterministic three-layer
mapping flow using a matched historical `chat.db` snapshot:

1. **Historical snapshot DB** provides authoritative message↔attachment
   relationships via SQL joins (not filesystem heuristics)
2. **Current import DB** bridges Apple's `attachment.guid` to the runtime
   `import_attachment_id`
3. **Working DB + overlay** receives archive rows with provenance
   `imported_historical_snapshot`

Primary match: `attachment.guid` → import DB → working DB identity.
Single-attachment fallback: when GUID is NULL and exactly one attachment
exists on both sides.
No further fallback: no path-tail, transfer_name, or ordinal matching.

See [`50-deterministic-recovery.md`](50-deterministic-recovery.md) for full
mapping logic and edge cases.

---

## Current State

The onboarding pipeline today works as follows:

1. **App launches** → `OnboardingGate` evaluates environment via
   `OnboardingEnvironmentReportProvider`
2. **FDA gate** → if blocked, overlay shows FDA instructions with
   "Open System Settings" action
3. **Data gate** → if databases are empty, overlay shows "Import" button
4. **Import** → `ImportOrchestrator` runs topologically-ordered table importers
5. **Migration** → `MigrationOrchestrator` projects imported data into
   working DB; attachment migrator triggers archive service
6. **Archive initialization** → `archiveAllAvailable()` copies all locally
   available image files into content-addressable storage
7. **Completion** → overlay shows summary, user clicks "Get Started"
8. **Ongoing** → `ChatDbChangeMonitor` polls `chat.db` every 15 seconds,
   auto-importing new messages and maintaining the archive

Historical recovery from a backup snapshot is available as a separate
user-initiated flow via the Settings panel.
