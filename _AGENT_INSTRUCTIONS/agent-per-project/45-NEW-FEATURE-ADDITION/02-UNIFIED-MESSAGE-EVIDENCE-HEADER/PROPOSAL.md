# Unified Message Evidence Header Proposal

## Purpose

Unify center-panel message evidence headers without changing message evidence rendering, message data sources, sidebar behavior, skeleton construction, row hydration, or attachment presentation.

Core rule:

```text
source-specific composers write meaning
shared header renderer writes form
```

This slice should make evidence-reading surfaces easier to understand by giving them a consistent header grammar while preserving legitimate source-specific context.

Preserve this boundary strictly:

- source-specific composers own meaning, wording, contextual semantics, caveat semantics, active scope semantics, and actions/controls configuration
- the shared renderer owns typography, spacing, hierarchy, blur/fade behavior, layout rhythm, and chrome minimization
- the renderer must not infer semantic wording from raw scopes or become a magical semantic interpreter

---

# Existing Header Implementations

## Shared Renderer

- `lib/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart`
  - defines `MessageEvidenceHeaderData`
  - renders title, subtitle parts, status line, scope indicator, controls, action strip, and details

Current issue:

- the renderer is shared, but the data model is too generic and loosely structured
- each source surface hand-builds title/subtitle/status semantics differently
- the renderer cannot distinguish identity, context, count/date facts, caveats, active filters, and controls as intentional regions
- current context/status fields risk merging distinct meanings such as participant identity, handle filters, recovered-message caveats, and unfamiliar-source explanations

## Contact / All Messages

- `lib/features/messages/presentation/view/contact_graph_messages_view.dart`
- Current header:
  - title: `All messages from Claire`
  - subtitle: date span + count, or selected month + month count
  - status: graph skeleton / selected handle / selected month / hydration wording
  - controls: contact message search field

This is the current visual gold standard:

- light, unboxed, calm
- compact context line
- optional interaction row
- no heavy chrome

## Contact / By Conversation

Contact-by-conversation itself is primarily sidebar navigation. Once a conversation is selected, the center panel currently uses:

- `lib/features/messages/presentation/view/conversation_messages_preview_view.dart`

So header unification should target the selected conversation evidence header, not the sidebar conversation list.

## Conversations

- `lib/features/messages/presentation/view/conversation_messages_preview_view.dart`
- Current header:
  - title: `Conversation: Claire and Cathie`
  - subtitle: date span + message count
  - status: graph skeleton / full conversation / search context / anchor

Legitimate difference:

- conversation identity is participant/topology-oriented rather than contact-owner-oriented

## Search All Messages

- `lib/features/messages/presentation/view/global_graph_messages_view.dart`
- Current header:
  - title: `All messages`
  - subtitle: date span + total count, or match count
  - status: graph skeleton / selected month / search overlay
  - controls: global search field

Legitimate difference:

- global scope has no participant identity
- search state is an evidence-scope overlay

## Search Result Context

- `lib/features/messages/presentation/view/search_result_context_sidebar_view.dart`
- Current header:
  - context-window title and bounded result explanation
  - anchor/context wording

Legitimate difference:

- this is a bounded context window, not a full timeline-like surface
- it should orient the user around why this small slice is being shown

## From Unfamiliar Sources

- `lib/features/messages/presentation/view/handle_lens_view.dart`
- embedded `_HandleLensEvidencePane`
- Current header:
  - title: `Message evidence`
  - subtitle: date span + count
  - status: graph skeleton / handle scope / hydration wording

Related direct handle route:

- `lib/features/messages/presentation/view/handle_graph_messages_view.dart`
- title: `Handle messages`

Current issue:

- two handle-evidence surfaces use similar data with slightly different wording
- this is a good candidate for early unification after contact/conversation

## Recovered Deleted Messages

- `lib/features/messages/presentation/view/recovered_messages_evidence_view.dart`
- Current header:
  - title: `Recovered deleted messages`
  - subtitle: explanatory caveat + count/match count
  - optional scope indicator for selected month
  - controls: recovered search field

Legitimate difference:

- recovered messages require diagnostic caveat language
- they are evidence candidates outside normal conversation linkage

## Recovered No-Handle Messages

- same file: `recovered_messages_evidence_view.dart`
- configured via `RecoveredMessagesEvidenceScope.onlyNoHandleFromMe`

Legitimate difference:

- needs caveat explaining no surviving handle linkage

## Handle-Filtered Messages

- `contact_graph_messages_view.dart` through `ContactHandleMessagesEvidenceScope`
- Current header is still contact-owned:
  - `All messages from Claire`
  - status mentions selected handle

Legitimate difference:

- handle filtering is an active scope/filter, not primary identity
- it should likely appear as a quiet active-scope line or chip, not replace the contact identity

---

# Shared Header Elements

The unified model should represent these regions explicitly:

1. **Primary identity/title**
   - examples:
     - `All messages from Claire`
     - `Conversation: Claire and Cathie`
     - `All messages`
     - `Recovered deleted messages`

2. **Participant/identity context**
   - examples:
     - contact display name or selected handle context
     - conversation participant summary

3. **Scope/caveat context**
   - examples:
     - recovered deleted-message warnings
     - no-handle caveats
     - search context wording
     - unfamiliar handle evidence context

4. **Date range**
   - full scope date span
   - selected month date label
   - context-window date span where relevant

5. **Message count**
   - total selected logical scope count
   - selected month count
   - match count overlay
   - context-window count

6. **Search/filter row**
   - global search field
   - contact search field
   - recovered search field
   - future scope controls

7. **Scope-specific actions**
   - allowed only as explicit actions passed by source composers
   - not inferred by the renderer

---

# Legitimate Source-Specific Meaning

Source-specific composers may decide:

- the title wording
- the participant or entity identity label
- the scope/caveat wording
- whether the scope is a full timeline or bounded context window
- whether a selected month is active
- whether a search/filter overlay is active
- whether caveat text is necessary
- which controls/actions are meaningful for that surface
- whether the count represents total scope, selected month, or matched subset

The shared renderer decides:

- typography
- spacing
- visual hierarchy
- ordering of regions
- subdued status/caveat treatment
- control row placement
- blur/fade boundary relationship to message scrolling
- chrome minimization

---

# Proposed Header Model

Introduce a typed model near the shared header widget, for example:

```dart
class MessageEvidenceHeaderModel {
  const MessageEvidenceHeaderModel({
    required this.title,
    this.identityContextLine,
    this.scopeContextLine,
    this.dateRangeLabel,
    this.countLabel,
    this.scopeNote,
    this.activeScopeLabel,
    this.statusLine,
    this.controls,
    this.actions,
    this.details,
  });

  final String title;
  final String? identityContextLine;
  final String? scopeContextLine;
  final String? dateRangeLabel;
  final String? countLabel;
  final String? scopeNote;
  final String? activeScopeLabel;
  final String? statusLine;
  final Widget? controls;
  final Widget? actions;
  final Widget? details;
}
```

`identityContextLine` and `scopeContextLine` may render similarly at first, but they must remain conceptually distinct:

- `identityContextLine`: who or what the evidence is about, such as a contact, handle, or participant set
- `scopeContextLine`: why this evidence scope is unusual or bounded, such as recovered records, no-handle records, unfamiliar sources, or a search context window

Possible refinement:

```dart
class MessageEvidenceHeaderMetric {
  const MessageEvidenceHeaderMetric({
    required this.label,
    this.kind = MessageEvidenceHeaderMetricKind.neutral,
  });
}
```

Metrics should eventually become a structured region rather than a pair of unrelated strings. The first slice should avoid overbuilding, so `dateRangeLabel` and `countLabel` are acceptable if the regions are named, stable, and easy to replace with structured metrics later.

Status/debug wording such as `graph skeleton • hydrate visible rows` is not long-term user-facing semantic meaning. It may remain temporarily for development visibility, but the model should not let pipeline diagnostics masquerade as evidence context.

Compatibility option:

- keep `MessageEvidenceHeaderData` temporarily
- add `MessageEvidenceHeaderModel`
- provide a small adapter or migrate call sites directly

Preferred first slice:

- introduce `MessageEvidenceHeaderModel`
- update `MessageEvidenceHeader` to accept the model
- keep `MessageEvidenceHeaderData` only if it meaningfully reduces churn during migration

---

# Shared Renderer Responsibilities

`MessageEvidenceHeader` should:

- render the title with the app’s theme typography tokens
- render context/date/count in a compact, consistent secondary line
- render caveats/status as quiet supporting text
- render controls in one predictable place
- avoid cards, heavy panels, borders, or dashboard chrome
- preserve the calm contact/all-messages visual language
- keep the header visually attached to the evidence stream

Visual invariant:

- message evidence headers should feel calm, editorial, lightly integrated into the evidence stream, minimally chromed, and spatially coherent
- avoid dashboard headers, boxed panels, heavy cards, nested chrome, and visually detached control slabs
- preserve the Contact All Messages header as the baseline: subtle blur/fade separator, calm hierarchy, evidence-reading feel, low-friction typography, and no obtrusive framing
- MessageLens should read as a focused evidence-reading environment, not a dashboard

`MessageEvidenceHeader` should not:

- infer wording from `MessageEvidenceScope`
- query providers
- compute counts
- inspect contacts/conversations/handles
- decide recovered-message semantics
- create navigation behavior
- mutate state

---

# First Implementation Slice

Migrate two low-risk graph-backed surfaces first:

1. **Contact / All Messages**
   - primary visual reference
   - already uses `MessageEvidenceHeader`
   - contains search controls and month/filter states
   - proves model can express the gold-standard header

2. **Conversation Messages**
   - different semantic identity shape
   - no search field unless opened from search context
   - proves model can express participant/topology identity without changing row rendering

This first slice should:

- add `MessageEvidenceHeaderModel`
- update `MessageEvidenceHeader` rendering to use named regions
- build source-specific header models in the existing contact and conversation views
- preserve existing wording as much as possible
- keep `MessageEvidenceTimelineView` unchanged except for the header data type if necessary
- add focused widget tests for both migrated surfaces

This first slice should not introduce header DSLs, giant region managers, abstract layout engines, polymorphic semantic builders, or generalized configuration trees. Keep the change typed, incremental, semantically grounded, and visually coherent.

---

# Deferred Surfaces

Defer until the model is proven:

- Search All Messages
- Search result context
- From unfamiliar sources / HandleLens evidence pane
- direct Handle messages
- Recovered deleted messages
- Recovered no-handle messages

Reason:

- these have more caveat/control/action variation
- migrating them after contact/conversation will reveal whether the model needs a `scopeNote`, `activeScopeLabel`, or `actions` adjustment

---

# Tests Needed

## Model / Renderer Tests

- renders title
- renders context/date/count regions in stable order
- omits empty optional regions
- renders controls without changing layout assumptions
- does not require source-specific providers

## Contact Header Tests

- all messages title remains `All messages from Claire`
- date/count line remains present
- selected month line remains present
- search field remains mounted while search updates
- handle-filtered state is represented as active scope/status without replacing contact identity

## Conversation Header Tests

- conversation title remains participant-oriented
- date/count line remains present
- anchor/search-context status remains quiet and secondary
- no data queries or topology decisions move into the header renderer

## Regression Tests

- contact timeline still uses full skeleton
- conversation timeline still hydrates through shared evidence rows
- attachments remain unaffected
- no new renderer path introduced

---

# Guardrails

Do not:

- change `MessageEvidenceScope`
- change skeleton construction
- change row hydration
- change attachment evidence hydration
- change sidebar behavior
- move navigation controls into the center panel
- create source-specific header widgets
- create a renderer that infers semantic wording from raw data
- add a new message renderer

Do:

- preserve the Message Evidence Spine invariant
- keep source-specific semantic composition outside the renderer
- centralize header form and rhythm
- keep the contact/all-messages visual language as the baseline
- migrate incrementally

---

# Follow-On Questions

1. Should recovered-message caveats use `scopeNote`, `scopeContextLine`, or both when recovered surfaces migrate?
2. When should `dateRangeLabel` and `countLabel` become a structured metrics region?
3. When should `MessageEvidenceHeaderData` be retired after compatibility migration is complete?
4. Should status/debug wording such as `graph skeleton • hydrate visible rows` remain visible in normal user-facing mode, or should it become developer-only in a later slice?
