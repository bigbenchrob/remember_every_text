---
tier: project
scope: design-notes
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: exploratory
links:
  - ./PROPOSAL.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/DESIGN_NOTES.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Structured Conversation Retrieval Design Notes

## Design Premise

Conversation Retrieval should feel like describing a remembered Conversation,
not like searching a database.

The user should be able to build a query from things they recognize:

- people;
- tags;
- favourites;
- working context;
- visibility state;
- conversation structure;
- future confirmed classifications.

Each accepted descriptor becomes a visible token. The growing token set
explains why the Conversation list contains what it contains.

## Product Language

Avoid presenting this as "search conversations" unless the UI makes clear that
the search space is structured Conversation metadata, not message text.

Better mental model:

> Describe the Conversation context.

Possible future user-facing labels may include:

- Find conversations;
- Retrieve conversations;
- Filter conversations;
- Conversation scope;
- Conversation context.

The final label remains open. The design principle is settled: this is
structured retrieval, not message-content search.

## Token Semantics

A token represents a selected known descriptor.

Examples:

```text
[Claire]
[Family]
[Favourite]
[Working Set: Hawaii booking]
[Group conversation]
[Suppressed]
[Has notes]
```

Tokens should be visually distinct from raw typed text. Selecting a typeahead
candidate should convert the candidate into a badge/chip/token and clear the
input for continued typing.

## Candidate Sources

Potential token sources include:

- Contact display identities;
- Conversation participants;
- user-defined Tags;
- built-in Core Favourite state;
- active or saved Working Sets;
- visibility state such as Suppressed;
- Conversation structure such as group or one-to-one;
- annotation presence such as Has Notes;
- future user-confirmed AI classifications.

The retrieval layer should consume these sources through typed read models. It
should not parse display strings or infer intent inside widgets.

## Retrieval Semantics

The default combination model should be explicit before implementation.

Open questions include:

- Do multiple tokens combine as AND by default?
- Should some token groups support OR?
- How are repeated token types handled?
- Can the user negate a token, such as "not suppressed"?
- How should empty results be explained?

The first product slice should likely use a simple AND model:

```text
Claire + Family + Favourite
  -> Conversations involving Claire
  -> tagged Family
  -> marked Favourite
```

More expressive retrieval should wait until the basic model is proven.

## Relationship To Lenses

Conversation Retrieval chooses the set. Conversation Lenses choose the
presentation.

Do not build lens behavior into retrieval tokens.

For example:

- `Dormant` may be a lens.
- `Suppressed` may be a visibility token.
- `Family` may be a Tag token.

A future screen might combine them, but each concept should remain distinct.

## Relationship To Search

All Messages Search and Structured Conversation Retrieval may hand off to each
other, but they should not blur.

Appropriate handoffs:

- message search result -> add source Conversation to Working Set;
- message search result -> open source Conversation;
- message search result -> suggest creating a Tag after explicit user action;
- Conversation retrieval result -> open Conversation evidence.

Inappropriate behavior:

- typing free text into Conversation Retrieval silently searches message bodies;
- Search owns tag/favourite/working-set logic;
- message rows become members of a Conversation Working Set.

## Relationship To Conversation Intent Categories

Conversation Intent categories provide retrieval sources, but retrieval should
not flatten their meanings.

Examples:

- Importance token: Favourite.
- Meaning token: Tag.
- Visibility token: Suppressed.
- Context token: Working Set.
- Annotation token: Has Notes.

Each token type may need different wording, affordances, and persistence
behavior even if they share a retrieval field.

## UX Risks

### Generic Search Confusion

If the field looks like a plain search box, users may expect message-content
search. The UI must signal that suggestions are structured Conversation
descriptors.

### Token Overload

Too many token types may make the typeahead feel noisy. Candidate ranking and
grouping will matter.

### Sidebar Mode Proliferation

The feature exists partly to avoid adding more permanent sidebar modes. Do not
let saved retrievals or token types become fixed navigation areas by default.

### False Permanence

Temporary retrieval tokens should not silently create durable intent. Selecting
`Family` as a token is not the same thing as tagging a Conversation Family.

### Hidden Message Search

Conversation Retrieval must not appear to miss messages. It should explain that
it retrieves Conversations, while All Messages Search retrieves message
evidence.

## Minimal First Slice Direction

When implementation is eventually approved, the smallest useful slice may be:

1. Replace the current low-value Conversation metadata search field with a
   structured retrieval field in Browse mode.
2. Support a small token set:
   - Contact identity;
   - Core Favourite;
   - group / one-to-one;
   - maybe Tag only if Tags already exist.
3. Combine tokens with a simple AND model.
4. Keep the existing Conversation Lens / Organize by control separate.
5. Show empty-state copy that explains selected tokens.

This slice should wait until Conversation Intent and Tags planning are resolved.

## Open Questions

- What should the user-facing label be?
- Should first-slice retrieval replace or sit beside the current Conversation
  search field?
- Which token types are available before Tags exist?
- How should typeahead candidates be ranked?
- Should tokens be keyboard-first?
- Should retrieval state persist across app relaunch?
- Should retrieval state belong to sidebar flow state or overlay only when
  saved?
- How should suppressed Conversations be included explicitly?
