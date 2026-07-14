---
tier: feature
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-03-19
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ../../50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md
  - ../../52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md
  - ../../54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
  - ../../56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md
tests: []
---

# Design Notes - Sidebar Flow State Introduction

## Objective

Introduce a canonical source of truth for the contacts/messages sidebar flow so:

- sidebar cassettes are projected from declared state
- user actions are expressed as explicit transitions
- panel content cannot drift into stale combinations after sidebar resets

The initial delivery should improve correctness without widening into a full rewrite of all sidebar branches.

## Existing Architecture Summary

- the sidebar rack currently stores an ordered list of `CassetteSpec` values
- current contact/message flow meaning is partly encoded in those rendered specs
- widgets can replace upstream specs and recascade from the middle of the rack
- the center panel is already spec-driven, but today it is updated through paths that can diverge from sidebar meaning

The weakness is not that the app uses specs.

The weakness is that the visible sidebar stack is acting as a partial state container.

## Constraints (Non-negotiable)

- do not replace the cross-surface spec architecture
- do not bypass feature-owned specs or move feature meaning into global widget code
- do not let the sidebar own panel widget rendering directly
- do not infer critical flow state primarily from the rendered cassette rack after phase 1
- do not widen phase 1 into a rewrite of unrelated sidebar branches
- do not change persistence, overlay, or database behavior as part of this feature

## Recommended Shape

### Phase 1 Boundary

Phase 1 should introduce a canonical flow state for the contacts/messages branch and use it to:

- derive sidebar cassette composition
- centralize reset semantics
- drive explicit center-panel `ViewSpec` updates

In phase 1, the center panel remains ViewSpec-driven exactly as it is today.

What changes is the source of meaning behind those `ViewSpec` updates.

### Phase 2 Boundary

Phase 2 can extend the same model into a fuller investigation-state system where:

- center-panel content is itself projected from canonical state
- state can include location within the current investigation, such as a focused month
- saved investigation states or bookmarks become possible

## State Model

### Recommendation

Use a dedicated flow-state type for the targeted branch rather than continuing to discover truth by scanning the rack.

The initial shape should prefer explicitness over nullable bags of data.

Two reasonable options exist:

1. A single data class with carefully enforced invariants.
2. A sealed union representing distinct flow branches.

The second is safer if the branch structure becomes complex.

### Suggested Phase 1 State Fields

At minimum, the canonical flow state should answer:

- which top-level branch is active, if the provider spans more than one top menu path
- whether a contact has been chosen
- which contact is active
- whether the investigation scope is regular messages or recovered/deleted messages
- whether all handles or a specific handle is active

Suggested conceptual shape:

```text
SidebarFlowState
  rootBranch
  chosenContactId
  messageScope
  selectedHandleId
```

### Suggested Phase 2 Additions

Only after phase 1 is stable, the state can expand to include investigation position:

```text
InvestigationState
  rootBranch
  chosenContactId
  messageScope
  selectedHandleId
  heatMapMonth
```

The important test is this:

If a field does not change legitimate sidebar composition or legitimate panel meaning, it should not be canonical state.

## Invariants

The state model should make these rules explicit:

1. If `chosenContactId` is null, `selectedHandleId` must also be null.
2. If `chosenContactId` changes, subordinate contact-specific state resets to defaults.
3. If `messageScope` changes to a branch incompatible with the current subordinate state, that subordinate state resets.
4. A rendered cassette arrangement must always be explainable from canonical state alone.
5. In phase 1, a center-panel `ViewSpec` must be derivable from canonical flow state plus transition rules, not from ad hoc widget-local decisions.

## Transition Model

Transitions should be explicit methods or events on the canonical flow-state owner.

Suggested phase 1 transition set:

| Transition | Required State Effect | Panel Effect In Phase 1 |
| --- | --- | --- |
| `topMenuChanged(branch)` | switch root branch and clear incompatible subordinate state | update active center-panel view if needed |
| `contactChosen(contactId)` | set `chosenContactId`, clear `selectedHandleId`, set default `messageScope` | navigate to default contact-scoped message view |
| `chooseAnotherContact()` | clear `chosenContactId`, clear `selectedHandleId`, restore pre-contact defaults | remove invalid contact-scoped center content |
| `handleSelected(handleId)` | set `selectedHandleId` | navigate to handle-filtered panel content |
| `allHandlesSelected()` | clear `selectedHandleId` | navigate to all-handles panel content |
| `messageScopeChanged(scope)` | set `messageScope`, clear incompatible subordinate context if required | navigate to scope-aligned panel content |

Suggested phase 2 transition additions:

| Transition | Required State Effect |
| --- | --- |
| `heatMapMonthFocused(month)` | set `heatMapMonth` |
| `savedInvestigationLoaded(state)` | replace current investigation state with saved canonical state |

## Projection Rules

### Sidebar Projection

The projection layer should derive cassette composition from canonical state.

Examples:

1. No contact chosen:
   - show the contact-picker info card
   - show the contact chooser

2. Contact chosen, default message scope, all handles:
   - show the chosen-contact info card
   - show the contact hero summary
   - show the handle filter in all-handles mode
   - show the regular message exploration branch

3. Contact chosen, deleted-message scope, all handles:
   - show the chosen-contact info card
   - show the contact hero summary
   - show the handle filter
   - show the deleted-message exploration branch

4. Contact chosen, deleted-message scope, one handle selected:
   - same cassette structure as above
   - with the handle filter projected in selected-handle state

The cassette rack becomes a rendering artifact of this projection, not the place where truth lives.

### Center-Panel Projection

Phase 1:

- transitions update the panel through explicit `ViewSpec` routing
- the chosen `ViewSpec` must be derived from the canonical flow state and the triggering transition

Phase 2:

- panel content can become a direct projection of canonical investigation state

For example, a state like:

```text
contactId: 42
messageScope: deleted
heatMapMonth: 2019-05
```

should correspond to exactly one valid center-panel meaning.

After `chooseAnotherContact()`, that state no longer exists, so the old deleted-message panel cannot legitimately remain visible.

## Provider Scope Recommendation

Prefer introducing this as a narrowly scoped provider for the contacts/messages branch first.

Why:

- the current pain is concentrated there
- a narrow provider reduces migration risk
- the model can later be generalized if it proves sound

If a single global sidebar provider is introduced too early, it may accumulate unrelated branch state and become harder to reason about than the system it replaces.

## Migration Strategy

### Step 1: Introduce Canonical State Beside Existing Rack

Add the canonical flow-state owner without removing current rack behavior immediately.

### Step 2: Route User Actions Through Transitions

Convert contact choice, handle choice, and message-scope changes so they update canonical state first.

### Step 3: Project Sidebar From Canonical State

Replace branch-local rack inference with deterministic projection.

### Step 4: Align Phase 1 Panel Updates

Ensure the center panel is updated from transition-driven logic tied to canonical state.

### Step 5: Remove Old Rack-State Assumptions

Retire helper paths that infer truth from the current rack, such as "latest selected contact from visible cassette specs" style accessors.

## Risks And Failure Modes

### Risk 1: State Bag Without Invariants

If the new state is just a loose bag of nullable fields, invalid combinations may become easier to create than before.

### Risk 2: Two Sources Of Truth During Migration

If both rack contents and canonical state are allowed to drive behavior simultaneously for too long, debugging will get worse before it gets better.

### Risk 3: Hidden Projection Logic

If projection rules are scattered across widget callbacks instead of being centralized, the new architecture will reproduce the current problem under a different name.

### Risk 4: Phase 2 Pulled In Too Early

Saved investigations and full center-panel derivation are valuable, but they should not complicate the first migration step.

## Open Decisions

1. Should phase 1 use a sealed union or a single data class with strict invariant checks?
2. Should root branch be part of this provider initially, or should the provider remain scoped under the relevant top-level menu path?
3. Which existing `MessagesSpec` variants are the correct phase 1 targets for explicit transition-driven routing?
4. Which location details, if any, belong in canonical state during phase 1 versus phase 2?
