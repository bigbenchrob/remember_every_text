---
tier: feature
scope: feature-checklist
owner: agent-per-project
last_reviewed: 2026-05-24
source_of_truth: doc
status: proposed
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
feature: conversation-topology-presentation
created: 2026-05-24
---

# Development Checklist - Conversation Topology Presentation

**Status**: Proposed  
**Branch**: `Ftr.convo-topol`

## Phase 0 - Approval

- [ ] Review `PROPOSAL.md`.
- [ ] Review `DESIGN_NOTES.md`.
- [ ] Review `TESTS.md`.
- [ ] Confirm first implementation slice.
- [ ] Confirm no additional sidebar controls in v1.

## Phase 1 - Current Flow Audit

- [ ] Identify the current center-panel Conversations entry point.
- [ ] Identify the widget(s) that render the current center-panel conversation list.
- [ ] Identify the widget(s) that render selected conversation messages.
- [ ] Identify the ViewSpec path for selected conversation messages.
- [ ] Identify current conversation summary/read-model providers.
- [ ] Identify whether existing graph summary data already supports a compact signature list.
- [ ] Confirm no SQL exists outside infrastructure in the current conversation path.

## Phase 2 - Preserve Existing Center Browser As Reference

- [ ] Identify the current center-panel conversation browser/list path.
- [ ] Preserve the old browser enough for future comparison or debugging.
- [ ] Remove the old browser/list path from default Conversations routing once the new sidebar path works.
- [ ] Do not move or rename the old path before the new path works unless necessary.
- [ ] Ensure the reference path does not own production navigation semantics.
- [ ] Add clear code comments or naming indicating reference/diagnostic status if it remains reachable.
- [ ] Verify existing selected-conversation message view remains reusable.

## Phase 3 - Signature Read Model

- [ ] Define the minimal conversation signature model.
- [ ] Use existing conversation graph repository methods where possible.
- [ ] Add repository methods only in infrastructure if additional data is required.
- [ ] Keep application/domain models typed and SQL-free.
- [ ] Avoid semantic decisions in presentation widgets.
- [ ] Compute conversation signature facts outside widgets; widgets render only typed signature data.
- [ ] Keep the first signature data lightweight.

Candidate v1 fields:

- [ ] `conversationId`
- [ ] participant labels
- [ ] participant count
- [ ] message count
- [ ] latest message timestamp
- [ ] temporal density bins
- [ ] selected/active marker input

Optional only if already cheap:

- [ ] attachment density/count
- [ ] participant dominance bands
- [ ] silence-gap markers

## Phase 4 - Sidebar Signature Cassette

- [ ] Add or adapt a Conversations-mode sidebar cassette for conversation signatures.
- [ ] Render compact rows with participant labels and canonical Trace signature.
- [ ] Keep Hybrid available only as an experimental diagnostic overlay if implemented.
- [ ] Render participant count as a quiet structural cue, not as a metadata pill.
- [ ] Cap visible participant marks at five and show `+N` for overflow.
- [ ] Place participant-count marks near the title or at the left edge of the trace frame.
- [ ] Keep participant-count marks low contrast and subordinate to the trace.
- [ ] Verify participant-count cue distinguishes one-to-one, small group, and large group under blur.
- [ ] Keep rows dense enough for sidebar use.
- [ ] Use theme tokens only.
- [ ] Avoid hard-coded production colors.
- [ ] Add hover and selected states consistent with app controls.
- [ ] Keep rendering removable and isolated if marked experimental.
- [ ] Do not add sort/filter/search controls in this phase.
- [ ] Do not add visual tuning panels in production UI unless behind an experimental/dev-only flag.

## Phase 5 - Selection And Center Pairing

- [ ] Selecting a signature updates sidebar flow state or selected conversation state through the existing navigation architecture.
- [ ] Effective center projection derives `MessagesSpec.forConversation(...)` from that state.
- [ ] Center panel shows selected conversation messages.
- [ ] Center panel no longer defaults to the conversation browser/list.
- [ ] Sidebar remains visible and useful while messages are read.
- [ ] No imperative panel push, clearing, or force-reset behavior is introduced.
- [ ] Incompatible panels remain hidden by derived effective-panel logic.

## Phase 6 - Visual Calibration

- [ ] Compare the Flutter sidebar signature rows to the HTML sandbox reference.
- [ ] Preserve the recognizable compact signature idea.
- [ ] Avoid copying sandbox architecture.
- [ ] Avoid turning the sidebar into a dashboard.
- [ ] Verify the center panel remains message evidence only.

## Phase 7 - Verification

- [ ] Run focused sidebar flow tests.
- [ ] Run focused panel projection tests.
- [ ] Run focused conversation graph/read-model tests.
- [ ] Run focused widget tests for signature row rendering if practical.
- [ ] Run `dart analyze` on changed files.
- [ ] Run manual app check: Conversations opens with sidebar signatures.
- [ ] Run manual app check: selecting a signature opens messages in center.
- [ ] Run manual app check: old center browser is not the default visible Conversations mode.

## Completion Criteria

- [ ] Sidebar presents conversation signatures.
- [ ] Center panel presents selected conversation messages.
- [ ] No additional controls were added in v1.
- [ ] Existing browser/list path is preserved for reference or diagnostics and removed from default routing.
- [ ] DDD boundaries are preserved.
- [ ] No imperative UI repair behavior was introduced.
- [ ] Documentation and tests reflect the new sidebar/center split.
