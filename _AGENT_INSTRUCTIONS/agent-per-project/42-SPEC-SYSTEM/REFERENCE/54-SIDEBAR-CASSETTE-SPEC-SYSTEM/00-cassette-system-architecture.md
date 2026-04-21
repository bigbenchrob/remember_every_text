# Sidebar Cassette System Architecture

## Overview

The sidebar displays a vertical stack of **cassettes** — self-contained cards
that each show feature-specific content. The sidebar supports multiple modes
(`SidebarMode.messages`, `SidebarMode.settings`) with different initial stacks.

The system has four layers:
1. **Rack state** — what specs should be displayed, in what order
2. **Cascade** — how selecting something in one cassette determines the next
3. **Coordinator dispatch** — routing each spec to the owning feature
4. **Card chrome** — wrapping feature content in visual card containers

For the detailed layout ownership contract, including feature-owned complex
bodies and optical composition inside an essentials-owned frame, read
`10-layout-and-optical-composition.md` in this folder.

---

## 1. CassetteSpec — The Top-Level Sealed Class

`CassetteSpec` is a freezed sealed class with one variant per feature (or feature surface):

```dart
@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) = ...;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) = ...;
  const factory CassetteSpec.contactsSettings(ContactsSettingsSpec spec) = ...;
  const factory CassetteSpec.contactsInfo(ContactsInfoCassetteSpec spec) = ...;
  const factory CassetteSpec.handles(HandlesCassetteSpec spec) = ...;
  const factory CassetteSpec.handlesInfo(HandlesInfoCassetteSpec spec) = ...;
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) = ...;
  const factory CassetteSpec.messagesInfo(MessagesInfoCassetteSpec spec) = ...;
}
```

Each variant wraps a **feature-specific inner spec** that the feature alone defines
and interprets. The inner spec is domain data living in the feature's
`domain/spec_classes/` folder.

**Location:** `lib/essentials/sidebar/domain/entities/cassette_spec.dart`

---

## 2. Rack State

The **rack** is an ordered, immutable list of `CassetteSpec` objects representing
what the sidebar currently shows:

```dart
@freezed
abstract class CassetteRack with _$CassetteRack {
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;
}
```

The `CassetteRackState` provider manages the rack per `SidebarMode`:

```dart
@riverpod
class CassetteRackState extends _$CassetteRackState {
  @override
  CassetteRack build(SidebarMode mode) { ... }  // Returns initial rack for mode
}
```

### Canonical flow state for the contacts/messages branch

The rack remains the rendered sidebar artifact, but it is no longer the
canonical owner of all sidebar meaning.

For the contacts/messages branch, `SidebarFlowState` in
`lib/essentials/sidebar/application/sidebar_flow_state_provider.dart` owns the
meaningful flow decisions, including:

- active top-menu branch
- chosen contact
- selected handle, if any
- regular vs recovered/deleted message scope

That provider is responsible for explicit transitions such as contact choice,
contact reset, handle selection, and message-scope switching. Those transitions
update both the visible rack and the center-panel `ViewSpec` routing so the
sidebar and panels stay coherent.

This distinction matters:

- the rack still stores what should currently render in the sidebar
- the canonical flow provider stores why that branch is active
- code should not reintroduce critical state inference by scanning the current
  rack when canonical flow state already owns the answer

### Initial stacks

- **Messages mode**: Starts with `SidebarUtilityCassetteSpec.topChatMenu()`, then
  cascades automatically to contacts → messages cassettes
- **Settings mode**: Starts with `SidebarUtilityCassetteSpec.settingsMenu()`, then
  cascades to settings-specific cassettes

### Rack mutations

The rack state provider exposes methods for modifying the stack:

| Method | Purpose |
|---|---|
| `replaceAtIndexAndCascade(index, newSpec)` | Replace a cassette and re-cascade everything below it |
| `resetToInitial()` | Return to the mode's initial state |

**Location:** `lib/essentials/sidebar/application/cassette_rack_state_provider.dart`

---

## 3. Cascade System

When a cassette is placed or updated, the system needs to determine what cassettes
should appear **below** it. This is the cascade.

### How it works

Every `CassetteSpec` has a `childSpec()` extension method that returns the next
spec in the chain (or `null` to end the chain):

```dart
extension CassetteSpecX on CassetteSpec {
  CassetteSpec? childSpec() => resolveCassetteChild(this);
}
```

`resolveCassetteChild()` dispatches to per-feature **topology extensions** via
`spec.when(...)`. Each feature's inner spec type also exposes a `childSpec()`
method defining what comes next.

### Topology files

Each feature that participates in cascading has a topology file:

```
lib/essentials/sidebar/domain/entities/cascade/
├── cassette_child_resolver.dart       ← top-level dispatcher
├── sidebar_utility_topology.dart      ← SidebarUtilityCassetteSpec cascades
├── contacts_cassette_topology.dart    ← ContactsCassetteSpec cascades
├── contacts_info_topology.dart
├── contacts_settings_topology.dart
├── handles_cassette_topology.dart
├── handles_info_topology.dart
├── messages_cassette_topology.dart
└── links/
  ├── contacts_children.dart         ← cross-feature: contacts → messages
  └── sidebar_utility_children.dart  ← cross-feature: utility → contacts
```

### Cross-feature links

When a cascade needs to cross a feature boundary (e.g., selecting a contact should
show that contact's messages below), the link files in `cascade/links/` define the
transition. These are the **only** place where one feature's spec type connects to
another's.

### Cascade on rack mutation

When `replaceAtIndexAndCascade()` is called, the rack state provider:
1. Replaces the spec at the given index
2. Calls `childSpec()` repeatedly to build the cascade chain
3. Replaces everything below the index with the new chain

For branches that use canonical flow state, the recascade is the projection
mechanism, not the source of truth. In particular, the contacts/messages branch
should be understood as:

1. user interaction triggers an explicit transition on `SidebarFlowState`
2. the transition computes the correct replacement cassette root for the branch
3. `CassetteRackState` re-cascades from that root
4. panel routing is updated from the same transition so stale center-panel
  content cannot linger legitimately

### Important: Cascade Does Not Automatically Reconcile Panels

The cassette rack owns sidebar intent, but it does not by itself guarantee that
center/right panel content is still valid after a cascade change.

Therefore:

- Any cassette transition that changes the meaning of the sidebar flow must be
  evaluated against existing panel content.
- If previously shown panel content no longer matches the active cassette path,
  the panel content must be cleared or replaced.
- Do not assume that replacing the cassette rack is enough to remove stale
  center-panel content. Widget-level effects may reassert an older spec unless
  they are guarded.

This is especially important for cassettes that auto-open panel content on
mount, such as heatmaps or recovered-message navigators.

### Current chosen-contact branch shape

The stabilized contacts/messages chosen-contact flow now projects this branch
order:

1. top chat menu
2. contact hero summary
3. chosen-contact info card
4. message-scope toggle
5. handle filter
6. contact-scoped messages heatmap or recovered contextual branch, depending on
  the canonical message scope

That order is semantically intentional:

- hero first establishes identity
- info card explains the current context and offers the reset action
- controls follow after context rather than competing with it above

---

## 4. CassetteWidgetCoordinator — App-Level Dispatch

The `CassetteWidgetCoordinator` is the app-level async provider that transforms
the rack into rendered widgets:

```dart
@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  @override
  Future<List<Widget>> build(SidebarMode mode) async { ... }
}
```

### What it does

1. **Watches** `cassetteRackStateProvider(mode)` — rebuilds when rack changes
2. **Iterates** each `CassetteSpec` in the rack
3. **Routes** each spec to the owning feature's coordinator via `spec.when(...)`:
   ```dart
   spec.when(
     contacts: (innerSpec) => ref
       .read(contacts_feature.contactsCassetteCoordinatorProvider.notifier)
       .buildViewModel(innerSpec, cassetteIndex: i),
     messages: (innerSpec) => ref
       .read(messages_feature.messagesCassetteCoordinatorProvider.notifier)
       .buildViewModel(innerSpec, cassetteIndex: i),
     // ... one branch per CassetteSpec variant
   );
   ```
4. **Awaits** the returned `Future<SidebarCassettePayload>` from each feature
5. **Returns** `List<ResolvedSidebarCassette>` — semantic payloads plus rack context
6. **Defers** widget construction and chrome selection to the shared sidebar render router

### Feature import pattern

The coordinator imports each feature via its barrel with an alias:

```dart
import '.../features/contacts/feature_level_providers.dart' as contacts_feature;
import '.../features/messages/feature_level_providers.dart' as messages_feature;
import '.../features/handles/feature_level_providers.dart' as handles_feature;
```

This prevents provider name collisions and enforces the barrel-only import rule.

**Location:** `lib/essentials/sidebar/application/cassette_widget_coordinator_provider.dart`

### Widget Builder Side Effects

Some cassette widget builders intentionally trigger panel navigation in response
to becoming active. This is allowed, but only under the following constraints:

- The side effect must dispatch through `panelsViewStateProvider(...)` using a
  `ViewSpec`; no direct panel manipulation is allowed.
- The widget must verify that its owning cassette context is still current
  before dispatching. If the user has already switched the top menu or the rack
  has cascaded elsewhere, the side effect must abort.
- Essentials-level reconciliation should still exist as a fail-safe. Guards in
  widgets reduce races; they do not replace architecture-level coherence.

---

## 5. SidebarCassettePayload

The canonical sidebar boundary contract is `SidebarCassettePayload`. All live
sidebar payloads are inert and declare their render family explicitly via
`SidebarCassetteRenderKind`.

### Approved payload families

| Payload family | Purpose |
|---|---|
| `PlacementGovernedSidebarCassettePayload` | Feature-owned bodies that render inside the shared cassette shell |
| `FeatureInfoSidebarCassettePayload` | Shared info-card chrome with semantic body text and optional feature-owned supplemental content |
| `SharedBodyModelSidebarCassettePayload` | Essentials-owned body-model shells such as dropdown/menu cassettes |

The resolver decides payload fields. The shared sidebar render router reads
`renderKind` and subtype to select chrome, render-edge builders, and shared
layout rules.

**Location:** `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart`

---

## 6. Shared Chrome and Render Families

Essentials-owned presentation widgets still provide the sidebar chrome, but they
are now chosen by the shared render router rather than by a feature-supplied
render-family contract.

| Render family | Shared chrome / host |
|---|---|
| `placementGovernedFeature` | `SidebarCassetteCard.placementGoverned(...)` |
| `featureInfo` | `SidebarInfoCard` |
| `sharedBodyModel` | `SidebarCassetteCard` + `SidebarBodyModelContent` |

Features never construct or return these chrome widgets. They return inert
payloads and essentials applies the shared wrapper.

### Practical ownership guidance

- When a sidebar cassette can be expressed as a governed primitive such as a
  button, menu, or compact navigation control, essentials should own that body.
- When a sidebar cassette body is highly feature-specific and depends on
  feature infrastructure or complex rendering, the feature may build the body,
  but only inside the constrained frame owned by essentials.
- Feature-owned complex bodies may tune their internal composition, but must
  not redefine the outer cassette rails or width.

---

## 7. Payload → Widget Translation and Expandability

The sidebar render router translates each `ResolvedSidebarCassette.payload`
into a widget. This section documents how payload families map to shared chrome
and how expandability is preserved through the shared host.

### 7a. Render-Kind Routing

The shared router switches on `payload.renderKind` to select the host widget:

| `renderKind` | Widget created | Key payload data used |
|---|---|---|
| `.placementGovernedFeature` | `SidebarCassetteCard.placementGoverned(...)` | title/subtitle/footer, placement, alignment, layout style, `shouldExpand`, feature-owned render-edge body |
| `.featureInfo` | `SidebarInfoCard` | title, body text, footnote, optional feature-owned supplemental content |
| `.sharedBodyModel` | `SidebarCassetteCard` + `SidebarBodyModelContent` | title/subtitle/footer, placement, alignment, layout style, `shouldExpand`, `SidebarBodyModel` |

**Key detail:** `shouldExpand` is only meaningful on the payload branches that
support full card bodies (`placementGovernedFeature` and `sharedBodyModel`).

### 7b. Sidebar Surface Layout (`_LeftSidebarSurface`)

The sidebar surface in `panel_widget_providers.dart` sorts cassette widgets into
two zones:

**Controls zone** (pinned at top, never expands):
- Any `SidebarCassetteCard` where `isControl == true` or `isNaked == true`
- Rendered as individual `SliverToBoxAdapter` widgets — always intrinsic height

**Content zone** (remaining cards):
- Everything that isn't a control
- Each widget is tagged with a `shouldExpand` value extracted per type:
  - `SidebarCassetteCard` → reads the widget's own `shouldExpand` field
  - All other widget types → `false`

### 7c. Expansion Strategy

The content zone uses a **conditional layout strategy** based on whether any
content item needs to expand:

**When any content item has `shouldExpand: true`:**
All content items are placed in a single `SliverFillRemaining(hasScrollBody: true)`
containing a `_ContentFillColumn`. Inside that column:
- Expanding items are wrapped in `Expanded` — they share remaining space equally
- Non-expanding items sit at intrinsic height

**When no content items want to expand:**
Each content item is individually wrapped in a `SliverToBoxAdapter` — all cards
render at their intrinsic height. No vertical space filling occurs.

This means a single info card alone in the sidebar will **not** stretch to fill
the viewport — it will sit at its natural height.

### 7d. Inner Card Expansion (`SidebarCassetteCard`)

`SidebarCassetteCard` has its own internal expansion logic using `LayoutBuilder`:

```dart
if (hasBoundedHeight && shouldExpand)
  Expanded(child: body)
else
  body
```

This is defensive: if the card somehow receives unbounded height constraints
(e.g., placed in a `SliverToBoxAdapter`), it won't use `Expanded` even if
`shouldExpand: true`, avoiding layout errors. The bounded-height check acts as
a safety net.

### 7e. Expandability Defaults — Opt-In System

Payload branches that support expansion default `shouldExpand` to **`false`**.
Cards are intrinsic-height unless the resolver explicitly opts in:

```dart
// Scrollable list — needs vertical space:
SomePlacementGovernedPayload(
  shouldExpand: true,  // explicit opt-in
);

// Info card — fixed content:
StaticFeatureInfoSidebarCassettePayload(
  bodyText: 'Contact Names are resolved from the chosen contact.',
);
```

**Rule of thumb:** Set `shouldExpand: true` only for cards whose child widget
contains a scrollable list or other content that meaningfully benefits from
filling available space. All other cards (info text, summaries, heatmaps,
controls) should leave the default.

### 7f. Complete Height Constraint Flow

```
Resolver sets shouldExpand on payload (when supported)
    │
    ▼
Sidebar render router
  ├─ placement/sharedBodyModel → shared card host reads shouldExpand
  └─ featureInfo → SidebarInfoCard (always intrinsic)
    │
    ▼
_LeftSidebarSurface sorts widgets
    ├─ Controls (naked/isControl) → SliverToBoxAdapter → intrinsic
    └─ Content → tagged with shouldExpand per widget type
        │
        ├─ Any expanding? → SliverFillRemaining → _ContentFillColumn
        │    ├─ shouldExpand: true items → Expanded (share remaining space)
        │    └─ shouldExpand: false items → intrinsic
        │
        └─ None expanding? → individual SliverToBoxAdapter → all intrinsic
            │
            ▼
SidebarCassetteCard.build (inner LayoutBuilder)
    ├─ hasBoundedHeight && shouldExpand → Expanded(child: body)
    └─ else → body at intrinsic height
```

---

## 8. Payload Configuration Patterns

This section provides guidance for choosing the right card configuration based on
the cassette's purpose and content characteristics.

### 8a. Payload Families

Choose the payload family that matches the chrome ownership and render-edge
behavior you need:

| Family | When to use | Example cassettes |
|---|---|---|
| `PlacementGovernedSidebarCassettePayload` | Feature-specific interactive content inside the shared card shell | Contact lists, heatmaps, stray handles review |
| `FeatureInfoSidebarCassettePayload` | Explanatory text or shared info chrome | feature explanations, static settings info |
| `SharedBodyModelSidebarCassettePayload` | Essentials-owned controls expressed as body models | top menus, settings dropdowns |

### 8b. Layout Styles (`SidebarCardLayoutStyle`)

The `layoutStyle` controls **horizontal rails** (margin, padding, section gaps)
without changing the card's structural behavior:

| Style | Horizontal inset | Section gap | When to use |
|---|---|---|---|
| `standard` | 32pt (16pt margin + 16pt padding) | 8pt | Most cassettes, moderate content density |
| `listDense` | 12pt (0pt margin + 12pt padding) | 4pt | Space-sensitive scrollable lists |

**Use `listDense` when:**
- The cassette contains a scrollable list with per-row metadata
- Rows have overlaid action buttons (e.g., dismiss/restore) that need gutter space
- Long text values (phone numbers, email addresses) need horizontal room
- You want dividers and content edges to align tightly

**Layout values (AppSpacing reference):**
- `standard`: margin=`(v: sm=8, h: md=16)`, padding=`all(md=16)`, sectionTitleGap=`sm=8`
- `listDense`: margin=`(v: xs=4, h: 0)`, padding=`(h: 12, v: sm=8)`, sectionTitleGap=`xs=4`

### 8c. Behavioral Flags

#### `isControl`

Marks the cassette as a **navigation control** rather than content:
- Pinned in the "controls zone" at the top of the sidebar
- Never expands vertically
- Receives reduced visual emphasis (tighter margins)

**Use for:** Menu selectors, mode switchers, filter dropdowns.

#### `isNaked`

Removes **all card chrome** — no title, no padding structure:
- Only horizontal margin remains (to align with card edges)
- Child widget owns all padding, typography, and interaction

**Use for:** Dropdowns, popup menus, and controls that should align flush with
the sidebar edge and need full control over their layout.

#### `shouldExpand`

Opts the card into **vertical space filling**:
- When `true`, card expands to fill remaining sidebar height
- When `false` (default), card takes intrinsic height
- Only meaningful for payload families that render through `SidebarCassetteCard`

**Use for:** Scrollable lists that should fill available space (contact lists,
message threads, stray handles review). Leave `false` for fixed-height content
(info cards, summaries, heatmaps).

### 8d. Decision Matrix

| Cassette purpose | Payload family | `layoutStyle` | `isNaked` | `shouldExpand` |
|---|---|---|---|---|
| Scrollable contact/message list | `PlacementGoverned...` | `standard` | `false` | `true` |
| Dense list with action overlays | `PlacementGoverned...` | `listDense` | `false` | `true` |
| Menu/filter dropdown | `SharedBodyModel...` | `standard` | `true` | `false` |
| Mode switcher popup | `SharedBodyModel...` or placement-governed | `standard` | `true` | `false` |
| Explanatory help text | `FeatureInfo...` | — | — | `false` |
| Summary statistics card | `PlacementGoverned...` | `standard` | `false` | `false` |

### 8e. Action Gutter Pattern

For lists with per-row action buttons (dismiss, restore, etc.), use the
**action gutter** pattern:

1. Define a fixed `actionGutterWidth` constant (e.g., 32pt)
2. Apply as right padding to the data content — data never overlaps action area
3. Position action buttons as overlays anchored at `right: 0`
4. Set divider `endIndent` to `actionGutterWidth` — dividers stop at data boundary
5. Non-actionable rows leave gutter empty but still reserve the space

This keeps action buttons vertically aligned in a dedicated column, visually
separate from the data region.

```dart
// Example: Stray handles review cassette
static const double actionGutterWidth = 32;

// Row data padding
Padding(
  padding: const EdgeInsets.only(right: actionGutterWidth),
  child: Row(children: [/* data content */]),
)

// Divider stops at data boundary
Divider(endIndent: actionGutterWidth)

// Action button overlay
Positioned(
  right: 0,
  top: 0,
  bottom: 2,  // nudge up to align with metadata cluster
  child: Center(child: DismissButton()),
)
```

---

## 9. Sidebar Rendering

The `leftPanelWidget()` provider in `lib/essentials/navigation/application/panel_widget_providers.dart`:
1. Watches `cassetteWidgetCoordinatorProvider(mode)`
2. Uses stale-while-revalidate: shows previous widgets while new ones load
3. Wraps the widget list in `_LeftSidebarSurface` (padding, scroll, layout)

---

## Complete Data Flow

```
SidebarMode
    │
    ▼
CassetteRackState.build(mode)
    │  produces initial CassetteRack via cascade
    ▼
CassetteRack.cassettes  →  [CassetteSpec, CassetteSpec, ...]
    │
    ▼
CassetteWidgetCoordinator.build(mode)
    │  iterates each CassetteSpec
    │  routes to feature coordinator via spec.when(...)
    │
    ├──→ Feature coordinator.buildViewModel(innerSpec, cassetteIndex)
    │       │  pattern-matches inner spec
    │       │  calls resolver with explicit params
    │       │
    │       ├──→ Resolver.resolve(...)
    │       │       │  domain logic, data lookups
    │       │       │  constructs SidebarCassettePayload
    │       │       │  returns Future<SidebarCassettePayload>
    │       │       ▼
    │       │    SidebarCassettePayload
    │       ▼
    │    Future<SidebarCassettePayload>
    │
    ▼
  CassetteWidgetCoordinator returns ResolvedSidebarCassette list
    │
    ▼
  Shared sidebar render router builds widgets
    │  placementGovernedFeature → SidebarCassetteCard.placementGoverned(...)
    │  featureInfo             → SidebarInfoCard
    │  sharedBodyModel         → SidebarCassetteCard + SidebarBodyModelContent
    │
    ▼
List<Widget>  →  leftPanelWidget()  →  _LeftSidebarSurface  →  UI
```
