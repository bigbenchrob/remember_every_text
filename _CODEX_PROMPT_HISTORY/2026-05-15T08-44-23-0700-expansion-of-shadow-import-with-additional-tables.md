---
created_at: 2026-05-15T08:44:23-07:00
title: "Expansion of shadow import with additional tables"
tags: []
source: codex_prompt_history.html
---

# Expansion of shadow import with additional tables

## Prompt

```text
My prompt:

I have added some new documents to 55-READERS-INTEGRATORS-ORCHESTRATORS in anticipation of the next steps. Please read them and briefly summarize what they suggest about the tasks we should tackle next


-----
Response:

The new docs point toward a careful expansion phase rather than immediately adding more production-like behavior.

Main implications:

Treat macos_import_shadow.db as a persistent shadow ledger, not disposable scratch output. The next tasks should avoid reset-and-rerun workflows and instead make shadow execution resumable, idempotent, and able to continue from durable cursors.

Expand table-by-table, with explicit dependencies. The suggested order is handles, chats, joins, messages relationship upgrades, then attachments. Each slice should get readers, semantic state, policy decision, executor/importer, validation, comparison, and endurance visibility before moving on.

Evolve from narrow executors toward importers. The current ShadowMessageImportExecutor / migration executor proved the spine, but the docs suggest the next architectural move is probably to refactor or introduce a ShadowMessageImporter shape with metadata, continuation strategy, idempotence strategy, validation, and execution events.

Establish source-scoped identity before adding more relationship-bearing tables. The most important design prerequisite is source_id + source_table + source_rowid as provenance identity. This especially matters before importing handles, chats, chat-handle joins, or message relationships, because raw source row IDs are not globally meaningful across live and archived sources.

Separate provenance identity from dedupe/canonical identity. The import ledger should preserve source truth; migration/projection should decide app truth. That means future ledger rows should preserve source-local relationships like source_chat_rowid and source_sender_handle_rowid, while working DB projection resolves those into canonical app-facing IDs.

Suggested next task sequence:

Define the source identity/source row key conventions concretely in the shadow schema/provider layer.
Add or prepare ledger fields/tables needed for source-scoped handles/chats/relationships.
Introduce a small importer abstraction or refactor the current message executor toward an importer shape without building the full graph system yet.
Add the first prerequisite table importer, probably handles or chats, with idempotent continuation and validation.
Add comparative/endurance visibility for that slice before expanding to joins or attachments.
The docs are basically saying: do not chase feature parity yet. Build the source-scoped identity foundation and importer discipline first, then expand the shadow pipeline one causally understandable concern at a time.
```
