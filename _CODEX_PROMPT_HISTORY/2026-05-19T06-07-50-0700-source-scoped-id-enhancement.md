---
created_at: 2026-05-19T06:07:50-07:00
title: "source scoped id enhancement"
tags: []
source: codex_prompt_history.html
---

# source scoped id enhancement

## Prompt

```text
Documentation refinement task: formalize the relationship/join projection implications of SourceScopedRowKey.

Context

The architecture has now stabilized around this invariant:

SourceScopedRowKey is the canonical working-row identity
for source-derived projected rows.

This restores an important simplification that previously existed in the single-source architecture:

source relationships are already correct in Apple chat.db

The original architecture could often reuse Apple relationship topology directly because source ROWIDs were globally meaningful within one source database.

Multiple sources broke that assumption because:

source A rowid 42
!=
source B rowid 42

However, SourceScopedRowKey restores the same simplicity at a multi-source-safe level.

Key realization

Relationship endpoints themselves must become source-scoped canonical working identities.

Examples:

chat_source_scoped_row_key
message_source_scoped_row_key
handle_source_scoped_row_key
attachment_source_scoped_row_key

This means source-local relationship tables can project almost mechanically into working topology.

Example

Source topology:

source_id = 2
source_chat_rowid = 7
source_message_rowid = 42

Working topology:

chat_id = pack(2, 7)
message_id = pack(2, 42)

This dramatically simplifies:

* topology projection
* joins
* provenance
* replayability
* projection repair
* multi-source support
* relationship correctness

without requiring canonical remapping layers.

Goal

Update the source-scoped identity docs to formally define the implications for relationship/join projection.

Likely files to update

* 64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md
* possibly:
    * 60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md
    * 62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md
    * 00-TERMINOLOGY
    * 30-INVARIANTS.md

Requested additions

Please add a clearly named section such as:

Join Endpoint Projection Invariant

or equivalent.

The section should formalize:

Every source-local relationship endpoint
must be transformed into the corresponding
SourceScopedRowKey before entering working projection.

Examples to discuss

Potential relationship tables:

chat_message_join
chat_handle_join
message_attachment_join
message reply/reaction relationships
future topology tables

Clarify projection semantics

Import ledger preserves:

source_id
source_rowid
source_chat_rowid
source_message_rowid

Working projection transforms endpoints into:

SourceScopedRowKey

Clarify architectural benefit

Explicitly document that this restores the original simplicity:

source relationships are already correct

while remaining multi-source-safe.

Clarify what is avoided

Document that this strategy avoids:

* canonical endpoint remapping layers
* relationship lookup tables
* ambiguous projection joins
* source-collision bugs
* merge-collapse identity instability

Constraints

Do NOT:

* redesign topology
* redesign projection pipeline
* introduce semantic merge systems
* introduce canonical remapping layers
* alter runtime behavior

Do:

* sharpen the invariants
* document the implications clearly
* keep the architecture internally consistent
* preserve the occurrence-preserving identity model

Response style

Keep the response terse.

Report only:

* files updated
* sections added/revised
* any unresolved architectural questions
```
