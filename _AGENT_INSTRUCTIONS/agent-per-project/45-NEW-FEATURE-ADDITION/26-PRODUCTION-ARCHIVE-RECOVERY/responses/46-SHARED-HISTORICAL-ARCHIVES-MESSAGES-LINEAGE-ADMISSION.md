---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/45-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.MD
  - ./45-MESSAGELENS-ATTACHMENT-RECOVERY-LINEAGE-PROOF.md
  - ../../../10-DATABASES/15-messages-lineage-admission.md
---

# Shared Historical Archives Messages Lineage Admission

## Result

The dormant attachment-specific proof is now the one shared Messages-lineage
authority in `lib/essentials/source_scoped_import/`.

Both Historical Archives source arms consume typed anchors:

```text
originalMessagesRowId + messageGuid
```

The Mac Messages adapter reads `message.ROWID` and `guid` directly. The future
MessageLens adapter reads the sole `live_chat_db` import-ledger source and uses
`SourceScopedRowKey` to recover its original ROWID. One service compares either
form with the authoritative current `chat.db` through `SourceDatabaseOpener`.

## Admission Semantics

The preserved `exact-rowid-guid-v1` policy is:

- one contradiction produces `contradictoryLineage`;
- at least 64 exact matches across at least three of four ROWID bands, coherent
  source shape, and no contradiction produce `sameLineage`;
- every other result is `insufficientEvidence`.

The policy was not weakened for small archives. No independent deterministic
proof currently exists, so small legitimate candidates fail closed.

## Mac Messages Ordering

The implemented qualification sequence is:

```text
structural/read-only inspection
  -> canonical duplicate lookup
  -> shared lineage admission
  -> source metadata persistence
  -> typed ready-to-add state
  -> explicit import authorization
```

Duplicate recognition remains first because it is read-only and avoids an
unnecessary lineage scan for a source already imported. A ready, importing, or
retry state contains a `SameMessagesLineageAdmission`; contradictory and
insufficient outcomes therefore cannot authorize import.

Both failures restore hub presentation and produce distinct concise modals.
They create no source registration, import, blue selection, or orange
correspondence.

## Ownership Boundaries

`HistoricalArchiveSourceIdentity` remains the sole answer to “which historical
source is this?” Lineage admission independently answers “may this source's
original Messages ROWIDs be interpreted in the current history?”

The MessageLens segment, attachment matching, and payload recovery remain
disabled. Its existing evidence adapter can consume the shared authority later
without a second comparison algorithm.

## Protection

Focused tests cover raw and scoped anchor extraction, exact admission,
contradiction, insufficient evidence, and no-mutation workflow rejection.
Architecture tripwires require one comparison authority, read-only adapters,
canonical unscoping, and typed ready-state admission.
