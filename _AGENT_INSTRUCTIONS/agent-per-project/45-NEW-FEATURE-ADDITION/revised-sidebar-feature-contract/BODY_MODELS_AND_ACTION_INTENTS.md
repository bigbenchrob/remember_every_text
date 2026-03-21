# Sidebar Body Models and Action Intents

This document is a companion to `contract.txt`.

Its purpose is to define the first-pass essentials-owned contract surface for
sidebar cassette content so implementation can proceed without reintroducing
feature-owned layout, widgets, or behavior execution.

---

## 1. Design Goal

The sidebar contract must make the following impossible:

- features returning Flutter widgets
- features constructing controls locally
- features choosing alternative dropdown/button/list implementations
- features encoding layout with spacing, margins, widths, or alignment flags
- features dispatching behavior directly through callbacks or provider calls

To achieve this, features must emit only:

- cassette role
- typed body model
- semantic content data
- semantic action intents

Essentials owns:

- all widget construction
- all control rendering
- all styling
- all geometry
- all interaction binding
- all action dispatch

---

## 2. Proposed Projection Shape

The target projection becomes:

`FlowState -> CassetteSpec -> FeatureMeaningModel -> SidebarBodyModel -> EssentialsRenderer -> UI`

Where:

- `CassetteSpec` still identifies feature-specific meaning targets
- the feature layer interprets that meaning into typed data
- the body model becomes the final non-widget boundary
- the essentials renderer turns the body model into concrete widgets

The important distinction is that `FeatureMeaningModel` and
`SidebarBodyModel` are not widget-oriented APIs. They are semantic content
descriptions.

---

## 3. First-Pass Body Model Catalog

The catalog below is deliberately small. New body types should be added only
when a genuinely new canonical interaction shape appears.

### 3.1 Top-Level Body Family

```dart
sealed class SidebarBodyModel {
  const SidebarBodyModel();
}
```

Initial variants:

- `SidebarInfoBodyModel`
- `SidebarHeroBodyModel`
- `SidebarDropdownBodyModel`
- `SidebarSegmentedControlBodyModel`
- `SidebarActionBodyModel`
- `SidebarListBodyModel`
- `SidebarHeatMapBodyModel`

### 3.2 Info Body

Use for explanatory or supporting text.

Fields:

- `title`
- `bodyText`
- `footnote`
- `supplementalAction`

Notes:

- no custom text widget definitions
- no arbitrary supplemental widget slot
- if action exists, it is an action intent descriptor

### 3.3 Hero Body

Use for the current contact hero cassette and any future truly hero-style
sidebar content that cannot yet be reduced to a more canonical body shape.

This type is intentionally exceptional.

Fields:

- `heroKind`
- `primaryText`
- `secondaryText`
- `metadata`
- `heroActions`

Notes:

- this exists to keep the contract honest during migration
- the hero remains essentials-rendered even if it is only used in one place
- features still return only typed data, never hero widgets
- later, this can be split into smaller canonical or app-specific body families
  if that proves worthwhile

### 3.4 Dropdown Body

Use for any single-select menu control in the sidebar.

Fields:

- `promptLabel`
- `selectedOptionId`
- `options`
- `visualPriority`

Each option:

- `id`
- `label`
- `secondaryLabel`
- `selectionIntent`
- `isDestructive`
- `isDisabled`

Notes:

- there is exactly one dropdown renderer in essentials
- no feature may override menu row rendering
- all dropdowns of the same priority level must render from the same source

### 3.5 Segmented Control Body

Use for compact mutually-exclusive control groups.

Fields:

- `segments`
- `selectedSegmentId`
- `density`

Each segment:

- `id`
- `label`
- `selectionIntent`
- `isDisabled`

Notes:

- all segmented controls are renderer-owned in essentials
- width policy is chosen by essentials, not by the feature

### 3.6 Action Body

Use for explicit affordances like buttons, links, or navigation controls.

Fields:

- `actions`
- `presentation`

Each action:

- `label`
- `intent`
- `tone`
- `icon`
- `isEnabled`

Notes:

- the renderer decides whether an action is shown as button, inline link,
  nav row, or destructive affordance based on body/presentation rules

### 3.7 List Body

Use for scrollable collections of canonical rows.

Fields:

- `items`
- `selectionState`
- `emptyState`
- `listStyle`
- `trailingAffordanceMode`

List styles:

- `standard`
- `dense`
- `guttered`

Trailing affordance modes:

- `none`
- `inline`
- `reservedGutter`

Each item:

- `id`
- `title`
- `subtitle`
- `metadata`
- `badge`
- `rowIntent`
- `trailingAction`
- `tone`
- `isSelected`

Notes:

- the unfamiliar-sources review list is the canonical example for
  `reservedGutter`
- the gutter belongs to essentials; features only declare that the list
  requires trailing affordances

### 3.8 Heat Map Body

Use for the sidebar heatmap specifically.

This is intentionally not a general visualization bucket in the first pass.
At the moment, the contract only knows about one sidebar visualization shape,
so the model should name that shape directly.

Fields:

- `heatMapKind`
- `dataSeries`
- `selectedMonthAnchor`
- `legend`
- `emptyState`

Each data point:

- `monthAnchor`
- `value`
- `interactionIntent`
- `isSelected`

Notes:

- the current messages heatmap belongs here
- heatmap geometry and chrome remain essentials-owned
- if new app-specific visualization types emerge later, they should be added
  deliberately rather than hidden behind a generic visualization model

---

## 4. Composite Bodies

The contract should avoid free-form composition.

Preferred rule:

- one cassette -> one primary body model

If a cassette truly needs multiple canonical sub-bodies, use a tightly bounded
composite:

```dart
class SidebarCompositeBodyModel extends SidebarBodyModel {
  const SidebarCompositeBodyModel({required this.sections});

  final List<SidebarBodySectionModel> sections;
}
```

Constraints:

- sections must still be typed body models
- sections must be vertically composed only by essentials
- no feature-owned layout between sections
- composites should be exceptional, not default

Probable early composites:

- info text plus one supporting action
- list plus secondary mode control only if a separate cassette is not desired

---

## 5. Role and Body Relationship

Role still answers: “what is this cassette for in the sidebar hierarchy?”

Body type answers: “what canonical content shape does this cassette have?”

Examples:

- top menu -> role `appControl`, body `dropdown`
- contact hero summary -> role `contextPrimary`, body `hero`
- contact explanation card -> role `contextSecondary`, body `info`
- message scope selector -> role `filter`, body `segmentedControl`
- unfamiliar-sources review list -> role `contextPrimary`, body `list`
- choose another contact -> role `action`, body `action`

Role must not be used as a layout switch.
Body type must not be used as a section-placement proxy.

---

## 6. Action Intent Taxonomy

Action intents must be essentials-owned and exhaustively typed.

### 6.1 Top-Level Family

```dart
sealed class SidebarActionIntent {
  const SidebarActionIntent();
}
```

### 6.2 First-Pass Intents

Global/sidebar branch intents:

- `TopMenuChanged(choice)`
- `SettingsMenuChanged(choice)`

Contact branch intents:

- `ContactChosen(contactId)`
- `ChooseAnotherContact()`
- `ContactHandleSelected(contactId, handleId)`
- `ContactMessageScopeChanged(contactId, scope)`

Message branch intents:

- `HeatMapMonthFocused(contactId, monthAnchor)`
- `RecoveredMonthFocused(contactId, monthAnchor, onlyNoHandleFromMe)`

Handles/unfamiliar-sources intents:

- `StrayHandleFilterChanged(filter)`
- `StrayHandleModeChanged(mode)`
- `StrayHandleOpened(handleId)`
- `StrayHandleDismissed(normalizedHandle)`
- `StrayHandleRestored(normalizedHandle)`

Settings/action intents:

- `SettingsActionChosen(choice)`
- `ReimportDataRequested()`
- `SendLogsRequested()`

### 6.3 Dispatch Rules

Essentials action dispatch must:

- receive an intent
- receive essentials-owned dispatch context when rack replacement or panel target
  selection depends on sidebar position
- map the intent to a canonical flow state transition or sanctioned service call
- perform all provider interactions centrally

Feature code must never hold:

- callback closures
- notifier references
- cassette indices
- widget event handlers

---

## 7. Suggested Essentials Rendering Structure

Suggested new responsibilities under `lib/essentials/sidebar/`:

### 7.1 Domain / Contract

- `domain/sidebar_body_model.dart`
- `domain/sidebar_action_intent.dart`
- `domain/sidebar_body_option.dart`
- `domain/sidebar_list_item_model.dart`

### 7.2 Application

- `application/sidebar_action_dispatcher.dart`
- `application/sidebar_body_model_coordinator.dart`

### 7.3 Presentation

- `presentation/renderers/sidebar_body_renderer.dart`
- `presentation/renderers/sidebar_dropdown_renderer.dart`
- `presentation/renderers/sidebar_segmented_control_renderer.dart`
- `presentation/renderers/sidebar_action_renderer.dart`
- `presentation/renderers/sidebar_list_renderer.dart`
- `presentation/renderers/sidebar_hero_renderer.dart`
- `presentation/renderers/sidebar_heatmap_renderer.dart`

Important:

- features should not import any renderer directly
- only essentials composition code should invoke these renderers

---

## 8. Migration Matrix (First Pass)

This is the initial mapping from current sidebar cassette outputs to the target
body model system.

### 8.1 Sidebar Utilities

- top chat menu -> `dropdown` + `TopMenuChanged`
- settings top menu -> `dropdown` + `SettingsMenuChanged`

### 8.2 Contacts

- contact chooser -> likely `list` or `dropdown` depending on final UX decision
- contact hero summary -> `hero`
- message scope toggle -> `segmentedControl` + `ContactMessageScopeChanged`
- handle filter -> `dropdown` + `ContactHandleSelected`
- contact selection control -> `action` + `ChooseAnotherContact`

### 8.3 Contacts Info / Settings

- chosen contact info -> `info`
- display name info -> `info`
- actions info -> `info`
- reimport data info -> `info`
- actions submenu -> `dropdown` + `SettingsActionChosen`

### 8.4 Messages

- heatmap -> `heatMap` + `HeatMapMonthFocused`
- messages info cards -> `info`

### 8.5 Handles

- unfamiliar-sources type switcher -> `segmentedControl` + `StrayHandleFilterChanged`
- unfamiliar-sources mode switcher -> `dropdown` + `StrayHandleModeChanged`
- unfamiliar-sources review list -> `list` with `reservedGutter`
- unmatched handles list -> probably `list`
- stray phones / stray emails legacy list cassettes -> fold into canonical `list`

### 8.6 Handles Settings / Info

- manual linking settings -> likely `list` plus `action`, possibly a bounded composite
- spam management -> likely `list` and `segmentedControl`
- info cassettes -> `info`

---

## 9. Immediate Refactor Sequence

Recommended implementation order:

1. Introduce `SidebarActionIntent`
2. Introduce `SidebarBodyModel` family
3. Create essentials-owned body renderers for dropdown, segmented control,
   action, info, and list
4. Migrate one vertical slice completely
5. Remove feature widget builders for migrated slice
6. Remove cassette index from migrated slice
7. Repeat by feature family

Recommended proving slice:

- unfamiliar-sources / handles branch

Why:

- exercises dropdown
- exercises segmented control
- exercises list with gutter
- exercises selection and row actions
- exercises center-panel navigation intents

---

## 10. Decision Notes

The following decisions are intentional in this first pass:

- The catalog is intentionally small.
- Hero content remains its own body type for now, even though it is currently
  used in only one place.
- Dropdown must have one renderer source app-wide for sidebar use.
- “List with gutter” is a list variant, not a special feature widget.
- Heat map is named explicitly instead of hiding behind a generic
  visualization category.
- Action dispatch is essentials-owned from the first migration step.
- Composite bodies are allowed only as a bounded escape hatch, not a default.

If a new feature cannot fit the catalog, that should trigger a contract review,
not a one-off widget.