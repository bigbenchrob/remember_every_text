---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2026-06-08
source_of_truth: doc
links:
  - ./01-aggregate-boundaries.md
  - ../30-ESSENTIALS/README.md
  - ../40-FEATURES/README.md
  - ../42-SPEC-SYSTEM/README.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
tests: []
---

# Architecture Overview

This document is the project-level architecture map. It describes current
ownership boundaries and points to the authoritative subsystem docs. Do not use
older generic DDD examples as evidence of current code structure.

The canonical description of cross-surface behavior and spec-driven
architecture lives in `../42-SPEC-SYSTEM/`. This document is a high-level map
and must not be used to infer implementation patterns that contradict that
layer.

## Current Code Structure

```text
lib/
├── essentials/                  # App-level systems and shared infrastructure
├── features/                    # Business feature modules and feature content
├── domain_driven_development/   # Shared DDD helpers
├── core/                        # Shared utilities
├── config/                      # Theme/config support
└── constants/                   # Shared constants
```

Current feature modules include `address_book_folders`, `attachments`, `chats`,
`contacts`, `environment_readiness`, `handles`, `messages`, `reactions`,
`settings`, and `sidebar_utilities`.

Current essentials areas include navigation, sidebar, search, onboarding, db,
source-scoped import, conversation graph, retained compatibility import/
projection, logging, window state, config, debug, services, tooltips, and shared
contacts infrastructure.

## Essentials vs Features

Essentials owns app-level orchestration:

- global flow state
- sidebar cassette rack topology and shared sidebar chrome
- panel stack ownership and `ViewSpec` routing
- onboarding gate state and overlay lifecycle
- shared search service and graph search/evidence selection
- database providers, source-scoped import, graph build, and retained
  compatibility orchestration
- logging, window state, app shell, and cross-cutting services

Features own domain content:

- feature-owned inner specs
- feature data resolution and repositories
- payloads/view models for approved feature surfaces
- terminal feature rendering inside essentials-owned surface contracts

Path location alone does not prove architectural ownership. Some contact-related
logic is shared infrastructure under essentials; other contact-related logic is
feature-owned under `lib/features/contacts`.

## Spec-Driven Surface Architecture

For sidebar, panel, onboarding, and related surfaces, the canonical architecture
is defined under `../42-SPEC-SYSTEM/`.

Canonical pipeline:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

New work must not introduce widget-returning coordinator patterns or move
rendering logic across the data boundary. Older panel code still has a
documented migration boundary; treat that as transitional, not permission for
new work.

## Data Pipeline

The ordinary app-facing data pipeline is:

```text
macOS Messages + AddressBook
→ macos_import_ss.db
→ working_ss.db / conversation graph
→ provider merge with user_overlays.db
→ specs / payloads / rendering
```

The old retained `macos_import.db` -> `working.db` projection implementation is
retired from active app code. Fresh `macos_import.db` stores historical
archive-source metadata, and existing `working.db` files are retained
file/schema inventory for reset cleanup and read-only diagnostics. Source
import, graph build, and retained storage details belong in
`../20-DATA-IMPORT-MIGRATION/`.
Database boundaries and provider access rules belong in `../10-DATABASES/`.

Hard boundaries:

- source-scoped import writes only to `macos_import_ss.db`
- graph projection writes only to `working_ss.db`
- archive-source metadata writes only to overlay-owned services
- user intent writes only to `user_overlays.db`
- providers merge graph projection + overlay at read time

## Onboarding And Archive

Onboarding is essentials-owned orchestration. It evaluates environment readiness,
drives the onboarding overlay lifecycle, coordinates graph build actions, and
syncs readiness states into panel surfaces. Retired-file cleanup storage
is not the ordinary onboarding success path.

Attachment archive and deterministic recovery are feature-owned attachment
systems that coordinate with onboarding and the database providers. Archive
metadata lives in overlay; archive files live under the MessageLens app support
directory.

Use `../25-ONBOARDING-AND-ARCHIVE/` for current behavior.

## Naming And Provider Conventions

- Riverpod providers should use project-standard generated-provider patterns.
- Use the current provider names from code and database docs. Ordinary graph
  reads use `driftConversationGraphDatabaseProvider`; source-scoped import uses
  `importDatabaseProvider` from `source_scoped_import`; overlay user intent and
  archive-source metadata use `overlayDatabaseProvider`.
  Retired `macos_import.db` and `working.db` are transitional cleanup file concerns
  and no longer have central app providers.
- Do not invent generic provider names such as `workingDatabaseProvider` or
  `importDatabaseProvider` unless code first introduces them.
- Keep generated files untouched unless running the approved generator.

## Historical Note

Older project docs used generic feature scaffolds such as `_import_and_dbs` and
example files like `import_db.dart`. Those examples are superseded by the
current essentials-owned database, source import, graph build, and retained
compatibility structure. Use this document and the linked subsystem docs for
current placement decisions.
