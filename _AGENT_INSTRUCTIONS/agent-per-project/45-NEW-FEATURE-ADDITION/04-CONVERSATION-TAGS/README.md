---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: draft
status: exploratory
links:
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Conversation Tags

This is the exploratory work package for introducing Conversation Tags.

Conversation Tags are user-created semantic labels attached to canonical
Conversation entities. They are intended to help users retrieve, organize, and
rediscover meaningful parts of their communication history without turning
MessageLens into a folder hierarchy.

This package is not an implementation task. It defines product and
architectural direction only.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - product goal, rationale, scope, and proposed
  direction.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - architectural and UX considerations.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and completion checklist.
- [`TESTS.md`](TESTS.md) - future validation strategy.

## Governing Principles

- There is only one Conversation.
- Tags are user intent and belong in overlay.
- Tags attach to stable Conversation identity.
- Tags are not folders.
- Tags should support retrieval and discovery.
- Tags should be reusable across future Conversation lenses, Search,
  Discovery, Working Sets, and saved investigations.

## Status

Exploratory. Do not implement until the proposal has been reviewed and an
implementation plan is explicitly approved.
