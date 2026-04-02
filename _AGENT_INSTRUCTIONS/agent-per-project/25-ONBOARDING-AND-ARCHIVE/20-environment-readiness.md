# Environment Readiness Evaluation

## Purpose

Before presenting the user with import/migration options, the onboarding
system evaluates the macOS environment to determine what is accessible, what
is missing, and what action the user should take. This prevents ambiguous
error states and provides evidence-backed advice.

## Provider

```dart
// lib/essentials/onboarding/application/onboarding_environment_report_provider.dart
@riverpod
class OnboardingEnvironmentReportProvider extends _$OnboardingEnvironmentReportProvider {
  @override
  Future<OnboardingEnvironmentReport> build() async { ... }
}
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
- Path resolution fails → contacts will be unavailable (non-blocking warning)
- Path resolves, DB readable → contacts healthy

### 4. App Database Probe

**Check:** `DatabaseExistenceChecker` — pure filesystem check for
`macos_import.db` and `working.db` (file exists and size > 0). No SQLite
connection opened.

**Evidence gathered:**
- Import DB present/absent/empty
- Working DB present/absent/empty

**Outcomes:**
- Both populated → `ready` (app can skip onboarding)
- Either missing/empty → `readyToImport`

### 5. Failure History

**Check:** Read persisted import/migration results from overlay DB
`OverlaySettings` table.

**Evidence gathered:**
- Last import result (success/failure, timestamp, row counts)
- Last migration result (success/failure, timestamp)
- Whether the failure is "fresh" (recent enough to be the current blocker)

**Outcomes:**
- Last import failed → `importFailed`
- Last migration failed → `migrationFailed`
- No failure history → standard flow

## Report Model

```dart
// lib/essentials/onboarding/domain/onboarding_environment_report.dart
@freezed
abstract class OnboardingEnvironmentReport with _$OnboardingEnvironmentReport {
  const factory OnboardingEnvironmentReport({
    required OnboardingEnvironmentState state,
    OnboardingBlockerKind? blockerKind,
    required SyncPlausibility syncPlausibility,
    required DatabaseProbes databaseProbes,
    DbImportResult? lastImportResult,
    DbMigrationResult? lastMigrationResult,
    bool? failureIsFresh,
  }) = _OnboardingEnvironmentReport;
}
```

## State Classification

| State | Meaning | User sees |
|-------|---------|-----------|
| `permissionBlocked` | FDA not granted | FDA instructions + "Open System Settings" |
| `sourceUnavailable` | `chat.db` not found | Explanation + guidance |
| `sourceSparseOrUnsynced` | Source has < 10 messages | Warning about likely missing sync + proceed option |
| `readyToImport` | Sources healthy, DBs empty | "Import" button |
| `importing` | Import in progress | Progress view |
| `importFailed` | Last import failed | Error details + "Retry" |
| `migrating` | Migration in progress | Progress view |
| `migrationFailed` | Last migration failed | Error details + "Retry" |
| `ready` | App databases populated | No overlay (normal app) |

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

## Future: Center Panel Readiness Surface

A proposal exists to move the readiness experience from an overlay model to
a first-class ViewSpec-driven center panel with a vertical checklist of
readiness steps (FDA → Messages → Contacts → Import). This would replace
the overlay's modal presentation with a calmer, more informational surface.

See `45-NEW-FEATURE-ADDITION/enhanced-onboarding-readiness-panel/` for the
full proposal. When implemented, the environment evaluation layer documented
here would serve as the evidence source for the new surface.
