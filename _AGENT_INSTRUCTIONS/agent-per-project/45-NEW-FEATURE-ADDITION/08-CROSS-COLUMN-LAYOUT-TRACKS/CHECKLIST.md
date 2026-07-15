---
tier: project
scope: checklist
owner: agent-per-project
last_reviewed: 2026-07-14
source_of_truth: proposal
status: second-slice-implemented
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
tests: []
---

# Checklist: Cross-Column Layout Tracks

This checklist records a possible future implementation path. It is not
approval to implement.

## Phase 0 - Decision Gate

- [x] Review this package with the user.
- [x] Confirm that the current fixed wrapper model should evolve toward tracks.
- [x] Confirm Search page as the only first implementation target.
- [x] Confirm that the sidebar cassette system is not rewritten in the first
      slice.
- [x] Confirm that current `TitleColumnBand` remains a compatibility wrapper
      during the first Track A slice.
- [x] Defer `ContextColumnBand` / Track B participation until the second
      slice.

## Phase 1 - Model The Track Plan

- [x] Define the minimal concept of a page layout track.
- [x] Define a small `TrackRequirement` object.
- [x] Define a `ResolvedTrackPlan` that maps each track to a resolved
      allocation.
- [x] Keep the model page-level and feature-neutral.
- [x] Avoid direct dependency on Search, Messages, Conversations, or sidebar
      cassette types.

## Phase 2 - Search Page Track A Prototype

- [x] Apply the track plan to the Search page only.
- [x] Map current title band behavior to Track A.
- [x] Preserve existing Search page functionality.
- [x] Preserve current sidebar cassette flow below the top menu.
- [x] Map center metadata subheader behavior to Track B.
- [x] Preserve empty sidebar and right-panel Track B allocations.

## Phase 3 - Participant Requirements

- [x] Let center panel title content declare a Track A requirement.
- [x] Let right Conversation panel title content declare a Track A requirement.
- [x] Let sidebar top menu participate in Track A.
- [x] Let center panel metadata content declare a Track B requirement.
- [x] Let sidebar and right panel declare empty Track B requirements.
- [x] Do not make sidebar cassettes publish automatic Track B participation yet.
- [ ] Let future center/right context or control content declare later-track
      requirements.
- [x] Provide sensible fallback heights matching the current title wrapper
      default.
- [x] Provide sensible fallback heights matching the current context wrapper
      default.

## Phase 4 - Rendering

- [x] Render all Track A participating columns with the resolved track plan.
- [x] Ensure title columns cannot independently choose Track A height.
- [x] Render all Track B participating columns with the resolved track plan.
- [x] Ensure metadata columns cannot independently choose Track B height.
- [x] Keep Track B child placement inside the assigned track allocation.
- [ ] Preserve or adapt developer debug margins to show resolved tracks.
- [x] Do not introduce ad hoc title padding outside the track plan.
- [x] Do not introduce ad hoc Track B padding outside the compatibility wrapper.

## Phase 5 - Validation

- [x] Verify Track A model behavior with focused widget tests.
- [x] Verify Track B model behavior with focused widget tests.
- [ ] Manually verify Search page with no right panel.
- [ ] Manually verify Search page with right Conversation excerpt panel.
- [ ] Verify short and long Conversation Card content.
- [ ] Verify tag/hook/glyph variations on Conversation Cards.
- [ ] Verify light and dark mode.
- [ ] Verify window resizing.
- [ ] Verify sidebar top menu behavior and popover interaction.

## Phase 6 - Documentation

- [ ] Update `09-CROSS-COLUMN-LAYOUT/` if the track model becomes canonical.
- [x] Mark this package as second-slice implemented.
- [ ] Document migration notes from wrappers to tracks.
- [x] Record deferred sidebar cassette participation work.

## Deferred Work

- [ ] Contacts page migration.
- [ ] Conversation Browse page migration.
- [ ] Automatic sidebar cassette content-start selection.
- [ ] General track participation for arbitrary cassette chains.
- [ ] Retiring the old wrapper model.
