---
tier: project
scope: architecture-proposal
owner: agent-per-project
last_reviewed: 2026-07-20
source_of_truth: proposal
status: first-slice-implemented
links:
  - ./seed.md
  - ./EVALUATION.md
  - ../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md#the-mechanical-impossibility-principle
  - ../../40-FEATURES/chat-handles/CHARTER.md
  - ../../40-FEATURES/chat-handles/INTERACTIONS_AND_NAVIGATION.md
tests:
  - ../../../../test/features/handles/domain/entities/stray_handle_endpoint_kind_test.dart
  - ../../../../test/features/handles/application/stray_handles_provider_test.dart
  - ../../../../test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart
---

# Unknown Sources Architecture Proposal

## Decision

MessageLens should treat source identification and numeric-sender review as
separate investigations.

The current page should become a pure source-identification surface. Numeric
sender IDs that match the existing short-code shape should not enter that
investigation.

This boundary is structural, not behavioral. MessageLens can currently prove
that an endpoint resembles a short code. It cannot prove that the source is
automated, unwanted, malicious, or spam.

## Investigation Boundaries

### Identify Unknown Sources

Question:

> Who is this unresolved person or organization?

This investigation contains unresolved source endpoints for which identity
resolution is a meaningful task:

- full telephone numbers;
- email addresses;
- business URNs;
- other non-short-code endpoints that can reasonably represent a person or
  organization.

Its primary actions are:

- inspect the source's message evidence;
- create a Contact;
- link the source to an existing Contact.

The ordinary list does not require a `SPAM` badge or per-row dismissal button.
If an exceptional source must be dismissed, that action can remain available
through the source's detail context until its long-term semantics are settled.

### Review Numeric Sender IDs

Question:

> What is this numeric sender ID, and should it remain in active review?

The first version contains endpoints recognized by the existing short-code
shape rule. This is a neutral structural classification.

The investigation may support:

- inspecting message evidence;
- recognizing a useful service;
- dismissing an unhelpful source from active review;
- restoring a previously dismissed source.

It must not imply that every numeric sender ID is spam. Authentication,
delivery, banking, appointment, and other service messages may be both
machine-generated and useful.

## Navigation

Keep both investigations inside the Handles feature and beneath one
source-review entry point. They are peer investigations over the same canonical
handle facts, not separate top-level application features.

The intended composition is:

```text
Source review
  -> Identify unknown sources
       -> optional endpoint-kind filter
       -> unresolved-source list

  -> Review numeric sender IDs
       -> active numeric IDs
       -> dismissed/recovery access
```

Final labels and control styling remain open. The architectural requirement is
that investigation choice precedes endpoint filtering. `Phone`, `Email`, and
`Business` describe endpoint form; they must not also decide whether a source
belongs to the identification or numeric-review investigation.

Dismissed is a maintenance state, not a third peer investigation.

## Ownership

### Handles feature

Handles owns:

- endpoint-kind interpretation;
- the two investigation specifications;
- compatible read models;
- source-review actions;
- source-review presentation payloads.

### Conversation graph

The graph owns imported and derived facts:

- canonical handles and aliases;
- service metadata;
- sender evidence;
- contact-to-handle graph links.

The graph does not own dismissal, unwantedness, or user-confirmed
classification.

### Overlay

Overlay owns user intent:

- manual Contact links;
- reviewed state;
- dismissal and restoration;
- visibility or blacklist decisions.

The existing distinction between dismissal and blacklist remains intact until
a later proposal defines whether and how they should converge.

### Sidebar and Messages

The sidebar cassette system routes and composes the selected investigation. It
does not classify sources.

Messages owns the source's message-evidence presentation. It consumes the
selected canonical handle identity but does not own source-review policy.
`MessagesSpec.handleInvestigation` remains wholly Messages-owned. Handles supplies one
per-source identity projection and one source-review workflow facade; Contacts
supplies the Contact creation and linking primitives used by that facade.

Cross-feature presentation ownership does not permit Messages to reimplement
Handles fallback identity, normalization, dismissal, persistence, invalidation,
or association ordering.

## Read-Model Implications

The current graph-backed unresolved-handle reader remains the shared factual
source. Feature-owned read models then project that source into compatible
investigations.

Conceptually:

```text
canonical unresolved handles + overlay intent
  -> endpoint-kind classification
  -> investigation compatibility
  -> source-identification read model
     or numeric-sender read model
```

The source-identification read model must not return short-code endpoints. The
numeric-sender read model must return the structurally compatible endpoints
without assigning a spam verdict.

The current `Phone` string filter is insufficient because it accepts every
endpoint that is neither an email nor a business URN, including short codes.
Endpoint kind should become typed before presentation. Widgets should receive
already compatible rows and should not calculate `junkScore`, infer spam, or
remove incompatible rows locally.

Dismissed sources remain overlay-backed and recoverable. Existing dismissal
data does not need to be discarded for the first slice.

## Mechanical Impossibility

This separation directly applies the Mechanical Impossibility Principle.

The source-identification widget should not receive numeric sender IDs and then
hide, tint, or dismiss them. Its read model should make their presence
impossible:

```text
short-code endpoint
  -> incompatible with source-identification investigation
  -> cannot enter its read model
  -> cannot appear in its list
```

Removing incompatible rows naturally removes the structural causes of the
current visual noise, misleading `SPAM` badges, and ordinary per-row `X`
buttons. Row-width improvement is a consequence of the corrected architecture,
not the architectural objective.

## Staged Implementation Plan

### Stage 1: Truthful endpoint kinds

- Introduce a typed endpoint-kind result at the Handles read-model boundary.
- Preserve the current short-code shape rule as a structural signal only.
- Add focused boundary tests for full phone numbers, short codes, emails,
  business URNs, and unknown endpoint forms.
- Do not add persistence or automated-source claims.

### Stage 2: Separate compatible read models

- Add source-identification and numeric-sender projections over the shared
  unresolved-handle facts.
- Guarantee that short codes cannot enter source identification.
- Preserve existing overlay links, dismissal, visibility, and blacklist
  behavior.

### Stage 3: Separate investigation navigation

- Replace the mixed all/spam presentation with the two peer investigations.
- Keep endpoint-kind filtering inside source identification where useful.
- Keep dismissed/recovery access subordinate to numeric-sender maintenance.
- Route both through existing Handles cassette/spec coordination.

### Stage 4: Remove misleading mixed-view behavior

- Remove `SPAM` and junk-score presentation from the identification list.
- Remove the ordinary per-row `X` from that list.
- Present short codes neutrally in their own investigation.
- Retain an explicit, semantically named dismissal action where appropriate.

### Stage 5: Future classification, only if justified

- Explore user-confirmed person, organization, service, automated, useful, or
  unwanted classifications.
- Treat machine-generated signals as suggestions rather than durable truth.
- Decide separately whether unwantedness belongs to a source or individual
  messages.
- Reconcile dismissal and blacklist only after their intended scopes are
  explicitly defined.

## First-Slice Success Criterion

The architecture is proven when:

- the primary source-identification list contains useful unresolved people and
  organization candidates;
- structurally recognized short codes cannot appear in that list;
- those short codes remain available through a separate review investigation;
- no source messages or graph facts are deleted or suppressed;
- user dismissal remains overlay-owned and recoverable;
- neither read model nor UI claims that a short code is spam.

## Implemented First Slice

The first user-visible slice now implements the architectural boundary above:

- Handles classifies unresolved endpoints into typed structural kinds without
  assigning sender intent.
- `Identify` consumes a read model from which short codes are mechanically
  excluded, then offers Phone, Email, and Business endpoint filters.
- `Numeric IDs` consumes a separate read model containing only structurally
  recognized short codes.
- The existing cassette cascade expresses investigation choice before the
  investigation-specific controls and list.
- The ordinary source-identification list no longer displays a `SPAM` verdict
  or per-row dismissal button. Dismissal remains an explicit action in the
  selected source's evidence context.
- Active/Dismissed remains a subordinate maintenance mode in both
  investigations for the first slice. This preserves recovery for historical
  dismissal data without reintroducing a mixed source list or a peer Spam mode.

No graph schema or imported fact changed. Endpoint kind is a Handles-owned
read-model interpretation, while dismissal remains overlay-owned user intent.

## Implemented Cross-Column Composition

The source-review page now participates in the canonical cross-column matrix.
Its top menu aligns with the selected source title, while source identity,
metrics, search, and triage presentations occupy center-only cells. A final
fixed-height occupant establishes the shared point after which both the
remaining sidebar cassette chain and message evidence begin.

This does not move cassette composition into the page. The matrix owns only
pre-content placement and geometry; the cassette coordinator still owns the
investigation controls and source list. See
[`09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md`](../../09-CROSS-COLUMN-LAYOUT/06-unfamiliar-sources-page-current-implementation.md).

## Implemented Investigation Provenance

The sidebar and center panel now share an opaque unfamiliar-source
investigation identity. Handle evidence records the identity of the episode in
which it was selected. Identify/Numeric IDs, endpoint-filter, and review-mode
changes advance the current identity, making evidence from the previous episode
ineffective without deleting the stored selection or issuing an imperative
panel-clear command.

The center projection is now total for every active Unknown Sources
investigation. `MessagesSpec.handleInvestigation` carries the opaque
investigation identity, the Handles-owned investigation kind, and one explicit
target: `idle` or `selectedSource`. No independent idle boolean exists. With no
compatible source selected, the center panel renders a quiet Messages-owned
idle presentation for the current Identify or Numeric IDs investigation rather
than projecting no center ViewSpec.

This keeps investigation state truthful through initial entry, filter changes,
dismissal, and investigation switching. The selected-source target preserves
the existing handle evidence and actions; the idle target omits source-specific
controls and explains what selection will continue the investigation.

This closes the split that previously allowed the cassette chain to show Email
or Numeric IDs while `SidebarFlowState` continued projecting messages selected
under Phone. Messages still owns evidence rendering; Handles owns investigation
semantics and provenance; navigation derives the effective center presentation
from compatibility.

## Implemented Source-Review Ownership Repair

The Messages-owned handle lens now consumes a Handles-owned per-source
presentation model instead of scanning the full active source list and
reconstructing fallback identity. Its Create Contact, Link to Existing, and
Dismiss controls call a Handles-owned source-review facade. The facade delegates
Contact creation and linking to Contacts and delegates recoverable dismissal to
Handles review persistence.

The visible `Dismiss` action now uses the overlay-backed dismissed-source path,
not reviewed-only state. Active and dismissed source projections therefore
derive from the same Handles-owned meaning, while the complete ViewSpec and all
widgets remain in Messages.

Dismissal is also a complete investigation transition. Once Handles confirms
the overlay write, the Messages-owned interaction boundary advances the opaque
unfamiliar-source investigation identity. Navigation compatibility then makes
the originating center evidence ineffective without an imperative panel-clear
command. Failed persistence does not advance the investigation.

The loaded active projection removes only the dismissed source and remains in
`AsyncData`; it does not invalidate the visible database-wide aggregation and
flash an empty loading cassette. The repository remains authoritative on
restart, and dismissed/recovery projections are refreshed independently.

## Implemented Persistent Center-Panel Identity

The Unknown Sources center panel now derives its enduring identity from the
active investigation rather than from the current target:

- Identify projects `Messages not linked to a contact`.
- Numeric IDs projects `Messages from numeric IDs`.

Selecting a source changes the current subject beneath that identity. It no
longer promotes the endpoint into the page-title position, and the redundant
`Unfamiliar source` status line is not part of the Messages presentation.
Loading and evidence-error states preserve the same derived identity.

When no source is selected, the idle presentation uses the evidence region to
explain what the active investigation contains, why those sources appear, and
which actions are available. The explanation replaces evidence, not the
header. The Matrix continues to coordinate shared header geometry without
becoming responsible for local explanatory prose.
