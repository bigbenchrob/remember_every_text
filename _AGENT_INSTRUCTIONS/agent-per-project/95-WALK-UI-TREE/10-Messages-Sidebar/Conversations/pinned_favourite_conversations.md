# Review

---

## Surface

Messages sidebar -> Conversations -> favourited conversations.

This review covers how favourited conversations are exposed in the Conversations sidebar and how they relate to the normal browse/search/filter/sort conversation list.

---

## Purpose

Favourites should give the user fast access to a small curated set of important conversations without making ordinary conversation browsing harder.

The user should be able to switch between:

- a focused list of favourite conversations
- the normal browse/search/filter/sort conversation library

without losing the currently selected conversation in the center evidence pane.

---

## User Goals

- Quickly open daily or important conversations.
- Browse, search, filter, and sort the broader conversation library.
- Understand whether they are looking at curated favourites or the browseable conversation library.
- Add or remove favourites using the existing star affordance.
- Keep reading the currently selected conversation while changing sidebar browsing mode.

---

## Current Behaviour

Favourited conversations appear as a block above the normal Conversations sidebar controls.

The sidebar currently stacks:

- Favourites section
- search field
- filter menu
- sort menu
- normal conversation list

This works when there are only one or two favourites. As the favourite count grows, the favourites block consumes vertical space and pushes the browse controls and normal conversation results downward.

---

## What Works Well

- The star affordance makes favouriting easy to understand.
- Favourite conversations use the same conversation-card language as normal conversation rows.
- Favourites correctly represent global user intent attached to a conversation rather than local list position.
- The current placement makes favourites visible and discoverable when the list is short.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | Favourites and Browse currently compete for the same vertical sidebar space. Several favourites can push browse controls and results too far down. |
| High | The current hierarchy treats favourites as an embedded block inside Browse, but the user intent is better understood as a separate sidebar mode. |
| Medium | Search/filter/sort controls remain visible even when the user may simply want quick access to favourites. |
| Medium | If there are no favourites, disabling or visually muting the Favourites affordance would make the feature less discoverable. |
| Low | The current layout risks making favourites feel like a large pinned header rather than a focused curated mode. |

---

## UX Observations

- "Favourites" and "Browse" are distinct navigation intents, not sections of one long list.
- "Browse" is clearer than "All" because the normal mode is not merely all conversations; it also includes search, filtering, sorting, and exploration.
- Favourites mode should feel light and fast, not like a separate app area.
- Browse mode should preserve the current exploration tools without also carrying a favourites block above them.
- The center pane should remain a stable evidence-reading surface. Changing sidebar mode should not clear or reset a selected conversation unless the user explicitly selects another conversation.

---

## Proposed Improvements

Add a lightweight section-level mode control beneath the existing Conversations selector:

- Favourites
- Browse

Favourites mode:

- Shows only favourited conversations.
- Does not show search/filter/sort controls.
- Does not show the full conversation list.
- Uses an explanatory empty state when no favourites exist:

  ```text
  No favourite conversations yet.
  Click the star beside a conversation to add it here.
  ```

- May give favourite cards slightly more breathing room than browse rows, while preserving the shared conversation-card language.

Browse mode:

- Shows the existing search/filter/sort controls.
- Shows the normal conversation list.
- Does not include a separate favourites block above the controls.

Mode switching:

- Switching between Favourites and Browse changes sidebar navigation context only.
- The currently selected conversation remains selected in the center pane unless the user explicitly selects a different conversation.
- The star affordance remains available wherever conversation cards appear.

---

## Acceptance Criteria

- [x] A lightweight Favourites/Browse segmented control appears below the Conversations selector.
- [x] Favourites mode shows only favourited conversations.
- [x] Favourites mode hides Browse search/filter/sort controls.
- [x] Favourites mode hides the normal unfavourited conversation list.
- [x] Browse mode shows search/filter/sort controls and the normal conversation list.
- [x] Browse mode does not duplicate a separate favourites block above the browse controls.
- [x] Empty Favourites mode remains accessible and shows the explanatory empty state.
- [x] Switching between Favourites and Browse does not clear or reset the current center-pane conversation selection.
- [x] Conversation cards retain the current shared visual language unless explicitly changed in a later review.
- [x] The mode toggle feels like a sidebar section control, not a major app-level tab.

---

## Notes

This review intentionally does not change:

- the top Messages / Settings area
- the Conversations selector
- the conversation card visual language
- the favourite star semantics
- the center message evidence rendering

Any later changes to conversation-card styling should be handled through the separate conversation card review.

---

## Status

- [ ] Not Started
- [x] Under Review
- [ ] Ready for Codex
- [x] Implemented
- [x] Verified
