# 50-INCREMENTAL-UPDATE-PILOT

## Purpose

This document defines the shadow incremental-update pilot for the Readers → Integrators → Orchestrators architectural responsibility model.

The message sync pilot under `lib/essentials/incremental_update/` is now a working, validated implementation of the model. It remains shadow/dev-only and non-authoritative, but it has proven the responsibility split, the correct invalidation boundary for polling, closed-loop shadow import, source topology preservation, closed-loop shadow migration, comparative validation, and developer-facing observability.

Initial pilot target:

```text
Incremental update detection
```

Current validated milestone:

```text
closed-loop shadow import + topology preservation + migration + comparative validation
through PipelineOrchestrator and ordered StageControllers
```

This pilot exists to evaluate whether responsibility decomposition can improve:

- human comprehensibility
- causal traceability
- orchestration clarity
- safe architectural evolution

without destabilizing existing production behavior.

---

# Why Incremental Update Detection?

The existing incremental update flow is a strong pilot candidate because it currently combines multiple abstraction layers simultaneously:

- factual reads
- semantic reconciliation
- polling lifecycle
- startup reconciliation
- debounce scheduling
- execution gating
- import triggering
- migration triggering
- attachment sweep scheduling
- orchestration state publication

This makes it an excellent candidate for responsibility decomposition experiments.

---

# Pilot Scope

Initial pilot scope should remain intentionally narrow.

Preferred initial target:

```text
message incremental detection only
```

The current pilot has advanced beyond detection while remaining shadow-only: it can execute a minimal message import into `macos_import_shadow.db`, execute a minimal message migration into `working_shadow.db`, compare shadow conclusions against production behavior, and expose current state in a dev-only status panel.

NOT:

- full import replacement
- full migration replacement
- full attachment archival replacement
- projection ownership replacement
- production import execution

The purpose is architectural evaluation, not immediate production replacement.

---

# Existing Production Flow

Current production flow broadly performs:

```text
1. Observe live chat.db
2. Compare against imported ledger state
3. Determine whether incremental work is required
4. Coordinate execution ownership
5. Trigger import/migration
6. Publish resulting state
```

Currently, many of these responsibilities are concentrated inside:

```text
chatDbChangeMonitorProvider
```

The pilot explores whether these responsibilities can be decomposed more clearly.

---

# Validated Shadow Incremental-Update Pipeline

The implemented shadow message pipeline now follows this flow:

```text
poll tick
→ SyncStatePollingOrchestrator owns timer lifecycle
→ PipelineOrchestrator runs ordered StageControllers
→ stage controllers invalidate factual reader providers
→ readers re-query source/ledger/projection databases
→ integrators derive deltas, semantic states, policy decisions, and comparisons
→ stage controllers execute narrow import/topology/migration work when policy allows
→ PipelineRunReport aggregates stage reports and tick events
→ comparative validation compares production facts with shadow conclusions
```

Concrete implemented examples:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
→ snapshotDeltaIntegratorProvider
→ messageSyncStateProvider
→ importDecisionProvider
→ MessageImportStageController
→ ShadowImportExecutionOrchestrator
→ MessageImporter

liveChatDbChatMessageJoinSnapshotProvider
importLedgerChatMessageJoinSnapshotProvider
→ chatMessageJoinSnapshotDeltaIntegratorProvider
→ chatMessageJoinSyncStateProvider
→ chatMessageJoinImportDecisionProvider
→ ChatMessageJoinStageController
→ ChatMessageJoinImportExecutionOrchestrator
→ ChatMessageJoinImporter

shadowImportProjectionSnapshotProvider
shadowWorkingProjectionSnapshotProvider
→ messageMigrationDeltaProvider
→ messageMigrationStateProvider
→ migrationDecisionProvider
→ MessageMigrationStageController
→ ShadowMigrationExecutionOrchestrator
→ ShadowMessageMigrationExecutor

legacyIncrementalUpdateSnapshotProvider
incrementalUpdateComparisonProvider
→ ComparativeValidationStageController
→ ComparativeValidationOrchestrator

PipelineOrchestrator
→ HandleStageController
→ ChatStageController
→ MessageImportStageController
→ ChatMessageJoinStageController
→ MessageMigrationStageController
→ ComparativeValidationStageController
```

The reader snapshot providers are the external observation boundary:

- `liveChatDbMessageSnapshotProvider` observes live `chat.db`
- `importLedgerMessageSnapshotProvider` observes shadow `macos_import_shadow.db`
- topology reader providers observe live `chat.db.chat_message_join` and shadow `macos_import_shadow.db.chat_message_joins`
- shadow migration readers observe shadow `macos_import_shadow.db` and `working_shadow.db`
- comparative validation observes production facts read-only and compares them with shadow conclusions

The derived providers do not observe external reality directly. They compose values and derive meaning.

The `StageController` and `PipelineOrchestrator` patterns are now validated:

- `StageController` owns one concern-local refresh / meaning / policy / execution cycle
- `StageReport` records what that concern observed, decided, executed, and re-observed
- `PipelineOrchestrator` owns the manual ordered stage loop
- `PipelineRunReport` aggregates concern-local reports and diagnostic events
- `SyncStatePollingOrchestrator` owns polling lifecycle rather than concern sequencing

The topology stage is now part of `PipelineOrchestrator`. Its placement is intentional:

```text
messages imported
→ source chat/message topology preserved in macos_import_shadow.db
→ migration/projection runs afterward
```

This preserves source relationship facts before projection without making the topology stage responsible for canonical relationship meaning.

Current projection direction: future topology projection should transform source-local relationship endpoints into `SourceScopedRowKey` working identities. It should not route ordinary source-derived endpoints through GUID matching or merge-collapsed canonical remapping.

No graph execution, topological sorting, or descriptor-driven runtime planning has been introduced.

---

# Validated Architecture Spine

The shadow pilot has validated a reusable orchestration grammar in running app behavior, focused tests, console logs, comparative validation, and the dev-only status panel. This is no longer only aspirational architecture.

The same shape now appears across shadow import, shadow migration, and comparison:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation
```

This is the architecture spine.

The important property is not the specific database or table. The important property is that each step has a distinct responsibility and the next step depends on the previous step's output.

Generic responsibility mapping:

```text
Reader snapshots
→ semantic-state Integrator
→ policy-decision Integrator
→ execution Orchestrator
→ narrow Executor
→ reader snapshots on the next observation cycle
→ comparison Integrator / comparison Orchestrator for diagnostic visibility
```

For shadow import:

```text
live chat.db + macos_import_shadow.db facts
→ MessageSyncState
→ ImportDecision
→ ShadowImportExecutionOrchestrator
→ ShadowMessageImportExecutor
→ updated macos_import_shadow.db facts
```

For shadow migration:

```text
macos_import_shadow.db + working_shadow.db facts
→ MessageMigrationState
→ MigrationDecision
→ ShadowMigrationExecutionOrchestrator
→ ShadowMessageMigrationExecutor
→ updated working_shadow.db facts
```

For comparative validation:

```text
production facts + shadow facts
→ comparison semantics
→ MATCH / PHASE SKEW / MISMATCH / NOT COMPARABLE
→ human-readable diagnostic visibility
```

The naming symmetry is intentional and valuable:

```text
ImportDecisionIntegrator
ShadowImportExecutionOrchestrator
ShadowMessageImportExecutor

MigrationDecisionIntegrator
ShadowMigrationExecutionOrchestrator
ShadowMessageMigrationExecutor
```

This symmetry shows the system becoming compositional rather than bespoke. New execution boundaries should prefer this grammar unless there is a concrete reason to diverge.

The spine also clarifies safety:

- raw facts do not mutate state
- semantic states do not mutate state
- policy decisions do not mutate state directly
- execution orchestration decides whether an executor may run
- executors perform narrow, explicitly scoped mutation
- updated facts are observed by readers on the next refresh
- comparative validation remains observational and does not become a control plane

This preserves causal traceability:

```text
what was observed?
→ what did it mean?
→ what policy did that imply?
→ was execution allowed?
→ what changed?
→ did the facts resolve?
```

The validated runtime comparison state should capture the spine at decision and comparison boundaries:

- shadow import decision
- shadow migration decision
- comparison import outcome
- comparison migration outcome
- last transition time

These fields are the minimal useful observability surface for the pilot. They show what the shadow pipeline concluded, how those conclusions compare with production behavior, and when the most recent semantic transition occurred.

---

# Closed-Loop Import + Migration Milestone

The pilot now validates a full observable, testable, comparable shadow cycle:

```text
live chat.db changes
→ shadow import decision changes
→ shadow import executes into macos_import_shadow.db
→ shadow migration decision changes
→ shadow migration executes into working_shadow.db
→ comparative validation classifies production-vs-shadow agreement
→ system returns to steady state
```

One polling loop now drives the validated shadow sequence:

```text
shadow import catch-up
→ shadow migration catch-up
→ comparative validation
```

This does not make the pilot production-authoritative. It proves that mutation-producing work can remain downstream of explicit semantic and policy meaning across multiple execution boundaries.

---

# Closed-Loop Shadow Import Milestone

The pilot has now validated the first real execution boundary while staying shadow-only:

```text
observe drift
→ derive MessageSnapshotDelta
→ derive MessageSyncState
→ derive ImportDecision
→ execute minimal shadow import
→ observe updated shadow ledger
→ resolve to ImportDecision.doNothing
```

This is not a production importer replacement. The execution path exists to prove the architecture at the boundary where policy meaning becomes action.

Validated execution components:

```text
ShadowImportExecutionOrchestrator
ShadowMessageImportExecutor
```

The executor performs the smallest useful write path:

```text
live chat.db.message rows
→ macos_import_shadow.db.messages
```

The executor imports only enough fields to keep the shadow ledger useful for incremental continuation and message counting:

- `id`
- `source_rowid`
- `source_id`
- `source_kind`
- `guid`
- `chat_id`
- `service`
- `is_from_me`
- `text`
- source-presence booleans required by the schema
- `is_system_message`
- `batch_id`

Because the existing import ledger schema has foreign keys, the shadow executor may create shadow-only support rows in `import_batches` and a placeholder `chats` row inside `macos_import_shadow.db`. These support rows are schema compatibility scaffolding, not a reimplementation of legacy chat import behavior.

The closed-loop proof is:

```text
ImportDecision.considerIncrementalImport
→ shadow message import executes
→ macos_import_shadow.db.messages catches up to live chat.db.message
→ reader invalidation observes the new ledger state
→ MessageSyncState resolves
→ ImportDecision.doNothing
```

This milestone validates that execution can remain downstream of policy meaning without collapsing readers, integrators, and orchestration back into one responsibility-compressed object.

---

# Closed-Loop Shadow Migration Milestone

The pilot has also validated a second shadow-only execution boundary:

```text
observe shadow ledger/projection drift
→ derive message migration delta
→ derive MessageMigrationState
→ derive MigrationDecision
→ execute minimal shadow migration
→ observe updated working_shadow.db projection facts
→ resolve to MigrationDecision.doNothing
```

Validated execution components:

```text
ShadowMigrationExecutionOrchestrator
ShadowMessageMigrationExecutor
```

The executor performs the smallest useful projection write path:

```text
macos_import_shadow.db.messages
→ working_shadow.db.messages
```

This validates that migration can follow the same architecture spine as import without invoking legacy migration orchestration or production projection ownership.

---

# Dev-Only Status Panel

The pilot now has a dev-only status panel. The panel is an observability surface, not a control plane.

It displays already-derived facts and meanings:

- polling status
- last refresh / transition time
- shadow import decision
- message sync state
- import row-id and message-count deltas
- shadow migration decision
- message migration state
- migration message-id and message-count deltas
- comparative validation outcomes and reason text

The panel must not compute business meaning itself. It should watch the existing provider graph and display the current state of the pilot. Start, stop, and refresh controls may invoke existing development orchestration actions, but the panel must not introduce a separate polling loop, production mutation path, or hidden execution policy.

---

# Focused Test Coverage

The closed-loop pilot now has narrow architectural tests covering semantic derivation, policy derivation, execution eligibility, and comparative validation semantics.

Current focused test files:

```text
test/essentials/incremental_update/application/messages/integrators/
  message_sync_assessment_integrator_test.dart
  import_decision_integrator_test.dart
  migration_state_integrator_test.dart
  migration_decision_integrator_test.dart
  incremental_update_comparison_integrator_test.dart

test/essentials/incremental_update/application/messages/orchestrators/
  shadow_import_execution_orchestrator_test.dart
  shadow_migration_execution_orchestrator_test.dart
```

Validated semantic derivation:

```text
MessageSnapshotDelta(rowIdDelta: 0)
→ MessageSyncState.sourceAndLedgerCursorsMatch()

MessageSnapshotDelta(rowIdDelta: positive)
→ MessageSyncState.sourceAheadOfLedger()

MessageSnapshotDelta(rowIdDelta: negative)
→ MessageSyncState.ledgerAheadOfSource()
```

Validated policy derivation:

```text
MessageSyncState.sourceAndLedgerCursorsMatch()
→ ImportDecision.doNothing()

MessageSyncState.sourceAheadOfLedger()
→ ImportDecision.considerIncrementalImport()

MessageSyncState.ledgerAheadOfSource()
→ ImportDecision.blockAndReportLedgerAhead()
```

Validated execution safety:

```text
ImportDecision.doNothing()
→ no executor invocation

ImportDecision.blockAndReportLedgerAhead()
→ no executor invocation

ImportDecision.considerIncrementalImport()
→ executor invoked exactly once
```

The explicit ledger-ahead safety scenario is:

```text
live max rowid = 100
ledger max source_rowid = 105
rowIdDelta = -5
→ MessageSyncState.ledgerAheadOfSource()
→ ImportDecision.blockAndReportLedgerAhead()
→ execution blocked
```

The execution tests use a callback-backed fake executor through a test-only constructor on `ShadowImportExecutionOrchestrator`. They do not open production databases, shadow databases, or call legacy import/migration systems.

Validated migration safety:

```text
MigrationDecision.doNothing()
→ no executor invocation

MigrationDecision.blockAndReportProjectionAhead()
→ no executor invocation

MigrationDecision.considerShadowMigration()
→ executor invocation may occur
```

Validated comparison semantics:

```text
equivalent legacy/shadow conclusions
→ MATCH

temporally offset but causally explainable pipeline phases
→ PHASE SKEW

durable semantic disagreement without a recognized transient explanation
→ MISMATCH

missing or invalid facts
→ NOT COMPARABLE
```

These tests protect the causal safety rule:

```text
facts
→ semantic meaning
→ policy meaning
→ execution eligibility
```

Execution must not occur directly from raw numeric facts, and ledger-ahead conditions must block shadow execution.
Projection-ahead conditions must likewise block shadow migration execution.

---

# Validated Implementation Structure

Current implemented structure:

```text
incremental_update/
  messages/
    executors/
    readers/
    integrators/
    orchestrators/
```

The pilot remains isolated from production orchestration ownership.

---

# Reader Snapshot Providers

Validated reader snapshot providers:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
shadowImportProjectionSnapshotProvider
shadowWorkingProjectionSnapshotProvider
legacyIncrementalUpdateSnapshotProvider
```

Reader goal:

```text
factual observation only
```

Readers and reader snapshot providers:

- observe external reality
- execute factual database reads
- produce immutable snapshots

Readers should avoid:

- orchestration
- retries/debounce
- execution triggering
- semantic interpretation

---

# Integrators

Validated integrator providers:

```text
snapshotDeltaIntegratorProvider
messageSyncStateProvider
importDecisionProvider
messageMigrationDeltaProvider
messageMigrationStateProvider
migrationDecisionProvider
incrementalUpdateComparisonProvider
```

Integrator goal:

```text
semantic interpretation
```

The implemented integrator sequence separates facts, semantic meaning, and policy meaning:

```text
live/import snapshots
→ MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision

shadow ledger/projection snapshots
→ message migration delta
→ MessageMigrationState
→ MigrationDecision

production/shadow facts
→ comparison semantics
```

Integrator roles:

- `snapshotDeltaIntegratorProvider` computes numeric drift from factual snapshots
- `messageSyncStateProvider` converts numeric drift into semantic sync state
- `importDecisionProvider` converts semantic sync state into policy meaning
- `messageMigrationStateProvider` converts projection drift into semantic migration state
- `migrationDecisionProvider` converts semantic migration state into policy meaning
- `incrementalUpdateComparisonProvider` compares production and shadow conclusions

Integrators should remain synchronous and pure whenever practical. Providers may coordinate async reads, but the semantic transform itself should be deterministic:

```text
facts in
→ meaning out
```

Decision integrators are still integrators. Their input is semantic meaning and their output is policy meaning. They should not perform side effects.

Integrators and decision integrators should avoid:

- lifecycle ownership
- retries/debounce
- execution triggering
- mutation-producing work

---

# Orchestrator

Validated orchestrator:

```text
SyncStatePollingOrchestrator
ShadowImportExecutionOrchestrator
ShadowMigrationRefreshOrchestrator
ShadowMigrationExecutionOrchestrator
ComparativeValidationOrchestrator
```

Orchestrator goal:

```text
execution coordination
```

Orchestrators should own:

- polling cadence
- polling lifecycle
- refresh triggering
- overlap prevention
- transition observation
- execution triggering when downstream policy meaning calls for it

The validated polling orchestrator does not own semantic interpretation. It invalidates the factual observation boundary, reads the final policy provider, triggers shadow execution orchestration, runs migration refresh/comparison coordination, and logs transitions.

Orchestrators should prefer:

- readers for factual observation
- integrators for meaning
- providers for reactive composition and dependency propagation

rather than embedding all logic internally.

---

# Executor

Validated executor:

```text
ShadowMessageImportExecutor
ShadowMessageMigrationExecutor
```

Executor goal:

```text
narrow shadow-only mutation
```

The executor is deliberately not a Reader and not an Integrator:

- it performs writes
- it does not derive semantic meaning
- it does not decide whether import should occur
- it does not own polling lifecycle

The current import executor is intentionally limited to:

```text
live chat.db.message
→ macos_import_shadow.db.messages
```

The current migration executor is intentionally limited to:

```text
macos_import_shadow.db.messages
→ working_shadow.db.messages
```

It must not call or reuse:

- legacy `MessagesImporter`
- legacy import orchestration
- migration orchestration
- attachment orchestration
- search indexing
- projection logic
- production `macos_import.db`
- production `working.db`
- overlay database

This keeps the pilot execution boundary understandable and prevents the shadow architecture from inheriting the responsibility compression it is meant to evaluate.

---

# Invalidation Boundary Principles

The main architectural discovery from the working pilot is:

```text
Invalidate at the external observation boundary,
not at semantic/derived providers.
```

Polling means:

```text
observe external reality again
```

It does not mean:

```text
refresh conclusions
```

For the validated message pilot, the polling orchestrator invalidates only:

```text
liveChatDbMessageSnapshotProvider
importLedgerMessageSnapshotProvider
```

For the validated migration step, refresh invalidation targets the shadow projection observation boundary:

```text
shadowImportProjectionSnapshotProvider
shadowWorkingProjectionSnapshotProvider
```

It does not manually invalidate:

```text
snapshotDeltaIntegratorProvider
messageSyncStateProvider
importDecisionProvider
messageMigrationStateProvider
migrationDecisionProvider
incrementalUpdateComparisonProvider
```

Those providers should recompute naturally because they depend on the reader snapshot providers.

If invalidating factual observation providers does not propagate upward, the provider graph is structured incorrectly. The correct fix is to repair the dependency graph, not to force-refresh semantic conclusions.

---

# Reactive vs Imperative Flow

The pilot clarified an important distinction:

```text
reactive provider graph
vs
imperative polling invalidation
```

Providers watching other providers creates a reactive dependency graph. It does not mean that invalidating an upper derived provider forces lower providers to re-query external reality.

The imperative polling action should be narrow:

```text
poll tick
→ invalidate factual observation providers
→ read final semantic/policy provider
```

The reactive graph then handles:

```text
reader snapshots changed
→ delta recomputed
→ sync state recomputed
→ import decision recomputed
```

This preserves responsibility separation:

- polling owns time
- readers own external observation
- providers own dependency propagation
- integrators own meaning

---

# Semantic State Derivation

The validated message pilot uses distinct layers of meaning:

```text
MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
```

`MessageSnapshotDelta` is factual numeric drift:

- row id delta
- message count delta

`MessageSyncState` is cursor-based semantic sync meaning:

- cursors match
- source ahead of ledger
- ledger ahead of source

For message import continuation, the cursor is the source-local `ROWID` frontier. If the live source `MAX(ROWID)` and ledger `MAX(source_rowid)` match, the incremental importer has no newer source-local message rows to import.

`messageCountDelta` is still important, but it is diagnostic reconciliation evidence rather than import continuation policy. A count divergence with matching cursors may reflect persistent ledger behavior, live source deletion/pruning below the cursor, duplicate/conflict handling, or source/ledger snapshot queries counting different semantic populations.

Therefore this combination is valid:

```text
MessageSyncState.sourceAndLedgerCursorsMatch
messageCountDelta != 0
```

It should be surfaced in status/logs as count divergence, but it should not by itself schedule import, block import, or imply importer failure.

Continuation cursor reads are now source-scoped. The current pilot still observes only the live source:

```text
source_id = live-chat-db
source_kind = live_chat_db
```

but repositories and importers must already be multi-source-safe:

```text
MAX(source_rowid)
WHERE source_id = live-chat-db
```

or the equivalent source-scoped API.

This is required because future archived Messages-folder imports will introduce additional `chat.db` sources with independent local `ROWID` sequences. A higher `source_rowid` from an archive source must never advance the live source continuation cursor.

`ImportDecision` is policy meaning:

- do nothing
- consider incremental import
- block/report ledger-ahead condition

These should remain separate. A numeric fact should not directly schedule work. A semantic state should not perform side effects. A policy decision should not mutate production systems by itself.

---

# Why Sealed Unions Matter

Semantic states and policy decisions should use sealed unions when the set of meanings is intentionally finite.

The pilot validates this for:

```text
MessageSyncState
ImportDecision
MessageMigrationState
MigrationDecision
ComparisonOutcome
```

Sealed unions make transitions explicit and force exhaustive handling. This matters because missing a state in incremental update logic can lead to silent import skips, unsafe execution, or confusing logs.

Prefer sealed unions for semantic meaning such as:

- source and ledger cursors match
- source is ahead of ledger
- ledger is ahead of source
- import should do nothing
- import should be considered
- import should be blocked and reported

Avoid encoding these as loose strings or unstructured booleans once they become orchestration-relevant.

---

# Why Readers Must Own External Observation

Readers are the right invalidation boundary because they are the only layer that observes external reality.

In the validated pilot, external reality is:

- live Messages `chat.db`
- shadow `macos_import_shadow.db`
- shadow `working_shadow.db`
- production import/projection facts used read-only for comparison

The reader snapshot providers re-query those databases and produce factual snapshots. Everything above that layer should be a deterministic consequence of those facts.

This rule prevents semantic providers from becoming accidental lifecycle owners. It also makes logs easier to reason about:

```text
external facts changed
→ semantic meaning changed
→ policy meaning changed
```

instead of:

```text
some conclusion was refreshed
→ maybe facts changed
```

---

# Important Architectural Clarification

The pilot does NOT attempt to eliminate orchestration complexity.

The incremental update pipeline genuinely contains complex coordination concerns:

- asynchronous polling
- startup reconciliation
- execution ownership
- retry behavior
- projection synchronization
- attachment coordination

These concerns are real.

The goal is:

```text
understandable orchestration
```

rather than:

```text
minimal orchestration
```

---

# Shadow Implementation Strategy

Initial pilot behavior should remain:

```text
parallel
non-authoritative
observable
reversible
```

Preferred initial behavior:

- observe production state
- produce comparable semantic outputs
- log decisions
- perform explicitly scoped shadow-only execution when policy meaning allows it
- avoid authoritative execution ownership

The pilot should initially avoid:

- production mutation
- production scheduling ownership
- production migration ownership

---

# Comparative Validation Semantics

The pilot now compares itself against existing production behavior. This is epistemic validation, not execution ownership.

The first comparative validation layer has validated four explicit outcome meanings:

```text
MATCH
PHASE SKEW
MISMATCH
NOT COMPARABLE
```

`MATCH` means legacy production behavior and shadow behavior reached equivalent conclusions.

`PHASE SKEW` means both systems appear valid but are being observed at different moments in asynchronous import/projection execution.

`MISMATCH` means the comparison has no recognized transient explanation and should be treated as possible durable semantic disagreement.

`NOT COMPARABLE` means one side lacks enough stable facts for a meaningful comparison.

`PHASE SKEW` is especially important: it is not a failure. It identifies valid but temporally offset pipeline phases, such as production import advancing before production projection, or shadow projection catching up before production projection is sampled.

The comparison layer should preserve, log, or expose:

- shadow import decision
- shadow migration decision
- comparison import outcome
- comparison migration outcome
- last transition time

This keeps comparative validation epistemic rather than authoritative: it explains whether the systems agree, are temporarily phase-skewed, truly disagree, or cannot yet be compared.

---

# Behavioral-Equivalence Assessment

The pilot has moved from proving that the shadow pipeline works to studying how it behaves relative to production.

Behavioral-equivalence assessment asks:

- does shadow reach the same durable conclusion as production?
- does shadow converge earlier or later?
- are differences caused by cadence, batching, invalidation boundaries, execution timing, or legacy constraints?
- is a divergence intentional, acceptable, accidental, or unresolved?

Important terms:

- behavioral equivalence: same durable conclusions and steady state
- acceptable transient skew: temporary `PHASE SKEW` that resolves naturally
- operational divergence: observed runtime difference between production and shadow
- cadence divergence: difference caused by polling or scheduling cadence
- scheduling divergence: difference caused by when work is triggered
- convergence latency: duration or tick count from observed drift to steady state
- steady-state equivalence: final `MATCH / MATCH` after both systems settle

The endurance log records lightweight observational metrics:

- shadow import convergence duration
- shadow import ticks to convergence
- shadow migration convergence duration
- shadow migration ticks to convergence
- total shadow convergence duration
- total shadow ticks to convergence
- whether production convergence still appears pending
- observed production pending duration

The endurance log also records per-tick causal events before the end-of-tick summary. This matters because fast shadow convergence can erase evidence from a final snapshot. A tick may observe source drift, execute shadow import, execute shadow migration, and settle back to `doNothing / projectionCaughtUp` before the summary is written.

Per-tick events preserve that intra-tick history:

```text
tick started
→ reader refresh started
→ import delta observed
→ import decision observed
→ shadow import executed or skipped
→ migration delta observed
→ migration decision observed
→ shadow migration executed or skipped
→ comparison observed
→ end-of-tick summary
```

These are assessment signals only. They must not change production scheduling, shadow cadence, retry behavior, or execution ownership.

Recurring `PHASE SKEW` patterns are now meaningful architectural evidence. For example:

```text
legacy=migration required
shadow=projection current
```

This can indicate that shadow projection has already caught up while production migration is still pending. That is not automatically a failure; it is an operational divergence to study before any promotion decision.

Open assessment questions:

- Does shadow consistently converge earlier than production?
- Are faster shadow transitions caused by simpler orchestration, different batching, or missing production responsibilities?
- Are any `MISMATCH` outcomes durable after multiple ticks?
- Do all `PHASE SKEW` outcomes resolve to `MATCH / MATCH`?
- Which observed differences are acceptable for a future production path?

Examples:

## Factual Comparison

```text
live rowid
imported rowid
message counts
projection completion state
```

---

## Semantic Comparison

```text
ledger behind?
startup reconciliation required?
incremental update required?
projection inconsistent?
```

---

## Scheduling Comparison

```text
would incremental work be scheduled?
would retry occur?
would debounce occur?
```

Differences should be:

- logged
- reviewed
- explained

before production adoption occurs.

---

# Logging Philosophy

Preferred logging style:

```text
[legacy]
startup probe → schedule incremental import

[shadow]
startup probe → identical decision
```

or:

```text
[legacy]
ledger current

[shadow]
ledger behind
reason: imported count mismatch
```

Goal:

```text
causal architectural visibility
```

rather than merely low-level debugging.

---

# Attachment Relationship Clarification

Attachments are related to message orchestration but may still represent a distinct concern slice.

Reason:

- independent scheduling cadence
- independent maintenance behavior
- independent retry semantics
- independent orchestration narrative

Therefore, future structure may resemble:

```text
incremental_updates/
  messages/
  attachments/
```

even though attachments remain semantically connected to messages.

Concern separation is based primarily on:

- causal coherence
- orchestration coherence
- human comprehensibility

rather than complete physical independence.

---

# Success Criteria

Pilot success is NOT defined solely by runtime correctness.

Success also includes:

- improved explainability
- improved causal traceability
- improved architectural readability
- easier onboarding
- easier modification safety
- clearer orchestration narratives

The pilot should help humans more easily answer:

```text
What facts were observed?
What meaning was derived?
What execution occurred?
Why did execution occur?
```

---

# Promotion Criteria

Experimental architecture should only become production-authoritative after:

- behavioral equivalence
- comparative validation
- orchestration observability
- safe rollback capability
- explicit execution ownership and gating
- staged adoption plan
- continued comparison against production behavior during rollout
- sufficient confidence

The validated architecture spine is now a candidate template for future orchestration systems, but the pilot is not feature-complete and has not replaced legacy production behavior. Promotion requires proof that the decomposed system reaches equivalent conclusions and can be adopted reversibly.

Promotion should preferably occur incrementally rather than through wholesale replacement.

Examples:

- production Readers first
- production Integrators second
- production Orchestrators last

Or:

- attachment orchestration first
- message orchestration later

Incremental adoption is preferred over abrupt replacement.

---

# Final Clarification

This pilot should be treated as:

```text
architectural exploration
```

rather than:

```text
mandatory architectural replacement
```

The purpose is to evaluate whether responsibility decomposition produces a system that is:

- easier for humans to understand
- easier to reason about
- easier to safely evolve

while preserving the strengths of the existing deterministic pipeline architecture.
