# Review

---

## Surface

Messages sidebar -> Conversations -> Browse mode -> Show and Sort controls.

This review covers the paired filtering and sorting controls that organize the
conversation signature list.

---

## Purpose

The Show and Sort controls should help the user reduce a large conversation
library into a more manageable, meaningful set.

They should support quick shifts in perspective without turning the sidebar
into a dashboard or moving browse controls into the center pane.

---

## User Goals

- Reduce the number of visible conversations.
- Bring important or active conversations into view quickly.
- Change the conversation list order based on the current browsing goal.
- Understand the difference between filtering the list and sorting the list.
- Keep the center pane focused on the selected conversation evidence.

---

## Current Behaviour

In Browse mode, the Conversations sidebar shows two dropdown controls:

- Show
- Sort

They are grouped in a slightly darker gray control region beneath the
Favourites/Browse mode toggle and above the conversation signature list.

Current user-observed useful configuration:

- Show: High activity
- Sort: By date of creation / Longest first-to-last span

This configuration surfaces important, frequently updated family/friend
conversations without requiring the user to scroll through the full conversation
library.

---

## What Works Well

- The controls belong in Browse mode. Even users with relatively few contacts
  can have enough conversations that browsing needs organization.
- Show and Sort together provide useful reduction and ordering of the
  conversation library.
- The slightly darker gray grouped-control background sets the controls apart
  from conversation cards without making them feel heavy.
- The labels "Show" and "Sort" have the right weight and prominence.
- The Show choices are broadly meaningful, with one revision now identified:
  add `All` and remove `Dormant/revived`.
- "High activity" is useful for quickly surfacing important recurring
  conversations.
- `Dormant/revived` initially seemed interesting, but focused review now
  suggests removing it from Show and representing dormancy as a Sort option.
- The current control placement keeps the sidebar as the navigation/browsing
  surface and preserves the center pane for message evidence.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | Sort choices need focused review before implementation changes. |
| Medium | Some Sort labels may be less immediately clear than the Show labels. |
| Medium | The relationship between "High activity" as a Show option and activity-related Sort options may need clarification. |
| Medium | `Dormant/revived` should be removed from Show and replaced by a clearer `Dormant` Sort option. |

---

## UX Observations

- These controls earn their place because the conversation list can be too large
  to scan manually.
- The current grouping and visual weight are directionally correct.
- Filtering and sorting are complementary: Show narrows the universe; Sort
  changes the order within that universe.
- The immediate next UX work should focus on Sort labels/options rather than
  questioning the existence of the control pair.

---

## Proposed Improvements

Keep the Show and Sort controls in Browse mode.

For now:

- preserve the grouped-control visual treatment
- preserve the Show control, but update options during the Sort implementation
  pass: add `All`, remove `Dormant/revived`
- focus the next review on Sort options, labels, and defaults

Do not implement changes from this combined review until the Sort-specific
review has clarified what should change.

---

## Acceptance Criteria

- [x] The review records that Show and Sort belong in Browse mode.
- [x] The review records that the grouped gray background works.
- [x] The review records that the Show and Sort labels have appropriate
      prominence.
- [x] The review records that Show options are useful enough to keep for now.
- [x] The review records that Sort needs focused follow-up review.
- [x] No implementation is proposed until Sort-specific changes are clarified.

---

## Notes

Related focused review to complete next:

- `sort_conversations_menu.md`

---

## Status

- [ ] Not Started
- [x] Under Review
- [ ] Ready for Codex
- [ ] Implemented
- [ ] Verified
