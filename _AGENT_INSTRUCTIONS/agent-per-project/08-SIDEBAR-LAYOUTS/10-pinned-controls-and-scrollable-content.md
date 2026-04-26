---
tier: project
scope: sidebar-pinned-scroll
owner: @rob
last_reviewed: 2026-04-26
source_of_truth: doc
links:
  - ./README.md
  - ./00-sidebar-cassettes-controls-and-info-cards.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
  - ../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md
tests: []
---

# Pinned Controls Versus Scrollable Content

This document captures the layout principles for splitting a sidebar surface into pinned controls and scrollable content.

The goal is to preserve orientation and control access without turning the sidebar into two competing layouts.

## Core idea

Pinned content should establish context or keep an important control continuously available.

Scrollable content should carry the variable-length branch body.

The split should feel intentional:

- pinned content anchors the branch
- scrollable content carries exploration

It should not feel like two unrelated sidebars stacked on top of each other.

## Primary goals

1. Keep the user oriented while scrolling long branch content.
2. Keep high-value controls available without repeating them deep in the branch.
3. Preserve one coherent visual rail from top to bottom.
4. Avoid accidental competition between pinned and scrollable zones.

## What belongs in the pinned zone

Pinned content should be rare and justified.

Good candidates:

- app-level mode controls
- branch identity or current selection context when losing it would be disorienting
- high-frequency filter or scope controls that meaningfully govern the whole scrollable branch
- safety-critical actions that should remain visible throughout the branch

Pinned content should usually be short, stable, and semantically central.

## What belongs in the scrollable zone

Scrollable content should hold the branch material that varies in length or depth.

Good candidates:

- long lists
- drill-in navigation rows
- expandable detail cards
- explanation stacks that can grow with feature state
- evidence or metadata that is helpful but not always needed on screen

If the user can read or interact with the content sequentially, it likely belongs in the scrollable zone.

## Layout principles

### 1. Pin only what must stay visible

Pinned space is expensive in a narrow sidebar.

Every pinned cassette reduces the visible height available to the branch body, so the default should be to scroll unless persistent visibility materially improves the interaction.

### 2. Pinned content should feel lighter than the branch body

Pinned content is an anchor, not a second main event.

It should establish context or control availability without visually overpowering the scrollable branch.

Common failure mode:

- a heavy pinned block with large chrome and multiple controls
- a second heavy scrollable stack beneath it

That makes the sidebar feel crowded before the user even starts scrolling.

### 3. Keep one optical rail across both zones

Pinned and scrollable cassettes should share the same horizontal alignment language.

They should feel like one surface with two behaviors, not two different layout systems.

That means:

- consistent outer rails
- compatible cassette width rules
- compatible title and body alignment
- spacing that suggests continuity rather than a hard visual fracture

### 4. The boundary should be clear but not dramatic

Users should understand that the top content stays put and the lower content scrolls.

But the divider between them should not become a strong visual interruption unless the product explicitly wants a toolbar-like effect.

Subtle boundary signals are usually enough:

- a small separation gap
- a mild surface shift
- a divider line if needed

### 5. Avoid duplicating the same control in both zones

If a control is pinned, do not repeat it lower in the scrollable branch unless there is a compelling reason.

Duplication makes the branch feel poorly organized and raises doubt about which control is canonical.

## When to pin branch context

Pin branch context only when losing that context during scroll would materially harm comprehension.

Examples that may justify pinning:

- a chosen-contact identity card above a very long contact-specific list
- a mode selector that changes the meaning of every item below it
- a search or filter control that the user will likely adjust repeatedly while scanning the list

Examples that usually should not be pinned:

- explanatory prose that can be reread by scrolling upward
- secondary caveats
- decorative summary cards

## Relationship to expansion and `shouldExpand`

The detailed expansion rules live in the sidebar cassette architecture docs, not here.

At the layout level, the practical principle is simple:

- pinned content should generally be intrinsically sized and stable
- scrollable branch content is where expanding and long-running content belongs

If a cassette needs large, flexible height, that is usually a signal that it belongs in the scrollable content zone rather than the pinned zone.

## Composition patterns

### Pinned context + scrollable branch

Use when the user needs a stable reminder of where they are.

Typical order:

1. pinned identity or branch-context cassette
2. scrollable controls, drill-in rows, or lists

### Pinned controls + scrollable results

Use when a stable filter or mode selector governs everything below.

Typical order:

1. pinned control cassette
2. scrollable result or branch content

### Pinned app control + normal branch

Use when an app-level or mode-level control must remain available independent of feature depth.

The pinned control should feel like shell chrome, not a competing feature card.

## Anti-patterns

Avoid these:

- pinning several large cassettes until the scrollable branch is squeezed into a small viewport
- pinning explanatory cards that are only needed once
- mixing unrelated app-level and feature-level controls in one pinned block
- creating a heavy visual divider that makes the sidebar feel split in two
- relying on pinning to compensate for poor branch ordering

## Relationship to architecture docs

This document is about composition and user experience.

It does not define:

- canonical sidebar flow state
- cascade topology
- expansion mechanics
- payload-family contracts

Those mechanics belong in:

- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`
- `../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md`

This doc answers a narrower question:

When the sidebar needs both stable controls and variable-length content, how should the split look and feel?

## Future reference candidates

Useful future examples for this doc:

- long contact-selection surfaces with stable branch context
- filter-driven settings or review sidebars
- any branch that keeps a narrow control rail visible while deeper content scrolls
