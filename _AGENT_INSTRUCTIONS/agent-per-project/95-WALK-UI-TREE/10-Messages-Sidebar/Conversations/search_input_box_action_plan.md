# Implementation Plan

Related Review

- [search_input_box.md](search_input_box.md)

---

# Objective

Remove the low-value "Find conversations" search input from the Conversations sidebar Browse controls.

The goal is to reduce confusion between conversation browsing and message evidence search, while preserving the useful Browse controls that remain: Show and Sort.

---

# Scope

This implementation should modify only the Conversations sidebar Browse control group.

In scope:

- Remove the visible "Find conversations" input from Browse mode.
- Remove local search-query state used only by that input.
- Stop passing sidebar search text into the conversation signature display provider.
- Preserve Show filter behaviour.
- Preserve Sort behaviour.
- Preserve Favourites/Browse mode behaviour.
- Preserve conversation selection and center-pane evidence behaviour.

Out of scope:

- Adding message-content search to Conversations.
- Adding Working Set.
- Changing Contacts -> Conversations.
- Changing All Messages search.
- Redesigning conversation cards.
- Changing conversation signature query semantics except removing the sidebar search filter from this surface.

---

# Constraints

- Preserve existing functionality outside the reviewed search field.
- Maintain architectural boundaries.
- Do not introduce duplicate widgets.
- Keep behaviour consistent with the rest of MessageLens.
- Minimize unnecessary code churn.
- Do not add a replacement search surface in this slice.
- Do not add imperative center-pane clearing or selection repair.

---

# Tasks

- [ ] Locate the Browse control group in `ConversationSignaturesWidget`.
- [ ] Remove the search text controller/state if it is no longer needed.
- [ ] Remove the search input from `_ConversationSignatureControls`.
- [ ] Stop passing search text to `conversationSignatureDisplayProvider` from this widget.
- [ ] Keep Show and Sort controls in the grouped Browse control surface.
- [ ] Update focused tests only if they assert search-field presence or preference behaviour affected by removal.
- [ ] Update the review document if implementation differs from this plan.

---

# Expected Files

Likely files to inspect or modify:

- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
- Focused Conversations sidebar/widget tests, if present
- `test/architecture/forbidden_imports_test.dart` only if the removal changes an existing explicit allowance or message

No database, graph, evidence spine, Contacts, or All Messages files should be modified for this slice.

---

# Testing

Verify:

- Conversations -> Browse no longer shows "Find conversations".
- Browse still shows Show and Sort controls.
- Browse still shows conversation results.
- Show filter still works.
- Sort still works.
- Favourites/Browse mode switching still works.
- Selecting a conversation still updates the center pane.
- Existing conversation selection is not cleared by this change.

---

# Definition of Done

- Search input removed from Conversations Browse controls.
- No replacement search surface added.
- Show and Sort still operate normally.
- Favourites/Browse mode still operates normally.
- No center-pane selection regression.
- Review document updated if implementation differs from the original proposal.
