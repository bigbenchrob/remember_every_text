# Environment Readiness Evaluation

## Purpose

Before presenting the user with setup/retry options, the onboarding system
evaluates the macOS environment to determine what is accessible, what is
missing, and what action the user should take. This prevents ambiguous error
states and provides evidence-backed advice.

Current readiness presentation is split across essentials and a feature:
`lib/essentials/onboarding/` owns the report and gate state,
`lib/essentials/navigation/` projects gate states into the panel stack, and
`lib/features/environment_readiness/` owns the readiness panel content for
`EnvironmentReadinessSpec`.

## Provider

```dart
// lib/essentials/onboarding/application/onboarding_environment_report_provider.dart
@Riverpod(keepAlive: true)
Future<OnboardingEnvironmentReport> onboardingEnvironmentReport(Ref ref) async { ... }
```

## Evaluation Steps

The provider runs these checks in sequence:

### 1. Full Disk Access (FDA)

**Check:** `FdaChecker.canReadMessagesDatabase()` — attempts `File.openSync()`
on `~/Library/Messages/chat.db`.

**Outcomes:**
- Readable → FDA granted
- Permission denied → `permissionBlocked`
- File not found → rare (Messages not installed or never used)

**User action:** "Open System Settings" button that opens the FDA pane via
macOS URL scheme (`x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles`).

**Build note:** FDA grants are tied to the app's bundle identifier
(`com.bigbenchsoftware.MessageLens`) and code signing identity. Changing
either revokes the grant. See
[`60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`](../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md).

### 2. Messages Database Probe

**Check:** Open `~/Library/Messages/chat.db` read-only and query key tables.

**Evidence gathered:**
- File exists and is readable
- File size is non-trivial
- Row counts from `message`, `chat`, `handle`, and join tables
- Newest message date (if cheaply available)

**Outcomes:**
- Absent → `sourceUnavailable`
- Present but very few messages (< 10) → `sourceSparseOrUnsynced`
- Present with meaningful data → source healthy

**Sync plausibility:** The app cannot directly query Apple's iCloud sync
state. A near-empty `chat.db` on a Mac with an active iCloud account suggests
that Messages in iCloud has not synced locally, or the Mac is not enrolled in
Messages sync. This is communicated as an inference, never a certainty.

### 3. AddressBook Probe

**Check:** Resolve AddressBook database path via the approved provider-driven
path logic (see [`10-DATABASES/06-addressbook-path-resolution.md`](../10-DATABASES/06-addressbook-path-resolution.md)).

**Evidence gathered:**
- Path resolution succeeds
- Database is readable
- Contact row count available

**Outcomes:**
- Path resolution fails or DB unreadable → `sourceUnavailable` with
  `addressBookUnavailable`
- Path resolves, DB readable → contacts healthy

### 4. App Database Probe

**Check:** Probe `macos_import_ss.db` and `working_ss.db` / conversation graph
readiness for file existence, readability, graph completeness, and message row
counts. `DatabaseExistenceChecker` remains the fallback filesystem check used
by `OnboardingGate` while the async report is loading or unavailable.

**Evidence gathered:**
- Source-scoped import ledger present/absent/empty
- Conversation graph present/absent/empty/without required topology

**Outcomes:**
- Both populated → `ready` (app can skip onboarding)
- Either missing/empty → `readyToImport`

### 5. Failure History

**Check:** Read persisted import/graph-projection failure summaries from overlay DB
`OverlaySettings` table.

**Evidence gathered:**
- Last import result (success/failure, timestamp, row counts)
- Last graph projection/build failure (timestamp)
- Whether the failure is "fresh" (recent enough to be the current blocker)

**Outcomes:**
- Last import failed → `importFailed`
- Last graph projection/build failed → `graphProjectionFailed`
- No failure history → standard flow

## Report Model

```dart
// lib/essentials/onboarding/domain/onboarding_environment_report.dart
class OnboardingEnvironmentReport {
  const OnboardingEnvironmentReport({
    required this.state,
    required this.blockerKind,
    required this.syncPlausibility,
    required this.messagesDatabase,
    required this.addressBookDatabase,
    required this.importDatabase,
    required this.conversationGraph,
    required this.hasFullDiskAccess,
    this.sourceAttachmentCount,
    this.lastImportFailure,
    this.lastGraphProjectionFailure,
    this.shouldResetAppDatabasesBeforeImport = false,
    this.resetAppDatabasesReason,
  });
}
```

## State Classification

| State | Meaning | User sees |
|-------|---------|-----------|
| `permissionBlocked` | FDA not granted | FDA instructions + "Open System Settings" |
| `sourceUnavailable` | `chat.db` not found | Explanation + guidance |
| `sourceSparseOrUnsynced` | Source has < 10 messages | Warning about likely missing sync + proceed option |
| `readyToImport` | Sources healthy, DBs empty | "Import" button |
| `importFailed` | Last import failed | Error details + "Retry" |
| `graphProjectionFailed` | Last graph projection/build failed | Error details + "Retry" |
| `ready` | App databases populated | No overlay (normal app) |

Import and graph-build progress are `OnboardingStatus` workflow states, not
`OnboardingEnvironmentState` values.

## Current Readiness Surface

`OnboardingCenterPanelSyncObserver` watches `OnboardingGate`:

* `awaitingFda` and `awaitingUserAction` show
  `ViewSpec.environmentReadiness(EnvironmentReadinessSpec.readinessPanel())`
  in the center panel.
* Existing import panel content is not overwritten.
* When readiness is no longer needed, the observer clears the readiness center
  panel.

This makes readiness a first-class panel surface. It is not an overlay-only
flow.

## Design Principles

### Conservative Diagnosis

If a condition cannot be known directly (e.g., iCloud sync state), the system
says it is "likely" or "inferred." No false certainty.

### Evidence-Backed Advice

Every recommendation is tied to a concrete signal:
- File unreadable → permission advice
- Row counts near zero → sync advice
- Import DB empty after attempt → pipeline advice

### No Architectural Leakage

The user sees a clear readiness assessment, not raw exceptions or internal
pipeline details.

## Historical Context

Older planning material under
`45-NEW-FEATURE-ADDITION/enhanced-onboarding-readiness-panel/` describes the
readiness panel as proposed work. That proposal has been partially implemented:
the current app has `ViewSpec.environmentReadiness`, an environment readiness
feature, and an essentials-owned panel sync observer. Treat overlay-only
wording in older docs as legacy unless current code confirms it.
