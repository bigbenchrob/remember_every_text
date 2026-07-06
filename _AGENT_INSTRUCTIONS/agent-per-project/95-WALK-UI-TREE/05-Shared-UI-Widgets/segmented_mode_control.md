# Review

---

## Surface

Shared segmented mode control.

Initial observed use: Conversations sidebar Favourites / Browse mode switch.

This review covers the reusable visual and interaction language for lightweight two-option mode switches used inside MessageLens sidebars and similar local control surfaces.

---

## Purpose

The segmented mode control should let the user switch between two local modes without confusing the control for a major app-level tab or navigation destination.

It should communicate three things immediately:

- these two choices belong together
- one choice is currently selected
- the control is lightweight and local to the current sidebar/surface

---

## User Goals

- Quickly understand which mode is active.
- Switch modes without visual ambiguity.
- Recognize both labels as parts of a single control.
- Read selected and unselected labels comfortably in light and dark mode.
- Encounter the same control language wherever MessageLens uses a local two-option mode switch.

---

## Current Behaviour

The current segmented control appears in the Conversations sidebar as:

- Favourites
- Browse

The selected segment uses a dark blue-grey selected background with dark/grey text. This produces weak contrast and makes the selected label harder to read.

The selected segment also appears to have a fuzzy blurred edge or glow, which makes the control feel visually muddy rather than crisp.

The unselected segment has very little visible chrome, so it can read as loose adjacent text rather than the inactive half of one segmented control.

---

## What Works Well

- The two-option segmented pattern is appropriate for Favourites / Browse.
- The control is compact enough for sidebar use.
- The placement makes the local mode relationship easy to understand.
- The labels are concise and user-facing.

---

## Issues

| Priority | Description |
| -------- | ----------- |
| High | Selected text lacks strong contrast against the selected fill. |
| High | The selected pill edge/glow appears fuzzy, making the control feel muddy. |
| Medium | The unselected segment does not clearly read as part of the same control. |
| Medium | The current visual treatment is not yet strong enough to become an app-wide reusable control. |
| Low | The control risks reading as an improvised one-off rather than part of MessageLens' shared UI vocabulary. |

---

## UX Observations

- Sidebar mode switches should feel local and subordinate to the top Messages / Settings area.
- Crispness matters more than ornament: the control should rely on clear fill, border, contrast, and spacing rather than glow or blur.
- Unselected options need enough container context to remain visibly part of the same switch.
- The selected state must remain legible in both light and dark mode.
- This should become a shared widget/style decision, not a Conversations-specific fix.

---

## Proposed Improvements

Create or refine a shared segmented mode control suitable for sidebar-local mode switching.

Desired visual direction:

- clear selected segment fill
- strong selected text contrast
- subtle but visible shared control container
- crisp border or pill treatment
- no fuzzy glow, blur, or muddy selected edge
- lightweight enough to avoid feeling like a major app tab
- reusable for any two-option MessageLens mode switch

The control should support:

- two labelled options
- selected value
- value-change callback
- sidebar-local density
- light and dark mode theme tokens

This review does not prescribe the exact implementation file yet. The later action plan should decide whether this belongs in the existing shared theme widget area, such as `lib/config/theme/widgets/`, or another established shared UI boundary.

---

## Acceptance Criteria

- [x] Selected segment has strong text contrast.
- [x] Selected segment reads clearly as selected.
- [x] Unselected segment still reads as part of the same control.
- [x] Control avoids fuzzy glow, blur, or muddy selected-edge effects.
- [x] Control uses crisp borders, subtle fill, or clear macOS-style pill treatment.
- [x] Control feels lightweight and sidebar-local, not like a major app-level tab.
- [x] Control works in light mode.
- [x] Control works in dark mode.
- [x] Control is reusable anywhere MessageLens needs a two-option local mode switch.
- [x] Conversations sidebar Favourites / Browse uses the shared control when implementation is approved.

---

## Notes

This review intentionally focuses on the shared segmented control visual vocabulary, not on the behaviour of the Conversations Favourites / Browse mode itself.

The Conversations mode split is covered separately in:

- `10-Messages-Sidebar/Conversations/pinned_favourite_conversations.md`

---

## Status

- [ ] Not Started
- [x] Under Review
- [ ] Ready for Codex
- [x] Implemented
- [x] Verified
