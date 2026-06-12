---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-06-06
source_of_truth: code
links:
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../25-ONBOARDING-AND-ARCHIVE/00-overview.md
tests: []
---

# Database Health Audit

This folder documents the implemented `DatabaseHealthAuditService` and its support-bundle integration.

Use it when you need to understand:

- what the Phase 1 audit currently inspects
- how `database_health.json` is assembled
- which databases are audited
- how the support bundle export path invokes the audit
- which limitations are intentional in the current implementation

## Canonical Docs

- [`00-overview.md`](00-overview.md) - Implemented architecture, report shape, and current Phase 1 scope
- [`10-support-bundle-integration.md`](10-support-bundle-integration.md) - Export path, trigger points, bundle contents, and failure behavior

## Current Status

- **Implemented phase:** Phase 1 only
- **Output artifact:** `database_health.json`
- **Invocation path:** support bundle export
- **Privacy model:** aggregate-only; no raw database copies; no row-level sampling
- **Current DB scope:** source-scoped import, conversation graph, overlay,
  retained archive-source metadata, and retained historical reference storage

## Important Constraints

- The audit reads app-owned graph databases through provider-managed
  connections and retained storage through explicit read-only diagnostic
  boundaries.
- The audit service remains service-layer only and does not know about UI or presentation.
- Overlay cross-database relationship checks are intentionally deferred beyond Phase 1.
- Phase 2 and Phase 3 remain out of scope for the implemented system.
