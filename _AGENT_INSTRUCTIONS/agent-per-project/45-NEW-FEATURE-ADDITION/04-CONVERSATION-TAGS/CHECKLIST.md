---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: draft
status: exploratory
links:
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
---

# Conversation Tags Checklist

This checklist is intentionally exploratory. It defines phases and completion
criteria for future work, but it is not authorization to implement.

## Planning Package

- [x] Create feature package folder.
- [x] Define product rationale.
- [x] Define product philosophy.
- [x] Define architectural considerations.
- [x] Define UX considerations.
- [x] Define open questions.
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
- [ ] Decide whether Core Favourites remain separate from tag infrastructure.
- [ ] Decide minimum deletion confirmation behavior.
- [ ] Decide whether first version includes tag management surface.

## Phase 1: Architecture Plan

- [ ] Define overlay ownership boundary.
- [ ] Define Conversation identity reference strategy.
- [ ] Define read-model merge points.
- [ ] Define feature ownership between Conversations, Search, Messages, and
      overlay infrastructure.
- [ ] Define how tags appear in Conversation display models.
- [ ] Define how future Search/Discovery surfaces may consume tags without
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
- [ ] Filter Browse Conversations by a single tag.

This phase should prove the model without implementing full Discovery, Working
Sets, Saved Investigations, AI suggestions, or sync.

## Phase 3: Cross-Lens Integration

Potential later work:

- [ ] Show tag state consistently in Conversation sidebar cards.
- [ ] Show tag state consistently in Contact-derived Conversation lists.
- [ ] Show tag state consistently in right-side Conversation excerpt cards.
- [ ] Allow Search results to request tag actions on the source Conversation.
- [ ] Allow All Messages/Search to refine by tag scope.
- [ ] Allow Discovery lenses to use tag scopes.

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

## Explicit Non-Completion Criteria

The feature does not require the following to be considered initially complete:

- AI-assisted tagging.
- Tag sync.
- Nested tags.
- Folder hierarchy.
- Saved investigations.
- Full bulk-edit workflow.
- Rich tag analytics.
