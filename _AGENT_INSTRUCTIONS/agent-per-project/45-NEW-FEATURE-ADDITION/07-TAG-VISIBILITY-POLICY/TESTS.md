---
tier: project
scope: validation-strategy
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: canonical
status: first-slice-implemented
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./CHECKLIST.md
---

# Tag Visibility Policy Tests

This document records the validation strategy and implemented first-slice test
coverage.

## Repository / Persistence Tests

Implemented tests prove:

- Tag definitions can persist a visibility policy.
- Existing Tags without explicit policy default to ordinary visibility.
- Updating visibility policy does not alter Tag assignments.

Future tests should also prove:

- Deleting a Tag removes both assignment and policy state according to the Tag
  deletion rules.
- Overlay remains the only persistence owner.

## Read-Model Tests

Implemented tests prove:

- Conversation read models merge Tag visibility policy at read time.
- Default Conversations Browse excludes Conversations with suppressing Tags.
- Explicit Tag-token retrieval includes Conversations carrying the selected
  Tag, even if the Tag is suppressing.
- Organize By / Conversation Lenses remain independent of visibility policy.

Future tests should also prove:

- Multiple Tags are handled correctly when at least one Tag suppresses default
  Browse.

## UI / Widget Tests

Future tests should prove:

- The visibility affordance updates Tag policy through Conversation-owned
  actions.
- Conversation cards remain presentation-only.
- Suppressed Tags are communicated clearly where policy is edited.
- The Conversations list updates after a Tag visibility change.
- Explicit retrieval of a suppressing Tag visibly returns matching
  Conversations.

## Architecture Tests

Future tests should guard:

- graph projection does not import or write Tag visibility policy;
- non-Conversations features do not own Tag visibility actions;
- widgets do not write overlay directly;
- no Conversation-level suppression flag is introduced as a parallel mechanism.

## Manual Verification

The first implementation should be manually verified with this workflow:

1. Create a Tag named `2FA`.
2. Apply it to several low-value Conversations.
3. Mark the `2FA` Tag as suppressed from ordinary Browse.
4. Confirm default Conversations Browse no longer shows those Conversations.
5. Type `2f` in Structured Conversation Retrieval.
6. Accept the `2FA` Tag token.
7. Confirm the tagged Conversations appear.
8. Remove the token and confirm ordinary Browse becomes clean again.
9. Restart the app and confirm the policy persists.

## Regression Risks

- Suppression accidentally becomes deletion.
- Suppressed Conversations become impossible to retrieve.
- Contact/Search explicit contexts accidentally hide matching Conversations.
- Visibility policy leaks into graph projection.
- Tag retrieval starts behaving like message-content search.

## Implemented Focused Verification

As of 2026-07-12, the focused verification set includes:

- overlay migration from schema v7 to v8 adds Tag visibility policy;
- overlay Tag repository persists Tag visibility policy;
- Conversation Tag actions update visibility policy through the repository;
- Conversation signature display suppresses default Browse results while
  preserving explicit Tag-token retrieval;
- existing Tag-token retrieval and pure Conversation card presentation tests
  still pass.
