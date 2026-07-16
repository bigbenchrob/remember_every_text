---
tier: project
scope: checklist
owner: agent-per-project
last_reviewed: 2026-07-16
source_of_truth: proposal
status: c2-fixed-height-occupant-implemented
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
- [x] Confirm that a compatibility wrapper remains during the first Track A
      slice.
- [x] Defer Track B participation until the second slice.

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
- [x] Map current first-row wrapper behavior to Track A.
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
- [x] Provide sensible fallback heights matching the current Track A wrapper
      default.
- [x] Provide sensible fallback heights matching the current Track B wrapper
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

## Phase 4A - TrackOccupant First Slice

- [x] Define a minimal generic `TrackOccupant` contract.
- [x] Define a plain `TrackRequirementContext` for environment inputs needed by
      requirement calculation.
- [x] Define a `ResolvedTrackAllocation` passed to occupant presentation
      construction.
- [x] Add `ResolvedTrackPlan.fromOccupants`.
- [x] Add `TextTrackOccupant` for title and metadata text.
- [x] Add a Search top-menu occupant backed by the same presentation metrics as
      the rendered top menu.
- [x] Replace Search-page Track A/B numeric declarations with occupant-derived
      requirements.
- [x] Represent empty Track B sidebar/right cells by omitting occupants.
- [x] Keep the coordinator feature-blind and free of top-menu/title/card
      branches.
- [x] Preserve the existing compatibility wrappers.
- [x] Do not introduce C2 spacing, Conversation Card occupants,
      glyph occupants, sidebar cassette participation, or Contacts migration.

## Phase 4B - Search-Page C2 Post-Metadata Controls Occupant Slice

- [x] Add `FixedHeightTrackOccupant` for cells that need fixed vertical
      allocation.
- [x] Place the Message Evidence search-controls occupant in Search-page cell
      C2.
- [x] Render the resolved C-track allocation in sidebar, center panel, and
      right panel cells.
- [x] Keep C1 unoccupied; it honors the resolved allocation only.
- [x] Keep Track C semantically neutral; C2's occupant carries the
      page-specific search-control requirement.
- [x] Bottom-align the C2 search-control group inside the resolved cell
      allocation.
- [x] Avoid direct fixed Track C height overrides outside occupant
      negotiation.
- [x] Preserve Track A and Track B behavior.
- [x] Do not introduce Conversation Card tracks, sidebar cassette
      participation, or Contacts migration in this slice.

## Phase 4C - Search-Page C3 Conversation Card Occupant Slice

- [x] Replace the temporary fixed Conversation Card track requirement with a
      natural requirement.
- [x] Derive the requirement from
      `ConversationSignatureCardPresentationMetrics`, shared with the rendered
      `ConversationSignatureCard`.
- [x] Make the requirement canonical-width aware so glyph row count can change
      the resolved track height without depending on the right panel's current
      width.
- [x] Define the canonical card width in
      `ConversationSignatureCardPresentationMetrics`.
- [x] Ensure the rendered canonical `ConversationSignatureCard` uses the same
      width as the occupant requirement calculation.
- [x] Keep the page coordinator free of Conversation Card, glyph, and feature
      branches.
- [x] Keep Track C semantically neutral; C3's occupant carries the
      page-specific Conversation Card placement.
- [x] Preserve Track A and Track B behavior.
- [x] Do not introduce sidebar cassette participation, Contacts migration,
      widget measurement, GlobalKeys, or post-frame repair.

## Phase 4D - Search-Page D2/D3 Supporting Text Occupant Slice

- [x] Add an ordinal Track D to the generic track model.
- [x] Place the Message Evidence supporting-context occupant in Search-page
      cell D2.
- [x] Place the Conversation excerpt label occupant in Search-page cell D3
      when the right Conversation excerpt is visible.
- [x] Render an empty D1 cell in the sidebar without contributing an occupant.
- [x] Keep Track D semantically neutral; D2 and D3 carry only current
      page-composition occupancy.
- [x] Preserve Track A, Track B, and Track C behavior.
- [x] Do not introduce sidebar cassette participation, Contacts migration,
      widget measurement, GlobalKeys, or post-frame repair.

## Phase 4E - Search-Page E Fixed-Height Occupant Slice

- [x] Add an ordinal Track E to the generic track model.
- [x] Place one fixed-height 16 px occupant in the current Search-page
      composition.
- [x] Render the resolved E allocation in sidebar, center panel, and right
      panel cells before primary content begins.
- [x] Keep Track E semantically neutral; the fixed-height occupant carries only
      geometry.
- [x] Preserve Track A, Track B, Track C, and Track D behavior.
- [x] Do not introduce sidebar cassette participation, Contacts migration,
      widget measurement, GlobalKeys, or post-frame repair.

## Phase 5 - Validation

- [x] Verify Track A model behavior with focused widget tests.
- [x] Verify Track B model behavior with focused widget tests.
- [x] Verify TrackOccupant requirement resolution with focused widget tests.
- [x] Verify fixed-height spacing occupants with focused widget tests.
- [x] Verify Conversation Card presentation metrics with focused widget tests.
- [x] Verify Conversation Card occupant requirements increase with glyph
      height.
- [x] Verify rendered Conversation Card height stays synchronized with the
      calculated natural requirement.
- [x] Verify finite width affects Conversation glyph row count at the metrics
      level.
- [x] Verify `ConversationSignatureCardTrackOccupant` requirements use the
      canonical card width rather than ambient container width.
- [x] Verify rendered Conversation Card width is canonical inside wider
      containers.
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

## Phase 7 - Future Track Cell Alignment

- [ ] Define a page-composition-level vertical alignment model.
- [ ] Support only top, center, and bottom initially.
- [ ] Keep alignment out of `TrackId`, `TrackRequirement`, and
      `TrackOccupant`.
- [ ] Verify alignment changes do not affect resolved track heights.
- [ ] Verify alignment is not used as hidden spacing.

## Deferred Work

- [ ] Contacts page migration.
- [ ] Conversation Browse page migration.
- [ ] Automatic sidebar cassette content-start selection.
- [ ] General track participation for arbitrary cassette chains.
- [ ] Retiring the old wrapper model.
