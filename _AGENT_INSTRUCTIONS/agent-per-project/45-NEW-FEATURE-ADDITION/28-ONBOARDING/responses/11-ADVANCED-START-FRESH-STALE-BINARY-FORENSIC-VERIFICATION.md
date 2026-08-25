---
tier: project
scope: onboarding-advanced-start-fresh
owner: agent-per-project
last_reviewed: 2026-08-25
source_of_truth: implementation-record
---

# Advanced Start Fresh Stale-Binary Forensic Verification

## Manual Retest Did Not Run The Correction

The repeated manual symptom did not execute commit `be9f8ae7`.

The development process was PID 7162, launched at 2026-08-25 11:52:18 from:

```text
build/macos/Build/Products/Debug/MessageLens Development.app
```

The embedded Dart build predated the correction. Its build products were from
10:07, while commit `be9f8ae7` was created at 11:41:47. Launching the existing
app bundle after that commit did not rebuild or replace its embedded Dart
kernel. Rebuilding the bundle on disk later also did not replace code already
mapped into the running process.

The live Dart VM service provided conclusive read-only evidence. The running
process contained:

- the pre-fix `AdvancedStartFreshAction` with only `cancelled` and
  `startedFresh` results;
- an `AutoDisposeProvider<AdvancedStartFreshAction>`;
- no advanced Start Fresh presentation model, controller, or overlay script;
- a `MacosAppShell` whose top-level stack ended with `OnboardingOverlay` and
  did not contain `AdvancedStartFreshOverlayHost`.

The loaded action therefore had no operation occurrence, no `preparing`
publication, no end-of-frame paint boundary, and no typed visible failure. The
observed inert Settings screen was the exact behavior of that stale
intermediate binary.

## Provider And Presentation Ownership

Production composition creates one `ProviderContainer` in `main.dart` and
passes it to the app through one root `UncontrolledProviderScope`. There is no
nested production `ProviderScope` between the Settings action, sidebar action
dispatcher, `MacosAppShell`, and advanced operation host.

The corrected shell places `AdvancedStartFreshOverlayHost` last in its
top-level stack. It therefore renders above the ordinary Settings workspace.
No completed-installation navigation guard suppresses its `preparing` or
`failed` states. Onboarding status participates only in the verified-virgin
handoff.

Focused widget coverage now proves that the real Settings action and the
visible operation overlay resolve to the identical `ProviderContainer`.

## Corrected Execution Trace

The corrected implementation is protected by an ordered, non-mutating test
trace:

```text
Settings Reset message data action
  -> confirmation presented
  -> Start Fresh accepted
  -> modal closes
  -> keep-alive advanced action remains available
  -> operation occurrence publishes preparing
  -> mounted operation host renders preparing
  -> endOfFrame completes
  -> StartFreshService resolves
  -> StartFreshService starts
  -> ArchiveMutationCoordinator requests startFresh admission
  -> coordinator supplies the active caller-scoped capability
  -> derived-data reset begins
  -> virgin installation is verified
  -> Onboarding refresh is requested
  -> Onboarding assumes presentation ownership
```

The error-path test proves that a service exception changes the same mounted
surface to a typed failure with **Try Again** and **Return to Settings**. It
does not disappear into the action dispatch future.

## Staging Preservation

No reset was run during this investigation.

Read-only immutable inspection found both derived stores intact after the
stale manual attempt:

- `macos_import_ss.db`: 137,379 messages, `quick_check = ok`, modification time
  11:22:46;
- `working_ss.db`: 137,379 messages, `quick_check = ok`, modification time
  11:22:46.

Both modification times predate the stale app launch at 11:52. The attempted
reset therefore did not modify either derived store. The staging archive is
safe for one deliberate retry after the stale process is quit and the freshly
built app is launched.

## Fresh Build Evidence

A new debug bundle was built from source commit:

```text
be9f8ae7e0fbc5c9ed7cae260f235b0a3ca3eb9c
```

The bundle identity is:

```text
bundle id: com.bigbenchsoftware.MessageLens.development
version: 0.2.90
build: 108
```

The new Dart kernel was produced at 11:56:38, after the commit, at:

```text
build/macos/Build/Products/Debug/MessageLens Development.app/
  Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/
  kernel_blob.bin
```

Its SHA-256 at verification time was:

```text
083406bee3ad2aa8f9768ce7788f1559c3d6b09f29db7233c8c8ec8f2552f101
```

The old PID must be quit before manual validation. A process keeps executing
the kernel mapped at launch even if the app bundle is rebuilt in place.
