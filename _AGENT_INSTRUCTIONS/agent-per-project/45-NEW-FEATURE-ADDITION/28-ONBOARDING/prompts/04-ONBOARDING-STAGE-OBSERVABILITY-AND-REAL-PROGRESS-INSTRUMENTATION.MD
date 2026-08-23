Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Prompt 03 correctly hit its stop conditions.

No watchdog was implemented because:

- Flutter macOS lifecycle signals do not reliably distinguish ordinary focus/visibility changes from true system sleep/suspension;
- all four current Onboarding stages lack complete measured no-progress contracts;
- existing graph observations cover only part of `messageDataBuild`;
- a timeout now could falsely classify legitimate coarse work or sleep as a stall.

That result is accepted.

The next prerequisite is therefore:

> **Make the actual Onboarding work observable before attempting to infer whether it has stalled.**

This task instruments the existing Onboarding pipeline with truthful, typed, real progress observations and profiles the remaining coarse work.

Do NOT implement a watchdog in this task.

Do NOT add arbitrary timeouts.

Do NOT implement Start Fresh yet.

Do NOT redesign the full Onboarding UI yet.

Do NOT add record quarantine yet unless instrumentation itself requires a typed record-outcome seam.

Suggested prompt name:

`04-ONBOARDING-STAGE-OBSERVABILITY-AND-REAL-PROGRESS-INSTRUMENTATION.MD`

# Governing principle

Apply:

> If MessageLens is doing countable work, expose the work.

and:

> Do not infer liveness from time when the operation can report liveness from completed work.

The immediate goal is to transform opaque stages into observable stages wherever the architecture supports real observations.

# Existing durable foundation

Prompt 02 established the canonical durable Onboarding operation snapshot:

- idle;
- running;
- interrupted;
- failed;
- completed;

with:

- typed stages;
- operation/process identity;
- real progress observation support;
- restart reconciliation;
- Presence projection;
- durable completion evidence.

Use that model.

Do not create a second progress authority.

# Prompt 03 blocker findings

Read the Prompt 03 blocker report first.

Treat its stage/liveness findings as authoritative unless current code disproves them.

The report identified four current Onboarding stages that do not yet have complete liveness contracts.

Map those exact stages by current type/name.

Do not rename them prematurely.

# First task — decompose every stage into actual work

For each of the four current stages, trace the implementation from stage entry to stage completion.

Build a detailed execution map showing:

- repositories/services called;
- database transactions;
- tables/entities processed;
- loops/batches;
- isolate work;
- graph operations;
- filesystem operations;
- coarse library calls;
- existing callbacks/streams;
- current durable checkpoints.

Identify every natural unit of completed work.

# Profile before instrumenting

Measure representative fixture/staging execution time for each actual suboperation.

Produce a table:

| Stage | Suboperation | Typical duration | Work units | Existing observation | Main/worker isolate | Instrumentable? |

The purpose is to identify what actually deserves instrumentation.

Do not instrument 5 ms operations simply because they exist.

# Real progress contract

For every perceptibly long enumerable operation, define a typed progress observation containing the smallest useful truth.

Conceptually:

- completed;
- total;
- optional unit kind.

Examples only where true:

- handles processed / total handles;
- contacts processed / total contacts;
- chats processed / total chats;
- messages processed / total messages;
- attachments processed / total attachments;
- reactions processed / total reactions;
- graph messages projected / total;
- conversation relations projected / total.

Use actual project terminology.

# Denominators

For every candidate observation classify the denominator as:

## Exact and already known

Use it.

## Exact and cheaply derivable before execution

Derive it.

## Expensive to determine

Do not perform a second full scan merely to create progress unless profiling justifies it.

## Fundamentally unavailable

Leave the operation coarse.

Do not fabricate totals.

# Numerators

A numerator advances only when real work has completed.

Do not increment when:

- a row is merely scheduled;
- a batch begins;
- a timer fires;
- a callback repeats the same state.

Define what “completed” means for each operation.

# Observation cadence

Do not publish every row when hundreds of thousands exist.

Use real batching.

Determine appropriate cadences from workload.

Historical Archives used, where appropriate:

- 250-row progress batches;
- 1,000-row matching batches.

These are precedents, not mandatory values.

Choose based on actual Onboarding work.

Always emit:

- 0 / total at start where truthful;
- periodic completed values;
- exact final total.

# Typed operation observations

Prefer typed observation contracts owned by the domain/service performing the work.

Do not have widgets inspect repositories and calculate progress.

Potential shape:

`OnboardingImportObservation`

with typed variants/substages.

Use repository conventions.

Do not create one giant generic progress object if stage-specific contracts are clearer.

# Preserve stage semantics

The durable top-level typed stage remains the human/operation boundary.

Suboperations are observations within that stage.

Do not turn every table import into a top-level Onboarding Journey stage solely because it now has a progress counter.

This distinction will later support:

Narrator = meaning/scope

Directed Instrumentation = factual work inside the scope.

# `messageDataBuild`

Prompt 03 specifically found that current graph row observations cover only part of `messageDataBuild`.

Audit this stage especially carefully.

Determine exactly what occurs before, during, and after the existing graph observations.

Identify opaque intervals.

Instrument all meaningful countable units where possible.

If one long coarse call remains, document it explicitly.

# Source import stage

Audit the import of Apple source data.

At minimum investigate whether progress can be exposed for:

- handles;
- chats;
- messages;
- attachments;
- reactions;
- contact-related evidence where part of this stage.

Do not assume table names map one-to-one to human-visible rows.

# Contact work

Determine whether Contacts processing belongs to the same stage or another.

If Contacts import can encounter malformed data, instrumentation should preserve enough context to know which domain stopped progressing later.

Do not expose contact names/PII in routine progress.

# Attributed-string decoding

This may be computationally significant.

Audit whether typedstream/attributed-string decoding occurs:

- per message;
- in the same message loop;
- in batches;
- through Rust/FFI.

If decoding can stall a single row, determine what progress observation exists immediately before/after it.

Do not add per-message logging.

The future anomaly-handling slice may need to know the failing record identity, but this task should only establish safe bounded diagnostic context.

# Handle normalization

Given the historical `*city*`/Hong Kong tester failure, inspect handle-processing loops.

Do not special-case the literal.

Ensure real progress tells us whether:

- handle processing began;
- N handles completed;
- a thrown record stops the stage.

A thrown error already maps to typed Failed through Prompt 02.

This task should make the failure location more precise.

# Graph preparation

Inventory existing graph observations.

Determine whether truthful progress is available for:

- participants;
- conversations;
- messages;
- attachments;
- relationships;

or whatever the Onboarding graph actually builds.

Reuse the same neutral graph projection contracts established elsewhere if they are genuinely shared.

Do not duplicate them.

# Filesystem/attachment preparation

Audit whether Onboarding performs:

- attachment archival;
- directory scanning;
- payload copying;
- metadata registration;
- derived media setup.

If long-running and countable, expose real:

- file count;
- byte count;

where cheaply available.

Do not hash merely for progress.

# Search/index preparation

If Onboarding builds FTS/search structures:

- profile duration;
- identify set-based counts or SQLite progress hooks if available;
- do not fake incremental progress if one SQLite statement is opaque.

If it is now fast enough to remain coarse, leave it coarse.

# Coarse operation classification

After instrumentation, every remaining >2–3 second opaque operation should be classified:

## Can be decomposed further

Instrument it.

## Single bounded library/database call

Measure it and document.

## External wait

Move conceptually out of “working” into waiting/blocker semantics for later presentation.

## Unobservable architecture gap

Document as explicit blocker for future liveness work.

Do not hide it.

# First-paint behavior

Instrumentation must not delay initial operation presentation.

For each user action beginning long-running Onboarding work:

typed running state
→ first frame paints
→ expensive work begins.

Audit current ordering.

Use an `endOfFrame` barrier only where necessary and consistent with established project architecture.

No arbitrary delays.

# Main-isolate responsiveness

Profile synchronous CPU work.

If instrumentation reveals multi-second main-isolate loops:

- optimize/restructure;
- move pure computation to worker isolate where architecture permits;
- or yield in bounded real-work batches.

Do not merely report progress from a blocked UI isolate that cannot paint it.

# Query architecture

Look for the same classes of pathology found in Features 26/27:

- N×M matching;
- per-row SQL;
- repeated full scans;
- repeated DB opens;
- duplicate provider execution.

If a long stage is slow because of a clear pathological query, fix the algorithm before adding more UI progress.

This prompt is pre-approved for bounded performance corrections discovered directly through profiling.

Do not redesign unrelated database architecture.

# Progress persistence

Prompt 02 persists bounded real observations.

Decide which observations should update the durable snapshot.

Do not persist every UI emission.

Recommended model:

service may emit frequent in-process observations
→ coordinator persists at bounded batch cadence / semantic milestones.

Use current snapshot write strategy.

Measure overhead.

# Same-value observations

Do not treat repeated identical counts as progress.

A real progress observation must advance work or transition substage.

This prepares future liveness inference.

Add tests.

# Substage transitions

A transition from one real suboperation to another is itself meaningful progress even if the next numerator begins at zero.

Represent this typed transition.

Future liveness can reset its contract on substage change.

# Presence seam

Do not redesign Onboarding Presence yet.

But expose enough typed data that Presence can later know:

- current top-level stage;
- current factual suboperation;
- last completed numerator/denominator;
- last real observation.

Do not persist display strings.

# Directed Instrumentation seam

Design projection-ready observations, but do not necessarily replace current UI yet.

The eventual UI should be able to render rows such as:

`Messages       42,500 / 137,340`

without deriving counts itself.

# Diagnostic context

When an operation fails, attach bounded safe context where available:

- stage;
- suboperation;
- last completed count;
- total;
- source row identifier only if necessary and non-PII/sanitized.

Do not log message text, contact names, or raw handles by default.

# Record identity caution

The upcoming anomaly-handling slice may require identifying a bad source row.

If current error propagation loses that identity, introduce a typed technical record reference such as:

- source table/domain;
- source ROWID;

without user-facing PII.

Do not yet decide skip/quarantine policy.

# Tester archetype

Build fixture tests representing:

- normal handle;
- unusual non-phone/non-email handle;
- malformed handle record;
- malformed message record;
- attachment anomaly.

For this task, the goal is:

normal/unusual valid record
→ progress continues.

malformed record that throws
→ progress stops at a known suboperation/count and typed Failed is recorded.

Do not yet continue past malformed records.

# One execution only

Prove instrumentation does not cause duplicate work.

Widget/provider rebuild must not:

- restart import;
- resubscribe in a way that duplicates DB writes;
- cause progress replay to look like new work.

Operation identity remains authoritative.

# Completion

Top-level stage completion must still derive from actual work completion.

Do not let:

`numerator == denominator`

alone advance durable completion if final transaction/verification still remains.

Exact final progress and stage transition are separate facts.

# Performance goals

Do not set arbitrary SLAs.

But classify:

- sub-second work: normally no visible instrumentation needed;
- 1–3 seconds: may show stage activity;
- > 3 seconds: should expose changing real evidence if possible;
- minutes: must expose substantive real progress or be decomposed/profiled further.

Record representative timings.

# Future liveness contract deliverable

The most important output of this task, beyond instrumentation, is a **new liveness-contract table**.

For every resulting suboperation report:

- expected observation;
- typical interval between observations;
- worst measured active interval;
- coarse/unobservable gaps;
- whether a future stall threshold is now defensible.

Do NOT implement thresholds yet.

Prompt 05 will decide whether liveness is now sufficiently observable.

# Tests

Add/update focused tests covering:

## Progress truth

1. start observation is truthful;

2. numerator advances only after completed work;

3. exact final numerator emitted;

4. same numerator does not count as new progress;

5. substage transition is typed.

## Source domains

6. handles progress;

7. messages progress;

8. attachments progress;

9. graph progress;

plus other real domains found.

## Failure context

10. stage failure preserves last real progress;

11. malformed record failure includes bounded domain/row context where available;

12. failure does not leave progress running.

## Persistence

13. bounded snapshot writes;

14. no per-row durable writes;

15. restart retains last durable progress evidence.

## UI responsiveness

16. first running state can paint before expensive work;

17. progress can be rendered during long fixture work;

18. main isolate is not blocked by newly instrumented loops.

## Architecture

19. UI cannot invent numerator/denominator;

20. no timer-driven progress;

21. canonical graph observation reused;

22. no duplicate provider execution.

Do not mechanically create one test method per number.

# Architecture tripwires

Protect:

- typed progress authority;
- no UI arithmetic;
- no heartbeat-as-progress;
- no raw progress strings as truth;
- no duplicate source-scoping/date conversion;
- no per-row durable snapshot writes;
- no new correlated/per-row database pathology.

# No watchdog

Do not add:

- `stalled`;
- timeouts;
- watchdog timers;
- sleep detection.

This task establishes evidence only.

# No Start Fresh

Do not wire the no-op Delete MessageLens App Data control.

# No quarantine

Do not skip malformed records yet.

Thrown malformed-record failures should now be better localized, but stage behavior remains fail-closed until the dedicated anomaly policy slice.

# Documentation

Create:

`04-ONBOARDING-STAGE-OBSERVABILITY-AND-REAL-PROGRESS-INSTRUMENTATION-IMPLEMENTATION.md`

Document:

- before/after execution map;
- profiling table;
- typed observation contracts;
- denominators;
- batching cadence;
- source-domain observations;
- graph observations;
- coarse operations remaining;
- performance corrections;
- first-paint behavior;
- persistence cadence;
- failure diagnostic context;
- new liveness-contract table.

Update canonical Onboarding/Presence/import guidance.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- import/source tests;
- graph projection tests;
- Onboarding snapshot tests;
- progress observation tests;
- failure routing tests;
- provider/session tests;
- maintenance/readiness tests;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- instrumentation requires schema migration;
- canonical repositories cannot expose progress without major redesign;
- adding observations materially slows import;
- a long operation remains opaque because its underlying library offers no safe seam;
- correct instrumentation requires changing record failure policy.

Document such gaps rather than inventing fake progress.

# Final report

Report:

- exact top-level stages;
- exact instrumented substages;
- denominators and numerators;
- observation batching;
- stage timings before/after;
- performance fixes;
- remaining coarse/unobservable work;
- failure diagnostic context;
- durable snapshot write cadence;
- new liveness-contract table;
- whether future stall detection is now safe for any subset of stages;
- full verification;
- commit hash;
- recommendation for Prompt 05.

Acceptance standard:

> Onboarding should expose real completed work wherever its pipeline actually has countable work. By the end of this slice, we should know precisely which stages are visibly advancing, which are legitimately coarse, and whether enough real evidence now exists to reason about stalls without guessing from a spinner or from wall-clock time.

The nice part here is that even if we ultimately decide a generic watchdog is impossible, this work is still directly valuable. A tester watching `Messages 84,000 / 137,000` advance does not need a watchdog to know MessageLens is alive. And if it stops permanently at `84,231`, we will know _where_ to look.
