---
created_at: 2026-05-19T04:21:42-07:00
title: "Nix display_name in chats table"
tags: []
source: codex_prompt_history.html
---

# Nix display_name in chats table

## Prompt

```text
Small cleanup/refinement task: stop treating display_name as meaningful ledger identity in the shadow chat pipeline.

Context

Audit findings showed:

* macos_import_shadow.db.chats.display_name is frequently empty
* when populated, it is often derivable from or duplicative of guid
* it is not stable identity
* it is not required for topology preservation
* it is not required for endpoint resolution
* it is not suitable for canonicalization
* current topology preview/projection logic should not depend on it

Examples observed:

guid = any;-;+15147700101
display_name = +15147700101

and:

guid = any;-;+17789908506
display_name = empty

Goal

Reduce accidental semantic weight around display_name in the shadow ledger path.

Important distinction

guid remains the provisional source-derived identity candidate.

display_name should be treated as optional display metadata only, not topology/canonical identity.

Requested changes

1. Audit current shadow chat import/projection code paths.

Determine:

* where display_name is populated
* whether it is synthesized/fallback-filled
* whether any resolution logic currently depends on it

2. Remove or minimize semantic use of display_name.

Preferred direction:

* keep the schema column for compatibility if needed
* stop synthesizing/fallback-populating it
* preserve source value only if directly present from Apple source
* do not use it for:
    * endpoint resolution
    * topology projection
    * canonicalization
    * dedupe
    * identity

3. Add/clarify invariants/docs.

Document something equivalent to:

display-facing metadata must not become canonical identity implicitly

and:

Apple chat GUIDs are treated as opaque source identifiers

4. Ensure projection preview/integrators do not depend on display_name.

Projection should continue using:

ledger.chats.guid
→ working.chats.guid

not display metadata.

Important constraints

Do NOT:

* redesign chat identity
* alter topology import
* alter pipeline ordering
* alter projection-preview statuses
* mutate working topology
* add new schema
* remove the column unless clearly safe and justified
* add UI/display behavior

Do:

* simplify semantics
* reduce accidental identity ambiguity
* keep source truth clean
* keep the change narrow

Tests

Add/update focused tests confirming:

* endpoint resolution does not depend on display_name
* empty/null display_name does not affect projection readiness
* guid remains the provisional endpoint bridge
* no runtime behavior changes unexpectedly

Verification

Run:

* dart analyze on changed files
* focused chat/topology preview tests

Report back with:

* files changed
* whether display_name population behavior changed
* whether any logic depended on it
* invariants/docs added
* tests run
```
