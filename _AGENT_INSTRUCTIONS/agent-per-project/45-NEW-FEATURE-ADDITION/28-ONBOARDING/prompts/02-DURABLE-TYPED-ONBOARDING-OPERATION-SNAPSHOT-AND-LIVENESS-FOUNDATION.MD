Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 28’s comprehensive audit identified four primary release blockers:

1. Option-launch **Delete MessageLens App Data** is currently a no-op.
2. Long-running Onboarding work has no durable liveness/watchdog contract.
3. One malformed source record can abort an entire import stage.
4. Abandoned/incomplete installations have no proven recovery path.

The audit recommends that the first implementation slice establish a:

> **typed, durable Onboarding operation snapshot containing truthful stage and liveness evidence.**

That recommendation is accepted.

This task builds that foundation.

Do NOT implement Start Fresh yet.

Do NOT wire Delete MessageLens App Data yet.

Do NOT implement record quarantine yet.

Do NOT redesign the Onboarding UI broadly.

Suggested prompt name:

`02-DURABLE-TYPED-ONBOARDING-OPERATION-SNAPSHOT-AND-LIVENESS-FOUNDATION.MD`

# Purpose

Current Onboarding can perform significant durable work without one canonical representation of:

- what Journey is underway;
- what real stage is current;
- which stages have completed;
- what work is actively progressing;
- when progress was last observed;
- whether human attention is required;
- whether an operation failed;
- whether an interrupted installation can resume.

That makes graceful recovery difficult and permits the worst tester experience:

> work stops, but the UI cannot distinguish “still running” from “failed” from “waiting for me.”

Before introducing watchdogs, retry, quarantine, Start Fresh, or richer Presence, establish one authoritative operation snapshot.

# Governing principle

Apply:

> Durable operational truth must be representable independently of the widget currently displaying it.

And:

> Presentation may describe durable truth, but presentation state must never become the authority for whether Onboarding is running, interrupted, failed, resumable, or complete.

# Read first

Read:

- Feature 28 audit;
- current Onboarding coordinator/state;
- Presence persistence architecture;
- Environment Readiness;
- import/source migration orchestration;
- archive mutation coordinator;
- working/import database lifecycle;
- current progress providers;
- current Onboarding completion checks;
- canonical Presence Journey/Episode/Moment guidance;
- Historical Archives typed-state/session work as precedent, without copying it mechanically.

Before editing, map every existing field/type currently used to represent:

- onboarding phase;
- import stage;
- progress;
- failure;
- completion;
- retry;
- maintenance;
- persisted Presence state.

Identify duplicated authorities.

# Journey versus operation snapshot

Do not conflate human-facing Journey with low-level database implementation.

The durable snapshot should describe consequential Onboarding work at the level necessary to recover/reason safely.

A likely conceptual distinction:

## Journey state

Where the human is in Onboarding.

## Operation snapshot

What admitted durable work is currently doing or last did.

The exact architecture should follow current code.

Do not invent a generic workflow framework.

# Required durable semantics

The canonical snapshot must be able to represent at minimum:

## Idle / no admitted operation

No Onboarding mutation currently executing.

## Running

A known operation/stage is active.

Must include truthful liveness evidence.

## Interrupted

Durable work began previously but is no longer executing in the current process/session and completion has not been proven.

This must be distinguishable from Running.

## Failed

A typed operation failure occurred.

Must preserve:

- stage;
- completed durable work where known;
- failure evidence;
- retry/resume capability evidence.

## Completed

The operation reached its durable completion invariant.

Do not infer completion from UI progress.

If additional states are required, define them explicitly.

# Typed stage model

Audit the actual Onboarding execution pipeline and introduce one typed stage vocabulary.

Do not persist arbitrary strings such as:

`"Importing messages..."`

as operation truth.

Stages should correspond to real operational boundaries.

Use actual code evidence.

Potential concepts might include, where true:

- environment preparation;
- source inspection;
- import/source facts;
- graph projection;
- attachment preparation;
- final verification.

Do NOT mechanically expose every repository/table operation as a top-level stage.

The type should support future projection into human Episodes and Directed Instrumentation.

# Operation identity

Every admitted Onboarding operation must have a unique process/durable identity sufficient to distinguish:

old interrupted run

from:

new current run.

Determine whether an existing Journey/session/operation ID should be reused.

Do not create competing IDs unnecessarily.

The identity should prevent stale progress from a previous attempt being interpreted as current execution.

# Liveness evidence

The snapshot must contain enough truthful evidence to answer:

> Has this operation made observable progress recently?

Potential fields:

- operation started time;
- stage started time;
- last progress observation time;
- last completed work unit/count;
- current numerator/denominator where known;
- current durable checkpoint.

Do not make elapsed time itself progress.

A timestamp means:

> last evidence of progress occurred then.

It does NOT mean:

> operation is 67% complete.

# Progress evidence

Persist only useful bounded progress facts.

For each stage determine whether numerator/denominator is:

- exact;
- unavailable;
- process-only.

Do not persist massive per-record logs.

The snapshot should survive restart without becoming a second import ledger.

Durable databases remain authoritative for actual imported facts.

# Heartbeat caution

Do NOT solve liveness by writing a timer heartbeat every second.

That would merely prove that an event loop is alive, not that work is progressing.

Liveness observations should come from real execution progress where possible.

If a coarse operation has no granular observation, stage entry plus bounded underlying call state may be all that exists.

Document limitations.

# Persistence authority

Determine the correct storage for the snapshot.

Audit whether current Presence persistence is appropriate.

Requirements:

- MessageLens-owned;
- survives process restart;
- lightweight;
- does not require opening a database whose maintenance state makes it unsafe;
- can be read early enough during launch to reconcile interrupted Onboarding;
- does not become a dependency cycle with Environment Readiness.

Do not casually add a schema/database.

If existing Presence storage cleanly owns this, use it.

If schema change is genuinely required, STOP and report before implementing.

# Snapshot is not a transaction journal

Do not use the snapshot as evidence that rows were imported.

For example:

snapshot says `messages 42,000 / 100,000`

must not substitute for:

actual import database truth.

On restart:

durable repositories

- operation snapshot
  → reconciliation.

Durable database truth wins if they conflict.

# Atomic stage transitions

Where feasible, operation-stage publication should be coherent.

Avoid visible/persisted intermediate combinations such as:

old stage marked complete
but new stage not yet established
while work has already begun.

Use typed replacement/transition APIs rather than unrelated field mutation.

# Stage transition API

Create a narrow owned API conceptually capable of operations such as:

- begin operation;
- enter stage;
- report progress;
- complete stage;
- fail operation;
- mark interruption/reconcile;
- complete operation.

Use repository naming conventions.

Do not let random repositories write snapshot fields directly.

# Mutation authority integration

Trace how Onboarding executes under `ArchiveMutationCoordinator`.

The snapshot must know enough to identify admitted work without becoming mutation authority itself.

Do NOT duplicate capability/admission logic.

Desired relationship:

mutation authority determines **whether work may execute**.

operation snapshot records **what admitted work is doing**.

# Process restart reconciliation

On launch, if a durable snapshot says:

`Running`

but no originating process can still be executing, current state cannot remain Running indefinitely.

Define reconciliation.

Conceptually:

persisted Running from previous process
→ Interrupted
→ inspect durable authoritative state
→ determine resumable / completed / failed / inconsistent.

Do not mark failed merely because the app quit.

Do not mark complete merely because progress was near denominator.

# App quit/crash behavior

The application does not need to persist a special “I am about to crash” event.

The persisted snapshot plus new-process reconciliation should make interrupted work detectable mechanically.

Normal graceful shutdown may add clarity where safe, but correctness must not depend on it.

# Sleep/wake

Do not classify sleep as interruption merely because wall-clock time advances.

This is an important future watchdog requirement.

Liveness must distinguish:

no execution opportunity

from:

execution opportunity but no progress.

Do not implement the final watchdog yet, but structure timestamps/evidence so it can make this distinction later.

# Human-attention evidence

Audit whether operation snapshot should include:

`attentionRequired`

or whether that belongs solely to typed Journey state.

Prefer not to mix presentation concerns.

However, a durable blocker requiring human action may need a durable typed reason.

Define ownership carefully.

# Failure evidence

Do not persist raw stack traces as primary operation truth.

Use typed failure/category plus bounded sanitized diagnostics.

Unexpected internal failures may retain technical detail through existing diagnostic logging.

The snapshot must at least identify:

- operation;
- stage;
- failure category;
- occurrence/time;
- whether durable completion was reached.

# No swallowed failure

Wire all currently owned top-level Onboarding operation futures/streams so an unexpected terminal exception produces:

typed `Failed` snapshot

rather than:

provider remains loading / spinner remains forever.

Do not fix individual record-level errors here unless required to route them into the top-level failure boundary.

This slice establishes the escape hatch.

# Completion invariant

Audit current completion truth and define the exact event that may transition snapshot to Completed.

The operation may become Completed only after established durable readiness checks succeed.

Do not use:

- last stage callback;
- progress numerator == denominator alone;
- UI completion animation.

# Presence integration

Audit how persisted operation snapshot should inform Presence.

Do not redesign Presence UI yet.

Establish a projection seam so future work can derive:

- “working”;
- “interrupted”;
- “needs attention”;
- “failed”;
- “done”

from typed truth.

Do not persist Narrator strings.

# Existing presentation compatibility

Keep current Onboarding UI functioning.

This task may adapt current providers to read/project the new typed snapshot, but do not broadly redesign screens.

The human-facing transformation comes later.

# Architecture tripwires

Add protections proving:

1. one canonical durable Onboarding operation snapshot authority exists;

2. stage truth is typed, not display-string driven;

3. UI does not directly mutate durable operation stage;

4. progress timestamps derive from real observations;

5. no timer heartbeat masquerades as progress;

6. persisted Running from another process cannot remain indefinitely Running on relaunch;

7. Interrupted is distinct from Failed;

8. snapshot completion cannot occur before durable readiness/completion truth;

9. operation snapshot cannot authorize database mutation;

10. mutation coordinator remains mutation authority;

11. Narrator strings are not persisted as operational truth;

12. raw progress snapshot cannot substitute for import/database truth.

# Tests — state model

Add focused tests for:

- begin operation;
- stage transition;
- real progress observation;
- failure;
- completion;
- interruption;
- restart reconciliation;
- stale operation identity;
- durable truth overriding stale snapshot.

# Tests — failure routing

Prove at least top-level examples where:

- synchronous stage exception;
- async Future failure;
- progress stream failure;

all leave a terminal typed snapshot rather than permanent Running.

Do not yet solve record-level policy.

# Tests — restart

Simulate:

running snapshot
→ new process/session
→ reconciliation
→ interrupted.

Then test cases where authoritative durable state proves:

- operation actually completed before crash;
- operation is resumable;
- operation is inconsistent/failed.

Use existing fixtures.

# Tests — maintenance

Ensure reading/reconciling snapshot does not open protected working/import databases during admitted maintenance improperly.

Reuse established readiness rules.

# Performance

Snapshot writes must be lightweight.

Do not write on every row if import processes hundreds of thousands of records.

Use existing batch observation cadence.

Measure write volume on representative fixture.

Operation progress should remain significantly cheaper than the work it observes.

# Start Fresh preparation

Do not implement Start Fresh.

But ensure the snapshot can later distinguish:

- no journey;
- incomplete/interrupted operation;
- completed installation.

Do not make the snapshot the sole installation-state authority.

It will contribute evidence to the later typed installation-state model.

# No-op Delete App Data

Do not wire the no-op control in this slice.

Add a documentation/tripwire note if needed ensuring no future agent mistakes it for working functionality.

Its implementation belongs after the Fresh/abandoned-state model is established.

# Record anomaly preparation

Do not quarantine malformed records yet.

But ensure a stage-level exception from such a record now results in:

- typed Failed operation;
- stage identity preserved;
- liveness no longer claims Running;
- future UI can explain/retry.

This is the minimum immediate safety improvement.

# Forever-spinner preparation

After this slice, every top-level spinner-owning Onboarding operation should be projectable from typed operation state.

A terminal exception must therefore have a terminal state.

This does not yet solve genuine hung calls.

That is the next liveness/watchdog slice.

# Documentation

Create the next Feature 28 implementation record:

`02-DURABLE-TYPED-ONBOARDING-OPERATION-SNAPSHOT-AND-LIVENESS-FOUNDATION-IMPLEMENTATION.md`

Document:

- old state/progress authorities;
- final snapshot model;
- persistence location;
- typed stages;
- operation identity;
- liveness evidence;
- progress write cadence;
- failure routing;
- restart reconciliation;
- completion invariant;
- Presence seam;
- mutation-authority separation;
- limitations intentionally deferred.

Update canonical Onboarding/Presence documentation where the new model becomes authoritative.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules if application code changes.

# Verification

Run:

- Onboarding state/coordinator tests;
- Presence persistence tests;
- import pipeline tests;
- restart/resume tests;
- maintenance/readiness tests;
- mutation-coordinator tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- durable snapshot requires a schema change not already sanctioned;
- existing Presence persistence cannot safely store it and no canonical alternative exists;
- completion truth is ambiguous;
- mutation authority would need redesign;
- current Onboarding has multiple conflicting operation coordinators requiring a broader architecture decision.

Do not create a second competing state system just to finish the task.

# Final report

Report:

- final snapshot type and variants;
- persistence authority;
- typed stage vocabulary;
- operation identity semantics;
- liveness/progress fields;
- write cadence;
- restart reconciliation behavior;
- top-level failure routing;
- durable completion rule;
- Presence integration seam;
- architecture tripwires;
- full verification;
- commit hash;
- exact remaining blocker recommended for Prompt 03.

Acceptance standard:

> After this slice, MessageLens must be able to distinguish “Onboarding is actively making progress,” “the previous run was interrupted,” “Onboarding failed in this specific stage,” and “Onboarding durably completed” without relying on whichever screen happens to be visible. A terminal operation error must never leave the canonical state saying that work is still running.
