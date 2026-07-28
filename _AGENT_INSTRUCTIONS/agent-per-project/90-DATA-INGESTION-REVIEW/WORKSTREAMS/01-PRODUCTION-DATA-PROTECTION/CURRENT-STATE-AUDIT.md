---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: audit
status: current-state-audit-complete
links:
  - ./README.md
  - ./00-task.md
  - ../../00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ../../../10-DATABASES/00-all-databases-accessed.md
  - ../../../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../../../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests:
  - macos/RunnerTests/RunnerTests.swift
  - test/architecture/forbidden_imports_test.dart
---

# Production Data Protection Current-State Audit

## Evidence Classification

This audit uses four evidence classes:

- **Verified static:** established directly from source code, configuration, or
  test code.
- **Documented intention:** stated by project documentation but not fully
  enforced or verified by the inspected implementation.
- **Runtime verification required:** static inspection defines the expected
  behavior, but an actual process, filesystem, signing, or concurrency
  experiment is needed.
- **Unresolved:** neither static inspection nor current documentation establishes
  the answer.

No production database, live Apple source, application process, or destructive
workflow was exercised during this audit.

## Executive Summary

### Primary answer

> **Yes. A current development path can reach and mutate the production
> MessageLens archive.**

A normal macOS debug launch executes the same `lib/main.dart`, uses the same
bundle identifier, resolves the same Application Support directory, and opens
the same app-owned import, graph, overlay, attachment, and pipeline-evidence
stores as a production launch. There is no distinct archive-environment
identity and no debug/test data-root selection gate before writable providers
become available.

This does **not** mean Apple source databases are being mutated. The inspected
Apple Messages and Contacts source readers consistently use read-only
connections and query-only enforcement. The risk is to the permanent
MessageLens archive derived from those sources.

### Current safety posture

The system has several strong local protections:

- centralized providers own the three current app databases;
- Apple-owned source databases are opened read-only;
- a native single-instance authority runs before Flutter initialization;
- historical archive import rejects the live `chat.db` path;
- some high-risk graph/archive operations use a shared execution gate and
  maintenance lock;
- reset and historical-source removal have explicit user-facing confirmation;
- most tests use in-memory or temporary databases;
- manual snapshot and recovery procedures are documented.

Those protections do not establish development/production isolation. They
protect particular resources or operations after a single writable archive has
already been selected.

### Principal risks

1. **No archive-environment boundary.** Debug and release builds select the same
   app-owned writable root.
2. **Build identity is being used as archive identity by consequence, not by an
   explicit contract.** The stable production bundle identifier is correctly
   required for Full Disk Access continuity, but it also makes ordinary debug
   launches converge on the production Application Support directory.
3. **Mutation serialization is incomplete.** The shared
   `GraphMaintenanceExecutionGate` is used by live reconciliation and
   historical archive workflows, but not by every graph-build and reset entry
   point.
4. **Snapshot/recovery is procedural.** The application does not establish or
   verify a recoverable snapshot before destructive reset or rebuild work.
5. **Test isolation is conventional rather than universal.** Inspected tests
   generally use temporary or memory storage, but no fail-closed test archive
   identity prevents a future test or integration entry point from initializing
   the production root.

### Strongest protections

The strongest current mechanisms are the native pre-Flutter process lock,
read-only Apple source access, centralized persistent database providers, and
the overlay/derived-data ownership boundary. Each is mechanically enforced
within its stated scope.

### Highest-priority unknowns

Runtime verification is still required for:

- the exact Application Support paths selected by debug, profile, and installed
  release artifacts;
- single-instance behavior across differently signed or separately installed
  copies;
- Full Disk Access behavior for those artifacts;
- overlap between live monitoring and graph build/reset entry points that do
  not share one execution authority;
- snapshot completeness and restoration, including SQLite sidecars and the
  attachment archive.

## Environment Resolution

### Build mode

Flutter build mode is available through normal compile-time constants such as
`kDebugMode` and `kReleaseMode`. Inspected uses affect developer controls,
logging, diagnostics, and some window-state behavior.

**Verified static:** build mode does not select the MessageLens database root or
an archive environment.

### Bundle and signing identity

`macos/Runner/Configs/AppInfo.xcconfig` declares the application bundle
identifier as:

```text
com.bigbenchsoftware.MessageLens
```

Both macOS Debug and Release configurations include the same application
identity configuration. The production build documentation intentionally
requires a stable bundle identifier and release signing identity so existing
Full Disk Access grants carry forward.

**Verified static:** there is no separate development bundle identifier in the
inspected project configuration.

**Runtime verification required:** the effective signing identity,
entitlements, and bundle identifier of actual debug, profile, locally built
release, and distributed release artifacts must be inspected from built
products.

### Archive environment

No first-class archive-environment identity was found. The inspected startup,
provider, build, and launch configuration does not distinguish concepts such as:

```text
production
development
test
disposable experiment
```

No `String.fromEnvironment`, process environment variable, launch argument, or
in-app selector determines which MessageLens archive may be opened.

**Verified static:** archive environment is currently implicit and resolves to
the one Application Support root.

### Startup resolution

`lib/main.dart` performs this sequence before the application UI is built:

1. initialize Flutter bindings;
2. call `initDatabaseDirectoryPath()`;
3. initialize SQLite FFI and Rust support;
4. create the root provider container;
5. initialize logging and window state;
6. run the application.

`lib/essentials/db/database_directory.dart` implements
`initDatabaseDirectoryPath()` using `path_provider`'s
`getApplicationSupportDirectory()` and assigns the result to the process-global
`databaseDirectoryPath`.

No archive admission check runs between Application Support resolution and
writable provider availability.

**Verified static:** the startup path selects one platform-derived writable
root, not an environment-qualified root.

### Runtime overrides

No supported runtime override for the active MessageLens archive root was
found. Tests can assign the process-global directory before creating providers,
but this is test setup, not an application environment contract.

The Option-key startup dialog is not an environment selector. Its current
"Delete MessageLens App Data" path records the selected action and continues;
it is not the production reset service and does not protect archive selection.

### Active archive identity

The active app-owned archive is the collection of stores rooted in the selected
Application Support directory:

```text
macos_import_ss.db
working_ss.db
user_overlays.db
attachment_archive/
pipeline and diagnostic evidence files
```

The same root also contains or has contained retired cleanup/diagnostic database
files. Operational application logs are additionally written beneath
`~/Library/Logs/MessageLens/`.

**Verified static:** archive identity is currently equivalent to "the
Application Support directory returned for this bundle/process."

**Runtime verification required:** record the exact resolved path for every
supported build/launch mode on a clean verification machine.

## Mutation Authority

### App-owned writable databases

`lib/essentials/db/feature_level_providers/persistent_database_providers.dart`
is the central construction seam:

| Store | Provider | Open mode | Current role |
| --- | --- | --- | --- |
| `macos_import_ss.db` | `sourceScopedImportDatabaseProvider` | Writable | Source-scoped imported facts and ledger |
| `working_ss.db` | `driftConversationGraphDatabaseProvider` | Writable | Derived Conversation graph and evidence projections |
| `user_overlays.db` | `overlayDatabaseProvider` | Writable | User intent and archive-source metadata |

The providers create the selected directory as needed. Opening the stores may
also create or migrate schemas.

**Verified static:** all three current databases resolve from
`databaseDirectoryPath`; therefore a debug process can open the production
archive writable.

### Writable filesystem locations

| Location | Current writer | Authority |
| --- | --- | --- |
| `attachment_archive/` | Attachment archive file store and archive settings/actions | Copies source attachments, exports files, and may recursively clear/recreate the archive |
| Pipeline audit/incident evidence under the app data root | Logging and incident-storage services | Appends operational evidence and records the latest incident |
| `~/Library/Logs/MessageLens/app.log` | Application log writer | Appends application diagnostics |
| Window/preferences state | Window-state and preferences infrastructure | Persists application state; some behavior varies in debug |

The attachment clear action also clears corresponding overlay records.

**Verified static:** these locations are not selected independently from the
active application identity. Debug and production activity can share them.

### Apple-owned source access

The primary Apple source paths include:

- `~/Library/Messages/chat.db`;
- the dynamically resolved AddressBook database;
- live attachment files referenced by Messages.

The source database abstraction opens SQLite sources read-only, enables
`PRAGMA query_only=ON`, and restricts the query surface to read-only SQL.
Additional probes and historical readers use read-only SQLite modes and
query-only enforcement.

**Verified static:** inspected import and probe paths do not write Apple source
databases.

Attachment ingestion reads Apple-owned files and copies them into the writable
MessageLens attachment archive. Read-only source database safety therefore does
not imply isolation of app-owned archive writes.

### Application-instance admission

`macos/Runner/MainFlutterWindow.swift` establishes native admission before the
Flutter engine starts:

1. inspect running applications for the same bundle identifier;
2. acquire a non-blocking POSIX advisory lock;
3. terminate a duplicate after activating the existing instance.

The lock file is hard-coded beneath:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens/
MessageLens.instance.lock
```

`macos/RunnerTests/RunnerTests.swift` covers first-owner admission and rejection
of a contending owner.

**Verified static:** two ordinary same-identity MessageLens processes cannot
both pass this admission path on one account.

This is process admission, not environment isolation. One debug instance may
still mutate production after a release instance exits. The hard-coded
production lock path would also remain shared if data roots were later separated
without a corresponding lock-identity decision.

**Runtime verification required:** verify installed release, `flutter run`,
renamed app copies, and differently signed copies.

### Operation-specific execution authority

Two process-local mechanisms exist:

#### `GraphMaintenanceExecutionGate`

This gate grants named, reentrant ownership to one graph-maintenance operation.
It is used by:

- live `ChatDbChangeMonitor` reconciliation/update work;
- historical archive import;
- historical archive removal.

#### `DbMaintenanceLock`

This lock marks database maintenance in progress. The graph database provider
refuses to open while it is active. It is used around:

- message-data reset;
- historical archive import/removal.

#### Static coverage gap

The ordinary `ConversationGraphBuildController.runOnce()` coalesces calls made
through that controller, but does not acquire the shared
`GraphMaintenanceExecutionGate`. Onboarding, reimport, automatic recovery, and
developer graph-build actions can reach this controller.

`MessageDataResetService` acquires `DbMaintenanceLock`, closes and invalidates
selected providers, and deletes derived database files, but does not acquire
`GraphMaintenanceExecutionGate`.

**Verified static:** not every graph/import/reset entry point derives mutation
authority from one shared operation gate.

Current architecture documentation describes broader gate coverage than the
inspected code enforces. That wording is a **documented intention**, not a
verified current invariant.

**Runtime verification required:** exercise live monitor, onboarding,
reimport/reset, developer build, and historical archive operations under
controlled disposable storage to determine which overlaps are reachable.

### Ownership boundaries

The current intended write ownership is coherent:

- source import writes imported source facts;
- graph projection writes derived graph state;
- overlay writes user intent;
- attachment infrastructure writes the living attachment archive;
- source readers do not write source databases.

The central provider seams make construction discoverable and auditable.
However, ownership boundaries do not determine which archive environment those
writers receive.

## Production Safety

### Provider centralization

Persistent app database construction is centralized and architecture tests
guard against ordinary feature-owned database construction.

**Verified static:** this is a strong seam for future environment enforcement.

### Overlay/derived separation

User intent belongs to overlay storage and is merged with graph facts at read
time. Import and graph projection do not own overlay state.

**Verified static for inspected paths:** destructive rebuild of derived stores
does not intentionally delete `user_overlays.db`.

### Historical archive protections

Historical workflows:

- open selected source databases read-only;
- reject the live Messages `chat.db` as a historical source;
- use both the graph execution gate and maintenance lock;
- require confirmation before removing imported historical archive data.

**Verified static:** these protections exist in the inspected workflow.

**Runtime verification required:** verify source-path equivalence handling for
aliases, symlinks, case differences, and mounted/restored paths.

### Reset protections

The settings reset workflow requires confirmation and uses
`MessageDataResetService`. That service:

- closes current import/graph database handles;
- deletes current derived import/graph files and SQLite sidecars;
- removes retired cleanup/diagnostic files where present;
- preserves overlay state and the attachment archive;
- invalidates providers before releasing its maintenance lock.

Onboarding recovery can invoke the same reset as part of an automatic recovery
decision. No application-enforced snapshot precondition was found.

**Verified static:** reset scope is bounded to named app-owned derived stores.

**Verified static:** reset is not currently protected by the shared graph
execution gate.

### Path and deletion safeguards

Inspected reset, archive, and logging code validates expected paths or names and
avoids following arbitrary paths for destructive operations.

**Verified static:** basic path-scope safeguards exist.

### Snapshot and recovery

The Environment Safety documentation defines:

- a manual pre-experiment snapshot using `rsync`;
- a requirement to quit MessageLens before copying;
- a manual recovery procedure;
- an experimental workflow that requires a snapshot before high-risk work.

The routine snapshot procedure excludes the attachment archive.

**Documented intention:** developers must create and verify snapshots before
high-risk work.

**Verified static:** no startup gate, mutation gate, snapshot manifest, automated
backup, or rollback mechanism enforces that requirement.

**Runtime verification required:** prove that the procedure produces a
restorable archive, including SQLite WAL/SHM state, overlay data, attachment
policy, logs needed for diagnosis, permissions, and archive-source metadata.

### Test isolation

Inspected database tests predominantly use:

- `NativeDatabase.memory()`;
- `Directory.systemTemp`;
- provider overrides;
- explicit temporary import roots.

One onboarding test assigns `databaseDirectoryPath` to a temporary directory
before constructing providers. No inspected test intentionally invokes the
production application startup path.

**Verified static:** current focused unit/widget tests generally isolate
database writes.

**Unresolved as a universal guarantee:** no test-only archive identity makes
production access mechanically impossible if a future integration test or tool
initializes normal app startup/providers.

### Startup checks and health probes

Onboarding and health providers inspect source and app database readiness,
coverage, and schema state. Their SQLite probes are read-only where they inspect
existing databases.

These checks answer whether data appears usable. They do not establish whether
the current writable root is production, development, or disposable.

## Escape Paths

The following are current paths by which development or experimental work can
affect production app-owned data.

### 1. Ordinary debug launch

`.vscode/launch.json` launches `lib/main.dart` in debug mode without selecting a
separate data root. `flutter run -d macos` follows the same startup path.

**Verified static escape path:** opening any central writable provider can
create, migrate, or mutate the production archive.

### 2. Debug live synchronization

Once started, `ChatDbChangeMonitor` can read the live Apple Messages source and
write new source facts and graph projections into the shared archive.

**Verified static escape path:** development UI work can cause production
archive ingestion even when the developer did not explicitly begin an import.

### 3. Onboarding, reimport, reset, and recovery

Development launches expose workflows that can reset and rebuild derived
production stores because archive selection is not environment-qualified.

**Verified static escape path:** confirmation limits some user actions, but the
target remains production.

### 4. Historical archive workflows

Historical import/removal correctly protects source access and serializes its
own operation, but writes the one active app archive.

**Verified static escape path:** experimental historical import in a debug build
is a production archive operation.

### 5. Attachment archive operations

Development launches can copy files into, export from, or clear the shared
living attachment archive.

**Verified static escape path:** database isolation alone would not protect the
complete archive.

### 6. Operation-gate bypass

Not every graph-build/reset caller acquires the shared graph execution gate.

**Verified static escape path:** the architecture does not mechanically exclude
all overlapping mutation paths within an admitted process.

### 7. Future tests using normal startup

Current tests are mostly isolated, but isolation is not enforced by the
application's root-selection mechanism.

**Potential escape path:** a future integration test, diagnostic harness, or
developer tool can reach production if it initializes normal startup without a
root override.

### 8. Standalone maintenance scripts

At least one legacy tool (`tool/reformat_handle_display_names.dart`) opens a
writable SQLite database by a hard-coded personal path outside the centralized
provider seam. The inspected path refers to a legacy database, not the current
production archive.

**Verified static design escape:** standalone scripts can bypass application
environment and provider boundaries. Whether any current local invocation
targets retained production data requires operator verification.

## Required Runtime Verification

These experiments must use read-only inspection or a disposable clone unless a
separate production-safe protocol explicitly authorizes otherwise.

| Question | Required experiment | Expected evidence |
| --- | --- | --- |
| What root does each build use? | Launch debug, profile, local release, and installed release with root reporting before providers open | Bundle identity, signing identity, build mode, resolved root, archive identity |
| Does FDA carry across artifacts? | Inspect entitlements/codesign and attempt read-only Apple source probes | Artifact identity and read-only access result |
| Which copies share admission? | Launch installed release, `flutter run`, renamed copy, and differently signed copy in controlled combinations | Native admission/termination and lock ownership log |
| Can graph operations overlap? | Under disposable storage, hold or delay monitor/build/reset/archive phases and trigger competing entries | Gate owner, lock state, operation rejection/serialization, database integrity |
| Is reset recoverable? | Snapshot a disposable archive, run reset/rebuild, restore it, and compare manifests/health reports | Hash/manifest, schema state, overlay preservation, sidecar handling |
| Is the attachment policy recoverable? | Exercise snapshot and restore with archived files and overlay records | File/record reconciliation and documented exclusion consequences |
| Is historical-source rejection canonical? | Test equivalent paths, symlinks, aliases, and copied snapshots | Accepted/rejected source identity matrix |
| Are all tests isolated? | Instrument root/provider construction during the full test and integration suite | No path beneath production Application Support; no live source writes |
| Does the shipped artifact match documentation? | Inspect final app and DMG with `codesign`, `spctl`, and bundle metadata tools | Team, identity, entitlements, bundle identifier |
| Are manual snapshots transactionally complete? | Compare snapshots made with the app stopped versus active against SQLite integrity/health checks | Explicit proof of required process state and included files |

## Audit Matrix

| Concern | Current mechanism | Code authority | Mechanically enforced? | Production risk | Evidence |
| --- | --- | --- | --- | --- | --- |
| Environment identity | No first-class archive environment | Startup/build configuration | No | Critical: development resolves production by default | Verified static |
| Build mode | Flutter debug/profile/release constants | Flutter build | Yes as build metadata; no archive effect | Build mode can be mistaken for safety boundary | Verified static |
| Bundle/signing identity | One bundle ID; stable production signing required for releases | macOS xcconfig/build pipeline | Bundle ID yes; effective signing needs artifact inspection | Debug/release identity convergence contributes to shared root | Static + runtime required |
| Data-root selection | `getApplicationSupportDirectory()` assigned globally | `database_directory.dart` | Yes, but not environment-qualified | Critical shared writable root | Verified static |
| Archive identity | Collection of files under selected app root | Implied by provider paths | No explicit identity | Process cannot prove which archive it may mutate | Verified static |
| Database providers | Central import, graph, overlay providers | Persistent database providers | Yes for ordinary app construction | Strong future enforcement seam, currently points to production | Verified static |
| Apple source databases | Read-only open mode and query-only pragma | Source database opener/readers | Yes for inspected paths | Low source-mutation risk | Verified static |
| Attachment archive | App-owned file store under selected root | Attachment infrastructure | Yes as ownership; no environment isolation | Debug can modify production files | Verified static |
| Operational evidence | App-root pipeline evidence and shared app log | Logging/incident services | Path mechanically selected; no environment isolation | Debug and production evidence can mix | Verified static |
| Application-instance admission | Bundle check plus POSIX lock before Flutter | Native macOS runner | Yes for same admission identity | Prevents simultaneous ordinary copies, not sequential production access | Static + runtime required |
| Operation execution authority | Graph gate plus maintenance lock, applied selectively | Graph/archive/reset orchestration | Partial | Competing mutation paths may remain reachable | Verified static gap + runtime required |
| Snapshot requirement | Manual quit-and-`rsync` protocol | Environment Safety docs | No | Destructive work may proceed without recovery evidence | Documented intention |
| Recovery | Manual folder replacement and health verification | Environment Safety docs | No | Recovery confidence is unproven | Documented intention + runtime required |
| Test isolation | Memory/temp databases and overrides in inspected tests | Individual tests | Mostly, by convention | Future normal-startup test could reach production | Static + unresolved universal guarantee |
| Onboarding reset | Confirmation/recovery flow and bounded reset service | Onboarding/settings + reset service | Scope yes; snapshot/gate coverage no | Debug can reset production derived stores | Verified static |
| Historical import/removal | Read-only source, live-source refusal, operation gates, confirmation | Historical archive workflow | Strong within workflow | Still mutates production archive in debug | Verified static |
| Build/debug launch tooling | Default debug launch of normal `main.dart` | VS Code/Flutter launch config | Yes, toward shared root | Direct development-to-production path | Verified static |
| Maintenance tooling | Standalone writable script with hard-coded legacy path | `tool/` script | Outside app seam | Can bypass environment/provider policy | Verified static |
| Startup dialog | Option-key action UI; current delete action logs only | `main.dart` startup host | No archive safety effect | May create a false impression of reset authority | Verified static |

## Conclusions

### Verified protections

- Apple source databases are opened read-only by inspected import/probe paths.
- Current app database construction is centralized.
- Overlay intent is separated from derived import/graph state.
- Native process admission runs before Flutter and has focused tests.
- Historical archive workflows reject the live source and use both operation
  gates.
- Reset deletion is bounded to named app-owned derived database files.
- Most inspected tests use memory or temporary storage.
- Manual snapshot and recovery procedures exist.

### Unverified assumptions

- Debug, profile, and installed release resolve exactly the paths predicted by
  static bundle configuration.
- All relevant app copies are excluded by the native single-instance authority.
- Manual snapshots are complete and recoverable.
- Full Disk Access behavior matches documented signing expectations for every
  artifact.
- Current test and CI entry points can never initialize production providers.
- SQLite handles and provider invalidation are sufficient under every competing
  reset/build sequence.

### Known escape paths

- An ordinary debug launch selects the production app-owned archive.
- Automatic live synchronization can mutate that archive during development.
- Onboarding, reset/reimport, historical archive, attachment, and developer
  graph operations target that same archive.
- Shared operation authority is not acquired by every graph-build/reset entry
  point.
- Standalone maintenance scripts can bypass centralized environment/provider
  seams.

### Questions requiring runtime testing

- What exact root, bundle, team, entitlements, and signing identity does each
  supported artifact use?
- Which artifact combinations share process admission?
- Can the uncovered graph/reset entry points overlap with monitor or archive
  work?
- Can the documented snapshot restore the complete usable archive?
- Do all test and diagnostic entry points remain outside production storage?
- Are historical source identity comparisons robust to filesystem aliases?

### Minimum conditions before Workstream 2

Read-only onboarding analysis may proceed, but no mutating onboarding experiment
should use the permanent archive until these conditions are met:

1. Development, test, and production have explicit archive identities.
2. Writable root resolution fails closed before providers, logging, window
   persistence, or background ingestion can mutate an archive.
3. Debug and test launch configurations select disposable or explicitly
   approved non-production roots.
4. Every import, graph build, reset, historical archive, and attachment
   mutation derives authority from a complete, auditable operation-admission
   contract.
5. Production mutation authority is visible in diagnostics and attributable to
   an admitted process and operation.
6. A snapshot/recovery protocol has runtime evidence for databases, SQLite
   sidecars, overlay state, archive metadata, and the attachment policy.
7. Native instance admission, FDA continuity, environment selection, and
   concurrency behavior have been verified against real built artifacts.
8. Tests and maintenance tools are mechanically prevented from resolving the
   production archive unless an explicit, separately authorized production
   procedure exists.

The principal architectural asset is already present: persistent stores are
largely constructed through centralized seams. The missing protection is an
explicit production archive identity and an admission chain that those seams
must consume before any write becomes possible.
