---
created_at: 2026-05-19T04:00:49-07:00
title: "62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md"
tags: []
source: codex_prompt_history.html
---

# 62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md

## Prompt

```text
Next task: perform a working-chat endpoint resolution audit for topology projection.

Context

The new read-only topology projection preview slice is working.

Current observed state from the bounded preview:

missingWorkingChat: 250

This is expected and important.

It means:

* source topology exists
* source chats/messages exist in the shadow ledger
* working message resolution likely succeeds
* working chat resolution is not yet established

The preview successfully identified the next missing projection bridge without mutating any working topology.

Goal

Perform a narrow diagnostic/design audit of:

ledger chat
→ working chat

resolution semantics.

This is still diagnostic-only.

Do NOT implement topology projection mutation yet.

Questions to answer

1. What currently exists in working_shadow.db.chats?
2. How are working chats currently created/populated?
3. What identifiers currently exist on working chats?
4. Which fields are stable enough to support ledger-chat → working-chat resolution?
5. Are working chats currently:
    * canonicalized?
    * placeholder-driven?
    * migration-generated?
    * source-derived?
6. What is the smallest safe mapping rule that could resolve:

ledger chat
→ working chat

    without collapsing multi-source semantics prematurely?

Important constraints

Do NOT:

* mutate working_shadow.db
* implement topology projection writes
* remove placeholder chat behavior
* alter migration logic
* alter topology importer
* alter pipeline ordering
* add canonical conflict resolution
* assume single-source forever
* add new schema yet

Do:

* inspect current working chat semantics
* inspect migration-created chat rows
* inspect ledger chat identifiers
* identify possible mapping keys
* identify missing invariants
* identify ambiguity/failure cases
* recommend the smallest next implementation slice

Suggested investigation areas

1. working_shadow.db.chats
    * schema
    * identifiers
    * uniqueness semantics
    * source-related columns if any
2. Shadow migration path
    * where working chats originate
    * whether they are canonicalized already
    * whether placeholder chat dominates current projection
3. Ledger chat identifiers
    * guid
    * service
    * identifiers
    * participant-related metadata already available
4. Resolution candidates

Potential mapping candidates:

ledger chat guid
ledger chat identifier
(source_id + source_rowid)
future participant topology
temporary shadow-only mapping table

Discuss strengths/risks of each.

5. Multi-source implications

Specifically discuss:

* live + archive same conversation
* divergent source chat GUIDs
* participant changes over time
* whether working chat identity should remain provisional initially

6. Placeholder chat analysis

Determine precisely:

* how placeholder chat rows currently enter working projection
* whether they block working-chat resolution
* whether they can coexist temporarily with future canonical chat projection

Desired output

Produce:

* a concise audit/design document
* recommended minimal mapping rule
* recommended smallest safe implementation slice afterward
* explicit risks/invariants

Suggested document location

Likely under:

55-READERS-INTEGRATORS-ORCHESTRATORS/

Suggested filename:

62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md

Verification

No runtime changes expected.

If any exploratory diagnostic code/tests are added:

* keep them read-only
* keep them narrow
* run dart analyze
* report all touched files
```

---

Added the audit/design document:

- `_AGENT_INSTRUCTIONS/agent-per-project/55-READERS-INTEGRATORS-ORCHESTRATORS/62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md`

Key findings:

- `working_shadow.db.chats` currently has exactly one row: the shadow placeholder chat with `id = -1`.
- All current shadow working messages point to `chat_id = -1`.
- `macos_import_shadow.db.chats` has source-backed live chat rows, and `chat_message_joins` has source-backed topology rows.
- Working chats are currently placeholder-driven in the shadow path, not source-derived or canonicalized.
- The preview’s `missingWorkingChat` result is therefore correct.

Recommended minimal mapping rule:

- Use `ledger chat guid → working chat guid` as a provisional shadow-only endpoint bridge.
- Do not use source ROWID as working chat identity.
- Keep the rule explicitly provisional and provenance-explainable.

Recommended next slice:

- Add a read-only working chat endpoint bridge preview:
  - `workingChatResolvable`
  - `missingWorkingChat`
  - `ambiguousWorkingChat`
  - `placeholderOnly`
- If that validates, the next mutation slice would be a narrow shadow chat projection stage that copies source-backed ledger chats into `working_shadow.db.chats` by GUID, without updating message `chat_id` or projecting topology relationships yet.

No Dart code or database behavior was changed for this audit. The existing untracked topology-preview code from the prior task remains untouched.
