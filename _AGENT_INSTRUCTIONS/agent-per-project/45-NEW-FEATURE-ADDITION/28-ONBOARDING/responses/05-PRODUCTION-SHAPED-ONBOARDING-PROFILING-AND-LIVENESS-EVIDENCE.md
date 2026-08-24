---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-24
source_of_truth: feature-profiling-record
---

# Production-Shaped Onboarding Profiling And Liveness Evidence

## Outcome

A complete first import was profiled against a disposable development archive
using the Mac's live Messages and Contacts databases through the established
read-only source boundaries. The run imported and projected 137,360 messages,
40,229 attachments, and their relationships, then completed durable readiness
verification in 48.94 seconds.

Real progress now changes frequently during every long enumerable operation.
No counted operation had a healthy no-observation interval longer than 949 ms.
Two set-based graph relationship projections remain truthfully coarse: one
lasted 8.13 seconds and one lasted 2.81 seconds.

No watchdog, timeout, stalled state, Start Fresh path, malformed-record policy,
or sleep detector was added. One bounded performance defect was corrected:
Environment Readiness was opening derived stores as an unrelated observer while
Onboarding owned archive mutation. Those reads encountered two SQLite busy
waits, delayed the first import work by 6.6 seconds, and starved frames for more
than three seconds. Environment Readiness now reports maintenance while any
archive mutation is admitted and does not open either derived store.

## Profiling Environment

The profile used:

- app: the exact macOS Debug `MessageLens Development.app` bundle;
- build identity: `com.bigbenchsoftware.MessageLens.development`;
- archive environment: development;
- archive root:
  `/Volumes/WD_ELEMENTS/ONBOARDING_PROFILING/2026-08-24-first-import-observer-fix`;
- source Messages database: the current Mac's `chat.db`, read through the
  canonical read-only source architecture;
- source Contacts database: the current resolved AddressBook source, read
  through the existing feature boundary;
- output: a new disposable MessageLens archive containing no prior imported or
  graph data and no prior user archive;
- timing: monotonic in-process elapsed time plus Flutter frame timings;
- profiling hooks: compile-time development instrumentation, removed after the
  evidence was captured.

The source databases were not modified. The disposable archive was the only
write target. No attachment payload was copied or archived during Onboarding.

The application was launched through macOS LaunchServices so Full Disk Access
belonged to the application bundle rather than Terminal. The Debug bundle was
ad hoc signed, so rebuilding changed its CDHash and required the exact rebuilt
bundle to be admitted again before the second run.

## Source Scale

| Source or derived fact | Count |
| --- | ---: |
| Chats | 239 |
| Handles | 257 |
| Contacts loaded | 113 |
| Contact email channels | 27 |
| Contact phone channels | 132 |
| Messages | 137,360 |
| Rich-text candidates | 124,080 |
| Attachments | 40,229 |
| Chat-message relationships | 116,621 |
| Chat-handle relationships | 324 |
| Message-attachment relationships | 39,613 |

The source-scoped import ledger contains exactly two deterministic live source
registrations: `live-chat-db` and `live-address-book`.

## Full Journey Timing

| Boundary | Elapsed time | Notes |
| --- | ---: | --- |
| Consequential operation begins | 0.444 s | `environmentPreparation` |
| Message-data build begins | 0.590 s | Preparation completed in about 146 ms |
| First import substage begins | 0.727 s | 137 ms after message-data stage entry |
| Last enumerable projection completes | 37.843 s | Attachment projection complete |
| Chat-message edge projection begins | 37.983 s | Coarse set-based work |
| Message-attachment edge projection begins | 46.114 s | Prior coarse work took 8.13 s |
| Durable verification begins | 48.924 s | Prior coarse work took 2.81 s |
| Durable operation completes | 48.942 s | Verification took about 18 ms |

The post-completion profiling observation closed at 50.459 seconds. The app then
entered ordinary browsing with the expected fresh-archive state: imported data
was present, while prior MessageLens-specific favourites, labels, and personal
overlay history were not.

## Substage Measurements

Observation gaps are intervals between durable typed progress observations.
For counted work, the maximum gap is also the longest measured interval during
which the visible numerator did not change.

| Substage | Total work | Duration | First count | Median gap | Max gap | Classification |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Import chats | 239 | 40 ms | 23 ms | 23 ms | 23 ms | Coarse but short |
| Import handles | 257 | 404 ms | 372 ms | 372 ms | 372 ms | Visible; no threshold evidence |
| Import contacts | 113 | 17 ms | 10 ms | 10 ms | 10 ms | Coarse but short |
| Import email channels | 27 | 3 ms | immediate | 3 ms | 3 ms | Coarse but short |
| Import phone channels | 132 | 4 ms | immediate | 4 ms | 4 ms | Coarse but short |
| Import messages | 137,360 | 6.708 s | 949 ms | 38 ms | 949 ms | Progress visible |
| Extract rich text | 124,080 | 1.335 s | 605 ms | 3 ms | 605 ms | Progress visible |
| Persist rich text | 124,080 | 3.667 s | immediate | 30 ms | 117 ms | Progress visible |
| Import attachments | 40,229 | 1.855 s | 379 ms | 37 ms | 379 ms | Progress visible |
| Import chat-message edges | 116,621 | 3.467 s | 61 ms | 28 ms | 101 ms | Progress visible |
| Import chat-handle edges | 324 | 15 ms | 3 ms | 11 ms | 11 ms | Coarse but short |
| Import message-attachment edges | 39,613 | 1.165 s | 5 ms | 28 ms | 80 ms | Progress visible |
| Project conversations | 239 | 35 ms | 3 ms | 32 ms | 32 ms | Coarse but short |
| Project messages | 137,360 | 12.565 s | 309 ms | 88 ms | 309 ms | Progress visible |
| Project attachments | 40,229 | 2.738 s | 79 ms | 65 ms | 127 ms | Progress visible |
| Project chat-message edges | Set-based | 8.131 s | None | None | 8.131 s | Coarse and long |
| Project message-attachment edges | Set-based | 2.810 s | None | None | 2.810 s | Coarse boundary |
| Durable verification | Two counts/proof | 18 ms | None | None | 18 ms | Coarse but short |

Handle intake processed the complete production-shaped handle set in 404 ms.
Existing unusual-handle fixtures remain the source of shape-specific
correctness evidence; this run found no individual-handle timing seam and does
not justify a handle watchdog.

## Gaps Between Substages

No unexplained pre-progress gap exceeded two seconds after the correction.
The notable non-counted intervals were:

- message import completion to rich-text extraction entry: about 1.11 seconds,
  including candidate discovery and preparation;
- rich-text persistence completion to attachment import entry: about 1.21
  seconds, including attachment source query/preparation;
- attachment projection completion to chat-message edge projection entry:
  about 140 ms.

The two long silent intervals are the explicitly coarse set-based relationship
projections shown in the timing table. They are not disguised as determinate
work.

## Process And Transaction Boundaries

The Journey, operation snapshot, and progress coordination run in the Dart
isolate. SQLite plugin/native work and Rust decoding cross their existing
native boundaries; no new worker-isolate architecture was introduced.
Rich-text extraction invokes the existing native decoder per candidate and
yields to the Dart event loop every 1,000 completed candidates.

Source importers first read their source result set through the read-only source
adapter, then perform each domain's ledger writes inside its existing
transaction. Rich-text persistence uses one existing ledger transaction. Graph
row projectors retain their existing transaction boundaries. The two coarse
relationship projectors remain set-based database operations without internal
callbacks.

Progress means completed processing inside the owning operation. It does not
claim transaction commit or durable stage completion. The operation controller
and final readiness proof retain those authorities.

## Database Contention Finding And Correction

### Before

In the first 137,358-message profile:

- `messageDataBuild` began at 0.618 seconds;
- `importingChats` did not begin until about 7.22 seconds;
- application logs showed Environment Readiness attempting derived-store row
  counts while Onboarding mutation owned those stores;
- two SQLite busy waits of approximately three seconds each occurred;
- terminal completion took 57.32 seconds;
- the worst Flutter frame was approximately 3.21 seconds.

`ArchiveMutationOperation.onboardingImport` deliberately does not globally
block its owner's graph reopen, because Onboarding must construct that graph.
That did not mean unrelated readiness observers were entitled to open the
stores. The observer had been checking only the global database-maintenance
lock and missed the admitted Onboarding mutation.

### Correction

`onboardingEnvironmentReportProvider` now treats either of these as
maintenance for its observational derived-store reads:

- the existing database-maintenance lock; or
- any active admitted archive mutation.

During that state it reports truthful maintenance and does not count rows in
`macos_import_ss.db` or `working_ss.db`. The generic graph-connection authority
was not weakened or broadened, and the owning Onboarding operation retains its
required graph access.

### After

In the corrected 137,360-message run:

- first import work began 137 ms after `messageDataBuild` entry;
- no `SQLITE_BUSY` or `database is locked` event occurred;
- terminal completion took 48.94 seconds, 8.38 seconds faster;
- the worst frame during the operation was 427 ms, down from 3.21 seconds;
- all import and graph counts agreed.

A focused regression test admits a real `onboardingImport` mutation and proves
that Environment Readiness reports maintenance without opening either derived
store or evaluating graph readiness.

The live-update monitor logged a separate startup race against the deliberate
derived-store reset (`database_closed`). It did not delay or fail Onboarding and
is not folded into this correction.

## Main-Isolate Responsiveness

The corrected operation recorded 1,500 frames before terminal completion and
three frames above 100 ms. The maximum was 427 ms during initial startup. Two
additional 126-170 ms frames occurred around early source/import setup. A
111 ms frame followed completion. No multi-second frame starvation remained.

The counted progress cadence was paintable throughout the long message,
rich-text, attachment, relationship-import, and row-projection stages. The
8.13-second set-based edge projection still provides no changing evidence and
is the remaining interval most likely to feel static.

## Snapshot Persistence Cost

The run produced 810 semantic snapshot writes:

| Stage | Writes | Summed awaited write time | Maximum write |
| --- | ---: | ---: | ---: |
| Environment preparation | 2 | 176 ms | 139 ms |
| Message-data build | 805 | 4.384 s | 103 ms |
| Durable verification | 3 | 24 ms | 13 ms |
| **Total** | **810** | **4.585 s** | **139 ms** |

Across all writes:

- minimum: 2.68 ms;
- median: 3.17 ms;
- 95th percentile: 16.81 ms;
- 29 writes exceeded 20 ms;
- 9 exceeded 50 ms;
- 2 exceeded 100 ms.

Persistence is bounded and stable, but its summed awaited time is about 9.4%
of the operation and is therefore not described as negligible. One run is not
enough evidence to change the established 1,000-row cadence. No cadence change
was made.

## Correctness And Final State

Read-only post-run verification established:

- `macos_import_ss.db`: `quick_check = ok`;
- `working_ss.db`: `quick_check = ok`;
- `user_overlays.db`: `quick_check = ok`;
- import messages = graph messages = 137,360;
- import attachments = graph attachments = 40,229;
- import chat-message edges = graph chat-message edges = 116,621;
- import chat-handle edges = graph chat-handle edges = 324;
- import message-attachment edges = graph message-attachment edges = 39,613;
- one stable operation identity and one stable process-session identity were
  observed throughout all 810 writes;
- each substage occurred once; provider rebuild did not restart work;
- the disposable archive contains no attachment payload files.

The fresh archive has no prior user's MessageLens overlay history. That is the
truthful reason the resulting application looked "naive" despite containing
all imported source data.

## Controlled Interruption, Sleep, And Contention Scope

No process was killed during a critical production-shaped database operation.
There is not yet an externally observable safe checkpoint that would justify
doing so merely for profiling. Existing deterministic restart-reconciliation
tests remain the evidence for interrupted-operation classification.

No sleep/wake conclusion was drawn. Flutter lifecycle events remain
insufficient evidence of execution opportunity, and one manual sleep test
would not establish a watchdog contract.

The live source remained an ordinary active Messages database during the run,
and read-only import completed correctly. The observed contention defect was
between an unrelated MessageLens observer and the admitted mutation, not a
source-WAL failure. No dangerous deadlock was manufactured.

## Failure Localization

The production-shaped run was healthy. Existing focused fixtures continue to
prove bounded typed failure localization for malformed handles, malformed
messages, rich-text decoder failures, and attachment errors. No record was
suppressed and no quarantine/skip policy was introduced. The operation
snapshot retains stage, substage, last completed count, total, and bounded
source-row context where the service can truthfully provide it.

## Revised Liveness Contract

| Substage group | Measured evidence | Execution opportunity observable? | Classification | Future threshold defensible? |
| --- | --- | --- | --- | --- |
| Source imports | Maximum counted gap 949 ms; all complete normally | No | Progress visible but threshold still unsafe | No |
| Rich-text extraction/persistence | Maximum counted gap 605 ms; event-loop yield every 1,000 | No | Progress visible but threshold still unsafe | No |
| Row graph projections | Maximum counted gap 309 ms | No | Progress visible but threshold still unsafe | No |
| Small imports/projections | 3-404 ms total | No | Coarse but short | No watchdog needed |
| Chat-message edge projection | 8.13 s, no internal observation | No | Coarse and long | No; instrument first |
| Message-attachment edge projection | 2.81 s, no internal observation | No | Coarse boundary | Not from one run |
| Preparation/reset | 146 ms in this run | No | Coarse but short | No watchdog needed |
| Durable verification | 18 ms in this run | No | Coarse but short | No watchdog needed |
| External prerequisite waiting | Not execution | Not applicable | Waiting/external | Never use execution watchdog |

## Watchdog Decision

Recommendation **B** applies to enumerable work: do not implement a watchdog
yet; real progress has solved the immediate human-liveness problem, while
macOS execution opportunity remains unobservable.

Recommendation **C** applies to the 8.13-second chat-message edge projection:
if automated liveness is later required, that operation needs truthful internal
phase/progress evidence before any threshold can be considered. Its efficient
set-based SQL must not be replaced with a slower row loop merely to animate it.

No timeout value can be justified from one healthy run.

## Recommended Next Slice

Prompt 06 should remain narrow and evidence-led:

1. determine whether the chat-message edge projector can expose truthful
   internal SQL phases or a safe database progress observation without changing
   its set-based algorithm;
2. investigate the live-update monitor's startup/reset `database_closed` race
   independently of Onboarding readiness;
3. measure whether durable snapshot persistence can be made cheaper without
   reducing semantic fidelity or introducing a second progress authority;
4. preserve watchdog deferral until execution opportunity and repeated healthy
   variance are both known.

Start Fresh, record quarantine, broad performance optimization, and visual
redesign remain outside this evidence slice.

## Verification

- 393 focused Onboarding, archive-mutation, source-import, graph-build,
  rich-text, operation-snapshot, and architecture tests pass.
- The complete Flutter suite passes all 2,003 tests.
- `flutter analyze` reports no issues.
- The macOS Debug application builds successfully after all temporary profiling
  hooks were removed.
- `dart format` and `git diff --check` are clean.
