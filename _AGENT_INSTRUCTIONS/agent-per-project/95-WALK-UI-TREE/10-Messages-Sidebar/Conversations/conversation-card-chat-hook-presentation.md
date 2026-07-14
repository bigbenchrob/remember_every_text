---
tier: project
scope: ui-ux-evaluation
owner: agent-per-project
last_reviewed: 2026-07-13
source_of_truth: draft
status: evaluation
links:
  - ./conversation-card-chat-hook.md
  - ./conversation_card.md
  - ../../../45-NEW-FEATURE-ADDITION/04-CONVERSATION-TAGS/01-OPEN-QUESTION-EVALUATION/09-contact-tags.md
  - ../../../45-NEW-FEATURE-ADDITION/05-CONVERSATION-INTENT-ARCHITECTURE/README.md
tests: []
---

# Conversation Card Chat Hook Presentation

## Question

How should the formatted chat hook be visually presented on a one-to-one
Conversation Card?

The current implementation displays:

```text
Rusung
via rusung@icloud.com
```

The functionality is correct. The remaining question is whether this visual
presentation best supports the user's mental model.

## Observation

The chat hook is not ordinary metadata.

It explains why several Conversations with the same Contact display name exist.
Its job is to disambiguate otherwise identical Conversation Cards. That makes it
part of Conversation identity, not a statistic like message count or date range.

The card should therefore read as:

```text
Conversation identity
Relationship topology glyph
Conversation statistics
Conversation intent
```

not:

```text
Name
Miscellaneous metadata
Glyph
Statistics
```

## Current Concern

The current presentation:

```text
Rusung
via rusung@icloud.com
```

uses light gray text and the word `via`.

This has two possible drawbacks:

- the hook can visually compete with the relationship glyph as a separate row
  of metadata;
- the hook can appear to be miscellaneous descriptive text rather than part of
  the Conversation identity block.

As a result, the eye may move:

```text
Name
↓
gray metadata
↓
glyph
```

instead of perceiving the name and endpoint as a single identity unit.

## Alternative Presentation

Evaluate presenting the hook as part of the identity block:

```text
Rusung
rusung@icloud.com
```

In this version:

- `via` is removed;
- the hook uses the same dark text color as the title, or a very near variant;
- the hook uses a smaller font size and regular weight;
- the title and hook read as one two-line identity block;
- the glyph becomes the next visual block rather than competing with the hook.

This treatment better matches the hook's purpose: it tells the user which
Conversation identity this card represents.

## Visual Hierarchy

Recommended hierarchy:

1. Contact display name remains primary.
2. Chat hook sits immediately below the name as a quiet identity qualifier.
3. Relationship glyph follows as the next visual block.
4. Message count, date range, tags, and lens-driven highlights remain
   subordinate.

The hook should be visually quieter than the title but not so quiet that it
reads as incidental metadata. It should feel like the second line of a name
plate.

Avoid:

- badge treatment;
- icon treatment;
- strong color;
- large spacing between title and hook;
- visual styling that makes the hook look like a filter, action, or warning.

## Typography Direction

Recommended typography direction:

- no `via` prefix;
- one line only;
- title color or near-title color;
- smaller than the title;
- regular weight;
- truncate gracefully;
- tight vertical spacing below the name.

The aim is not to make handles primary again. The Contact display name remains
the main label. The hook explains the particular communication endpoint only
when that endpoint is needed to understand why this is a separate Conversation.

## Conditional Display

The chat hook should probably appear only when it provides useful
disambiguation.

Common case:

```text
Claire
```

If there is only one Conversation for a resolved Contact display identity, the
hook adds noise without improving comprehension.

Disambiguation case:

```text
Rusung
rusung@icloud.com

Rusung
+1 503-776-0150

Rusung
+974 667 80166
```

When multiple one-to-one Conversations share the same resolved display identity,
the hook becomes the disambiguator. This keeps the card clean in the common case
while making duplicate-looking Conversations immediately understandable.

## Relationship To Conversation Identity

The hook reinforces the One Conversation principle.

Several cards may share the same person identity, but each card still represents
one canonical Conversation. The hook answers:

> Why is this a separate Conversation?

That answer belongs near the display name because it qualifies the identity of
the Conversation itself.

The hook should not override the app-wide identity rule that user-assigned or
known Contact display names win. Handles remain secondary. They become visible
only as identity qualifiers when the primary identity would otherwise be
ambiguous.

## Relationship To The Relationship Glyph

The glyph communicates relationship topology and activity texture.

The chat hook communicates endpoint disambiguation.

These should not compete. Placing the hook tightly under the display name helps
the user read name and endpoint as one identity block. The glyph then reads as
the next block: the shape and history of that Conversation.

This produces a clearer sequence:

```text
Who / which endpoint?
What did this relationship look like over time?
How large / when active?
What user meaning is attached?
```

## Relationship To Contact Tags

Formatted chat hooks and Contact-backed Conversation Tags remain separate
concepts.

Formatted chat hooks answer:

> Why is this a separate Conversation?

Contact-backed Conversation Tags answer:

> Which relationship chapter am I trying to retrieve?

The hook is an identity qualifier for a Conversation Card. Contact-backed Tags
are retrieval coordinates and user-authored meaning. They may both appear on or
near Conversation surfaces in the future, but they should remain visually and
conceptually distinct.

## Risks

- Showing hooks unconditionally may add visual noise to many ordinary
  one-to-one cards.
- Rendering hooks too faintly may make them look like incidental metadata.
- Rendering hooks too strongly may make handles appear to outrank Contact names.
- Duplicate detection may require read-model support so widgets do not decide
  when hooks are useful.
- Conditional display must be stable; hooks should not flicker in and out based
  on transient filtering unless the rule is intentionally scoped to the current
  visible collection.

## Future Implementation Slice

A future implementation slice should be narrow:

1. Determine whether the card belongs to a duplicate display-identity group in
   the relevant Conversation collection.
2. Show the hook only for one-to-one cards in that duplicate group.
3. Remove the `via` prefix.
4. Render the hook as a second identity line: near-title color, smaller size,
   regular weight.
5. Keep group Conversation Cards unchanged.
6. Verify the presentation in Conversations Browse and Contacts / By
   conversation.

Do not use that slice to implement Contact Tags, Structured Conversation
Retrieval contact tokens, or broader identity refactors.

## Recommendation

Refine the chat hook into a conditional Conversation identity qualifier.

The preferred direction is:

```text
Rusung
rusung@icloud.com
```

shown only when multiple one-to-one Conversations share the same resolved
display identity.

This preserves the clean Conversation Card design while making duplicate-looking
Conversation Cards understandable. It also strengthens the user's mental model:
the endpoint is not miscellaneous metadata; it is the reason this canonical
Conversation is distinct from another Conversation with the same person.
