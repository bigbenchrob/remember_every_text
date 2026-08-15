---
tier: project
scope: attachment-preservation-safety-invariant
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code-and-canonical-invariant
links:
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ./21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - ./25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md
tests:
  - test/essentials/onboarding/infrastructure/persistence/filesystem_derived_message_data_file_store_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Attachment Preservation Safety Invariant

## Decision

The permanent rule now lives in
[`ATTACHMENT-PRESERVATION-INVARIANT.md`](../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md):

> Archived attachment payloads are MessageLens preservation data. Ordinary
> onboarding, reset, reimport, recovery, migration cleanup, rebuild, and tests
> must never mutate them as a side effect.

This record connects that invariant to the current onboarding/import work. It
does not redefine attachment archival.

## Why This Became Blocking Here

The current first-run path resets rebuildable derived stores before graph
construction. Recent progress-surface work made that destructive boundary more
visible, but visibility does not define its safety. The reset must remain
strictly narrower than the admitted archive root.

The crucial distinction is:

```text
AUTHORITATIVE EXTERNAL SOURCES — NEVER OUR DELETION TARGET
    Apple Messages chat.db
    Apple Contacts databases
    locally available Messages attachment payloads

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores
    indexes and projections

MESSAGELENS PRESERVATION DATA — TREAT LIKE GOLD
    archived attachment payloads
```

## Current Code Evidence

`MessageDataResetService` uses private `AppDatabaseFile` allow-lists and a
filesystem port restricted to base filenames. Its complete payload deletion
scope is:

```text
macos_import_ss.db  (+ -wal / -shm)
working_ss.db       (+ -wal / -shm)
macos_import.db     (+ -wal / -shm)
working.db          (+ -wal / -shm)
```

It does not receive attachment archive path authority. It does not delete a
directory, enumerate the archive root, or use recursive deletion. All current
first-run, reimport, automatic-recovery, explicit-reset, and development-reset
callers share this boundary.

## Tripwires Added

- The production-shaped temporary-folder reset test now proves archived
  payload contents remain byte-for-byte unchanged while named rebuildable
  stores and sidecars are removed.
- The same test proves overlay, Presence, and unrelated archive-root files
  remain unchanged.
- The architecture suite rejects reset code that gains archive path authority,
  preserved database categories, directory traversal, broad listing, or
  recursive deletion.

## Explicit Specialist Exception

The attachments feature has a dormant, archive-owned `clearArchive()` API. It
has no current `lib/` caller and is not part of reset/rebuild semantics. Any
future production exposure requires its own preservation-aware design,
authorization, and confirmation. This record does not authorize or modify it.

## Scope Confirmation

This safety slice changes no:

- archive payload;
- archive behavior or root;
- naming or content-addressing format;
- attachment discovery or import behavior;
- reset/reimport/recovery runtime behavior;
- schema or migration;
- production or development data.

It makes the current narrow reset semantics explicit and protects them against
future broadening.
