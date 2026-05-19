# 55-READERS-INTEGRATORS-ORCHESTRATORS

## Purpose

This folder defines an experimental architectural responsibility model intended to make complex application orchestration more human-comprehensible, testable, observable, and safely evolvable.

The architecture is based on three primary responsibility layers:

```text
Readers
→ Integrators
→ Orchestrators
```

The incremental-update pilot has validated the fuller execution spine:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation
```

This model is being developed in parallel with existing production architecture and must not interfere with the currently functioning application unless explicitly promoted into production after validation.

The intent is not architectural novelty for its own sake. The intent is to improve:

- human understanding
- causal traceability
- decomposition of responsibilities
- testability
- observability

## Reading Flow

Use these documents in this order when working on the shadow incremental-update architecture:

1. [`00-TERMINOLOGY.md`](00-TERMINOLOGY.md) - shared vocabulary for Readers, Integrators, Orchestrators, snapshots, semantic state, and decisions.
2. [`10-ARCHITECTURE-CONTRACT.md`](10-ARCHITECTURE-CONTRACT.md) - responsibility boundaries and architectural contract.
3. [`20-ALLOWED-DEPENDENCIES.md`](20-ALLOWED-DEPENDENCIES.md) - permitted dependency direction between architecture layers.
4. [`30-INVARIANTS.md`](30-INVARIANTS.md) - rules that must not be violated while extending the pipeline.
5. [`49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md`](49-IMPORT-STAGE-CONTROLLER-AND-PIPELINE-ORCHESTRATOR-STRATEGY.md) - validated StageController and PipelineOrchestrator pattern.
6. [`50-INCREMENTAL-UPDATE-PILOT.md`](50-INCREMENTAL-UPDATE-PILOT.md) - current pilot behavior and validated runtime spine.
7. [`60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md`](60-CANONICAL-TOPOLOGY-PROJECTION-DESIGN.md) - design options for projecting preserved source topology into working app truth.
8. [`62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md`](62-WORKING-CHAT-ENDPOINT-RESOLUTION-AUDIT.md) - current audit of ledger-chat to working-chat endpoint resolution.
9. [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md) - source-scoped row identity strategy for multi-source-safe provenance and topology resolution.

Read [`64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md`](64-SOURCE-SCOPED-ROW-KEY-STRATEGY.md) before adding archive-source support, topology projection, source occurrence tables, provenance sidecars, or any schema that stores source-derived relationship endpoints.
