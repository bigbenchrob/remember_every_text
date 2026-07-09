# Implementation Plan

Related Review

- [pinned_favourite_conversations.md](pinned_favourite_conversations.md)

---

# Objective

Change Conversations sidebar favourites from an embedded block above Browse controls into a lightweight Favourites/Browse sidebar mode switch.

The goal is to preserve quick access to curated conversations while preventing favourites from consuming the vertical space needed for browsing, searching, filtering, and sorting the broader conversation library.

---

# Scope

This implementation should modify only the Conversations sidebar favourites/browse presentation and state needed to support the two modes.

In scope:

- Add a Favourites/Browse mode control below the Conversations selector.
- Render only favourite conversations in Favourites mode.
- Render search/filter/sort controls and normal conversation results in Browse mode.
- Add the no-favourites empty state.
- Preserve selected conversation evidence in the center pane while switching modes.

Out of scope:

- Changing the Messages / Settings top area.
- Changing the Conversations selector.
- Redesigning conversation cards.
- Changing favourite persistence semantics.
- Changing message evidence rendering.
- Adding new search/filter/sort behavior.

---

# Constraints

- Preserve existing functionality.
- Maintain architectural boundaries.
- Do not introduce duplicate conversation-card widgets.
- Keep behaviour consistent with the rest of MessageLens.
- Minimize unnecessary code churn.
- Sidebar mode is navigation context only; it must not imperatively clear the center pane.
- Favourites remain a global user-intent overlay on conversation identity.
- Use "Browse", not "All", for the non-favourites mode.

---

# Tasks

- [x] Identify the existing Conversations sidebar state/composer responsible for rendering favourites, controls, and conversation results.
- [x] Add a small typed sidebar mode state for `favourites` and `browse`, using existing overlay/sidebar persistence only if the current Conversations sidebar mode choices are already persisted there.
- [x] Render a lightweight Favourites/Browse segmented control beneath the Conversations selector.
- [x] In Favourites mode, render favourite conversation cards only.
- [x] In Favourites mode, render the explanatory empty state when no favourites exist.
- [x] In Browse mode, render the existing search/filter/sort controls and normal conversation list.
- [x] Remove the embedded favourites block from Browse mode.
- [x] Ensure switching modes does not change the current selected conversation/message evidence spec.
- [x] Verify favourite toggling still works from any rendered conversation card.

---

# Expected Files

Likely files to inspect or modify:

- `lib/features/messages/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart`
- `lib/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_display_provider.dart`
- `lib/features/messages/application/sidebar_cassette_spec/` related Conversations sidebar state/composer files, if mode state already belongs nearby
- Existing overlay-intent provider files only if mode persistence already uses that boundary
- Focused widget/provider tests for the Conversations sidebar, if existing test coverage is available

Do not modify database import, graph projection, message evidence spine, or conversation card internals unless implementation proves a narrow dependency is unavoidable.

---

# Testing

Verify:

- Favourites mode with zero favourites shows the explanatory empty state.
- Favourites mode with several favourites remains usable and does not show Browse controls.
- Browse mode shows search/filter/sort controls and normal conversation results.
- Browse mode does not duplicate favourited conversations in a separate top block.
- Toggling a conversation star updates the appropriate mode/list on refresh.
- Switching Favourites/Browse preserves the selected center conversation.
- Switching top-level sidebar surfaces and returning to Conversations does not regress existing conversation selection behavior.
- Visual spacing remains consistent with sidebar cassette standards.

---

# Definition of Done

- All review acceptance criteria are satisfied.
- No center-pane clearing or reset is introduced by sidebar mode switching.
- No duplicate conversation display widget is introduced.
- Favourites remain a global conversation overlay, not local list ordering.
- No unrelated UI, data, or architecture changes are included.
- Review document is updated if implementation differs from this proposal.
