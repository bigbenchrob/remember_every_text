---
tier: project
scope: implementation-checklist
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: draft
status: exploratory
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./TESTS.md
---

# Tag Visibility Policy Checklist

## Phase 0 - Architecture Confirmation

- [x] Seed decision establishes visibility as Tag definition policy.
- [x] Package created from the approved seed.
- [ ] Confirm whether the first implementation requires a dedicated
  implementation readiness audit.
- [ ] Confirm final first-slice scope before code changes.

## Phase 1 - First Vertical Slice

- [ ] Extend Tag definition read/write model with a visibility policy.
- [ ] Persist visibility policy in overlay/user-intent storage.
- [ ] Keep graph projection unchanged.
- [ ] Add Conversation-owned action for updating a Tag visibility policy.
- [ ] Merge Tag visibility into Conversation read models at read time.
- [ ] Exclude Conversations carrying suppressing Tags from default
  Conversations Browse.
- [ ] Ensure explicit Tag-token retrieval still includes matching suppressed
  Conversations.
- [ ] Provide a minimal UI affordance to mark/unmark a Tag as suppressed from
  ordinary Browse.
- [ ] Keep Conversation Cards pure presentation.

## Phase 2 - Cross-Surface Policy Clarification

- [ ] Decide whether Contact-scoped Conversation lists respect suppression by
  default.
- [ ] Decide whether Favourites override suppressing Tags in default Browse.
- [ ] Decide how Search result context displays suppressed Conversations.
- [ ] Decide whether Discovery excludes suppressing Tags by default.
- [ ] Decide how suppressed Tags appear in Tag suggestions and token retrieval.

## Phase 3 - Management And Cleanup

- [ ] Design a future Tag management / cleanup surface if needed.
- [ ] Add support for finding all suppressing Tags.
- [ ] Add support for reversing suppression safely.
- [ ] Consider a built-in generic `Hidden` / `Suppressed` Tag.
- [ ] Consider explanatory empty or filtered-state copy.

## Phase 4 - Deferred Enhancements

- [ ] AI-suggested suppressing classifications.
- [ ] Bulk apply suppressing Tag.
- [ ] Import/export of visibility policy.
- [ ] Sync of Tag definitions and visibility.
- [ ] Visibility analytics or counts.

## Non-Goals For First Slice

- [ ] Do not implement Conversation-level hidden flags.
- [ ] Do not modify graph projection.
- [ ] Do not filter message evidence.
- [ ] Do not add Boolean retrieval syntax.
- [ ] Do not implement a full Tag Manager.
- [ ] Do not implement AI suggestions.
