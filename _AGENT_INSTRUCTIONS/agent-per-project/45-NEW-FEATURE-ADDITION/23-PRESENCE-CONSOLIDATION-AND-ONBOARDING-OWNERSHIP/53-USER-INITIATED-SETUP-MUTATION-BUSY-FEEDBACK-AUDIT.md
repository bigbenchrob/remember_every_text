---
tier: project
scope: user-initiated-setup-mutation-busy-feedback
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - ./41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md
  - ./50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md
  - ./51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md
  - ./52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md
tests:
  - test/essentials/onboarding/application/onboarding_gate_provider_test.dart
  - test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart
---

# User-Initiated Setup Mutation-Busy Feedback Audit

## Executive Answer

When a person presses **Import My Messages** while another operation owns
archive mutation authority, setup does not start. The coordinator rejects the
request before the supplied action runs. No FDA check, reset, import, graph
build, progress state, or file mutation occurs on behalf of that click.

Current code leaves the Gate and readiness state unchanged but lets
`ArchiveMutationDeniedException` escape through an unobserved UI Future. The
person receives no meaningful feedback and may interpret the click as broken.

The smallest truthful correction is:

> Translate ordinary mutation denial into a narrow Onboarding start outcome,
> leave the underlying readiness or prior-failure state intact, and have the
> active presentation show one transient, phase-neutral acknowledgement. Do
> not retain or replay the denied command.

The recommended message concept is:

```text
MessageLens is busy with another task, so setup didn't start. Please try again.
```

No new `OnboardingStatus`, persistent state, timer, queue, owner-label
translation, proactive button disabling, or Presence behavior is justified.

## 1. Exact Production Initiation Paths

### Environment Readiness

The ordinary initial-setup route is:

```text
EnvironmentReadinessPanelView
    -> startImport button onPressed
    -> EnvironmentReadinessActions.startImportAndGraphBuild()
    -> OnboardingGate.startImportAndGraphBuild()
    -> ArchiveMutationCoordinator.run(onboardingImport)
```

The button callback is synchronous and discards the returned `Future`. The
action provider awaits the Gate but catches nothing and publishes no action
state. If mutation admission is denied, the exception escapes asynchronously.
No readiness presentation observes or translates it.

The result is:

- the Gate remains `awaitingUserAction`;
- the Environment Readiness panel remains on its current detail;
- no progress presentation appears;
- no reset or controller call occurs; and
- the person sees an apparent no-op.

### Blocking Onboarding overlay

The production blocking overlay supplies **Try Again** while the Gate is in
`preparationFailed`:

```text
OnboardingOverlay._WelcomeContent
    -> async FilledButton callback
    -> OnboardingOverlayActions.startImportAndGraphBuild()
    -> OnboardingGate.startImportAndGraphBuild()
    -> ArchiveMutationCoordinator.run(onboardingImport)
```

The callback awaits the action provider, but Flutter's button machinery does
not await the callback's returned Future and there is no local catch. Ordinary
denial therefore still reaches asynchronous framework/zone error reporting,
not human feedback. The existing `preparationFailed` surface remains visible;
no recovery or import progress replaces it.

`OnboardingOverlay` also retains legacy `awaitingUserAction` branches for
**Import My Messages** and **Import Anyway**. The current app shell does not
mount the overlay for `awaitingUserAction`; it mounts the required-sources
Presence host, which disappears after Schedule completion, while Navigation
keeps the Environment Readiness panel available. These legacy callbacks have
the same exception behavior but are not the ordinary current production
entry.

The Presence Schedule does not start import. It establishes source-readiness
acceptance and then releases its blocking surface. The explicit import command
belongs to Environment Readiness or the process-local failure overlay.

## 2. Busy-Denial Truth

`ArchiveMutationCoordinator.run()` calls `_tryAcquire()` before invoking the
supplied action. If another owner is active, `_tryAcquire()` records denial
diagnostics and returns false; `run()` immediately throws
`ArchiveMutationDeniedException`.

For the denied setup request:

```text
action called                 NO
FDA guard evaluated           NO
reset started                 NO
controller started            NO
Gate workflow status changed  NO
files changed by this click   NO
command retained              NO
```

This differs mechanically from:

| Condition | Truth | Existing projection |
| --- | --- | --- |
| User-initiated busy denial | Explicit command was not admitted and nothing started | Missing transient feedback |
| Preparation failure | Admitted preparation or exceptional admission failed | `preparationFailed` |
| FDA block | Admitted setup found its source prerequisite unavailable | `awaitingFda` |
| Controller failure | Build began and failed inside the controller boundary | Existing persisted failure path |

Busy denial must not enter `preparationFailed`: **MessageLens couldn't finish
setup** is false when setup never began.

## 3. Human Command Versus Automatic Intent

Slice 52 correctly gives automatic recovery this behavior:

```text
busy
    -> defer
    -> observe release
    -> obtain fresh environment truth
    -> reconsider whether automatic work remains warranted
```

That mechanism does not transfer to **Import My Messages**.

Automatic recovery expresses a standing system policy: current truth may
justify trying again after relevant facts change. A button press is an event at
one moment. Denial means that event had no operational effect. Retaining the
click and executing it later would convert an explicit command into a queued
command without the person's knowledge.

No current interaction promises queueing, and mutation release does not prove
that the person's intention is still current. The environment, FDA, visible
screen, or their own decision may have changed meanwhile.

**Verdict:** retaining or replaying a denied **Import My Messages** command is
not justified. A later attempt must come from another explicit click.

## 4. Realistic Competing Owners

The coordinator is process-global. Any current operation can mechanically deny
setup. The most plausible production overlaps are:

| Operation family | Example owner labels | Visibility and duration | Natural readiness effect |
| --- | --- | --- | --- |
| Live graph update and account reconciliation | `chat-db-change-monitor` | Background; ordinarily short but source work may be perceptible | May update existing derived data; does not promise initial-setup admission |
| Attachment reconciliation and archival | `attachment-live-source-range`, `attachment-graph-sweep-*`, `attachment-archive-all` | Background or Settings initiated; some sweeps can be long | Does not inherently make setup readiness change |
| Deterministic attachment recovery | `deterministic-attachment-recovery` | Background recovery; potentially long | Attachment truth changes, not necessarily setup readiness |
| Historical archive import or removal | `historical-archives-import`, historical testing/removal owner | Visible Settings workflow; potentially long | May rebuild graph data and could alter later environment facts |
| Explicit message-data reset or destructive maintenance | `message-data-reset` and maintenance owners | Usually a visible maintenance workflow; potentially disruptive/long | May make a later readiness report materially different |
| Graph build, setup, reimport, or automatic recovery | caller-supplied graph owner, `onboarding-first-run`, `settings-reimport`, `onboarding-automatic-recovery` | Usually represented by blocking progress when owned by this Gate; another entry point or race can still hold authority | Completion may change Gate/environment presentation |
| Attachment clearing | `attachment-archive-clear` | Explicit specialist operation | Does not define initial-setup readiness |

Some combinations are unlikely in a clean first launch because their normal UI
is unavailable or blocked. They remain mechanically possible during retries,
recovery, development, or a state transition. The feedback should therefore
describe only the universal fact: another task prevented setup from starting.

## 5. Proactive Button Disabling

The coordinator already exposes `ArchiveMutationCoordinatorState.isLocked`, so
a presentation could technically watch it and disable the import button.
Environment Readiness does not currently depend on that provider.

Disabling is not recommended for this slice:

- an unexplained disabled primary action gives less information than an
  enabled action with precise denial feedback;
- exposing coordinator lock state would couple readiness presentation to
  mutation machinery that does not otherwise define its ViewModel;
- owner identity and nested ownership do not belong in button policy;
- the lock may release independently while the person is reading; and
- rendering an enabled button can never prevent another owner acquiring the
  lock before admission.

A race-safe denial path is mandatory regardless. Given the expected rarity of
contention, handling actual denial is the smaller and clearer design.

## 6. Feedback Philosophy Comparison

| Model | Truthfulness | Human clarity | Architecture | Verdict |
| --- | --- | --- | --- | --- |
| Silent no-op | Does not lie, but omits the command outcome | Poor; looks broken | Small but incomplete | Reject |
| Stable setup-failure surface | Claims setup failed after beginning | False and conflates Slice 50 | Reuses the wrong state | Reject |
| Transient busy acknowledgement | Says the command did not start and asks for a new choice | Clear and proportionate | Command-result presentation only | Recommend |
| Disable while known busy plus fallback | Can reduce clicks but still needs fallback | Disabled reason requires more UI | Adds coordinator coupling without eliminating races | Defer/reject for this slice |
| Automatic retry on release | Executes an old click later | Surprising | Creates pending work and replay semantics | Reject |

## 7. Feedback Duration And State

Contention is a transient command outcome, not durable workflow state. The
person does not need to resolve an error, navigate elsewhere, restart, or make
a choice inside a modal. They need to know that this click did not start setup
and that another explicit attempt is required.

The best current form is the application's ordinary transient `SnackBar`:

- it does not replace the truthful readiness or prior-failure surface;
- it survives long enough to acknowledge the click without becoming a task;
- it requires no explicit dismissal;
- it does not interrupt the legitimate operation holding authority; and
- it naturally disappears if the presentation is disposed.

Use the standard snackbar duration. Do not add an Onboarding timer or a stable
Gate status. A modal alert, inline persistent message, or temporary button
state would give contention too much workflow weight.

## 8. Existing Feedback Conventions

Two directly relevant precedents already exist:

1. `EnvironmentReadinessPanelView` uses `ScaffoldMessenger` and `SnackBar` for
   the result of **Send Report To Developer**.
2. `OnboardingOverlay` uses the same mechanism for the same transient command
   result.

This establishes a presentation-local transient acknowledgement on both
surfaces without adding application workflow state.

Historical Archives also models coordinator availability proactively and
records **Execution Gate Busy** in its workflow activity log. That is a dense,
specialist Settings workflow where execution-gate state is itself part of the
visible operational model. It exposes owner-derived detail such as which
operation has authority. That precedent is intentionally not reused for calm
initial setup.

`ChatDbChangeMonitor` silently handles mutation denial and observes release for
background work. It resembles automatic recovery, not an explicit human
command, and therefore does not establish the interaction rule here.

No project-wide busy-notification framework is warranted.

## 9. Coordinator Owner Labels

Current labels include implementation-facing strings such as:

```text
attachment-graph-sweep-chunk
chat-db-change-monitor
message-data-reset
historical-archives-import
```

They are diagnostics, not stable product vocabulary. Specificity would not
change the person's action: setup did not start and they may try again.

**Verdict:** do not expose owner labels and do not create a translation
taxonomy. Use phase-neutral **another task** wording.

## 10. Race Behavior

### Lock begins after rendering

The enabled button may race with a new owner. Actual admission denial must
produce the transient acknowledgement. This is why proactive disabling cannot
be the correctness boundary.

### Owner releases immediately after denial

The message describes the denial event, not an indefinite current state. It
does not promise a duration. An immediate second click may succeed.

### Another owner wins after release

A second explicit click may be denied and may show the same acknowledgement.
No fairness or replay promise exists.

### Presentation is disposed

The callback must check `context.mounted` before projecting feedback. A disposed
surface must not route a snackbar into unrelated UI. The denied command itself
has already ended and requires no cleanup.

### Environment changes while busy

The Gate must not invalidate readiness because of denial. A later explicit
click enters the ordinary Gate method, including its current status guard,
fresh coordinator admission, and current FDA check. No readiness snapshot or
callback is retained.

## 11. Retry And Environment Semantics

After denial:

```text
show transient acknowledgement
    -> retain no command
    -> leave readiness/failure presentation intact
    -> human may press again
    -> ordinary Gate entry point runs from current state
```

For Environment Readiness, the underlying state remains `readyToImport` (or
the current retry projection) because the denied request changed nothing.

For the blocking `preparationFailed` overlay, the prior admitted failure remains
the current process truth. A denied retry does not erase or replace it.

No environment invalidation is needed merely to manufacture visible change.
If the competing operation independently changes environment facts, its own
existing publication/invalidation seams remain authoritative.

## 12. Panel And Overlay Comparison

Both surfaces already cross a dedicated action boundary:

```text
Environment Readiness
    -> EnvironmentReadinessActions

Onboarding overlay
    -> OnboardingOverlayActions
```

Both then call the same Gate method. The semantic translation should therefore
occur once at the Onboarding orchestration boundary, not by making each widget
catch `ArchiveMutationDeniedException`.

Each presentation still owns projecting the returned semantic outcome through
its local `ScaffoldMessenger`. This is the same separation already used for
diagnostic-report results: application code reports what happened;
presentation decides how to say it.

The dormant `awaitingUserAction` overlay branches can consume the same outcome
if retained, but they do not justify a separate implementation.

## 13. Exception And API Ownership

An ordinary widget should not understand `ArchiveMutationCoordinator`, owner
labels, or `ArchiveMutationDeniedException`.

`OnboardingGate` already owns the coordinator call and can distinguish:

- a disallowed Gate state;
- ordinary busy denial;
- successful admission; and
- every other exception.

A small typed outcome is therefore earned. A truthful conceptual contract is:

```text
StartSetupOutcome.admitted
StartSetupOutcome.busy
StartSetupOutcome.notApplicable
```

Three values are preferable to the tempting two-case `started/busy` model.
The current Gate deliberately ignores calls outside `awaitingUserAction` and
`preparationFailed`; calling that result `started` would be false. The third
case preserves the existing duplicate/stale-callback guard without turning it
into an error.

The Gate should catch only ordinary `ArchiveMutationDeniedException` and return
`busy`. Other admission exceptions must keep their established behavior; this
slice must not silently classify them as contention. Once admitted, the result
is `admitted` regardless of whether later specialist logic reaches an existing
handled FDA, preparation-failure, controller-failure, or completion state.

The two action providers relay the Onboarding-owned outcome. Presentation
checks only for `busy`; it does not import coordinator types. No large result
hierarchy, provider-held action state, or general command framework is needed.

## 14. Failure And FDA Separation

The following behavior remains unchanged:

```text
ordinary busy denial
    -> StartSetupOutcome.busy
    -> transient acknowledgement

exceptional non-contention admission error
    -> existing error behavior

admitted preparation error
    -> preparationFailed

admitted FDA false
    -> awaitingFda

controller failure
    -> existing persisted failure path
```

Busy feedback must not mention permissions, reset, import failure, or support.
The cached-FDA concern is unrelated and remains untouched.

## 15. Attachment-Preservation Verification

Busy denial executes no action and performs no file work. The recommendation
changes only how that fact reaches the person.

It does not alter:

- the reset filename allow-list;
- source databases or locally available attachment payloads;
- archived attachment payloads;
- overlay/user-intent storage;
- mutation admission policy; or
- any eventual manually retried setup path.

The attachment-preservation invariant remains mechanically unchanged.

## 16. Human Truth Budget

### We may truthfully say

- MessageLens was busy with another task at admission time.
- This setup request did not start.
- The person may explicitly try again.

### We must not imply

- setup or preparation failed;
- reset began or failed;
- data changed;
- the request is queued;
- setup will begin automatically;
- the person must restart MessageLens;
- the competing operation is erroneous; or
- MessageLens knows how long contention will last.

Recommended copy concept:

```text
MessageLens is busy with another task, so setup didn't start. Please try again.
```

This avoids unsupported **in a moment** or **when it finishes** timing claims.

## 17. Ownership Verdict

```text
ArchiveMutationCoordinator
    owns exclusive mutation admission and diagnostic denial facts

OnboardingGate
    owns setup orchestration and translates ordinary denial into
    an Onboarding start outcome

EnvironmentReadinessActions / OnboardingOverlayActions
    relay the semantic outcome across their existing presentation boundaries

Environment Readiness / Onboarding overlay presentation
    owns transient human wording and mounted-context projection
```

The coordinator must not produce Onboarding copy. The Gate must not display a
snackbar. Presentation must not import mutation-coordinator exceptions.

Presence has no role. This is an Onboarding command attempting to acquire
archive mutation authority after Presence has already established readiness.

## 18. Eventual Test Strategy

The bounded implementation should add tests proving:

1. With the coordinator locked, an explicit setup request returns `busy`,
   performs zero reset/controller work, and never reaches
   `preparationFailed`.
2. Environment Readiness shows the recommended transient acknowledgement.
3. The process-local failure overlay shows the same acknowledgement for a
   denied **Try Again** attempt while preserving the prior failure surface.
4. Releasing the coordinator starts no setup automatically.
5. A second explicit attempt after release is admitted exactly once and follows
   the ordinary lifecycle.
6. Acquisition after the button rendered but before admission still returns
   `busy`.
7. Disposed presentation projects no orphan feedback.
8. `notApplicable` performs no work and displays no busy feedback.
9. Non-contention admission errors retain their current classification.
10. Admitted FDA false still reaches `awaitingFda`.
11. Controller failure still uses the existing persisted failure path.
12. A new provider container reconstructs no busy outcome or pending command.

The existing coordinator suite remains authority for exclusivity and denial
metadata. No coordinator behavior needs to change.

## 19. Other Explicit Mutation Actions

Settings reset, reimport, Historical Archives, and attachment operations can
also encounter contention. Historical Archives already has its own specialist
busy model. This audit does not standardize them.

The narrow Onboarding outcome may later inform another audit, but no generic
operation-busy framework is justified by this initial-setup correction.

## 20. Exactly One Next Implementation Slice

```text
Next concern:
    User-initiated initial setup has no truthful mutation-busy acknowledgement.

Why it comes next:
    Automatic recovery contention is now mechanically correct, while the
    explicit human command still appears to do nothing and leaks an expected
    coordinator exception through UI callbacks.

Current defect:
    ArchiveMutationDeniedException escapes Future<void>; setup does not start,
    Gate/readiness state stays correct, and the person receives no feedback.

Smallest implementation:
    Add one small Onboarding-owned start outcome with admitted, busy, and
    notApplicable cases. Translate only ArchiveMutationDeniedException in the
    Gate. Relay the outcome through both existing action providers. On busy,
    show one standard snackbar with the recommended phase-neutral copy.

Owner:
    Onboarding owns outcome translation; each active presentation owns
    transient projection.

Gate/API changes:
    Change startImportAndGraphBuild() from Future<void> to the narrow typed
    outcome. Preserve current state guard and all non-contention behavior.

Presentation changes:
    Environment Readiness and the blocking failure overlay inspect the outcome,
    check mounted context, and show the same busy acknowledgement. No layout or
    stable copy changes.

New state required:
    No Gate status or provider-held state. The result is one returned command
    outcome only.

Persistence impact:
    None.

Automatic replay:
    None. Release alone does nothing.

Coordinator changes:
    None.

Reset impact:
    None. Denied requests still never enter reset; admitted requests use the
    unchanged service.

Attachment-preservation impact:
    None.

Race handling:
    Actual admission remains authoritative. A race-time denial returns busy;
    a later click performs a fresh ordinary attempt.

Test seam:
    Gate result tests plus focused Environment Readiness and overlay widget
    tests using the existing coordinator and fake reset/controller services.
```

## Completion

When the user presses **Import My Messages** while mutation authority is busy,
MessageLens should **briefly explain that it is busy and setup did not start**.
The denied command should **be discarded**. The underlying readiness or prior-
failure state should **remain unchanged**. Retry should occur only when **the
person explicitly invokes the ordinary setup action again**.
