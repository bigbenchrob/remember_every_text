---
created_at: 2026-05-20T13:03:42-07:00
title: "extract attributed body blob"
tags: []
source: codex_prompt_history.html
---

# extract attributed body blob

## Prompt

```text
Implement SS rich-text enrichment as a separate enrichment stage, not inside the main MessageImporter.

Context:
The selected-chat SS message view revealed many rows showing:

no text

Investigation showed the issue is NOT incorrect topology or reaction handling.

The issue is:

* source message.text is NULL
* text actually exists in attributedBody
* the current SS flow is not yet running the Rust attributed-body extractor

Legacy architecture already solved this using a separate enrichment stage:

* messages imported first
* later MessageRichTextImporter filled missing text using the Rust extractor

We should preserve that architectural separation in the SS proof.

Goal:
Add a separate SS rich-text enrichment stage.

Do NOT embed attributedBody decoding directly into MessageImporter.

Desired flow:

Import Messages
→ Enrich Missing Text
→ Project Messages

Implement:

1. Add SS rich-text enrichment component

Suggested name:

MessageRichTextEnricher

or:

SourceScopedRichTextEnricher

inside:

incremental_update_ss/

Responsibilities:

* find import_ss.messages rows where:
    * text IS NULL
    * attributed_body_blob IS NOT NULL
* run existing Rust attributedBody extraction logic
* update import_ss.messages.text with extracted text
* leave attributed_body_blob intact in import_ss

Do NOT:

* alter ss_id
* alter topology
* alter projection logic broadly

2. Preserve architectural separation

Import stage:

preserve source facts

Enrichment stage:

derive app-usable text

Projection stage:

project best available text into working_ss

3. Update dev-panel orchestration

Current dev-panel flow likely runs:

Import
→ Project

Change to:

Import
→ Enrich Missing Text
→ Project

Sequential execution is sufficient.

No polling/orchestration redesign needed.

4. Add diagnostics

Add simple diagnostics/readouts if practical:

messages needing enrichment
messages enriched
messages still null after enrichment

5. Verify selected group chats

Re-run the previously failing long-running group chat.

Expected result:

* recent messages should now display normal text
* no-text rows should drop dramatically
* topology should remain unchanged

6. Tests

Add/update focused tests for:

* attributed_body rows enriched correctly
* existing text rows untouched
* NULL attributed_body rows skipped
* enrichment idempotence
* projection receives enriched text
* working_ss.messages.text populated correctly

7. Constraints

Do NOT:

* redesign graph architecture
* merge enrichment into importer
* remove attributed_body_blob from import_ss
* add new abstraction layers
* redesign message projection broadly

Do:

* preserve staged architecture
* keep import/enrichment/projection conceptually separate
* reuse existing Rust extraction behavior where practical

Verification:

* run full SS flow on real data
* inspect previously failing group chat
* confirm message text now appears correctly
* dart analyze on changed files

Response style:
Keep response under 12 lines.

Report only:

* files changed
* enrichment stage added
* enrichment counts observed
* selected-chat behavior after enrichment
* tests run
* blockers if any
```
