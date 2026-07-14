---
tier: project
scope: post-implementation-review
owner: agent-per-project
last_reviewed: 2026-07-12
source_of_truth: review
status: reviewed
links:
  - ./README.md
  - ./PROPOSAL.md
  - ./DESIGN_NOTES.md
  - ./IMPLEMENTATION_READINESS_AUDIT.md
  - ./FIRST_SLICE_IMPLEMENTATION_PLAN.md
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ../../10-DATABASES/07-overlay-database-independence.md
tests:
  - flutter analyze
  - flutter test test/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository_test.dart test/features/conversations/application/conversation_tags/conversation_tag_actions_provider_test.dart test/features/conversations/application/conversation_signatures/conversation_signature_display_provider_test.dart test/features/conversations/presentation/widgets/conversation_signature_card_test.dart test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart
---

# Conversation Tags Post-Implementation Architectural Review

## Summary

The first Conversation Tags vertical slice successfully validates the approved
Conversation Intent architecture.

The implementation proves the intended flow:

```text
canonical Conversation identity
  -> overlay-persisted user Meaning intent
  -> Conversation-owned action/read boundary
  -> read-time merge with graph facts
  -> pure Conversation Card presentation
```

No architectural contradiction was discovered. No code changes are recommended
before the next slice.

## Strengths

### Overlay Persistence Is Correctly Owned

Observation:
Conversation tag definitions and Conversation/tag assignments live in the
overlay database, with schema migration from version 6 to 7.

Why it matters:
Tags are user-authored Meaning intent. Persisting them in overlay storage
preserves the rule that user intent survives graph rebuilds and is not derived
from source data.

Severity:
Low risk / validated.

Suggested direction:
Continue using overlay storage for durable Conversation Intent. Later intent
types should follow the same source-of-truth separation unless their lifetime is
explicitly session-scoped.

### Graph Projection Remains Untouched

Observation:
The graph continues to provide canonical `conversationId` and Conversation
facts. Tag state is not read, written, or derived by graph projection.

Why it matters:
This preserves deterministic graph projection and prevents user-authored
meaning from becoming rebuild-sensitive.

Severity:
Low risk / validated.

Suggested direction:
Keep future retrieval and display slices as read-time consumers of tag state.
Do not move tag semantics into `essentials/conversation_graph`.

### `features/conversations` Owns Tag Semantics

Observation:
The tag domain type, repository boundary, read providers, action provider, UI
affordance, and card display integration live under `features/conversations`
except for physical overlay schema ownership in `essentials/db`.

Why it matters:
Tags are Conversation Intent, not Search state, Message evidence state, Contact
state, or graph state. The implementation reinforces the repaired Conversation
feature boundary.

Severity:
Low risk / validated.

Suggested direction:
Future tag surfaces should consume the Conversation-owned providers/actions
instead of creating local tag models.

### Read Models Merge Graph Facts And Intent

Observation:
`ConversationSignatureDisplayModel` now carries tag display data. The merge
happens in the Conversation signature display provider after graph signatures
and display identity are resolved.

Why it matters:
This is the correct place for graph facts plus user intent to become
display-ready Conversation data. Widgets receive resolved data instead of
querying storage.

Severity:
Low risk / validated.

Suggested direction:
Use this same pattern for additional Conversation surfaces. If later surfaces
need tag-aware filtering or retrieval, add that above the read model rather than
inside presentation widgets.

### `ConversationSignatureCard` Remains Pure

Observation:
The card accepts `ConversationSignatureCardData`, style, callbacks, and slots.
It renders supplied tag labels but does not watch providers, query storage, or
perform mutations.

Why it matters:
This preserves the canonical Conversation Card as reusable presentation. It can
appear in Favourites, Browse, Contact-derived lists, right-side excerpts, and
future retrieval surfaces without inheriting persistence policy.

Severity:
Low risk / validated.

Suggested direction:
Keep tag action widgets outside the pure card. Pass tag labels as data and tag
controls as slots or surrounding Conversation-owned action widgets.

## Architectural Validation

The implementation faithfully follows the approved Conversation Intent model:

- Tags are durable Meaning intent.
- Tags attach to canonical `conversationId`.
- Overlay owns persistence.
- Graph projection does not own tag state.
- `features/conversations` owns tag semantics and workflow.
- Read models merge overlay intent with graph facts.
- The canonical card remains provider-free and behavior-light.

The architecture did not need adjustment. The first slice demonstrates that a
specific intent type can be added without inventing a new sidebar mode, a new
Conversation container, or a special Search-owned concept.

## Implementation Observations

### Vertical Slice Discipline

Observation:
The slice remained narrow. It implements create/apply/remove in the
Conversations sidebar only, while deferring Structured Conversation Retrieval,
Tag Manager, colors, descriptions, import/export, sync, and broad cross-surface
display.

Why it matters:
The architecture is validated without prematurely building the complete tag
ecosystem.

Severity:
Low risk / validated.

Suggested direction:
Keep the second slice similarly explicit. Do not expand from "show tags in
another Conversation surface" into retrieval or management unless that is the
approved slice.

### Provider Invalidation Is Correct But Coarse

Observation:
`ConversationTagActions` mutates overlay through the repository and invalidates
tag reads plus Conversation signature display providers.

Why it matters:
The invalidation is owned by a named action boundary, which is correct. It is
also intentionally broad for a first slice.

Severity:
Low.

Suggested direction:
Do not refactor before the second slice. If tag usage becomes frequent or
larger lists make refresh behavior visible, consider a more targeted refresh
strategy inside the same action/read-model boundary.

### The Tag Editor Is A Conversation-Owned Action Surface, Not A Pure Widget

Observation:
`ConversationTagButton` and its editor watch tag providers and call the
Conversation tag action provider. The pure card itself does not.

Why it matters:
This is acceptable because the editor is the user workflow surface, analogous
to the existing favourite action, while the reusable card remains pure.

Severity:
Low.

Suggested direction:
Keep this distinction explicit. Future action surfaces may be Consumer widgets;
canonical presentation components should remain provider-free.

### Invalid Conversation Or Tag IDs Are Ignored In Assignment

Observation:
The repository returns early when assigning with non-positive IDs.

Why it matters:
This avoids persisting invalid rows from accidental UI calls, but it also hides
programmer misuse.

Severity:
Low.

Suggested direction:
No immediate change required. Before broader APIs or import/export exist,
decide whether invalid IDs should remain ignored, throw a typed error, or be
asserted in debug builds.

### Cross-Surface Tag Display Is Deliberately Opt-In

Observation:
The display model carries tags, but card data only includes tag labels when the
caller passes `includeTags: true`. The first surface opts in; other surfaces do
not yet.

Why it matters:
This preserves first-slice discipline while leaving a small policy seam for
later UI review.

Severity:
Low.

Suggested direction:
The next display slice should explicitly decide which Conversation Card
surfaces should opt in and whether any compact surfaces need a different tag
presentation.

## Deviations From Approved Plan

No material deviations were found.

The only notable interpretation is that broad cross-surface tag visibility was
deferred by making tag labels opt-in at the card-data adapter layer. This is
consistent with the approved first-slice scope, which excluded Contacts and
right-panel integration.

## Product Semantics

The implementation preserves the intended distinctions:

- **Favourites** remain Importance intent and use the star affordance.
- **Tags** are durable Meaning intent and use a separate tag affordance.
- **Working Sets** remain future task/context intent and were not implemented.
- **Suppressed** remains future visibility intent and was not blurred into tags.
- **Notes** remain future annotation intent and were not implemented.

The UI does not present Tags as folders or containers. Creating a tag from a
Conversation context reinforces "recognized meaning" rather than "file this row
away."

## UI Evaluation

The first user experience is consistent with the approved philosophy:

- tagging starts from a Conversation, not from an administrative taxonomy;
- the affordance sits near Favourite without replacing it;
- tag chips are visually quieter than title, glyph, and summary metadata;
- applied tags read as semantic context rather than list ownership.

This validates the principle:

> Tags should be discovered through use, not through administration.

No redesign is recommended before the next slice.

## Future Readiness

The implementation is a solid foundation for:

- showing tags on additional canonical Conversation Card surfaces;
- using tags as Structured Conversation Retrieval tokens;
- introducing a later tag cleanup/management surface;
- adding colors or descriptions if approved;
- bulk tagging from future Working Sets;
- future import/export or sync review.

The key future constraint is to keep the same ownership chain:

```text
Conversation Intent storage
  -> Conversation-owned read/action model
  -> graph + overlay display composition
  -> pure Conversation presentation
  -> consuming lenses
```

Search, Contacts, Messages, and Discovery may consume tags, but should not
define tag semantics.

## Technical Debt Introduced By This Slice

### Implementation Debt

- Assignment invalid-ID handling is conservative but silent.
- Provider invalidation is coarse.
- Tag display is opt-in per adapter call, so future surfaces require deliberate
  review to avoid accidental inconsistency.

### Architectural Debt

No significant architectural debt was introduced.

The implementation follows the intended seam and does not reveal a weakness in
the Conversation Intent architecture.

### Future Enhancements

These are not defects:

- tag rename/delete;
- tag cleanup/management surface;
- tag colors/descriptions;
- cross-surface display;
- Structured Conversation Retrieval token integration;
- bulk tagging;
- import/export/sync;
- AI-suggested tags.

## Lessons Learned

1. The Conversation Intent seam is practical, not merely conceptual.
   Tags were added without changing graph projection or creating a local
   sidebar-only state model.

2. First-class overlay tables are appropriate for intent types with vocabulary
   plus assignments.
   A single settings blob would have been too small for Tags.

3. The repaired `features/conversations` boundary is paying off.
   A Conversation-owned feature can now absorb new Conversation semantics
   without pushing responsibility into Messages or Search.

4. Read-time merging is the right pattern.
   It keeps graph facts deterministic and user meaning durable.

## Recommendations Before The Second Slice

1. Do not refactor the first slice before using it.
   The architecture is validated and should be tested manually in the running
   app first.

2. Choose the second slice explicitly.
   Good candidates are:
   - show existing tags on Contact-derived Conversation cards;
   - show existing tags on the right Conversation excerpt card;
   - add a minimal tag cleanup surface;
   - begin Structured Conversation Retrieval tag-token planning.

3. Keep retrieval separate from message search.
   Tag-based retrieval should answer "Which Conversation context am I trying to
   work with?", not "Where was this word said?"

4. Preserve UI quietness.
   Tags should remain semantic context until a future lens makes them the
   primary comparison value.

5. Leave unrelated architecture test failures out of tag work.
   The current full architecture test failure for
   `vertical_column_bands.dart` is unrelated to Conversation Tags.
