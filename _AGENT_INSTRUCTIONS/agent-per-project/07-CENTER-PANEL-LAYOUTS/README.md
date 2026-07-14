---
tier: project
scope: center-panel-layouts
owner: @rob
last_reviewed: 2026-07-14
source_of_truth: doc
links:
  - ../05-COLOR-AND-TYPOGRAPHY-THEMING/05-dark-mode-theming.md
  - ../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
---

# Center Panel Layouts

This folder defines the visual and structural rules for MessageLens center-panel report surfaces.

Use these docs when a feature needs to explain system state through a center-panel control surface, audit panel, trust report, infographic, or summary dashboard.

## Scope

- Row composition for report-style surfaces
- How hero sections, evidence panels, notes, and compact metadata should be arranged
- How layout decisions relate to theming and ViewSpec-based panel routing

## What belongs here

- Rules for full-width versus paired rows
- Equal-height requirements for paired evidence cards
- Guidance for compact notes, metadata, and explanatory sections
- Principles for center-panel density, hierarchy, and infographic clarity

## What does not belong here

- Sidebar cassette layout rules
- Cross-column vertical alignment between sidebar, center panel, and end panel
- Theme token definitions
- Feature-specific business meaning
- ViewSpec routing mechanics

Those concerns belong respectively in:

- `../08-SIDEBAR-LAYOUTS/`
- `../09-CROSS-COLUMN-LAYOUT/`
- `../05-COLOR-AND-TYPOGRAPHY-THEMING/`
- feature-local docs under `../40-FEATURES/` or `../45-NEW-FEATURE-ADDITION/`
- `../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md`

## Canonical docs

- [`00-center-panel-control-panels-and-infographics.md`](00-center-panel-control-panels-and-infographics.md)
