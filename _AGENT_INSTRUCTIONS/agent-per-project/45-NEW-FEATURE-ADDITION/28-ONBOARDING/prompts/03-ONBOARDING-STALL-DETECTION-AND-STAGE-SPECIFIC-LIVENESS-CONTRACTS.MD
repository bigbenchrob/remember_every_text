Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 28 now has a durable typed Onboarding operation snapshot with:

- `idle`
- `running`
- `interrupted`
- `failed`
- `completed`

plus:

- typed stages;
- operation/process identity;
- real progress observations;
- restart reconciliation;
- Presence projection;
- durable completion evidence;
- mutation authority remaining with `ArchiveMutationCoordinator`.

The next release blocker is:

> distinguishing genuine stalled execution from sleep, app suspension, coarse but legitimate work, or stages that simply have no granular progress signal.

This task implements **bounded, stage-specific liveness/stall detection**.

Do NOT implement Start Fresh yet.

Do NOT redesign Onboarding presentation broadly.

Do NOT add record quarantine yet.

Suggested prompt name:

`03-ONBOARDING-STALL-DETECTION-AND-STAGE-SPECIFIC-LIVENESS-CONTRACTS.MD`

# Governing principle

Do NOT define:

> no progress for N seconds = failure

globally.

Instead:

> A stage may be considered stalled only when that stage’s own execution contract says observable progress should have occurred, the process had a genuine opportunity to execute, and no such progress occurred within a stage-specific bound.

The watchdog must understand:

- typed stage;
- real progress evidence;
- execution opportunity;
- suspension/sleep;
- process restart;
- legitimate coarse operations;
- terminal failure/completion.

No heartbeat timers masquerading as progress.

# Core product requirement

A tester must never remain indefinitely in:

- spinner;
- working state;
- “still processing” narration;

when the underlying operation has stopped making meaningful progress.

But MessageLens must also never falsely accuse a healthy operation of being stalled merely because:

- the Mac slept;
- the process was suspended;
- the stage performs one long database call with no intermediate callback;
- the system was busy but work remained alive.

# Read first

Read:

- Feature 28 audit;
- Prompt 02 durable snapshot implementation;
- current typed Onboarding stages;
- existing import/projection progress observation seams;
- Presence projection;
- ArchiveMutationCoordinator;
- macOS lifecycle/sleep/wake handling;
- background/isolate execution paths;
- current Onboarding progress UI;
- database busy timeout behavior;
- Historical Archives performance/liveness work as precedent.

Before editing, create an explicit liveness inventory for every long-running Onboarding stage.

# Stage-by-stage liveness table

For each typed stage document:

- operation performed;
- typical duration;
- worst expected duration from fixtures/current evidence;
- progress signal available;
- numerator;
- denominator;
- observation cadence;
- whether the stage blocks in one coarse call;
- whether execution occurs on main isolate / worker isolate / SQLite;
- whether sleep/suspension pauses expected progress;
- safe stall threshold;
- safe recovery action.

Do not assign a timeout to a stage until this table justifies one.

# Classify stage liveness

Classify each stage into one of:

## Granular observable

Examples:

- rows processed;
- messages imported;
- attachments copied;
- graph entities projected.

Stall detection may use lack of real progress.

## Coarse but bounded

A stage performs one known operation with no incremental progress but has a defensible maximum expected execution duration.

Use bounded completion timing only if architecture supports it.

## Externally blocked / wait state

The operation may legitimately wait for:

- permission;
- external database availability;
- user action;
- another admitted operation.

This is NOT a stall.

Project it as waiting/attention-required.

## Unobservable/unbounded

No truthful stall determination can currently be made.

Do not invent one.

Document as a gap and expose that stage accordingly.

# Execution opportunity

Wall-clock time alone is not enough.

Introduce/reuse a concept that tracks whether the app/process had actual opportunity to run.

Audit available lifecycle signals:

- app active/inactive;
- suspended;
- sleep;
- wake;
- process restart.

The watchdog should pause or discount liveness elapsed time while execution opportunity is absent.

Do not persist “five minutes elapsed” across a two-hour laptop sleep as evidence of stall.

# Monotonic execution time

Where practical, use monotonic/process execution timing for in-process liveness decisions rather than wall-clock timestamps.

Persisted snapshots may retain wall-clock observation times for diagnostics/restart, but in-process stall thresholds should not be vulnerable to clock changes.

Use existing platform/runtime facilities.

Do not invent a custom timer subsystem if Dart/system clocks already provide appropriate semantics.

# No heartbeat timer

Explicitly prohibit:

`Timer.periodic(...) → update lastAlive`

unless that timer is merely scheduling watchdog evaluation and not claiming work progressed.

A heartbeat proves only that the event loop executed.

Liveness must derive from:

- changed numerator;
- completed batch;
- stage transition;
- underlying operation completion;
- other real work evidence.

# Watchdog evaluation

Create a narrow Onboarding-owned watchdog/liveness evaluator.

It should consume:

- current operation snapshot;
- stage liveness contract;
- latest real progress observation;
- execution opportunity;
- process identity/session.

It should produce a typed conclusion such as conceptually:

- healthy;
- waiting;
- stalled;
- indeterminate.

Use project naming conventions.

Do not put watchdog logic in widgets.

# Stalled state ownership

Determine whether `stalled` belongs as:

- a new durable operation snapshot variant;
- a typed failure subtype;
- an attention state derived from `running`.

Prefer the smallest model that preserves truth.

Important:

A stall is not necessarily an operation failure yet.

It means:

> MessageLens expected real progress from this stage and has not observed it within the stage’s contract.

The system may still support:

- automatic retry;
- user retry;
- cancellation;
- restart/resume.

Do not classify stalled as completed or failed without evidence.

# Persistence of stall evidence

If stall becomes durable, retain bounded evidence:

- operation ID;
- stage;
- last real progress observation;
- last numerator/denominator;
- execution-opportunity duration since progress;
- detected-at time;
- watchdog contract/version.

Do not persist huge logs.

# Automatic recovery

Audit whether any stalled stage can safely self-retry.

Examples might include:

- transient SQLite contention;
- stale read-only query;
- retryable source access.

Do not automatically retry mutations unless idempotency and authority are proven.

If automatic retry exists:

- limit attempts;
- record occurrences;
- do not loop forever;
- expose eventual human-visible blocker.

# Human retry

For stages where retry is safe:

stalled
→ human chooses Retry
→ new operation identity or explicit retry attempt
→ reconcile durable truth first
→ resume/restart at safe boundary.

Do not simply rerun the same closure blindly.

# Cancellation

Audit whether a stalled operation can be cancelled safely.

Do not promise Cancel if:

- underlying SQLite call cannot be interrupted safely;
- mutation may be mid-transaction;
- worker isolate termination could violate storage invariants.

Where cancellation is not safe, the future UI should say what MessageLens can actually do.

# Database busy/lock conditions

Map existing SQLite busy timeout behavior.

Distinguish:

- legitimate bounded contention;
- maintenance-authority block;
- true stalled query;
- deadlock/invariant failure.

Do not let watchdog compete with canonical busy timeout.

A busy timeout exception should route through normal typed failure if the database contract already defines it.

# Worker isolate failure

Audit Onboarding worker isolates.

Ensure:

- isolate exits/crashes project typed failure;
- isolate hangs can be detected where progress contract supports it;
- abandoned isolate output cannot update a newer operation ID;
- watchdog does not misclassify isolate startup latency as stall without evidence.

# Stream/subscription liveness

For progress streams:

- completion must terminate running state;
- error must terminate running state;
- silence is evaluated only if contract expects emissions.

Search for streams that can silently stop emitting without closing.

Add tests.

# Stage-specific thresholds

Do not use one number for every stage.

Derive thresholds from:

- representative measured duration;
- observation batch cadence;
- expected I/O;
- generous safety margin.

For example conceptually:

stage normally emits every <1s
→ stall bound might be tens of seconds.

Do not use these example numbers blindly.

Record rationale per stage.

# Adaptive thresholds caution

Do not create complex statistical/adaptive timeout machinery unless clearly necessary.

Static stage-specific conservative bounds are preferable initially.

This is a safety feature, not an ML scheduler.

# Tester edge cases

Use the old tester failures as scenarios.

## Strange handle / `*city*`

If one bad record causes a stage to throw:

→ typed failure immediately.

If a bug causes the loop to stop advancing without throwing:

→ granular stage watchdog should detect no-progress.

Do not special-case the handle string.

## Permission/iCloud prerequisite

These should be waiting/blocker states, not stall.

Watchdog must not fire while waiting for human/external condition.

# Presence integration

Expose a typed projection seam for Presence.

Future human meaning should support:

## Healthy work

“I’m working through your message history.”

## Waiting for human

“I need you to change a setting before I can continue.”

## Stalled

“I expected this step to keep moving, but it hasn’t.”

Do not implement final copy yet.

The important thing is that Presence can distinguish these states mechanically.

# Directed Instrumentation integration

For granular stages, preserve real counts.

When watchdog flags a stall, future presentation should be able to show:

- last known progress;
- stage;
- whether any previous stages completed.

Do not fake continued animation after stall detection.

# No spinner forever invariant

Add architecture tests/tripwires proving:

> Every indeterminate-spinner Onboarding state is backed by either:
>
> - a bounded stage contract;
> - a waiting/attention-required state;
> - or a typed unobservable state that does not falsely imply ongoing progress forever.

Where possible, remove truly unbounded spinner ownership.

Do not redesign full UI yet.

# Process restart

Persisted `running` from an old process already reconciles to `interrupted`.

Watchdog must only judge current-process execution.

Do not mark old-process work `stalled` after launch merely because its last progress timestamp is old.

Restart semantics remain:

old running
→ interrupted
→ durable reconciliation.

# Sleep/wake tests

Add explicit tests.

Simulate:

progress at T0
→ app loses execution opportunity for a long interval
→ resumes
→ watchdog should NOT immediately report stalled solely due to wall-clock gap.

Then:

execution resumes
→ no progress for stage-specific active-execution bound
→ stalled.

# App inactive but running

Audit macOS lifecycle nuance.

If the app is inactive/backgrounded but still executing, decide whether that counts as execution opportunity.

Base this on actual runtime behavior, not assumptions.

Document.

# Performance overhead

Watchdog evaluation must be cheap.

Do not write durable snapshots every second.

Recommended shape:

- progress producers publish at existing real-work cadence;
- watchdog evaluates in-memory periodically or on observation/lifecycle events;
- durable state changes only when semantic state changes or progress batch is already persisted.

Measure overhead.

# Logging/diagnostics

When stall is detected, log bounded diagnostics:

- operation ID;
- stage;
- last progress;
- execution-opportunity duration;
- relevant timeout/contract;
- retryability;
- process ID/session.

Do not log message contents or raw PII.

# Tests — granular stage

Prove:

- progress resets stall clock;
- unchanged numerator does not count as progress;
- repeated observation with same value does not falsely reset liveness;
- stage transition resets contract;
- completion cancels watchdog;
- failure cancels watchdog.

# Tests — sleep/suspension

Prove:

- long sleep does not cause immediate stall;
- wall-clock jump does not cause false stall;
- active execution without progress eventually stalls.

# Tests — waiting states

Prove:

- permission wait never becomes stalled;
- maintenance wait never becomes stalled;
- human-attention state never runs execution watchdog.

# Tests — process/session

Prove:

- stale watchdog callback from old operation ID cannot mutate new operation;
- stale process identity rejected;
- restart yields interrupted, not stalled.

# Tests — failures

Prove:

- thrown stage failure becomes failed, not stalled;
- busy timeout follows typed failure semantics;
- isolate error becomes failed;
- genuinely silent no-progress path becomes stalled.

# Architecture tripwires

Add protections ensuring:

1. no global one-size-fits-all timeout;

2. no heartbeat updates `lastProgress`;

3. stall only evaluates current-process running operations;

4. waiting states excluded;

5. sleep/suspension excluded from execution-opportunity elapsed time;

6. repeated same numerator does not count as progress;

7. watchdog cannot mutate database or authorize work;

8. stale watchdog cannot affect new operation/session;

9. stalled state retains last real progress evidence;

10. completion/failure disable watchdog ownership.

# No Start Fresh yet

Do not wire Delete MessageLens App Data.

Do not implement abandoned-install remediation.

This liveness layer is a prerequisite for trustworthy resume/recovery behavior.

# No record quarantine yet

Do not change per-record failure policy.

That is likely the next major slice after liveness.

This task only ensures:

- thrown record-stage failures become terminal typed failures;
- silent no-progress failures can become typed stalls where contract permits.

# Documentation

Create:

`03-ONBOARDING-STALL-DETECTION-AND-STAGE-SPECIFIC-LIVENESS-CONTRACTS-IMPLEMENTATION.md`

Document:

- stage liveness table;
- stage classification;
- execution-opportunity model;
- monotonic timing approach;
- watchdog architecture;
- stall state semantics;
- thresholds and rationale;
- sleep/wake behavior;
- waiting-state exclusions;
- retry/cancel findings;
- Presence projection;
- diagnostic evidence;
- known unobservable stages.

Update canonical Onboarding/Presence docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules if application code changes.

# Verification

Run:

- Onboarding operation snapshot tests;
- watchdog/liveness tests;
- lifecycle/sleep tests;
- import progress tests;
- worker-isolate tests;
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

- current platform lifecycle cannot distinguish sleep/suspension from active execution sufficiently for safe stall detection;
- major stages have no observable progress and no defensible bound;
- adding watchdog requires invasive runtime/task infrastructure;
- cancellation/retry semantics require mutation-authority redesign;
- liveness persistence requires schema changes.

Do not create false certainty.

# Final report

Report:

- final stage liveness table;
- which stages are granular/coarse/waiting/unobservable;
- watchdog type/location;
- execution-opportunity model;
- stall semantics;
- stage thresholds;
- sleep/wake behavior;
- automatic/human retry policy;
- cancellation findings;
- Presence projection;
- tests/tripwires;
- full verification;
- commit hash;
- exact recommended Prompt 04 blocker.

Acceptance standard:

> Onboarding must distinguish “this stage is legitimately taking time” from “this stage has stopped making the progress its contract says it should make,” without treating sleep, suspension, waiting for the human, or mere wall-clock passage as failure. A genuine no-progress stall must become a typed, diagnosable state rather than an endless spinner.
