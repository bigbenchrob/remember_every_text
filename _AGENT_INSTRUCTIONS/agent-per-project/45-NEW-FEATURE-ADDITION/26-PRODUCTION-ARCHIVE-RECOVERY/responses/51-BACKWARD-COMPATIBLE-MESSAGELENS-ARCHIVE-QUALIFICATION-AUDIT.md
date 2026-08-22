---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: audit
status: superseded-product-model
links:
  - ../prompts/51-BACKWARD-COMPATIBLE-MESSAGELENS-ARCHIVE-QUALIFICATION.MD
  - ./50-ENABLE-MESSAGELENS-HISTORICAL-ARCHIVES-THROUGH-READY-STATE.md
  - ../../../10-DATABASES/14-historical-archive-source-identity.md
  - ../../../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/QUESTIONS.md
tests: []
---

# Backward-Compatible MessageLens Archive Qualification Audit

> **Superseded conclusion:** this audit correctly established that pre-marker
> archives have no durable identity. Prompt 52 subsequently clarified that a
> MessageLens attachment-recovery donor is an ephemeral recovery candidate,
> not a durable Historical Archives source. The forensic evidence below
> remains authoritative; the conclusion that missing durable identity blocks
> recovery admission does not. See the
> [Prompt 52 implementation](52-EPHEMERAL-MESSAGELENS-RECOVERY-DONORS-IMPLEMENTATION.md).

## Decision

The requested compatibility implementation stops at the prompt's mandatory
identity boundary.

The inspected pre-marker archives are genuine, healthy MessageLens archives,
and their attachment evidence schemas are readable by the current donor
adapter. They do not, however, contain an `archiveInstanceId` or another
documented durable archive identifier from which the current canonical
MessageLens recovery identity can be reconstructed.

Admitting them by path, folder name, familiar filenames, database timestamps,
or a newly invented content hash would weaken source-identity authority. No
such fallback was implemented.

## Exact Current Rejection

`MessageLensHistoricalArchivePreflightService.inspect(...)` currently reads:

```text
<selected root>/.messagelens-archive.json
```

through `FileSystemArchiveMarkerStore`. When the marker is absent, the service
returns:

```text
MessageLensHistoricalArchiveInvalidFolder
```

The Historical Archives workflow maps that typed result to
`HistoricalArchivesMessageLensNoticeKind.invalidFolder`, whose modal title is:

> This doesn't appear to be a MessageLens data folder.

The rejection occurs before required database checks, lineage admission, or
attachment preflight. For a genuine pre-marker archive, this result is
semantically too coarse: the archive is recognizable but not currently
admissible.

## Historical Generation

The archive marker and archive-instance model entered the repository in the
July 2026 production-data-protection work. Historical records explicitly
describe the then-current production archive as an **unmarked** archive that
required a dedicated adoption operation.

Representative read-only snapshots were inspected with immutable SQLite
connections:

| Snapshot | Approximate app generation | Import schema | Overlay schema | Marker |
| --- | --- | ---: | ---: | --- |
| 2026-05-31 | `0.1.16+17` | 8 | 5 | absent |
| 2026-06-20 | `0.1.16+17` | 9 | 5 | absent |
| 2026-07-27 | `0.2.15+33` | 10 | 1 | absent |

All three contain the MessageLens source-scoped import database, overlay
database, graph database, and attachment archive expected from their
generation. Their absence of a marker is historical format truth, not evidence
that they are arbitrary folders.

## Identity Findings

### Did these generations have the current marker?

No. `.messagelens-archive.json` did not yet exist.

### Did they have an archive instance ID?

No persisted archive-instance identifier was found in the marker, source
registry, import batches, overlay settings, graph store, or documented schema.

### Where was archive identity stored?

It was not stored. Before production-data protection, archive identity was
implicit in whichever collection of files the app's providers opened.

### Did the canonical Application Support folder serve as identity?

It served as the operational location, not a durable archive identifier. The
settled adoption architecture explicitly states that the canonical root is not
stored as identity. During adoption, MessageLens minted a new UUID; it did not
recover one from the old root or its databases.

### Which checks are newer than these archives?

All current marker checks are newer:

- marker presence and format version;
- marker environment;
- archive-instance identity;
- donor/current archive-instance distinction; and
- production donor-environment policy.

The required evidence database and SQLite compatibility checks operate on
older structures and are not themselves the blocker.

## Structural And Donor Compatibility

The representative pre-marker archives are structurally compatible with the
current read-only attachment donor adapter:

- `macos_import_ss.db` contains one `live_chat_db` source;
- `messages`, `attachments`, and `message_to_attachment` contain every column
  required by `SqliteMessageLensAttachmentDonorEvidenceReader`;
- `user_overlays.db.archived_attachments` contains every required payload
  evidence column;
- immutable `PRAGMA quick_check` returned `ok`; and
- no donor migration or writable open was needed.

The May 31 snapshot, for example, contains 132,980 source-scoped messages and
31,729 archived-attachment metadata rows. This is strong evidence that it is a
MessageLens-owned historical format and that current attachment evidence could
be read. It is not archive identity authority.

No version-specific donor SQL adapter is currently required for the inspected
generations.

## Three Qualification Outcomes

The required semantic distinction remains:

1. **Not a MessageLens data folder**: arbitrary folder with no authoritative
   MessageLens format evidence.
2. **Recognizable but unsupported**: a pre-marker MessageLens archive whose
   database format is recognizable but whose canonical recovery identity
   cannot be established.
3. **Recognizable and supported**: a current-format archive with a valid marker
   and archive-instance identity that may continue to lineage admission.

The inspected pre-marker archives belong to outcome 2. The current code maps a
missing marker directly to outcome 1; that UX mismatch is recorded but was not
patched because the prompt requires stopping when legacy identity authority is
absent.

## Why No Legacy Identity Was Invented

The following candidates were rejected:

- **Selected path or basename:** locator evidence changes when a backup moves
  and was never canonical archive identity.
- **Familiar files or table names:** sufficient to recognize a format, but easy
  to copy and explicitly prohibited as identity authority.
- **Source-registry creation time or import batches:** operational facts, not
  documented unique archive identifiers.
- **Filesystem inode or creation time:** copy- and volume-dependent.
- **A new hash of databases or payloads:** no existing architecture defines
  which mutable snapshot facts compose that hash or whether successive
  snapshots represent one archive identity.
- **A random receiving-side UUID:** not deterministic reconstruction and would
  identify the selection event rather than the donor archive.

## Preserved Safety Invariants

- Donor folders and databases were inspected read-only and were not modified.
- No marker was created in a donor.
- No donor schema was migrated.
- No donor message, graph, overlay, source registry, or attachment was imported.
- The shared `MessagesLineageAdmissionService` remains mandatory for any
  future admissible donor.
- Attachment matching still occurs only after lineage admission.
- D1/D2/D3 remain intact; in particular, source identity is not inferred from
  filenames or paths.
- No attachment-recovery mutation was enabled.

## Required Product Decision Before Compatibility Can Proceed

A future slice needs an explicitly approved canonical identity contract for
pre-marker MessageLens archives. That contract must be deterministic,
read-only, stable across relocation, and grounded in evidence that the old
format actually persisted. If no such evidence exists, the supported product
boundary must remain current-format marked archives only.

Once that decision exists, qualification can safely distinguish recognizable
unsupported archives in code and use the incompatible-not-invalid modal copy.
Until then, the real older archive must not be manually marked, migrated, or
admitted by heuristic.
