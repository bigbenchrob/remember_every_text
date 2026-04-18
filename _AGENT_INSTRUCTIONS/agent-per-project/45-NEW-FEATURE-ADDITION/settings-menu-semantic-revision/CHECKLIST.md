---
tier: feature
scope: checklist
owner: agent-per-project
last_reviewed: 2026-04-17
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
feature: settings-menu-semantic-revision
status: proposed
created: 2026-04-17
---

# Checklist - Settings Menu Semantic Revision

## Phase 0 - Planning Alignment

- [ ] Confirm the approved terminology split: `persistentState` for durable context, `transientAction` for user intent, and `ephemeral projection` as the preferred description of transient cassette expansion behavior
- [ ] Confirm that persistent settings context is represented only in global flow state and never in menu-local stored selection
- [ ] Confirm that transient cassette expansion is derived only from the most recent dispatched intent and never from a stored transient flag
- [ ] Confirm that transient cassette layers over existing persistent context and never clears or replaces it

## Phase 1 - Flow State Ownership

- [x] Introduce a first-class global flow-state field for persistent settings context
- [x] Remove or repurpose any durable `selectedActionId` style field that currently mixes persistent and transient meaning
- [x] Ensure persistent context serialization, restoration, and bookmarking include only durable context
- [x] Ensure no transient settings flow is serialized into persisted or bookmarkable sidebar state

## Phase 2 - Menu Projection And Dispatch

- [ ] Extend `SettingsTopMenuActionRow` with explicit semantic classification
- [x] Make the settings menu widget project the selected label only from persistent global flow state
- [x] Ensure transient menu selections dispatch intent without mutating persistent context
- [x] Ensure the placeholder label remains visible whenever no persistent settings context is active

## Phase 3 - Topology And Ephemeral Projection

- [ ] Derive transient cassette expansion directly from the most recent dispatched transient intent
- [ ] Ensure dispatcher and topology, not the menu widget, own transient lifecycle
- [ ] Remove any reliance on local widget state or flow-state flags to remember transient settings actions
- [ ] Preserve persistent context while transient cassette expansions are present
- [ ] Ensure transient expansion clears cleanly on cancel or completion without mutating persistent context

## Phase 4 - Transient Cassette Semantics

- [ ] Add self-contained headings to transient settings cassettes
- [ ] Preserve the single-cassette semantic unit for `Send logs…`
- [ ] Replace reset's blocking confirmation dialog with a sidebar-local transient cassette flow
- [ ] Ensure reset cancel dismisses only the transient projection and leaves persistent context unchanged

## Phase 5 - Verification

- [ ] Add flow-state tests proving persistent context is global-only
- [ ] Add topology tests proving transient cassette expansion is intent-derived and not stored-state-derived
- [ ] Add menu tests proving transient actions do not remain selected in menu chrome
- [ ] Add lifecycle tests proving transient cassette layering does not clear persistent context
- [ ] Add regression coverage for reset's non-modal sidebar-local confirmation flow
- [ ] Update canonical feature docs if implementation changes any long-term sidebar state contract