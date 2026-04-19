---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-04-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ../ephemeral-sidebar-projection/CHECKLIST.md
tests: []
feature: settings-menu-semantic-revision
status: superseded
created: 2026-04-17
---

# Test Plan - Settings Menu Semantic Revision

Historical note: this test plan predates the stable/ephemeral projection split.

Current verification for the shipped behavior lives in the sidebar projection tests and the `../ephemeral-sidebar-projection/` docs.

## Flow State Tests

- [ ] Persistent settings context is stored only in first-class global flow state
- [ ] No transient settings action writes any stored transient flag into global flow state
- [ ] Restored or bookmarkable sidebar state reconstructs persistent context only, not transient cassette projection

## Menu Projection Tests

- [ ] Closed menu label reflects persistent context from global flow state
- [ ] With no persistent context active, the menu shows `Choose setting or action`
- [ ] Selecting a transient action does not leave that label in the closed menu chrome
- [ ] Selecting a persistent action updates the projected closed-menu label if and when a durable settings context is later introduced

## Topology And Dispatcher Tests

- [ ] Transient cassette expansion is derived directly from the most recent dispatched transient intent
- [ ] Transient cassette expansion does not depend on any stored transient flow-state flag
- [ ] Dispatcher and topology, not widget-local state, own transient cassette lifecycle
- [ ] Cancelling a transient projection removes only the transient cassette expansion
- [ ] Completing a transient projection clears only the transient cassette expansion

## Layering Tests

- [ ] Persistent context remains intact while a transient cassette is present
- [ ] Transient cassette projection layers over existing persistent context rather than replacing it
- [ ] Clearing transient projection does not clear persistent context

## Transient Cassette Tests

- [ ] `Send logs…` renders as a single self-contained cassette with its own heading
- [ ] `Reset message data…` renders as a single self-contained cassette with its own heading
- [ ] Reset confirmation is sidebar-local and non-modal
- [ ] Reset cancel dismisses the transient projection without mutating persistent context

## Regression Tests

- [ ] Group headers remain inert and non-selectable
- [ ] The settings menu remains usable while a transient cassette is present
- [ ] No transient settings flow is reconstructible after restore or deep-link style state rehydration
- [ ] Existing settings cassette rendering continues to route through the sidebar spec -> coordinator -> resolver -> payload -> widget-builder path