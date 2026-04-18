# Settings Menu Semantics

## Purpose

Define the semantic behavior of the Settings top menu.

This document formalizes the distinction between:

- persistent settings contexts
- transient one-off actions

It also establishes how each integrates with:

- `SidebarActionDispatcher`
- global flow state
- cassette rendering

This behavior is intentional and enforced. It is not incidental UI behavior.

---

## Core Principle

The Settings top menu is primarily a context selector, with support for transient commands.

Not all menu choices represent a persistent state.

---

## Two Types of Menu Actions

Every actionable Settings menu item must be classified as one of the following.

### 1. Persistent State

Represents an ongoing settings context.

Examples:

- Appearance
- Typography (future)
- Notifications (future)

### 2. Transient Action

Represents a one-off operation.

Examples:

- Send logs...
- Reset message data...
- Export diagnostics...

---

## Behavioral Contract

### Persistent State

When a persistent state item is selected:

- The selected label remains visible in the menu chrome.
- The selection defines the current sidebar context.
- The sidebar renders a stable cassette topology.
- The user remains in that settings mode until changed.

This mirrors behavior already established in Messages:

- menu selection -> ongoing state -> deterministic sidebar + center panel

### Transient Action

When a transient action is selected:

- The menu does not retain the selected label.
- The menu either:
    - immediately reverts to placeholder text, or
    - never adopts the action label as selected state.
- A temporary cassette is introduced representing the action.

That cassette:

- contains its own heading, which is required
- contains explanatory text
- contains one or more explicit action controls, such as buttons

After resolution, whether confirm or cancel:

- the cassette is removed
- the sidebar returns to a neutral state
- the menu shows: "Choose setting or action"

---

## Menu Label Semantics

The Settings menu label has a strict meaning.

If a label is displayed, it represents the current persistent settings context.

Therefore:

- persistent state -> label is shown
- transient action -> label is not shown

The placeholder text, "Choose setting or action", represents:

- no active persistent context
- no active transient flow

---

## Cassette Responsibility

### Persistent State

- May render multiple cassettes.
- May omit redundant headings because the menu already provides context.
- Represents stable, navigable UI.

### Transient Action

- Must render as a self-contained cassette.
- Must include:
    - a heading
    - explanatory content
    - explicit user choices

The cassette owns the interaction lifecycle.

---

## Non-Modal Requirement

Transient actions must not introduce modal behavior.

Specifically:

- the top menu must remain usable
- the sidebar must not freeze
- the user must not be forced into a blocking interaction

All flows remain sidebar-local and non-blocking, even when confirmation is required.

---

## Architectural Flow

### Persistent State

```text
menu selection
-> semantic action dispatched
-> global flow state updated
-> cassette topology derived
-> sidebar renders stable context
```

### Transient Action

```text
menu selection
-> semantic action dispatched
-> transient cassette added to stack
-> user interacts with cassette
-> action resolves (confirm or cancel)
-> transient cassette removed
-> sidebar returns to neutral
```

---

## Required Menu Model Extension

Settings menu actions must include semantic classification.

`SettingsMenuRow.action` must include:

- `label`
- `actionId`
- `semantics: persistentState | transientAction`

This classification drives:

- menu label behavior
- cassette lifecycle
- flow state persistence

---

## Rendering Rules Summary

| Behavior | Persistent State | Transient Action |
| --- | --- | --- |
| Menu label persists | Yes | No |
| Defines sidebar context | Yes | No |
| Requires cassette title | Optional | Required |
| Lifecycle | Ongoing | Temporary |
| Clears after completion | No | Yes |

---

## Anti-Patterns

The following are incorrect and must not be implemented:

- Treating all menu items as persistent selections
- Leaving transient actions as the displayed menu label
- Freezing the menu during action flows
- Modeling transient actions as global state
- Rendering transient actions as multiple chained cassettes when they represent a single semantic unit
- Omitting a heading in transient action cassettes

---

## Design Intent

This system ensures that:

- the menu remains semantically meaningful
- sidebar state remains predictable
- transient operations do not pollute global state
- UI remains calm and non-modal
- features cannot drift into inconsistent behavior

---

## TL;DR

The Settings menu contains two kinds of actions:

- persistent states -> remain selected and define sidebar context
- transient actions -> open temporary cassettes and do not persist

Only persistent states appear as the selected menu value.