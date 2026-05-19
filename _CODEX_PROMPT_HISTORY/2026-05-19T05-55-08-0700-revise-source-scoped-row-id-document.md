---
created_at: 2026-05-19T05:55:08-07:00
title: "revise source-scoped row id document"
tags: []
source: codex_prompt_history.html
---

# revise source-scoped row id document

## Prompt

```text
Revision task: correct and sharpen the semantics of SourceScopedRowKey in 64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md.

Important correction

The current document over-preserves a hypothetical future “canonical merge” model and therefore understates the intended role of SourceScopedRowKey.

The intended architecture is now:

SourceScopedRowKey IS the canonical app row identity
for source-derived projected rows.

This is a deliberate simplification strategy.

Examples:

working.messages.id
= message_source_scoped_row_key
working.chats.id
= chat_source_scoped_row_key
working.handles.id
= handle_source_scoped_row_key

or equivalent semantics.

The important distinction is NOT:

source-scoped identity vs canonical app identity

The real distinction is:

canonical row identity
vs
semantic deduplication/merge identity

Clarify this explicitly throughout the document.

Key revised semantics

The architecture should now state:

SourceScopedRowKey is deterministic, collision-free canonical app row identity
for source-derived projected rows.

It preserves provenance by construction because the identity itself embeds source scope.

However:

SourceScopedRowKey is NOT a semantic deduplication key.

Example:

source 1 + row 42
→ canonical working row A
source 2 + row 42
→ canonical working row B

These remain distinct canonical working rows even if later analysis determines they represent the same logical message.

Future semantic grouping, deduplication, or merge views should occur ABOVE base row identity.

Examples of future higher-level concepts:

logical_message_group_id
duplicate_cluster_id
semantic_merge_view

These must not replace or destabilize canonical row identity.

Requested document changes

Please revise 64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md accordingly.

Specifically:

1. Remove or rewrite sections implying:

SourceScopedRowKey
is merely provenance identity
and not canonical app identity.

2. Replace with language stating:

SourceScopedRowKey
is canonical working-row identity
for source-derived projected entities.

3. Clarify the new invariant:

source-derived projected rows preserve source occurrence identity directly
rather than collapsing occurrences into merged canonical rows.

4. Introduce the distinction:

canonical row identity
≠
semantic deduplication identity

5. Rewrite provenance discussion accordingly.

Provenance is still preserved, but now because:

canonical identity itself is source-scoped.

6. Rewrite projection discussion accordingly.

The architecture preference is now:

ledger row
→ stable working row with same source-scoped identity

rather than introducing separate canonical remapping layers.

7. Keep the warnings against:

hash
global_rowid
canonical_merge_id

8. Keep the distinction that this is still NOT:

* cross-source semantic merge
* deduplication
* logical-message grouping
* canonicalized conversation collapse

9. Add a concise explicit invariant section like:

# Canonical Row Identity Invariant
SourceScopedRowKey is the canonical identity
of source-derived projected rows.
Canonical app identity is occurrence-preserving,
not merge-collapsing.
Semantic deduplication, grouping, or merge behavior
must exist above this identity layer.

10. Preserve the existing packed deterministic integer semantics and collision-free guarantees.

Important constraints

Do NOT:

* redesign packing mechanics
* redesign topology
* redesign projection pipeline
* introduce merge algorithms
* introduce semantic deduplication
* alter existing runtime behavior

Do:

* make the terminology unambiguous
* remove contradictory wording
* sharpen the invariants
* align the document with the intended simplified architecture

Response style

Keep your response terse.

Report only:

* sections materially revised
* any remaining ambiguities/questions
* no long architectural recap unless necessary
```
