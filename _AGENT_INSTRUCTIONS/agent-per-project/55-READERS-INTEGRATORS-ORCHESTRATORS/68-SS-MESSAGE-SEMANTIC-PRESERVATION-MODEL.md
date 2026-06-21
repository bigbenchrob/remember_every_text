---
tier: project
scope: source-scoped-migration
owner: agent-per-project
last_reviewed: 2026-06-21
source_of_truth: doc
links:
  - ./64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md
  - ./67-SS-LEGACY-PARITY-AUDIT.md
tests: []
---

# SS Message Semantic Preservation Model

## Core Guardrail

Legacy parity does not mean field parity.

The SS architecture must not recreate the legacy message schema simply because
legacy once carried a field. Legacy is the data-integrity reference, not the
target shape.

The target shape is:

```text
source facts
→ lightweight semantic derivation
→ graph/query/review projections
```

The SS graph is not a raw Apple message mirror. It is a traversable,
source-scoped communication graph and semantic exploration layer.

## Preservation Criteria

A legacy-carried message field or semantic should enter the SS architecture only
when it satisfies at least one of these criteria:

- supports a named current or future product behavior
- materially improves search, review, or traversal semantics
- preserves critical source integrity
- enables meaningful semantic classification
- supports timeline correctness
- supports reaction/system-message interpretation
- supports attachment integration
- supports investigative or legal review workflows

## Separation Of Responsibilities

### `macos_import_ss.messages`

The import ledger stores source facts and source-proximate presence signals.

It should not become a UI table.

It may preserve source facts that are not immediately exposed if they are
needed for future semantic interpretation.

### `working_ss.messages`

The working graph stores stable row identity, traversal endpoints, searchable
message content, and small app-ready semantic flags.

It should not carry arbitrary Apple payload internals.

### Query Layers

Readers/integrators derive view-specific or investigation-specific projections.

Examples:

- conversation search overlays
- reaction interpretation
- sparse/anomalous message review
- attachment-aware timeline rendering
- legal review filters

These projections should be derived from source facts and stable working graph
semantics, not from large raw blobs in UI-facing tables.

## Category A: Definitely Preserve As Source Facts

These belong in `macos_import_ss.messages` because they are source facts or
source-proximate primitives that preserve integrity and enable later semantic
interpretation.

| Fact | Suggested import shape | Why preserve |
| --- | --- | --- |
| `raw_item_type` | `raw_item_type INTEGER` | Apple source primitive for message kind and sparse/system classification. |
| `raw_associated_message_type` | `raw_associated_message_type INTEGER` | Required for reaction/associated-message interpretation. |
| `associated_message_guid` | already present | Source fact for Apple associated-message references; projected to `associated_message_ss_id`. |
| `thread_originator_guid` | `thread_originator_guid TEXT` | Source relationship clue for threaded/reply-like behavior; preserve as fact, not UI identity. |
| attributed-body presence | `has_attributed_body_source INTEGER` or derive from blob | Important for text enrichment and sparse-message interpretation. |
| `message_summary_info` presence | `has_message_summary_info INTEGER`; optional blob only if needed later | Edited/unsent semantic signal. |
| `payload_data` presence | `has_payload_data_source INTEGER`; avoid decoded payload by default | App/balloon/special message signal without carrying large internals into working graph. |
| error state | `error_code INTEGER` | Investigative integrity and delivery/anomaly analysis. |
| system flag | source `is_system_message` as raw fact if present | Required for system-message classification. |

### Attachment Presence

Attachment presence is foundational, but it should not be guessed inside
message import.

Current graph-era sequence:

```text
attachment import/topology
→ message attachment endpoint preservation
→ message evidence/query layer attachment semantics
```

Attachment topology now exists through `message_to_attachment`. Message import
still must not fabricate `has_attachments`; readers should derive attachment
presence from graph topology unless a specific, measured query need justifies a
small projected shortcut.

## Category B: Derive Lightweight SS Semantics

These belong in `working_ss.messages` only if they are small, stable, and useful
for query/review/traversal behavior.

| Semantic | Suggested working shape | Why derive |
| --- | --- | --- |
| semantic kind | `semantic_kind TEXT` | Lets timelines/search distinguish plain text, rich text, associated/reaction, system, sparse, attachment-oriented, app/balloon. |
| normalized item kind | `item_kind TEXT` | Stable app vocabulary over raw Apple item types. |
| system message flag | `is_system_message INTEGER` | Fast review/timeline filtering. |
| sparse/anomaly flag | `is_sparse_artifact INTEGER` | Ensures anomalous records remain visible and reviewable. |
| reaction/associated flag | `is_associated_message INTEGER` or encoded in `semantic_kind` | Supports reaction overlays and filtering without exposing Apple internals. |
| attachment presence | derive from `message_to_attachment`; optional projected shortcut only if measured | Timeline/search/review shortcut derived from topology, not message import. |
| canonical sender endpoint | `sender_canonical_handle_ss_id INTEGER` or separate view | Supports participant-centric review while preserving source sender occurrence. |

### Sender Handle Semantics

Do not lose the distinction between source occurrence and semantic endpoint.

Recommended model:

```text
sender_handle_ss_id
= source occurrence handle endpoint

sender_canonical_handle_ss_id
= optional semantic/canonical handle endpoint
```

If only one sender field is kept in `working_ss.messages`, it must be explicit
whether it is occurrence identity or semantic alias identity. The safer model is
to keep both when sender-centric workflows begin to depend on it.

## Category C: Do Not Blindly Reintroduce

These should not be restored solely because legacy carried them.

| Field/semantic | Default decision | Reason |
| --- | --- | --- |
| `balloon_bundle_id` | Do not project to working by default | Only useful if app/balloon review becomes a named product behavior. |
| decoded `payload_json` | Do not project by default | Large implementation detail; preserve presence first. |
| raw `payload_data` blob | Avoid unless a concrete extractor/review use case exists | Heavy Apple-specific payload; risks schema baggage. |
| arbitrary Apple app-message internals | Exclude by default | Not graph identity, not currently traversal-critical. |
| `subject` | Exclude unless real data/use case proves value | Historically available but not yet tied to graph exploration. |

If a Category C field later supports a concrete behavior, add it through a
focused design slice with tests and documented rationale.

## Proposed Minimal SS Message Model

### Import Ledger: `macos_import_ss.messages`

Keep current fields:

- `ss_id`
- `source_id`
- `source_rowid`
- `guid`
- `sender_handle_ss_id`
- `is_from_me`
- `date_utc`
- `date_read_utc`
- `date_delivered_utc`
- `text`
- `attributed_body_blob`
- `associated_message_guid`
- `batch_id`

Add narrowly:

- `raw_item_type INTEGER`
- `raw_associated_message_type INTEGER`
- `thread_originator_guid TEXT`
- `error_code INTEGER`
- `is_system_message INTEGER`
- `has_attributed_body_source INTEGER`
- `has_message_summary_info INTEGER`
- `has_payload_data_source INTEGER`

Defer:

- message summary blob
- payload blob
- decoded payload JSON
- balloon bundle id
- subject

Rationale: the added fields are small, source-proximate, and enough to derive
useful semantic classifications without copying large legacy payload surfaces.

### Working Graph: `working_ss.messages`

Keep current fields:

- `ss_id`
- `guid`
- `sender_handle_ss_id`
- `is_from_me`
- `date_utc`
- `text`
- `associated_message_ss_id`

Add narrowly:

- `sender_canonical_handle_ss_id INTEGER`
- `semantic_kind TEXT`
- `item_kind TEXT`
- `is_system_message INTEGER`
- `is_sparse_artifact INTEGER`
- `has_attributed_body_source INTEGER`
- `has_message_summary_info INTEGER`
- `has_payload_data_source INTEGER`
- `error_code INTEGER`

Defer:

- payload JSON
- balloon/app-message internals
- message-table attachment flag unless a measured query need justifies it
- reaction summary until reaction interpretation is intentionally designed

## Suggested Semantic Vocabulary

Initial `semantic_kind` values should remain small:

- `plain-text`
- `rich-text`
- `associated`
- `system`
- `sparse-artifact`
- `app-or-payload`
- `unknown`

Initial `item_kind` values should remain source-informed but app-owned:

- `text`
- `attachment-oriented`
- `reaction-carrier`
- `system`
- `app-or-payload`
- `unknown`

These names are intentionally product-facing enough to support search/review
filters, but not so detailed that they mirror Apple internals.

## First Implementation Slice

Implement only the minimal model above:

1. Add small source fact columns to `macos_import_ss.messages`.
2. Populate them from `chat.db.message` using existing legacy source logic as a
   reference.
3. Add lightweight semantic columns to `working_ss.messages`.
4. Derive `semantic_kind`, `item_kind`, sparse/system/presence flags, and
   `sender_canonical_handle_ss_id`.
5. Add focused tests for:
   - source facts preserved
   - attributed-body presence preserved
   - message-summary/payload presence preserved
   - associated-message projection still resolves to `ss_id`
   - sender canonical endpoint resolves through handle aliases
   - sparse/system/associated semantic classification

Do not add UI behavior in the first implementation slice.

Do not add message-table attachment semantics merely because topology exists.
Attachment-aware evidence should derive from `message_to_attachment` unless a
specific read-model shortcut is intentionally introduced.

Do not add decoded payload behavior until a concrete review/search use case is
defined.
