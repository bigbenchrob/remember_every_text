# Startup Hook

This document records the current startup and onboarding entry path. It is an
observation of the existing application, not a proposal for changing it.

## Launch Path

`main()` in `lib/main.dart` first admits the configured archive environment.
If archive admission fails, application startup stops before Riverpod, the
router, or onboarding is created. Archive admission is therefore a startup
precondition, not the onboarding decision point.

After platform and service initialization, `main()` creates the root
`ProviderContainer` and runs `StartupApp`. `StartupApp` handles the separate
Option-launch reset dialog and then builds `App`.

There is one temporary laboratory exception: in `kDebugMode`, `App.build()`
currently displays `PresenceIterationSimpleHost` directly. That branch does
not construct the router or the production onboarding flow. The application
path described below is the router-backed path used when that debug override
is not active.

The router opens `MacosAppShell`. Building the shell watches the onboarding
gate, which causes the current readiness decision to be evaluated.

## Existing Decision Point

The existing startup decision point is:

```text
OnboardingGate.build()
```

Location:

```text
lib/essentials/onboarding/application/onboarding_gate_provider.dart
```

Owning class:

```text
OnboardingGate
```

`OnboardingGate.build()` watches `onboardingEnvironmentReportProvider`, then
passes the report through `resolveBuildStatus()` and
`_classifyStatusFromReport()`. The resulting `OnboardingStatus` answers the
current startup question:

- `notNeeded`: the application data is ready;
- `awaitingFda`: protected source data cannot yet be read;
- `awaitingUserAction`: setup requires user attention before import;
- a workflow status: recovery, import, graph construction, or completion is
  already in progress.

While the asynchronous report is loading or fails, `_fallbackBuildStatus()`
performs a cheaper check using Full Disk Access plus the existence and
readiness of the source-scoped import and conversation-graph databases.

## Data Examined

The authoritative report is assembled by
`onboardingEnvironmentReportProvider` in
`lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`.
Its evaluator currently examines:

- whether `~/Library/Messages/chat.db` is readable under Full Disk Access;
- whether the Messages database exists and how many message and attachment
  rows are locally available;
- whether the local Contacts source is available;
- the admitted MessageLens archive root;
- the attachment archive directory;
- the overlay database probe;
- the source-scoped import database, including imported message rows;
- the conversation-graph database, including graph readiness and row counts;
- whether database maintenance currently holds the archive lock;
- persisted import or graph-projection failures;
- current graph-build and live-update monitor state;
- developer readiness simulations, when explicitly active.

The evaluator classifies those facts as an
`OnboardingEnvironmentState` and an `OnboardingBlockerKind`. `OnboardingGate`
then translates that report into the application-facing `OnboardingStatus`.

## What Becomes Visible

The gate owns the decision but does not directly build the initial setup UI.

`OnboardingCenterPanelSyncObserver`, mounted by `MacosAppShell`, watches the
gate status. After the frame it calls:

```text
OnboardingCenterPanelSyncController.synchronize()
```

For `awaitingFda` or `awaitingUserAction`, that controller selects Messages
mode and installs the Environment Readiness `ViewSpec` in the center panel.
The environment-readiness feature resolves that spec to
`EnvironmentReadinessPanelView`.

The full-window `OnboardingOverlay` is not the initial readiness surface. The
shell displays it only after the workflow enters recovery, import, graph
construction, or completion states.

## Where Import Begins

The **Import My Messages** action is rendered by the Environment Readiness
panel. Its action boundary calls:

```text
EnvironmentReadinessActions.startImportAndGraphBuild()
```

That delegates to:

```text
OnboardingGate.startImportAndGraphBuild()
```

The gate accepts the request only while its state is
`awaitingUserAction`, obtains archive mutation authority, rechecks Full Disk
Access, prepares derived data for a fresh start, changes the workflow status
to `importing`, and invokes the conversation-graph build pipeline.

## Natural Journey Request Location

The natural existing hook is the decision represented when
`OnboardingGate.build()` resolves to `awaitingFda` or
`awaitingUserAction`. `OnboardingGate` is already the single owner that turns
startup evidence into the decision that onboarding is required. It acts
before Navigation chooses a presentation and before the import action begins.
This observation identifies the decision boundary; it does not imply that an
arbitrary side effect should be placed directly inside `build()`.

The surrounding responsibilities are already distinct:

```text
OnboardingEnvironmentReport
    -> supplies observed readiness facts

OnboardingGate.build()
    -> decides whether onboarding is required

OnboardingCenterPanelSyncController.synchronize()
    -> makes the compatible readiness presentation visible

OnboardingGate.startImportAndGraphBuild()
    -> begins operational import work after user action
```

This identifies the entry seam without changing startup, onboarding, or
Presence architecture.
