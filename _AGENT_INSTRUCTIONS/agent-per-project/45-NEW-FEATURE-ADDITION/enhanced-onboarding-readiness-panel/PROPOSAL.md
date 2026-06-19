# Environment Readiness Center Panel Proposal

## Current Conformance Note (2026-06-06)

This proposal remains directionally current: readiness belongs in a calm,
durable center-panel surface rather than chained failure dialogs. The checks
should now describe graph-era setup: source readability, AddressBook readiness,
source-scoped import, conversation graph build/readiness, overlay failure
state, and retained compatibility diagnostics only where clearly labeled.

## Problem

The current onboarding implementation has outgrown the dialog/overlay shape.

The app now performs materially richer environment analysis, including:

- Full Disk Access readiness
- Messages database availability and readability
- Contacts / AddressBook readiness
- source sparsity and likely-local-history gaps
- source-scoped import failure evidence
- conversation graph build/projection failure evidence
- graph-era app-owned database readiness
- retained compatibility diagnostics when explicitly labeled

That breadth is useful, but it no longer fits cleanly into a sequence of modal
or overlay-style failure panels. The result is increasing UI density,
increasing layout pressure, and a weaker mental model for the user.

The user does not need a stack of interruptions.
The user needs one calm, durable, state-driven readiness surface.

## Goal

Introduce a first-class center-panel environment-readiness surface that:

- replaces chained failure dialogs for ordinary readiness failures
- shows the current state of required environment checks in one place
- explains why MessageLens needs each dependency or permission
- reassures the user about read-only behavior and on-device privacy
- provides direct actions where appropriate
- allows repeated re-checking until the environment is ready
- transitions cleanly into import/bootstrap once all checks pass

## Non-Goals

- replacing the underlying source-scoped import or graph-build pipelines
- embedding raw environment checks directly into widgets
- inventing a wizard with manually persisted step position
- using tabs as the primary control metaphor
- introducing feature-local navigation outside the ViewSpec system
- folding developer simulation tooling into the user-facing readiness flow

## Product Direction

This feature should be presented as an environment-readiness checklist, not a
wizard and not an error dialog.

The center panel should show:

- a readiness summary rail or checklist
- one active step at a time
- clear status coloring and iconography
- detailed explanation and repair guidance for the active step
- direct actions such as Open System Settings and Re-check

The flow should remain deterministic and system-driven:

- the app computes the first failing step
- earlier passing steps show success
- later steps remain pending
- when the active step passes, the next failing step becomes active

## Why Center Panel Is The Right Surface

This is a cross-surface feature, not a transient startup hack.

The existing architecture already supports this shape:

- the center panel is driven by `ViewSpec`
- app-level coordinators decide which surface is shown
- feature coordinators interpret feature specs
- resolvers own meaning and sequencing
- builders/widgets render already-decided content

That makes a center-panel readiness surface a better fit than a growing overlay.

## Recommended UX Model

Use a vertical readiness checklist with one active step.

Recommended initial steps:

1. Full Disk Access
2. Local Messages database readiness
3. Contacts database readiness
4. Source-scoped import readiness
5. Conversation graph readiness

Each step should support these stable statuses:

- pending
- active
- success
- failure

Recommended visual semantics:

- gray for pending
- accent color for active
- green for success
- amber for failure / action needed

## Behavioral Model

At launch:

1. the environment resolver computes a full readiness snapshot
2. the first failing step becomes active
3. completed earlier steps render as success
4. later steps remain pending

When the user clicks Re-check:

1. the readiness resolver recomputes the environment snapshot
2. if the active step now passes, it turns green
3. the success state is allowed to register briefly
4. the next failing step becomes active automatically

When all steps pass:

1. the readiness surface shows all-green completion
2. the app proceeds into import / bootstrap progression

## Architectural Fit

This feature should follow the established cross-surface rules:

- app-level routing decides when readiness is shown
- the readiness feature owns step definitions and sequencing
- a resolver produces a full readiness snapshot from source truth
- a feature coordinator maps that snapshot to a surface view model
- widgets remain dumb renderers of decided state

The current onboarding environment evaluator should be reused as the low-level
inspection substrate where practical, rather than replaced outright.

## Primary Risks

### 1. UI logic leakage

The stepper UI will tempt widget-level sequencing. That must be resisted.
Active-step selection and state progression must live in resolver/coordinator
logic, not widget state.

### 2. Duplicate readiness logic

If the new feature rebuilds the environment-inspection layer from scratch, the
codebase will split into two competing truth systems. The new surface should
reuse existing readiness evidence gathering where practical.

### 3. Overloading one surface

Readiness and import progress are related but not identical concerns. The first
implementation should keep the readiness surface focused on environment
compliance, then transition clearly into import flow.

## Success Criteria

This feature is successful when:

- users can understand all readiness blockers in one place
- the app explains why each step matters in plain language
- repair actions are clear and low-friction
- success progresses naturally from one step to the next
- no ordinary readiness failure requires a modal dialog
- the feature fits the existing ViewSpec and coordinator/resolver architecture

## Deliverables

- `DESIGN_NOTES.md` defining the architecture and domain model
- `CHECKLIST.md` defining phased implementation work
- `TESTS.md` defining unit, provider, and manual scenarios
