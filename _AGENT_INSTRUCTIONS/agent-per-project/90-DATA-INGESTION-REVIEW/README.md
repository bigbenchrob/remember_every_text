---
tier: project
scope: data-ingestion-review
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: index
links:
  - ./00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ./WORKSTREAMS/README.md
  - ./WORKSTREAMS/00-WORKSTREAMS-ORGANIZATION.md
  - ./global-project-seed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../25-ONBOARDING-AND-ARCHIVE/README.md
  - ../10-DATABASES/00-all-databases-accessed.md
tests: []
---

# Data Ingestion Review And Production Readiness

This folder coordinates the production-readiness review of MessageLens
onboarding, archival data ingestion, archive integrity, validation, and
production health.

Workstream 1 has implemented the non-production archive boundary through
checkpoint/tooling hardening. The existing production archive has not been
adopted. See the
[`completion report`](WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/COMPLETION-REPORT.md)
before beginning later ingestion work.

Start with:

- [`00-PRODUCTION-READINESS-MASTER-PLAN.md`](00-PRODUCTION-READINESS-MASTER-PLAN.md)
  — authoritative project purpose, safety contract, shared concerns,
  workstreams, and completion criteria.
- [`global-project-seed.md`](global-project-seed.md) — original design seed.
  It is retained as source context; the master plan is authoritative.
- [`WORKSTREAMS/README.md`](WORKSTREAMS/README.md) — active workstream index
  and dependency order.
- [`WORKSTREAMS/00-WORKSTREAMS-ORGANIZATION.md`](WORKSTREAMS/00-WORKSTREAMS-ORGANIZATION.md)
  — required organization and historical-preservation convention.

## Planned Workstream Packages

Focused subfolders will be created as their work begins:

```text
WORKSTREAMS/
  01-PRODUCTION-DATA-PROTECTION/
  02-ONBOARDING-REVIEW/
  03-HISTORICAL-MESSAGES-IMPORT/
  04-ARCHIVED-MESSAGELENS-IMPORT/
  05-ATTACHMENT-INTEGRITY/
  06-IMPORT-VALIDATION/
  07-PRODUCTION-HEALTH/
```

They share the master plan's development/production boundary, preservation
rules, provenance model, operation lifecycle, and evidence requirements.
Individual workstreams retain their own analysis, decisions, plans, tests, and
completion reports.

The original seed used conception-order numbering and `10`-increment folder
names. The authoritative workstream structure instead uses dependency order:
Production Data Protection is Workstream 1 because it establishes the safety
boundary required by every later production operation.

## Relationship To Current Architecture

This folder governs the project and its target safety contract. Current
runtime behavior remains documented in:

- [`20-DATA-IMPORT-MIGRATION/`](../20-DATA-IMPORT-MIGRATION/)
- [`25-ONBOARDING-AND-ARCHIVE/`](../25-ONBOARDING-AND-ARCHIVE/)
- [`10-DATABASES/`](../10-DATABASES/)
- [`50-ENVIRONMENT-SAFETY/`](../50-ENVIRONMENT-SAFETY/)

When a workstream ships, it must update the canonical owner of the resulting
behavior. Sequence 90 must not become a parallel architecture tree.

The retired use-case illustration material formerly stored at this sequence
number is preserved under
[`archive/legacy-use-case-illustrations/`](archive/legacy-use-case-illustrations/)
for historical reference. It does not define this review.
