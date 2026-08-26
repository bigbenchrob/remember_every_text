---
tier: project
scope: onboarding
owner: essentials-onboarding
last_reviewed: 2026-08-26
source_of_truth: feature-implementation-record
---

# Single-Authority Typed Onboarding Journey Coordinator

## Result

Onboarding now has one authority that selects its active Episode:
`OnboardingJourneyCoordinator`.

Environment Readiness, source probes, operation snapshots, lifecycle events,
Start Fresh, widgets, and Presence contribute facts or intent. They do not
advance the Journey.

## Competing-Authority Audit

Before this slice, production prerequisite progression was distributed across:

| Former participant | Former effective authority | Disposition |
|---|---|---|
| `OnboardingGate` | classified report state and assigned operational status | demoted to read-only compatibility projection and forwarding seam |
| required-sources Presence Schedule | persisted and advanced prerequisite Trips/Steps | removed from production composition; retained only as laboratory/history fixture |
| `OnboardingPresenceHost` | mounted prerequisite Schedule and FDA specialist | removed |
| Environment Readiness surface | combined report truth with Schedule completion | now consumes only the coordinator's coherent typed state |
| focus/relaunch flow | could resume “Welcome back” Step progression | removed as progression authority; may request a fresh check only |
| pipeline incident center sync | could replace first-run readiness content | blocked while a first-run Journey owns presentation |
| Start Fresh | invalidated several competing prerequisite authorities | now establishes verified virgin truth and requests coordinator refresh |

The application shell no longer mounts the prerequisite Presence host or
initializes its Scheduler. No fallback authority remains in production.

## Final Episode Model

The sealed `OnboardingJourneyState` variants are:

- `OnboardingCheckingPrerequisites`;
- `OnboardingNeedsMessagesAccess`;
- `OnboardingNeedsLocalHistoryConfirmation`;
- `OnboardingNeedsContactsAccess`;
- `OnboardingReadyToImport`;
- `OnboardingRecoveringDerivedData`;
- `OnboardingPreparingImport`;
- `OnboardingBuildingLocalData`;
- `OnboardingVerifyingDurableReadiness`;
- `OnboardingOperationFailed`;
- `OnboardingReadyToStart`;
- `OnboardingNormalApplication`;
- `OnboardingReimporting`;
- `OnboardingReimportReady`.

Each variant carries one occurrence and a compatibility status. Prerequisite
variants also carry the evidence revision that selected them. The compatibility
status exists only to preserve established shell, overlay, and navigation
consumers while those surfaces migrate to typed state.

## Evidence Model

`OnboardingPrerequisiteEvidence` contains:

- process-local revision;
- UTC observation time;
- one complete `OnboardingEnvironmentReport`.

One report supplies FDA, Messages, history plausibility, Contacts, maintenance,
import, and graph facts. Environment Readiness uses this same evidence object
for both Episode selection and Details presentation. It no longer composes an
independent Schedule-completion stream with a report from another time.

Invalidating an in-flight report creates a new provider occurrence. Riverpod
discards completion from the retired occurrence; the stale-result regression
test proves that an older ready result cannot replace a newer FDA blocker.

## Completion Predicates

| Episode | Required proof |
|---|---|
| checking | coherent report observed |
| Messages access | fresh protected-source read succeeds |
| local-history confirmation | sufficient local evidence or explicit acceptance in this Episode |
| Contacts access | current local Contacts source read succeeds |
| ready to import | all current prerequisite predicates pass in one report revision |
| recovery | admitted derived-store reset completes |
| import preparation | admitted preparation stage completes |
| local-data build | source intake and Conversation Graph build complete |
| durable verification | canonical verifier proves populated, coherent derived stores |
| operation failed | retry/recovery intent accepted and subsequent work succeeds |
| ready to start | human selects terminal OK |
| normal application | no first-run Episode owns presentation |

Import action is ignored outside `OnboardingReadyToImport`. Operation
completion cannot skip durable verification. Terminal readiness cannot reveal
the normal sidebar until the human acknowledges it.

## Transition Graph

```text
checking
  -> Messages access
  -> local-history confirmation (when required)
  -> Contacts access (when required)
  -> ready to import
  -> recovery (when partial derived data exists)
  -> import preparation
  -> local-data build
  -> durable verification
  -> ready to start
  -> normal application

operation Episode -> operation failed -> allowed retry boundary
normal application -> reimporting -> reimport ready -> normal application
```

Fresh evidence may legitimately move a prerequisite Episode backward. The
command transition table rejects impossible shortcuts and allows typed failure
edges from active recovery/import states.

## Blocker Priority

Actual dependency order is:

1. admitted maintenance;
2. protected Messages access;
3. local Messages presence/history;
4. required local Contacts data;
5. app-owned import and graph readiness.

The report applies this classification before Journey derivation. Asynchronous
provider completion order does not select the user-visible blocker.

## FDA Semantics

Opening System Settings, focus return, modal dismissal, relaunch, and re-check
are not FDA proof. Re-check requests a new report. Only evidence that the
protected source is readable completes the Episode.

The old “Welcome back” Step progression was removed from production. Returning
without enabling FDA leaves the Journey on the same blocker with a new
occurrence. Enabling FDA and re-checking produces one coherent transition.

## Contacts Semantics

Contacts is required because the current pipeline imports local Contacts
unconditionally. Presentation now says that directly. It no longer suggests
that opening Contacts, inspecting an iPhone, or merely waiting mechanically
resolves the blocker.

## iCloud And Local-History Semantics

MessageLens observes only history stored on the current Mac. It may recommend
checking Messages in iCloud when local history looks sparse, but cannot claim
sync completion. `Use This Local History` is accepted only while the matching
typed Episode is active. The acceptance is process-Journey state, not rewritten
source evidence or a Presence Schedule completion flag.

## Startup And Resume

The app shell consumes the coordinator through `OnboardingGate`, a read-only
compatibility projection. This preserves existing shell status consumers while
ensuring startup reaches one transition authority.

Interrupted operation history is reconciled into environment/operation truth.
The operation snapshot does not navigate. Its result becomes evidence consumed
by the coordinator.

## Start Fresh Integration

Start Fresh remains the preservation-safe mutation owner. It:

1. runs under `ArchiveMutationCoordinator`;
2. deletes only the explicit rebuildable-store allow-list;
3. preserves overlays, Presence history, preferences, logs, archive identity,
   and attachment preservation data;
4. proves virgin installation state;
5. requests fresh prerequisite evaluation.

It does not choose an Onboarding Episode. The coordinator derives the first
truthful Episode from the fresh evidence.

## Presentation Ownership

- Environment Readiness renders prerequisite Episodes.
- `OnboardingOverlay` renders admitted operations, failures, verification, and
  terminal handoff.
- Navigation projects compatibility status into the existing ViewSpec stack.
- Presence may render other Journeys but cannot assign Onboarding state.
- Pipeline incidents cannot replace active first-run Journey content.

## Lifecycle Ownership

Focus and visibility callbacks may request refresh. They cannot mark FDA,
Contacts, history, import, or completion predicates true. Dialog dismissal and
animation completion likewise have no Journey transition authority.

## Stale Occurrence Protection

- prerequisite checks use provider occurrences and evidence revisions;
- operation work uses durable operation identity;
- Start Fresh uses its existing presentation/session occurrence guard;
- a retired async result cannot affect a newer presentation session;
- diagnostics expose occurrence and evidence revision without PII.

## Compatibility Boundary

`OnboardingGate` remains temporarily because many established operational and
presentation tests consume `OnboardingStatus`. It watches coordinator state and
forwards intents to the coordinator. It contains no state assignment.

The required-sources Scheduler providers remain callable only for laboratory
fixtures and historical tests. They are no longer exported through the
Onboarding feature seam or mounted by application composition.

## Verification Coverage

Focused coverage proves:

- FDA re-check without proof cannot advance;
- one report derives one typed Episode;
- Contacts cannot appear until report classification reaches it;
- sparse-history acceptance is Episode-gated;
- import is rejected outside ready-to-import;
- stale prerequisite completion is rejected;
- allowed operation transitions and impossible shortcuts are explicit;
- existing recovery, import, graph, failure, terminal, and sidebar tests remain
  compatible through the read-only Gate projection;
- architecture tripwires prohibit the prerequisite Presence host, independent
  Environment Readiness report composition, and Gate state assignment.

## Verification Results

- focused Journey Coordinator and Environment Readiness tests: 17 passed;
- Onboarding, Environment Readiness, Presence, and Navigation subsystem tests:
  419 passed;
- architecture tripwires: 384 passed;
- complete Flutter suite: 2,085 passed;
- `flutter analyze`: no issues;
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`;
- formatting and `git diff --check`: clean.

## Manual Staging Path

1. Start Fresh in the disposable staging archive.
2. Reach the FDA Episode.
3. Open System Settings.
4. Return without enabling FDA.
5. Confirm the FDA Episode remains.
6. Enable FDA.
7. Choose **Re-check**.
8. Confirm exactly one transition.
9. Complete any local-history and Contacts Episodes.
10. Reach **Everything is ready**.
11. Import.
12. Reach **You’re ready to start**.
13. Choose **OK**.
14. Confirm the normal sidebar opens.

Do not perform this path against production while validating the feature.
