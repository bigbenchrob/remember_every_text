# 62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT

## Purpose

This document audits the current `ledger chat → working chat` endpoint resolution problem exposed by the read-only topology projection preview.

The preview reported:

```text
missingWorkingChat: 250
```

for a bounded sample of live-source topology rows.

That result is expected. It means source topology, ledger messages, and ledger chats are present, but the shadow working projection does not yet contain source-derived working chats that can serve as canonical topology endpoints.

This document is diagnostic/design only. It does not define implemented mutation behavior.

---

# Current Observed State

Read-only local audit of the current shadow databases showed:

```text
working_shadow.db.chats
  total rows: 1
  only row:
    id = -1
    guid = __shadow_incremental_update_placeholder_chat__
    service = Unknown

working_shadow.db.messages
  total rows: 132412
  distinct chat_id values: 1
  min chat_id = -1
  max chat_id = -1

macos_import_shadow.db.chats
  source-backed live-chat-db rows: 241

macos_import_shadow.db.chat_message_joins
  source-backed live-chat-db topology rows: 111728

bounded topology projection preview
  missingWorkingChat: 250
```

Interpretation:

- source chats have been imported into the shadow ledger
- source topology has been imported into the shadow ledger
- working messages have been migrated
- working chats have not been source-derived in the shadow path
- every shadow working message currently points to the placeholder chat

---

# Working Chat Schema

`working_shadow.db.chats` uses the existing `WorkingChats` schema:

```text
id
guid
service
is_group
last_message_at_utc
last_sender_handle_id
last_message_preview
unread_count
pinned
archived
muted_until_utc
favourite
created_at_utc
updated_at_utc
is_ignored
```

Current uniqueness:

```text
UNIQUE(guid)
```

There are no source provenance columns on working chats:

- no `source_id`
- no `source_rowid`
- no `source_kind`
- no source-chat mapping sidecar table

Therefore a working chat row is app/canonical state, not direct source truth.

---

# How Working Chats Are Currently Created

## Shadow Path

The current shadow message migration path creates exactly one placeholder working chat:

```text
id = -1
guid = __shadow_incremental_update_placeholder_chat__
service = Unknown
```

Then it inserts all shadow working messages with:

```text
chat_id = -1
```

This is intentional scaffolding from the messages-only migration slice. It allowed message projection to converge before topology projection existed.

The shadow path does not yet run a chat projection/migration stage.

## Production Legacy Path

The legacy `ChatsMigrator` copies ledger chats into working chats using:

```text
working.chats.id = import.chats.id
working.chats.guid = import.chats.guid
working.chats.service = import.chats.service
```

That is production behavior, but it is not yet the shadow topology projection design. It relies on source-like IDs and a single import ledger shape in ways that must be reconsidered for multi-source archive support.

---

# Current Working Chat Identity Meaning

In the current shadow pipeline, working chats are:

- placeholder-driven
- not source-derived
- not canonicalized from source chat identity
- not participant-derived
- not suitable as resolved topology endpoints

The only working chat identifier currently available for resolution is `guid`, but the only existing shadow working chat GUID is the placeholder GUID. It does not correspond to source chat GUIDs.

Therefore the preview correctly reports `missingWorkingChat`.

---

# Ledger Chat Identifiers

The shadow ledger `chats` table currently preserves source-backed rows with:

```text
id
source_rowid
source_id
source_kind
guid
service
display_name
batch_id
```

Observed live-source examples:

```text
source_rowid = 4
guid = any;-;+15147700101
service = iMessage
display_name = +15147700101

source_rowid = 5
guid = any;+;chat965845160131627119
service = iMessage
display_name = chat965845160131627119
```

Useful source-derived identifiers:

- `source_id + source_rowid`
- `guid`
- `service`

Optional display metadata:

- `display_name`

Source-derived timing metadata:

- `created_at_utc`
- `updated_at_utc`

`display_name` is not stable identity. It is frequently empty, and when populated it may duplicate or derive from source chat identifiers. Source timing metadata should be preserved when it maps to verified source fields, but it is also not stable chat identity. These fields must not be used for endpoint resolution, topology projection, canonicalization, or dedupe.

Missing for stronger canonicalization:

- participant topology from `chat_handle_join`
- source archive identity/fingerprint beyond current live source
- conflict/reconciliation metadata

---

# SourceScopedRowKey Revision

This audit originally evaluated `ledger chat → working chat` endpoint resolution through GUID matching and possible mapping tables.

That approach has been superseded by the `SourceScopedRowKey` strategy.

The current invariant is:

```text
SourceScopedRowKey is the canonical working-row identity
for source-derived projected rows.
```

Therefore the projected working chat endpoint for a source chat row should be:

```text
working.chats.id = chat_source_scoped_row_key
```

not:

```text
ledger chat guid → working chat guid
```

and not:

```text
source_id + source_chat_rowid → mapping table → working_chat_id
```

as the ordinary endpoint identity path.

GUID, service, display metadata, participant topology, and timing fields may still inform diagnostics or higher-level semantic grouping, but they are not the base working-row identity for source-derived rows.

---

# Join Endpoint Projection Implication

Once source-derived working chats and messages use `SourceScopedRowKey` ids, source-local topology can project mechanically.

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

This restores the single-source simplicity:

```text
source relationships are already correct
```

while making the endpoints multi-source-safe.

This avoids:

- canonical endpoint remapping layers
- relationship lookup tables for ordinary source-derived endpoints
- ambiguous projection joins
- source-collision bugs
- merge-collapse identity instability

Semantic deduplication, grouping, or merge views can still exist above this layer, but they must not replace occurrence-preserving working row ids.

---

# Recommended Smallest Next Implementation Slice

Recommended next code slice:

```text
read-only SourceScopedRowKey endpoint projection preview
```

The preview should compute, without mutation:

```text
source chat row → chat_source_scoped_row_key
source message row → message_source_scoped_row_key
source relationship row → projected endpoint pair
```

and report whether those source-scoped working endpoint rows exist.

If mutation is chosen after that:

1. Add a narrow source-derived chat projection stage that writes `working.chats.id = chat_source_scoped_row_key`.
2. Keep placeholder chat behavior until source-derived message/chat endpoints are proven.
3. Project `chat_message_join` only after both endpoints exist.
4. Do not introduce semantic merge or canonical remapping behavior.

That sequencing preserves the architecture:

```text
ledger chat facts
→ source-scoped working chat row identity
→ topology endpoint readiness
→ relationship projection later
```

---

# Placeholder Chat Analysis

The placeholder chat enters the shadow working projection in `ShadowMessageMigrationExecutor`.

It exists only to satisfy the current `messages.chat_id → chats.id` foreign key while message migration remains intentionally narrow.

It does not block future working chat resolution, because it can coexist with source-derived working chats:

```text
chats.id = -1
guid = __shadow_incremental_update_placeholder_chat__

chats.id = source-derived/provisional/canonical ids
guid = source chat guid
```

However, it does block topology projection from appearing complete if the resolver expects source chat GUIDs to exist in working chats. The placeholder is not a match for any source chat GUID and must not be treated as one.

Future removal or bypass should happen only after:

- source-derived working chats exist
- topology endpoint preview resolves
- message rows can be reassigned or relationships can be represented without relying on placeholder chat identity

---

# Multi-Source Implications

Live and archive sources may contain:

- same source chat row IDs with different meanings
- same conversation represented by different chat GUIDs
- changed participants over time
- split or merged Apple source chat rows

Therefore:

- source row IDs cannot be working chat IDs
- source GUID matching should be provisional
- source-to-working mapping should eventually preserve source provenance
- conflicts should be observable rather than hidden inside projection mutation

Possible future production-shaped mapping:

```text
source_id + source_chat_rowid
→ source_chat_guid
→ working_chat_id
→ mapping provenance row
```

This allows multiple source chats to support one working chat without erasing the source facts.

---

# Risks

- Copying legacy chat migration behavior directly into shadow projection may reintroduce single-source assumptions.
- Mapping by chat GUID alone may fail for archive/live divergence.
- Mapping by source row ID is not archive-safe.
- Updating message `chat_id` before endpoint preview is stable can hide unresolved topology defects.
- Removing the placeholder too early can destabilize message projection.

---

# Candidate Invariants

Recommended invariants to promote once the next preview slice is validated:

```text
Working chat endpoint projection must use SourceScopedRowKey, not raw source ROWID.
```

```text
Placeholder working chats must not satisfy source topology endpoint resolution.
```

```text
Working chat projection must preserve source occurrence identity directly.
```

```text
Topology relationship projection must wait until both message and chat endpoints are resolvable.
```
