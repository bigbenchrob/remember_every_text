Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation after a mandatory **profile-first investigation**.

Do NOT proceed into actual attachment recovery.

The newly enabled MessageLens arm successfully accepts the real legacy donor and begins read-only attachment preflight, but manual testing exposed a serious performance/observability problem.

Suggested prompt name:

`prompts/53-MESSAGELENS-ATTACHMENT-PREFLIGHT-PERFORMANCE-AND-OBSERVABILITY.MD`

# Manual finding

The real legacy MessageLens donor now passes qualification.

Observed sequence:

1. user selects donor folder;
2. Finder closes;
3. macOS beach ball appears for several seconds before useful center-panel feedback becomes visible;
4. center eventually shows Narrator:

   **“I’m checking this MessageLens folder for attachments that are missing here.”**

5. Directed Instrumentation shows essentially one:

   `Checking for recoverable attachments     [spinner]`

6. that unchanged spinner remained visible for **more than five minutes** during manual testing.

The user is leaving it running for approximately another ten minutes to learn whether it eventually completes.

This is not acceptable as merely a presentation issue.

A read-only preflight taking many minutes may contain:

- an algorithmic/pathological performance problem;
- expensive but legitimate work;
- both.

Therefore:

> PROFILE FIRST. OPTIMIZE PATHOLOGICAL WORK IF FOUND. THEN INSTRUMENT WHATEVER LEGITIMATELY REMAINS LONG-RUNNING.

Do not merely add more animation around a pathological algorithm.

# Hard acceptance principle

No MessageLens attachment preflight should leave the human staring at an unchanged spinner for more than a few seconds when the underlying operation has real observable work units.

And:

> If a five-minute operation can safely be made a five-second operation, fix the operation rather than decorating the five-minute wait.

# Part 1 — trace folder-selection to first paint

The user experienced several seconds of beach-ball/unresponsiveness immediately after choosing the folder, before useful center content became visible.

Audit the exact timeline:

```text
folder chooser returns
→ workflow receives selected folder
→ typed presentation state changes
→ Flutter schedules/builds inspection state
→ first inspection frame paints
→ structural qualification begins
→ compatibility inspection
→ lineage admission
→ attachment preflight.
```

Determine what synchronous work occurs before the first useful frame.

We previously solved the analogous Mac Messages Add-button problem using an `endOfFrame` barrier after publishing truthful operation state.

Do not assume the same fix automatically applies here.

Measure first.

## Required behavior

Once the chooser returns a folder:

- workflow should immediately enter a truthful MessageLens inspection state;
- center should be able to paint Narrator/instrumentation;
- then expensive read-only work proceeds.

The user should not see several seconds of beach ball while the previous hub remains frozen.

If synchronous qualification currently begins before Flutter can paint, introduce the smallest legitimate render boundary consistent with existing architecture.

Do not add an arbitrary delay.

# Part 2 — profile the entire preflight

Instrument/profile the real read-only preflight pipeline.

At minimum measure separately:

1. structural MessageLens archive qualification;
2. legacy/current format compatibility inspection;
3. donor evidence opening/loading;
4. same-Messages-lineage admission;
5. donor attachment evidence enumeration;
6. current attachment evidence enumeration;
7. message matching;
8. attachment relationship matching;
9. current payload-presence checks;
10. donor payload path resolution;
11. donor payload existence/stat checks;
12. donor payload hash/size verification;
13. classification;
14. aggregate recoverable count/byte calculation.

These are investigation categories, not assumed final stages.

Use actual implementation boundaries.

Report elapsed time for each.

# Part 3 — identify algorithmic pathology

Look explicitly for:

- N×M matching;
- repeated full-list scans;
- per-attachment linear searches;
- repeated database queries inside loops;
- repeated opening/closing of SQLite connections;
- filesystem `stat` per candidate when batching/indexing is possible;
- synchronous file hashing of every donor payload;
- hashing files that do not need hashing yet;
- reading payload bytes during preflight unnecessarily;
- repeated path canonicalization;
- repeated lineage calculations;
- provider invalidation causing work to restart;
- accidental duplicate preflight execution;
- nested awaits that serialize independent cheap reads;
- large collections copied/sorted repeatedly;
- source-scoped ID conversion repeated unnecessarily;
- debug logging overhead;
- main-isolate CPU loops causing beach-ball behavior.

Do not assume the five-minute duration is inevitable.

# Part 4 — inspect whether preflight is doing mutation-time work too early

This is especially important.

Read-only preflight needs to answer:

> Which missing attachments can safely be recovered, and how much data is recoverable?

It may NOT need to perform every expensive verification that will later be repeated immediately before copying.

Audit whether preflight currently:

- hashes every donor payload;
- reads complete payload bytes;
- performs exhaustive expensive integrity checks;
- performs work that belongs at recovery execution boundary.

Separate:

## Preflight proof

Enough evidence to truthfully classify a payload as a safe recovery candidate.

from:

## Execution-boundary revalidation

Checks that must be repeated immediately before actual installation because donor/current state may have changed.

Do not weaken safety.

But do not perform expensive mutation-time work twice without reason.

# Part 5 — hash strategy

Response 47 established donor size/hash verification where hashes exist.

Determine exactly when hashing occurs.

If preflight hashes gigabytes of donor files synchronously, this may explain the runtime.

Ask:

- Is a trusted stored hash already available?
- Does preflight need to recompute it now?
- Can hash verification occur only for the subset actually authorized for recovery?
- Can hash computation be streamed with real byte progress?
- Can existing metadata provide sufficient preflight classification, followed by execution-time verification?

Do not remove required integrity verification.

Place it at the correct lifecycle boundary.

# Part 6 — database matching strategy

The identity model is strong:

```text
original message ROWID + GUID
→ exact message/attachment ROWID relationship
→ noncontradictory attachment GUID.
```

This should permit efficient keyed lookup.

Audit whether current implementation builds indexed maps/sets such as:

- original message ROWID → message evidence;
- message identity → attachment relationships;
- original attachment ROWID → attachment evidence;

or repeatedly searches lists.

Prefer O(N) / indexed matching over O(N²).

Do not introduce premature complexity if the current algorithm is already efficient.

# Part 7 — payload presence strategy

Determine how current payload presence is checked.

If current MessageLens has tens of thousands of attachments, avoid repeated expensive directory scans.

Prefer canonical destination evidence/path lookup.

If filesystem existence checks are necessary, they may still be individually cheap; measure them.

Do not cache stale truth across the operation merely for speed.

# Part 8 — duplicate execution

Prove preflight runs exactly once per selected candidate/session unless explicitly retried.

The earlier Historical Archives work encountered provider invalidation/rebuild effects.

Ensure:

- widget rebuild does not restart preflight;
- readiness refresh does not restart preflight;
- arm state projection does not duplicate it;
- Details expansion does not duplicate it;
- lineage result publication does not accidentally trigger a second complete matching pass.

Add instrumentation/tests.

# Part 9 — main-isolate responsiveness

A macOS beach ball suggests the UI event loop may be blocked.

Identify CPU-heavy synchronous Dart work.

If a large pure-Dart matching/hash operation blocks the main isolate:

- move appropriate pure computation to an isolate where consistent with project architecture;
- or restructure into yielding bounded batches.

Do not move database objects/connections across isolates unsafely.

Do not add generic worker infrastructure unless justified.

The preferred solution is often to make the algorithm efficient enough that this is unnecessary.

# Part 10 — establish real execution stages

After optimization, identify the remaining phases that take long enough to earn Directed Instrumentation.

Narrator should explain meaning/scope.

Directed Instrumentation should show factual work.

Possible human stages, ONLY if they map to real measured work, might be:

- Verifying this MessageLens folder
- Comparing Messages history
- Reading attachment records
- Matching attachments
- Checking available attachment files
- Calculating what can be recovered

Do not use these labels unless supported by actual execution boundaries.

# Part 11 — expose real counts

Attachment preflight naturally works over countable collections.

For any perceptibly long enumerable phase, expose real numerator/denominator evidence.

Examples only if truthful:

`Reading attachment records       12,500 / 48,231`

`Matching attachments             8,250 / 31,842`

`Checking donor files             4,750 / 12,116`

or:

`Checking attachment files        18.4 GB / 42.7 GB`

if actual bytes are being read.

Prefer raw counts.

Do not show a progress bar unless it adds value beyond counts.

# Part 12 — live useful discoveries

If recoverable count/bytes can be accumulated monotonically during inspection, consider showing subordinate factual evidence such as:

`Recoverable so far               1,142 attachments`

`Recoverable size so far          18.6 GB`

ONLY if these are truthful monotonic facts.

Do not imply final totals until inspection completes.

This may provide excellent reassurance during long filesystem enumeration.

# Part 13 — progress publication frequency

Do not publish a provider/UI update for every attachment if there are tens of thousands.

Use bounded actual-work batches.

Prompt 34 used every 250 rows successfully for graph projection.

Determine an appropriate batch size from measured workload.

Progress updates must derive from completed work, not timers.

# Part 14 — Narrator lifecycle

Use the stable Narrator Track.

The current Narrator:

**I’m checking this MessageLens folder for attachments that are missing here.**

is appropriate as an overall initial interpretation.

But if preflight has multiple long phases with a meaningful scope change, Narrator may transition.

Do not leave stale commentary.

Do not narrate every technical stage.

Example conceptual transition:

initial donor inspection
→ “I’m checking this MessageLens folder…”

then, if a genuinely different long phase begins:

→ “This folder matches your Messages history. Now I’m checking which attachments are missing here.”

Only if earned.

Final ready state replaces operation commentary with the recovery summary.

# Part 15 — stable Tracks

Preserve the current A–I Track layout.

Manual review says layout looks good.

Do not redesign it.

Narrator changes/silence must not move Directed Instrumentation.

# Part 16 — cancellation

Audit whether a five-minute read-only preflight should be cancellable.

At minimum, switching away/navigating away must invalidate presentation/session results.

If expensive computation can continue unnecessarily after navigation, determine whether it should support cancellation.

Do not add complex cancellation infrastructure unless justified.

But a stale five-minute task must never later resurrect MessageLens-arm state.

# Part 17 — final ready state

Preserve Prompt 50/52 ready-state semantics.

When preflight completes:

- Narrator interprets result;
- exact recoverable count;
- exact recoverable byte total;
- Details for diagnostics;
- no recovery mutation yet unless separately approved.

No spinner remains.

# Part 18 — zero result

Preserve calm zero-result behavior.

Do not spend five minutes only to display a red “failure.”

# Part 19 — performance targets

Do not invent an arbitrary strict SLA without evidence, but establish useful expectations.

For the real-sized donor:

- structural qualification should feel immediate;
- lineage admission should remain sub-100ms-ish as previously measured where comparable;
- database evidence matching should ideally be seconds, not minutes;
- filesystem enumeration may take longer depending on file count/storage medium;
- any phase exceeding roughly 2–3 seconds should expose changing evidence if possible.

If the donor lives on a slow external disk, distinguish I/O cost from algorithmic cost.

# Part 20 — benchmark fixtures

Create representative performance tests/benchmarks where repository conventions permit.

Do not make fragile wall-clock unit tests on CI.

Prefer:

- operation-count assertions;
- query-count assertions;
- proof that matching is indexed rather than nested scans;
- bounded fixture performance tests with generous thresholds only where stable.

The existing sub-100ms lineage bound is precedent but do not proliferate brittle timing tests.

# Part 21 — architecture tripwires

Add protections proving:

1. preflight does not restart from widget rebuild;

2. no O(N²) obvious nested attachment matching pattern exists where keyed matching is required;

3. expensive donor payload hashing does not occur in preflight unless explicitly justified;

4. progress counts derive from real work;

5. no timer drives progress;

6. first inspection presentation state is published before expensive work;

7. stale session completion cannot resurrect abandoned UI;

8. no mutation occurs;

9. MessageLens donor remains read-only;

10. Mac Messages arm remains unchanged.

# Part 22 — actual recovery remains out of scope

Do not implement:

- Recover Attachments button;
- batch copy;
- payload installation from UI;
- mutation authority orchestration;
- terminal recovery modal.

This task is preflight performance and observability only.

# Safety

Do not mutate:

- production MessageLens data;
- donor archive;
- staging archive;
- live chat.db;
- attachment payloads.

Read-only inspection of a real donor may be performed only if repository/user rules permit and through established read-only infrastructure.

Prefer fixtures for automated work.

# Documentation

Create the next Feature 26 implementation/performance record under `responses/`.

Document:

- manual >5 minute symptom;
- chooser-to-first-paint timeline;
- exact phase timings;
- pathological work discovered;
- optimizations made;
- preflight versus execution-time verification boundary;
- final real Directed Instrumentation stages;
- progress denominators;
- batching frequency;
- cancellation/session behavior;
- measured post-fix performance;
- any unavoidable slow I/O.

Update canonical attachment-recovery guidance if lifecycle placement of verification changes.

Update version/changelog according to repository rules.

# Verification

Run:

- MessageLens preflight tests;
- attachment matcher tests;
- donor/current adapter tests;
- lineage tests;
- Historical Archives presentation/session tests;
- Settings suite;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP and report rather than hiding the problem if:

- the five-minute runtime is caused by an unavoidable operation with no truthful progress evidence;
- fixing performance requires weakening identity/integrity checks;
- correct optimization requires schema changes;
- donor compatibility requires mutation;
- current architecture cannot perform safe read-only enumeration without blocking the UI;
- a broad worker/task framework would be required.

# Final report

Report:

- exact total preflight time before/after on representative data;
- cause of chooser-to-first-paint beach ball;
- exact time spent in each preflight phase;
- any N²/repeated-query/repeated-hash pathology found;
- optimizations implemented;
- what work moved from preflight to execution-time revalidation, if any;
- final Directed Instrumentation rows;
- exact numerators/denominators;
- progress update batching;
- session/cancellation behavior;
- confirmation no safety proof was weakened;
- tests/tripwires;
- commit hash;
- manual retest instructions.

Acceptance standard:

> MessageLens attachment preflight should become visible immediately, complete as efficiently as the safety model permits, and expose real changing evidence whenever legitimate work lasts long enough that a human could reasonably wonder whether the application has stalled.
