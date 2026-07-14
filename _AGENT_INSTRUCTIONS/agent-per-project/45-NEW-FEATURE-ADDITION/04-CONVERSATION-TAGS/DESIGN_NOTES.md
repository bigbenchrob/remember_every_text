---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: consolidated-exploratory
links:
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ./PROPOSAL.md
  - ../../10-DATABASES/07-overlay-database-independence.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
---

# Conversation Tags Design Notes

## Design Premise

Tags are a semantic overlay on Conversation identity.

They answer:

> What does this Conversation mean to the user?

They do not answer:

> Where does this Conversation live?

That distinction keeps tags from becoming folders and keeps MessageLens aligned
with its memory exploration model.

In the broader architecture, Tags are durable **Meaning** intent. Conversation
Intent owns the shared seam for user-authored or user-confirmed Conversation
meaning. This document remains focused on the tag-specific expression of that
model.

## Inherited Architecture

Tags inherit these constraints from Conversation Intent:

- Tags attach to canonical Conversation identity.
- Tags are overlay/user intent.
- Tags survive graph rebuilds.
- Graph projection does not read or write tag state.
- Read models merge graph facts with tag overlay state at read time.
- Search, Messages, Contacts, and Discovery may consume tag state but do not
  own tag semantics.

Those rules are owned by
[`../05-CONVERSATION-INTENT-ARCHITECTURE/`](../05-CONVERSATION-INTENT-ARCHITECTURE/).
This package should not duplicate them beyond this summary.

## Feature Ownership

`features/conversations` should own:

- user-facing tag workflows;
- Conversation Card tag affordances;
- tag-aware Conversation lenses;
- tag management surfaces if they are Conversation-centric;
- wording and presentation of tags as Conversation meaning.

Overlay/database infrastructure should own persistence mechanics.

Search, Contacts, and Messages may consume tag state, but should not define
the tag model.

Structured Conversation Retrieval may eventually consume tags as retrieval
tokens. That retrieval grammar is owned by
[`../06-STRUCTURED-CONVERSATION-RETRIEVAL/`](../06-STRUCTURED-CONVERSATION-RETRIEVAL/),
not by this package.

## UX Considerations

### Editing Workflow

Possible entry points:

- from a Conversation Card action;
- from a Conversation detail/header surface;
- from a tag management view;
- from a Search result's "In conversation" context;
- from a future bulk-selection or Working Set flow.

First-slice editing should be local, visible, and reversible. The user should
never wonder whether they tagged the card, the list row, or the underlying
Conversation.

### Creation Workflow

Tag creation should feel lightweight:

- type a new tag name;
- confirm creation;
- apply it to the current Conversation.

The system should avoid accidental duplicate tags caused by capitalization or
minor whitespace differences. The exact normalization rules should be decided
in implementation planning.

### Deletion

Deleting a tag is different from removing a tag from a Conversation.

The UI must distinguish:

- remove `Family` from this Conversation;
- delete the `Family` tag entirely.

Deletion should be difficult enough to avoid accidental global loss, but not so
heavy that tag cleanup becomes unpleasant.

### Renaming

Renaming a tag should update it everywhere because the tag is a single user
intent object, not copied text on each Conversation.

This mirrors the One Conversation principle:

> There is only one Tag named by the user, applied in many places.

### Color

Color is optional and should be treated carefully.

Risks:

- tag colors could compete with Conversation glyph colors;
- colors could imply category semantics the app does not own;
- too many colors could make the sidebar feel like a dashboard.

Possible first-release direction:

- no user color at first;
- subdued tag chips using existing theme tokens;
- preserve color for later once tag density and usage are understood.

### Ordering

Ordering can mean several things:

- order tags appear on a Conversation;
- order tags appear in a tag picker;
- order tagged Conversation lenses appear;
- user-prioritized/frequent tags.

Do not overdesign initial ordering. Reasonable first behavior:

- tag picker ordered by recent use or name;
- tags on a Conversation ordered by explicit user order if available,
  otherwise name.

### Presentation

Tags should be visible enough to communicate meaning but quiet enough not to
compete with Conversation identity.

Potential presentation rules:

- Conversation title remains primary.
- Conversation glyph remains topology/history signature.
- Tags are secondary semantic context.
- Show only a limited number of tags on compact cards.
- Use a disclosure, popover, or detail surface for full tag editing.

### Scalability

The design should handle:

- hundreds of Conversations;
- dozens of tags;
- Conversations with many tags;
- tags applied to many Conversations;
- future filters combining tag + lens.

Avoid UI patterns that assume only a handful of tags.

## Relationship To Retrieval And Discovery

Tags should support both:

- direct retrieval: "Find conversations tagged Work";
- rediscovery: "Show dormant Family conversations";
- retrieval refinement: "Show Conversations tagged Health";
- message-search refinement: "Search message text only inside Health
  conversations";
- interpretation: "This old conversation matters because I tagged it Taxes."

Tags become a bridge between user memory and graph evidence. They are especially
valuable when the user remembers meaning rather than participants or exact
phrasing.

## Future Synchronization

Synchronization is out of scope for the first design, but the model should not
block it.

Future sync may require:

- stable tag identifiers;
- conflict handling for rename/delete;
- assignment timestamps;
- source device metadata;
- import/export representation.

Do not implement sync-specific complexity in the first slice unless needed to
avoid data loss.

## Future Import/Export

Tags are user-authored data. They should eventually be exportable.

Export should preserve:

- tag definitions;
- Conversation identity references;
- assignments;
- enough identity/provenance to detect whether assignments still resolve after
  rebuilds.

Import should avoid creating duplicate tags accidentally.

## Future AI-Assisted Exploration

AI assistance may eventually suggest tags or group Conversations.

That must remain separate from user-authored truth:

- AI can suggest.
- User confirms.
- Confirmed tags become overlay intent.

Do not let generated tags silently become durable user intent.

## Anti-Patterns

Avoid:

- storing tags in graph projection tables;
- deriving tags from message content without user confirmation;
- attaching tags to card instances rather than Conversation identity;
- treating tags as mutually exclusive folders;
- letting Search own tag semantics;
- making tag color the primary meaning carrier;
- using tags to patch weak Conversation identity or display-name resolution.

## Open Design Questions

These are tag-specific product questions, not general Conversation Intent
questions:

- Should tag names be globally unique case-insensitively?
- Should tags support descriptions?
- Should tags support user color eventually?
- Should tag application be shown on every Conversation Card or only expanded
  surfaces?
- Should tags appear in message evidence headers when a Conversation is in
  scope?
- Should there be a dedicated tag management surface in the first slice?
- Should tag retrieval first appear in the Conversation sidebar, Structured
  Conversation Retrieval, or both?
- Should deleted tags disappear completely, or leave a user-visible recovery
  affordance?
