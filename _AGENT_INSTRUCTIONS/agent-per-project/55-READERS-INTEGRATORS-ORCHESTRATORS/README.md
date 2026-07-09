# 55-READERS-INTEGRATORS-ORCHESTRATORS

## Purpose

This folder defines the architectural responsibility model used to make complex application orchestration more human-comprehensible, testable, observable, and safely evolvable.

The architecture is based on three primary responsibility layers:

```text
Readers
→ Integrators
→ Orchestrators
```

The retired shadow incremental-update pilot validated the fuller execution spine:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation
```

The original `lib/essentials/incremental_update/` shadow implementation has been retired. The validated ideas now continue through source-scoped import, conversation graph projection, graph lifecycle orchestration, and the message evidence spine.

The intent is not architectural novelty for its own sake. The intent is to improve:

- human understanding
- causal traceability
- decomposition of responsibilities
- testability
- observability

## Current Status

This folder contains both durable architectural guidance and a long graph
migration history. Do not treat every numbered document as an active task.

Use [`TOPIC_INDEX.md`](TOPIC_INDEX.md) when looking for a specific topic. It
groups the numbered documents by purpose so readers do not have to infer
currency from file number alone.

Current use:

- For responsibility boundaries, read `00` through `30` plus the specific
  invariant docs linked below.
- For message evidence work, read
  [`69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`](69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md).
- For retained database and attachment reachability questions, read
  [`81-LEGACY-STORAGE-RETENTION-REGISTER.md`](81-LEGACY-STORAGE-RETENTION-REGISTER.md),
  [`83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`](83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md),
  and [`84-ATTACHMENT-REACHABILITY-AUDIT.md`](84-ATTACHMENT-REACHABILITY-AUDIT.md).
- For deciding whether to do more architecture hardening, read
  [`85-RELEASE-EXIT-PLAN.md`](85-RELEASE-EXIT-PLAN.md) first. The default
  answer is now: defer hardening unless it directly unblocks release,
  data-integrity, archive/recovery, onboarding, readiness, or user-visible
  correctness.

The graph migration has crossed from primary project objective into
infrastructure. Current product work normally belongs in release readiness,
archive/recovery verification, onboarding, or the UI/UX walk.

## Reading Flow

Use these documents in this order when working on the source-scoped graph architecture:

1. [`00-TERMINOLOGY.md`](00-TERMINOLOGY.md) - shared vocabulary for Readers, Integrators, Orchestrators, snapshots, semantic state, and decisions.
2. [`10-ARCHITECTURE-CONTRACT.md`](10-ARCHITECTURE-CONTRACT.md) - responsibility boundaries and architectural contract.
3. [`20-ALLOWED-DEPENDENCIES.md`](20-ALLOWED-DEPENDENCIES.md) - permitted dependency direction between architecture layers.
4. [`30-INVARIANTS.md`](30-INVARIANTS.md) - rules that must not be violated while extending the pipeline.
5. [`49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md`](49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md) - validated StageController and PipelineOrchestrator pattern.
6. [`50-INCREMENTAL-UPDATE-PILOT.md`](50-INCREMENTAL-UPDATE-PILOT.md) - historical pilot behavior and validated runtime spine that has since been absorbed into source-scoped graph lifecycle work.
7. [`60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`](60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md) - design options for projecting preserved source topology into working app truth.
8. [`62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md`](62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md) - current audit of ledger-chat to working-chat endpoint resolution.
9. [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md) - source-scoped row identity strategy for multi-source-safe provenance and topology resolution.
10. [`67-SS-LEGACY-PARITY-AUDIT.md`](67-SS-LEGACY-PARITY-AUDIT.md) - audit checklist for preserving hard-won legacy message, chat, contact, and handle semantics while migrating to the SS graph.
11. [`68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md`](68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md) - guardrail and minimal model for preserving message semantics without recreating the legacy message schema.
12. [`69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`](69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md) - canonical message evidence scope, skeleton, hydration, row rendering, and attachment presentation invariant.
13. [`70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md`](70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md) - current graph migration checkpoint, remaining legacy dependencies, completion criteria, and safest roadmap for finishing the graph-based data system.
14. [`71-LEGACY-DEPENDENCY-MATRIX.md`](71-LEGACY-DEPENDENCY-MATRIX.md) - explicit classification of remaining `working.db`, `macos_import.db`, legacy repository, lifecycle, recovery, diagnostic, and deletion-candidate dependencies.
15. [`72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md`](72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md) - leverage-based migration ordering, compatibility bridges, overlay identity audit, and retirement blockers for finishing the graph transition.
16. [`73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md`](73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md) - practical execution checklist for checkpointing, overlay identity, graph-native search, graph-native contact identity, lifecycle orchestration, remaining reads, recovery, and legacy retirement.
17. [`74-OVERLAY-IDENTITY-KEY-AUDIT.md`](74-OVERLAY-IDENTITY-KEY-AUDIT.md) - graph-era overlay identity inventory, bridge strategy, migration order, and tests for preserving user intent while moving ordinary app identity to source-scoped graph ids.
18. [`75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md`](75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md) - graph-era archive/recovery identity strategy for preserving attachment reachability and historical source compatibility.
19. [`76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md`](76-RECOVERED-MESSAGE-GRAPH-IDENTITY-PLAN.md) - recovered/orphan message graph identity plan and retention strategy.
20. [`77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md`](77-RECOVERED-MESSAGE-GRAPH-PARITY-AUDIT.md) - recovered-message parity audit used to gate graph cutover.
21. [`78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md`](78-GRAPH-MIGRATION-PAUSE-AND-REMAINING-WORK.md) - June 2 pause report summarizing graph migration state and remaining work.
22. [`79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md`](79-INDEPENDENT-ARCHITECTURAL-REVIEW-OF-GRAPH-MIGRATION-STATE.md) - independent review snapshot and addendum against Documents 70-78.
23. [`80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md`](80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md) - interim progress report covering graph lifecycle, legacy retirement, and documentation alignment completed after Documents 78-79.
24. [`81-LEGACY-STORAGE-RETENTION-REGISTER.md`](81-LEGACY-STORAGE-RETENTION-REGISTER.md) - explicit retention register for remaining `macos_import.db` / `working.db` storage, archive/recovery blockers, diagnostics, reset behavior, tests, and removal criteria.
25. [`82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md`](82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md) - cutover plan for replacing old archive import/projection paths with source-scoped archive source registration, import, projection, and verification.
26. [`83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`](83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md) - policy assessment classifying `macos_import.db` and `working.db` as retired cleanup/diagnostic inventory rather than permanent reference databases.
27. [`84-ATTACHMENT-REACHABILITY-AUDIT.md`](84-ATTACHMENT-REACHABILITY-AUDIT.md) - attachment reachability proof showing ordinary graph-era attachment evidence and living archive sweeps resolve through `working_ss.db`, overlay archive metadata, and the archive filesystem rather than retired databases.
28. [`85-RELEASE-EXIT-PLAN.md`](85-RELEASE-EXIT-PLAN.md) - current product/release mode: stop opportunistic hardening and advance readiness, onboarding, archive import, archive/recovery verification, retired database readiness, and final smoke testing.

## Navigation Guide

### Durable Invariants

These documents are current architectural guardrails:

- `00-TERMINOLOGY.md`
- `10-ARCHITECTURE-CONTRACT.md`
- `20-ALLOWED-DEPENDENCIES.md`
- `30-INVARIANTS.md`
- `49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md`
- `60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`
- `64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`
- `68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md`
- `69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`

### Migration History And Audit Evidence

Documents `40` through `84` include pilot plans, graph migration checkpoints,
dependency matrices, parity audits, retirement assessments, and reachability
proofs. They are useful when interpreting why the system has its current
shape. They should not be read as permission to restart retired legacy paths.

### Current Work Selection

`85-RELEASE-EXIT-PLAN.md` is the current gate for deciding whether work should
proceed. Architecture cleanup that does not directly improve release readiness
or user-visible correctness should be recorded for later rather than executed.

Read [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md) before adding archive-source support, topology projection, source occurrence tables, provenance sidecars, or any schema that stores source-derived relationship endpoints.

Read [`67-SS-LEGACY-PARITY-AUDIT.md`](67-SS-LEGACY-PARITY-AUDIT.md) before replacing legacy import/migration behavior with SS graph behavior.

Read [`68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md`](68-SS-MESSAGE-SEMANTIC-PRESERVATION-MODEL.md) before adding message fields or semantic classifications to the SS graph.

Read [`69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md`](69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md) before adding any new message-bearing surface, timeline search mode, recovered-message view, attachment evidence view, or message row presentation behavior.

Read [`70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md`](70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md) before planning broad graph-migration work, retiring legacy import/read systems, promoting graph build lifecycle behavior, or deciding the next source-scoped migration slice.

Read [`71-LEGACY-DEPENDENCY-MATRIX.md`](71-LEGACY-DEPENDENCY-MATRIX.md) before deleting legacy code, replacing `working.db`/`macos_import.db` consumers, migrating search/contact/handle reads, or deciding whether a legacy dependency is still production lifecycle, recovery/archive, diagnostic, or safe to remove.

Read [`72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md`](72-GRAPH-CHOKE-POINTS-AND-RETIREMENT-BLOCKERS.md) before choosing the next graph-migration slice, changing overlay identity keys, productionizing graph lifecycle, or deciding whether to migrate Search, Contact Identity, lifecycle, or archive/recovery next.

Read and update [`73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md`](73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md) while executing graph migration slices so status, blockers, required verification, and exit criteria remain explicit.

Read [`74-OVERLAY-IDENTITY-KEY-AUDIT.md`](74-OVERLAY-IDENTITY-KEY-AUDIT.md) before changing overlay schemas, graph-native Search, message tags/saved state, contact favourites, manual handle links, dismissed/visibility behavior, or attachment archive identity.

Read [`80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md`](80-GRAPH-MIGRATION-INTERIM-PROGRESS-REPORT.md) for historical interim state after graph lifecycle productionization, live polling proof, ordinary-read migration, retained-storage cleanup, and documentation alignment.

Read [`81-LEGACY-STORAGE-RETENTION-REGISTER.md`](81-LEGACY-STORAGE-RETENTION-REGISTER.md) before deleting retired `macos_import.db` / `working.db` files, retired archive import/projection references, historical archive settings metadata, retired database diagnostics, or legacy schema/migrator tests.

Read [`82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md`](82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md) before implementing graph-native historical archive import, registering non-live source IDs, parameterizing graph import/projection by source, or changing the Historical Archives workflow.

Read [`83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md`](83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md) before treating `macos_import.db` or `working.db` as anything other than retired transitional cleanup/diagnostic storage.

Read [`84-ATTACHMENT-REACHABILITY-AUDIT.md`](84-ATTACHMENT-REACHABILITY-AUDIT.md) before changing archive lookup, attachment evidence hydration, graph attachment sweeps, archive compatibility keys, or retired database cleanup policy.
