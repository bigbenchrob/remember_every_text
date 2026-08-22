---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-22
source_of_truth: implementation-record
links:
  - ../prompts/50-ENABLE-MESSAGELENS-HISTORICAL-ARCHIVES-THROUGH-READY-STATE.MD
  - ./44-MESSAGELENS-DATA-FOLDER-HISTORICAL-ARCHIVES-AUDIT.md
  - ./46-SHARED-HISTORICAL-ARCHIVES-MESSAGES-LINEAGE-ADMISSION.md
  - ./47-MESSAGELENS-ATTACHMENT-MATCHING-AND-PRESERVATION-SAFE-RECOVERY.md
  - ./48-PRESERVATION-SAFE-ATTACHMENT-RECOVERY-INFRASTRUCTURE.md
  - ../../../10-DATABASES/14-historical-archive-source-identity.md
---

# MessageLens Historical Archives Ready-State Implementation

## Result

Historical Archives now has two working source arms with different contracts:

- **Mac Messages** adds historical messages from another snapshot of the same
  continuing Messages history.
- **MessageLens** inspects an older MessageLens data folder from that same
  history and identifies archived attachment payloads missing from the current
  MessageLens archive.

The MessageLens arm is enabled through a read-only ready state. It does not yet
execute attachment recovery.

## Sidebar And Switching

The existing `Mac Messages | MessageLens` segmented control now enables both
options. Switching while no mutation is active ends the prior presentation
session and creates a virgin destination-arm hub. Candidate evidence,
selection, notices, and stale asynchronous results do not cross arms.

The control remains disabled while Mac Messages import or removal owns the
mutation boundary. MessageLens has no mutation state in this slice.

The MessageLens hub contains source-specific guidance and `Choose MessageLens
Folder…`. It intentionally has no persistent donor list or cartouche. Recovery
folders are read-only evidence sources, not content sources added to
MessageLens membership.

## Qualification Pipeline

Folder selection runs these gates in order:

1. the selected path is a directory with a readable MessageLens archive marker;
2. marker format, environment policy, donor/current distinction, required
   read-only database shape, and SQLite integrity are compatible;
3. the shared `MessagesLineageAdmissionAuthority` proves the donor's live
   Messages source belongs to the current Messages lineage;
4. the Attachments-owned donor/current evidence adapters, payload inspector,
   and matcher produce exact recovery classifications.

Donor SQLite databases are opened read-only with query-only enforcement. No
donor migration, sidecar creation, source registration, overlay merge, graph
read, graph write, or graph rebuild is part of this path.

## Identity

MessageLens donor identity is:

```text
message_lens_recovery_archive + archiveInstanceId
```

`HistoricalArchiveSourceIdentity` owns construction and persisted validation.
The donor path remains locator evidence only.

## Typed Outcomes

The sealed Historical Archives presentation model now distinguishes:

- invalid folder;
- recognizable but incompatible archive;
- contradictory Messages lineage;
- insufficient lineage evidence;
- valid same-lineage donor with nothing recoverable;
- active read-only inspection; and
- exact ready evidence.

All pre-context rejections restore the MessageLens hub and use modal ownership.
Zero recoverable attachments is a calm informational outcome, not failure.

## Ready State

The ready composition uses the established A-I Track skeleton, Narrator, and
Directed Instrumentation. Primary evidence is:

- exact recoverable attachment count;
- exact recoverable bytes.

Already-present, missing, mismatch, conflict, ambiguity, unsafe-path, archive
instance, and donor path evidence remain subordinate in Details.

## Mutation Decision

`Recover Attachments` is omitted. The preservation-safe per-candidate installer
and exact-scope `attachmentReconciliation` capability exist, but no aggregate
batch executor yet owns candidate iteration, interruption reconciliation,
aggregate progress, and truthful terminal outcomes. Exposing authorization
before that boundary exists would be misleading.

The next mutation slice must compose the existing installer; it must not move
payload installation into Historical Archives or weaken capability admission.

## Preserved Boundaries

- No donor messages, graph, overlays, source registry, or Presence state are
  imported.
- No donor database is mutated.
- No current graph rebuild occurs.
- No MessageLens donor membership or persistent cartouche is created.
- Same-lineage admission precedes attachment matching.
- Recovery mutation still requires the exact-scope capability and is absent
  from this UI slice.
- The Mac Messages arm's import/removal behavior is unchanged.

## Verification Focus

Focused tests cover arm switching, source-specific sidebar presentation,
structural invalidity versus incompatibility, lineage-gate ordering, distinct
lineage outcomes, exact typed count/byte evidence, zero-results handling,
canonical archive-instance identity, read-only donor access, stable Tracks, and
absence of a recovery command.
