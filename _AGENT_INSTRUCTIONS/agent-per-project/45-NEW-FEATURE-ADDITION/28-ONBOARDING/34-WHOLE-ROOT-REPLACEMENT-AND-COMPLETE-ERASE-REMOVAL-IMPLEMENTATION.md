---
tier: project
scope: onboarding-and-archive
owner: agent-per-project
last_reviewed: 2026-09-06
source_of_truth: implementation
---

# Whole-Root Replacement and Complete Erase Removal

## Status

Implemented. The generalized runtime capability that could recursively erase
and replace the active MessageLens Application Support root has been removed.

Every supported mutation now targets a named, bounded resource. No database
schema, archive marker, archive UUID, production archive, or user data was
changed by this implementation.

This document implements the decision recorded in
[`33-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-AUDIT.md`](33-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-AUDIT.md).
Earlier Complete Erase implementation records remain historical evidence and
are superseded for current architecture by this document.

## Removed Runtime Capability

The following production concepts were removed:

- `CompleteInstallationEraseStore` and its filesystem implementation;
- `CompleteInstallationEraseTransaction` as an active mutation model;
- `CompleteInstallationEraseService` and provider wiring;
- Complete Erase action, dialog, overlay, and presentation state;
- the sidebar intent and dispatcher branch;
- `ArchiveAccessMode.completeEraseOnly` and `_EraseOnlyStartup`;
- `ArchiveMutationOperation.completeInstallationErase`;
- replacement UUID generation and virgin-marker installation after erase;
- the operation-specific virgin verifier;
- Dart and native archive-replacement relaunch adapters;
- automatic destructive transaction resumption from `main.dart`.

There is no reusable production primitive remaining that can recursively erase
the active MessageLens archive root.

## Permanent Mutation Model

MessageLens now has these distinct mutation boundaries:

| Concern | Permanent boundary |
| --- | --- |
| Virgin initialization | Create the first marker and archive UUID only |
| Current store evolution | Run each store's supported schema migration |
| Start Fresh and automatic recovery | Remove only enumerated rebuildable stores |
| Historical Archives and attachments | Mutate only the specifically admitted source or payload state |
| Checkpoint restore | Restore offline into an absent disposable destination only |
| Archive adoption | Create an in-place marker only after exact verification |

Start Fresh continues to preserve the Application Support root, archive marker
and UUID, overlay/user intent, preferences, Presence history, diagnostics, and
`attachment_archive/`.

Checkpoint creation and verification are unchanged. Offline restore still
refuses an existing destination and cannot overwrite the active archive root.

## Temporary Legacy Journal Compatibility

`LegacyCompleteInstallationEraseJournalCompatibility` is the only retained
accommodation for the obsolete file:

```text
.messagelens-complete-installation-erase.json
```

It is a startup compatibility reader, not an archive mutation service. It can:

- parse that exact journal;
- inspect the current marker, ordinary admission, database integrity, and
  generic installation classification;
- emit bounded diagnostics;
- delete only the same unchanged journal file in a proven-safe stale state.

It cannot recursively delete, delete databases or attachments, install or
alter a marker, generate an identity, create replacement authority, invoke the
mutation coordinator, or relaunch the app.

## Safe-Handling Matrix

| Evidence | Result |
| --- | --- |
| No journal | Perform ordinary archive admission |
| Matching environment; current marker differs from recorded replacement; ordinary admission and coherent database evidence succeed | Delete only the unchanged stale pre-erase journal, then continue ordinary admission |
| Matching environment; marker equals the recorded replacement; generic evidence proves Virgin and root inventory contains only marker, process lock, and journal | Delete only the unchanged stale post-install journal, then continue Virgin Onboarding |
| Malformed journal, environment mismatch, missing marker, admission failure, integrity failure, partial state, unexpected post-install artifact, symlink, identity ambiguity, or concurrently changed journal | Fail closed without deleting the journal or any archive data |

The reader compares journal bytes again immediately before deletion. A changed
or replaced journal is retained and startup fails closed.

## Mechanical Protection

The replacement architecture test proves:

1. retired service/store/action/operation/access-mode/relaunch symbols are
   absent from production Dart;
2. Start Fresh remains an enumerated preservation-safe reset;
3. the compatibility seam contains no recursive deletion or identity,
   mutation-coordinator, marker-installation, or relaunch authority;
4. startup cannot resume the obsolete destructive transaction;
5. checkpoint restore retains its absent-destination refusal.

Focused compatibility tests cover every allowed and refused matrix state and
verify that marker bytes, database bytes, attachment payloads, and unrelated
files remain unchanged.

## Compatibility Sunset

Remove the compatibility reader no earlier than both:

- MessageLens `0.4.0`; and
- 2027-09-01.

Removal also requires confirmation that the supported tester-upgrade window no
longer includes builds capable of writing the obsolete journal. The sunset
must remove the parser and one-file cleanup path without restoring any
destructive compatibility behavior. Permanent negative architecture tripwires
remain after the reader is removed.

## Verification

Verification completed on 2026-09-06:

- 110 focused admission, onboarding, Start Fresh, checkpoint, adoption,
  Historical Archives, graph-projection, and attachment-recovery tests passed;
- all 385 repository architecture tripwires passed;
- the complete Flutter suite passed with 2,142 tests;
- `flutter analyze` reported no issues;
- `git diff --check` passed;
- the macOS debug build completed as `MessageLens Development.app`;
- the macOS release build completed, then the repository production-candidate
  pipeline re-signed it with the configured Developer ID and verified the
  production bundle, signing team, entitlements, and archive-root contract;
- the signed candidate was neither installed, launched, notarized, nor
  published.

Repository-wide production-code searches found none of the removed Complete
Erase service, store, operation, access-mode, startup, or relaunch symbols.
The remaining recursive filesystem deletions belong only to bounded checkpoint
temporary destinations, adoption inventory cleanup, and the attachment-owned
archive operation; no active-root recursive eraser remains.
