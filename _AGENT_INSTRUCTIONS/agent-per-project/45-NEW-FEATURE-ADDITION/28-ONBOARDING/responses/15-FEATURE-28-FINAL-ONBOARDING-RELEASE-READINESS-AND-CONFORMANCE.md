---
tier: project
scope: onboarding
owner: essentials-onboarding
last_reviewed: 2026-08-27
source_of_truth: feature-conformance-record
---

# Feature 28 Final Onboarding Release Readiness And Conformance

## Release Decision

**READY WITH DEFERRED NON-BLOCKERS.**

Feature 28 has one production Journey authority, one truthful six-node human
path, durable operation evidence, preservation-safe recovery, typed failures,
and a mechanically enforced verification gate. No release blocker was found in
this final pass.

The canonical human Journey is:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

The internal Coordinator state machine is intentionally richer. Durable
verification remains inside Import and is not a seventh human Episode.

## Authority Audit

`OnboardingJourneyCoordinator` is the sole production authority that selects
the active Onboarding Episode.

| Participant | Final responsibility | Not permitted to do |
| --- | --- | --- |
| Environment Readiness | Render the Coordinator's current prerequisite Episode and forward typed intent | Derive or advance the Journey independently |
| `OnboardingGate` | Read-only compatibility projection and forwarding seam | Assign Journey state |
| startup classifier | Admit or block the process before normal application composition | Reclaim presentation after process admission |
| durable operation snapshot | Persist operation identity, stage, progress, proof, failure, and interruption truth | Navigate or select a human Episode |
| `ArchiveMutationCoordinator` | Admit one archive mutation owner and issue its capability | Select Onboarding presentation |
| Start Fresh | Execute the authorized preservation-safe reset and prove virgin state | Choose the next Episode |
| modal, focus, lifecycle, and animation callbacks | Request a fresh observation or finish presentation work | Satisfy FDA, Contacts, import, or completion predicates |
| Journey path | Project the current typed Coordinator state | Inspect databases, operation counters, or timers |

The required-sources Presence Schedule remains available only to laboratory
fixtures and selective maintenance of its preserved run during Start Fresh. It
is not mounted by production application composition and is not a competing
prerequisite authority.

## Prerequisite Episodes

The prerequisite order follows actual dependencies:

1. Messages protected-source access;
2. locally available Messages history and explicit acceptance when evidence is
   sparse;
3. readable local Contacts data while the current import pipeline requires it;
4. one coherent ready-to-import evidence revision;
5. explicit human authorization to import.

Opening System Settings, returning focus, dismissing a dialog, or relaunching
does not prove Full Disk Access. Only a fresh protected-source read can complete
the Messages Episode.

The local-history Episode does not claim to inspect iCloud or another device.
It reports only what is present on this Mac. Contacts remains a truthful
mandatory Episode because the current pipeline consumes Contacts
unconditionally.

## Operation And Liveness

Import is admitted through `ArchiveMutationCoordinator` before source import or
Conversation Graph mutation begins. The durable operation snapshot records:

- operation and process-session identity;
- environment preparation, message-data build, and durable verification
  stages;
- factual import and projection substages;
- bounded real progress observations;
- typed anomaly totals;
- typed failure and recovery disposition;
- completion proof or interrupted state.

Environment Readiness does not open the import or graph stores for unrelated
row counts during admitted maintenance. Presentation ownership is established
and painted before expensive work begins. There are no artificial progress
timers or fabricated completion percentages.

Production-shaped evidence completed a 137,373-message first import in 49.14
seconds with real progress observations and a responsive UI. The absence of a
watchdog is deliberate: execution-opportunity evidence and healthy timing
variance are still insufficient to justify a mechanically truthful stall
threshold.

## Mandatory Internal Verification

The completion order is fixed:

```text
Import work completes
    -> Coordinator enters internal durable verification
    -> canonical verifier proves populated import and graph stores
    -> durable operation completion is recorded
    -> Coordinator constructs Start
    -> human selects OK
    -> normal application presentation is released
```

While `OnboardingVerifyingDurableReadiness` is active:

- the human Journey path remains on Import;
- Start remains future;
- no timer or renderer can satisfy the gate.

If verification fails:

- operation completion is not recorded;
- the Coordinator publishes a typed operation failure;
- the path remains on Import;
- Start is never current or actionable.

Focused tests hold the verifier open and prove Start remains unavailable, then
release a successful proof and observe Start. A separate failing verifier test
proves failure never exposes Start. Architecture tripwires also protect the
ordering `verify -> operation complete -> Start` and prohibit a visible Verify
node.

## Startup, Recovery, And Start Fresh

Startup installation classification is a one-shot process-admission decision.
It distinguishes virgin, resumable, completed, abandoned, and
remediation-required installations from durable evidence. After admission,
later derived-store recreation cannot cause startup to reclaim the window.

Advanced Start Fresh:

1. requires a completed installation and explicit confirmation;
2. publishes a visible operation occurrence before mutation;
3. waits for the presentation frame rather than an arbitrary delay;
4. runs only under the `startFresh` archive-mutation capability;
5. deletes only enumerated rebuildable database base files and SQLite
   sidecars;
6. selectively resets Onboarding failure and operation intent plus the legacy
   required-source run;
7. verifies the resulting virgin installation state;
8. hands the fresh evidence back to the Coordinator;
9. projects typed retryable or non-retryable failure if any boundary fails.

The operation occurrence guard prevents a stale completion or older retry from
altering a newer presentation session.

## Preservation And Database Boundaries

Start Fresh preserves:

- Apple Messages and Contacts sources;
- `attachment_archive/` payloads;
- overlay-authored user intent;
- preferences and customizations;
- Presence definitions and history except the narrowly superseded legacy
  prerequisite run;
- diagnostics and logs;
- archive marker, instance identity, and instance lock;
- Historical Archive source and recovery-donor truth.

Deletion is filename-scoped to the source import, Conversation Graph, and
retired derived database base files plus their `-wal` and `-shm` companions.
The file-store boundary rejects paths. There is no broad archive-root deletion
and no attachment-specific exception to one.

Readiness, installation classification, source import, graph projection, and
overlay intent continue through their canonical database providers and
repositories. Mutation authority and archive-root admission remain distinct.

## Source Fidelity And Anomalies

The completed production-shaped validation reconciled:

- 137,373 source-import messages;
- 137,373 Conversation Graph messages;
- 116,633 conversation-linked messages;
- 20,740 recovered messages;
- zero unaccounted messages;
- exact source/graph relationship parity;
- zero dangling graph endpoints;
- exactly 7 unresolved reaction targets in the completed durable operation
  snapshot.

Structurally valid anomalous records are preserved rather than suppressed.
Optional interpretation may degrade, but required identity, direction, and
relationship truth fail closed when continuing would fabricate or lose graph
facts.

All Apple Messages timestamp normalization remains under
`lib/core/util/date_converter.dart`; no Onboarding-private Apple epoch
conversion was found.

## Presentation, Accessibility, And Handoff

The Journey path has exactly six visible and accessible nodes. It derives only
from `OnboardingJourneyState`, supports truthful backward prerequisite
movement, remains stable through import substages and internal verification,
and honors reduced motion.

Environment Readiness owns prerequisite presentation. `OnboardingOverlay`
owns admitted operation, failure, internal-verification, and terminal handoff
presentation. The normal sidebar remains unavailable until terminal OK, then
the path disappears and focus moves to normal application navigation.

Operation and failure surfaces use semantic labels and live-region behavior.
Primary actions are keyboard reachable, the path has an aggregate semantic
label, and no color alone carries Journey-state meaning.

## Manual Evidence

Manual staging established the following production-shaped path:

- FDA removal and re-grant remained blocked until a fresh readable-source
  observation;
- onboarding progressed smoothly through local-history and Contacts evidence;
- **Everything is ready** exposed one explicit import authorization;
- factual import progress remained responsive;
- the completed anomaly snapshot persisted exactly 7 unresolved reaction
  targets;
- Start Fresh immediately took visible presentation ownership;
- Start Fresh reached a mechanically verified virgin installation and returned
  to Onboarding;
- the final human transition was perceived as Import to Start, as intended;
- terminal OK released the normal application with complete data.

No manual claim is made that Verify appeared as a visible Episode.

## Deferred Non-Blockers

1. A stall watchdog remains deferred until execution-opportunity evidence and
   stage-specific healthy bounds can support a truthful policy.
2. The unmounted required-sources Schedule and unreachable prerequisite
   branches in the operational overlay remain bounded compatibility/laboratory
   cleanup debt. They do not participate in production progression.
3. Typed anomaly totals remain primarily diagnostic; a broader ordinary-user
   anomaly presentation was intentionally outside Feature 28.

These items do not weaken source fidelity, mutation safety, completion proof,
or the usability of the current Onboarding Journey.

## Final Verification

Final verification on 2026-08-27:

- focused Feature 28 and Environment Readiness coverage: 231 tests passed;
- architecture tripwires: 385 tests passed;
- complete Flutter suite: 2,105 tests passed;
- `flutter analyze`: no issues found;
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`;
- no Dart formatting was required in this documentation-only pass;
- `git diff --check`: clean.

Feature 28 may close after those checks remain clean. Future work must preserve
the six-node human topology independently from the internal Coordinator state
machine and must not make Start constructible without durable verification.
