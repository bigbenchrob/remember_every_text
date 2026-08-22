---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation
status: implemented
links:
  - ../prompts/52-EPHEMERAL-MESSAGELENS-RECOVERY-DONORS-VS-DURABLE-HISTORICAL-SOURCES.MD
  - ./51-BACKWARD-COMPATIBLE-MESSAGELENS-ARCHIVE-QUALIFICATION-AUDIT.md
  - ../../../10-DATABASES/14-historical-archive-source-identity.md
tests:
  - ../../../../../test/features/settings/infrastructure/repositories/message_lens_historical_archive_preflight_service_test.dart
  - ../../../../../test/architecture/message_lens_attachment_recovery_architecture_test.dart
---

# Ephemeral MessageLens Recovery Donors

## Implemented Product Boundary

Mac Messages folders may become durable historical content sources. They keep
canonical `HistoricalArchiveSourceIdentity`, source registration, provenance,
sidebar membership, and later removal semantics.

MessageLens data folders do none of those things. They are session-scoped,
read-only attachment-recovery donors. Selecting one does not register a source,
persist its path, create a cartouche, mint an archive UUID, or authorize
attachment mutation.

## Typed Qualification

Attachments owns `MessageLensAttachmentRecoveryDonor` and its qualifier.
The donor records only:

- the current selected root locator;
- the recognized format generation; and
- an optional marker `archiveInstanceId` for diagnostics.

The UUID is not recovery authority. Legacy donors legitimately carry no UUID.

The qualifier recognizes:

| Format | Import | Overlay | Graph |
| --- | ---: | ---: | ---: |
| May 2026 generation | 8 | 5 | 1 |
| June 2026 generation | 9 | 5 | 1 |
| July 2026 generation | 10 | 1 | 2 |

Legacy recognition also requires the expected database set, attachment archive
directory, healthy SQLite integrity checks, and the table/column contracts
consumed by the existing read-only evidence adapter. Familiar filenames alone
do not qualify a folder. Unsupported recognizable schema tuples produce the
typed incompatible outcome.

## Admission Pipeline

Historical Archives now orchestrates:

```text
choose folder
    -> qualify supported MessageLens format
    -> exact Messages ROWID/GUID lineage admission
    -> exact per-message/per-attachment preflight
    -> read-only ready state
```

Contradictory and insufficient lineage stop before attachment matching. The
existing attachment matcher, donor-path checks, payload verification, and
current-payload-state checks are unchanged.

Repeated selection performs the whole read-only pipeline again. This is
intentional: the donor is an ephemeral locator and current payload state may
have changed.

## Mechanical Boundaries

`HistoricalArchiveSourceIdentity` now represents durable Mac Messages sources
only. It cannot construct or restore a MessageLens recovery identity.

Architecture tripwires require the MessageLens flow to retain the lineage gate
and prohibit source registration, path-key construction, synthetic archive ID
creation, donor writes, and attachment mutation through the ready-state UI.

No database schema, donor file, marker, source registry, graph, overlay, or
attachment payload was changed by this slice. Actual attachment recovery
execution remains separately gated and unavailable from Historical Archives.
