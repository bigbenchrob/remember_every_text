# 42 — Spec System

This folder is the authoritative home for the app's spec-driven architecture.

It defines how user intent and global state must move through explicit specs, coordinators, resolvers, payloads, view models, and rendering surfaces.

Canonical pattern:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

## Start here

Read [GUIDED-OVERVIEW.md](GUIDED-OVERVIEW.md) first. It gives the reading paths for new agents, sidebar work, panel work, feature-boundary questions, and invariant checks.

Then read:

1. [CANONICAL-ARCHITECTURE/00-overview.md](CANONICAL-ARCHITECTURE/00-overview.md)
2. the relevant canonical surface or responsibility document
3. [CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md](CANONICAL-ARCHITECTURE/90-invariants-and-contracts.md)

Use [REFERENCE/](REFERENCE/) only after the canonical layer. Reference material preserves deeper detail and historical nuance, but the canonical architecture docs are the preferred source for implementation decisions.

## Folder structure

* [GUIDED-OVERVIEW.md](GUIDED-OVERVIEW.md)
  Short navigational guide and reading paths.
* [CANONICAL-ARCHITECTURE/](CANONICAL-ARCHITECTURE/)
  Curated, authoritative architecture docs.
* [REFERENCE/](REFERENCE/)
  Legacy and deep-dive documents organized by topic.

## Interpretation rule

When a reference document and a canonical architecture document overlap, follow the canonical architecture layer unless the canonical document explicitly defers to the reference material for a more specific rule.

New work must not introduce patterns where coordinators return widgets or where rendering logic crosses the data boundary.

## What this folder governs

This documentation covers:

* cross-surface specs
* sidebar cassette specs
* panel view specs
* feature handling of specs
* coordinated rendering across sidebar, panel, onboarding, and related surfaces
* stable vs ephemeral projection rules
* architectural invariants that keep these systems clean

This folder is not a backlog, feature-planning area, or substitute for feature-specific charters under `40-FEATURES/`.
