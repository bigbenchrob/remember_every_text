---
tier: project
scope: source-scoped-migration
owner: agent-per-project
last_reviewed: 2026-05-21
source_of_truth: doc
links:
  - ./64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md
  - ./65-SOURCE-SCOPED-SS-GRAPH-CHECKPOINT.md
  - ./66-SS-MIGRATION-STRATEGY.md
tests: []
---

# SS Legacy Parity Audit

## Purpose

The source-scoped graph has proven the right architectural direction, but the
legacy import and migration pipeline remains the data-integrity gold standard.
Before replacing legacy behavior, each SS slice must audit the corresponding
legacy importer and migrator for hard-won semantics that should be preserved.

This audit covers the remaining core entities after the handle-alias correction:

- messages
- chats
- contacts

## Audit Principle

Do not copy legacy implementation shape blindly.

Legacy parity does not mean field parity.

Do preserve legacy data-integrity semantics unless there is an explicit reason
to replace them.

The goal is to preserve important source facts, semantic classifications,
traversal behavior, search/review behavior, and data-integrity invariants
without accumulating historical schema baggage.

The SS graph should keep its core invariant:

```text
base working graph = source occurrence identity
semantic/canonical layers = interpretation above base identity
```

## Messages

### Legacy Behavior

Legacy message import preserves substantially more source semantics than the
current SS proof:

- `service`
- `subject`
- `raw_item_type`
- `raw_associated_message_type`
- `message_summary_info`
- `payload_data`
- `has_attributed_body_source`
- `has_message_summary_info`
- `has_payload_data_source`
- `item_type`
- `error_code`
- `is_system_message`
- `thread_originator_guid`
- `associated_message_guid`
- `balloon_bundle_id`
- decoded `payload_json`
- recovered/unlinked message handling

Legacy migration derives app-facing semantics:

- `semantic_kind`
- `is_sparse_artifact`
- normalized `item_type`
- `reaction_carrier`
- attachment presence
- sender handle canonicalization
- chat last-message metadata
- backfill of previously missing sender handles

### Current SS Behavior

Current SS message import preserves:

- `ss_id`
- `source_id`
- `source_rowid`
- `guid`
- `sender_handle_ss_id`
- `is_from_me`
- message dates
- `text`
- `attributed_body_blob`
- `associated_message_guid`

Current SS projection derives:

- `associated_message_ss_id`

Current SS enrichment restores text from attributed body in a separate stage.

### Gaps

The SS message spine is usable, but it is not yet semantically complete.

Highest-risk missing semantics:

- source `item_type` and associated/reaction classification
- system message classification
- payload/balloon/app-message preservation
- message summary info for edited/unsent variants
- sparse/anomalous message classification
- attachment presence integration
- sender-handle alias projection for `sender_handle_ss_id`

### Recommendation

Next message slice should add source semantic preservation before UI behavior
depends more heavily on message classification, but it must follow the narrower
model in
[`68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md`](68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md).

Keep import/enrichment/projection separated:

```text
message import = source facts
rich text enrichment = derived text
message projection = app-ready semantic endpoints and lightweight flags
```

Do not collapse message identity by GUID. `ss_id` remains canonical row identity.

## Chats

### Legacy Behavior

Legacy chat import preserves:

- source row id
- `guid`
- `service`
- display name when present
- `is_group`
- created timestamp
- updated/last-read timestamp
- ignore state

Legacy chat migration projects:

- `service`
- `is_group`
- created/updated timestamps
- ignore state

Legacy message migration later backfills:

- last message timestamp
- last sender handle
- last message preview

### Current SS Behavior

Current SS chat import preserves:

- `ss_id`
- `source_id`
- `source_rowid`
- `guid`
- `service`
- `group_id`
- `original_group_id`
- `last_read_message_at_utc`

Current SS chat projection derives:

- `is_group` from participant topology

Current SS graph queries derive:

- last message timestamp
- last message preview
- participant count
- message count

### Gaps

Current SS chat behavior is mostly aligned with the new graph architecture, but
some legacy semantics remain unaudited:

- `created_at_utc` is not preserved in SS chats
- ignore/visibility semantics are not represented in SS working graph
- last-message metadata is derived at query time rather than materialized
- display name was intentionally removed because it is not stable identity

### Recommendation

Do not reintroduce display name as identity.

Consider adding source-derived `created_at_utc` to `import_ss.chats` and
`working_ss.chats` if user-facing date ranges or chat sorting need it.

Keep `is_group` derived from topology. The earlier nonexistent Apple
`chat.is_group` assumption must not return.

## Contacts

### Legacy Behavior

Legacy contact import preserves all AddressBook records with a source `Z_PK`.
It builds:

- `display_name`
- `short_name`
- first name
- last name
- organization
- created timestamp

Legacy contact channel import preserves:

- email values
- phone values
- labels
- owner contact row id

Legacy participant migration filters only non-meaningful contacts. It does not
require the contact to have a current Messages handle before projection.

### Current SS Behavior

Current SS contact import now preserves:

- source-scoped contact identity
- source row id
- display/short/given/family/organization fields
- created timestamp
- contact channels

Current SS projection:

- projects meaningful contacts even without a current graph handle
- filters `Unknown Contact`-only records
- projects contact-to-handle edges only when a channel matches a graph handle
- resolves through the handle alias layer

### Gaps

Current contact behavior is now aligned with the important legacy integrity
rules.

Remaining cleanup:

- `contact_channels` should be refined to a fully source-row-shaped table.
- AddressBook email and phone source rows have distinct tables, so future schema
  should preserve `source_table` or use separate channel tables.
- overlay-owned manual/virtual contacts remain outside the SS graph and must not
  be migrated into working graph as source truth.

### Recommendation

Do not filter contacts by current handle availability.

Project all meaningful contacts.

Keep contact-to-handle as a relationship edge that can grow as new handles are
imported or aliasing improves.

## Priority Corrections

1. **Message semantic preservation**
   Add source message classification fields to `macos_import_ss.messages` and
   project lightweight semantic flags into `working_ss.messages`.

2. **Contact channel source-row shape**
   Refine `contact_channels` so each imported channel has a deterministic
   source-scoped row identity and source table provenance.

3. **Chat created timestamp**
   Preserve source-derived chat creation time if Apple source data supports it
   reliably.

4. **Message sender handle alias endpoint**
   Decide whether `working_ss.messages.sender_handle_ss_id` should remain the
   source occurrence handle or become the canonical handle alias endpoint.

## Open Architectural Question

For relationship endpoints, topology tables should preserve source occurrence
identity in the base graph.

For semantic fields on an entity row, such as:

```text
working_ss.messages.sender_handle_ss_id
```

we need an explicit rule:

- occurrence endpoint: source sender handle occurrence
- semantic endpoint: canonical sender handle

The handle-alias correction resolved participant topology reads without
rewriting base topology. Message sender display may need both concepts.
