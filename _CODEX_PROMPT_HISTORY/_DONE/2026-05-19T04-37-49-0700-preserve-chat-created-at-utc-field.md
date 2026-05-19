---
created_at: 2026-05-19T04:37:49-07:00
title: "Preserve chat.created_at_utc field"
tags: []
source: codex_prompt_history.html
---

# Preserve chat.created_at_utc field

## Prompt

```text
You’re right to stop here. That refinement likely went too far.

The distinction should be:

Do not synthesize display_name from chat_identifier.

But:

Do preserve real source timing fields if Apple chat.db provides them.

If legacy macos_import.db.chats.updated_at_utc is mostly non-null, then shadow should probably preserve the same source-derived value unless there is a documented reason not to.

So the next correction is narrow:

Audit legacy chat import timing semantics
→ identify which source field populates updated_at_utc
→ make ChatImporter preserve that same source fact

Do not guess the Apple column name. Have Codex inspect the legacy importer/source docs/tests and align shadow with proven behavior.

Prompt:

Correction task: audit and restore source-derived chat timing preservation in ChatImporter.

Context

A recent cleanup intentionally stopped synthesizing display_name from chat_identifier, which is good.

However, the same change also stopped populating created_at_utc and updated_at_utc in the shadow chat ledger.

That may be wrong.

Observation

In legacy macos_import.db.chats:

* created_at_utc appears mostly null
* updated_at_utc appears mostly non-null

In shadow macos_import_shadow.db.chats:

* updated_at_utc is currently null

This suggests shadow ChatImporter may be failing to preserve important source-derived chat timing data that the legacy importer already captures.

Working projection also has fields such as:

* last_message_at_utc
* last_message_preview

so chat timing/enrichment may be important downstream.

Goal

Audit legacy chat timing semantics and align the shadow ChatImporter with proven source-derived behavior.

Important distinction

Keep the display-name cleanup:

* do not synthesize display_name from chat_identifier
* do not use display_name for identity/canonicalization/topology resolution

But do not discard real source timing facts.

Tasks

1. Inspect legacy chat import path.

Determine:

* which source field(s) populate macos_import.db.chats.updated_at_utc
* whether created_at_utc is intentionally null
* whether timing values are source-derived, computed, or migration-derived
* whether any conversion/normalization occurs

2. Inspect Apple chat.db.chat source schema / source-contract docs.

Do not infer column names.

Use existing source-contract docs or actual schema/query logic already present in the project.

3. Update shadow ChatImporter if appropriate.

If updated_at_utc is a real source-derived chat fact:

* preserve it in macos_import_shadow.db.chats.updated_at_utc
* use the same conversion/normalization semantics as legacy where possible
* add tests

If created_at_utc is not available or intentionally null:

* keep it null
* document why

4. Correct docs/invariants.

Update any docs from the previous cleanup that imply timing fields are meaningless ledger noise.

Clarify:

* display-facing metadata should not become identity
* but source-derived timing facts should be preserved when meaningful and used downstream

Constraints

Do NOT:

* reintroduce display_name synthesis
* use display_name for identity
* invent timing fields
* guess Apple source columns
* change topology import
* change pipeline order
* change working projection behavior
* add schema changes unless clearly required

Do:

* preserve meaningful source truth
* align shadow behavior with legacy where legacy behavior is proven correct
* keep the correction narrow
* add focused tests

Tests

Add/update tests verifying:

* display_name is not synthesized from chat_identifier
* updated_at_utc is preserved when source/legacy semantics support it
* created_at_utc remains null if no source meaning exists
* chat provenance and source-scoped cursor behavior remain unchanged
* topology preview logic does not depend on display_name

Verification

Run:

* dart analyze on changed files
* focused chat importer tests
* affected topology preview tests if touched

Report back with:

* legacy timing source identified
* whether updated_at_utc was restored
* whether created_at_utc remains null and why
* docs corrected
* tests run
```
