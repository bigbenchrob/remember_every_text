---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-23
source_of_truth: feature-implementation-blocker
---

# Onboarding Stall Detection And Stage-Specific Liveness Contracts: Blocker

## Outcome

Prompt 03 stopped before implementation because two explicit stop conditions
are present:

1. Flutter's current macOS lifecycle surface does not distinguish system sleep
   or process suspension from ordinary desktop focus and visibility changes.
2. The current typed Onboarding stages do not yet expose both truthful progress
   and a measured, defensible maximum no-observation interval.

Adding a watchdog now would create false certainty. In particular, it could
classify a laptop sleep as a stall or apply an invented timeout to a legitimate
coarse database operation.

No application code, persistence format, presentation, threshold, retry path,
or cancellation behavior changed in this pass.

## Liveness Inventory

No production-sized Onboarding benchmark or longest-no-event measurement exists
for any of the four current typed stages. Consequently, `unknown` below is an
important result rather than a missing estimate.

| Typed stage | Operation | Duration evidence | Progress currently available to Onboarding | Execution boundary | Sleep/suspension effect | Classification | Safe stall threshold | Safe recovery today |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `environmentPreparation` | Closes active derived stores, deletes only enumerated rebuildable database files, invalidates providers, and verifies deletion | Typical and worst production duration unknown | Stage entry and eventual return/throw only | Main isolate coordinates asynchronous database lifecycle and filesystem work | No trustworthy opportunity signal | Unobservable/unbounded | None justified | Thrown errors become typed failure; otherwise wait. Do not cancel or retry blindly. |
| `messageDataBuild` | Runs the ordered source import, rich-text enrichment, and Conversation Graph projection pipeline | Production duration and longest no-event interval unknown. Historical fixture projector timings are not production Onboarding bounds. | Only top-level stage entry and eventual return/throw. Selected graph repositories have latent row observers, but the live Onboarding controller does not receive them; source import and several projection units remain coarse. | Main isolate orchestrates sqflite/SQLite work and an external Rust extraction process; no Onboarding worker-isolate protocol exists | No trustworthy opportunity signal | Unobservable/unbounded in the current Onboarding composition; partially instrumentable later | None justified | Thrown process/database/projection errors become typed failure. Retry must begin at an existing safe operation boundary after durable reconciliation. |
| `durableReadinessVerification` | Opens the source-scoped import and graph stores read-only and proves positive canonical `messages` counts | Typical and worst duration unknown | Stage entry and completion/throw only | Synchronous `sqlite3` count probes on the calling isolate; each connection sets `busy_timeout = 3000`, but table-count duration is not bounded by that contention setting | No trustworthy opportunity signal | Unobservable/unbounded | None justified. The SQLite busy timeout is not a stage timeout. | Probe failure follows the existing typed failure path. |
| `automaticRecoveryReset` | Performs the same preservation-safe derived-store reset under automatic-recovery mutation authority | Typical and worst production duration unknown | Stage entry and eventual return/throw only | Same reset boundary as `environmentPreparation` | No trustworthy opportunity signal | Unobservable/unbounded | None justified | Thrown errors become typed preparation failure. Existing mutation-busy deferral remains a waiting condition before admission, not a stall. |

## Existing Real Progress Seams

The Conversation Graph already has a truthful numerical observer for selected
projection repositories:

```text
0 / exact row count
every 250 completed rows
exact terminal completed row count
```

The chat, message, and attachment projection repositories use this seam.
Historical Archives composes those observations into its own directed
instrumentation. The ordinary Conversation Graph build used by Onboarding does
not currently forward them through
`ConversationGraphBuildController.runOnce()` or the Onboarding progress
reporter.

This is useful future infrastructure, but it is not enough to declare the whole
`messageDataBuild` stage granular:

- source table import is not represented by the same observer;
- rich-text extraction is a coarse external process call;
- several graph units expose only completion;
- no production longest-no-event interval has been measured;
- a single aggregate numerator/denominator has not been defined truthfully.

Stage transitions and operation completion remain real observations. A repeated
observation of the same numerator must not become progress in a future slice.
The current snapshot controller increments its progress revision whenever
`reportProgress` is called, so this semantic must be corrected before a
watchdog consumes that revision.

## Execution Opportunity Audit

### What Flutter reports on macOS

Flutter's desktop lifecycle reports application focus and view visibility:

- `resumed`: visible and active;
- `inactive`: visible, but all application views have lost input focus;
- `hidden`: all views are hidden or occluded.

Flutter explicitly documents that `paused` and `restart` are not called on
desktop. The macOS engine implementation emits lifecycle changes from AppKit
activation and occlusion notifications. It does not bridge
`NSWorkspaceWillSleepNotification` or `NSWorkspaceDidWakeNotification` into
Flutter lifecycle state.

Therefore:

- `inactive` cannot mean no execution opportunity; a user may simply be using
  another application while MessageLens continues working;
- `hidden` cannot safely mean suspended; a hidden desktop process may continue
  database and child-process work;
- no current app-owned signal identifies the interval in which the Mac slept;
- process restart is already handled separately through the durable process
  session identity and must remain `interrupted`, not `stalled`.

### Monotonic time is necessary but insufficient

Dart `Stopwatch` provides a monotonic elapsed counter and is appropriate for
measuring admitted execution intervals. It does not, by itself, establish
whether the process had an opportunity to execute. Without a truthful
sleep/suspension signal, leaving a stopwatch running can count an interval that
the prompt requires the watchdog to exclude; stopping it on `inactive` or
`hidden` would incorrectly discount legitimate work.

A periodic timer would prove only that the Dart event loop fired. It must not
update `lastProgressObservedAtUtc` or act as a work heartbeat.

## Busy, Waiting, Process, And Stream Findings

- The canonical read-only probe busy timeout is 3 seconds. A resulting SQLite
  exception already belongs to normal typed failure handling. The timeout is
  bounded contention tolerance, not permission to infer that a longer stage is
  stalled.
- Archive-mutation denial and required FDA/source/user decisions occur before
  an admitted running operation or in explicit waiting/attention paths. They
  must remain excluded from a watchdog.
- Onboarding does not own a worker-isolate progress protocol. Rich-text
  extraction uses an awaited external process; a nonzero exit becomes a thrown
  failure, but a silent process hang has no truthful current progress contract.
- The durable snapshot stream is a projection of controller state. Its silence
  is not evidence that underlying work should have emitted progress.
- Completion, failure, interruption, stage transition, and operation/session
  replacement are already typed terminal or identity boundaries. Any future
  watchdog must stop ownership immediately at those boundaries.

## Stall State Decision

No `stalled` snapshot status or failure subtype was added. Until a stage has a
truthful liveness contract, durable stall evidence would merely persist an
unsupported conclusion.

The intended future distinction remains:

- a thrown operational error is `failed`;
- an old-process running snapshot becomes `interrupted`;
- permission, source, user, or mutation-authority prerequisites are waiting or
  attention states;
- a stall may be concluded only for a current-process running stage whose real
  progress contract and execution-opportunity clock both support it.

No automatic retry is justified for current mutation stages. No Cancel action
is truthful while an underlying SQLite transaction or external extraction
process may still own work. Human retry must continue to use an existing safe
operation boundary and durable reconciliation rather than rerun an arbitrary
closure.

## Presence Projection

The current operation-to-Presence projection remains unchanged. It can
truthfully project working, interrupted, needs-attention, and done states. It
must not project a special stalled meaning until Onboarding has first produced
a justified typed liveness conclusion.

## Why Implementation Stopped

The requested acceptance standard requires a genuine silent no-progress path
to become typed stall without treating sleep or coarse work as failure. The
current system cannot meet both halves simultaneously:

- wiring a timer now would not establish execution opportunity;
- applying a threshold now would not be supported by production measurements;
- instrumenting every import, extraction, projection, reset, and verification
  boundary plus native sleep/wake is a broader runtime/instrumentation project,
  not the narrow evaluator requested by Prompt 03.

The prompt explicitly requires a stop rather than invented certainty under
these conditions.

## Recommended Prompt 04 Blocker

The next bounded prerequisite should be an **Onboarding liveness evidence and
execution-opportunity instrumentation audit/implementation**, not stall
detection itself. It should:

1. measure production-shaped stage and substage durations plus the longest
   real no-observation interval;
2. define a typed progress observation stream for the ordinary source import,
   rich-text extraction, and graph build without manufacturing one aggregate
   denominator;
3. preserve source-specific and graph-specific work units rather than flatten
   incompatible counts;
4. establish a narrow macOS sleep/wake execution-opportunity adapter, with
   direct platform tests, while treating focus loss and hiding as continued
   opportunity unless actual suspension is observed;
5. prove stale operation/session observations are rejected;
6. correct repeated identical progress so it does not advance liveness;
7. return measured evidence from which one or more conservative stage-specific
   no-progress bounds can be justified.

Only after that evidence exists should Prompt 03's evaluator, durable stall
evidence, Presence projection, and watchdog tests be implemented.
