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

Recovered deleted/unlinked messages are the last message-evidence surface whose
source records still come from legacy recovered-message tables in `working.db`.

This document defines the conservative migration path. The goal is to preserve
the hard-won recovery semantics while moving identity toward the source-scoped
graph.

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

The remaining legacy dependency is the source repository:

```text
recoveredUnlinkedMessagesProvider
→ working.db.recovered_unlinked_messages
→ working.db.recovered_unlinked_attachments
→ legacy handle/participant compatibility helpers
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

Keep reading `working.db.recovered_unlinked_messages` temporarily, but classify
the implementation as a legacy compatibility repository.

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

The retained legacy recovered repository remains only as a diagnostic comparison
source for graph parity and recovery/archive review.

Real-data parity review is now documented in
`77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md`. The graph repository candidate
covers most legacy recovered evidence. The three initially suspicious
legacy-only rows are now resolved as expected graph-era user-intent suppression
from testing the Unknown Senders discard action, not source/import evidence
loss. The remaining cutover decision is whether to intentionally accept that
195 legacy recovered rows are now ordinary graph-projectable conversation
messages.

### 6. Retire legacy recovered tables only after parity is proven

The old `working.db.recovered_unlinked_*` tables can be deleted only when the
app no longer needs them for retained parity diagnostics, coverage reports, or
archive/recovery review.

## Non-Goals

Do not:

- merge recovered records into normal conversations by GUID alone
- infer topology by raw handle alone
- drop sparse artifacts
- hide no-text records
- remove recovered attachment paths
- treat recovered-message GUIDs as canonical graph identity
- recreate the legacy schema shape inside `working_ss.db`

## First Safe Code Slice

The next safe implementation step is:

1. Define a recovered message evidence repository contract.
2. Move the current `working.db` logic behind a clearly named legacy repository.
3. Keep `RecoveredMessagesEvidenceScope` behavior unchanged.
4. Add focused tests proving the repository preserves:
   - contact scoping
   - no-handle filtering
   - inferred outgoing rows
   - attachment deduplication
   - sender label fallback

This does not retire legacy storage yet. It removes production architectural
coupling so the graph-backed recovered implementation can remain the live
evidence path while retained legacy storage serves only diagnostics/review.

## Done Means

Recovered-message migration is complete only when:

- recovered evidence uses source-scoped identity
- recovered attachment evidence is source-scoped
- recovered no-handle inference still works
- recovered contact scoping still works
- message evidence presentation remains shared
- coverage settings no longer need `working.db.recovered_unlinked_messages`
- `working.db.recovered_unlinked_*` tables are no longer production blockers
