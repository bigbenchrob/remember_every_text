---
tier: project
scope: source-scoped-migration
owner: agent-per-project
last_reviewed: 2026-06-26
source_of_truth: doc
links:
  - ./30-INVARIANTS.md
  - ./49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md
  - ./64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md
  - ./65-SOURCE-SCOPED-SS-GRAPH-CHECKPOINT.md
tests: []
---

# Source-Scoped Migration Strategy

The source-scoped architecture should migrate into the existing app incrementally. It must not create a parallel replacement app tree.

## Core Rule

Do not build a `lib/new/` app.

Do not create parallel feature trees such as:

- `features/search_ss/`
- `features/contacts_ss/`
- `features/messages_ss/`
- `features/conversations_ss/`

The migration model is one app with progressively replaced data spines, provider-level switches, and feature-by-feature adoption.

## Architecture Spine Placement

Add new architecture spines beside legacy essentials when the responsibility is app-wide infrastructure.

Examples:

- Retired `essentials/db_importers/` must not return. Source-scoped import
  belongs in `essentials/source_scoped_import/`; graph lifecycle belongs in
  `essentials/conversation_graph/`; retired-file diagnostics belong in
  `essentials/db/`.
- `essentials/source_scoped_import/` is the source-scoped import semantics spine.
- `essentials/db/` owns centralized physical database provider construction,
  database filename identity, readiness probes, and retired-file diagnostics.
- `essentials/conversation_graph/` is the source-scoped working graph,
  projection, lifecycle, and graph-read spine.

Do not bury app-wide source-scoped infrastructure inside one feature folder.

Do not keep production-targeted source-scoped code permanently inside proof-only folders such as `incremental_update_ss/`.

## Feature Placement

Existing features remain existing features.

Examples:

- `features/search/`
- `features/contacts/`
- `features/conversations/`
- `features/messages/`

When a legacy feature needs source-scoped behavior, add implementation variants inside the existing feature folder rather than creating a sibling feature.

Example:

```text
features/search/application/
  search_provider.dart
  legacy/
  ss/
```

The feature boundary remains stable while its implementation can migrate behind that boundary.

Conversation note: `features/conversations/` is the canonical user-facing
Conversation feature boundary. The older `features/chats/` feature boundary has
been retired and must not be reintroduced for user-facing Conversation
behavior.

## Provider Switch Points

Public providers are the switch points.

Feature callers should depend on stable public providers, not directly on legacy or source-scoped implementations.

Preferred shape:

```text
feature caller
-> public feature provider
-> selected implementation
   -> legacy spine
   -> source-scoped spine
```

This keeps adoption reversible and allows feature-by-feature rollout.

Do not scatter conditional source-scoped branching throughout UI widgets or unrelated application services.

## Migration Model

The intended migration path is:

1. Preserve the existing app surface.
2. Introduce source-scoped infrastructure spines beside legacy essentials.
3. Add source-scoped implementation variants inside existing feature folders.
4. Route public providers to legacy or source-scoped implementations.
5. Adopt source-scoped behavior one feature at a time.
6. Remove legacy implementation paths only after their callers have been fully migrated and verified.

This is not a rewrite. It is a controlled replacement of data spines and implementation variants under stable feature surfaces.

## Source-Scoped Graph Principles

The source-scoped architecture carries these invariants into the migration:

- `ss_id` is canonical working-row identity for source-derived projected rows.
- `import_ss` stores source facts and provenance.
- `working_ss` stores the lean app graph.
- Working graph relationships use `ss_id` endpoints.
- Source-local relationship endpoints project mechanically into source-scoped working identities.
- GUIDs are metadata or bridge fields, not canonical identity.
- Semantic deduplication, grouping, and merge views must live above canonical row identity.

## Non-Goals

Do not use this migration to:

- create a new app tree
- duplicate every feature into `_ss` folders
- redesign UI navigation
- introduce broad abstraction layers before callers need them
- collapse legacy and source-scoped responsibilities into mixed implementations
- treat GUIDs as canonical identity

The goal is a careful, incremental migration from legacy data spines to source-scoped data spines while preserving the existing app structure.
