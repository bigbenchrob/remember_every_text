# Review

---

## Surface

Messages sidebar -> Conversations -> future Working Set display mode.

This review captures the Conversations-sidebar side of a future Working Set
workflow. It does not approve implementation yet.

---

## Purpose

Working Set would let the user temporarily collect conversations relevant to a
current investigation or task, then explore those conversations in the
Conversations sidebar.

It is distinct from:

- Favourites: long-term relationship anchors
- Browse: normal conversation-library exploration

The likely future Conversations hierarchy is:

```text
Favourites | Working Set | Browse
```

---

## User Goals

- Move from message evidence into conversation context.
- Temporarily collect conversations during an investigation.
- Explore a task-specific subset of conversations without making those
  conversations long-term favourites.
- Keep Favourites reserved for stable, personal relationship anchors.
- Avoid cluttering Browse with task-specific temporary state.

---

## Current Behaviour

The Conversations sidebar currently supports:

- Favourites
- Browse

There is no Working Set mode.

Users can approximate a temporary working set by favouriting conversations and
later removing them, but this overloads a long-term user-intent feature.

---

## What Works Well

- The new Favourites/Browse split creates a clear place where a third mode could
  eventually fit.
- Conversation cards already provide a reusable display language for curated
  and browsed conversation sets.
- Center-pane selection is stable across sidebar mode changes, which is the
  right interaction model for a future Working Set mode.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | Working Set cannot be meaningfully displayed until another surface can populate it. |
| High | Showing an empty Working Set now would expose a feature with no obvious way to use it. |
| Medium | Using Favourites as a temporary substitute works but blurs long-term and short-term user intent. |
| Medium | Dummy conversations or fake populated states would misrepresent product behaviour and create cleanup debt. |
| Low | A future three-segment control may need a small spacing/label review once real Working Set data exists. |

---

## UX Observations

- Working Set belongs conceptually beside Favourites and Browse, not inside the
  Browse list.
- Populating Working Set belongs to evidence surfaces, especially All Messages,
  because the user discovers relevant conversations while inspecting matching
  messages.
- Displaying Working Set belongs to Conversations, because the user explores
  collected conversations in conversational context.
- The display mode should not be visible until population, empty-state wording,
  and clearing/removal workflows are designed.

---

## Proposed Improvements

Do not implement Working Set display in the Conversations sidebar yet.

Record the intended future shape:

- Conversations sidebar may eventually use a three-option local mode control:
  `Favourites | Working Set | Browse`.
- Working Set should display conversation cards using the same shared
  conversation-card language.
- Working Set should not use dummy/fake conversations.
- Working Set should remain hidden until All Messages can add conversations to
  it or until a complete empty-state/action workflow is designed.

The implementation dependency belongs to the All Messages review:

- All Messages must be able to add the source conversation for a message result
  to Working Set.

---

## Acceptance Criteria

- [x] Working Set is recorded as a future Conversations sidebar display mode.
- [x] Working Set is explicitly distinguished from Favourites.
- [x] The likely future hierarchy is recorded as `Favourites | Working Set | Browse`.
- [x] The review states that Working Set display is blocked until All Messages can populate it.
- [x] The review rejects dummy/fake conversations for this feature.
- [x] The review states that no Conversations sidebar behaviour should change now.

---

## Notes

Related deferred implementation:

- `95-WALK-UI-TREE/00-Registers/IMPLEMENTATION_DEBT.md`
- `95-WALK-UI-TREE/10-Messages-Sidebar/All-Messages/01-PENDING-IMPLEMENTATIONS.md`

---

## Status

- [ ] Not Started
- [x] Under Review
- [ ] Ready for Codex
- [ ] Implemented
- [ ] Verified
