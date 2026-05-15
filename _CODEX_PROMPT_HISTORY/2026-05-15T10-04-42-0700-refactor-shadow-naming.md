---
created_at: 2026-05-15T10:04:42-07:00
title: "Refactor 'shadow' naming"
tags: []
source: codex_prompt_history.html
---

# Refactor 'shadow' naming

## Prompt

```text
Architectural naming alignment refactor before additional importer work.

Context

The shadow incremental-update pipeline is evolving from:
experimental narrow executors

toward:
production-shaped importer architecture.

We now have:

- MessageImporter-style abstraction
- ImporterDescriptor metadata
- source-scoped relationship preservation
- validated shadow import/migration loop
- comparative validation
- endurance logging
- dev observability panel

As we prepare to add prerequisite-bearing importers (handles/chats/etc), we want to prevent unnecessary future refactoring.

Important architectural clarification

We now distinguish between:

1. portable production-shaped architectural components
and
2. explicitly shadow/dev orchestration surfaces

Portable components should NOT contain “shadow” in their names if they are intended to eventually migrate toward production ownership.

Shadow/dev orchestration surfaces SHOULD retain shadow/dev naming.

Examples that SHOULD remain shadow/dev named:

- ShadowImportExecutionOrchestrator
- ShadowMigrationExecutionOrchestrator
- shadow endurance logging
- shadow status panel
- shadow polling orchestration
- macos_import_shadow.db
- working_shadow.db
- dev DB providers

Examples that SHOULD become production-shaped:

- MessageImporter
- MessageImportResult
- MessageImporterDescriptor
- future HandleImporter
- future ChatImporter

Task

Refactor ONLY the existing message importer layer to remove unnecessary “shadow” naming from portable architectural components.

Scope

Rename/refactor ONLY:

ShadowMessageImporter
ShadowMessageImportResult
related provider/file names directly tied to the importer abstraction

Suggested resulting names:

MessageImporter
MessageImportResult
message_importer.dart
message_importer_provider.dart

Do NOT rename:

- ShadowImportExecutionOrchestrator
- shadow polling orchestration
- shadow migration orchestration
- shadow comparison systems
- shadow/dev databases
- endurance logging
- dev panel
- comparison semantics

The importer remains shadow-executed because the orchestrator/environment is shadow, not because the importer itself is inherently shadow-specific.

Architectural intent

The importer should become:

production-shaped behavior
+
injected environment/database target

rather than:

shadow-specific behavior hardcoded into names.

The database/provider layer already distinguishes shadow vs production execution targets.

Constraints

DO NOT:
- change runtime behavior
- alter polling semantics
- alter comparative validation
- alter endurance logging
- alter migration behavior
- introduce production ownership
- rename unrelated orchestration systems
- build importer graph execution
- add topological sorting

DO:
- preserve tests
- preserve architecture symmetry
- preserve explicit boundaries
- keep the refactor narrow and mechanical where possible

Tests

Update and rerun focused tests:
- importer descriptor tests
- import execution orchestrator tests
- any importer-specific tests affected by renaming

Verification

Run:
- dart analyze on changed files
- focused flutter tests for importer/orchestrator slices

Report back with:
- files renamed
- symbols renamed
- which “shadow” names intentionally remain
- confirmation that runtime behavior is unchanged
```
