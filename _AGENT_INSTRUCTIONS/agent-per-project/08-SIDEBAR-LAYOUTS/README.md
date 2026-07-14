---
tier: project
scope: sidebar-layouts
owner: @rob
last_reviewed: 2026-07-14
source_of_truth: doc
links:
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md
tests: []
---

# Sidebar Layouts

This folder defines the visual and structural rules for MessageLens sidebar surfaces.

Use these docs when a feature needs to compose a sidebar branch from navigation cassettes, controls, explanatory info cards, or mixed control-and-context stacks.

## Scope

- vertical rhythm for sidebar cassette stacks
- density and spacing rules for controls, navigation cards, and info cards
- how branch context, controls, and supporting explanation should be ordered
- how visual layout rules relate to, but stay separate from, sidebar flow state and cassette topology

## What belongs here

- layout principles for narrow sidebar surfaces
- rules for section boundaries and card rhythm
- guidance for info-card readability and control alignment
- baseline composition patterns for navigation stacks and explanatory stacks

## What does not belong here

- durable sidebar flow state
- cassette topology and cascade logic
- cross-column vertical alignment and content-start seams shared with center
  and end panels
- feature-specific business meaning
- center-panel report composition
- theme-token definitions

Those concerns belong respectively in:

- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/20-sidebar-cassette-system.md`
- `../42-SPEC-SYSTEM/REFERENCE/54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md`
- `../09-CROSS-COLUMN-LAYOUT/`
- feature-local docs under `../40-FEATURES/` or `../45-NEW-FEATURE-ADDITION/`
- `../07-CENTER-PANEL-LAYOUTS/`
- `../05-COLOR-AND-TYPOGRAPHY-THEMING/`

## Canonical docs

- [`00-sidebar-cassettes-controls-and-info-cards.md`](00-sidebar-cassettes-controls-and-info-cards.md)
- [`10-pinned-controls-and-scrollable-content.md`](10-pinned-controls-and-scrollable-content.md)
- [`20-navigation-row-emphasis-rules.md`](20-navigation-row-emphasis-rules.md)
- [`30-sidebar-action-density-and-destructive-action-spacing.md`](30-sidebar-action-density-and-destructive-action-spacing.md)
- [`40-info-card-typography-and-supplemental-content.md`](40-info-card-typography-and-supplemental-content.md)
- [`50-interaction-state-examples-for-hover-selection-and-disabled-rows.md`](50-interaction-state-examples-for-hover-selection-and-disabled-rows.md)
