Perfect. **28-ONBOARDING begins now.**

I would make the seed deliberately comprehensive and primarily read-only. Before Codex fixes anything, we want a map of the _entire_ journey—including the six testers' failure modes, restart/recovery behavior, and the future **Start Fresh** capability.

Work on the current project branch/worktree according to repository conventions.

Create Feature 28 for **Onboarding** under the normal new-feature working area.

This is a comprehensive READ-ONLY architecture, journey, failure, persistence, performance, and recovery audit.

Do NOT redesign Onboarding yet.

Do NOT begin fixing individual bugs as you encounter them.

Do NOT change schemas, databases, source data, or application behavior.

The purpose is to reconstruct the entire existing Onboarding system before we touch it.

# Why this feature matters

Onboarding is the final major MessageLens feature requiring completion.

Earlier external testing exposed a fundamental product failure:

> Testers could encounter prerequisites, unusual source data, or operational failures and become stranded without understanding what had happened or what they needed to do.

The first six testers did not become active MessageLens users because they encountered installation/onboarding problems and abandoned the process.

Known examples include:

- users not realizing that the relevant Messages/iCloud configuration needed to be enabled on both Mac and iPhone;
- at least one intake apparently stopping around an unusual handle resembling `*city*` associated with Hong Kong, without useful explanation;
- long-running work that could appear stalled;
- incomplete installations whose later state/recoverability is unclear.

Do not assume these remembered examples identify the current bugs precisely.

Treat them as evidence of the larger architectural/product requirement:

> No prerequisite failure, unusual record, operational error, interruption, or unsupported condition may leave the user staring at a spinner, frozen screen, unexplained halt, or apparently dead application.

# Central acceptance principle

At every point in Onboarding, the human should be able to answer:

1. **What is MessageLens doing?**
2. **Do I need to do anything?**
3. **If something went wrong, what happened in human terms?**
4. **What can I do next?**
5. **Is work already completed safe/preserved?**
6. **Can I leave and come back?**

There must eventually be no reachable state whose practical human interpretation is:

> “I don't know whether MessageLens is working, broken, waiting for me, or finished.”

# Presence principle

Onboarding is the strongest application yet of the established Presence model.

Treat the product promise:

> **“I’ve got you. I’ll be here when you come back.”**

as an architectural requirement, not decorative reassurance.

Presence must remain truthful.

It must derive from actual operational/persistent state.

Do not invent progress, estimates, reassurance, or continuity that the system cannot support.

# Existing design grammar to reuse where earned

The project now has established patterns for:

- typed presentation state;
- Mechanical Impossibility;
- stable Page Tracks;
- Narrator lifecycle;
- Directed Instrumentation;
- real progress denominators;
- immediate first paint before expensive work;
- mutation authority;
- maintenance admission;
- session/occurrence ownership;
- stale async callback rejection;
- terminal completed-state dwell;
- modal ownership;
- durable versus transient truth;
- fail-closed qualification;
- restart/idempotency;
- profiling before decorating long spinners.

Audit how much of this Onboarding already uses.

Do not assume it does.

# First deliverable — reconstruct the complete journey

Build an explicit state/transition map from:

first application launch

through:

usable MessageLens application.

Do not start from UI screens alone.

Trace actual application/domain/database state.

At minimum identify:

- pre-Onboarding environment detection;
- permissions;
- Messages source availability;
- Contacts source availability;
- iCloud-related assumptions/detection;
- archive/data-folder initialization;
- source registration;
- import database creation;
- source import;
- attributed-string decoding;
- handles;
- contacts;
- conversations/chats;
- messages;
- attachments;
- reactions;
- graph preparation;
- search/index preparation;
- attachment archival;
- overlays;
- readiness checks;
- final transition into normal application use.

Use actual code as authority.

Do not force this exact list if architecture differs.

# Journey table

Create a table for every meaningful state/stage:

| State / Stage | Durable truth | Transient truth | Work occurring | Human sees | Human action required | Can leave/restart? | Failure outcome | Recovery |

There must eventually be no unexplained hole in this table.

# Distinguish Journey, Episode, Moment

Apply canonical Presence terminology.

Determine:

## Journey

The complete undertaking from first launch to usable MessageLens.

## Episodes

Human-meaningful interaction steps where attention/decision may be required.

## Moments

Transient information/progress that does not change the current Episode.

Audit whether current Onboarding incorrectly models implementation stages as user Episodes or vice versa.

# Prerequisite audit

Enumerate every prerequisite that can prevent successful Onboarding.

At minimum investigate:

- Full Disk Access / Messages database access;
- Contacts access;
- source database readability;
- Messages/iCloud configuration assumptions;
- iCloud Messages synchronization state;
- whether Mac has complete local history;
- whether iPhone/iPad settings matter;
- disk space;
- database locks;
- unsupported Messages schema;
- required application directories;
- archive-environment validity;
- attachment accessibility;
- network requirements, if any.

For each classify:

### Detectable automatically

MessageLens can establish truth mechanically.

### Partially detectable

MessageLens can see symptoms but cannot prove configuration.

### Human-only

MessageLens must explain what the person needs to verify.

Do not claim MessageLens can detect an iPhone setting if it cannot.

# iCloud / Messages history problem

Investigate the historical tester failure where users did not understand that Messages/iCloud configuration needed to be enabled appropriately on Mac and iPhone.

Determine exactly what MessageLens actually requires.

Questions:

- Does MessageLens require Messages in iCloud?
- Or was that requirement merely necessary to get the complete phone history onto the Mac?
- Can MessageLens detect whether Messages in iCloud is enabled on the Mac?
- Can it detect whether the local `chat.db` appears incompletely synchronized?
- Can it know anything authoritative about the iPhone's setting?
- Is the prerequisite “enable iCloud” or actually “ensure the messages you want are present on this Mac before import”?

This distinction matters enormously.

Do not perpetuate historical instructions until their semantics are proven.

Recommend the truthful human prerequisite language.

# Permission audit

Trace every macOS permission involved.

For each:

- what API/database access requires it;
- how MessageLens detects absence;
- whether the OS prompt can be triggered;
- whether System Settings must be opened manually;
- whether restart is required after granting;
- how Onboarding knows permission has become available;
- what current UI says;
- whether denial can strand the journey.

Map exact recovery path.

# Source-data audit

Trace every source-data assumption.

For `chat.db` and Contacts:

- expected location;
- schema/version;
- WAL/SHM handling;
- read-only behavior;
- snapshot/copy behavior;
- database consistency;
- concurrent Messages writes;
- malformed rows;
- missing relationships;
- unusual handles;
- NULL/invalid fields;
- attachment anomalies;
- attributed-string decoding failures.

The source data is not under MessageLens control.

Onboarding must treat weird but valid source records as expected environmental input.

# The `*city*` / Hong Kong failure archetype

Search code, tests, logs/docs, historical records, and git history where appropriate for evidence of the tester failure involving an unusual handle resembling:

`*city*`

and/or Hong Kong.

Do not special-case that literal value unless current evidence proves a specific canonical rule.

Instead determine:

- which pipeline stage could stop on unusual handle data;
- whether normalization/parsing assumes phone/email format;
- whether exceptions propagate;
- whether one malformed/unrecognized handle aborts an entire batch;
- whether current code logs/skips/classifies it;
- whether UI receives a typed failure.

Use this as an archetype:

> One unexpected source record must not silently terminate the Journey.

# Record-level failure policy

Audit each intake domain:

- handles;
- contacts;
- chats;
- messages;
- attachments;
- reactions;
- attributed strings.

For each determine whether one bad record should:

### Fail the entire operation

Only if continuing would make durable state untrustworthy.

### Be quarantined/recovered

Preserve record/evidence in a recoverable path.

### Be skipped with explicit accounting

Only if product semantics allow it.

### Require human intervention

Only where the human can genuinely resolve it.

No silent loss.

No broad `catch (_)` followed by continuation without evidence.

# Batch semantics

For every large import stage determine:

- total work denominator, if known;
- batch size;
- transaction boundaries;
- checkpoint behavior;
- what is durable after each batch;
- what happens if item N fails;
- whether successful prior batches survive;
- whether retry duplicates work;
- whether import is idempotent.

# Directed Instrumentation audit

Inventory all current progress reporting.

For every visible progress element identify:

- real work boundary;
- numerator;
- denominator;
- completion condition.

Find:

- spinner-only stages;
- fabricated percentages;
- timers;
- stale progress;
- stages that disappear too quickly;
- operations lasting >2–3 seconds without changing evidence.

Do not redesign yet.

# Narrator audit

Inventory every current Onboarding explanatory/status sentence.

For each determine:

- typed state/phase that owns it;
- when it becomes true;
- when it ceases to be true;
- whether it can become stale;
- whether it merely paraphrases instrumentation;
- whether it asks the human for action clearly.

Identify where Narrator is missing but a scope/meaning transition genuinely needs interpretation.

# Long-running operation profiling

Profile representative Onboarding stages using fixtures/known-safe test data.

Look for the lessons from Features 26/27:

- N² algorithms;
- per-row queries;
- exhaustive work performed too early;
- hashing/integrity work at wrong lifecycle boundary;
- synchronous main-isolate work;
- duplicate provider execution;
- repeated database opening;
- work restarted by rebuild;
- expensive calculations that should be set-based.

Do not decorate pathological operations.

Record timings.

# First-paint audit

For every consequential user action:

- Start;
- Continue;
- Grant/Retry permission;
- Begin import;
- Resume;
- other major controls;

trace:

button activation
→ typed state publication
→ first painted frame
→ expensive work.

Identify places where the user can click and receive no immediate visual acknowledgement.

Do not fix yet unless needed for instrumentation.

# Database lifecycle

Map every database involved during Onboarding.

At minimum where applicable:

- live `chat.db`;
- Contacts database;
- import database;
- working graph database;
- overlay database;
- attachment archive;
- search database/index;
- presence database;
- archive marker/environment metadata.

For each operation document:

- who opens it;
- read/write mode;
- canonical constructor/opener;
- transaction ownership;
- mutation authority;
- maintenance restrictions;
- close behavior;
- busy timeout;
- restart behavior.

Look for ad-hoc constructors and ordering workarounds.

# Mutation authority

Audit all Onboarding mutation.

Determine:

- which operations are currently admitted through `ArchiveMutationCoordinator`;
- which predate it;
- whether Onboarding has broad bypasses;
- whether graph/import/attachment writes can overlap incorrectly;
- whether nested operation semantics are correct.

Do not redesign coordinator in this audit.

# Maintenance/readiness

Onboarding and Environment Readiness have historically interacted.

Trace:

- what causes Onboarding to appear;
- how readiness is computed;
- what happens during admitted maintenance;
- what happens after crash/restart;
- whether temporary maintenance can masquerade as failed installation;
- whether stale failure state can reopen Onboarding incorrectly.

Use Feature 26's hardened maintenance semantics as reference.

# Completion truth

Define exactly what must be durably true before Onboarding may say:

> complete

and enter the ordinary application.

List required invariants.

Do not rely on:

- UI stage completion;
- progress reaching 100%;
- existence of one database.

Completion should derive from durable authoritative facts.

# Restart/interruption matrix

For every major stage, analyze:

### App quit normally

### App force-quit/crash

### Mac restart

### Sleep/wake

### User navigates away

### Source database changes

### External operation/maintenance begins

Determine what happens on relaunch.

The Journey should resume/reconcile from durable truth rather than replay stale presentation state.

# Presence persistence

Audit current Presence persistence.

Determine:

- what Journey/Episode state is durable;
- what is reconstructed;
- what is presentation-only;
- whether stale Presence can contradict databases;
- whether operation progress survives restart truthfully;
- whether Presence database is authoritative or descriptive.

Apply:

> Durable operational truth outranks persisted narration.

# Failure taxonomy

Enumerate every typed/current failure.

Then identify untyped failure sources.

Build a taxonomy such as:

## Prerequisite not satisfied

Human can fix configuration/permission.

## Source temporarily unavailable

Retry later.

## Unsupported source

Cannot proceed with current version.

## Recoverable record anomaly

Continue with explicit accounting.

## Operation failure

Retry/resume possible.

## Integrity failure

Cannot safely continue.

## Internal defect

Unexpected invariant violation.

Use actual architecture; this is illustrative.

Every failure class needs a human-visible destination eventually.

# No silent failure invariant

Search explicitly for:

- swallowed exceptions;
- `catch (_)`;
- logged-only errors;
- futures whose errors are ignored;
- stream subscriptions without error handlers;
- batch loops that terminate on one item;
- providers that remain loading after exception;
- nullable results interpreted as “still working”;
- background isolates whose failure is not projected.

This is a critical audit.

# “Forever spinner” audit

Identify every state capable of displaying an indeterminate spinner.

For each answer:

- what ends it?
- what failure ends it?
- is there a timeout?
- should there be a timeout?
- can underlying work terminate without state transition?
- can work never terminate?
- is there real progress evidence available instead?

No spinner should be capable of becoming the user's only evidence indefinitely.

# Human attention model

For every state classify:

### MessageLens is working — human can leave

### MessageLens needs the human now

### MessageLens cannot proceed until external condition changes

### MessageLens has failed and offers recovery

This should eventually drive Presence/Narrator semantics.

# Fresh-install / Start Fresh audit

This is a first-class Feature 28 requirement.

The original six testers have abandoned/incomplete installations and are waiting for the new version.

The desired product behavior is:

> They should be able to install the new build, deliberately discard incomplete MessageLens-owned installation state, and begin from the same known-clean Onboarding state as a first-time user.

They should NOT need to:

- understand Application Support;
- manually delete databases;
- run Terminal commands;
- preserve archaeological state from failed old onboarding.

# Define “fresh”

Identify exactly what constitutes a virgin MessageLens installation.

List:

- files;
- databases;
- directories;
- markers;
- overlay state;
- Presence state;
- preferences;
- source registry;
- attachment archive;
- search/index state.

Distinguish:

### MessageLens-owned derived/imported state

Potentially safe to discard.

### User-authored MessageLens state

Potentially valuable and deserving warning/preservation.

### External source data

Must NEVER be touched:

- `chat.db`;
- Contacts;
- Messages attachments;
- other Apple data.

# Existing reset machinery

Audit all current:

- reset;
- rebuild;
- delete working data;
- maintenance;
- archive initialization;
- database close/recreate;
- Onboarding restart;

services.

Determine whether Start Fresh can be composed from canonical existing operations.

Do not implement it yet.

# Incomplete-install detection

Determine how MessageLens can distinguish:

### Virgin

No installation begun.

### In progress / resumable

Durable valid work exists and journey can continue.

### Completed

Normal app ready.

### Abandoned/incomplete legacy installation

State exists but current Onboarding cannot safely resume it.

### Corrupt/inconsistent

Requires remediation/reset.

Do not infer this solely from file existence.

Build a proposed typed installation-state model.

# Start Fresh safety contract

Recommend a future operation with hard invariants:

- explicit human authorization;
- clearly state what MessageLens-owned data will be deleted;
- never touch source `chat.db`;
- never touch Contacts;
- never touch Apple's attachment files;
- close databases before deletion;
- run under mutation/maintenance authority;
- delete/recreate only canonical owned artifacts;
- verify clean state;
- restart Journey from virgin state.

If user-authored overlays might exist, determine whether Start Fresh should:

- preserve them;
- offer choice;
- warn that they will be removed.

Do not decide casually.

# Tester migration strategy

Recommend how the six abandoned testers should enter the new version.

Potential flow:

old incomplete state detected
→ MessageLens explains that this installation was not completed
→ offers **Start Fresh**
→ confirmation explains MessageLens-owned data reset
→ reset
→ new Onboarding Journey.

Do not implement yet.

# Testability

Onboarding must become reproducibly testable.

Audit existing fixture/harness support for:

- clean first launch;
- permission denied;
- missing chat.db;
- partial iCloud/local history;
- malformed handle;
- malformed message;
- attachment anomaly;
- crash mid-stage;
- database contention;
- maintenance;
- restart/resume;
- legacy incomplete installation;
- Start Fresh.

Identify missing test seams.

# Architecture ownership

Map ownership of:

- Journey coordinator;
- prerequisite detection;
- source inspection;
- import orchestration;
- progress observations;
- Presence;
- failure projection;
- reset/fresh-start;
- Settings/Onboarding presentation.

Find UI code that owns domain decisions.

Find application services that own presentation copy.

# State architecture

Determine how current Onboarding state is represented.

Audit for combinatorial nullable fields like pre-D1 Historical Archives.

List contradictory states currently representable.

Recommend whether a sealed typed state model is needed.

Do not implement yet.

# Tracks/layout

Map current Onboarding page geometry.

Determine:

- shared Tracks;
- sidebar/center relationship;
- progress placement;
- modal placement;
- state-dependent geometry;
- layout jumps.

Do not redesign yet.

# Accessibility

Audit:

- keyboard navigation;
- VoiceOver semantics;
- permission instructions;
- progress;
- errors;
- required-human-attention states;
- reduced motion;
- color-only signals.

Document gaps.

# Existing tester-facing copy

Audit current copy for:

- prerequisites;
- iCloud;
- permissions;
- progress;
- failure;
- retry;
- completion.

Flag:

- technically inaccurate instructions;
- developer terminology;
- vague “something went wrong”;
- statements that imply MessageLens is working when it is waiting for the human;
- instructions that cannot actually resolve the condition.

# Security/privacy

Audit whether Onboarding:

- sends any source data externally;
- logs message contents/PII unnecessarily;
- exposes raw handles in diagnostics;
- stores sensitive debug artifacts;
- writes source data or user-authored content outside canonical MessageLens-owned storage.

Confirm diagnostic logs avoid unnecessary message text/PII.

Do not redesign privacy architecture in this audit; document violations or risk.

# Performance baselines

Measure representative current Onboarding stages where fixtures safely permit.

Do not obsess over microbenchmarks.

We need to know:

- which stages complete essentially instantly;
- which take seconds;
- which take minutes;
- which are CPU-bound;
- which are database-bound;
- which are filesystem-bound;
- which are currently opaque.

Create a timing table.

# Existing progress denominator inventory

For every long-running stage determine whether MessageLens already knows:

- total handles;
- total contacts;
- total chats;
- total messages;
- total attachments;
- total reactions;
- graph entities;
- files;
- bytes;
- batches.

Record whether each denominator is:

### Exact

### Derivable cheaply

### Unavailable without architectural/performance harm

This will later drive Directed Instrumentation.

# Human-facing stage model recommendation

After tracing actual execution, recommend a small number of human-meaningful stages.

Do NOT simply expose every repository/table operation.

The human should understand the Journey.

For example only if supported by actual architecture:

- Preparing MessageLens
- Checking your Messages setup
- Reading your message history
- Organizing conversations
- Preparing attachments
- Checking everything is ready

But do not adopt these labels in the audit unless the real boundaries support them.

# Narrator recommendation

For each recommended Episode/stage identify where Narrator should:

- explain a scope/meaning transition;
- ask for human attention;
- become silent.

Narrator must not become a progress log.

# Directed Instrumentation recommendation

For each long-running execution stage identify:

- truthful rows;
- real counts;
- real bytes;
- real suboperations.

Apply lessons from Historical Archives:

Narrator explains meaning.
Directed Instrumentation demonstrates work.

# Blocker presentation model

Recommend a reusable onboarding blocker presentation.

A blocker should tell the human:

1. what MessageLens discovered;
2. whether their data is safe;
3. what they need to do;
4. exactly how to do it;
5. what control resumes the Journey;
6. whether MessageLens will detect resolution automatically.

Examples:

- permission missing;
- Messages history not present locally;
- unsupported source;
- disk full;
- source temporarily locked;
- anomalous record requiring skip/quarantine;
- old incomplete installation.

Do not implement.

# Automatic recovery versus human action

For each blocker classify:

### Auto-retry

MessageLens can wait/retry itself.

### Retry button

Human may resolve external condition and ask MessageLens to check again.

### Guided system action

Open System Settings/Finder/etc.

### Skip/quarantine

Operation can continue safely while preserving anomaly evidence.

### Start Fresh

Current MessageLens-owned state should be discarded and Journey restarted.

### Fatal unsupported condition

No safe path exists with current version.

This taxonomy should eventually prevent vague generic error screens.

# Retry semantics

Audit every existing retry action.

Determine:

- what it actually re-runs;
- whether it duplicates durable work;
- whether it clears evidence incorrectly;
- whether it can repeat destructive initialization;
- whether it returns to the correct Episode.

Recommend idempotent retry boundaries.

# Resume semantics

Determine whether Onboarding currently supports genuine resume.

If not, distinguish:

- restart whole journey;
- resume from durable checkpoint;
- reconcile and continue.

Do not call something “resume” if it actually deletes/reimports.

# Tester-observable diagnostics

We need future testers to be able to report a problem without becoming database experts.

Recommend a bounded diagnostic artifact for failed/stuck onboarding containing, where safe:

- Journey/Episode;
- current stage;
- typed failure;
- app version;
- database schema versions;
- source counts;
- last successful checkpoint;
- retryability;
- sanitized technical error.

Do not include message bodies or unnecessary PII.

Consider a future:

`Copy Diagnostic Information`

action.

Do not implement unless trivial; audit first.

# Watchdog / stall detection

Investigate whether some operations can become genuinely stuck without throwing.

Examples:

- hung isolate;
- blocked SQLite call;
- stream that never closes;
- deadlocked maintenance lock;
- lost callback.

Do not solve with arbitrary global timeouts.

Determine where bounded watchdogs might be appropriate.

A timeout should mean:

> “This operation exceeded a duration that indicates its expected contract has failed.”

not:

> “The user has been waiting too long, so pretend it failed.”

# Terminal completion presentation

Audit current transition from final operation to normal app.

Determine whether:

- all final checks become visibly complete;
- terminal acknowledgement exists;
- Onboarding disappears abruptly;
- user knows they are done;
- normal app appears before durable readiness is verified.

Recommend a perceptible terminal state.

# “Your data is safe” language

Audit every reassurance.

Only say:

- source data is unchanged;
- work is preserved;
- safe to quit;

when architecture proves it.

Do not use blanket reassurance.

# Start Fresh and backup/archive interaction

Feature 26 now provides Historical Archives.

Consider whether Start Fresh should encourage preserving old MessageLens data before deletion.

For abandoned tester installs, that may be unnecessary.

Audit whether:

- attachments/user overlays might be worth preserving;
- a MessageLens data folder could later be used for attachment recovery;
- current incomplete installs may contain unique data not present in source `chat.db`.

Do not automatically delete valuable user-owned state.

Recommend safe policy.

# Tester reset UX recommendation

Design conceptually, but do not implement, the future abandoned-install path.

Potential flow:

MessageLens detects incomplete older installation.

Narrator/center:

**This installation wasn’t completed.**

Explain:

- source Messages data will not be touched;
- existing MessageLens-owned setup can either be resumed if safe or discarded;
- for tester/legacy incomplete states, Start Fresh may be recommended.

Actions:

- Start Fresh
- perhaps Continue/Resume if genuinely safe
- Details

Do not expose this on healthy completed installations unnecessarily.

# Clean-install test harness

Recommend a repeatable test harness allowing agents/testers to create:

- virgin MessageLens environment;
- interrupted environment at known checkpoints;
- completed environment;
- legacy incomplete environment.

The harness must never point at production accidentally.

Prefer temp/staging roots and explicit environment markers.

Do not implement destructive helpers without strong guards.

# Known-incomplete tester migration

Document a future migration/testing procedure for the six abandoned testers.

The desired experience:

1. install new build;
2. old incomplete state detected;
3. clear explanation;
4. deliberate Start Fresh;
5. MessageLens-owned state reset;
6. modern Onboarding begins;
7. no Terminal/manual file deletion.

This becomes an explicit Feature 28 acceptance scenario.

# Architecture checklist

Before ending the audit, classify current Onboarding against these project rules:

## Mechanical Impossibility

Can contradictory states be represented?

## One semantic authority

Are prerequisite/readiness/import facts duplicated?

## Durable truth over presentation

Can UI state claim progress/completion inconsistent with databases?

## Mutation authority

Can work mutate outside admitted operations?

## Session safety

Can stale async completions affect a newer Journey?

## Canonical database ownership

Any ad-hoc constructors?

## DateConverter

Any duplicate Apple timestamp handling?

## SourceScopedRowKey

Any local scoping arithmetic?

## Tracks

Stable page geometry?

## Narrator

Phase-scoped?

## Directed Instrumentation

Real observations?

## Accessibility

Human meaning available without color/animation?

# Severity classification

Classify findings:

## P0

Potential data corruption/source mutation/security issue.

## P1

Can strand user, falsely report completion, or create inconsistent durable Onboarding state.

## P2

Architecture violation likely to cause future blocker/recovery bugs.

## P3

UX, accessibility, duplication, maintainability.

Do not begin remediation during this audit unless repository rules require a tiny diagnostic addition.

# Ordered implementation slices

At the end propose implementation slices.

Do NOT assume the order in advance.

However, likely categories may include:

- typed Journey/state foundation;
- prerequisite/readiness model;
- Start Fresh/reset;
- import instrumentation;
- record-level anomaly handling;
- Presence/Narrator rendering;
- restart/resume;
- terminal completion;
- final conformance.

Derive actual order from dependencies and severity.

# Required Feature 28 documentation

Create the Feature 28 working folder according to repository conventions.

Save this seed prompt.

Create the first response document, suggested:

`01-ONBOARDING-JOURNEY-FAILURE-RECOVERY-AND-FRESH-START-AUDIT.md`

The audit must include:

1. executive conclusion;
2. complete Journey/state map;
3. Journey/Episode/Moment mapping;
4. prerequisite matrix;
5. iCloud/Messages history findings;
6. permission matrix;
7. source-data anomaly handling;
8. `*city*`/Hong Kong investigation;
9. record-level failure policy;
10. batch/checkpoint semantics;
11. current progress inventory;
12. Narrator inventory;
13. performance timing table;
14. first-paint findings;
15. database lifecycle map;
16. mutation-authority audit;
17. maintenance/readiness interaction;
18. completion truth;
19. restart/interruption matrix;
20. Presence persistence audit;
21. failure taxonomy;
22. silent-failure findings;
23. forever-spinner findings;
24. human-attention model;
25. virgin/fresh installation definition;
26. existing reset machinery;
27. incomplete-install classification;
28. Start Fresh safety contract;
29. tester migration strategy;
30. testability gaps;
31. state architecture findings;
32. Track/layout findings;
33. accessibility findings;
34. security/privacy findings;
35. recommended blocker presentation;
36. retry/resume semantics;
37. diagnostic-report recommendation;
38. ordered implementation slices;
39. hard invariants;
40. release-blocking risks.

# No implementation

Do NOT:

- redesign screens;
- add Start Fresh;
- fix individual malformed-record bugs;
- add progress UI;
- change import algorithms;
- change schemas;
- change mutation authority;
- alter production data;
- modify source `chat.db`;
- modify Contacts;
- delete incomplete installations.

Tiny test/diagnostic additions are allowed only when needed to prove audit findings and must not change production behavior.

# Real data safety

Do not run destructive onboarding against production or tester data.

Use:

- fixtures;
- temp databases;
- explicit staging environments.

Read-only inspection of existing developer data is allowed only through canonical safe mechanisms and only when genuinely necessary.

# Verification

For a documentation-first audit, run:

- relevant Onboarding tests;
- readiness/environment tests;
- import pipeline tests where needed;
- architecture tripwires;
- `git diff --check`.

Run `flutter analyze` only if code/tests change.

Do not run a real full Onboarding mutation unless explicitly authorized later.

# Stop conditions

STOP and report rather than improvising if:

- canonical Onboarding documentation conflicts with current code materially;
- source-data safety is unclear;
- Start Fresh would risk user-authored unique data;
- completion truth cannot be derived without schema change;
- current state cannot be reconstructed safely;
- investigating tester failures requires unavailable historical logs.

Do not fill missing historical evidence with guesses.

# Final report to user

Return a concise but substantive summary containing:

- current Onboarding architecture;
- biggest user-stranding risks;
- likely explanation/status of known tester failures;
- prerequisite/iCloud truth;
- silent failure paths;
- spinner/stall risks;
- persistence/restart behavior;
- whether Start Fresh is safely achievable;
- what it would delete/preserve;
- recommended implementation slices in order;
- which slice should happen first;
- whether any P0/P1 issue must be addressed before UI work.

Do not start implementation until the audit is reviewed.

# Ultimate Feature 28 acceptance standard

The finished Onboarding feature must satisfy:

> A first-time user, a user with a missing prerequisite, a user whose source data contains something strange, a user whose import fails, a user who quits halfway through, and a tester returning with an abandoned old installation must all remain inside a truthful, recoverable Journey.

And:

> No one should ever have to wonder whether MessageLens has stopped, whether they caused the problem, or what they are supposed to do next.

And:

> A tester with an abandoned incomplete installation must be able to deliberately return to a known-clean MessageLens-owned state without manually deleting files and without risking Apple source data.
