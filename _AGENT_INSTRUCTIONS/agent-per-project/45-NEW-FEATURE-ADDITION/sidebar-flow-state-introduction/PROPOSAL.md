---
tier: feature
scope: proposal
owner: agent-per-project
last_reviewed: 2026-03-19
source_of_truth: doc
links:
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md
  - ../../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md
tests: []
feature: sidebar-flow-state-introduction
status: proposed
created: 2026-03-19
---

# Feature Proposal - Sidebar Flow State Introduction

**Proposed Branch**: `Ftr.cass-state`
**Status**: Proposed
**Created**: 2026-03-19

---

## Overview

Introduce a canonical sidebar flow state for the contact and message exploration branch so the sidebar cassette stack becomes a deterministic projection of state, rather than the place where state is implicitly stored and surgically mutated.

This proposal does not treat the sidebar as a cosmetic layout problem.

It treats the current behavior as a state-ownership problem:

- user intent is currently registered through rendered cassettes
- important flow state is inferred back out of the visible cassette stack
- widgets can replace upstream cassette specs and recascade from the middle of the rack
- downstream resets and mode changes are therefore real, but implicit

The proposal introduces a more explicit model:

- canonical flow state is the source of truth
- user actions become explicit transitions on that state
- the visible cassette stack is projected from state deterministically
- center-panel content can be derived unambiguously from the same declared state
- panel navigation remains ViewSpec-driven, but becomes a projection of canonical flow meaning rather than a parallel source of truth

## User Value

### Problem

The current sidebar cassette system works, but it has become difficult to reason about as the contacts and messages branch has gained more stateful behavior.

In particular:

- `chosenContactId` is not owned by a dedicated flow state object; it is inferred from currently rendered cassette specs
- reset behavior such as "choose another contact" is implemented by replacing upstream cassette specs and recascading
- message mode changes, including recovered or deleted-message branches, are not represented as explicit sidebar flow state
- the sidebar and center panel can drift into conceptually mismatched states because each is updated through separate paths
- topology comments and mental models are easy to let drift because the real logic lives partly in rack mutation side effects

This creates friction in three places:

1. implementing new sidebar behavior safely
2. verifying invariants like downstream reset semantics
3. explaining the system clearly to future contributors

### Proposed User-Facing Outcome

This feature should make the app's sidebar behavior more predictable without changing the broader cross-surface architecture.

Concretely, it should make these behaviors explicit and reliable:

- selecting a contact establishes canonical contact-scoped sidebar state
- selecting another contact clears invalid subordinate state
- regular message flow and recovered-message flow are explicit state choices, not incidental cassette arrangements
- visible cassettes always reflect the current canonical flow state
- the center panel cannot legitimately linger on stale content because valid content is derived from the same canonical state
- panel navigation and sidebar composition stay coherent because they are driven by declared transitions rather than rack surgery

### Benefits

- fewer hidden state transitions
- easier debugging of sidebar behavior
- clearer reset rules for product behavior
- safer foundation for future sidebar branches and spec-topology work
- reduced temptation to solve new behavior by mutating cassette stacks ad hoc

---

## Existing Architecture Summary

- the sidebar is currently driven by a rack of `CassetteSpec` values managed by the cassette rack provider
- cascade topology determines the next child cassette based on the current spec branch
- feature-level resolvers and widget builders interpret the feature-owned inner specs
- some current flow state, especially in the contacts branch, is encoded inside the rendered stack itself
- widgets can update the sidebar by replacing a cassette spec at a specific index and recascading from that point
- center and right panels already use a more explicit model: a `ViewSpec` describes what should be shown, and panel state owns that independently of rendering

The sidebar therefore already participates in the app's spec-driven architecture, but its internal state ownership is weaker than the panel system's ownership model.

## Assumptions

1. The current cassette system is still the correct rendering surface for the sidebar.
2. The app should keep the existing cross-surface spec architecture rather than replace it with direct widget management.
3. The initial target is the contacts and messages branch, where the current stack-encoded state is most visible.
4. Product behavior should preserve the already-discussed reset rule: choosing a new contact resets subordinate state to the default contact-scoped message path.
5. It is acceptable to introduce a dedicated canonical sidebar flow state object if it remains narrowly scoped and does not duplicate unrelated navigation state.

## Hard Invariants

1. Do not replace the app's cross-surface spec architecture.
2. Do not bypass feature-owned cassette specs or move feature meaning into app-global widget code.
3. Do not let the sidebar become the owner of panel widget content; panel content must remain ViewSpec-driven.
4. Do not infer critical flow state primarily from the rendered cassette stack after this feature lands.
5. Do not widen this work into a general rewrite of all sidebar surfaces in phase 1.
6. Do not change database behavior, overlay behavior, or unrelated persistence architecture as part of this feature.

---

## Scope

### Phase 1 - Introduce Canonical Sidebar Flow State For The Contacts/Messages Branch

1. **Define canonical flow state**
   Introduce an explicit state model that represents the meaningful sidebar flow decisions for this branch.

2. **Define explicit transitions**
   Represent user actions such as choosing a contact, clearing a contact, selecting a handle, or switching message mode as explicit state transitions.

3. **Project cassettes from state**
   Make the visible cassette stack a deterministic projection from canonical state rather than the carrier of truth.

4. **Keep panel routing aligned**
   Ensure sidebar transitions can drive appropriate ViewSpec changes without creating separate hidden meaning in the sidebar rack.

5. **Preserve product reset semantics**
   Confirm and encode which downstream fields are cleared or defaulted after each higher-level change.

### Phase 2 - Extend To Cross-Surface Investigation State

1. **Project center-panel content from canonical state**
   Treat the center panel as another deterministic projection of declared investigation state.

2. **Represent location within a message surface explicitly**
   Allow canonical state to carry view-positioning context such as a selected heat-map month when that context is required to reconstruct the correct center-panel view.

3. **Enable saved investigation states**
   Support later persistence of meaningful investigation states for reopening a specific historical context.

### Candidate State Fields

The initial canonical state should remain minimal and behavior-driven.

Candidate fields:

- top-level sidebar branch or mode
- `chosenContactId`
- `selectedHandleId`
- message scope or message mode
- focused time anchor such as `heatMapMonth` when needed to reconstruct the active investigation view
- any branch discriminator required to distinguish normal versus recovered flows

If a field does not change cassette projection or panel routing meaningfully, it should not be part of the canonical state.

### Candidate Transition Events

Examples:

- `topMenuChanged(...)`
- `contactChosen(contactId)`
- `chooseAnotherContact()`
- `handleSelected(handleId)`
- `allHandlesSelected()`
- `messageModeChanged(...)`

These transitions are the real heart of the feature. They replace hidden rack surgery with declared intent.

### Out Of Scope

- rewriting every sidebar branch at once
- eliminating cassette topology entirely
- replacing ViewSpec panel navigation
- broad visual redesign of sidebar cards
- database, import, migration, or overlay changes
- a generic app-wide state machine beyond what the sidebar flow requires

---

## Proposed Direction

### Core Principle

The rendered cassette stack is a projection of sidebar flow state, not the source of truth.

### State Model

Introduce a canonical sidebar flow state provider for the targeted branch.

That state should answer questions like:

- has the user chosen a contact
- which contact is active
- is the current branch regular messages or recovered messages
- is the contact narrowed to a single handle or to all handles

Those answers should no longer depend on scanning the latest matching cassette in the rendered rack.

### Transition Model

Each meaningful user action should map to a deliberate state transition with explicit reset semantics.

For example:

- choosing a contact sets `chosenContactId` and clears state that is no longer valid under the new contact
- choosing another contact clears contact-specific subordinate state
- switching message mode updates canonical mode and may reset incompatible subordinate state if required by the product rules

This is not extra bureaucracy.

It is the existing logic, made visible and testable.

### Projection Model

Given the canonical flow state, the sidebar should derive:

- which info cassette appears
- which contact cassette appears next
- whether the handle filter is present
- which message-oriented cassette branch is shown
- what the default child path should be after a reset

The same model can later support deterministic center-panel projection.

For example, if state declares:

- `chosenContactId: 42`
- `messageScope: deleted`
- `heatMapMonth: 2019-05`

then only one center-panel meaning is valid: the deleted-message investigation view for contact `42`, positioned to that month.

If `chooseAnotherContact()` clears or replaces the contact-scoped state, that old center-panel meaning is no longer derivable and therefore cannot legitimately remain on screen as stale content.

Projection logic should be deterministic and explainable from the state alone.

### Saved Investigation States

Once state is explicit enough to reconstruct a specific investigation context, the same structure can later support saved states or bookmarks.

That would allow a user to reopen a precise investigative position such as:

- a specific contact
- a specific message scope
- a specific historical month or focus point

This should remain a later-phase capability, not part of the initial implementation scope.

### Relationship To Existing Topology

This proposal does not assume cassette topology disappears.

Instead, topology becomes constrained by a stronger source of truth:

- topology remains useful for how feature-owned cassette specs relate to one another
- canonical flow state decides which branch is active and which inputs those specs receive
- rack mutation becomes an implementation detail of projection, not a hidden state-management strategy

---

## Why This Is A Feature, Not Just A Refactor

This work changes the contract for how sidebar behavior is represented and reasoned about.

It is therefore more than an internal cleanup because it introduces:

- a new state owner for sidebar flow truth
- explicit transition semantics for user intent
- a stronger behavioral guarantee about resets and branch coherence
- a path toward deterministic cross-surface investigation state
- a migration path away from stack-as-state reasoning

Treating this as a feature helps preserve scope discipline and gives the proposal a stable place to document invariants, transitions, and acceptance scenarios before implementation begins.

---

## Architecture Impact

### Areas Likely To Change In Implementation

| Area | Planned Change |
| --- | --- |
| Sidebar state | add canonical flow state for the targeted branch |
| Transition logic | centralize user-intent transitions and reset rules |
| Cassette projection | derive visible cassette sequences from canonical state |
| Contacts branch topology | simplify or constrain places that currently infer state from rack contents |
| Panel routing | phase 1 aligns sidebar transitions with explicit ViewSpec updates; phase 2 can derive center-panel content directly from canonical investigation state |
| Documentation | record invariants, transitions, and projection rules for future work |

### Areas Explicitly Not Changed In Phase 1

| Area | Reason |
| --- | --- |
| Database and import layers | unrelated to sidebar flow-state ownership |
| Cross-surface architecture | already the correct higher-level pattern |
| General feature resolvers/widget builders | should remain feature-owned |
| Unrelated sidebar branches | keep the first rollout narrow and reviewable |

---

## Risks

1. **Over-modeling**
   The flow state could become bloated if it captures every UI detail instead of only behaviorally meaningful decisions.

2. **Split truth during migration**
   If the rack and the canonical state both act as truth at the same time, the migration could temporarily make reasoning worse.

3. **Scope creep**
   This work could expand into a complete sidebar rewrite if phase boundaries are not enforced.

4. **Projection complexity**
   Poorly scoped projection code could simply move rack surgery into a new layer without actually simplifying behavior.

5. **Reset-rule ambiguity**
   If product reset behavior is not recorded precisely, the new state model could encode the wrong defaults with more confidence than before.

6. **Premature cross-surface expansion**
   Pulling full center-panel derivation into phase 1 could overcomplicate the initial rollout if the sidebar-state foundation is not stabilized first.

---

## Acceptance Criteria

This proposal should be considered successful in implementation when all of the following are true for the targeted branch:

1. The active contact, handle selection, and message branch are represented in canonical sidebar flow state rather than being primarily inferred from the rendered cassette rack.
2. Choosing a new contact resets subordinate state according to the agreed product rules.
3. Choosing another contact is implemented as an explicit transition, not by relying on implicit upstream cassette replacement semantics alone.
4. The sidebar cassette stack for the targeted branch can be explained as a deterministic projection from canonical state.
5. The center panel's corresponding message view remains coherent with the canonical sidebar branch after supported user actions.
6. The new model is documented clearly enough that a contributor can understand the branch flow without reconstructing hidden rack-mutation behavior from widget code.

For the later cross-surface extension, success would additionally mean that a declared investigation state is sufficient to derive the correct center-panel content without stale-content drift.

---

## Open Questions

1. Should the canonical flow state be scoped narrowly to the contacts/messages branch first, or introduced as a generic sidebar-flow abstraction from the start?
2. Which message-mode distinctions are first-class in phase 1, and which remain derived or deferred?
3. Which transitions should also trigger explicit center-panel ViewSpec changes in phase 1, before full center-panel derivation exists?
4. How much of the current cascade topology should remain intact after projection is introduced?
5. Which investigation-location details, such as heat-map month, deserve canonical-state status versus transient UI-local status?
6. What persistence format would later be appropriate for saved investigation states or bookmarks?

## Recommended Next Step

If this proposal is approved, the next planning stage should add:

- `CHECKLIST.md` for implementation sequencing
- `DESIGN_NOTES.md` for the canonical state shape, transition table, projection rules, and the phase-1 versus phase-2 boundary for center-panel derivation
- `TESTS.md` for interaction scenarios and manual verification expectations