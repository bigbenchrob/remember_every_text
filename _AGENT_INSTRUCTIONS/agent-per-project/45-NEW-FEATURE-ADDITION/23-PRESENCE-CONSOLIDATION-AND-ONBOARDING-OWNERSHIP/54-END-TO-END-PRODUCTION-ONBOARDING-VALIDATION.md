---
tier: project
scope: end-to-end-production-onboarding-validation
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code-and-executed-tests
links:
  - ./18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md
  - ./20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ./29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md
  - ./32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md
  - ./50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md
  - ./52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/onboarding/
  - test/features/environment_readiness/
  - test/essentials/presence/presentation/presence_runner_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# End-To-End Production Onboarding Validation

## Executive Result

The production release composition uses the real Onboarding Gate, authored
Onboarding Schedule, real Onboarding Agents, and generic Presence runner. It
does not route the production Gate into the Presence development harness.

The validation did find and correct one composition blocker: every debug launch
previously bypassed the router and mounted `LinearPresenceExperimentHost`
directly. That made ordinary `flutter run` incapable of exercising the
production-shaped onboarding path. The harness is now explicit opt-in tooling:

```text
ordinary debug or release launch
    -> router
    -> MacosAppShell
    -> OnboardingGate

explicit development harness launch
    flutter run -d macos \
      --dart-define=PRESENCE_DEVELOPMENT_HARNESS=true
    -> LinearPresenceExperimentHost
```

No Presence, Schedule, Gate, database, reset, or onboarding behavior changed.

The realistic automated journeys otherwise pass. One production-path defect
remains: the authored Messages source check has only a Boolean result. Every
false result routes to FDA remediation, including a genuinely missing or
invalid `chat.db`. A person whose source is absent can therefore receive
incorrect permission guidance and remain in the remediation loop. This is the
single earned next correction.

No production archive was used. No destructive GUI journey was run.

## Production Composition

### Release And Ordinary Debug Path

The current composition is:

```text
App
    -> GoRouter
    -> MacosAppShell
    -> watch OnboardingGate
    -> awaitingFda / awaitingUserAction
    -> OnboardingPresenceHost
    -> requiredSourcesReadinessSchedulerProvider
    -> authored Schedule 6
    -> PresenceScheduler
    -> PresenceRunner
```

`MacosAppShell` mounts:

- `OnboardingPresenceHost` for `awaitingFda` and `awaitingUserAction`;
- `OnboardingOverlay` for recovery, preparation failure, import/build,
  completion, and reimport states; and
- the ordinary workspace underneath both blocking surfaces.

`requiredSourcesReadinessSchedulerProvider` is the production composition root.
It installs the real authored Schedule and binds:

- the real Messages source-readiness Agent;
- the real Contacts source-readiness Agent;
- the real Messages-history sufficiency Agent; and
- the real FDA Settings-opening authority.

`OnboardingPresenceHost` supplies the generic `PresenceRunner`. Generic Tell,
Test, fixed-destination, and Choice behavior remains in Presence. The explicit
FDA Settings presentation remains delegated to Onboarding.

### Development Harness Boundary

The development harness remains under
`features/presence_iteration_simple/`. It owns diagnostics, substitutions,
Schedule maps, traces, Mermaid output, and repeat-run controls. It consumes
Presence and selected Onboarding abstractions; neither permanent subsystem
imports it.

Before this pass, `main.dart` selected that host for every debug build through
an unconditional `kDebugMode` branch. Release composition was correct, but the
normal development application was not production-shaped. The corrected
switch requires both debug mode and the explicit
`PRESENCE_DEVELOPMENT_HARNESS` compile-time flag.

No Environment Readiness simulation or developer-mode control can otherwise
replace `OnboardingPresenceHost` with the harness.

## Actual Production Journey

### Launch And Admission

```text
launch
    -> archive admission and environment evaluation
    -> populated, ready derived stores
        -> notNeeded
        -> normal application
    -> incomplete derived browsing data eligible for recovery
        -> request automatic-recovery mutation authority
    -> source/readiness work required
        -> awaitingFda or awaitingUserAction
        -> production Onboarding Presence flow
```

The Gate owns operational admission, recovery, reset, import, graph build,
completion, and reimport. It does not own the authored human readiness journey.

### Authored Readiness Schedule

```text
welcome
    -> explain source check
    -> test Messages readability
        -> true: test Contacts readability
        -> false: explain FDA and open System Settings
            -> restart/resume at verification Trip, Step 1
            -> fresh Messages readability test
    -> Contacts readable?
        -> false: Contacts guidance, then fixed route back to fresh test
        -> true: test Messages-history sufficiency
    -> history sufficient?
        -> true: combined source confirmation
        -> false: sparse-history guidance and ChoiceStep
            -> Re-check: fresh history test
            -> Import Anyway: combined source confirmation
    -> Schedule complete
```

Completion of this Schedule is the durable accepted-readiness fact. Presence
does not start import.

### Import And Build Handoff

Environment Readiness composes the current environment report with durable
Schedule completion. It exposes **Import My Messages** when current facts and
accepted readiness permit it.

```text
Import My Messages
    -> OnboardingGate.startImportAndGraphBuild()
    -> request onboardingImport mutation authority
    -> fresh FDA guard
    -> importing / Preparing setup...
    -> reset only allow-listed rebuildable derived stores
    -> buildingGraph
    -> Conversation Graph controller build
    -> complete
    -> MessageLens is ready
    -> Get Started
    -> normal application
```

### Failure And Recovery Branches

- **Automatic recovery:** incomplete derived stores request mutation authority.
  Busy denial waits silently for release and fresh environment truth. Admission
  shows recovery, resets the allow-list, then returns to ordinary readiness. It
  does not automatically rerun setup.
- **Preparation/reset failure:** the current process enters
  `preparationFailed`, shows the calm retry/support surface, and **Try Again**
  starts a fresh ordinary attempt. Restart discards this process-local fact.
- **Controller/build failure:** the existing persisted controller failure is
  recorded, the Gate returns to `awaitingUserAction`, and the stable retry and
  support surface remains distinct from `preparationFailed`.
- **Existing ready environment:** current populated-store truth wins; neither
  Presence nor recovery is shown.

## Validation Evidence

### Code/Test Verified

The pass executed:

```text
flutter test test/essentials/onboarding
flutter test test/features/environment_readiness \
  test/essentials/presence/presentation/presence_runner_test.dart
flutter test test/architecture/forbidden_imports_test.dart
flutter test
flutter analyze
flutter build macos --debug
```

Results:

- all focused suites passed;
- the complete Flutter suite passed: 1,709 tests;
- analyzer reported no issues;
- the architecture tripwires passed;
- `MessageLens Development.app` built successfully; and
- the new opt-in harness composition tripwire passed.

The macOS build emitted only the existing Xcode build-version messages and the
existing `volume_controller` privacy-manifest processing warning.

### Manual Evidence Available From Earlier Work

The earlier FDA experiment manually demonstrated:

```text
unreadable source
    -> FDA guidance
    -> System Settings
    -> grant FDA
    -> restart
    -> verification Trip resumes at Step 1
    -> fresh test succeeds
```

That evidence remains relevant, but it was not rerun during this pass and is
not presented as a fresh visual observation.

### Manual Visual Validation Still Required

This pass did not launch a destructive or state-changing GUI journey against
the production archive. It also did not claim to observe animation, flashes,
spinner timing, overlay competition, or reading order from automated tests.

A fresh disposable/development-root manual pass is still needed to visually
observe the complete normal import/build journey, automatic recovery, both
failure surfaces, and the selected relaunch boundaries in one production-
shaped application run.

## Journey Table

| Journey | Result | Human state/action | Durable authority | Finding |
| --- | --- | --- | --- | --- |
| Already ready | Code/test verified | Normal application; no onboarding obstruction | Populated source-scoped import and Conversation Graph stores | No defect |
| Fresh normal onboarding | Cross-seam code/test verified | Tell sequence, confirmation, then **Import My Messages** | Environment facts plus completed Schedule run | Manual full-flow observation remains |
| FDA unavailable/restored | Automated and earlier manually observed | Guidance, System Settings, restart, fresh verification | Current source-readability probe plus persisted Trip checkpoint | Production copy says `MessageLens Development`; P2 copy defect |
| Messages source absent/invalid | Deterministically reproduced by false source probe and configured route | FDA remediation repeats although permission may not be the cause | Boolean source-readiness result | P1 observed production defect |
| Contacts unavailable | Automated | Contacts guidance, then fresh re-check | Current Contacts Agent result plus Trip checkpoint | No defect |
| Sparse -> Re-check | Automated in Schedule and production host | Human selects **Re-check**; a fresh history fact is evaluated | Persisted Choice route and Trip checkpoint | No defect |
| Sparse -> Import Anyway | Automated in Schedule, production host, and durable handoff | Human knowingly continues; existing import action appears | Completed canonical Schedule run | No defect |
| Import/build success | Gate and presentation seams verified | **Preparing setup...**, build progress, readiness handoff | Populated durable derived stores | Full visual sequence still required |
| Preparation failure/retry | Automated | Calm retry/support surface; **Try Again** starts fresh attempt | Process-local Gate outcome only | No defect |
| Controller failure/retry | Automated | Stable phase-neutral failure and existing retry/support actions | Persisted controller failure evidence | No defect |
| Automatic recovery | Automated, including busy deferral | Calm non-interactive recovery only after admission | Fresh environment truth and mutation authority | No defect |
| Relaunch before import | Automated through Schedule/provider reconstruction | Accepted or in-progress readiness returns from checkpoint | Presence run checkpoint | No defect |
| Relaunch after sparse acceptance | Automated | Import remains available | Completed Schedule run | No defect |
| Relaunch after successful build before Get Started | Code-derived, not one visual run | Normal readiness follows populated stores; handoff click is not authority | Populated derived stores | Manual confirmation remains |
| Relaunch after preparation failure | Automated | Process-local failure disappears; current environment is re-evaluated | Environment/filesystem probes | No defect |

## Attachment Preservation

The preservation invariant passed mechanically.

```text
AUTHORITATIVE EXTERNAL SOURCES — NEVER OUR DELETION TARGET
    Apple Messages chat.db
    Apple Contacts databases
    locally available Messages attachment payloads

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores
    indexes and projections

MESSAGELENS PRESERVATION DATA — TREAT LIKE GOLD
    archived attachment payloads
```

Reset/recovery tests use temporary roots and prove that only enumerated derived
database files and sidecars are removed. Archived payloads and durable stores
remain. Architecture tripwires continue to reject broad deletion and archive-
path authority in the reset implementation.

No tested reset or recovery path can reach archived attachment payloads.

## Human Reading Order And Transitions

Widget tests verify the settled ordinary text and controls:

- active work gives truthful keep-open guidance;
- completion says **MessageLens is ready** and keeps metrics out of ordinary
  reading order;
- preparation failure and persisted controller failure use calm primary copy;
- automatic recovery is non-interactive and appears only after admission;
- sparse-history labels are human-facing while values remain opaque; and
- stable support evidence remains outside primary reading order.

No automated test demonstrated stale content, competing overlays, a spinner
surviving terminal state, or an action becoming available before its authority.
Visual timing and transition polish remain unobserved rather than presumed
correct.

## Findings

### A. Observed Production Defects

#### P1 — Missing or invalid Messages source is routed as FDA failure

`MessagesSourceReadinessTestAgent` returns one Boolean from
`canReadMessagesDatabase()`. The authored Schedule routes every false result to
the FDA remediation Trip. Tests prove both that an invalid SQLite source
returns false and that false follows the remediation loop.

FDA is only one possible reason for false. If `chat.db` is genuinely absent,
unavailable because local history has not been established, or invalid, the
person receives permission guidance that cannot resolve the underlying fact.
The verification test remains false and the route returns to the same guidance.

This is a real reachable production route, not a speculative race. It is not
corrected here because distinguishing source absence from permission denial is
not a tiny wiring fix and the prompt explicitly excludes FDA redesign.

#### P2 — FDA Tell copy names the development app in production

The real authored Schedule says:

> In Full Disk Access, add or enable MessageLens Development.

The same Schedule is installed by production composition. The instruction is
therefore wrong for a shipped `MessageLens` application. This is bounded copy
debt and should be corrected with the P1 readiness distinction rather than
treated as a separate architecture project.

#### P2 — Debug composition substituted the harness (corrected)

Every debug launch previously mounted the development harness instead of the
router. The release path itself was not affected. This pass made the harness
explicit opt-in and added a tripwire, allowing ordinary debug execution to
exercise the production-shaped Gate and host.

### B. Observed Polish Issues

None established by visual observation during this pass.

### C. Known Architectural Debt, Not Exercised

- Audit 53's user-initiated mutation-busy feedback gap remains documented but
  was not exercised. It did not earn implementation here.
- FDA/source readability remains a coarse Boolean contract; the demonstrated
  missing-source route is the concrete defect, while additional reason
  taxonomy remains undesigned.
- The development harness remains compiled into debug builds, but it is now
  unreachable unless explicitly requested.

### D. Theoretical Edge Cases

- further mutation-owner timing permutations beyond the deterministic Slice 52
  coverage;
- abrupt termination at every individual Step rather than the selected human-
  meaningful boundaries; and
- hypothetical future reset targets not present in the current allow-list.

These are not implementation tasks.

## Production-Readiness Answers

**Can a new user get through onboarding?**

Not fully demonstrated. The sufficient-source and FDA-restored paths are
supported by automated and earlier manual evidence, but a missing/invalid
Messages source can strand the user in misleading FDA remediation, and the
complete current production-shaped GUI flow was not rerun in this pass.

**Does the Gate point to the real production onboarding flow?**

Yes. Release and ordinary debug composition now reach `MacosAppShell`,
`OnboardingGate`, `OnboardingPresenceHost`, and the authored Schedule. The
harness is explicit opt-in only.

**Can the user understand what MessageLens is doing during long work?**

Yes by code/test evidence for current copy and controls; visual transition
timing still requires manual observation.

**Can the user recover from the realistic failures exercised?**

Yes for FDA restoration, Contacts retry, sparse re-check, preparation failure,
controller failure, and automatic recovery. No for a genuinely absent or
invalid Messages source, which currently receives the wrong remediation.

**Are archived attachment payloads protected throughout?**

Yes. Temporary-root preservation tests and architecture tripwires passed.

**Did validation reveal any P0/P1/P2 defect requiring immediate work?**

Yes:

1. P1: distinguish a missing/invalid Messages source from FDA denial so the
   authored workflow cannot loop on incorrect remediation.
2. P2: remove the production-inaccurate `MessageLens Development` instruction.
3. P2 corrected during validation: make the development harness explicit
   opt-in instead of the debug default.

## One Earned Next Implementation Task

Implement one bounded source-readiness remediation correction:

> Preserve the existing real source probes, but prevent an absent or invalid
> Messages source from being represented as FDA denial. Route the person to
> truthful Messages-source guidance, while retaining the existing FDA route
> for actual permission failure. In the same bounded slice, make the FDA app
> name correct for the active application identity.

The next task must begin by determining the smallest truthful result contract
supported by current probes. It must not invent a general failure taxonomy,
new Presence grammar, or speculative recovery system.

No other implementation slice is currently earned. Continue manual
production-shaped validation after that correction.
