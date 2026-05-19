---
tier: project
scope: readers-integrators-orchestrators
owner: agent-per-project
last_reviewed: 2026-05-19
source_of_truth: architecture-strategy
links:
  - ./30-INVARIANTS.md
  - ./50-INCREMENTAL-UPDATE-PILOT.md
  - ./60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md
  - ./SOURCE-SCOPED-IDENTITY-AND-RELATIONSHIP-STRATEGY
tests: []
---

# 64 - Source-Scoped Row Key Strategy

## Purpose

This document defines the strategy for globally unique, source-scoped canonical row identity inside the shadow import and projection architecture.

The current incremental-update system already preserves these source coordinates across imported entities:

```text
source_id
source_kind
source_rowid
```

The next architectural step is to formalize a stable, deterministic canonical working-row identity derived from those source-scoped coordinates.

This document defines:

- terminology
- semantics
- invariants
- packing strategy
- relationship endpoint projection rules
- non-goals
- future-proofing rules

The goal is to establish this identity model before widespread implementation occurs.

---

## Core Concept

Apple source databases are not globally coordinated.

Examples:

- live `chat.db`
- archived `chat.db`
- imported historical folders
- future multi-machine imports

Each source owns an independent local `ROWID` space.

Therefore:

```text
ROWID alone is not globally meaningful.
```

The architectural identity boundary is:

```text
(source_id, source_rowid)
```

not:

```text
source_rowid
```

alone.

---

## Terminology

### SourceScopedRowKey

A `SourceScopedRowKey` is a deterministic, collision-free integer identity derived from:

```text
(source_id, source_rowid)
```

within documented bounds.

It is the canonical app row identity for source-derived projected rows.

Examples:

```text
working.messages.id = message_source_scoped_row_key
working.chats.id = chat_source_scoped_row_key
working.handles.id = handle_source_scoped_row_key
```

or equivalent semantics.

Example conceptual mapping:

```text
source_id = 2
source_rowid = 42

→ SourceScopedRowKey = 562949953421354
```

The exact packed integer value is an implementation detail.

The semantic meaning is:

```text
this canonical working row is the projected occurrence from:
  source 2
  row 42
```

---

## Important Clarification

A `SourceScopedRowKey` is not a probabilistic hash.

The implementation must be:

- deterministic
- collision-free
- reversible or structurally decomposable within documented bounds

Different source coordinates must never produce the same key.

---

## Why Not Text Composite Keys?

A rejected alternative was a text key such as:

```text
"sourceId-rowId"
```

Example:

```text
"2-42"
```

This was rejected because it creates:

- larger storage footprint
- slower joins and indexes
- poorer SQLite integer optimization
- weaker long-term projection ergonomics
- unnecessary parsing overhead

SQLite performs extremely well with indexed integer joins, so this architecture prefers packed integer identity.

---

## Preferred Representation

The preferred conceptual implementation is:

```text
SourceScopedRowKey = pack(source_id, source_rowid)
```

Possible implementation forms include:

```text
(source_id << N) | source_rowid
```

or an equivalent deterministic integer-packing strategy.

This document intentionally specifies semantics, not bit layout. That keeps future implementation flexible while preserving the identity contract.

---

## Bounds Invariant

The packing strategy must define explicit numeric bounds.

Example conceptual bounds:

```text
source_id: bounded integer range
source_rowid: bounded integer range
```

The selected ranges must guarantee unique packed identity without overflow inside SQLite signed 64-bit integer limits.

---

## Canonical Row Identity Invariant

`SourceScopedRowKey` is the canonical identity of source-derived projected rows.

The architecture invariant is:

```text
canonical app row identity is occurrence-preserving,
not merge-collapsing.
```

For source-derived projected entities:

```text
ledger row
→ stable working row with the same source-scoped identity
```

Examples:

```text
source 1 + row 42 → canonical working row A
source 2 + row 42 → canonical working row B
```

Those rows remain distinct canonical working rows even if future analysis determines that they represent the same logical message, chat, handle, attachment, or relationship occurrence.

This is a deliberate simplification strategy. Base working-row identity should remain stable, deterministic, and provenance-preserving.

---

## Canonical Row Identity vs Semantic Deduplication

The important distinction is:

```text
canonical row identity != semantic deduplication identity
```

`SourceScopedRowKey` answers:

```text
Which source occurrence does this working row project?
```

It does not answer:

```text
Which source occurrences should be semantically grouped, deduplicated,
or shown as one logical thing?
```

Future higher-level concepts may include:

```text
logical_message_group_id
duplicate_cluster_id
semantic_merge_view
```

Those concepts must live above base row identity. They must not replace, rewrite, or destabilize `SourceScopedRowKey`.

This distinction is critical for:

- archive import
- multi-machine import
- duplicate reconciliation
- provenance
- topology replay
- future merge semantics

---

## Projection Invariant

Projection should preserve source occurrence identity directly.

The preferred projection shape is:

```text
source ledger row
→ source-scoped canonical working row
```

not:

```text
multiple source ledger rows
→ one merge-collapsed canonical working row
```

This keeps projection simple, reversible, traceable, and stable.

Semantic grouping or deduplication can still be built later as a separate layer above the occurrence-preserving working rows.

---

## Join Endpoint Projection Invariant

Every source-local relationship endpoint must be transformed into the corresponding `SourceScopedRowKey` before entering working projection.

Apple source relationship tables already express correct source-local topology. Multiple sources only break the old single-source shortcut because source-local `ROWID` values collide across databases.

`SourceScopedRowKey` restores that simplicity at a multi-source-safe level.

Source topology:

```text
source_id = 2
source_chat_rowid = 7
source_message_rowid = 42
```

Working topology:

```text
chat_id = pack(2, 7)
message_id = pack(2, 42)
```

The import ledger preserves source facts:

```text
source_id
source_rowid
source_chat_rowid
source_message_rowid
source_handle_rowid
source_attachment_rowid
```

Working projection transforms relationship endpoints into source-scoped canonical working identities:

```text
chat_source_scoped_row_key
message_source_scoped_row_key
handle_source_scoped_row_key
attachment_source_scoped_row_key
```

This applies to relationship tables such as:

- `chat_message_join`
- `chat_handle_join`
- `message_attachment_join`
- message reply relationships
- message reaction relationships
- future topology tables

The relationship row itself may also receive its own source-scoped canonical row identity when the source relationship row has a stable source-local row coordinate.

This strategy avoids:

- canonical endpoint remapping layers
- relationship lookup tables for ordinary source-derived endpoints
- ambiguous projection joins
- source-collision bugs
- merge-collapse identity instability

Semantic merge views can still group or reinterpret relationships above this layer, but base working topology should preserve the source occurrence endpoints mechanically.

---

## Provenance Strategy

Provenance is preserved by construction because canonical row identity itself is source-scoped.

A projected row with id:

```text
message_source_scoped_row_key
```

already embeds:

```text
source_id
source_rowid
```

within documented bounds.

This supports:

- provenance
- replayability
- debugging
- traceability
- projection repair
- topology reconstruction

without requiring a separate canonical-remapping layer for base source-derived rows.

---

## Topology Implications

`chat_message_join` topology preservation strongly benefits from source-scoped identity because source relationship endpoints can be projected mechanically.

Example source coordinates:

```text
(source_id, source_message_rowid)
(source_id, source_chat_rowid)
```

can be transformed into:

```text
message_source_scoped_row_key
chat_source_scoped_row_key
```

without ambiguity.

This allows deterministic topology projection using occurrence-preserving canonical working-row identity.

---

## Cursor Semantics

The architecture already established:

```text
ROWID is source-local.
```

Therefore continuation semantics must be scoped by:

```text
source_id
source_table
source_rowid
```

`SourceScopedRowKey` aligns naturally with this invariant, but it does not replace source-scoped continuation queries unless a future implementation explicitly adopts it for that purpose.

---

## Recommended Usage

Prefer names that describe source-scoped provenance explicitly:

```text
message_source_scoped_row_key
chat_source_scoped_row_key
handle_source_scoped_row_key
attachment_source_scoped_row_key
```

Avoid ambiguous names such as:

```text
hash
global_rowid
packed_id
canonical_id
canonical_merge_id
```

unless they are specifically qualified and documented.

---

## Non-Goals

This strategy does not define:

- canonical deduplication
- cross-source message merging
- canonical chat reconciliation
- logical-message grouping
- canonicalized conversation collapse
- projection conflict resolution
- topology projection mutation
- semantic merge views
- graph execution planners

This document defines stable, source-scoped canonical working-row identity for source-derived projected rows.

---

## Architectural Benefit

`SourceScopedRowKey` provides:

- deterministic identity
- compact integer joins
- multi-source safety
- provenance preservation
- topology traceability
- replayability
- projection repairability
- future semantic grouping flexibility

while remaining compatible with the existing architecture spine:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation
```
