---
tier: project
scope: onboarding-advanced-start-fresh
owner: agent-per-project
last_reviewed: 2026-08-25
source_of_truth: implementation-record
---

# Advanced Start Fresh Execution And Presentation Correction

## Observed Failure

On a completed disposable staging installation, accepting the advanced
**Start Fresh** confirmation closed the modal but left the old Settings page
visible and inert. No reset progress appeared and Onboarding did not begin.

The accepted-confirmation path was:

```text
ResetMessageDataRequested
  -> read advancedStartFreshActionProvider
  -> validate completed installation
  -> await authorization dialog
  -> read StartFreshService
  -> StartFreshService.startFresh
  -> ArchiveMutationCoordinator(startFresh)
```

The provider was generated as an auto-dispose provider. The dispatcher read it
without listening, while the returned action retained closures that captured
the provider `Ref`. During the frames spent in the authorization dialog, the
provider could be disposed. After confirmation, the action attempted to read
`StartFreshService` through that disposed `Ref` and failed before the service
or `ArchiveMutationCoordinator` was reached.

The dispatcher awaited the action but owned no operation presentation and no
typed failure projection. The asynchronous error therefore left the old
Settings presentation unchanged. The completed-installation guard did not
reject the operation, and Start Fresh did not run successfully in the
background; execution failed before mutation admission.

`/tmp/onboarding_profile_run_after.log` contained no Start Fresh or mutation
entry for this attempt. The diagnosis comes from the concrete provider
lifecycle and execution ordering rather than from absence of log output.

## Correction

The advanced action is now process-lived. Its provider dependencies remain
valid across the authorization boundary.

After authorization, the action creates a new process-local presentation
occurrence and publishes `preparing` synchronously. It then awaits Flutter's
next `endOfFrame` before resolving the service. This boundary exists only to
let the already-published operation surface paint before synchronous or
expensive reset work begins; no arbitrary delay was added.

The app shell renders that state as an opaque operation surface above the old
Settings workspace. The surface exposes:

- preparing the fresh start;
- verified virgin state while Onboarding assumes ownership;
- typed mutation-unavailable, virgin-verification, or execution failure;
- retry when the freshly classified installation remains eligible;
- return to Settings when the user chooses not to retry.

Every transition carries a monotonically increasing process-local occurrence.
Completion, failure, retry, dismissal, and Onboarding handoff must match the
current occurrence. A stale async completion therefore cannot replace or clear
a newer operation presentation.

The presentation state is not persisted and is not installation identity.
Durable truth remains the installation classifier and Onboarding operation
evidence.

## Preserved Authority Chain

The correction does not move reset behavior into presentation:

```text
human authorization
  -> visible advanced Start Fresh occurrence
  -> end-of-frame presentation boundary
  -> StartFreshService
  -> ArchiveMutationCoordinator(startFresh)
  -> allow-listed derived-store reset
  -> durable evidence reread
  -> require virgin installation
  -> refresh Onboarding
  -> existing Onboarding presentation assumes ownership
```

Only the four enumerated rebuildable database bases and their sidecars remain
eligible for reset. Apple source data, Historical Archive sources, recovery
donors, `attachment_archive/`, overlays, preferences, Presence/history,
diagnostics, archive identity, and other preserved artifacts remain outside
the mutation target.

## Retry And Failure Semantics

Failures are converted into typed visible presentation outcomes rather than
escaping into an unobserved dispatcher future. Diagnostic logging retains the
underlying error and stack.

A retry reclassifies installation evidence. It uses the completed-installation
advanced entry only while the installation remains completed; a genuinely
resumable or abandoned partial attempt resumes through the ordinary incomplete
installation entry. The canonical service still rechecks eligibility and the
coordinator still grants the only mutation capability.

## Verification

Focused coverage proves:

- the action remains callable after the authorization dialog has remained open
  across multiple frames;
- `preparing` is visible before the service is resolved or called;
- the old Settings surface cannot receive input while Start Fresh owns the
  presentation;
- typed failures expose retry/recovery actions;
- retry selects the truthful entry point from fresh installation evidence;
- an older completion cannot alter a newer occurrence;
- successful mutation still verifies virgin state before Onboarding refresh;
- the dispatcher still delegates rather than mutating data itself.

No staging reset was run during this correction. Because the observed failing
path did not reach `StartFreshService` or mutation admission, and because the
workflow is independently idempotent and virgin-verified, the disposable
staging archive is safe for one deliberate manual retry with the corrected
binary.
