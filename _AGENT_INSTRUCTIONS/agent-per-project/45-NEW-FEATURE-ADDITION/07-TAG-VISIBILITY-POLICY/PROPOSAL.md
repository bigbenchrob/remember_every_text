---
tier: project
scope: feature-proposal
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: canonical
status: first-slice-implemented
links:
  - ./README.md
  - ./DESIGN_NOTES.md
  - ./CHECKLIST.md
  - ./TESTS.md
  - ../04-CONVERSATION-TAGS/README.md
  - ../04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/08-tag-visibility-policy.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
---

# Tag Visibility Policy Proposal

## Purpose

Add visibility policy to Conversation Tag definitions so that Tags can influence
ordinary Conversation browsing and Discovery without removing Conversations
from the underlying graph.

The motivating example is simple:

> I do not want to browse 2FA Conversations most of the time.

That is not primarily a request to hide one Conversation. It is a request to
classify a kind of Conversation and adjust how that class participates in
ordinary browsing.

## Product Rationale

MessageLens is a memory exploration and rediscovery application. It should help
users focus on meaningful communication history while keeping complete evidence
available.

Some Conversations are real evidence but are rarely useful during ordinary
browsing:

- 2FA alerts;
- spam;
- delivery notifications;
- appointment reminders;
- one-off transactional notices;
- low-value automated business messages.

Users should not need to delete, individually hide, or repeatedly ignore these
Conversations. They should be able to classify the class of Conversation and
let browsing respect that classification.

## Core Model

The approved model is:

```text
Conversation
  -> Tag Assignment
  -> Tag Definition
  -> Visibility Policy
```

The rejected model is:

```text
Conversation
  -> Suppressed
```

Visibility belongs to the Tag definition because suppression is usually about a
semantic class of Conversations, not one isolated row in a list.
Visibility is attached to Tag definitions because users typically wish to
suppress semantic classes of Conversations rather than individual
Conversations.

## Visibility Policy

At the product level, a Tag definition may eventually carry a policy such as:

- ordinary: included in normal browsing and Discovery;
- suppressed: excluded from ordinary browsing and default Discovery;
- explicit-only: visible only when directly requested by tag/retrieval context.

The exact enum names and storage representation are implementation details and
should not be settled in this proposal.

The important rule is that ordinary browsing can exclude Conversations because
of Tags attached to them, while explicit retrieval by that Tag can still return
them.

## Relationship To Existing Concepts

### Tags

Tags remain semantic labels. Visibility policy is a property of a Tag
definition, not a separate tag-like feature.

The tag `Family` will usually behave as ordinary meaning.

The tag `2FA` may behave as a suppressing classification.

### Conversation Intent

Tag Visibility Policy is still Conversation Intent because it is user-authored
or user-confirmed meaning attached to stable Conversation identity.

It refines the earlier Conversation Intent category "Visibility" by attaching
visibility behavior to Tag definitions rather than creating an independent
Conversation-level suppression mechanism.

### Structured Conversation Retrieval

Structured Conversation Retrieval must be able to retrieve suppressed
Conversations explicitly.

Example:

```text
Browse Conversations
  -> excludes Conversations tagged 2FA when 2FA is suppressing

Retrieve tag token "2FA"
  -> returns Conversations tagged 2FA
```

This preserves the distinction between default browsing and explicit
retrieval.

### Discovery

Default Discovery should usually respect suppressing Tags so low-value
Conversations do not dominate exploratory surfaces.

Discovery may later offer explicit lenses such as:

- show suppressed Conversations;
- show transactional Conversations;
- rediscover old suppressed business alerts.

Those are future features. They should consume visibility policy rather than
owning it.

### Favourites

Favourites are not visibility policy.

A Conversation may be Favourite and carry a suppressing Tag only if the user
creates that unusual state. Future UI should make such conflicts understandable
but should not collapse Favourites into visibility.

## UX Direction

The implementation does not need to expose "Tag Visibility Policy" as raw UI
language.

User-facing actions may be more natural:

- Suppress Tag from Browse;
- Hide Conversations with this Tag;
- Show only when requested;
- Include in normal browsing.

The Tag creation workflow should still be use-first, not administration-first.
Users should discover a class such as `2FA` through use, then decide that this
class should not appear in normal browsing.

## Architectural Direction

- Tag definitions and visibility policy are persisted in overlay/user-intent
  storage.
- Graph projection does not read or write visibility policy.
- `features/conversations` owns the user-facing Tag visibility workflow.
- Read models merge graph facts, Tag assignments, and Tag definition policy at
  read time.
- Sidebar state does not own visibility.
- Widgets render resolved display/read-model data and invoke explicit actions.
- Search, Messages, Contacts, and Discovery may consume visibility-aware read
  models but must not own the policy model.

## Proposed First Slice

The first implementation is deliberately small:

1. Allow one existing Tag definition to be marked as suppressing ordinary
   Browse.
2. Exclude Conversations carrying that Tag from default Conversations Browse.
3. Ensure explicit Tag-token retrieval for that Tag still returns those
   Conversations.
4. Display enough UI state that the user understands the Tag has a visibility
   consequence.

The implemented slice uses overlay persistence on Tag definitions, merges
visibility policy into Conversation read models, exposes a minimal action in
the existing Conversation Tag editor, and keeps explicit Tag-token retrieval as
an override of default Browse suppression.

Do not implement a full Tag Manager, bulk visibility controls, complex
visibility hierarchies, or Discovery-specific policy UI in the first slice.

## Non-Goals

Do not implement:

- Conversation-level hidden flags;
- message-level visibility;
- source import changes;
- graph projection changes;
- hard deletion;
- archive/recovery filtering;
- AI suppression suggestions;
- full Tag Manager;
- multi-user sync;
- visibility analytics.

## Acceptance Criteria For This Proposal

- Visibility is defined as Tag definition policy.
- Suppression is not deletion.
- Suppressed Conversations remain explicitly retrievable.
- Ordinary browsing can exclude low-value classes of Conversations.
- The model respects One Conversation and overlay/user-intent ownership.
- The package does not require graph or source import changes.
