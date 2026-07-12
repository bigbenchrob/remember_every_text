---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: consolidated-exploratory
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
---

# Conversation Tags Checklist

This checklist is intentionally exploratory. It defines phases and completion
criteria for future tag work, but it is not authorization to implement.

## Planning Package

- [x] Create feature package folder.
- [x] Define product rationale.
- [x] Define product philosophy.
- [x] Position Tags on the approved Conversation Intent architecture.
- [x] Define UX considerations.
- [x] Narrow open questions to tag-specific product questions.
- [x] Define implementation phases.
- [x] Define completion checklist.
- [x] Define future validation strategy.
- [ ] Review package with user.
- [ ] Decide whether Conversation Tags should enter active implementation.

## Phase 0: Product Decisions

- [ ] Confirm first-slice scope.
- [ ] Decide whether first version includes tag color.
- [ ] Decide tag creation/editing entry point.
- [ ] Decide whether tags appear on compact Conversation Cards.
- [ ] Decide minimum deletion confirmation behavior.
- [ ] Decide whether first version includes tag management surface.
- [ ] Decide duplicate-name normalization behavior.
- [ ] Decide whether tags support descriptions in the first slice.
- [ ] Decide whether tag retrieval first appears in Browse, Structured
      Conversation Retrieval, or both.

## Phase 1: Architecture Alignment

- [x] Confirm overlay ownership boundary is inherited from Conversation Intent.
- [x] Confirm stable Conversation identity is inherited from Conversation
      Intent.
- [x] Confirm feature ownership is inherited from Conversation Intent.
- [ ] Define tag-specific read-model display data.
- [ ] Define how tags appear in Conversation display models.
- [ ] Define how Structured Conversation Retrieval may consume tags without
      owning them.
- [ ] Identify migration or compatibility concerns.

## Phase 2: Minimal Product Slice

Candidate scope:

- [ ] Create a tag.
- [ ] Rename a tag.
- [ ] Delete a tag.
- [ ] Add a tag to a Conversation.
- [ ] Remove a tag from a Conversation.
- [ ] Show tags in at least one Conversation-owned surface.
- [ ] Filter or retrieve Conversations by a single tag, if included in the
      approved first slice.

This phase should prove the model without implementing full Discovery, Working
Sets, message-search refinement, AI suggestions, or sync.

## Phase 3: Cross-Lens Integration

Potential later work:

- [ ] Show tag state consistently in Conversation sidebar cards.
- [ ] Show tag state consistently in Contact-derived Conversation lists.
- [ ] Show tag state consistently in right-side Conversation excerpt cards.
- [ ] Allow Search results to request tag actions on the source Conversation.
- [ ] Allow All Messages/Search to refine by tag scope.
- [ ] Allow Discovery lenses to use tag scopes.
- [ ] Allow Structured Conversation Retrieval to use tag tokens.

## Phase 4: Management And Scale

Potential later work:

- [ ] Dedicated tag management surface.
- [ ] Tag ordering.
- [ ] Tag color, if approved.
- [ ] Bulk tagging from future Working Sets.
- [ ] Export/import format.
- [ ] Sync readiness review.

## Completion Criteria

Conversation Tags can be considered architecturally complete when:

- [ ] Tags are stored as overlay/user intent, not graph projection.
- [ ] Tags attach to stable Conversation identity.
- [ ] A Conversation can have multiple tags.
- [ ] Tag state appears consistently wherever the Conversation appears.
- [ ] Renaming a tag updates its presentation everywhere.
- [ ] Deleting a tag has clear global semantics.
- [ ] Removing a tag from a Conversation has clear local semantics.
- [ ] Search, Messages, Contacts, and Discovery can consume tag state without
      owning tag semantics.
- [ ] The implementation preserves the One Conversation principle.
- [ ] The UI distinguishes Tags from Favourites and Working Sets.
- [ ] The implementation treats Tags as durable Meaning intent, not a local
      sidebar mode.

## Explicit Non-Completion Criteria

The feature does not require the following to be considered initially complete:

- AI-assisted tagging.
- Tag sync.
- Nested tags.
- Folder hierarchy.
- Saved investigations.
- Full bulk-edit workflow.
- Rich tag analytics.
