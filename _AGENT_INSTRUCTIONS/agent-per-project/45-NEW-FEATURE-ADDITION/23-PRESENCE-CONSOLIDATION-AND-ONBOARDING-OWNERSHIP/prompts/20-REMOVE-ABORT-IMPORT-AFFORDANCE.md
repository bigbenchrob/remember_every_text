Yes — and the audit confirms your instinct about **Abort** was exactly right.

It isn’t merely a bad UX label. It is mechanically false. The button does not signal cancellation, does not stop the controller, does not interrupt the orchestrator, and does not wait for a safe boundary. Its fallback reset is normally refused because the active build still owns mutation authority. 21\-INITIAL\-IMPORT\-GRAPH\-BUILD\-LIFECYCLE\-AUDIT.md

So if the user “aborts halfway through,” the truthful answer today is:

```text
the build keeps running
```

and the attempted cleanup is usually denied. That is much worse than simply having no Abort button.

The audit’s recommendation is therefore very strong:

> **Remove the Abort Import affordance and do not replace it with another stop/cleanup command until real cancellation semantics exist.** 21\-INITIAL\-IMPORT\-GRAPH\-BUILD\-LIFECYCLE\-AUDIT.md

It also gives us a useful positive result: we already have enough operational truth for the calm progress experience you wanted. The app can truthfully show an indeterminate “Preparing MessageLens / Building local browsing data” state, ask the user to keep the app open, and show success or retry afterward. What it cannot truthfully show yet is live stage names, percentage complete, time remaining, resume, or safe cancellation. 21\-INITIAL\-IMPORT\-GRAPH\-BUILD\-LIFECYCLE\-AUDIT.md

So I’d make the next Codex slice deliberately tiny:

Implement the single next slice recommended by:

`21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`

The goal is:

> Remove the misleading `Abort Import` affordance from the initial import / graph-build progress experience.

Do not replace it with another stop, cancel, cleanup, or retry control.

Do not change the operation lifecycle.

Do not add cancellation.

Do not change Presence.

Do not change persistence.

---

## 1. Governing reason

The current operation is non-cancellable.

`Abort Import` currently:

```text
OnboardingOverlayActions.abortImport()
    -> OnboardingGate.abortImport()
    -> MessageDataResetService.resetDerivedData()
```

but while the build is active:

- it does not signal the controller;
- it does not interrupt the orchestrator;
- it does not wait for a safe stage boundary;
- its reset request is normally denied by the active mutation owner;
- the active build continues.

Therefore the control offers a capability that does not exist.

Remove that false promise.

---

## 2. Remove the visible Abort control

Find the production progress presentation used during:

```text
OnboardingStatus.importing
OnboardingStatus.buildingGraph
```

Remove the `Abort Import` affordance.

Do not replace it with:

```text
Cancel
Stop
Quit Setup
Clean Up
Return
Try Later
```

None of those semantics has been proven.

The progress experience should remain explicitly non-cancellable.

---

## 3. Remove presentation-only dead plumbing

Trace the narrow action path used only by the removed control.

Likely candidates include:

```text
OnboardingOverlayActions.abortImport()
OnboardingGate.abortImport()
```

Remove only code that is now provably unused because the UI no longer exposes Abort.

Before deleting `OnboardingGate.abortImport()`, search for all callers.

If any non-presentation production path still uses it, preserve it and document why.

Do not perform broad cleanup.

---

## 4. Preserve the active operation

Do not alter:

- `ArchiveMutationCoordinator`;
- `MessageDataResetService`;
- `ConversationGraphBuildController`;
- `ConversationGraphBuildOrchestrator`;
- source import;
- graph projection;
- failure persistence;
- automatic recovery;
- restart behavior.

This is presentation truthfulness only.

---

## 5. Preserve progress presentation

Keep the current truthful coarse progress experience:

```text
Preparing setup...
Building browsing data...
```

or the exact current production wording.

Do not redesign copy in this slice unless removing the Abort control causes a tiny layout issue.

Do not add:

- stage names;
- percentage;
- elapsed time;
- remaining time;
- cancel messaging;
- resume messaging.

---

## 6. Preserve failure/retry behavior

If the build fails, the existing failure/recovery path remains unchanged.

Do not move retry into the active progress screen.

Do not add a button that appears to stop work and later retry.

Retry still happens only after the operation has actually failed or startup has reconciled partial state.

---

## 7. Tests

Add/update focused presentation tests proving:

### First-run active build

During active first-run progress:

```text
Abort Import
```

is absent.

### Reimport active build

If the same progress surface is reused during reimport, prove Abort is absent there too.

### Build continues normally

Removing the UI control does not change controller execution.

### Failure path unchanged

Caught build failure still reaches the existing retry/recovery presentation.

### Success path unchanged

Successful build still reaches completion.

### No replacement false control

Do not introduce another cancel/stop affordance.

---

## 8. Architecture cleanup

If the removed action path becomes dead code, remove it cleanly.

Do not leave:

```text
abortImport()
```

as a compatibility shim unless there is a real remaining caller.

Prefer deletion over dormant misleading API.

If a lower-level reset API remains used elsewhere for legitimate recovery, keep it.

The distinction is:

```text
remove fake cancellation API

preserve real reset/recovery API
```

---

## 9. Documentation

Create:

`22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md`

Record:

1. exact control removed;
2. why it was mechanically false;
3. whether `abortImport()` plumbing was deleted or retained;
4. confirmation that the build lifecycle is unchanged;
5. confirmation that progress is now explicitly non-cancellable;
6. tests;
7. deviations from Audit 21.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not rewrite Audit 21.

---

## 10. Verification

Run:

- focused onboarding progress/presentation tests;
- import/graph-build controller tests;
- OnboardingGate tests;
- Environment Readiness tests if shared presentation is involved;
- complete Onboarding tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- debug macOS build.

Do not launch against the production archive.

---

# Hard constraints

Do not:

- add real cancellation;
- rename Abort to another misleading action;
- change mutation coordination;
- change reset behavior;
- change graph-build lifecycle;
- change restart semantics;
- add progress telemetry;
- add stage names;
- add percentage;
- add Presence Step types;
- add ActionStep;
- modify schema;
- alter recovery policy.

If removing the control unexpectedly requires any of these, stop and explain why.

---

# Success criterion

During active initial setup, the human sees:

```text
MessageLens is working
```

with no control falsely implying:

```text
I can safely stop this operation now
```

The build itself behaves exactly as before.

Stop after this slice and report before any further progress-experience changes.

That feels like exactly the right correction: remove the lie first, then decide later whether real cancellation is worth the engineering cost.
