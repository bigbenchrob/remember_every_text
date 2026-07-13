---
tier: project
scope: ui-ux-evaluation
owner: agent-per-project
last_reviewed: 2026-07-13
source_of_truth: draft
status: evaluation
links:
  - ./conversation_card.md
  - ../../../45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md
  - ../../../45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../../../40-FEATURES/conversations/README.md
tests: []
---

# Conversation Card Chat Hook

## Question

Should one-to-one Conversation Cards display the formatted chat hook in
addition to the Contact display name?

Examples:

```text
Claire
via claire@student.ubco.ca

Rusung
via +1 604-555-1234
```

The purpose is to explain why multiple canonical Conversations with the same
display identity exist.

## Current Behavior

Conversation Cards correctly answer:

> Who is this Conversation with?

For many Conversations, that is enough. The Contact display name, glyph,
message count, date range, tags, and favourite state establish the
Conversation as a recognizable entity.

However, multiple one-to-one Conversations may resolve to the same Contact
display name. This can happen when the same person has used different phone
numbers, email addresses, devices, work accounts, school accounts, or
historical handles.

In those cases, several Conversation Cards can appear to describe the same
Conversation even though they are distinct canonical graph entities.

## Rationale

The Conversation Card should reinforce the One Conversation principle: each
card represents one canonical Conversation, even when several Conversations
resolve to the same person.

A quiet formatted chat hook can help explain why two otherwise similar cards
are separate:

```text
Claire
via claire@student.ubco.ca
```

The hook is not the primary identity. It is supporting evidence that explains
the communication endpoint used by that Conversation.

This is especially useful during browsing and retrieval because it reduces the
need for the user to open each Conversation simply to discover which handle it
represents.

## Proposed Behavior

Evaluate adding a formatted chat hook as secondary identity information for
one-to-one Conversation Cards only.

The hook should be displayed only when it improves disambiguation. It should:

- sit below or near the Contact display name;
- use subdued metadata styling;
- remain visually quieter than the title;
- avoid competing with tags, glyphs, message statistics, and date range;
- be formatted for user comprehension rather than raw database fidelity.

Potential wording:

```text
via +1 604-555-1234
via claire@student.ubco.ca
```

Final wording and styling should be decided during implementation design, not
in this evaluation.

## One-To-One Versus Group Conversations

The recommendation applies to one-to-one Conversations only.

Group Conversations already derive identity from participant membership. Their
titles, participant suffixes, and glyphs communicate that they are group
contexts. Showing one chat hook for a group could imply that a single endpoint
defines the group, which is usually misleading.

Do not show chat hooks on group Conversation Cards unless a later use case
justifies it.

## Relationship To Contact Tags

This feature is independent of Contact-backed Conversation Tags.

Contact-backed Conversation Tags answer:

> Which relationship chapter am I trying to retrieve?

Formatted chat hooks answer:

> Why is this a separate Conversation?

The two concepts complement each other. They should not be merged.

Contact-backed Conversation Tags are identity-backed retrieval coordinates.
Chat hooks are visual disambiguation metadata for a Conversation Card.

## Relationship To Conversation Identity

The chat hook should reinforce Conversation identity without replacing the
Contact display name.

The display name remains the user-facing person identity:

```text
Claire
```

The chat hook explains the source endpoint that makes this Conversation
distinct:

```text
via claire@student.ubco.ca
```

This keeps the card aligned with MessageLens identity rules: user-assigned or
known Contact identity wins as the primary label, while handles remain
metadata unless the user is explicitly working at handle scope.

## UI Implications

The main UI risk is visual noise. Conversation Cards already carry several
signals:

- title;
- participant count suffix;
- tags;
- favourite star;
- topology glyph;
- message count;
- date range;
- lens-driven emphasis.

The chat hook should be added only if it remains quiet and improves
disambiguation.

Likely UI constraints:

- one short line maximum;
- compact formatting;
- no badge treatment;
- no strong color;
- no prominent icon unless later testing proves it helps;
- omit or truncate gracefully when space is tight.

The card should still read first as:

```text
Conversation with Claire
```

not:

```text
Conversation with +1 604...
```

## Potential Risks

- The card becomes too dense.
- Handles regain excessive prominence over user-assigned Contact names.
- Users read the hook as a separate action or filter rather than supporting
  identity metadata.
- Group Conversation behavior becomes confusing if the hook is applied too
  broadly.
- The implementation accidentally duplicates handle-formatting logic instead
  of consuming a resolved display/read model.

These risks are manageable if the hook remains secondary and is supplied by
the Conversation read model rather than assembled inside the card widget.

## Future Implementation Slice

A future implementation slice should be narrow:

1. Add or expose a resolved formatted chat hook for one-to-one Conversation
   display data.
2. Render it quietly on canonical Conversation Cards when available and useful.
3. Keep group Conversation Cards unchanged.
4. Verify that multiple Conversations with the same Contact display name become
   distinguishable without making the cards feel crowded.

Do not use this slice to implement Contact-backed Conversation Tags,
Structured Conversation Retrieval contact tokens, or a broader identity
refactor.

## Recommendation

Yes, evaluate this as a future UI refinement.

One-to-one Conversation Cards should likely display a quiet formatted chat hook
when it helps distinguish multiple canonical Conversations with the same
Contact display name.

This would improve Conversation disambiguation while preserving the clean
Conversation Card design, provided the hook remains secondary and is not shown
for group Conversations by default.
