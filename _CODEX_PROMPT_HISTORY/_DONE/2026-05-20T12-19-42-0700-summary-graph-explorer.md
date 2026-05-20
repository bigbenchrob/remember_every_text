---
created_at: 2026-05-20T12:19:42-07:00
title: "Summary graph explorer"
tags: []
source: codex_prompt_history.html
---

# Summary graph explorer

## Prompt

```text
What I mean is: stop thinking about the SS graph as an import experiment and start exercising it as a conversational model.

Right now the summaries prove:

* topology works,
* group detection works,
* latest-message derivation works.

But the UX is still “flat debug output.”

The next slice would make the graph explorable.

Use this prompt:

Refine the SS chat summary exploration layer.
Context:
The canonical SS graph is now functioning:
- messages
- chats
- handles
- chat_to_message
- chat_to_handle
The current dev panel already derives:
- participant handles
- participant_count
- is_group
- message_count
- latest message preview
- latest message timestamp
This successfully proved that the SS graph expresses real conversational structure.
Goal:
Improve the SS exploration layer so the graph becomes easier to inspect and reason about.
This is still a dev/proof tool.
Not production UI.
Scope:
- query/read improvements only
- lightweight interaction only
- no new schema work
- no AddressBook integration
- no polished design work
Implement:
1. Add summary filtering modes
Add lightweight filters/tabs/toggles for:
```text id="jlwmf1"
All chats
Group chats only
Single-participant chats only

2. Add sorting modes

Support simple sorting by:

Most recent message
Largest message count
Largest participant count

3. Improve participant readability

Current participant lists are useful but hard to scan.

Improve formatting modestly:

* clearer participant separation
* stable ordering
* avoid duplicate handles
* preserve raw handle ids for now

Do NOT add contact-name resolution yet.

4. Add chat selection state

Allow selecting a chat summary row.

Selection should display:

* chat_ss_id
* participant handles
* participant_count
* message_count
* recent messages preview

This is important because future UX will likely navigate:

contact
→ group chats
→ selected chat
→ scoped timeline

5. Add lightweight recent-message query

For selected chat:
show a small recent-message slice, for example:

* latest 20 messages
* newest first acceptable for now

Fields:

message_ss_id
date_utc
is_from_me
text

No message rendering system needed yet.

6. Add small topology diagnostics

Helpful optional diagnostics:

* orphan chats
* chats with zero handles
* chats with zero messages
* largest group chats
* largest conversations

7. Keep architecture lean

Do NOT:

* add caching systems
* add repository abstraction layers
* integrate old incremental_update code
* add production navigation systems
* add contact/profile logic
* redesign providers broadly

Do:

* exercise the canonical SS graph
* improve inspectability
* help reveal real conversational structure
* keep everything ss_id/topology based

Verification:

* run against real data
* inspect real group chats
* inspect a selected chat
* confirm message slices work
* confirm sorting/filtering works
* dart analyze on changed files

Response style:
Keep response under 12 lines.

Report only:

* files changed
* interaction/query additions
* sample observed behavior
* tests run
* blockers if any
```
