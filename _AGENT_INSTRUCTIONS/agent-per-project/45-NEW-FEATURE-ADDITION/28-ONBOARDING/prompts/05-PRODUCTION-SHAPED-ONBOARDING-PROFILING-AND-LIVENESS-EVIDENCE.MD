This is a strong result. We now have something old Onboarding conspicuously lacked: **real, inspectable movement through the intake pipeline**.

The most valuable change may be the apparently mundane one:

> `Messages  42000 / 137000`

That single factual counter does more for trust than an animated spinner ever could. And because the observations are typed, persisted, batched, and attached to real completed work, they can also support failure diagnosis and later Presence without becoming presentation-owned fiction.

Codex was also right to stop short of watchdog thresholds. We now know _what_ can move; we still need realistic evidence for **how long healthy movement can legitimately pause**. So Prompt 05 should be a controlled production-shaped profiling exercise rather than another architecture pass.

The goal should be to answer two things:

1. What are the real durations and maximum observation gaps during a large healthy first import?
2. After seeing those measurements, do we even need formal stall detection everywhere, or does truthful Directed Instrumentation already solve most of the human problem?

I’d proceed with this:

Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a controlled profiling/instrumentation exercise and bounded performance corrections.

Do NOT define watchdog thresholds yet.

Do NOT add timeout/stalled states yet.

Do NOT implement Start Fresh yet.

Do NOT implement malformed-record quarantine yet.

Suggested prompt name:

`05-PRODUCTION-SHAPED-ONBOARDING-PROFILING-AND-LIVENESS-EVIDENCE.MD`

# Context

Feature 28 now has:

- durable typed Onboarding operation snapshots;
- typed top-level stages;
- typed real-work substages;
- operation/process identity;
- restart reconciliation;
- typed failure evidence;
- real progress observations;
- bounded durable persistence;
- factual current overlay presentation such as:

  `Messages  42000 / 137000`

Current top-level stages are:

- `environmentPreparation`
- `messageDataBuild`
- `durableReadinessVerification`
- `automaticRecoveryReset`

Prompt 04 added observable substages covering:

- source imports;
- rich-text extraction/persistence;
- relationships;
- graph projections;
- reset/preparation;
- verification.

Enumerable work reports:

- `0 / total`;
- every 1,000 completed records;
- exact completion.

Prompt 04 correctly concluded that stall detection is still not safe because we lack production-scale evidence about:

- normal stage duration;
- maximum healthy gap between real progress observations;
- coarse suboperations;
- main/worker-isolate scheduling behavior;
- real database/file-system contention.

This task gathers that evidence.

# Governing rule

Do not guess timeout values from fixture performance.

Measure a **production-shaped healthy initial import** first.

The goal is not:

> “Find a timeout.”

The goal is:

> “Understand what healthy execution actually looks like.”

Only then decide whether a watchdog is justified.

# Safety

Do not mutate production data.

Use an explicit disposable staging/test environment equivalent in scale/shape to a real first import.

Do not operate against the user's primary MessageLens archive.

Do not alter live `chat.db`.

If a production-shaped source must be read from the current Mac, use the established read-only source architecture and write only into a disposable MessageLens staging environment.

Respect archive-environment markers and mutation authority.

# First — define profiling environment

Document exactly what environment will be used.

It should resemble a real first-time Onboarding run in:

- message count;
- handle count;
- chat count;
- attachment count;
- reactions;
- rich-text volume;
- graph size.

Prefer an existing safe staging clone/source setup over synthetic tiny fixtures.

Do not fabricate a gigantic benchmark dataset if representative safe data already exists.

# No human destructive preparation

Do not ask the user to delete their current MessageLens setup for this profiling task.

If a clean staging root can be created canonically, use it.

If obtaining production-shaped first-import behavior requires unsafe/manual deletion of user data, STOP and report.

# Profile the full Journey

Measure from the point consequential Onboarding work begins through durable readiness completion.

Capture:

- top-level stage start/end;
- substage start/end;
- progress observations;
- process/isolate placement;
- database transaction boundaries;
- pauses between substages;
- final durable verification.

Use monotonic in-process timing for interval analysis where possible.

Wall-clock timestamps may be retained for correlation only.

# Required timing table

Produce a table like:

| Stage | Substage | Total work | Duration | Median observation gap | Max observation gap | Main/worker | Notes |

Use actual measurements.

For enumerable work also report:

- first progress latency;
- progress cadence;
- longest healthy interval with unchanged numerator;
- final-observation-to-stage-transition delay.

# Critical question — first visible progress

For each long stage measure:

action/stage entry
→ first truthful progress observation.

This matters greatly to human perception.

A stage may complete in 30 seconds but still feel dead if its first changing evidence arrives after 20 seconds.

Identify all gaps >2–3 seconds before first progress.

# Coarse substages

Prompt 04 left some work honestly coarse.

Profile each coarse substage individually.

Especially:

- reset/preparation;
- durable verification;
- fast set-based graph operations;
- any SQLite statement/library call with no callbacks.

Determine:

- actual duration;
- variance;
- whether it blocks the main isolate;
- whether it can be decomposed cheaply;
- whether it is fast enough to remain coarse.

Do not instrument 100 ms work merely for completeness.

# Long silent gaps inside observable work

Search for healthy intervals where:

- operation remains running;
- no numerator advances;
- no substage transition occurs.

For every significant gap determine why.

Possible causes:

- large transaction commit;
- FFI rich-text decode;
- SQLite index creation;
- filesystem latency;
- isolate startup;
- database checkpoint;
- provider scheduling;
- batch size too coarse.

Classify the cause.

# Rich-text extraction

Pay special attention to rich-text extraction/persistence.

Prompt 04 added a yield every 1,000 records.

Measure:

- batch duration;
- UI responsiveness;
- worker/main isolate behavior;
- longest batch;
- cost of yielding;
- malformed/nontrivial attributed-string cases.

If 1,000 is too coarse or unnecessarily fine, adjust based on evidence.

Do not optimize blindly.

# Handles and historical failure archetype

Profile handle intake.

Use representative unusual-but-valid handles where fixtures exist.

Determine:

- normal processing speed;
- whether one complex handle materially increases a batch gap;
- whether normalization is CPU/database bound.

Do not special-case `*city*`.

# Messages

Profile message import at production scale.

Measure:

- DB read;
- decode;
- transform;
- insert;
- batch commit;
- progress publication.

Find the dominant cost.

Look for per-row queries or repeated normalization.

# Attachments

Profile attachment metadata intake and any payload/archive work performed during initial Onboarding.

Measure:

- claim count;
- DB work;
- filesystem work;
- bytes if relevant.

Do not hash merely for profiling.

# Relationships / graph

Profile each graph suboperation.

Existing set-based graph operations may be fast but observe:

- Participants;
- Conversations;
- Messages;
- Attachments;
- Relationships;

where applicable.

If a set-based statement takes several seconds but has no internal progress seam, record that fact.

Do not decompose efficient SQL into slower row loops merely to create animation.

# Database contention

Introduce only safe controlled contention scenarios already supported by tests/staging.

Measure behavior under:

- brief SQLite busy contention;
- source WAL activity;
- expected Messages writes during read-only source access.

Do not manufacture dangerous deadlocks.

Record whether existing busy timeout/failure semantics are sufficient.

# Main-isolate responsiveness

During the profiling run, verify the UI event loop remains responsive.

Collect evidence for:

- long synchronous CPU blocks;
- Flutter frame starvation;
- beach-ball risk.

If a stage emits progress but the frame cannot paint it, the instrumentation is not useful.

Fix clear bounded issues.

# Duplicate/restarted work

Prove the profiling/instrumentation itself does not:

- run import twice;
- restart from provider rebuild;
- duplicate graph work;
- emit replayed observations as if new progress.

Operation identity must remain stable.

# Progress batching review

The current default is every 1,000 records.

Evaluate per domain.

Potential outcomes:

## Keep 1,000

if progress paints frequently enough and persistence/UI overhead is negligible.

## Increase batch size

if updates are excessively frequent.

## Decrease batch size

if healthy gaps become uncomfortably long.

Do not force the same batch size onto every domain if workload differs substantially.

The batch size is an observation cadence, not a semantic invariant.

# Durable snapshot write volume

Measure:

- total snapshot writes;
- writes per stage;
- write overhead;
- overlay_settings contention.

Remember identical observations already cause no revision/write.

Confirm persistence remains negligible relative to import work.

# Performance pathology permission

If profiling uncovers an obvious pathological implementation similar to prior features, you MAY fix it.

Examples:

- N×M scan;
- per-row SQLite query;
- repeated database open;
- duplicate conversion;
- blocking pure-Dart loop that can be batched;
- redundant full-table pass.

Requirements:

- preserve semantics;
- add regression test;
- document before/after timing.

Do not launch a broad optimization campaign.

# Controlled interruption observations

Without corrupting data, exercise safe interruption scenarios in staging where architecture supports them:

- navigate away;
- normal app quit between durable checkpoints;
- process restart after interrupted operation.

The goal is to confirm Prompt 02 snapshot/reconciliation behavior under a production-shaped run.

Do not kill the process mid-critical filesystem/database primitive unless established tests prove it safe.

# Sleep/wake evidence

Because Flutter lifecycle cannot reliably prove true sleep/suspension, do NOT use this task to invent sleep detection.

However, if a manual sleep/wake observation can be performed safely in staging and documented, note what signals are actually seen.

Do not base production watchdog behavior on one manual experiment.

# New liveness table

After profiling, update the Prompt 04 liveness-contract table with measured evidence.

For every substage report:

- typical duration;
- maximum observed healthy duration;
- typical progress interval;
- maximum observed healthy progress interval;
- first-progress latency;
- whether execution opportunity is observable;
- whether a future no-progress threshold is defensible.

Classify each:

### Threshold now defensible

Real progress is granular enough and healthy active gaps are bounded.

### Progress visible but threshold still unsafe

Human sees liveness, but platform execution-opportunity ambiguity prevents automated stall conclusion.

### Coarse but short

No watchdog needed.

### Coarse and long

Remaining architectural liveness gap.

### Waiting/external

Should never use execution watchdog.

# Watchdog decision is an OUTPUT, not implementation

At the end make one of these recommendations:

## A. Implement bounded stall detection for a subset of substages

Only if evidence supports it.

## B. Do not implement watchdog yet; real progress has solved the practical problem

This is a perfectly valid conclusion.

## C. One or more coarse long-running gaps must first be instrumented/refactored

Identify them.

Do not add watchdog code in this task even if A is recommended.

# Human perception review

Review the current Onboarding overlay with the production-shaped run.

Ask:

- Is there changing evidence during every long stage?
- Are any status lines stale?
- Are counts legible?
- Does the user know which broad task is underway?
- Is there any interval where the UI appears dead despite healthy work?

Do not redesign broadly.

Record what later Presence/UI work needs.

# Failure localization

Inject controlled fixture-level failures where safe and verify the durable snapshot captures:

- stage;
- substage;
- last count;
- total;
- bounded source-row context.

Especially test:

- malformed handle;
- malformed message;
- rich-text decoder failure;
- attachment error.

Do not add skip/quarantine behavior yet.

# No record policy change

A malformed record may still fail the stage.

This task is measuring/localizing it.

Prompt 06 or later will decide record-level failure policy.

# No Start Fresh

Do not implement reset UI.

# No watchdog

Do not add timeout or stalled state.

# Architecture tripwires

Add only evidence-supported protections, such as:

1. production progress remains real-work-driven;

2. provider rebuild cannot restart profiling/import work;

3. batch observations do not mutate operation semantics;

4. snapshot writes remain bounded;

5. long pure CPU loops yield or execute off main isolate where required;

6. no pathological query fixed here can regress to old form.

# Tests

Add/update focused tests for:

- batching cadence per adjusted domain;
- first observation;
- exact completion;
- production-shaped counts where fixture-safe;
- no duplicate execution;
- durable write coalescing;
- failure localization;
- restart reconciliation;
- any performance correction.

Avoid brittle CI microbenchmarks.

Use:

- operation/query counts;
- algorithmic assertions;
- generous bounded timings only where repository precedent supports them.

# Documentation

Create:

`05-PRODUCTION-SHAPED-ONBOARDING-PROFILING-AND-LIVENESS-EVIDENCE.md`

Document:

1. profiling environment;
2. source scale;
3. full Journey timing;
4. per-stage timing;
5. per-substage timing;
6. first-progress latency;
7. max healthy observation gaps;
8. main-isolate responsiveness;
9. DB/filesystem findings;
10. batching changes;
11. performance corrections;
12. durable snapshot write cost;
13. controlled interruption findings;
14. failure localization;
15. revised liveness table;
16. watchdog recommendation;
17. remaining liveness blockers;
18. recommended Prompt 06.

Update Feature 28 index/documentation log.

Update application version/changelog only if production code changes.

# Verification

Run:

- Onboarding progress tests;
- import tests;
- graph tests;
- rich-text tests;
- snapshot/persistence tests;
- interruption/restart tests;
- maintenance/readiness tests;
- architecture tripwires;
- full Flutter suite if code changes;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if code changes.

Commit/push according to repository rules.

# Stop conditions

STOP if:

- production-shaped profiling would require destructive use of production data;
- clean staging cannot be established safely;
- profiling changes would alter user data;
- source access requires bypassing TCC/security architecture;
- measurements cannot distinguish instrumentation overhead from actual work.

Report the limitation instead.

# Final report

Return:

- production-shaped data scale;
- total Onboarding duration;
- stage/substage timing table;
- maximum healthy observation gaps;
- first-progress latencies;
- any beach-ball/main-isolate findings;
- progress batching changes;
- performance fixes;
- snapshot-write overhead;
- controlled interruption findings;
- revised liveness classification;
- explicit watchdog recommendation A/B/C;
- next release blocker to address;
- tests/verification;
- commit hash.

Acceptance standard:

> Before MessageLens decides that Onboarding has stalled, we must know what a healthy real-sized Onboarding run actually looks like. This slice should replace timeout intuition with measured stage and progress behavior—and may show that truthful visible progress is more valuable than a watchdog for much of the Journey.

If this comes back with progress moving smoothly through a real-sized import, I would be perfectly happy if Codex concludes **“don't build a watchdog for these stages.”** The user problem we're solving is being stranded without evidence, not satisfying an architectural desire to own a timeout.
