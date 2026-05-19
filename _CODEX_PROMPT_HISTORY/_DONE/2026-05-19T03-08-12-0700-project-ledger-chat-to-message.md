---
created_at: 2026-05-19T03:08:12-07:00
title: "Project ledger chat-to-message"
tags: []
source: codex_prompt_history.html
---

# Project ledger chat-to-message

## Prompt

```text
Next task: document design options for projecting source-scoped chat_message_join topology into working_shadow.db.

Context

The shadow incremental-update pipeline now successfully imports and preserves source topology:

* chat_message_join source observation exists
* chat_message_joins source-scoped ledger table exists
* ChatMessageJoinImporter exists
* ChatMessageJoinStageController exists
* topology stage is integrated into PipelineOrchestrator
* large initial topology backfill succeeded
* small incremental message import still works afterward

Current rule:

Import ledger = source truth
Working projection = app truth

Goal

Create a design document for canonical topology projection.

This is documentation/design only.

Do NOT implement projection code yet.

Core design question

How should source-scoped topology facts:

* source_id
* source_chat_rowid
* source_message_rowid

from macos_import_shadow.db.chat_message_joins

be resolved into working projection relationships such as:

* working chat id
* working message id

without losing provenance or assuming a single source forever?

Important constraints

Do NOT:

* write Dart code
* add schema migrations
* alter importers
* alter pipeline ordering
* alter migration behavior
* alter placeholder chat behavior yet
* implement working projection topology
* assume single-source-only semantics
* collapse source provenance into canonical IDs prematurely

Do:

* preserve source truth vs app truth separation
* preserve multi-source safety
* identify required mapping tables/lookup strategies
* identify unresolved questions
* recommend a small first implementation slice afterward

Suggested document location

Under the existing architecture docs, likely:

55-READERS-INTEGRATORS-ORCHESTRATORS/

Suggested filename:

60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md

Topics to cover

1. Source topology facts

Explain what the ledger now preserves:

* source-local join row
* source-local chat row
* source-local message row
* source identity

2. Projection problem

Explain that projection must map:

source-scoped endpoints

to

working/canonical endpoints

without pretending source row IDs are canonical app IDs.

3. Required mapping strategy

Discuss likely mapping needs:

* source message rowid → canonical/import-ledger message GUID → working message id
* source chat rowid → source chat GUID/identifier → working chat id
* source join row → projected working relationship

4. Provenance-preserving projection

Explain why working relationships should likely remain traceable back to source topology rows.

Potentially discuss whether working projection needs:

* canonical relationship rows
* provenance sidecar rows
* source topology reference columns
* conflict/reconciliation metadata

5. Multi-source considerations

Discuss cases like:

* same message GUID appearing in multiple sources
* same chat represented differently across sources
* archived source topology conflicting with live source topology
* multiple lawyers / multiple chat.db sources later
* source-specific topology may all be true even if canonical app projection chooses one relationship

6. Placeholder chat implications

Explain how the current placeholder chat is an import/projection shim, not source truth.

Discuss when it can be removed or bypassed:

* only after source topology can be projected into working relationships
* not during import
* not before topology projection semantics exist

7. First safe implementation slice recommendation

Recommend the smallest next code slice after this doc.

Likely something like:

* read-only topology projection preview
* resolver/integrator that maps source topology endpoints to existing ledger/working IDs
* no mutation initially

or:

* projection mapping table design before mutation

Please compare options and recommend one.

8. Explicit non-goals

Reiterate:

* no UI behavior yet
* no search behavior yet
* no canonical conflict resolution yet
* no multi-source UI yet
* no graph/topological planner yet

Desired output

Report back with:

* document added
* key projection options identified
* recommended first implementation slice
* open questions
* risks or invariants that should be added to architecture docs
```

---

Added the design document:

- `_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`

It covers:

- Source topology facts now preserved in `macos_import_shadow.db.chat_message_joins`
- The projection problem: mapping `source_id + source_chat_rowid/source_message_rowid` to canonical working IDs
- Mapping needs for message endpoints and chat endpoints
- Projection options:
  - direct working relationship rows with provenance columns
  - canonical relationship table plus provenance sidecar
  - read-only projection preview first
  - placeholder-chat replacement during migration
- Multi-source/archive risks and conflict cases
- Placeholder chat implications
- Explicit non-goals
- Open questions and candidate future invariants

Recommended first implementation slice:

- Build a **read-only topology projection preview** that resolves topology endpoints against existing ledger/working facts and reports projectable/unresolved/ambiguous states.
- Do not mutate `working_shadow.db` yet.

No Dart code, schema, importer, pipeline, or migration behavior was changed.
