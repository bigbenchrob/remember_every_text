---
tier: project
scope: source-scoped-graph-migration
status: active
last_reviewed: 2026-05-31
depends_on:
  - 69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - 71-LEGACY-DEPENDENCY-MATRIX.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md
---

# 76 - Recovered Message Graph Identity Plan

## Purpose

Recovered deleted/unlinked messages are now graph-orphan evidence: source-
retained `working_ss.messages` rows without current `chat_to_message` topology
render through the shared Message Evidence Spine.

This document records the conservative migration path that got there and the
remaining retention rule: old `working.db.recovered_unlinked_*` tables are
historical storage inside retained legacy DBs, not production recovered-message
routing.

## Current State

Recovered messages already use the shared Message Evidence Spine for display:

```text
MessagesSpec.recoveredUnlinkedMessages
→ RecoveredMessagesEvidenceScope
→ messageEvidenceTimelineSkeletonProvider
→ messageEvidenceRowProvider
→ MessageEvidenceTimelineView
```

The presentation path is therefore mostly aligned with the graph-era UI:

- shared header
- shared skeleton/jump/search behavior
- shared row renderer
- shared attachment evidence rendering

The former legacy source repository has been retired from production routing.
The current source repository is:

```text
recoveredUnlinkedMessagesProvider
→ GraphRecoveredMessageEvidenceRepository
→ working_ss.messages without chat_to_message topology
→ working_ss.message_to_attachment
→ shared graph attachment evidence hydration
```

## Why This Must Move Conservatively

Recovered records are not ordinary chat graph records.

They preserve source records that were not safely linked into normal
conversation topology. Current behavior includes:

- no-handle outgoing-message inference
- contact-scoped inference windows
- recovered attachment deduplication
- fallback text for sparse/system/reaction artifacts
- semantic kind preservation
- recovered attachment display

These are recovery semantics, not ordinary conversation topology. They should
not be casually collapsed into the normal `working_ss.messages` graph without a
specific source identity model.

## Current Identity Forms

The legacy recovered path uses:

- `recovered_unlinked_messages.id`
- `recovered_unlinked_messages.guid`
- `recovered_unlinked_messages.source_rowid`
- `sender_handle_id`
- `recovered_unlinked_attachments.import_attachment_id`
- attachment local paths / hashes

The graph-era target should use:

- `source_id`
- recovered source row identity
- deterministic recovered message identity
- deterministic recovered attachment identity
- explicit recovered-source provenance

The target identity must not pretend that recovered records are normal
live-source conversation messages unless topology proves that safely.

## Recommended Target Model

Recovered messages should become a source-scoped recovery source, not an
ordinary live chat source grafted into topology.

Conceptually:

```text
recovered source
→ import_ss.recovered_messages
→ working_ss.recovered_messages or recovered evidence projection
→ MessageEvidenceScope
```

The source-scoped identity should remain deterministic, but it may require a
dedicated recovered-source namespace because recovered records are not always
ordinary `chat.db.message` rows with valid conversation endpoints.

## Conservative Migration Sequence

### 1. Name the repository boundary

Create a recovered-message evidence repository interface/read boundary before
changing storage.

The existing provider should become an implementation detail behind a named
recovery repository, not a provider that presentation/evidence code depends on
directly.

This is a low-risk structural step because it preserves runtime behavior.

Status: started. `RecoveredMessageEvidenceRepository` is now the named
contract, with `RetainedLegacyRecoveredMessageEvidenceRepository` quarantining
the current `working.db.recovered_unlinked_*` reads. The contract/read model,
legacy implementation, and Riverpod provider wiring are now split into separate
files so a source-scoped implementation can replace the legacy repository
without changing the Message Evidence Spine or presentation.

Focused tests now cover the compatibility boundary for:

- recovered fallback text
- recovered attachment dedupe
- contact-scoped direct matching
- no-handle outgoing inference
- contact-name resolution through legacy handle/participant links

### 2. Move legacy read logic behind that boundary

Status: complete for production routing. The live recovered-message provider no
longer reads `working.db.recovered_unlinked_messages`. Retained legacy reads are
limited to `RetainedLegacyRecoveredMessageEvidenceRepository` for graph parity
diagnostics and archive/recovery review.

The Message Evidence Spine should depend on typed recovered evidence records,
not legacy table details.

### 3. Define recovered source-scoped identity before schema

Status: started. `RecoveredMessageIdentity` now documents and tests the
schema-free identity contract:

- recovered rows are source message occurrences
- canonical identity is `pack(source_id, message.ROWID)`
- the same `ROWID` in different sources remains distinct
- GUID does not participate in canonical identity
- topology controls whether the row appears as conversation graph evidence or
  recovered-only evidence
- recovery status does not create a separate identity scheme

### 4. Add graph/source-scoped recovered identity design tests

Before schema changes, test the expected semantics:

- recovered message identity is deterministic
- recovered attachments keep provenance
- no-handle outgoing inference remains intact
- contact-scoped inference remains intact
- sparse/system artifacts remain visible
- attachment evidence remains renderable

Status: started. A schema-free repository contract test now exercises the
target graph semantics with an in-memory source-scoped implementation before
any recovered storage schema exists. The contract locks:

- graph-projectable rows are excluded from recovered-only evidence
- recovered-only rows expose `pack(source_id, message.ROWID)` as their evidence
  id
- overlapping `ROWID` values and duplicate GUIDs across sources do not collapse
- sparse and attachment-only rows remain visible
- contact-scoped direct matches and nearby no-handle outgoing inference remain
  part of the recovery contract

### 5. Add source-scoped recovered import/projection only after tests exist

Do not migrate the tables until the repository contract and behavior tests make
the old/new implementations substitutable.

Status: production recovered evidence now reads from
`GraphRecoveredMessageEvidenceRepository` over source-scoped graph facts. It
reads
`working_ss.messages` rows that have no `chat_to_message` topology edge,
preserves source-scoped `ss_id` identity, hydrates attachment evidence through
`working_ss.message_to_attachment`, and preserves contact-scoped direct matching
plus nearby no-handle outgoing inference.

The retained legacy recovered repository was later retired as runtime
diagnostic code after production recovered evidence moved to graph orphan
evidence and the remaining legacy-only rows were accepted as retention caveats.

Real-data parity review is now documented in
`77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md`. The graph repository covers the
accepted recovered evidence surface. The three initially suspicious
legacy-only rows are now resolved as expected graph-era user-intent suppression
from testing the Unknown Senders discard action, not source/import evidence
loss. The cutover accepted that 195 legacy recovered rows are now ordinary
graph-projectable conversation messages.

### 6. Retire legacy recovered tables only with broader legacy DB retirement

The runtime parity diagnostic bridge has been removed. The old
`working.db.recovered_unlinked_*` tables still physically exist as part of the
retained legacy database schema and should be deleted only with the broader
legacy DB retirement decision, not as a standalone recovery cleanup.

## Non-Goals

Do not:

- merge recovered records into normal conversations by GUID alone
- infer topology by raw handle alone
- drop sparse artifacts
- hide no-text records
- remove recovered attachment paths
- treat recovered-message GUIDs as canonical graph identity
- recreate the legacy schema shape inside `working_ss.db`

## Current Safe Next Step

Do not continue deleting recovered storage in isolation.

The next safe work is broader legacy DB retirement planning:

1. Keep `working.db.recovered_unlinked_*` tables as historical retained storage
   while the legacy DB schema itself is retained.
2. Keep production recovered evidence on
   `GraphRecoveredMessageEvidenceRepository`.
3. Treat recovered source-folder import as a future source-scoped import
   problem, not a reason to resurrect the legacy recovered repository.
4. When broader legacy DB retirement starts, decide whether the historical
   recovered rows need export, source-scoped import, or no further retention.

## Done Means

Recovered-message migration is complete only when:

- recovered evidence uses source-scoped identity
- recovered attachment evidence is source-scoped
- recovered no-handle inference still works
- recovered contact scoping still works
- message evidence presentation remains shared
- coverage settings no longer need `working.db.recovered_unlinked_messages`
  (done; they count graph-orphan recovered rows from `working_ss.db`)
- `working.db.recovered_unlinked_*` tables are no longer production blockers
