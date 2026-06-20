---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-06-20
source_of_truth: code
links:
  - ./README.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# Database Health Audit Overview

This document describes the **implemented** database-health-audit system, not the earlier proposal set under `45-NEW-FEATURE-ADDITION/database-health-audit/`.

## Purpose

`DatabaseHealthAuditService` generates a privacy-safe structural report of the app-owned database environment so developers can inspect table population, relationship integrity, and high-level pipeline health without requesting raw database files.

The output is currently a single Phase 1 artifact:

- `database_health.json`

## Implemented Scope

The current implementation audits these app-owned databases:

- `db-import-ss` (`macos_import_ss.db`)
- `db-graph-working` (`working_ss.db`)
- `db-overlay` (`user_overlays.db`)
- retained `db-import` (`macos_import.db`)
- retained `db-working` (`working.db`)

It does **not** create retained database files as a side effect. It uses
provider-managed instances for active graph/overlay/source-scoped databases
and read-only file inspection for retained historical databases:

- `importDatabaseProvider` from source-scoped import
- `driftConversationGraphDatabaseProvider`
- `overlayDatabaseProvider`
- read-only file inspection for retained `macos_import.db`
- read-only file inspection for retained `working.db`

This preserves the project rule against competing writable connections while
also preventing diagnostics from recreating retained historical storage.

## Service Entry Point

Code location:

- `lib/essentials/db/application/database_health_audit/database_health_audit_service.dart`

Provider:

- `databaseHealthAuditServiceProvider`

The provider is intentionally **non-reactive** for orchestration purposes:

- it resolves the database providers with `ref.read(...)`
- it constructs `DatabaseHealthAuditService`
- it does not watch UI state or presentation-layer concerns

## Main Responsibilities

`DatabaseHealthAuditService` is responsible for:

1. building app/environment metadata
2. enumerating audited databases
3. generating table inventory
4. evaluating curated relationship checks
5. evaluating curated invariant checks
6. generating a compact summary
7. writing `database_health.json` to a caller-supplied output directory

Primary public methods:

- `buildPhase1Report()`
- `writePhase1Report({ required String outputDirectoryPath })`

## Query Architecture

SQL execution is isolated in:

- `lib/essentials/db/application/database_health_audit/database_health_audit_queries.dart`

Shared abstraction:

- `DatabaseHealthQueryLayer`

Concrete adapters:

- `SourceScopedImportDatabaseHealthQueryLayer`
- `ConversationGraphDatabaseHealthQueryLayer`
- `OverlayDatabaseHealthQueryLayer`
- read-only retained SQLite file query layers for `macos_import.db` and
  `working.db`

These adapters normalize query execution across source-scoped import,
conversation-graph Drift, overlay Drift, and retained read-only SQLite files
while keeping orchestration out of the query layer.

Shared query-layer responsibilities include:

- pinging the DB
- checking file existence
- reading `PRAGMA user_version`
- listing tables from `sqlite_master`
- listing columns from `PRAGMA table_info`
- counting rows
- extracting single-column integer PK bounds
- summarizing important columns with null/non-null/distinct counts

## Report Shape

Models live in:

- `lib/essentials/db/application/database_health_audit/database_health_audit_models.dart`

The report includes:

- schema metadata
- app metadata
- environment metadata
- audited database metadata
- `table_inventory`
- `relationship_checks`
- `invariant_checks`
- `summary`
- `errors`

Phase 1 relationship checks currently include source-scoped graph checks, retired storage/reference checks, and counts plus percentages where applicable:

- `matched_percentage`
- `unmatched_parent_percentage`
- `unmatched_child_percentage`

Percentages are omitted when the denominator is zero.

## Table Inventory

Table inventory combines:

- curated expected tables per database
- dynamic discovery from `sqlite_master`

Each entry can include:

- existence
- row count
- PK min/max for simple integer PKs
- important column summaries
- notes about empty or discovered-but-uncurated tables

Sensitive fields are represented only as privacy notes where necessary. The audit does not emit message text, URLs, attachment names, archive paths, or other raw user content.

## Relationship Checks

Relationship checks are defined as curated specs in the service layer, then executed via query-layer SQL.

Each check reports:

- `parent_row_count`
- `child_row_count`
- `matched_row_count`
- `unmatched_parent_row_count`
- `unmatched_child_row_count`
- percentages where defined
- status

Status rules are intentionally simple and deterministic:

- no unmatched rows → `pass`
- zero matches with non-empty participating tables → `fail`
- otherwise → `warning`

## Invariant Checks

Invariant checks are also curated specs.

Each invariant defines:

- a SQL query for evaluated row count
- a SQL query for violation count
- severity
- description

Status rules:

- `evaluated_row_count == 0` → `not_applicable`
- `violation_count == 0` → `pass`
- `violation_count == evaluated_row_count` → `fail`
- otherwise → `warning`

## Current Phase 1 Limitation

The current implementation explicitly records that overlay cross-database relationship checks are deferred.

This appears as an invariant with:

- check key: `overlay_cross_database_relationship_checks_deferred`
- status: `not_applicable`

That limitation is intentional. Phase 1 inventories overlay tables, but does not perform overlay-to-graph or overlay-to-retained-working cross-database relationship diagnostics.

## Privacy and Safety Model

The implemented system preserves these constraints:

- no raw database export
- no row-level sampling
- no copied SQLite files
- no message text or attributed body content
- no contact identity fields
- no attachment filenames or raw paths in the report body

The output is meant to be safe to attach to a support bundle without exposing user-generated content.

## Out of Scope

The following are **not implemented** in the current system:

- Phase 2 failure samples
- Phase 3 sanitized relational snapshot
- overlay cross-database relationship joins
- any UI or presentation layer for browsing audit results

## Related Code

- `lib/essentials/db/application/database_health_audit/database_health_audit_service.dart`
- `lib/essentials/db/application/database_health_audit/database_health_audit_queries.dart`
- `lib/essentials/db/application/database_health_audit/database_health_audit_models.dart`
- `lib/essentials/logging/infrastructure/support_bundle_export_service.dart`
