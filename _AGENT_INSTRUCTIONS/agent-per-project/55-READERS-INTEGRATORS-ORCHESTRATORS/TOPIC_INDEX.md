---
tier: project
scope: navigation
owner: agent-per-project
last_reviewed: 2026-07-09
source_of_truth: doc
links:
  - ./README.md
  - ./69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - ./85-RELEASE-EXIT-PLAN.md
tests: []
---

# RIO Topic Index

This folder combines durable Reader/Integrator/Orchestrator guidance with a
long graph-migration record. Use this topic index to find the right document
without assuming that later file numbers are always more current instructions.

## Current Decision Gate

| Need | Read |
| --- | --- |
| Decide whether to do more architecture hardening | [`85-RELEASE-EXIT-PLAN.md`](85-RELEASE-EXIT-PLAN.md) |
| Understand current project mode | [`../01-PROJECT/05-CURRENT-STATE.md`](../01-PROJECT/05-CURRENT-STATE.md) |

## Durable RIO Architecture

| Topic | Read |
| --- | --- |
| RIO vocabulary | [`00-TERMINOLOGY.md`](00-TERMINOLOGY.md) |
| Responsibility boundaries | [`10-ARCHITECTURE-CONTRACT.md`](10-ARCHITECTURE-CONTRACT.md) |
| Dependency direction | [`20-ALLOWED-DEPENDENCIES.md`](20-ALLOWED-DEPENDENCIES.md) |
| Core invariants | [`30-INVARIANTS.md`](30-INVARIANTS.md) |
| Stage controller / pipeline orchestrator pattern | [`49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md`](49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md) |

## Source-Scoped Graph And Semantic Preservation

| Topic | Read |
| --- | --- |
| Topology projection | [`60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`](60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md) |
| Source-scoped row identity | [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md) |
| Legacy semantic parity audit | [`67-SS-LEGACY-PARITY-AUDIT.md`](67-SS-LEGACY-PARITY-AUDIT.md) |
| Message semantic preservation | [`68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md`](68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md) |

## Message Evidence

| Topic | Read |
| --- | --- |
| Canonical message evidence spine | [`69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`](69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md) |
| Graph message presentation migration audit | [`../45-NEW-FEATURE-ADDITION/01-CONVERSATION-TOPOLOGY-PRESENTATION/GRAPH_MESSAGE_EVIDENCE_SPINE_AUDIT.md`](../45-NEW-FEATURE-ADDITION/01-CONVERSATION-TOPOLOGY-PRESENTATION/GRAPH_MESSAGE_EVIDENCE_SPINE_AUDIT.md) |

## Graph Migration History

These documents explain how the graph migration was planned, executed, and
reviewed. They are audit evidence, not a fresh checklist by default.

| Topic | Read |
| --- | --- |
| Completion roadmap | [`70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md`](70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md) |
| Legacy dependency matrix | [`71-LEGACY-DEPENDENCY-MATRIX.md`](71-LEGACY-DEPENDENCY-MATRIX.md) |
| Choke points and blockers | [`72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md`](72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md) |
| Execution checklist | [`73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md`](73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md) |
| Interim progress | [`78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md`](78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md), [`80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md`](80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md) |
| Independent review | [`79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md`](79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md) |

## Overlay, Retained Storage, Archive, And Recovery

| Topic | Read |
| --- | --- |
| Overlay identity keys | [`74-OVERLAY-IDENTITY-KEY-AUDIT.md`](74-OVERLAY-IDENTITY-KEY-AUDIT.md) |
| Archive/recovery identity | [`75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md`](75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md) |
| Recovered/orphan message graph identity | [`76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md`](76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md) |
| Recovered-message parity gate | [`77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md`](77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md) |
| Retained legacy storage | [`81-LEGACY-STORAGE-RETENTION-REGISTER.md`](81-LEGACY-STORAGE-RETENTION-REGISTER.md) |
| Source-scoped archive import cutover | [`82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md`](82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md) |
| Legacy database retirement | [`83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`](83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md) |
| Attachment reachability | [`84-ATTACHMENT-REACHABILITY-AUDIT.md`](84-ATTACHMENT-REACHABILITY-AUDIT.md) |

## Retired Or Historical Pilot Material

These files are useful for context but should not be treated as current
implementation plans unless a current document explicitly points back to them.

- `40-SHADOW-IMPLEMENTATION-STRATEGY.md`
- `45-SHADOW-PIPELINE-EXPANSION-STRATEGY/`
- `48-SHADOW-IMPORTER-GRAPH-AND-EXECUTION-STRATEGY/`
- `50-INCREMENTAL-UPDATE-PILOT.md`
- `62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md`
- `65-SOURCE-SCOPED-SS-GRAPH-CHECKPOINT.md`
- `66-SS-MIGRATION-STRATEGY.md`
- `72-PLAN-REDIRECTION.md`
- `98-UI-COURSE-CORRECTION-AND-PRINCIPLES.md`
- `99-ROADMAP/`
- `SOURCE-SCOPED-IDENTITY-AND-RELATIONSHIP-STRATEGY/`
