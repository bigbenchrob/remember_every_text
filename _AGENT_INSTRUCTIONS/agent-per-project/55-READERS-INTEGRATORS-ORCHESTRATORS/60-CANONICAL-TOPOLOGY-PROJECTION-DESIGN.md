# 60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN

> Update note, 2026-05-19: endpoint identity semantics have been simplified by
> [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md).
> Source-derived working row identity is now occurrence-preserving and
> source-scoped. Relationship endpoints should project to the corresponding
> `SourceScopedRowKey`, not through a separate canonical endpoint remapping
> layer. Treat older option analysis in this document as historical design
> context where it discusses remapping or merge-collapsed canonical endpoints.

## Purpose

This document records design options for projecting preserved source `chat_message_join` topology from the shadow import ledger into canonical working projection relationships.

This is design-only. It does not define an implemented projection path yet.

Current validated state:

- `chat.db.chat_message_join` is observed as source topology.
- `macos_import_shadow.db.chat_message_joins` preserves source-scoped topology facts.
- `ChatMessageJoinImporter` imports topology rows idempotently and resumably.
- `ChatMessageJoinStageController` runs before message migration/projection in `PipelineOrchestrator`.
- canonical relationship projection remains deferred.

Core rule:

```text
Import ledger = source truth
Working projection = app truth
```

The topology projection problem is deciding how source-scoped relationship facts become canonical app-facing relationships without losing provenance or assuming one source forever.

---

# Source Topology Facts

The shadow ledger now preserves `chat_message_join` as source truth.

Each ledger row represents a source-local relationship row:

```text
source_id
source_kind
source_rowid
source_chat_rowid
source_message_rowid
```

Meaning:

- `source_id` identifies the source database instance, such as `live-chat-db`.
- `source_kind` identifies the source type, such as `live_chat_db`.
- `source_rowid` is the source-local `chat_message_join.ROWID`.
- `source_chat_rowid` is the source-local `chat.ROWID`.
- `source_message_rowid` is the source-local `message.ROWID`.

These values are provenance, not canonical app identity.

The ledger row answers:

```text
In source X, join row J says chat row C contains message row M.
```

It does not answer:

```text
Which canonical app chat should the UI show?
Which canonical working message id should this relationship point to?
Should this source chat merge with another source chat?
```

Those are projection questions.

---

# Projection Problem

Projection must map source-scoped endpoints:

```text
source_id + source_chat_rowid
source_id + source_message_rowid
```

to working/canonical endpoints:

```text
working chat id
working message id
```

without pretending that source row IDs are global.

Unsafe shortcut:

```text
working_chat_id = source_chat_rowid
working_message_id = source_message_rowid
```

That fails as soon as another `chat.db` source is introduced, because every source has its own local ROWID sequence.

Projection therefore needs explicit source-to-working lookup semantics.

---

# Required Mapping Strategy

The projection layer likely needs two endpoint resolvers before it can project topology safely.

## Message Endpoint Mapping

Source message endpoint:

```text
source_id + source_message_rowid
```

Possible lookup path:

```text
macos_import_shadow.db.messages
WHERE source_id = ?
  AND source_rowid = ?
→ message guid / ledger message row
→ working_shadow.db.messages row
```

Preferred conceptual identity:

```text
source row key → ledger message → canonical/working message
```

Message `guid` is a strong canonical/dedupe candidate, but it should not erase source provenance. Multiple source rows may map to one canonical working message in future archive/live merge scenarios.

## Chat Endpoint Mapping

Source chat endpoint:

```text
source_id + source_chat_rowid
```

Possible lookup path:

```text
macos_import_shadow.db.chats
WHERE source_id = ?
  AND source_rowid = ?
→ source chat guid / identifier / service metadata
→ working_shadow.db.chats row
```

Chat canonicalization is less straightforward than message identity.

Possible canonicalization inputs include:

- source chat `guid`
- source chat identifier
- service
- participant topology once `chat_handle_join` is preserved
- source kind and source recency

The first projection slice should avoid pretending this is solved globally.

Display-facing metadata such as `display_name` is not a canonicalization input.
It may be useful for diagnostics or eventual UI hints when directly sourced,
but it must not drive endpoint resolution, dedupe, or topology projection.

Source-derived timing facts such as `created_at_utc` and `updated_at_utc`
should be preserved when they map to verified source columns. They may inform
future diagnostics or recency features, but they are not endpoint identity and
must not substitute for source topology or canonical relationship projection.

---

# Projection Options

## Option A: Direct Working Relationship Rows With Source Provenance Columns

Project directly into a working relationship table with canonical endpoints plus source provenance:

```text
working_chat_message_relationships
  working_chat_id
  working_message_id
  source_id
  source_join_rowid
  source_chat_rowid
  source_message_rowid
```

Benefits:

- simple to query
- keeps provenance near the projected relationship
- easy to validate source row → working row projection

Risks:

- mixes canonical relationship and provenance concerns in one table
- may become awkward if multiple source topology rows support one canonical relationship
- may need conflict metadata later

Best fit:

- early shadow projection validation
- small first mutation slice after read-only preview

## Option B: Canonical Relationship Table Plus Provenance Sidecar

Use one table for canonical relationships and a sidecar table for source evidence.

Conceptual shape:

```text
working_chat_message_relationships
  id
  working_chat_id
  working_message_id

working_chat_message_relationship_sources
  relationship_id
  source_id
  source_join_rowid
  source_chat_rowid
  source_message_rowid
```

Benefits:

- clean separation between app truth and source evidence
- supports many source topology rows backing one canonical relationship
- better future fit for archive/live reconciliation

Risks:

- more schema and query complexity
- requires a clearer canonical relationship identity decision
- likely too much for the first implementation slice

Best fit:

- future production-shaped canonical projection
- multi-source conflict/reconciliation work

## Option C: Read-Only Projection Preview First

Do not mutate `working_shadow.db` yet. Build a read-only resolver/integrator that joins:

```text
chat_message_joins source topology
→ ledger messages
→ ledger chats
→ current working messages/chats
```

and emits a preview such as:

```text
resolved
unresolvedMessageEndpoint
unresolvedChatEndpoint
ambiguousChatEndpoint
alreadyProjected
```

Benefits:

- validates endpoint mapping before schema commitment
- exposes missing mappings and ambiguous canonicalization
- preserves the existing shadow safety model
- avoids prematurely designing the final relationship schema

Risks:

- does not yet prove write behavior
- can defer hard schema decisions
- needs careful wording so "preview resolved" is not mistaken for authoritative projection

Best fit:

- immediate next slice
- causal observability before mutation

## Option D: Placeholder Chat Replacement During Message Migration

Use topology projection to replace the current placeholder chat behavior inside message migration.

Benefits:

- directly addresses the known placeholder shim
- moves message projection closer to source topology truth

Risks:

- couples topology projection to existing message migration too early
- requires canonical chat resolution before it has been validated
- can hide endpoint mapping problems behind migration behavior
- increases blast radius

Best fit:

- not recommended as the next slice
- candidate only after read-only projection preview and schema shape are validated

---

# Recommended First Implementation Slice

Recommended next slice:

```text
read-only topology projection preview
```

Build a resolver/integrator that takes preserved source topology and attempts to resolve both endpoints against existing shadow ledger and working projection facts.

The preview should not mutate `working_shadow.db`.

It should answer:

- Can this source topology row find its imported ledger message?
- Can this source topology row find its imported ledger chat?
- Can the ledger message resolve to a working message?
- Can the ledger chat resolve to a working chat under current rules?
- Which rows are unresolved and why?
- Are any endpoint mappings ambiguous?

Suggested result states:

```text
projectable
missingLedgerMessage
missingLedgerChat
missingWorkingMessage
missingWorkingChat
ambiguousWorkingChat
alreadyProjected
notYetSupported
```

This keeps the next step inside the established architecture spine:

```text
facts
→ semantic projection readiness
→ diagnostic policy meaning
→ no mutation yet
```

Only after the preview demonstrates stable endpoint mapping should a mutation slice write canonical topology into `working_shadow.db`.

---

# Provenance-Preserving Projection

When projection mutation is eventually introduced, projected relationships should remain traceable back to source topology.

Open design choice:

```text
store source topology reference directly on projected relationship rows
```

or:

```text
store canonical relationship rows separately from source provenance sidecar rows
```

The second option is more production-shaped for multi-source support, because multiple source rows may support one canonical relationship.

Important invariant:

```text
Projection may canonicalize endpoints, but it must not discard source topology provenance.
```

Provenance is needed for:

- debugging archive/live disagreements
- explaining canonicalization choices
- rollback/reprojection
- comparative validation
- future conflict resolution

---

# Multi-Source Considerations

Future archived source import can create cases that the live-only pilot does not yet exercise.

## Same Message GUID in Multiple Sources

Two sources may contain the same message `guid` with different source row IDs.

Possible projection meaning:

```text
source A message row 10
source B message row 999
→ same canonical working message
```

The topology rows from both sources may still be true source facts, even if they point to one canonical message after dedupe.

## Same Chat Represented Differently

Archived and live `chat.db` files may represent a conversation with:

- different source chat row IDs
- different chat GUIDs
- different participant membership at different points in time
- changed display names
- split/merged source chat rows

Projection must not assume that equal source row IDs or similar identifiers imply equal canonical chat identity.

## Conflicting Source Topology

One source may say a message belongs to chat A while another says the equivalent message belongs to chat B.

Both may be valid source observations from different database snapshots.

Projection must decide app truth without deleting source truth.

Possible future policy choices:

- prefer live source topology
- preserve multiple source-backed relationships
- mark conflict for diagnostics
- choose latest source by source timestamp/fingerprint

None of those policies should be hidden inside importers.

## Multiple Archived Sources

The design must support more than one archived source folder.

Therefore all topology projection logic should key source facts by:

```text
source_id + source_table + source_rowid
```

or table-specific equivalents where table context is implicit.

---

# Placeholder Chat Implications

The current placeholder chat is a structural shim, not source truth.

It exists because the narrow shadow message projection needed a schema-compatible destination before topology projection existed.

The placeholder should not be treated as:

- canonical chat identity
- source chat identity
- evidence of source topology
- a participant-bearing conversation

It can be removed, bypassed, or made irrelevant only after projection can map:

```text
source chat/message topology
→ canonical working chat/message relationship
```

That change should occur in projection/migration logic, not in importers.

Do not remove the placeholder during source import. Import remains source-truth preservation; projection owns app-truth shape.

---

# Explicit Non-Goals

This design does not propose:

- UI relationship behavior
- search relationship behavior
- canonical chat conflict resolution
- multi-source UI
- archive source import
- graph/topological planner execution
- production migration replacement
- attachment topology projection
- chat-handle participant projection
- deletion or replacement of placeholder chat behavior

Those remain future slices.

---

# Open Questions

1. Should working topology use a direct relationship table with provenance columns, or a canonical relationship table plus provenance sidecar?
2. What is the first acceptable canonical chat identity rule for shadow projection: source chat GUID, source row mapping, participant topology, or a deliberately temporary rule?
3. How should source-orphaned messages without `chat_message_join` be represented in the projection preview?
4. Should a single canonical message be allowed to have multiple projected canonical chat relationships when multiple sources disagree?
5. Should live source topology receive priority over archive topology in conflict cases, or should conflict be represented explicitly?
6. What validation proves that placeholder chat behavior is no longer needed?
7. Should topology projection emit comparison diagnostics against production working relationships before any mutation is introduced?

---

# Risks

- Premature canonicalization can collapse distinct source facts into one app identity without evidence.
- Directly projecting topology without endpoint preview can hide missing chat/message mappings.
- Treating source row IDs as working IDs will break multi-source archive support.
- Removing placeholder chat behavior too early can destabilize message projection before topology projection semantics are proven.
- A relationship table without provenance may be hard to debug, compare, or reproject later.

---

# Candidate Invariants To Promote

Potential invariants to add after the read-only projection preview is validated:

```text
Working topology projection must be source-provenance traceable.
```

```text
Source topology facts may be canonicalized, but they must not be erased by canonicalization.
```

```text
Placeholder structural chats must not become canonical topology evidence.
```

```text
Endpoint resolution must happen before topology mutation.
```

---

Implemented a read-only topology projection preview slice.

Added:

- Domain models:
  - `TopologyProjectionPreviewFact`
  - `TopologyProjectionPreviewResult`
  - `TopologyProjectionPreviewSummary`
- Status sealed union:
  - `projectable`
  - `missingLedgerMessage`
  - `missingLedgerChat`
  - `missingWorkingMessage`
  - `missingWorkingChat`
  - `ambiguousWorkingChat`
  - `alreadyProjected`
  - `notYetSupported`
- Read-only repository:
  - `TopologyProjectionPreviewRepository`
- Reader/provider chain under:
  - `application/topology_projection_preview/readers/`
- Integrator/provider chain under:
  - `application/topology_projection_preview/integrators/`

Endpoint resolution strategy:

- `source_id + source_message_rowid`
  → `macos_import_shadow.db.messages`
  → ledger message `guid`
  → `working_shadow.db.messages`
- `source_id + source_chat_rowid`
  → `macos_import_shadow.db.chats`
  → ledger chat `guid`
  → `working_shadow.db.chats`

The repository only reads. It does not mutate `working_shadow.db`, create topology tables, alter migration, or touch pipeline ordering.

Added focused tests for:

- successful endpoint resolution
- missing ledger message
- missing ledger chat
- missing working message
- missing working chat
- ambiguous working chat via pure integrator input
- fake archive source isolation
- provenance preservation
- no working DB mutation during preview reads

Verification:

- `dart run build_runner build --delete-conflicting-outputs`
- focused preview + topology tests passed
- `dart analyze` on changed files passed

Current data spot check:

- Bounded preview of the first 250 live-source topology rows showed:
  - `missingWorkingChat`: 250
  - no ambiguity in that sample

That matches the current architecture: source topology is preserved in the shadow ledger, but canonical working chat relationship projection is still deferred.
