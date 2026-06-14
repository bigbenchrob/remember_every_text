# Living Attachments Archive Checklist

## Current Conformance Note (2026-06-06)

This checklist records the original living-archive implementation path. Current
follow-up work should keep archive metadata overlay-owned while integrating
through graph attachment evidence and shared message rendering.

Current graph-era implementation has also split archive responsibilities behind
named attachment-feature ports:

- `AttachmentArchiveService` owns archive orchestration and policy flow only.
- Graph candidate reads belong behind `GraphAttachmentArchiveCandidateReader`.
- Archive record/recovery hint/integrity-row writes belong behind
  `AttachmentArchiveWriteStore`.
- Sweep cursor/status persistence belongs behind `AttachmentArchiveSettingsStore`.
- Filesystem copy/hash/existence/integrity work belongs behind
  `AttachmentArchiveFileStore`.

Do not use this historical checklist to reintroduce direct graph DB, overlay DB,
or filesystem work inside the archive service.

## Phase 0 — Planning

- [x] Capture seed concept from developer notes
- [x] Review seed against project architecture rules
- [x] Write formal proposal with overlay/working DB separation
- [x] Write design notes with domain model and schema
- [x] Write phased checklist
- [x] Write test plan
- [x] User sign-off on proposal

## Phase 1A — Overlay Schema and Archive Directory

- [x] Add `archived_attachments` table to overlay database Drift schema
- [x] Add migration for new overlay table
- [x] Create `AttachmentArchiveDirectory` service for managing archive path
- [x] Initialize archive directory under Application Support at app startup
- [x] Add archive directory path provider
- [ ] Verify overlay table creation on fresh app launch and on existing DB

## Phase 1B — Domain Model

- [x] Add `cloudOnly` variant to `AttachmentStatus` enum
- [x] Define `AttachmentAvailability` enum (available, cloudOnly, missing)
- [x] Define `AttachmentProvenance` enum (messagesLive, archived, importedHistorical)
- [x] Define `ResolvedAttachment` freezed class
- [x] Define `ArchivedAttachmentRecord` entity for overlay table rows
- [x] Run build_runner for code generation

## Phase 1C — Resolution Provider

- [x] Implement `attachmentResolverProvider` with multi-source pipeline
- [x] Pipeline step 1: check Messages local path
- [x] Pipeline step 2: check overlay archive record and archive file
- [x] Pipeline step 3: report cloudOnly or missing
- [x] Ensure provider caches results per attachment naturally
- [x] Remove inline `existsSync()` calls from `ImageMessageTile`
- [x] Remove inline `existsSync()` calls from `VideoMessageTile`
- [x] Wire message tiles to consume resolution provider

## Phase 1D — Archiving Service

- [x] Implement `AttachmentArchiveService` with `archiveAttachment` method
- [x] Content-addressable file copy (sha256 prefix/name)
- [x] Fallback to importAttachmentId when sha256Hex is null
- [x] Idempotent check (skip if overlay record already exists)
- [x] Implement import-time archiving hook after migration completes
- [x] Scope to `image/*` mime types only for Phase 1
- [x] Implement on-demand archiving trigger in resolution provider
- [x] Background file operations (do not block UI thread)

## Phase 1E — UI: State-Aware Placeholders

- [x] Replace "Image unavailable" with `cloudOnly` placeholder widget
- [x] Replace "Video unavailable" with `cloudOnly` placeholder widget
- [x] Add "Stored in iCloud — not downloaded to this Mac" messaging
- [x] Add "Attachment not available locally" for missing state
- [ ] Add optional "Open in Messages" action for cloudOnly attachments
- [ ] Add loading/shimmer placeholder during resolution

## Phase 1F — Settings Integration

- [x] Add archive enable/disable toggle to Settings panel
- [x] Persist archive-enabled preference in overlay DB or app preferences
- [x] Display current archive size (computed from directory)
- [x] Display number of archived attachments (count from overlay table)
- [x] Add "Clear Archive" action with confirmation dialog
- [x] Guard archiving service behind the enabled toggle

## Phase 1G — Validation

- [x] Run analyzer — zero warnings
- [x] Run all existing tests — no regressions
- [ ] Run new unit tests for resolution pipeline
- [ ] Run new provider tests for archive service
- [ ] Manual test: image renders from Messages path (live local)
- [ ] Manual test: image renders from archive after Messages eviction
- [ ] Manual test: cloudOnly state displays correctly
- [ ] Manual test: settings toggle enables/disables archiving
- [ ] Manual test: archive size and count display correctly

## Phase 2 — Historical Import

- [x] Design folder-selection UI for Time Machine recovery
- [x] Implement folder walker with hash computation
- [x] Match recovered files to known attachment records
- [x] Copy matched files into content-addressable archive
- [x] Create overlay records with provenance: imported_historical
- [x] Report results to user (matched, unmatched, total size)

## Phase 3 — Extended Media Types

- [x] Extend archiving scope to video attachments
- [x] Extend to other attachment types (opt-in)
- [x] Implement storage budget enforcement
- [x] Implement retention policy options

## Nice-To-Have Follow-Ups

- [x] Progress indicator for large initial archiving operations
- [x] Pause/resume archiving
- [x] "Open in Messages" deep link for cloud-only attachments
- [x] Archive integrity verification (hash check)
- [x] Archive export/backup utility
- [x] Automatic re-archive after iCloud re-download detected
