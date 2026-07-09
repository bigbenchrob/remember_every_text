---
tier: project
scope: architectural-walkthrough
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: audit
status: current
links:
  - ./DEVELOPER_GUIDE.md
  - ./00-START-HERE.md
  - ./01-PROJECT/05-CURRENT-STATE.md
  - ./40-FEATURES/conversations/README.md
  - ./95-WALK-UI-TREE/README.md
  - ./95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ./00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/00-READ-FIRST.md
---

# Conversations Architectural Walkthrough

Date: 2026-07-09

This walkthrough evaluates Conversations as a user-facing product surface and
as an architectural boundary. It is not a code review and not an implementation
plan. The question is whether the current Conversations experience supports
MessageLens' product goal: ship a memory exploration and rediscovery app while
preserving long-term architectural integrity.

## Method

The walkthrough followed the user journey:

1. Enter Messages -> Conversations.
2. Switch between Favourites and Browse.
3. Organize, filter, and select conversations.
4. Open conversation message evidence in the center panel.
5. Search within a conversation.
6. Open a search result in its original conversation excerpt.
7. Toggle Conversation Favourites from different lenses.
8. Return to previous contexts and compare whether the same Conversation remains
   recognizable across surfaces.

The review compared that journey against the Developer Guide, current-state
documentation, the Architectural Constitution, the UI Walk standards, and the
current code ownership boundaries.

## Overall Assessment

The Conversations feature is now largely aligned with the intended architecture.
It has crossed the important threshold from "conversation-shaped UI inside the
Messages feature" to a first-class `features/conversations` boundary.

The strongest architectural result is that Search can request a Conversation
excerpt without owning the Conversation panel:

```text
Search / Message evidence result
-> Conversation excerpt navigation action
-> ViewSpec.conversations(...)
-> Conversations feature coordinator
-> Conversation excerpt panel
-> shared Message Evidence Spine for rows
```

That flow reinforces the core rule:

> Search requests a Conversation excerpt. Conversations renders the Conversation
> lens. Messages renders the message evidence rows inside that lens.

The remaining concerns are not broad architectural failures. They are a small
set of release-relevant seams where vocabulary, search expectations, favourite
ownership, and evolving layout grammar could drift if left undocumented or
unreviewed.

## Strengths

### Observation: Conversations now has a first-class feature boundary

`features/conversations` is the canonical home for user-facing Conversation
behavior: Conversation cards, glyphs, display read models, navigation actions,
ViewSpecs, sidebar cassette rendering, and excerpt panels.

Why it matters:

The product treats Conversation as a canonical graph entity. The code now has a
matching feature boundary instead of scattering the concept across Messages,
Chats, and graph infrastructure.

Severity: Low

Suggested direction:

Preserve this boundary. New user-facing Conversation behavior should start in
`features/conversations`, while graph facts remain in
`essentials/conversation_graph` and message rows remain in `features/messages`.

### Observation: The canonical Conversation Card is reusable and mostly pure

`ConversationSignatureCard` takes typed card data, style, callbacks, a month
color resolver, selection state, and an optional trailing slot. It does not
watch providers, query data, construct ViewSpecs, or know about sidebar modes.

Why it matters:

This strongly supports the "There is only one Conversation" principle. The same
Conversation can be rendered in Browse, Favourites, Contact-derived lists, and
the right-side excerpt panel without creating local visual copies.

Severity: Low

Suggested direction:

Keep the card pure. Continue supplying Favourites, selection, navigation, and
context-specific actions from the surrounding feature/lens.

### Observation: Conversation excerpt ownership is now correctly routed

The "In conversation" flow no longer renders a Search-owned context sidebar.
Search/message evidence requests a Conversation excerpt through a Conversations
action, which opens `ViewSpec.conversations(ConversationsSpec.conversationExcerpt(...))`.
The Conversations ViewSpec coordinator renders the panel.

Why it matters:

This matches the panel architecture: the PanelCoordinator routes a ViewSpec to
the feature that owns the surface. Search finds messages; Conversations owns
the Conversation lens; Messages owns row evidence.

Severity: Low

Suggested direction:

Preserve this dispatch shape as the standard for future cross-lens navigation.
Other features should request Conversation surfaces rather than locally
assembling Conversation UI.

### Observation: Message evidence rendering is delegated to the shared spine

Conversation center-panel messages and right-side Conversation excerpts both
use Message Evidence Spine concepts and shared evidence timeline rendering.
Conversation-specific code defines the scope and header context, but does not
create a separate message renderer.

Why it matters:

This preserves the hard rule that source-specific scopes are allowed but
source-specific evidence presentation is not. It keeps attachment, search,
highlight, and row presentation improvements centralized.

Severity: Low

Suggested direction:

Do not add Conversation-only message rows, attachment renderers, or local search
match renderers. Any message display issue should be fixed in the evidence
spine unless it is genuinely a Conversation header or scope-composition issue.

### Observation: Favourites/Browse split improves the Conversation mental model

Favourites and Browse are separate sidebar modes rather than one long list with
Favourites embedded above controls. This gives Favourites the meaning of global
user intent and Browse the meaning of exploration.

Why it matters:

The old stacked approach scaled poorly and made Favourites feel like local list
ordering. The split better supports Favourites as a user overlay on the
Conversation entity itself.

Severity: Low

Suggested direction:

Keep Favourites separate from Browse. Future Working Set or Discovery modes
should be evaluated as lenses/modes, not inserted as ad hoc blocks above the
main list.

### Observation: Conversation lenses are becoming a durable discovery grammar

The Browse mode's filter/sort/read model supports different ways of organizing
the same Conversation collection. Sort-driven emphasis highlights the value
that explains the row's position.

Why it matters:

This matches MessageLens' rediscovery purpose. Conversations are not just
records to retrieve; they are relationships and histories that can be surfaced
through different lenses.

Severity: Low

Suggested direction:

Continue treating these as Conversation Lenses internally, even if the UI
eventually uses friendlier language such as "Organize by". New lenses should
provide typed display data that explains why each row appears where it does.

## Opportunities

### Observation: Conversations metadata search still risks overpromising

The "Find conversations" field searches visible/sidebar metadata: title,
participant labels/handles, and latest message preview. It does not search full
message history.

Why it matters:

Users may reasonably expect a conversation search field to search what was said
inside conversations. That conflicts with the established model where All
Messages is the evidence search surface and Conversations is the Conversation
browser/discovery surface.

Severity: Medium

Suggested direction:

Treat the field as a candidate for removal or relabeling during the UI Walk.
If retained for release, clarify its scope. Do not add full message-body search
to the Conversations sidebar unless that becomes a deliberate product decision.

### Observation: The right-side Conversation excerpt panel is conceptually sound
but layout grammar remains in flux

The panel now reads as Conversation -> Conversation Card -> excerpt description
-> messages. However, the surrounding X-column layout system is still actively
being refined.

Why it matters:

The excerpt panel is an important teaching surface: it shows that a message
found through Search belongs to an original Conversation. If the layout feels
like an unrelated sidebar, the "same Conversation through another lens" concept
weakens.

Severity: Medium

Suggested direction:

Continue the UI Walk layout work, but keep it product-focused. The durable
principle is not a particular band implementation; it is that Search, Messages,
and Conversation should read as coordinated peer workspaces.

### Observation: Contact-derived Conversation lists now use Conversation
presentation, but Contacts still controls the surrounding context

Contact By Conversation uses Conversation cards for each Conversation involving
the selected contact. The contact surface still owns contact selection, handle
filters, and the contact-specific sidebar context.

Why it matters:

This is the right split. Contacts answers "whose relationships am I exploring?"
Conversations answers "which Conversation entity is this?"

Severity: Low

Suggested direction:

Preserve this composition. Do not move contact identity editing or contact
scope selection into Conversations; do not let Contacts define local
Conversation card variants.

## Potential Architectural Drift

### Observation: Favourite overlay state is still exported from
`essentials/conversation_graph`

`ConversationFavouriteButton` lives in `features/conversations`, but it consumes
`conversationFavouritesControllerProvider` and
`conversationFavouriteActionsProvider` from the conversation graph essential
barrel.

Why it matters:

Favourites are user intent overlays on a Conversation entity, not graph facts.
Keeping favourite controllers under `conversation_graph` risks blurring graph
projection authority with overlay/user-intent authority, even if the current
implementation behaves correctly.

Severity: Medium

Suggested direction:

Do not block release on this if behavior is correct. Before adding tags or more
Conversation overlays, decide whether the favourite controller should move to
`features/conversations/application`, a neutral overlay-intent module, or be
explicitly documented as an overlay-facing service exported through graph only
for transitional reasons.

### Observation: Conversation lens rules are split between display read models
and widget helpers

Filtering and sorting are in the Conversation signature display provider, while
some visual emphasis decisions for sort modes are in the sidebar widget helper
functions.

Why it matters:

This is acceptable now, but future lenses could accumulate semantic decisions in
widgets. The Constitution expects widgets to render typed display data rather
than decide graph or lens semantics.

Severity: Low

Suggested direction:

When adding the next non-trivial lens, consider promoting "comparison value",
summary highlight, and glyph marker decisions into the typed Conversation
display/read model. Do not refactor solely for cleanliness before release.

### Observation: Favourites are currently Core-only while the model is expected
to grow

The UI uses Favourites/Core today. Future user-defined tags, Working Sets, and
Discovery collections are conceptually adjacent but not yet implemented.

Why it matters:

If future collections are implemented as sidebar-local lists, the "one
Conversation" and global overlay principles could erode.

Severity: Low

Suggested direction:

Keep Core Favourites simple for release. For future tags or Working Sets,
define them as user-intent overlays or temporary lens collections keyed by
stable Conversation identity, not by list position, title text, or local sidebar
state.

### Observation: `ConversationExcerptEvidenceScope` remains in Messages

Conversation excerpt panels construct a `ConversationExcerptEvidenceScope` from
the Messages domain and pass it into the shared timeline.

Why it matters:

This is not currently a violation: Messages owns message evidence scopes and
hydration. The risk is only if Conversations starts depending on Messages for
Conversation identity or panel structure.

Severity: Low

Suggested direction:

Keep this seam explicit: Conversations may request a bounded message evidence
scope for a Conversation excerpt, but Messages remains responsible only for
evidence skeleton/hydration/rendering, not Conversation presentation.

## Potential UX Drift

### Observation: "Find conversations" may conflict with Search All Messages

The current field can make users think there are two message search systems:
one in Conversations and one in All Messages.

Why it matters:

MessageLens depends on clear distinction between retrieval and discovery.
Ambiguous search controls weaken that distinction.

Severity: Medium

Suggested direction:

Resolve this during the Conversations UI Walk before expanding search-like
controls. The strongest current direction is to remove it or make its metadata
scope unmistakable.

### Observation: Conversation selection persistence supports continuity but can
also hide context switches

Switching sidebar modes generally preserves the selected Conversation rather
than clearing the center panel unnecessarily.

Why it matters:

This is good for continuity, but the UI must make it obvious whether the user
is viewing a Conversation selected from Browse, Favourites, Contact, or Search
context.

Severity: Low

Suggested direction:

Continue using clear headers, selected Conversation cards, and the right-side
Conversation excerpt title/card pairing to show context. Avoid imperative
clearing as a fix for confusion; fix derivation and presentation instead.

### Observation: Conversation glyphs are effective but sensitive to density

The monthly glyphs help Conversations feel recognizable, but they can crowd
small spaces such as right-side excerpt headers if not rendered compactly.

Why it matters:

The glyph is a topological signature, not decorative metadata. If it overflows
or dominates, it weakens rather than strengthens recognition.

Severity: Low

Suggested direction:

Keep using compact card styles in constrained panels. Do not create separate
Conversation visuals per lens; tune style variants around the same canonical
card model.

## Future Scalability Concerns

### Observation: New Conversation Lenses are structurally feasible

The display provider already has filter and sort enums, typed display models,
and card emphasis hooks. This gives future lenses a natural insertion point.

Why it matters:

Discovery is central to MessageLens. The architecture should make future
Conversation Lenses ordinary work, not a redesign.

Severity: Low

Suggested direction:

Add future lenses through typed Conversation display/read models and documented
visual emphasis semantics. Avoid burying lens-specific rules in card widgets.

### Observation: Working Set should not be implemented as local sidebar state

The UI documentation records Working Set as a future temporary collection of
conversations found during investigation.

Why it matters:

Working Set can easily become a second, local version of Favourites if it is
implemented as sidebar-only state. That would undermine global Conversation
identity.

Severity: Medium

Suggested direction:

When implemented, Working Set should be keyed by stable Conversation identity
and exposed as a Conversation lens. The act of adding a Conversation to a
Working Set likely belongs to All Messages/Search result workflows, while the
display belongs to Conversations.

### Observation: Conversation identity depends on the shared display identity
resolver

Conversation titles are resolved through the Contacts display identity resolver
from participant handles. This supports the invariant that user-assigned names
win over imported names and raw handles.

Why it matters:

Known people should not fall back to phone numbers or imported full names in
Conversation contexts. Identity consistency is central to user trust.

Severity: Low

Suggested direction:

Preserve the resolver boundary. Do not let Conversation widgets construct
titles directly from raw handles. If identity bugs appear, fix the resolver or
read model, not individual widgets.

### Observation: Conversation Graph remains a strong read primitive boundary

`essentials/conversation_graph` supplies graph facts, signature readers,
overview providers, topology, and source-scoped identifiers. User-facing
Conversation presentation is outside it.

Why it matters:

This keeps graph infrastructure from becoming an application feature and keeps
widgets from reconstructing topology.

Severity: Low

Suggested direction:

Maintain the split. Future graph fields should be exposed as named read models
and then interpreted by `features/conversations` for presentation.

## Debt Summary

### Architectural Debt

- Favourite controller/store naming and provider location still suggest graph
  ownership of a user-intent overlay.
- Some Conversation lens presentation semantics still live close to widget
  composition rather than fully in typed display data.

### Conceptual Debt

- The Conversations metadata search field does not clearly communicate its
  limited scope.
- Working Set is documented as a future concept but not yet integrated into a
  durable model.

### UI Debt

- X-column panel rhythm remains unsettled and can affect the right-side
  Conversation excerpt's perceived peer status.
- Compact Conversation card styling must remain carefully constrained in narrow
  panels.

### Documentation Debt

- If favourite overlay ownership remains in `conversation_graph` for release,
  document whether that is transitional or intentional.
- Once the X-column/sidebar content seam stabilizes, promote the durable rule
  into canonical UI/layout documentation rather than leaving it only in working
  notes.

## Release-Oriented Recommendation

Do not reopen broad Conversation architecture before release. The essential
ownership repair has been completed:

- Conversations owns Conversation presentation.
- Messages owns message evidence rendering.
- Search requests Conversation excerpts rather than owning them.
- Graph supplies facts/read primitives.
- Overlay intent is applied through read-time composition.

The next release-relevant work should be limited to:

1. resolving the Conversations metadata search UX decision;
2. stabilizing the X-column layout enough that Search, Messages, and
   Conversation read as peer workspaces;
3. documenting or lightly relocating favourite overlay ownership before it grows
   beyond Core Favourites.

Everything else can wait until after MessageLens ships unless it blocks
readiness, data integrity, archive/recovery correctness, onboarding, or
user-visible correctness.
