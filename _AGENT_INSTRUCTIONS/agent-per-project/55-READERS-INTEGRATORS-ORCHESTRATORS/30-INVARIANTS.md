# 30-INVARIANTS

## Purpose

This document defines architectural invariants for the Readers → Integrators → Orchestrators responsibility model.

These invariants exist to preserve:

- responsibility clarity
- causal traceability
- safe orchestration behavior
- human comprehensibility
- long-term architectural integrity

An invariant is a rule that should remain true regardless of implementation details.

---

# Core Architectural Invariant

The preferred conceptual flow is:

```text
facts
→ meaning
→ execution
```

The validated incremental-update pilot refines this into an explicit architecture spine:

```text
facts
→ semantic state
→ policy decision
→ execution orchestration
→ narrow executor
→ updated facts
→ comparative validation
```

Equivalent responsibility layers:

```text
Readers
→ Integrators
→ Orchestrators
```

Lower-level factual observation should not become entangled with higher-level orchestration concerns unless explicitly justified.

---

# User-Facing Identity Invariant

Known contacts are always named by the user-assigned name in user-facing UI.

There is exactly one user-defined contact name override:

```text
participant_overrides.display_name_override
```

This is written only by the contact hero-card pencil rename action. Other name-like fields are imported or derived metadata, not user intent.

Preferred display precedence:

```text
user display-name override
→ imported AddressBook display name
→ raw handle only when no known contact identity exists
```

There is no separate app-facing "short name" identity. Imported AddressBook names and raw handles remain source facts and useful metadata, but they must not replace the user's chosen identity label for a known contact.

Handles may appear for a known contact only in explicitly handle-oriented contexts, such as a contact handle scope selector, developer diagnostics, or a metadata line explaining an active handle filter.

Conversation graph surfaces must resolve participant handles through the preferred contact-name boundary before rendering conversation titles, signatures, message evidence headers, or search context labels.

---

# Reader Invariants

## Readers Observe Facts

Readers should primarily observe and expose factual state.

Examples:

- MAX(ROWID)
- message counts
- attachment existence
- projection completion state
- execution gate state

Readers should not reinterpret facts into semantic conclusions.

---

## Readers Avoid Lifecycle Ownership

Readers should not own:

- timers
- polling
- retry scheduling
- debounce behavior
- orchestration lifecycle

Readers should preferably remain execution-neutral.

---

## Readers Avoid Pipeline Mutation

Readers should avoid mutation-producing behavior.

Examples of prohibited mutation:

- importing rows
- migration execution
- projection updates
- attachment archival writes

Readers should primarily observe rather than coordinate.

---

## Readers Are the Invalidation Boundary for External Observation

When polling exists to re-observe external reality, invalidation should target Readers or reader snapshot providers.

Examples of external observation:

- live `chat.db`
- `macos_import.db`
- filesystem state
- projection readiness state

Derived semantic providers should recompute through dependency propagation. Orchestrators should not compensate for an incorrect provider graph by invalidating semantic conclusions directly.

The validated message shadow pipeline follows:

```text
poll tick
→ invalidate reader snapshot providers
→ derived providers recompute naturally
```

This preserves the distinction between:

- observing facts again
- recomputing meaning from facts

---

# Integrator Invariants

## Integrators Interpret Facts

Integrators should combine factual reader outputs into semantic meaning.

Examples:

- "ledger behind"
- "projection incomplete"
- "startup reconciliation required"
- "attachment archive drift detected"

Integrators should not directly coordinate execution lifecycle.

---

## Integrators Keep Meaning Separate from Policy and Execution

Integrators should make each level of meaning explicit.

The validated message shadow pipeline separates:

```text
MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
```

Numeric drift, semantic sync state, and policy decision are related but distinct. Keeping them separate prevents facts from directly becoming execution and prevents policy decisions from acquiring side effects.

Decision integrators may convert semantic meaning into policy meaning, but they should remain side-effect free.

---

## Integrators Prefer Deterministic Evaluation

Given the same inputs, Integrators should preferably produce the same outputs.

Integrators should favor:

- immutable semantic models
- pure evaluation helpers
- explicit reconciliation logic

Integrators should avoid hidden orchestration state.

---

## Integrators Avoid Lifecycle Ownership

Integrators should avoid owning:

- polling loops
- timers/listeners
- retry coordination
- execution gates
- debounce scheduling

Lifecycle coordination belongs primarily to Orchestrators.

---

# Orchestrator Invariants

## Orchestrators Coordinate Execution

Orchestrators own:

- lifecycle coordination
- async flow coordination
- retries/debounce
- execution triggering
- scheduling behavior
- execution ownership coordination

Orchestrators answer:

```text
"What should happen next?"
```

---

## Orchestrators Prefer Delegation

Orchestrators should preferably:

- delegate factual reads to Readers
- delegate semantic interpretation to Integrators

rather than embedding all concerns internally.

---

## Orchestrators Expose Causal Narrative

Orchestrators should expose understandable execution flow.

Humans should be able to explain:

```text
what triggered execution
→ what semantic condition was detected
→ what execution occurred
```

Opaque orchestration behavior should be treated as an architectural smell.

---

# Concern Invariants

## Concerns Represent Coherent Narratives

Concerns should generally represent coherent behavioral narratives.

Examples:

- messages
- attachments
- projection state
- onboarding import
- execution gating

Concern separation is based primarily on:

- causal coherence
- lifecycle coherence
- human comprehensibility

rather than strict physical isolation.

---

## Concern Boundaries May Evolve

Concern boundaries are not rigid.

If duplication becomes excessive:

```text
messages/
attachments/
```

this should trigger architectural review.

Possible outcomes:

- shared abstraction extraction
- revised concern boundaries
- shared orchestration services
- acceptance of intentional duplication

Duplication alone is not automatically an architectural failure.

---

# Shadow Implementation Invariants

## Shadow Implementations Must Remain Non-Authoritative

Experimental implementations should initially avoid:

- production mutation
- production scheduling ownership
- authoritative projection ownership

Shadow implementations should primarily:

- observe
- compare
- validate
- log differences

before becoming production actors.

---

## Parallel Validation Preferred

Experimental architectures should preferably be validated against:

- existing orchestration behavior
- existing projection outputs
- existing reconciliation decisions

before promotion into production.

---

## Comparative Validation Must Preserve Explicit Outcome Meaning

Comparative validation is observational, not authoritative.

It should capture enough state to explain what each system concluded and when that conclusion changed:

- shadow import decision
- shadow migration decision
- comparison import outcome
- comparison migration outcome
- last transition time

Comparison outcomes should remain explicit semantic meanings:

```text
MATCH
PHASE SKEW
MISMATCH
NOT COMPARABLE
```

`PHASE SKEW` is not a failure. It identifies a valid but temporally offset asynchronous execution window.

`MISMATCH` should be reserved for durable disagreement that has no recognized transient phase-skew explanation.

This protects the distinction between:

```text
temporary asynchronous execution phase
vs
durable architectural disagreement
```

The comparison layer must not mutate production state, trigger production execution, or become a scheduling authority.

---

## Behavioral Assessment Must Remain Observational

Behavioral-equivalence assessment may record:

- convergence duration
- ticks to convergence
- production pending duration
- recurring phase-skew patterns
- durable mismatch patterns
- per-tick causal events

End-of-tick summaries can hide fast convergence. If a polling tick observes drift, executes shadow work, and resolves before the final status snapshot is written, the summary may correctly show steady state while omitting the work that occurred. Endurance logs should therefore preserve per-tick causal history separately from the final summary.

These metrics are diagnostic evidence only. They must not:

- change production scheduling
- change shadow polling cadence
- trigger retries or debounce behavior
- promote shadow execution into production ownership
- mutate production databases

Behavioral assessment should explain operational divergence before any promotion decision.

---

## Shadow Execution Must Remain Downstream of Policy Meaning

Raw facts must not directly trigger mutation.

Execution may occur only after:

```text
facts
→ semantic meaning
→ policy meaning
```

For the message pilot:

```text
MessageSnapshotDelta
→ MessageSyncState
→ ImportDecision
→ ShadowImportExecutionOrchestrator
```

For the shadow migration pilot:

```text
message migration delta
→ MessageMigrationState
→ MigrationDecision
→ ShadowMigrationExecutionOrchestrator
```

This preserves the rule that factual drift is evidence, not an execution command.

---

## Shadow Execution Must Not Mutate Production Databases

Shadow execution may write only to explicitly named shadow/dev databases:

- `macos_import_shadow.db`
- `working_shadow.db`

Shadow execution must not write to:

- `macos_import.db`
- `working.db`
- `user_overlays.db`

Production databases may be read for comparative validation, but comparison must remain read-only and must not schedule or trigger production execution.

Shadow execution remains experimental and non-authoritative until explicitly promoted.

---

## Non-Source Structural Shim Rows Must Not Count as Source-Ledger Convergence

Shadow/dev databases may contain structural shim rows needed to satisfy existing schema constraints while a narrow pilot slice remains intentionally incomplete.

Example:

- a shadow-only placeholder `chats` row used as a temporary foreign-key anchor for message rows before `chat_message_join` topology import exists

These rows are implementation scaffolding, not observed source facts.

Therefore, source-ledger convergence calculations must exclude non-source structural shim rows. Counts, cursors, and drift calculations comparing a source table to a ledger table should count only rows that represent imported source records for that source concern.

Practical rule:

```text
source-backed rows participate in source-ledger convergence
non-source structural shim rows do not
```

For source-backed ledger rows, provenance such as `source_rowid`, `source_id`, and `source_kind` should distinguish imported source facts from structural scaffolding.

This preserves diagnostic honesty: a schema-compatibility shim must not make a source importer appear ahead, behind, or mismatched.

---

## Source Topology Must Be Preserved Before Projection

Apple source databases own relationship topology separately from individual entity rows.

For Messages `chat.db`, message-to-chat membership belongs to:

```text
chat_message_join
```

not to `message.chat_id`.

The shadow incremental-update pipeline now preserves this source topology as its own concern before migration/projection runs:

```text
HandleStageController
→ ChatStageController
→ MessageImportStageController
→ ChatMessageJoinStageController
→ MessageMigrationStageController
→ ComparativeValidationStageController
```

This ordering is intentional.

Source topology preservation means:

- observe source relationship rows
- preserve source-scoped relationship provenance in `macos_import_shadow.db`
- keep topology import resumable and idempotent
- run migration/projection only after source topology has had a chance to catch up
- project source-local relationship endpoints into `SourceScopedRowKey` working identities when topology projection is introduced

Source topology preservation does not mean:

- canonical chat resolution
- merge-collapsed relationship projection into `working_shadow.db`
- search/UI relationship semantics
- production projection ownership

Working relationship projection remains deferred until a projection concern explicitly owns it. When it is introduced, source-derived relationship endpoints should be occurrence-preserving and source-scoped, not remapped through merge-collapsed canonical endpoint layers.

---

## Display Metadata Must Not Become Canonical Identity

Display-facing source fields are optional metadata, not identity.

For source chats, fields such as `display_name` may be:

- empty
- user-facing hints
- derived from other source identifiers
- duplicative of source chat GUID or identifier values
- unstable across sources or time

Therefore display metadata must not be used for:

- endpoint resolution
- topology projection
- canonicalization
- dedupe
- import continuation

Importers should not synthesize display metadata from identity-like source
fields such as `chat_identifier`. Preserve a display field only when the source
row directly provides that display field.

Source-derived timing facts are different. Fields such as `created_at_utc` and
`updated_at_utc` should be preserved when they map to verified Apple source
fields, but they still must not become endpoint identity, topology resolution,
dedupe, or import-continuation inputs.

For source-derived working chat projection, the endpoint identity is:

```text
chat_source_scoped_row_key = pack(source_id, source_chat_rowid)
```

not:

```text
ledger.chats.guid
→ working identity
```

and not:

```text
ledger.chats.display_name
→ working identity
```

Apple chat GUIDs should be treated as opaque source identifiers. They may be useful semantic grouping evidence, but they are not base source-derived working row identity.

---

## Cursor Convergence and Count Divergence Are Different Meanings

For incremental import continuation, cursor convergence is authoritative:

```text
source-scoped source MAX(rowid) == ledger MAX(source_rowid)
→ no newer source-local rows are waiting to import
```

Count divergence is diagnostic reconciliation evidence, not an execution gate.

For the message pilot, `MessageSyncState` is intentionally cursor-driven. A state such as:

```text
MessageSyncState.sourceAndLedgerCursorsMatch
messageCountDelta = -4
```

means the source-local cursor has caught up while the live source count and persistent ledger count differ by four rows. That difference should remain visible, but it must not by itself schedule import, block import, or imply importer failure.

Possible causes include:

- persistent import ledger behavior
- live-source deletions or pruning below the max rowid
- duplicate/conflict handling
- source and ledger snapshot queries counting different semantic populations
- future reconciliation concerns that are broader than incremental continuation

Practical rule:

```text
cursor drift controls continuation policy
count drift remains diagnostic until a separate reconciliation policy is defined
```

Do not hide count divergence. Surface it as diagnostic reconciliation information.

---

## Import Cursors Must Be Source-Scoped

Apple source `ROWID` values are source-local. There is no global `MAX(ROWID)` across multiple `chat.db` files or archived Messages-folder sources.

Continuation cursors must therefore be scoped by source identity and table concern:

```text
source_id
source_table or table context
source_rowid
```

For current shadow import tables, the table context may be implicit in the repository or importer:

```text
messages → source_id + source_rowid
handles  → source_id + source_rowid
chats    → source_id + source_rowid
```

The current live source identity is:

```text
source_id = live-chat-db
source_kind = live_chat_db
```

Practical rule:

```text
Never compute an import continuation cursor with an unscoped
MAX(source_rowid) across all sources.
```

If the ledger contains:

```text
live-chat-db source_rowid = 148528
archive-test source_rowid = 999999
```

then the live importer must continue from `148528`, not `999999`.

This preserves the distinction between source-local cursor evaluation and source-scoped working row identity:

```text
source_id + source_rowid = source-local continuation coordinate
SourceScopedRowKey = source-derived working row identity
guid or later grouping id = semantic dedupe/grouping evidence
```

Do not add a source registry or source-table schema churn merely to satisfy this invariant. The important rule is that cursor reads and source-ledger counts must be scoped to the source instance they are evaluating.

---

## Blocked Policy States Must Prevent Execution

For the message pilot:

```text
ImportDecision.doNothing
→ no execution

ImportDecision.blockAndReportLedgerAhead
→ no execution

ImportDecision.considerIncrementalImport
→ execution may be considered
```

A ledger-ahead condition is a safety block, not an import trigger.

For the shadow migration pilot:

```text
MigrationDecision.doNothing
→ no execution

MigrationDecision.blockAndReportProjectionAhead
→ no execution

MigrationDecision.considerShadowMigration
→ execution may be considered
```

A projection-ahead condition is a safety block, not a migration trigger.

---

## Dev Visibility Must Remain Observational

Developer-facing status panels and comparative logs may expose:

- polling status
- last refresh / transition time
- shadow import decision
- shadow migration decision
- comparison import outcome
- comparison migration outcome
- reason text

They must display already-derived facts and meanings. They must not become a separate source of semantic interpretation, production mutation, or scheduling authority.

---

## Message Evidence Must Flow Through the Evidence Spine

Message-bearing surfaces must converge on the shared Message Evidence Spine.

The canonical flow is documented in:

```text
69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
```

In short:

```text
MessageEvidenceScope
→ lightweight timeline skeleton
→ visible row hydration
→ render-ready attachment evidence
→ shared evidence timeline / row widgets
```

Source-specific scopes are allowed. Source-specific evidence presentation is not.

Hard rules:

- no new source-specific message renderer without explicit architectural review
- pagination is not timeline navigation
- timeline-like evidence scopes must preserve the full logical selected message universe even when hydration/media loading is windowed
- the skeleton is semantic timeline, heatmap coordination, jump/navigation, and temporal orientation infrastructure, not merely a performance cache
- timeline-like surfaces coordinate heatmaps, jumps, and anchors against the full lightweight skeleton
- hydration limits apply to visible rows, not to the selected logical message scope
- attachment policy must be resolved before widgets receive render-ready evidence

Visual changes to message evidence should usually be made in the shared evidence widgets, not in contact-, conversation-, search-, handle-, or recovered-specific surfaces.

---

# Execution Ownership Invariants

## Mutation-Producing Work Requires Explicit Ownership

Operations such as:

- import execution
- migration execution
- projection mutation
- attachment archival writes

should preferably occur under explicit execution ownership coordination.

Example:

```text
ImportExecutionGate
```

This exists to prevent:

- overlapping orchestration
- conflicting mutations
- inconsistent projection visibility

---

## Ownership Arbitration Should Be Observable

Execution ownership systems should preferably expose observable state.

Examples:

- current owner
- denied requests
- retry opportunities
- contention state

This improves:

- diagnostics
- causal traceability
- supportability
- orchestration visibility

---

# Human Comprehensibility Invariant

The architecture should remain explainable in human causal terms.

Humans should be able to reasonably answer:

```text
What facts were observed?
What meaning was derived?
What execution occurred?
Why did it occur?
Who owned execution?
```

If answering these questions becomes difficult, responsibility compression or orchestration opacity may be increasing.

---

# Architectural Compression Invariant

Responsibility compression should be treated as an architectural smell.

Examples:

- factual reads
- semantic reconciliation
- retry coordination
- execution ownership
- mutation execution
- state publication

all occurring inside one actor.

Some orchestration complexity is unavoidable.

The goal is not:

```text
elimination of complexity
```

The goal is:

```text
understandable complexity
```

---

# Architectural Evolution Invariant

This responsibility model is experimental.

It should evolve through:

- observation
- pilot implementations
- comparative validation
- incremental adoption

rather than wholesale immediate replacement of functioning production systems.

Architectural evolution should prioritize:

- reversibility
- observability
- safety
- incremental confidence
