---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: architecture
links:
  - ./04-db-chat.md
  - ./14-historical-archive-source-identity.md
  - ../45-NEW-FEATURE-ADDITION/26-PRODUCTION-ARCHIVE-RECOVERY/responses/46-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.md
---

# Messages Lineage Admission

## Governing Rule

> **Every Historical Archives operation that depends on original Apple
> Messages ROWID identity must prove same current `chat.db` lineage through the
> canonical Messages-lineage authority before consequential work is
> authorized.**

The authority lives in `essentials/source_scoped_import`. It compares typed
`originalMessagesRowId` and `messageGuid` anchors against the authoritative
current Mac Messages database through the established read-only source opener.

It returns exactly one result:

- `sameLineage`;
- `contradictoryLineage`; or
- `insufficientEvidence`.

One same-ROWID/different-GUID contradiction rejects a candidate. Admission
requires at least 64 exact matches across at least three of four ROWID bands,
with coherent source evidence. Smaller or unreadable evidence fails closed.

Raw Mac Messages candidates supply `message.ROWID` and `guid` directly.
MessageLens candidates recover the original ROWID only through canonical
`SourceScopedRowKey` unpacking of the sole live-source ledger facts. These are
two evidence adapters feeding one comparison authority.

Paths, labels, archive instance IDs, date overlap, and message counts provide
no lineage authority. Historical source identity remains a separate question:
identity says which source; lineage admission says whether its ROWID namespace
may be interpreted as part of the current Messages history.

Lineage reads are read-only. A failed admission must not register a source,
authorize import, mutate an archive, or create selection/correspondence state.
