---
tier: feature
scope: tests
owner: agent-per-project
last_reviewed: 2026-05-24
source_of_truth: doc
links:
  - ./PROPOSAL.md
  - ./CHECKLIST.md
  - ./DESIGN_NOTES.md
tests: []
feature: conversation-topology-presentation
status: proposed
created: 2026-05-24
---

# Test Plan - Conversation Topology Presentation

## Architecture / Boundary Tests

- [ ] No SQL appears in presentation or application code added for this feature.
- [ ] New graph data access, if any, is implemented through infrastructure repositories.
- [ ] Conversation signature facts are computed outside widgets.
- [ ] Widgets render only typed signature data.
- [ ] Sidebar selection does not call imperative center-panel push/clear/reset logic.
- [ ] The center panel remains a ViewSpec projection.
- [ ] Experimental visual components are isolated and removable.
- [ ] No visual tuning panel appears in production UI unless behind an experimental/dev-only flag.

## Sidebar Flow Tests

- [ ] Conversations mode projects a sidebar conversation-signature cassette.
- [ ] Conversations mode no longer requires a center-panel conversation browser to navigate.
- [ ] Selecting a signature updates sidebar flow state or selected conversation state through existing semantic flow.
- [ ] Effective center panel projection derives `MessagesSpec.forConversation(...)` from that state.
- [ ] Switching away from Conversations hides incompatible selected conversation center content by derivation.
- [ ] Returning to Conversations shows either the selected compatible conversation or the default sidebar signature state according to the implemented state contract.

## Center Panel Tests

- [ ] Center panel renders selected conversation messages after sidebar selection.
- [ ] Center panel does not render the conversation signature list as its default Conversations content.
- [ ] Existing message stream behavior remains intact for selected conversations.
- [ ] The preserved diagnostic/reference browser is not selected by default.

## Read Model Tests

- [ ] Conversation signature read model returns stable IDs.
- [ ] Participant labels are present.
- [ ] Message counts are present.
- [ ] Latest message timestamps are present.
- [ ] Temporal density bins are deterministic for the same input data.
- [ ] Empty or anomalous conversations render diagnostic-safe signature values rather than disappearing.

## Widget Tests

- [ ] Signature row renders participant label.
- [ ] Signature row renders message count or compact metadata.
- [ ] Signature row renders Trace as the default compact visual signature.
- [ ] Hybrid is not the default signature mode.
- [ ] Signature row renders participant count as compact dots or initials, not a metadata pill.
- [ ] Participant marks cap at five visible marks plus `+N`.
- [ ] Participant-count cue remains visually subordinate to the Trace.
- [ ] Selected row state is visually distinguishable.
- [ ] Hover/focus state uses app theme tokens.
- [ ] Long participant labels truncate without layout overflow.
- [ ] Dense lists remain scrollable in the sidebar.

## Regression Tests

- [ ] Contacts mode remains available.
- [ ] Contact heatmap behavior remains unchanged.
- [ ] Contact "By conversation" behavior remains unchanged unless explicitly revised later.
- [ ] Stray handles mode remains available.
- [ ] Search all messages mode remains available.
- [ ] No import/projection/graph database behavior changes.

## Manual Verification

- [ ] Launch app on `Ftr.convo-topol`.
- [ ] Open Conversations mode.
- [ ] Confirm the sidebar contains conversation signatures.
- [ ] Confirm the center panel is not a conversation browser by default.
- [ ] Select a single-participant conversation and verify messages appear in center.
- [ ] Select a group conversation and verify messages appear in center.
- [ ] Verify the sidebar remains visible and useful while reading messages.
- [ ] Compare compact visual impression against `experiments/conversation_shape_sandbox/`.
- [ ] Confirm no additional controls were added in the first slice.

## Required Commands

Run focused tests according to touched files, then:

```bash
dart analyze <changed files>
```

If generated providers or Freezed classes are changed:

```bash
dart run build_runner build --delete-conflicting-outputs
```
