---
tier: project
scope: feature-package
owner: agent-per-project
last_reviewed: 2026-07-11
source_of_truth: draft
status: consolidated-exploratory
links:
  - ../05-CONVERSATION-INTENT-ARCHITECTURE/README.md
  - ../06-STRUCTURED-CONVERSATION-RETRIEVAL/README.md
  - ../../40-FEATURES/conversations/README.md
  - ../../95-WALK-UI-TREE/00-STANDARDS/UX_PRINCIPLES.md
  - ../../95-WALK-UI-TREE/00-Registers/DESIGN_LANGUAGE_NOTES.md
tests: []
---

# Conversation Tags

This is the focused feature package for introducing Conversation Tags.

Conversation Tags are user-created semantic labels attached to canonical
Conversation entities. They are intended to help users retrieve, organize, and
rediscover meaningful parts of their communication history without turning
MessageLens into a folder hierarchy.

Tags are one durable **Meaning** form of broader Conversation Intent:

[`../05-CONVERSATION-INTENT-ARCHITECTURE/`](../05-CONVERSATION-INTENT-ARCHITECTURE/)

This package remains focused on tag-specific product behavior and UX. The
Conversation Intent package owns the general architectural seam shared by
Favourites, Tags, Working Sets, Suppressed state, Notes, and future
user-confirmed classifications. Structured Conversation Retrieval owns the
future retrieval grammar that may consume tags as tokens.

This package is not an implementation task. It defines product and
architectural direction only.

## Package Contents

- [`PROPOSAL.md`](PROPOSAL.md) - product goal, rationale, scope, and proposed
  tag-specific direction.
- [`DESIGN_NOTES.md`](DESIGN_NOTES.md) - tag-specific UX and product design
  considerations.
- [`CHECKLIST.md`](CHECKLIST.md) - phased planning and completion checklist.
- [`TESTS.md`](TESTS.md) - future validation strategy.
- [`IMPLEMENTATION_READINESS_AUDIT.md`](IMPLEMENTATION_READINESS_AUDIT.md) -
  repository-aware audit of current seams and the recommended first
  implementation slice.

## Governing Principles

- Tags are not folders.
- Tags are durable user-authored Meaning intent.
- Tags describe what a Conversation means to the user.
- Tags should remain distinct from Favourites, Working Sets, Suppressed state,
  and Notes.
- Tags should support retrieval and discovery.
- Tags should appear consistently wherever the Conversation appears.

## Status

Consolidated exploratory feature specification. Do not implement until the tag
product questions have been reviewed and an implementation plan is explicitly
approved.
