---
tier: project
scope: open-question-evaluation
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: decision-record
status: recommended
links:
  - ../README.md
  - ../PROPOSAL.md
  - ../DESIGN_NOTES.md
  - ../../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
---

# Open Question Evaluation: Tag Creation And Management Workflow

## Question

What is the correct workflow for creating, editing, and managing Conversation
Tags?

The design goal is to maximize natural adoption without making Tags feel like
filing, administration, or taxonomy maintenance.

## Recommendation

Conversation Tags should be **Conversation-first**, not Tag-first.

The governing product principle:

> Tags should be discovered through use, not through administration.

Users normally create Tags when they recognize the meaning of a Conversation.
They should not need to construct, browse, or maintain a taxonomy before Tags
become useful.

The primary tagging moment should happen while the user is looking at a
Conversation and recognizes its meaning:

```text
I am looking at this Conversation
  -> this is about Hawaii
  -> apply or create "Hawaii Trip"
```

This makes tagging feel like preserving meaning. A global Tag Manager should
exist only as a secondary cleanup and maintenance surface after tags exist.

## Rationale

MessageLens is a memory exploration and rediscovery application. Tags should
extend that model by allowing the user to name the meaning they notice while
reading or recognizing a Conversation.

A Tag-first workflow asks the user to maintain a classification system before
they have a reason to care about it. That encourages folder-like thinking:

```text
make categories
  -> file Conversations into categories
```

That is the wrong mental model for MessageLens. The better model is:

```text
notice meaning
  -> preserve that meaning
  -> later retrieve or rediscover through it
```

Tags should therefore emerge from Conversation work, not from a standalone
administrative surface.

## Primary Workflow

The primary workflow should be available from Conversation-owned surfaces:

- Conversation sidebar cards;
- Contact-derived Conversation cards;
- right-side Conversation excerpt cards;
- future expanded Conversation detail surfaces.

The user should be able to:

1. Open a tag affordance on the Conversation.
2. See already-applied tags.
3. Search/select an existing tag.
4. Type a new tag name if no existing tag fits.
5. Confirm creation and apply it to the current Conversation.
6. Remove an assigned tag from the current Conversation.

The UI should make it clear that the user is tagging the underlying
Conversation, not the visible row, sidebar mode, or current card instance.

## Secondary Workflow

A global Tag Manager is useful, but it is not the normal tagging workflow.

Its role is occasional maintenance after Tags have accumulated. The primary
workflow remains creating and applying Tags in Conversation context.

The secondary maintenance surface should answer questions such as:

- What tags exist?
- How many Conversations use each tag?
- Did I accidentally create near-duplicates?
- Should `Tax` be renamed to `Taxes`?
- Should `Hawaii` and `Hawaii Trip` be merged or cleaned up?
- Should an unused tag be deleted?

Users should not need to visit the Tag Manager to create their first tags.

The Tag Manager can become more important as tag count grows, but it should not
be the conceptual entry point for the feature. Eventual user-facing wording may
be closer to "Organize Tags" or "Clean Up Tags" than "Manage Tags"; final UI
language should be settled later.

## Existing Tag Selection

Existing tag selection should feel like a lightweight picker, not a filing
dialog.

Recommended behavior:

- show currently assigned tags first;
- offer recent or frequently used tags;
- provide text filtering;
- allow keyboard selection;
- allow create-on-type when there is no good match;
- avoid large modal management UI for ordinary assignment.

The picker should encourage reuse without making users browse a long taxonomy.

## New Tag Creation

New tag creation should be inline from the tag picker.

The user should be able to type:

```text
Hawaii Trip
```

and apply it directly to the current Conversation.

Creation should not require leaving the Conversation context. The system can
show a clear action such as:

```text
Create tag "Hawaii Trip"
```

This preserves the user's flow of recognition.

## Duplicate Prevention

Duplicate prevention should happen at creation time.

Recommended product rule:

- tag names should be unique after simple normalization;
- normalization should at least trim leading/trailing whitespace;
- repeated internal whitespace should not create distinct tags;
- casing differences should not create distinct tags.

Examples:

```text
Family
family
 Family
Family 
```

should resolve to one existing tag.

If the user types a near-match, the UI should prefer showing the existing tag
over creating a duplicate. More advanced fuzzy duplicate detection can wait.

## Renaming

Renaming a tag is a global operation.

Because a Tag is one durable user-intent object applied to many Conversations,
renaming `Hawaii` to `Hawaii Trip` should update every Conversation where the
tag appears.

Renaming belongs primarily in the secondary management workflow. It may also be
reachable from an expanded tag editor, but it should not be confused with
renaming the tag only on one Conversation.

## Removing Versus Deleting

The UI must distinguish:

```text
Remove this tag from this Conversation
```

from:

```text
Delete this tag everywhere
```

Removing an assignment should be lightweight and reversible enough for ordinary
editing.

Deleting a tag should be treated as a global cleanup operation. The UI should
show the number of affected Conversations and require deliberate confirmation.

## Tag Cleanup

As the number of tags grows, cleanup becomes necessary. That does not mean
cleanup should dominate the first experience.

Cleanup should eventually include:

- rename;
- delete;
- show usage count;
- find unused tags;
- possibly merge near-duplicate tags.

Merge is useful but should not be required for the first slice unless duplicate
creation proves hard to prevent.

## Conversation Card Presentation

Tags should appear as quiet secondary meaning attached to the Conversation.

They should not compete with:

- Conversation title;
- favourite star;
- topology glyph;
- message count/date range;
- lens-specific emphasis.

Recommended direction:

- compact cards show no tags or only a very small number of relevant tags;
- expanded cards or excerpt panels can show more tags;
- tag editing affordance may be present but visually secondary;
- tag chips should use restrained styling and avoid strong color semantics in
  the first slice.

The user should perceive Tags as meaning context, not as another dashboard row.

## Relationship To Structured Conversation Retrieval

Structured Conversation Retrieval is the natural future consumer of Tags.

Tags should eventually become remembered-context tokens:

```text
Family
Taxes
Hawaii Trip
Health
```

The first tagging workflow does not need to implement the full retrieval system.
However, it should produce tag state that retrieval can later consume cleanly.

The key product distinction remains:

- Message search asks: "Where was this said?"
- Conversation retrieval asks: "Which Conversation context am I trying to work
  with?"

Tags help answer the second question.

## Authoring And Retrieval Symmetry

Conversation-first tagging and Structured Conversation Retrieval are
complementary operations:

```text
Authoring:
Conversation -> recognized meaning -> Tag

Retrieval:
remembered meaning -> Tag token -> Conversations
```

Tagging records meaning when the user encounters it. Structured Conversation
Retrieval later uses that recorded meaning to recover relevant Conversations.

This symmetry is part of the product rationale, not a new architectural
subsystem.

## Scalability

The design should scale from three tags to dozens of tags without requiring an
upfront taxonomy.

Scalability principles:

- creation remains local to Conversation context;
- reuse is encouraged through search and recent/frequent suggestions;
- cleanup is available but secondary;
- compact cards avoid showing too much tag material;
- retrieval eventually gives tags more value as the collection grows.

## UX Risks

### Risk: Tags Become Folders

If the primary UI is a Tag Manager or tag browser, users may treat Tags as
folders. Keep the primary workflow Conversation-first.

### Risk: Tagging Feels Like Administration

If users must leave the Conversation to create a tag, tagging becomes a chore.
Create and apply tags in place.

### Risk: Duplicate Tags Accumulate

If creation is too permissive, `Family`, `family`, and `Family ` will fragment
retrieval. Normalize names and show existing matches.

### Risk: Tags Overwhelm Conversation Cards

If every card shows many tags, Conversation identity will become visually noisy.
Use compact display rules and reserve full editing for expanded contexts.

### Risk: Deletion Feels Local When It Is Global

Deleting a tag affects all Conversations. Make this semantically and visually
different from removing the tag from one Conversation.

## High-Level Implementation Guidance

This evaluation does not authorize implementation or define schema/provider
details.

At a product level, the future implementation should prefer:

- a Conversation-owned tag affordance;
- an inline tag picker/editor for assignment and creation;
- normalized duplicate prevention;
- quiet tag display on Conversation cards;
- a secondary tag management surface for rename/delete/cleanup;
- no tag colors in the initial slice unless later product review explicitly
  approves them.

Do not build Tags as:

- a folder tree;
- a sidebar mode competing with Favourites/Browse;
- a Search-owned feature;
- a message-owned feature;
- a standalone taxonomy manager that users must configure before tagging.

## First Slice Recommendation

The first implementation slice should prove Conversation-first tagging:

1. Add a tag affordance to canonical Conversation presentation.
2. Show currently assigned tags for the Conversation.
3. Apply an existing tag to the Conversation.
4. Create a new tag inline and immediately apply it.
5. Remove a tag from the current Conversation.
6. Prevent simple duplicate tag names through normalization.
7. Display assigned tags quietly on at least one Conversation-owned surface.

Defer:

- tag color;
- tag descriptions;
- bulk tagging;
- tag merge;
- full Structured Conversation Retrieval;
- message-search tag refinement;
- AI-assisted tag suggestions;
- synchronization;
- import/export.

A minimal secondary management surface for rename/delete may be included if it
is small and clearly secondary, but it should not be the first interaction the
user sees.

## Decision

Conversation Tags should be designed around a **Conversation-first creation and
assignment workflow**, with a **secondary Tag Manager** reserved for cleanup,
rename, deletion, and scale.

This best preserves the intended feeling:

```text
I noticed what this Conversation means.
I named that meaning.
MessageLens can now help me find and rediscover it later.
```
