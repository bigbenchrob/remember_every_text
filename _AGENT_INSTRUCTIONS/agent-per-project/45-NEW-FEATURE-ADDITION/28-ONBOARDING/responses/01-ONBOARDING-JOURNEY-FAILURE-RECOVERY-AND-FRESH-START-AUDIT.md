---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-23
source_of_truth: audit-record
---

# Onboarding Journey, Failure, Recovery, And Start Fresh Audit

## Audit Boundary

This was a read-only architecture and product audit. It changed no application
code, schema, database, source data, archive payload, provider, or runtime
behavior. No real Onboarding mutation was run.

The current code is the authority for implementation facts. Older Onboarding
documents remain useful rationale, but this audit calls out places where their
descriptions no longer match the product.

Verification used existing fixtures and tests only:

- 155 Onboarding and Environment Readiness tests passed;
- 32 focused source-import and graph-build tests passed;
- 381 architecture tripwires passed.

## 1. Executive Conclusion

**NOT READY FOR A NEW UI PASS.**

The current system has a substantially sound safety core:

- Apple Messages and Contacts databases are opened through bounded read-only
  adapters;
- persistent MessageLens stores require admitted archive authority;
- initial mutation runs through `ArchiveMutationCoordinator`;
- reset deletes an explicit allow-list of rebuildable database files;
- overlay intent and `attachment_archive/` are preserved;
- operational readiness is re-derived from durable database evidence after a
  restart;
- Presence gives prerequisite guidance and persists Journey-level progress.

The main remaining failures are not cosmetic:

1. **P1: the Option-launch Start Fresh control is false.** The button labeled
   `Delete MessageLens App Data` logs `Delete requested` and continues startup.
   It deletes nothing.
2. **P1: long work has no bounded human liveness contract.** Import and graph
   build expose indeterminate progress with no heartbeat, timeout, watchdog, or
   durable current-stage evidence.
3. **P1: one malformed required source field can abort a whole table
   transaction.** There is no durable record-level anomaly ledger or bounded
   quarantine policy.
4. **P1: restart recovery is operationally reconstructable but not a true
   resume.** A failed or interrupted initial build is classified from database
   evidence and normally starts again through reset and rebuild.
5. **P2: completion and preservation scopes differ.** Onboarding can declare
   the app usable after metadata import and graph projection while attachment
   payload archival continues later through monitor/sweep work.
6. **P2: documentation overstates current progress telemetry.** Internal
   stage timings exist after completion, but the Onboarding presentation does
   not show table, row, percentage, or elapsed-stage progress.

No P0 source mutation or attachment-archive deletion path was found.

The first implementation slice should establish a typed, durable Onboarding
operation snapshot with liveness and truthful restart classification before
new progress or Narrator presentation is designed.

## 2. Complete Journey And State Map

The actual top-level flow is:

```text
process launch
  -> native archive claim
  -> Dart archive admission
  -> Flutter first frame
  -> Onboarding environment report
  -> Onboarding gate
       -> ordinary application, when durable app data is ready
       -> Presence prerequisite Journey, when human attention is required
       -> import/recovery overlay, while MessageLens-owned work is active
  -> admitted reset of rebuildable derived stores
  -> source-scoped import
  -> Conversation Graph projection
  -> process-local completion handoff
  -> ordinary application
  -> live update monitor and attachment preservation sweeps
```

| State / stage | Durable truth | Transient truth | Work occurring | Human sees | Action required | Restart | Failure / recovery |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Native bootstrap | archive marker and filesystem | native process claim | resolve and validate root | no Flutter surface yet | none | starts over | fail closed outside Flutter |
| Environment inspection | source and MessageLens files | current probes | FDA, source, Contacts, store checks | loading/readiness | usually none | probes again | report or gate fallback |
| FDA blocked | none beyond Presence run | current denial evidence | no import | Presence guidance | grant FDA, restart/recheck | Trip replays | remain blocked truthfully |
| Messages unavailable | none beyond Presence run | unreadable/missing source | no import | source guidance | repair source/recheck | Trip replays | remain blocked |
| Contacts unavailable | none beyond Presence run | no viable AddressBook source | no import | Contacts guidance | repair/recheck | Trip replays | remain blocked |
| Sparse local history | Presence Schedule position/choice | current row count | no import | warning and choice | recheck or Import Anyway | accepted choice remains durable | fresh test may loop or proceed |
| Ready to import | accepted prerequisite Journey plus source facts | Gate status | awaiting explicit import | readiness action | start import | readiness re-derived | no mutation yet |
| Preparing | existing archive stores | `importing` Gate state | admitted reset begins | calm indeterminate overlay | keep app open | incomplete files are reclassified | retry starts a fresh reset/build |
| Source import | source-scoped rows and batch-start rows | active operation | import source tables | same coarse overlay | none | committed tables remain | persisted failure plus retry |
| Graph projection | graph rows and controller evidence | `buildingGraph` | project source ledger | same coarse overlay | none | graph readiness re-derived | persisted graph failure plus retry |
| Complete handoff | populated import and graph stores | process-local `complete` | no setup mutation | `MessageLens is ready` | continue | normal startup derives readiness | dismiss enters app |
| Ordinary use | all persistent stores | selected UI state | monitor/update work | normal application | ordinary actions | normal | pipeline incidents use readiness surfaces |
| Attachment preservation | archived payloads and overlay metadata | sweep progress | copy eligible payloads | not part of Onboarding completion | usually none | sweeps retry | separate preservation recovery |

There is no durable row representing “initial Onboarding operation is at stage
N of M.” Durable truth is reconstructed from files, row counts, persisted
failure summaries, Presence run state, and graph-build status.

## 3. Journey, Episode, And Moment Mapping

### Journey

The human Journey is first launch through a usable MessageLens installation.
It includes prerequisite resolution, accepted sparse-history decisions, initial
data preparation, and the handoff into ordinary use.

### Episodes

The current human-meaningful Episodes are:

- welcome and explanation;
- FDA verification and remediation;
- Messages source verification and remediation;
- Contacts source verification and remediation;
- local-history sufficiency decision;
- explicit import authorization;
- stable failure with Retry or support action;
- completion acknowledgment.

### Moments

Operational import/build activity, elapsed work, table/stage changes, and
attachment-preservation updates are Moments. They inform the current Episode;
they are not independent user decisions.

Current Onboarding partly honors this distinction. Presence models prerequisite
attention as Steps and Trips, while the overlay treats import/build activity as
one non-interactive operation. The missing piece is truthful Moment evidence:
the overlay cannot yet say which stage is active or whether work is advancing.

## 4. Prerequisite Matrix

| Prerequisite | Detection | Current evidence | Human responsibility |
| --- | --- | --- | --- |
| Admitted MessageLens archive root | Automatic | native/Dart archive marker and identity agreement | choose/repair configured development root only when explicitly developing |
| Full Disk Access | Automatic but capability-based | source access/denial test | grant in System Settings and restart/recheck |
| Readable local `chat.db` | Automatic | read-only open and query | make Messages data locally available |
| Desired history present on Mac | Partial | local message count and date evidence only | verify Mac contains the history the person wants imported |
| iCloud Messages enabled on Mac | Not authoritatively detected | indirect local symptoms | verify in Messages/System Settings if history is absent |
| iCloud Messages enabled on iPhone/iPad | Human-only | no device authority | verify on device if synchronization is required |
| Contacts databases readable | Automatic | candidate discovery and read-only viability query | repair Contacts/FDA state if unavailable |
| Supported Apple schema | Partial | queries either succeed or fail | use supported macOS/Messages version; report diagnostics on failure |
| Sufficient disk space | Not proactively established | eventual filesystem/SQLite failure | free space after a failure; no current preflight estimate |
| Database not locked beyond tolerance | Partial | SQLite busy timeout and operation admission | retry after competing process/work ends |
| Required MessageLens directories writable | Automatic on use | archive admission and filesystem operations | repair configured archive availability |
| Attachment payload locally available | Per-item partial | resolved path/file existence | allow Messages/iCloud to download missing payloads |
| Network | Not a direct import prerequisite | no network operation in the core source import | network may be needed indirectly for iCloud download |

## 5. iCloud And Messages History Findings

MessageLens does **not** fundamentally require Messages in iCloud. It requires
the messages the user wants to preserve and browse to be present in the Mac's
locally readable `chat.db` before import.

Messages in iCloud may be the practical mechanism that transfers a person's
phone history to the Mac. That does not make the cloud setting itself the
application prerequisite.

Current capability boundaries are:

- MessageLens can open and count the local Mac source.
- It can infer that a very small local source is suspicious.
- It cannot prove that synchronization is complete.
- It cannot inspect an iPhone or iPad setting authoritatively.
- It cannot promise that enabling iCloud will produce a complete history by a
  particular time.

The present sparse policy is deliberately small but weak: a source with more
than 10 message rows is treated as sufficient. That threshold prevents an
obviously empty or nearly empty source from passing silently; it does not prove
historical completeness.

The truthful future instruction is therefore:

> Ensure the Messages history you want MessageLens to import is visible on
> this Mac. If your history lives on another Apple device, verify Messages in
> iCloud on the relevant devices and allow synchronization to finish, then
> re-check.

## 6. Permission Matrix

| Resource | Current access | Mutation permitted? | Boundary |
| --- | --- | --- | --- |
| Apple Messages `chat.db` | one-off read-only SQLite/sqflite | no | `SourceDatabaseOpener`, query-only guard |
| Apple AddressBook databases | candidate-scoped read-only opens | no | `AddressBookFolderRepository` helper |
| Source attachment files | filesystem reads | no source mutation | attachment file access boundary |
| Source-scoped import DB | central admitted provider | yes, under owning operation | archive authority + mutation coordinator |
| Conversation Graph | central admitted provider | yes, under owning operation | archive authority + graph owner admission |
| Overlay DB | central admitted provider | yes for intent/failure/archive metadata | overlay-owned repositories |
| Presence DB | central admitted provider | yes for definition/run/trace state | Presence repository |
| Attachment archive | canonical archive stores only | append/preserve; never reset | attachment mutation authority |
| Application logs | admitted archive log directory | append/rotate | logger boundary |

FDA guidance opens System Settings. MessageLens does not grant permission or
modify TCC itself.

## 7. Source-Data Anomaly Handling

Current import behavior is mixed:

- nullable text, attachment-only messages, association metadata, and reactions
  are preserved as source facts;
- missing rich-text extraction can be counted and continued;
- an arbitrary nonempty handle identifier can be imported;
- missing required row identity, GUID, or required scalar conversion can throw;
- table import commonly runs in one transaction over all newly selected rows.

Consequently, some anomalies remain visible as evidence while others abort the
whole stage. There is no shared classification such as accepted anomaly,
recoverable row failure, unsupported schema, or systemic database failure.

The current UI receives a phase-level failure summary, not the offending
record's safe diagnostic identity or a count of successfully preserved
anomalies.

## 8. `*city*` And Hong Kong Investigation

The remembered tester failure cannot be reconstructed conclusively. No
available log, fixture, current source row, or test links a literal `*city*`
handle or Hong Kong record to a present failure path.

Repository history does preserve a related but narrower fact: an earlier
chat-to-handle validation compared pre-canonical and post-canonical membership
counts incorrectly. Normalized variants such as `citycenter` and `city center`
could cause an Onboarding validation failure. That defect was corrected by
validating distinct final canonical memberships.

Current handle import rejects a missing/empty required handle identifier, but
does not reject unusual nonempty text merely because it is not a conventional
phone number or email address. Therefore:

- the recollection is credible evidence of an old data-shape blocker;
- the exact record and exact former failure remain unknown;
- it must not be presented as a proven current bug;
- a future anomaly harness should include unusual Unicode, punctuation,
  regional service IDs, duplicate canonical forms, and non-phone identifiers.

## 9. Record-Level Failure Policy

No complete policy currently exists.

The required policy must preserve the project's record-fidelity invariant:

1. Source records are never mutated or silently dropped.
2. A representable anomaly is imported and rendered, with diagnostic evidence.
3. A row that cannot enter the canonical schema receives a durable,
   source-scoped failure record containing safe identity and reason.
4. Other valid rows continue when relational integrity permits.
5. A systemic schema, transaction, permission, or storage failure stops the
   owning stage.
6. Completion cannot claim full source coverage while unresolved row failures
   exist.

This requires design work; it is not permission to add `try/catch` and skip
records.

## 10. Batch And Checkpoint Semantics

The source-scoped ledger has `import_batches` with start and optional finish
fields, plus source-row cursors derived from imported rows. Current importers:

- select all source rows after the maximum successfully imported source ROWID;
- create a batch-start row;
- write one table's selected rows inside a transaction;
- use idempotent/ignore semantics where appropriate;
- close the source database in `finally`.

The batch is not a bounded chunk checkpoint. No production code was found that
marks `finished_at_utc`. A failed transaction rolls back that table's new rows,
but earlier completed tables remain. Retry can therefore converge by rerunning
idempotent stages, while abandoned batch-start metadata may accumulate.

This is restart-safe enough to avoid partial rows inside one failed
transaction. It is not a durable resume protocol and does not prove exactly
which stage was active at process death.

## 11. Current Progress Inventory

| Available fact | Produced where | Visible during Onboarding? |
| --- | --- | --- |
| Gate phase: importing/building/failed/complete | `OnboardingGate` | yes, as coarse presentation |
| Graph controller: idle/running/succeeded/failed | graph build controller | indirectly |
| Ordered 17-stage names | graph build orchestrator | no |
| Per-stage elapsed durations | build report after each stage completes | no |
| Message/attachment inserted counts | importer result | no |
| Projection work totals/completed units | selected projectors | no |
| Import batch start | source ledger | no |
| Durable current stage/heartbeat | absent | no |
| Attachment archive counts | archive service | not part of initial completion |

The active surface uses an indeterminate progress indicator. Existing
documentation that describes table, row, duration, or percentage progress as
current Onboarding behavior is stale.

## 12. Narrator Inventory

Presence currently narrates prerequisite Episodes:

- welcome and local-data explanation;
- impending source tests;
- FDA guidance and verification;
- Messages unavailable guidance;
- Contacts unavailable guidance;
- sparse-history warning and choice;
- accepted-readiness confirmation.

The import overlay uses calm fixed statements rather than the feature's newer
Directed Instrumentation/Narrator lifecycle. It does not narrate operational
stage transitions or measured progress.

This is not inherently wrong: a Narrator must not manufacture detail. The next
presentation layer should consume a truthful operation snapshot rather than
read providers ad hoc or infer progress from elapsed time.

## 13. Performance Timing Table

No production-sized initial-Onboarding benchmark was run in this read-only
audit. Current instrumentation supports only partial post-hoc analysis.

| Boundary | Timing available now | Audit result |
| --- | --- | --- |
| native claim/archive admission | no product timing | unknown first-paint cost |
| environment probes | no aggregate timing | unknown |
| source table import | no visible per-table duration | post-hoc only where orchestrator wraps it |
| rich-text extraction | stage duration after return | no live heartbeat |
| graph projection | stage duration after return | some internal work counts, not surfaced |
| full initial operation | controller timestamps/report | not durable enough for restart narrative |
| SQLite contention | 3-second source busy timeout | bounded open/query contention only |

Before visual progress is added, a staging benchmark should capture first
frame, probe duration, every import/projection stage, row counts, throughput,
longest no-event interval, and total operation duration.

## 14. First-Paint Findings

`main()` performs archive claim/admission and several platform initializations
before `runApp`. A failure in archive admission is handled outside the Flutter
surface. The first Onboarding frame therefore cannot appear until these
bootstrap awaits complete.

After Flutter mounts, both environment-report loading and Presence-scheduler
loading can show a spinner. No first-paint timing, launch heartbeat, or timeout
was found.

The desired invariant is:

> Show a stable admitted application shell as soon as it is safe, then derive
> Onboarding content without leaving a blank or unexplained window.

Whether native archive admission can be presented earlier requires a separate
bootstrap design; it should not be hidden inside Onboarding UI work.

## 15. Database Lifecycle Map

| Store | Creation/open authority | Onboarding role | Reset behavior |
| --- | --- | --- | --- |
| `macos_import_ss.db` | admitted central provider | source-scoped import ledger | deleted as rebuildable |
| `working_ss.db` | admitted central provider | app-facing graph | deleted as rebuildable |
| `user_overlays.db` | admitted central provider | user intent, failures, archive metadata | preserved |
| `presence.db` | admitted central provider | definitions, runs, execution trace | preserved by message reset |
| `attachment_archive/` | admitted attachment stores | preservation payloads | never deleted by reset |
| retired `macos_import.db` / `working.db` | lifecycle cleanup only | none | may be deleted explicitly |
| `application_logs/` | admitted logger | diagnostics | preserved by message reset |

The live source uses canonical source identity in the import ledger. Initial
Onboarding does not create a separate archive-specific source workflow.

Graph schema creation also creates its ordinary SQLite indexes. No independent
FTS/search-index Onboarding stage was found; search uses the prepared graph and
its repository queries.

## 16. Mutation-Authority Audit

Initial import enters `ArchiveMutationOperation.onboardingImport` through
`ArchiveMutationCoordinator`. The reset runs as an owned nested
`messageDataReset` operation. Graph build receives the same owning identity.

This provides:

- one admitted mutation owner;
- exclusion of incompatible archive operations;
- owner-aware graph access;
- explicit provider closure before derived-file deletion;
- no UI-owned SQLite connection.

The authority model is stronger than the progress model. It determines who may
mutate, but does not itself persist operation progress or human-facing state.

No bypass of the coordinator was found in the initial Onboarding action path.

## 17. Maintenance And Readiness Interaction

Environment Readiness recognizes `maintenanceInProgress` and does not open the
import or graph databases merely to count rows during admitted maintenance.
The Gate treats that state as `notNeeded`, preventing unrelated maintenance
from redirecting the application into Onboarding.

This is an important mechanical invariant established by earlier archive work:

> Readiness observation cannot compete with or reinterpret an admitted
> mutation.

Busy timeout remains bounded SQLite contention tolerance. It does not authorize
readiness reads during maintenance.

## 18. Completion Truth

On restart, operational readiness requires both:

- populated source-scoped import evidence; and
- a ready Conversation Graph.

This is stronger than trusting a process-local “completed” flag. The immediate
completion screen is process-local, but ordinary future launch derives the
usable state from durable stores.

Completion does **not** currently prove:

- every source row imported without unresolved anomaly;
- desired iCloud history was fully synchronized;
- every locally available attachment payload was archived;
- all future background maintenance is complete.

The product claim should be scoped to “MessageLens has enough imported and
projected data to begin browsing,” unless stronger evidence is added.

## 19. Restart And Interruption Matrix

| Interruption point | On restart | Work preserved | Work repeated |
| --- | --- | --- | --- |
| prerequisite guidance | current Trip reconstructed at Step 1 | Schedule/Trip occurrence | Tell/interaction Steps in Trip |
| before import command | readiness and accepted choice re-derived | Presence completion/choice | probes |
| during derived reset | incomplete files detected | overlay, Presence, archive | reset and full build |
| during table transaction | committed earlier stages survive | prior committed tables | failed table/stages |
| during graph projection | graph readiness/failure inferred | committed graph rows | reset/full build under current Gate path |
| stable failure | persisted phase failure available | failure summary/time | retry operation |
| completion screen | durable stores classify ready | all persistent stores | no setup work |
| later attachment sweep | archived payloads/metadata retained | completed payload installs | unresolved candidates |

The restart promise is currently **reconstruct and retry**, not exact
checkpoint resume.

## 20. Presence Persistence Audit

`presence.db` owns reusable definitions, Schedule runs, and execution trace.
For the required-source Schedule:

- current Trip occurrence is durable;
- completed Schedule state is durable;
- selected Choice routing becomes durable Journey position;
- concrete Step position inside the active Trip is not durable;
- a restart reconstructs the active Trip from its first Step;
- process-local activation/interaction occurrences reject stale callbacks.

This explains the intentionally repeated “welcome back / I need to check”
experience after restart.

Presence completion represents accepted prerequisite Journey truth. It cannot
override a newly missing source, corrupt derived store, or active maintenance
operation. Operational evidence remains authoritative.

## 21. Failure Taxonomy

| Category | Example | Current representation | Needed ownership |
| --- | --- | --- | --- |
| permission blocked | FDA denied | typed readiness + Presence route | prerequisite Journey |
| source unavailable | missing/unreadable `chat.db` | typed blocker | prerequisite Journey |
| source suspicious | <=10 messages | typed sparse state + Choice | prerequisite Journey |
| unsupported source shape | missing table/column | generic query/import failure | source qualification |
| record anomaly | malformed required row | stage exception | future record-fidelity policy |
| storage failure | disk full / write denied | pipeline failure | owning mutation |
| contention/busy | competing operation/SQLite lock | denial or DB error | coordinator/database boundary |
| interrupted operation | process exit | inferred incomplete state | durable operation model |
| graph projection failure | projector throws | persisted graph failure | graph owner |
| diagnostics failure | log file unavailable | silent in-memory degradation | logging boundary |
| preservation lag | payload unavailable | archive hint/retry | attachment preservation |

## 22. Silent-Failure Findings

The following paths can lose useful human evidence:

- persistent logging intentionally degrades to in-memory only if its directory
  or file cannot be opened;
- log append/flush/rotation failures are swallowed to protect application
  execution;
- source readiness provider errors can fall back to coarse Gate inference;
- missing rich-text extraction is countable but not reported to the Onboarding
  human;
- attachment payload archival occurs after usable completion and can therefore
  lag without being part of the completion statement;
- the Option-launch delete request performs no operation and presents no
  warning that nothing was reset.

Logging degradation is acceptable operationally only if diagnostic export can
truthfully report that persistent logs were unavailable.

## 23. Forever-Spinner Findings

Reachable unbounded waiting surfaces include:

- Presence scheduler/provider loading;
- environment-report loading;
- initial import overlay;
- graph-build overlay;
- automatic recovery preparation.

No operation-level watchdog, durable heartbeat, longest-stage expectation, or
“still working / needs attention” transition was found. SQLite source opens
have a 3-second busy timeout, but that does not bound filesystem scans, source
queries, Rust extraction, Dart row loops, projection work, or a stuck Future.

This is a P1 because a user cannot distinguish slow work from dead work.

## 24. Human-Attention Model

Current attention ownership is mostly sound:

- Presence asks for FDA, source repair, Contacts repair, or sparse-history
  choice;
- the import overlay blocks conflicting interaction while MessageLens works;
- stable failure offers Retry and support rather than pretending work
  continues;
- completion asks for one final acknowledgment.

The missing state is “MessageLens has not produced operational evidence for a
bounded interval.” That is neither ordinary progress nor immediate failure.
It needs a truthful attention transition backed by a heartbeat/watchdog.

## 25. Virgin Or Fresh Installation Definition

A virgin MessageLens installation is not “the whole archive directory is
missing.” Production archive admission may require a valid adopted/installed
archive marker before Flutter starts.

The useful product definition is:

- valid admitted archive identity exists;
- preservation archive is absent or intentionally empty;
- no source-scoped import or graph data exists;
- no user overlay intent exists;
- no active/completed Presence Onboarding run exists;
- no persisted pipeline failure exists;
- Apple source databases remain completely external and untouched.

Packaging/adoption must guarantee that a legitimate first production launch
can reach this state. Otherwise archive admission can fail before Onboarding
has a surface on which to help.

## 26. Existing Reset Machinery

`MessageDataResetService` is a safe rebuildable-data reset, not Start Fresh.
It deletes only:

- `macos_import_ss.db` and sidecars;
- `working_ss.db` and sidecars;
- retired `macos_import.db` / `working.db` artifacts and sidecars.

It preserves:

- `user_overlays.db`;
- `presence.db`;
- `attachment_archive/`;
- archive identity/marker;
- application preferences and logs.

It validates base filenames, closes providers, uses mutation authority, and
does not recursively delete the archive root.

## 27. Incomplete-Installation Classification

The current report infers incomplete installation from combinations of:

- missing/empty import database;
- missing/empty graph;
- persisted import or projection failure;
- graph controller status;
- source/import count plausibility;
- existing derived files.

Automatic recovery uses heuristics, including relative row-count thresholds.
These heuristics can identify common interrupted builds but do not form one
durable installation-state entity.

A future typed classification should distinguish:

- virgin;
- prerequisites incomplete;
- ready for initial mutation;
- operation active;
- interrupted but safely retryable;
- stable failure requiring attention;
- ready for browsing;
- ready with background preservation still pending;
- inconsistent and requiring support.

## 28. Start Fresh Safety Contract

Start Fresh is achievable, but not by deleting the archive root.

The minimum contract is:

1. explicit human command and destructive confirmation;
2. fresh archive/mutation authority admission;
3. close all affected providers;
4. delete only enumerated rebuildable MessageLens stores;
5. never mutate Apple Messages, Contacts, or source attachment payloads;
6. never delete `attachment_archive/`;
7. preserve user-authored overlay intent by default;
8. treat Presence Onboarding state, persisted pipeline failures, and selected
   setup preferences explicitly rather than incidentally;
9. preserve archive identity unless a separate adoption operation owns its
   replacement;
10. record and present the resulting clean-state classification;
11. make interruption idempotent and safe to retry;
12. never describe a reset as completed until filesystem evidence confirms it.

There may eventually be two commands:

- **Rebuild Message Data**: current safe derived-store reset.
- **Restart Setup Journey**: reset relevant Onboarding/Presence/failure state
  while preserving user intent and archived payloads.

Combining them requires an explicit composition operation, not broad deletion.

## 29. Tester Migration Strategy

For abandoned installations:

1. admit the existing archive normally;
2. inventory preservation, overlay intent, Presence, import, graph, and failure
   state read-only;
3. classify the installation mechanically;
4. offer normal Resume/Retry when state is coherent;
5. offer Start Fresh only when the human explicitly chooses it;
6. explain exactly what is preserved before confirmation;
7. export diagnostics before destructive work when the state is inconsistent;
8. keep production and development archive identities separate;
9. never infer consent from an old version number or old failed run;
10. verify post-reset clean state before restarting prerequisite guidance.

Old Presence definitions/runs need a deliberate lifecycle policy. They must
not be dropped merely to make an old tester look new.

## 30. Testability Gaps

Existing tests strongly cover readiness classification, Presence routing,
Gate transitions, failure surfaces, reset allow-list behavior, source import,
graph orchestration, and architecture boundaries.

Missing or insufficient coverage includes:

- Option-launch Start Fresh end to end;
- first production launch with no prior archive adoption;
- process kill at every import/projection boundary;
- durable operation-stage reconstruction;
- disk full and permission loss mid-transaction;
- WAL/lock contention during initial import;
- malformed-record continuation without suppression;
- production-sized timing and longest-no-event interval;
- watchdog transitions;
- complete/partial iCloud-history fixtures;
- VoiceOver, keyboard-only, large text, and reduced-motion onboarding;
- attachment preservation status at initial completion;
- log-storage failure and truthful diagnostic export;
- migration of an abandoned pre-current-schema installation.

## 31. State-Architecture Findings

Current state is distributed across:

- environment report;
- Gate process-local status;
- Presence Schedule run/trace;
- import ledger and batch rows;
- graph rows/controller state;
- overlay failure metadata;
- archive mutation coordinator;
- attachment archive state.

Each owner is individually defensible. The missing composition authority is a
typed Onboarding Journey snapshot that derives one truthful human state from
those facts. It should not replace specialist owners or become another mutable
workflow flag bag.

The Mechanical Impossibility goal is:

> A presentation can claim working, waiting, failed, interrupted, or complete
> only when the corresponding operational evidence exists.

## 32. Track And Layout Findings

Current Onboarding and Environment Readiness presentation does not participate
in `PageTrackLayoutMatrix`. No `TrackOccupant`, `TrackCellView`, or page matrix
registration was found in these paths.

That is not automatically a defect. The initial prerequisite and import
surfaces are full-window modal journeys rather than peer sidebar/center page
composition. Track adoption should occur only if a real cross-column alignment
relationship is introduced.

The current risk is independent: large readiness/control content can exceed a
window and needs bounded scrolling and responsive text layout. Tracks must not
be used as fixed-height reservation for that problem.

## 33. Accessibility Findings

Positive current properties:

- actions use visible text labels;
- state is generally conveyed through text and icons, not color alone;
- blocking overlays prevent accidental background interaction;
- stable failure exposes explicit actions.

Unproven or missing properties:

- no feature-local explicit live-region announcements were found for progress,
  failure, or completion transitions;
- no focused VoiceOver journey test exists;
- keyboard focus entry/return for modal and Presence transitions is not proven;
- large text and constrained-window layouts are not covered end to end;
- indeterminate progress has no accessible elapsed/liveness description;
- reduced-motion behavior across the full Onboarding Journey is not verified.

Accessibility is P2/P3 until tested, but a user unable to discover the next
required action becomes a P1 product outcome.

## 34. Security And Privacy Findings

Strong boundaries:

- source databases are opened read-only and set `query_only`;
- one-off source handles close in `finally`;
- application stores require archive admission;
- mutation authority excludes conflicting writers;
- source records are not uploaded by the inspected core path;
- database-health diagnostics avoid row-level content samples;
- attachment preservation never deletes source payloads.

Privacy considerations:

- application logs persist inside the admitted archive and non-debug entries
  also go to macOS unified logging;
- errors and stack traces can contain filesystem paths or database details;
- diagnostic export may expose machine and archive metadata;
- FDA grants broad local visibility even though MessageLens should exercise
  only documented source access.

Future diagnostics must default to aggregate counts, typed failure codes, safe
source-scoped identities, and redacted paths. Message text, contact details,
attachment contents, and raw handles must not be included without explicit
reason and human consent.

## 35. Recommended Blocker Presentation

Every blocker should present five facts:

1. **What MessageLens checked.**
2. **What it could and could not establish.**
3. **Whether MessageLens is working or waiting.**
4. **The one action the human can take now.**
5. **What has already been preserved.**

Recommended categories are permission, source missing, source incomplete or
uncertain, Contacts unavailable, source/schema unsupported, storage failure,
operation interrupted, operation stalled, and internal inconsistency.

Raw exceptions belong in diagnostics, not the primary headline. A blocker
must never redirect to FDA unless permission-denial evidence specifically
supports that explanation.

## 36. Retry And Resume Semantics

Use these terms precisely:

- **Re-check**: rerun a read-only prerequisite test.
- **Retry**: start the failed owning operation again from its safe boundary.
- **Resume**: continue from a durable checkpoint without repeating earlier
  completed work.
- **Rebuild**: intentionally discard enumerated derived stores and derive them
  again.
- **Start Fresh**: deliberately return the MessageLens-owned setup Journey to
  a known state under the preservation contract.

Current initial setup supports re-check, retry, and rebuild/convergence. It does
not support exact resume. UI copy should not use “resume” until durable
checkpoint semantics exist.

## 37. Diagnostic-Report Recommendation

Add a bounded Onboarding diagnostic projection derived from existing owners.
It should include:

- app/build/archive environment identity without personal root details;
- current typed Journey classification;
- prerequisite outcomes and timestamps;
- operation identity, admitted owner, start/last-evidence/end timestamps;
- current/last completed stage;
- aggregate source/import/graph counts;
- unresolved anomaly counts by reason;
- persisted failure code and safe summary;
- database integrity/readiness results;
- attachment preservation aggregate status;
- whether persistent logging is available;
- restart and retry history.

It should exclude message text, contact names, raw handles, full source paths,
attachment contents, and secret material. Export must be an explicit human
action.

## 38. Ordered Implementation Slices

1. **Truthful operation snapshot and liveness.** Compose current specialist
   evidence into typed states; add durable operation/stage/heartbeat facts only
   where existing stores cannot prove them.
2. **Start Fresh authority and false-control removal.** Either remove the
   Option-launch destructive promise immediately or implement the reviewed
   allow-list operation with preservation proof.
3. **Record-level anomaly contract.** Preserve every source row or durable
   failure evidence without whole-dataset stranding.
4. **Prerequisite/history model.** Replace the 10-row heuristic with bounded
   local-history evidence and explicitly human-only iCloud guidance.
5. **Real progress instrumentation.** Publish measured stage, counts, elapsed
   time, and heartbeat; establish watchdog classification.
6. **Restart/retry reconciliation.** Make interruption classification and
   operation convergence explicit; add true checkpoints only if evidence
   justifies them.
7. **Presence/Narrator rendering.** Project the typed Journey and Moments with
   stable attention ownership, terminal dwell, and stale-event rejection.
8. **Accessibility and responsive layout.** Verify VoiceOver, keyboard, large
   text, reduced motion, and small windows.
9. **Tester migration and production rehearsal.** Exercise virgin, abandoned,
   failed, sparse, malformed, interrupted, and successful installations.
10. **Final conformance.** Reconcile docs, diagnostics, copy, release metadata,
    and complete end-to-end evidence.

Slice 1 precedes visual redesign because the presentation cannot be more
truthful than the facts it receives.

## 39. Hard Invariants

1. Apple Messages and Contacts databases are authoritative external sources
   and never MessageLens deletion targets.
2. All Apple Messages timestamp conversion uses
   `lib/core/util/date_converter.dart`.
3. Every source record remains visible or has durable source-scoped failure
   evidence; anomalies are never silently suppressed.
4. `attachment_archive/` is preservation data and never reset/recreated as a
   cache.
5. Overlay user intent never enters rebuildable graph projection.
6. Reset uses an explicit allow-list, never broad root deletion.
7. Presence cannot override operational truth.
8. Readiness cannot open protected stores during admitted maintenance.
9. Mutation requires archive admission and coordinator authority.
10. A source-side human/device setting is never claimed as known when only a
    local symptom is observable.
11. Progress, completion, recovery, and estimates derive from evidence, not
    elapsed-time theatre.
12. Start Fresh requires fresh explicit human authorization and proves what it
    preserved.
13. Restarted or late asynchronous work cannot revive an abandoned Journey
    occurrence.
14. Production and development archive identities remain distinct.
15. No ordinary Onboarding path mutates or deletes Apple source payloads.

## 40. Release-Blocking Risks

| Priority | Risk | Why it blocks |
| --- | --- | --- |
| P1 | Option-launch delete button is a no-op | explicitly promises recovery that does not occur |
| P1 | no liveness/watchdog contract | users can be stranded at an indistinguishable spinner |
| P1 | whole-stage malformed-record abort | one unusual source row can strand an otherwise valid installation |
| P1 | no end-to-end interrupted-install migration proof | returning testers may not know whether to retry, rebuild, or seek help |
| P1 | production first-use archive adoption dependency | a missing marker can fail before Flutter Onboarding can help unless packaging guarantees adoption |
| P2 | completion excludes attachment-payload preservation | product scope can be misunderstood |
| P2 | distributed state lacks one derived Journey snapshot | future fixes risk adding imperative cleanup and contradictory presentation |
| P2 | sparse-history threshold does not prove completeness | may admit unexpectedly incomplete local history |
| P2 | persistent diagnostic availability can fail silently | support evidence may disappear when most needed |
| P2/P3 | accessibility journey not validated | next action may be unavailable to keyboard/VoiceOver/large-text users |

There is no identified P0 data-corruption path in the audited initial
Onboarding flow. P1 work must precede visual polish.

## Audit Decision

Feature 28 should proceed, but implementation must begin with operational truth
and recovery authority, not a redesigned welcome screen.

The safety foundation is worth preserving. The next architecture must make its
facts legible enough that a person can always tell whether MessageLens is
working, waiting, blocked, interrupted, failed, or ready—and what will survive
the next action.
