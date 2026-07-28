---
tier: project
scope: production-readiness-workstreams
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: index
status: current
links:
  - ../00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ./00-WORKSTREAMS-ORGANIZATION.md
  - ./01-PRODUCTION-DATA-PROTECTION/README.md
tests: []
---

# Production Readiness Workstreams

This folder contains the focused architectural investigations that carry out
the MessageLens Production Readiness Master Plan.

Read:

1. [`../00-PRODUCTION-READINESS-MASTER-PLAN.md`](../00-PRODUCTION-READINESS-MASTER-PLAN.md)
   for the shared project contract.
2. [`00-WORKSTREAMS-ORGANIZATION.md`](00-WORKSTREAMS-ORGANIZATION.md) for the
   required notebook structure and promotion rules.
3. The active workstream's `README.md`, then its permanent `00-task.md`.

## Dependency Order

```text
01  Production Data Protection
    establishes which environment and archive may be modified

02  Onboarding Review
    relies on the production boundary

03  Historical Messages Import
04  Archived MessageLens Import
05  Attachment Integrity
06  Import Validation
07  Production Health
```

Folders are created only when work begins. Their numbers express architectural
dependency, not conception date or completion date.

## Active Workstreams

| Workstream | Status | Entry point |
| --- | --- | --- |
| 01 — Production Data Protection | Current-state audit | [`01-PRODUCTION-DATA-PROTECTION/README.md`](01-PRODUCTION-DATA-PROTECTION/README.md) |

The workstream folders preserve investigation history. Shipped architecture
must also be promoted into its permanent canonical documentation owner.
