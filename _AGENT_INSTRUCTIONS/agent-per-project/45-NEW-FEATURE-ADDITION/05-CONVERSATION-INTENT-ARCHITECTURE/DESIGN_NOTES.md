---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: doc
status: approved-architecture
links:
  - ./PROPOSAL.md
  - ../04-CONVERSATION-TAGS/DESIGN_NOTES.md
  - ./01-OPEN-QUESTION-EVALUATION/05-categories-of-conversation-intent.md
  - ../../10-DATABASES/07-overlay-database-independence.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
---

# Conversation Intent Design Notes

## Core Insight

MessageLens should not create a new container model every time the user wants
to curate Conversations.

The same canonical Conversation can be:

- favourited;
- tagged;
- suppressed from ordinary browsing;
- added to a Working Set;
- annotated with a note;
- classified by a user-confirmed AI suggestion.

Those are not competing Conversation identities. They are intent attached to
one Conversation.

## Ownership Model

### Overlay / User-Intent Storage Owns Persistence

Conversation Intent is authored or confirmed by the user. It must persist
outside graph projection.

Overlay storage should own:

- durable intent records;
- user-authored labels or notes;
- user-confirmed classifications;
- assignments from intent objects to Conversation identity;
- visibility state such as Suppressed.

### Conversations Owns User-Facing Intent Workflows

`features/conversations` should own:

- presenting intent on Conversation Cards;
- editing Conversation intent;
- applying/removing intent from a Conversation;
- tag-aware or intent-aware Conversation lenses;
- user-facing wording for Conversation-level curation.

### Graph Owns Conversation Facts

`essentials/conversation_graph` should own:

- source-scoped Conversation identity;
- topology;
- message membership;
- signature/read primitives;
- graph-derived facts.

It should not own user intent, even if it supplies the stable identity to which
intent attaches.

### Search, Messages, Contacts, Discovery Consume Intent

Other features may consume Conversation Intent:

- Search may refine by intent.
- Messages may expose "add source Conversation to intent" affordances.
- Contacts may show intent state on Contact-derived Conversation lists.
- Discovery may use intent as a lens or scope.

They should not own the intent model.

## Retrieval Implications

The old question:

> Which sidebar mode should contain this Conversation?

The better question:

> Which Conversations match the selected people, tags, favourites, working
> sets, visibility state, or other user intent?

This supports a future structured Conversation retrieval box.

Possible retrieval tokens:

- contact identity badges;
- tag badges;
- favourite badges;
- working-set badges;
- visibility badges;
- note-presence badges;
- confirmed classification badges.

This is not message-content search.

Message-content search answers:

> Where was this said?

Conversation retrieval answers:

> Which Conversation context am I trying to work with?

## Relationship To Existing Concepts

### Favourites

Favourites are a high-signal intent: "this Conversation matters enough to keep
nearby."

They are built-in Importance intent. They should share Conversation Intent
identity and ownership principles while remaining user-facing as Favourites.

The user should not create, rename, or delete the Favourite intent type. The
star affordance and privileged access role remain appropriate. Existing
favourite records do not need preservation during first implementation if a
cleaner Intent model is easier.

### Tags

Tags are durable Meaning intent.

Tags should use the broader intent seam rather than creating a separate
tag-only architectural island.

### Working Sets

Working Sets are Context intent.

They answer:

> Which Conversations am I working with right now?

They are task context, not semantic meaning. A Working Set contains canonical
Conversation identities. It begins as temporary session intent and becomes
durable only through explicit user action such as naming and saving.

A Tag says why Conversations belong together. A Working Set says why the user
is using them together right now.

### Conversation Lenses

Lenses organize and emphasize Conversations. Intent can scope lenses.

Examples:

- Dormant + Family tag.
- Most recently updated + Core Favourite.
- Date of creation + Health classification.

Lenses should consume intent but not own it.

### Search Refinement

Search can use intent as a scope:

- search messages inside Family-tagged Conversations;
- search messages in Core Favourites;
- search messages in a Working Set.

Search should remain the message-content retrieval surface. It should not become
the owner of Conversation Intent.

### Discovery

Discovery can use intent to surface meaningful history:

- forgotten Family conversations;
- dormant Work conversations;
- old conversations with Notes;
- seasonal conversations tagged Vacation.

Intent makes Discovery personal because it incorporates the user's meaning.

### Suppressed Conversations

Suppressed state is Visibility intent.

It means "exclude from ordinary browsing and discovery." It does not mean
delete, archive, remove from Search, remove from evidence, or pretend the
Conversation does not exist.

Important distinction:

- graph says the Conversation exists;
- intent says whether ordinary browse/discovery views should show it by
  default.

Visibility policy influences default presentation, not existence.

### Notes

Conversation Notes are durable Annotation intent.

They answer:

> What do I want to remember about this Conversation?

The first implementation should support one editable note per Conversation.
Notes belong to Conversations, not individual messages. Message annotations may
be designed later as a separate concept.

AI may suggest summaries, but an AI summary becomes a Conversation Note only
when the user explicitly adopts or edits it as their own note.

### Saved Investigations

Saved Investigations are outside the current Conversation Intent scope. They
are likely a higher-order workspace architecture that may combine search
queries, selected messages, selected Conversations, retrieval tokens, notes,
and navigation context.

### AI-Assisted Suggestions

AI may suggest intent but must not silently create durable intent.

Safe model:

```text
AI suggestion -> user review -> user confirmation -> Conversation Intent
```

Confirmed AI classifications become user-confirmed intent. Unconfirmed
suggestions remain suggestions.

## UX Implications

### Do Not Make Intent Feel Like Folders

The UI should avoid implying that a Conversation "lives in" one place.

Better language:

- tagged with Family;
- included in Working Set;
- suppressed from ordinary Browse;
- marked Favourite.

Avoid:

- move to Family;
- put in folder;
- remove from all other places.

### Keep Concepts Distinct In The UI

Shared architecture does not require shared UI.

Favourites, Tags, Working Sets, Suppressed state, and Notes may each need
different affordances because they mean different things to users.

The architecture should unify identity and persistence. The product should
preserve distinct meanings.

### Suppression Is Not Deletion

Prefer language such as:

- suppress from browsing;
- suppressed;
- include suppressed Conversations.

Avoid implying that the Conversation disappears from the archive. Search,
direct retrieval, message evidence, attachment evidence, and graph existence
remain intact.

### Structured Retrieval Should Feel Token-Based

Future Conversation retrieval should feel like selecting meaning-bearing tokens:

```text
Person: Claire
Tag: Family
Favourite
Visibility: Not suppressed
```

This supports retrieval without turning every intent type into a separate
sidebar mode.

## Storage And Overlay Considerations

Conversation Intent should support:

- stable Conversation identity references;
- multiple intent types;
- user-authored names and values;
- lifecycle state;
- eventual export/import;
- eventual sync;
- clear distinction between durable and session-scoped intent.

Do not choose table names or schema here.

Architectural requirements:

- graph rebuilds must not erase intent;
- projection must not consult intent;
- read models may merge intent;
- overlay wins over derived defaults where conflict is meaningful.

## Intent Categories And Lifetimes

### Categories

Conversation Intent categories are:

1. **Meaning**
   - Tags;
   - user-confirmed AI classifications.

2. **Importance**
   - Core Favourites.

3. **Visibility**
   - Suppressed Conversations.

4. **Context**
   - Working Sets.

5. **Annotation**
   - Conversation Notes.

Shared architecture does not imply shared semantics or shared user experience.

### Lifetimes

1. **Durable intent**
   - Core Favourites;
   - Tags;
   - Suppressed state;
   - Conversation Notes;
   - confirmed AI classifications;
   - saved Working Sets.

2. **Session-scoped intent/state**
   - current filters;
   - selected retrieval tokens;
   - temporary selections;
   - unconfirmed AI suggestions;
   - unsaved Working Sets.

3. **Persistable working intent**
   - Working Sets that begin temporary and become durable only through explicit
     user action.

Temporary state must never silently become durable. Durable intent must never
be lost merely because it began during exploration.

## Anti-Patterns

Avoid:

- storing intent in graph projection tables;
- making sidebar mode state the source of truth for intent;
- creating a separate persistence model for each intent concept;
- letting widgets directly persist intent;
- treating tags as folders;
- treating Working Sets as permanent tags by accident;
- allowing AI to create durable user intent silently;
- using display names or row positions as intent keys;
- hiding Conversations by deleting graph facts.

## Remaining Design Questions

- What minimal shared primitives should exist before implementing Tags?
- How much intent should appear on compact Conversation Cards?
- How should intent export/import preserve Conversation references safely?
