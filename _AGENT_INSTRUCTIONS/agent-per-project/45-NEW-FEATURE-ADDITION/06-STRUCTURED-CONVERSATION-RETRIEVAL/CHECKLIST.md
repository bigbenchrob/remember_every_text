---
tier: project
scope: planning-checklist
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: first-slice-implemented
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Structured Conversation Retrieval Checklist

This checklist records the exploratory planning and the first implemented Tag
token slice. It is not authorization to implement later token types.

## Package Creation

- [x] Create Structured Conversation Retrieval work package.
- [x] Define the distinction from All Messages Search.
- [x] Explain tokenized retrieval.
- [x] Explain relationship to Conversation Intent.
- [x] Explain relationship to Conversation Lenses.
- [x] Record non-goals.
- [x] Record open questions.
- [ ] Review package with user.

## Phase 0: Concept Approval

- [x] Confirm Structured Conversation Retrieval is the right term internally.
- [x] Confirm first-slice user-facing direction through Tag-token typeahead.
- [x] Confirm retrieval answers "Which Conversation am I trying to work with?"
- [x] Confirm All Messages Search remains the message-content retrieval system.
- [x] Confirm retrieval and Conversation Lenses remain orthogonal.
- [x] Confirm this feature is intended to reduce sidebar mode proliferation.

## Phase 1: Token Model Planning

- [x] Decide first-slice token types: Tag tokens only.
- [ ] Decide candidate grouping and ranking.
- [x] Decide whether tokens combine as AND by default.
- [x] Decide whether OR/negation are deferred.
- [ ] Decide how empty results explain active tokens.
- [ ] Decide how suppressed Conversations are included or excluded.

## Phase 2: Ownership Planning

- [x] Confirm `features/conversations` owns the retrieval experience.
- [x] Confirm Conversation Intent owns intent concepts consumed by retrieval.
- [x] Confirm graph/read models provide Conversation metadata and identity.
- [x] Confirm Search does not own Conversation retrieval.
- [x] Confirm widgets render tokens and candidates but do not infer retrieval
      semantics.

## Phase 3: UI Walk Planning

- [x] Decide where retrieval appears in the Conversations sidebar.
- [x] Decide whether it replaces the current Conversation search field.
- [ ] Preserve Favourites/Browse mode behavior unless explicitly changed.
- [x] Keep Organize by / Conversation Lens controls separate from retrieval.
- [x] Define first-slice Tag token visual language.
- [ ] Define keyboard and mouse interaction expectations.

## Phase 4: First Slice And Future Implementation Slices

Tag-token retrieval was explicitly approved as the first vertical slice.

- [x] Slice 1: typed retrieval state model.
- [x] Slice 2: typeahead candidate read model for Tags.
- [x] Slice 3: tokenized field UI for Tags.
- [x] Slice 4: Conversation list scoping by selected Tag tokens.
- [x] Slice 5: interaction with Conversation Lenses remains independent.
- [ ] Slice 6: empty states and reset/clear behavior.
- [x] Slice 7: persistence rules for retrieval state: no persistence in the
      first slice.

## Completion Criteria

Structured Conversation Retrieval is ready for implementation when:

- [x] the token model is settled for the first slice;
- [x] the ownership boundary is settled;
- [x] the relationship to Conversation Intent is settled;
- [x] the relationship to Conversation Lenses is settled;
- [x] message-content search is explicitly out of scope;
- [x] UI behavior is clear enough to test manually;
- [x] the feature can be implemented without creating a new sidebar mode for
      each token type.

## Explicit Non-Goals

- [ ] Do not implement message-content search here.
- [ ] Do not implement Tags here.
- [ ] Do not implement Working Sets here.
- [ ] Do not implement AI classification here.
- [ ] Do not design database schema here.
- [ ] Do not turn retrieval tokens into permanent sidebar modes.
