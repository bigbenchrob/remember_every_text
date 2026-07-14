---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: canonical
status: first-slice-implemented
links:
  - ./README.md
  - ./PROPOSAL.md
  - ../04-CONVERSATION-TAGS/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
---

# Tag Visibility Policy Design Notes

## The User Decision

The user is usually not deciding:

> Hide this row.

The user is deciding:

> Conversations of this kind are usually not useful while browsing.

That distinction matters. It moves the product from individual row cleanup to
semantic classification.

## Suppression Language

"Hidden" can imply deletion, secrecy, or disappearance.

"Suppressed from Browse" better expresses the behavior:

- the Conversation still exists;
- the evidence remains available;
- the Tag remains useful;
- the Conversation does not clutter ordinary browsing.

User-facing language should be tested, but implementation docs should preserve
the stronger conceptual distinction:

```text
suppressed != deleted
suppressed != graph exclusion
suppressed == excluded from ordinary browse/discovery unless explicitly requested
```

## Browse Versus Explicit Retrieval

Default Browse and explicit retrieval are different modes.

Default Browse should help the user see meaningful Conversations without
constant noise.

Explicit retrieval should respect what the user asked for, even if the matching
Tag is normally suppressed.

Example:

```text
Default Browse:
  excludes 2FA if 2FA is suppressing

Tag token retrieval:
  includes 2FA because the user explicitly asked for it
```

This makes suppression safe. Users can clean the browsing surface without
losing access.

## Built-In Versus User Tags

The package leaves open whether suppressing Tags are:

- ordinary user-created Tags with a visibility setting;
- built-in system Tags such as `Hidden`;
- both.

The preferred long-term model is both:

- semantic user Tags such as `2FA` or `Delivery` carry visibility policy;
- a generic built-in `Hidden` or `Suppressed` Tag exists for one-off hiding.

The built-in Tag should not become a separate suppression mechanism. It should
still be represented as a Tag with visibility policy.

## Conflict Cases

Potential conflict cases should be handled deliberately:

- Favourite + suppressing Tag;
- multiple Tags with different visibility policies;
- selected Tag token that normally suppresses Browse;
- Contact page showing a Conversation suppressed from global Browse;
- Search result context pointing to a suppressed Conversation.

The likely rule is:

> Explicit context wins over default visibility.

If the user explicitly chooses a Contact, Tag, Search result, or Conversation,
the Conversation should be shown. Visibility policy primarily affects default
browsing and unsolicited discovery.

## Visual Treatment

Suppressing Tags should not need loud styling.

Possible treatments:

- a quiet secondary label in the Tag editor;
- a subdued "Suppressed from Browse" row;
- a small visibility icon next to the Tag in administrative contexts;
- no special styling on ordinary Conversation Cards unless the current surface
  is explaining why an item is absent or included.

Conversation Cards should remain focused on identity. Visibility policy should
not dominate the card.

## Relationship To Conversation Lenses

Conversation Lenses organize visible sets of Conversations.

Tag Visibility Policy scopes the default set before lenses operate.

For example:

```text
Default Browse set
  -> exclude suppressing Tags
  -> organize by Most recently updated
```

Explicit retrieval can create a different set:

```text
Tag token: 2FA
  -> include Conversations tagged 2FA
  -> organize by Most recently updated
```

Organize By remains independent. Visibility policy changes which Conversations
enter the set; lenses decide how that set is emphasized.

## First-Slice UI Candidate

A minimal first slice adds a Tag-level action near the existing Tag
creation/application affordance:

- "Suppress this Tag from Browse"
- "Include this Tag in Browse"

The implemented wording and icon treatment may be refined later. The first
slice proves the behavior without finalizing every management workflow.

## Open Design Questions

- What final user-facing wording best communicates suppression without implying
  deletion?
- Should the first implementation expose visibility from the Conversation card
  affordance, a lightweight Tag popover, or a future Tag management surface?
- Should suppressed Tags appear in the Tag suggestion list with an indicator?
- Should default Browse show a count of suppressed Conversations, or would that
  add noise?
- Should Contact-scoped Conversation lists respect suppression by default, or
  does explicit Contact context imply inclusion?

## Implemented First-Slice Answers

- The first implementation exposes visibility in the existing Conversation Tag
  editor rather than adding a Tag Manager.
- Suppressing a Tag affects ordinary Conversations Browse.
- Explicit Tag-token retrieval includes matching Conversations even when the
  selected Tag normally suppresses ordinary Browse.
- Conversation Cards remain focused on identity. Suppression state is edited
  where Tags are edited, not made dominant on every card surface.
