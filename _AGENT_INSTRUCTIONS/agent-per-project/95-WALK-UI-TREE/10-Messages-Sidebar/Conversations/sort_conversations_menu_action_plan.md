# Action Plan

---

## Source Review

`sort_conversations_menu.md`

---

## Goal

Make Conversations Browse sorting clearer and more useful without changing the
center pane, message evidence spine, or conversation card presentation.

---

## Agreed Changes

- Add Show option `All`.
- Remove Show option `Dormant/revived`.
- Replace Sort options with:
  - Most recently updated
  - Most total messages
  - By date of creation
  - Started most recently
  - Longest first-to-last span
  - Dormant
- Disable Sort when the current Browse result set contains six conversations or
  fewer.
- Highlight the summary metadata segment that explains each Sort mode.
- In `Most recently updated` mode, show a quiet time cue next to each
  conversation title only when the conversation was updated today.
- In `Longest first-to-last span` mode, show a quiet month-span cue next to the
  conversation title.
- In `Dormant` mode, mark the last active glyph month with an orange ring while
  preserving the underlying heatmap color; do not also highlight metadata.
- Preserve existing persisted preferences through compatibility mapping.

---

## Implementation Scope

- Conversation signature display filter/sort enums and labels.
- Conversation signature preference storage mapping.
- Conversations sidebar control wiring for disabled Sort state.
- Shared dropdown disabled state support.
- Focused tests for preference compatibility, sort semantics, and disabled
  dropdown behavior.

---

## Out of Scope

- Removing the Conversations search field.
- Adding Working Set UI.
- Changing conversation cards.
- Changing message evidence or center-panel behavior.

---

## Verification

- Focused conversation signature display tests.
- Focused conversation signature preference tests.
- Shared dropdown disabled-state test.
- Analyzer.

---

## Status

- [x] Implemented
- [ ] Verified in app
