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
25. [`82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md`](82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md) - cutover plan for replacing retained historical archive import/projection with source-scoped archive source registration, import, projection, and verification.

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
