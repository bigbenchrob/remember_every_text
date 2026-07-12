---
tier: project
scope: planning-checklist
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: exploratory
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
tests: []
---

# Structured Conversation Retrieval Checklist

This checklist is exploratory. It is not authorization to implement.

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

- [ ] Confirm Structured Conversation Retrieval is the right term internally.
- [ ] Confirm user-facing wording direction.
- [ ] Confirm retrieval answers "Which Conversation am I trying to work with?"
- [ ] Confirm All Messages Search remains the message-content retrieval system.
- [ ] Confirm retrieval and Conversation Lenses remain orthogonal.
- [ ] Confirm this feature is intended to reduce sidebar mode proliferation.

## Phase 1: Token Model Planning

- [ ] Decide first-slice token types.
- [ ] Decide candidate grouping and ranking.
- [ ] Decide whether tokens combine as AND by default.
- [ ] Decide whether OR/negation are deferred.
- [ ] Decide how empty results explain active tokens.
- [ ] Decide how suppressed Conversations are included or excluded.

## Phase 2: Ownership Planning

- [ ] Confirm `features/conversations` owns the retrieval experience.
- [ ] Confirm Conversation Intent owns intent concepts consumed by retrieval.
- [ ] Confirm graph/read models provide Conversation metadata and identity.
- [ ] Confirm Search does not own Conversation retrieval.
- [ ] Confirm widgets render tokens and candidates but do not infer retrieval
      semantics.

## Phase 3: UI Walk Planning

- [ ] Decide where retrieval appears in the Conversations sidebar.
- [ ] Decide whether it replaces the current Conversation search field.
- [ ] Preserve Favourites/Browse mode behavior unless explicitly changed.
- [ ] Keep Organize by / Conversation Lens controls separate from retrieval.
- [ ] Define token visual language.
- [ ] Define keyboard and mouse interaction expectations.

## Phase 4: Future Implementation Slices

Do not begin until explicitly approved.

- [ ] Slice 1: typed retrieval state model.
- [ ] Slice 2: typeahead candidate read model.
- [ ] Slice 3: tokenized field UI.
- [ ] Slice 4: Conversation list scoping by selected tokens.
- [ ] Slice 5: interaction with Conversation Lenses.
- [ ] Slice 6: empty states and reset/clear behavior.
- [ ] Slice 7: persistence rules for retrieval state, if any.

## Completion Criteria

Structured Conversation Retrieval is ready for implementation when:

- [ ] the token model is settled for the first slice;
- [ ] the ownership boundary is settled;
- [ ] the relationship to Conversation Intent is settled;
- [ ] the relationship to Conversation Lenses is settled;
- [ ] message-content search is explicitly out of scope;
- [ ] UI behavior is clear enough to test manually;
- [ ] the feature can be implemented without creating a new sidebar mode for
      each token type.

## Explicit Non-Goals

- [ ] Do not implement message-content search here.
- [ ] Do not implement Tags here.
- [ ] Do not implement Working Sets here.
- [ ] Do not implement AI classification here.
- [ ] Do not design database schema here.
- [ ] Do not turn retrieval tokens into permanent sidebar modes.
