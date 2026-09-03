---
tier: project
scope: feature-28-virgin-install-archive-regime
owner: agent-per-project
last_reviewed: 2026-09-02
source_of_truth: read-only-code-and-documentation-audit
related:
  - 24-FIRST-INSTALL-PRODUCTION-ARCHIVE-MARKER-BOOTSTRAP-CORRECTION.md
  - 26-FIRST-PRODUCTION-IMPORT-CHECKPOINT-CONFLICT-CORRECTION.md
  - 27-TESTER-REPORTED-ONBOARDING-PROBLEMS-DIAGNOSES-AND-FIXES.md
  - 21-LEGACY-TESTER-DATA-DELETION-AUTHORIZATION-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md
---

# Virgin Installation Archive-Regime Simplification Audit

## Decision

The current architecture can express four truthful top-level cases without a
broad redesign:

1. **Virgin**: no meaningful MessageLens installation exists;
2. **Current**: the current identity and coherent supported stores exist;
3. **Exact legacy tester installation**: the audited pre-source-scoped `4/3/3`
   fingerprint exists;
4. **Remediation**: meaningful state exists but is neither current nor the
   exact supported legacy generation.

The two tester failures had one architectural cause:

> Existing-installation protection remained callable before the system had
> positively established that there was existing MessageLens state to protect.

The production-marker correction and first-import correction fixed both
observed failures. The first-run path is nevertheless not yet mechanically
minimal. It still constructs the overlay-backed operation controller and
window-state persistence before installation classification, and the method
named as the fresh first import still contains a conditional route into
derived-data reset and checkpoint authority.

The smallest durable correction is dependency removal, not another state:

- classify from minimal read-only evidence before constructing ordinary
  persistent providers;
- make the proven Virgin import path create fresh derived stores directly;
- keep reset, checkpoint, Start Fresh, legacy deletion, and root-replacement
  recovery behind positive evidence that an existing operation or
  installation requires them.

No stop condition was reached. Native and Dart admission can represent an
empty root safely, and the separation can be completed without weakening
Current-installation preservation.

## Important Identity Distinction

A virgin installation does need an archive identity before MessageLens writes
its own durable data. It does **not** need a pre-existing identity.

The truthful sequence is:

```text
native code proves the build, environment, and canonical root
  -> native process lock claims that root for this process
  -> Dart agrees with the same canonical-root policy
  -> the marker store proves the root is bootstrap-empty
  -> ArchiveAdmissionService atomically creates the first current marker
  -> all later archive consumers receive immutable ArchiveAccessAuthority
```

The marker identifies the archive that this first run is about to create. Its
existence does not mean import has happened or that the installation is
Current. Installation classification remains a separate question.

The resulting invariants are:

> Missing marker plus a bootstrap-empty root is Virgin initialization, not
> corruption.

> Missing marker plus meaningful MessageLens-owned state is a Legacy or
> Remediation decision, never implicit Virgin initialization.

## Current Virgin Launch Call Graph

| Order | Component | Fact expected or established | Virgin-valid? | Archive-oriented work | Finding |
| ---: | --- | --- | --- | --- | --- |
| 1 | `MainFlutterWindow` native archive claim | Signed build identity, environment, bundle ID, canonical root | Yes | Root policy and single-process lock | Required |
| 2 | `main.dart::_admitArchive()` | Native and Dart resolve the same canonical root | Yes | `ExactCanonicalArchiveRootPolicy` and `ArchiveIdentityValidator` | Required |
| 3 | `FileSystemCompleteInstallationEraseStore.readPending()` | Whether an interrupted root-replacement transaction exists | Normally absent | Reads one reserved transaction file | Legitimate crash-convergence probe, but not Virgin initialization |
| 4 | `ArchiveAdmissionService.admit()` | Existing marker, or proof that the root is bootstrap-empty | Yes | Marker read/create; legacy inspection only for meaningful unmarked production roots | Required, with correct empty-root boundary |
| 5 | `ProviderContainer` | Immutable admitted archive authority | Yes | Makes persistent providers constructible | Required |
| 6 | `appLoggerProvider` | Admitted root is available | Yes | Creates/opens persistent `application_logs` before installation classification | Too early for the desired minimal classifier boundary |
| 7 | `windowStateServiceProvider.restoreWindowState()` | Overlay-backed window state may be read | No on a pristine root | Opens/creates `user_overlays.db` before installation classification | Incorrect ordering |
| 8 | `StartupApp` | Legacy restricted mode has already been excluded | Yes | Watches installation classification | Required |
| 9 | `messageLensInstallationStateProvider` | Durable Onboarding snapshot plus store evidence | Partly | First resolves `onboardingOperationControllerProvider`, which opens the overlay, then performs read-only store inspection | Circular persistence dependency |
| 10 | `MessageLensInstallationStateClassifier` | Store validity/counts and operation snapshot | Yes | Classifies valid empty derived stores as Virgin | Correct classification semantics |
| 11 | `App` / `OnboardingJourneyCoordinator` | Virgin installation requires Onboarding | Yes | Reads source readiness and owns the six-node Journey | Required |
| 12 | `startImportAndGraphBuild()` | Ready Episode plus fresh source-access proof | Yes | Admits `ArchiveMutationOperation.onboardingImport` | Required write serialization, not existing-archive preservation |
| 13 | `_prepareForFreshStartIfNeeded()` | Environment report may request derived-data reset | Not for proven Virgin | Can invoke `MessageDataResetService` and therefore production checkpoint policy | Wrong dependency inside the Virgin import method |
| 14 | graph/import orchestration | Apple sources can be read | Yes | Lazily creates and populates `macos_import_ss.db` and `working_ss.db` | Required first construction |
| 15 | internal durable verification | Import and graph reconcile | Yes | Prevents Start until durable proof succeeds | Required |

## Archive Machinery Reachable From Virgin

"Reachable" distinguishes code that actually runs, code that is conditionally
callable from the first-run graph, and code that is already mechanically
excluded.

| Component | Purpose | Reachable from Virgin? | Should be? | Why |
| --- | --- | --- | --- | --- |
| Native root validation and process lock | Establish one canonical archive root and exclusive process ownership | Yes, always | Yes | New data still needs a safe destination and one writer |
| Marker store and first marker creation | Establish current archive identity | Yes, always | Yes | This is initialization after empty-root proof |
| Pending root-replacement transaction read | Resume interrupted Complete Erase or legacy deletion | One constant-time read on every launch | Only as a pre-admission convergence guard | If the file exists, the root is not truly pristine Virgin state |
| Root-replacement recovery execution | Converge an interrupted destructive transaction | Only when durable transaction evidence exists | No for pristine Virgin; yes for interrupted replacement | Positive evidence, not missing state, authorizes it |
| Exact legacy tester inspector | Recognize the audited `4/3/3` generation | No for bootstrap-empty root | No | Admission calls it only for meaningful non-empty unmarked production roots |
| Production adoption services | Explicit one-time cutover/adoption tooling | No runtime call path; tool-only | No | Correctly absent from application startup |
| Persistent application logger | Durable diagnostics | Yes, before classification | Not before minimal classification | It creates archive state before the top-level case is known |
| Overlay-backed window restoration | Restore user window geometry | Yes, before classification | No | It opens/creates a current store before Virgin/Current/Remediation is known |
| Overlay-backed Onboarding operation controller | Read and write durable operation state | Yes, during classification | The snapshot evidence is needed; the live writable controller is not | Classification should inspect it read-only, then construct the controller for admitted Onboarding |
| Read-only SQLite installation evidence reader | Classify canonical stores | Yes | Yes, narrowly | This is evidence gathering, not archive mutation |
| Archive mutation coordinator | Serialize first import and protect unrelated readers | Yes, when Import is pressed | Yes | First import is real mutation even though it is not reset/preservation |
| Database-maintenance/resource-admission guards | Stop unrelated store opens during protected mutation | Yes through the coordinator | Yes | Correct concurrency protection for first import |
| `MessageDataResetService` | Remove enumerated rebuildable derived stores | Conditionally callable inside first import | No | Proven Virgin has nothing to reset |
| Verified checkpoint authority | Protect destructive mutation of existing production data | Indirectly reachable if first import calls reset | No | Empty-store construction has no preservation target |
| Automatic Onboarding recovery | Reset inconsistent derived state after a failed/partial attempt | Present in the same coordinator; dormant for coherent Virgin evidence | Only after positive partial-install evidence | It must not be inferred from ordinary Virgin readiness |
| Start Fresh | Preserve durable intent while resetting rebuildable stores | Not on ordinary Virgin startup | No | It is for positively classified incomplete or completed installations |
| Generalized Complete Erase action/presentation | Replace an entire owned root | Idle host/provider remains in application composition; no active Settings producer was found | No | The retired product surface should not burden Virgin composition |
| Archive checkpoint verification | Prove a checkpoint before selected destructive operations | Not for `onboardingImport`; only through an erroneous nested reset | No | The operation policy correctly exempts first import |
| Archive rotation | Move between archive roots/generations | No implementation path found | No | Not required |
| Marker migration | Upgrade a marker format | No path found | No | Only current format 1 is supported |
| Historical compatibility shims | Preserve exact legacy/delete behavior | Admission branch only for positive legacy evidence | No | Correctly excluded from an empty root |

## Initialization Versus Preservation

### Initialization

Initialization establishes new current state where none exists:

- create the first archive marker after empty-root proof;
- create `macos_import_ss.db` and `working_ss.db` when first import begins;
- create Onboarding's own durable operation record after Virgin has been
  classified and the user authorizes import;
- create supporting current stores only when their owning feature first needs
  them.

### Preservation or mutation

Preservation protects or transforms state already known to exist:

- checkpoint-gated reset or historical-source mutation;
- Start Fresh of an incomplete/current installation;
- exact legacy tester deletion;
- recovery of an interrupted root-replacement transaction;
- production archive adoption;
- destructive maintenance of established stores.

### Current conflations

1. `_prepareForFreshStartIfNeeded()` is called by the method that implements
   the fresh first import. Its name and behavior permit "fresh" to mean either
   construct empty stores or reset existing stores.
2. Installation classification obtains the Onboarding snapshot by constructing
   the writable, overlay-backed `OnboardingOperationSnapshotController`.
   Evidence inspection and operation ownership are therefore coupled.
3. Window restoration creates/opens the overlay before the installation case
   is known. A presentation convenience is currently ahead of admission
   classification.
4. Persistent logging begins before classification. This is less dangerous
   than opening the overlay, but it weakens the desired statement that minimal
   evidence selects the case before ordinary archive machinery is constructed.
5. The generalized Complete Erase implementation remains represented in
   access modes, startup UI, an idle application overlay, action dispatch, and
   providers despite the Settings product action having been removed.

First marker creation is **not** archive adoption. The code now correctly
separates them: only a bootstrap-empty root may receive a new marker, while a
meaningful unmarked root enters exact legacy inspection or fails closed.

## Marker And Archive Identity Findings

`FileSystemArchiveMarkerStore.canCreateInitialMarker()` accepts:

- an absent root;
- an empty root;
- a root containing only `MessageLens.instance.lock`.

`ArchiveAdmissionService` now uses that proof in production as well as
development. It creates the marker atomically and returns one immutable
`ArchiveAccessAuthority`. The legacy inspector is not consulted for an absent
or bootstrap-empty root.

This is the correct ownership split:

- native code owns signed process/environment/root proof and process locking;
- `ArchiveAdmissionService` owns first marker creation;
- `ArchiveAccessAuthority` carries the admitted identity;
- persistent providers consume that authority but do not invent or repair it;
- the installation classifier decides whether meaningful application state is
  Virgin, Current, or requires attention.

`ArchiveAdmissionFailure.missingMarker` remains in the enum but has no active
lib use. The active failure for meaningful unmarked non-legacy data is
`nonEmptyUnmarkedArchive`. The unused case is a cleanup candidate, not a
reason to alter current marker semantics.

## First-Import Reset Finding

The current operation policy is correct:

- `ArchiveMutationOperation.onboardingImport` does **not** require a verified
  checkpoint;
- `ArchiveMutationOperation.messageDataReset` does;
- first import still uses the mutation coordinator because it writes shared
  persistent stores and must exclude conflicting work.

Commit `4ed5b2b2` removed the erroneous unconditional reset. A coherent Virgin
report now continues directly to import and graph construction.

The remaining problem is structural. `_startImportAndGraphBuild()` always runs
an `environmentPreparation` stage that calls
`_prepareForFreshStartIfNeeded()`. That helper can still invoke
`MessageDataResetService` when the current environment report asks for reset.
The public action also accepts both `OnboardingReadyToImport` and
`OnboardingOperationFailed`.

The system therefore obeys the desired invariant in the tested coherent case,
but does not encode it mechanically:

> First import on a positively classified Virgin installation creates fresh
> derived stores and has no call edge to reset or checkpoint authority.

A failed or partial installation may legitimately need recovery, but that
decision belongs before re-entry to Ready, not inside the Virgin import
procedure.

## Legacy Tester Handoff

The exact April path is cleanly isolated:

```text
meaningful unmarked production root
  -> read-only exact 4/3/3 inspection
  -> restricted legacyTesterInstallDetected authority
  -> explicit Delete Old Data and Continue authorization
  -> legacyTesterInstallDeletion mutation capability
  -> crash-convergent root replacement
  -> new current marker and canonical Virgin verification
  -> transaction completion
  -> process relaunch
  -> ordinary Virgin Onboarding
```

Restricted legacy authority cannot open current persistent providers or admit
ordinary operations. The deletion transaction is removed on successful
completion. No legacy classification is carried into the new process.

The implementation reuses the low-level Complete Erase transaction/store and
virgin verifier. That is acceptable crash-convergence infrastructure. The
legacy path should retain this narrow reuse even if the dead generalized
Complete Erase presentation is removed.

## Start Fresh And Complete Erase Containment

### Start Fresh

Start Fresh is not evaluated on ordinary Virgin startup. It is available only
for classified resumable/abandoned installations or the completed-installation
advanced action. It remains mutation-authorized and verifies Virgin state
after deleting only enumerated rebuildable data.

It does, however, still resolve the retired required-sources Presence Schedule
repository and supersede its run. Current production Onboarding no longer uses
that Schedule as presentation or coordination authority. This dependency is
historical coupling and should be removed after a focused preservation review.

### Complete Erase

The generalized Settings action is no longer offered, but most of its product
surface remains:

- `ArchiveAccessMode.completeEraseOnly`;
- `_EraseOnlyStartup` in `main.dart`;
- Complete Erase action/provider/presentation overlay;
- sidebar action intent and dispatcher branch;
- complete-erasure service/provider;
- the mutation operation and its access-mode branch.

No production constructor of `ArchiveAccessMode.completeEraseOnly` was found.
The idle overlay is still mounted by `MacosAppShell`, but expensive erasure is
not resolved or run without a request. These are historical cruft, not the
cause of the two tester failures.

The following low-level pieces remain necessary for the exact legacy path and
interruption convergence even if the generalized product surface is deleted:

- the durable root-replacement transaction model/store;
- startup's one pending-transaction probe;
- safe root erasure and first-identity installation;
- canonical Virgin verification;
- relaunch after authority replacement.

## Installation Classifier Findings

The current classifier's five cases are:

- `virgin`;
- `resumable`;
- `completed`;
- `abandoned`;
- `remediationRequired`.

The exact legacy case is intentionally outside this enum. Archive admission
must recognize it before any current provider can open or migrate the old
stores.

The five cases can project the desired four product-level cases without adding
another state:

| Product case | Current representation |
| --- | --- |
| Virgin | `MessageLensInstallationStateKind.virgin` under full current authority |
| Current | `completed` under full current authority |
| Exact legacy | `ArchiveAccessMode.legacyTesterInstallDetected` before current-store classification |
| Remediation | `resumable`, `abandoned`, or `remediationRequired`, with their current bounded recovery choices |

`resumable` and `abandoned` still govern real Start Fresh/retry behavior. They
are not dead today. They may later become typed reasons within one Remediation
product case, but collapsing them is cleanup and must not erase their different
authorization semantics.

The classifier correctly treats valid empty import/graph files as Virgin by
contents rather than file existence. It also fails closed for unreadable or
unsupported current stores, completed snapshots that disagree with durable
data, and historical sources in an incomplete installation.

Its current dependency is the larger defect: `messageLensInstallationState`
first awaits the live overlay-backed operation controller, then asks the
read-only evidence reader to inspect stores. Classification is therefore not
strictly read-only in construction even though its SQLite evidence queries are
read-only.

## Database And Directory Creation Ownership

| Artifact | Current creator/owner | Needed before Onboarding? | Current authority | Desired Virgin behavior |
| --- | --- | --- | --- | --- |
| `.messagelens-archive.json` | `ArchiveAdmissionService` through `FileSystemArchiveMarkerStore` | Yes | Empty-root proof plus native/Dart root identity | Create atomically before durable app writes |
| `MessageLens.instance.lock` | Native startup | Yes | Canonical native root and process ownership | Create/acquire before Dart admission |
| `macos_import_ss.db` | Central `sourceScopedImportDatabaseProvider` / `ImportDatabase.open` | No | Full archive access plus persistent-store resource admission | Create lazily inside admitted first import |
| `working_ss.db` | Central `driftConversationGraphDatabaseProvider` | No | Full archive access plus graph resource admission | Create lazily inside admitted graph build |
| `user_overlays.db` | Central `overlayDatabaseProvider` | Not for minimal installation classification | Full archive access plus persistent-store resource admission | Inspect any existing snapshot read-only; create only after Virgin/Current route is chosen |
| `presence.db` | Central `presenceDatabaseProvider` | No | Full archive access plus persistent-store resource admission | Remain absent unless a live Presence client actually requires it |
| `application_logs/` | `appLoggerProvider` / `LogFileWriter` | No for top-level classification | Full archive access | Use ephemeral diagnostics until case selection, then start persistent logging |
| `attachment_archive/` | Attachment archival workflow; provider only resolves the path | No | Admitted archive plus owning attachment operation | Create only when a payload is preserved; never as classifier evidence |

No dedicated generalized bootstrap framework is justified. Existing central
providers already own store creation. The required change is when they become
reachable.

## Startup Provider Graph Finding

The current effective ordering is:

```text
archive claim/root/marker authority
  -> ProviderContainer
  -> persistent logger
  -> window-state service
      -> overlay database open/create
  -> StartupApp
  -> installation-state provider
      -> live Onboarding operation controller
          -> same overlay database
      -> read-only import/graph/overlay/Presence evidence
  -> classify
```

The desired ordering is:

```text
archive claim/root/marker authority
  -> minimal read-only installation evidence
  -> classify Virgin / Current / Remediation
  -> construct only that case's writable providers and presentation
```

The exact legacy path remains earlier because it must be resolved before
current-store evidence readers are allowed to touch an unmarked root.

The immediate provider-graph correction is not to invent a second database or
container. It is to give classification a read-only operation-snapshot reader
and defer window-state restoration until after current full-mode
classification. The existing writable operation controller can then initialize
inside the admitted Onboarding or Current application path.

## Desired Top-Level Paths

### Virgin

```text
native build/environment/root proof
  -> process lock
  -> bootstrap-empty proof
  -> create first current marker/identity
  -> minimal read-only classification = Virgin
  -> construct Onboarding persistence/presentation
  -> Messages -> History -> Contacts -> Ready
  -> explicit Import
  -> onboardingImport mutation authority
  -> create/populate fresh import and graph stores
  -> mandatory internal durable verification
  -> Start
  -> normal application
```

No reset, checkpoint, adoption, migration, legacy reasoning, or recovery
transaction is created by this path.

### Current

```text
native build/environment/root proof
  -> validate existing current marker
  -> minimal read-only classification = Current
  -> restore current preferences/window state
  -> open ordinary providers lazily
  -> normal application
```

Maintenance, Start Fresh, historical archive mutation, and attachment work
remain available only after explicit feature intent and their existing
authorities.

### Exact Legacy Tester Installation

```text
native production root proof
  -> missing marker plus meaningful files
  -> exact read-only 4/3/3 fingerprint
  -> restricted legacy authority
  -> explicit human deletion authorization
  -> crash-convergent owned-root replacement
  -> verified Virgin identity
  -> relaunch into the ordinary Virgin path
```

### Remediation

```text
native/root/marker proof as applicable
  -> meaningful state detected
  -> exact legacy proof fails or current read-only evidence is inconsistent
  -> fail closed or show bounded typed recovery
  -> no ordinary provider silently opens, migrates, resets, or adopts the state
```

Resumable and abandoned operation evidence may choose different bounded
recovery actions inside this case. They do not require more top-level startup
categories.

## Proposed Architecture Tripwires

1. A bootstrap-empty production root is admitted without a pre-existing
   marker and receives exactly one new current marker.
2. A meaningful unmarked root can never receive an initial marker.
3. Exact legacy inspection is never called for a bootstrap-empty root.
4. Minimal installation classification cannot import a writable database
   provider or create a canonical database file.
5. Window-state restoration cannot occur before full-mode installation
   classification.
6. A positively classified Virgin first import has no call edge to
   `MessageDataResetService`.
7. `onboardingImport` never requires checkpoint authority.
8. Reset/checkpoint operations require positive meaningful-state or durable
   failed-operation evidence; absence is never sufficient.
9. Legacy deletion terminates in the same marker-plus-no-consequential-data
   Virgin classification as a brand-new install.
10. Start Fresh and generalized Complete Erase actions cannot influence or be
    offered by ordinary Virgin startup.
11. Current supported installations retain their marker, preservation stores,
    attachment archive, and maintenance protections unchanged.
12. Unknown or damaged meaningful state remains fail-closed.
13. The pending root-replacement probe may trigger work only from a valid
    durable transaction; absence performs no recovery action.
14. Persistent import, graph, overlay, and Presence providers remain incapable
    of opening under restricted legacy authority.

## Cruft Candidates

| Candidate | Why it exists | Still needed for Current? | Needed for Virgin? | Recommendation |
| --- | --- | --- | --- | --- |
| `ArchiveAccessMode.completeEraseOnly` | Generalized Complete Erase startup | No active production constructor found | No | Remove after confirming no support-only caller; retain the low-level transaction store used by legacy deletion |
| `_EraseOnlyStartup` | Presents generalized erase-only admission | No active authority can select it | No | Delete with the dead access mode |
| Complete Erase action, overlay, sidebar intent, dispatcher case, and service composition | Former Settings product surface | Settings no longer offers it | No | Remove product surface; preserve/refactor only low-level root-replacement primitives needed by legacy deletion |
| `ArchiveAdmissionFailure.missingMarker` | Earlier blanket missing-marker rejection | No active lib use | No | Remove after focused enum/test audit |
| Writable operation controller inside installation classification | Convenient snapshot access | Snapshot evidence remains needed | No | Replace with a read-only snapshot evidence seam; construct controller after classification |
| Window restoration before classification | Historical startup ordering | Yes, after Current is proven | No | Defer until the admitted case is known |
| Persistent logger before classification | Capture all post-admission events | Useful after case selection | No | Use ephemeral preclassification diagnostics, then initialize durable logging |
| `_prepareForFreshStartIfNeeded()` inside first import | Shared Virgin/retry preparation | Recovery may still need reset | No | Remove from Virgin import; route repair before Ready through an explicit existing recovery path |
| Automatic recovery in the same coordinator branch as ordinary Virgin evidence | Earlier retry repair | Yes for proven partial failures | No for coherent Virgin | Keep behavior but gate it from positive partial-install evidence, not generic Onboarding presence |
| Retired required-sources Presence Schedule mutation in Start Fresh | Supersede the previous experimental Journey | Not for current production Onboarding | No | Remove after verifying no retained durable contract requires it |
| `resumable` and `abandoned` as top-level enum cases | Distinct safe retry versus Start Fresh eligibility | Behaviorally yes | No | Keep for now; later consider typed Remediation reasons without changing authority |
| Production adoption implementation exports | Completed cutover tooling | Tool/support workflow only | No | Keep tool-only; do not import into runtime startup |
| Old database migration histories | Development evolution and diagnostic compatibility | Current schema authority still references them | No | Follow Response 23's separate post-release baseline plan; do not mix with Virgin simplification |

## Smallest Implementation Sequence

### Slice 1: Make Virgin first import structurally fresh

- Split the fresh import operation from failed/partial-install recovery.
- Remove `_prepareForFreshStartIfNeeded()` from the positively classified
  Virgin `Ready -> Import` path.
- Ensure any report requiring reset is resolved into a recovery/remediation
  Episode before Ready can be constructed.
- Add a dependency-boundary test proving the Virgin import call graph cannot
  invoke reset and a behavior test proving production first import needs no
  checkpoint.

This is the most important mechanical correction. It deletes the call edge
that caused the second tester failure.

### Slice 2: Classify before writable provider construction

- Read the Onboarding snapshot through the existing read-only installation
  evidence boundary rather than constructing
  `onboardingOperationControllerProvider`.
- Move window-state restoration after the full-mode classification decision.
- Start persistent archive logging after case selection; retain only ephemeral
  failure reporting before it.
- Add tests proving pristine classification creates no database files and that
  Remediation evidence is not migrated by observation.

### Slice 3: Remove dead generalized Complete Erase surface

- Delete the unconstructible `completeEraseOnly` access mode and
  `_EraseOnlyStartup`.
- Delete the idle overlay/action/intent/dispatcher product path if no live
  producer remains.
- Keep the root-replacement transaction/store and verifier under exact legacy
  deletion ownership.
- Keep startup transaction convergence, but name/document it as interrupted
  root-replacement recovery rather than a live generalized product mode.

### Slice 4: Retire old Onboarding experiment coupling

- Remove the required-sources Presence Schedule dependency from Start Fresh
  after proving current Onboarding owns all active state.
- Reassess `resumable`/`abandoned` only after their distinct recovery
  authorities are covered by tests.
- Perform schema-migration archaeology separately under Response 23's plan.

No new coordinator, persistence layer, archive state, or bootstrap framework
is required by these slices.

## Release Urgency

### Immediate tester blockers

Both known Virgin tester blockers are already corrected:

- `643b27a8` allows a bootstrap-empty production root to receive its first
  marker while preserving fail-closed handling for meaningful unmarked state;
- `4ed5b2b2` stops coherent Virgin first import from unconditionally invoking
  checkpoint-gated reset.

Those corrections are documented in Responses 24 and 26 and released as
`0.2.100+118` and `0.2.101+119` respectively. This audit found no third point
failure that must be patched before the tester retries `0.2.101+119`.

### Near-term architectural correction

Slices 1 and 2 should be completed before describing Virgin startup as
mechanically independent from existing-archive machinery. They prevent future
environment-report changes or provider-order changes from recreating the same
class of tester failure.

### Historical cleanup

Slices 3 and 4 remove dead Complete Erase presentation/state and retired
Presence experiment coupling. They reduce conceptual surface but do not block
the corrected tester build.

## Verification

This audit was read-only with respect to application and archive data. It did
not launch MessageLens, open a production/tester archive, run import, reset,
Start Fresh, Complete Erase, adoption, or legacy deletion, or change any
schema, marker, archive identity, or payload.

Verification completed after the documentation pass:

- 89 focused archive-admission, installation-classifier, startup,
  Onboarding-Journey, legacy-inspection, Start Fresh, and durable-operation
  tests passed;
- all 385 architecture tripwires passed;
- `git diff --check` passed;
- no trailing whitespace was found in the files changed by this audit.
