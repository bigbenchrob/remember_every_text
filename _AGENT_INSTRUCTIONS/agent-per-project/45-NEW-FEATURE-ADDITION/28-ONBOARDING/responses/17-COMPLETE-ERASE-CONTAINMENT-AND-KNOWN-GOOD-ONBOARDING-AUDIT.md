---
tier: project
scope: complete-erase-containment-audit
owner: agent-per-project
last_reviewed: 2026-08-28
source_of_truth: audit-record
---

# Complete Erase Containment And Known-Good Onboarding Audit

## Decision

**Containment Option A: keep Complete Erase.**

Prompt 16 changes ordinary runtime in a few narrow, constant-time ways, but it
did not introduce the operation responsible for the observed 45-60 second
startup delay. Complete Erase remains dormant until explicit authorization,
except for:

- one root-level pending-transaction existence check during admission;
- one access-mode branch;
- constant-time mutation-admission guards on persistent store construction;
- registration of resources that have already been opened;
- an idle overlay host and one Settings action descriptor.

No recursive archive scan, attachment inventory, erase qualification, hashing,
database integrity check, or deletion runs on ordinary marked startup.

The measured delay is the pre-existing installation evidence reader. It opens
the four canonical stores read-only and runs `PRAGMA quick_check(1)`
sequentially in a worker isolate before the normal application is admitted.
That reader, its provider, and its classifier are byte-for-byte unchanged
between the known-good commit and the Complete Erase commit.

No code correction was made in this audit.

## Anchors And Audit Isolation

| Meaning | Commit |
| --- | --- |
| Feature 28 known-good release boundary | `460d571e` |
| Complete Erase implementation | `a35f3edb` |

The audit compared those two committed trees. Focused tests were run from a
clean extracted `a35f3edb` snapshot because the working tree also contains
uncommitted responsiveness work and a stopped, incomplete classifier
experiment. Neither was treated as evidence about Prompt 16.

## Production Diff Classification

Generated Riverpod files are listed with their handwritten owner because their
committed changes are registration or source-hash consequences, not separate
runtime decisions.

| File | Change | Runtime reachability | Ordinary-path risk |
| --- | --- | --- | --- |
| `CHANGELOG.md`, `pubspec.yaml` | Release record and version | Metadata only | None |
| `archive_environment/application.dart` | Exports new contracts | Compile-time barrel | None |
| `archive_admission_service.dart` | Adds erase-only admission for unmarked, non-empty production roots | Every launch; marked roots take the pre-existing marker path | Low; no new scan for a marked root |
| `archive_mutation_coordinator_provider.dart` and generated file | Adds erase-only operation guard | Every mutation request; idle default unchanged | Low; one in-memory authority check |
| `archive_owned_resource_registry_provider.dart` and generated file | Tracks resources after they open | Ordinary store/logger construction | Low; map registration only |
| `complete_installation_erase_store.dart` | Store contract | Complete-Erase-only | None before authorization |
| `archive_environment/domain.dart` | Exports new domain types | Compile-time barrel | None |
| `archive_access_authority.dart` | Adds `full` and `completeEraseOnly` modes | Every authority consumer | Low; constant-time guard |
| `archive_mutation_operation.dart` | Adds operation and persistent-store resource action | Shared coordinator policy | Low; default state remains unlocked |
| `complete_installation_erase_transaction.dart` | Durable transaction model | Complete-Erase-only or pending recovery | None on an ordinary launch without a pending file |
| `archive_environment/feature_level_providers.dart` | Exports registry | Compile-time barrel | None |
| `archive_environment/infrastructure.dart` | Exports erase store | Compile-time barrel | None |
| `file_system_complete_installation_erase_store.dart` | Safe root validation, recursive erase, virgin install, pending read | Recursive work is Complete-Erase-only; startup calls only `readPending` | Low on ordinary startup: one file existence check |
| `persistent_database_providers.dart` and generated file | Adds admission checks and opened-resource registration | Ordinary database opens | Low; no enumeration, hashing, integrity check, or eager open |
| `app_logger.dart` and generated file | Registers an already-created writer and suppresses it for erase-only admission | Ordinary marked startup | Low; one map registration |
| `macos_app_shell.dart` | Mounts idle Complete Erase overlay host | Normal application tree | Low; watches an idle in-memory presentation provider |
| `advanced_start_fresh_action_provider.g.dart` | Generated source hash | Provider registration | None |
| `application_relauncher.dart` | Relaunch contract | Complete-Erase-only | None before authorization |
| `complete_installation_erase_action_provider.dart` and generated file | Confirmation and operation presentation | Provider is idle until explicit action | None before request |
| `complete_installation_erase_service.dart` | Mutation-authorized erase orchestration | Complete-Erase-only | None before authorization |
| `complete_installation_erase_service_provider.dart` and generated file | Composes store, registry, verifier, and relauncher | Lazily resolved by erase execution | None before request |
| `complete_installation_erase_virgin_verifier.dart` | Verifies post-erase state | Complete-Erase-only and pending recovery | None on an ordinary launch |
| `message_lens_installation_state_provider.g.dart` | Generated source hash only | Startup provider registration | No semantic change |
| `onboarding_journey_coordinator_provider.g.dart` | Generated source hash only | Coordinator registration | No semantic change |
| `complete_installation_erase_presentation.dart` | Typed operation surface state | Idle provider on normal runtime | None |
| `onboarding/feature_level_providers.dart` | Exports new action/service | Compile-time barrel | None |
| `macos_application_relauncher.dart` | Method-channel relaunch implementation | Complete-Erase-only | None before authorization |
| `complete_installation_erase_authorization_dialog.dart` | Explicit destructive confirmation | Complete-Erase-only | None before user action |
| `complete_installation_erase_overlay.dart` | Full-window operation/failure surface | Host is mounted; visible branch requires non-idle action state | Low; idle branch is `SizedBox.shrink()` |
| `sidebar_action_dispatcher.dart` and generated file | Dispatches new intent | Shared dispatcher, new case only | None unless action selected |
| `sidebar_action_intent.dart` | Adds typed intent | Shared type set | None |
| `reset_message_data_settings_resolver.dart` and generated file | Adds explanatory copy and action descriptor | Opening Settings | Low; no classifier, root inventory, or service resolution |
| `lib/main.dart` | Pending recovery check, erase-only startup, complete-erase startup choices | Shared startup file | Low for marked roots; one pending-file check and access-mode branches |
| `MainFlutterWindow.swift` | Relaunch method preserving development root | Method channel only | None unless invoked |

All other files in `460d571e..a35f3edb` are documentation or tests.

## Ordinary Startup Call Graph

For the completed, marked clone, startup is:

```text
native claim
  -> canonical-root validation
  -> read pending Complete Erase transaction file
  -> read and validate existing archive marker
  -> full ArchiveAccessAuthority
  -> ProviderContainer
  -> logger and window-state restoration
  -> StartupApp
  -> onboarding operation snapshot from overlay.db
  -> MessageLens installation evidence reader
       -> macos_import_ss.db quick_check/count/schema evidence
       -> working_ss.db quick_check/count/schema evidence
       -> user_overlays.db quick_check/schema evidence
       -> presence.db quick_check/schema evidence
  -> installation classifier
  -> completed-installation application
```

Prompt 16 adds only the pending-file read and constant-time admission/resource
bookkeeping to this marked-root path. The startup installation provider,
classifier, and SQLite reader have no committed diff between the anchors.

The evidence reader uses `Isolate.run`, so its database work does not execute on
Flutter's presentation isolate. It nevertheless gates admission of the normal
application, which explains the grey spinner until it finishes.

## Expensive Work Findings

The expensive Complete Erase implementation is correctly dormant:

- recursive descendant validation runs only after explicit erase execution;
- recursive deletion runs only after explicit erase execution or recovery from
  a durable pending erase;
- virgin-state verification runs only after deletion;
- no attachment archive enumeration occurs during ordinary startup;
- no hash work is introduced by Prompt 16;
- no eligibility or ownership inventory runs merely by opening Settings;
- no pending erase transaction exists in the validation clone.

The startup cost is instead the pre-existing sequential database integrity
inspection. It is intentionally not optimized in this containment audit.

## Settings And Normal Data Loading

Opening Settings constructs descriptive cassette data. It does not resolve the
Complete Erase service, inspect the root, classify installation state, or scan
attachments. The destructive service is reached only after the typed action is
selected and authorization succeeds.

Prompt 16 did add constant-time guards and resource registration to ordinary
database providers. Those providers remain keep-alive, do not reopen merely
because the registry exists, and are not invalidated unless Complete Erase is
executed. The mutation coordinator still builds in its prior unlocked state.
No Complete Erase lock can remain active when the action has never run.

The observed contact/message delay is therefore outside Prompt 16's committed
behavior. Runtime logs show live graph/attachment maintenance against the same
external archive after startup, including an attachment operation lasting
roughly 36 seconds. That is evidence of storage contention on the validation
environment, not evidence that Complete Erase reopens or serializes contact
reads. The exact first-contact render was not instrumented, so this audit does
not claim a more precise attribution.

## Clone Evidence

Read-only inspection of:

`/Volumes/WD_ELEMENTS/ONBOARDING_PROFILING/2026-08-27-complete-erase-validation`

established:

- the root is a marked development archive;
- archive UUID: `ba1b6b67-48d4-4773-a509-4a91cdb79af7`;
- no pending Complete Erase transaction exists;
- the zero-byte process lock is the expected single-instance lock artifact;
- total root size is approximately 37 GB;
- `attachment_archive/` is approximately 36 GB with 26,328 files;
- active database sizes are approximately 144 MB import, 48 MB graph,
  15 MB overlay, and 160 KB Presence;
- the root is on external APFS volume `WD_ELEMENTS` mounted with `noowners`;
- the root has a normal `com.apple.provenance` extended attribute;
- no unusual permission or marker defect was found.

The startup reader does not scan the 26,328 attachment files. The clone matters
because its canonical databases are read from the external volume and subjected
to full quick checks. CleanMyMac or Spotlight interference is possible but was
not proven and is not needed to explain the measured variability.

## Comparative Timing Evidence

The validation clone's durable log records one installation evidence inspection
per launch:

| Launch UTC | Inspection duration | Classification |
| --- | ---: | --- |
| 2026-08-28 15:30:07 | 14,525 ms | completed |
| 2026-08-28 15:47:59 | 37,416 ms | completed |
| 2026-08-28 16:24:38 | 34,078 ms | completed |
| 2026-08-28 16:26:51 | 51,198 ms | completed |

The formerly smooth `2026-08-24-first-import-observer-fix` root is no longer a
valid completed-installation comparator: it is now an 83 MB virgin/reset root
with tiny canonical databases. Its recent inspections took 4-66 ms. Earlier
logs show a 371 ms inspection, but the prior database sizes are no longer
available. An A/B launch would therefore compare different installation states.

A detached `460d571e` launch was not performed. It would start normal live
monitoring and could mutate the clone. More importantly, the exact classifier
provider and reader responsible for the measured delay are identical at both
commits, so such a run is unnecessary for the Prompt 16 attribution.

## Attribution And Release Recommendation

Prompt 16 touches shared startup and persistent-provider code, but only through
small guards and bookkeeping. It does not add or repeat the measured classifier
work and does not activate maintenance authority without an explicit action.

The completed clone explains the startup symptom as a production-shaped data
set on an external volume being subjected to the pre-existing exhaustive
startup classifier. It also presents substantial post-startup disk work. This
is a real responsiveness concern, but it is not a Complete Erase containment
failure and must not be used to redesign Complete Erase in this audit.

Recommendation:

1. retain Complete Erase in the release;
2. retain the external one-time support procedure as a fallback for the three
   legacy testers until manual destructive validation is completed;
3. do not run Complete Erase on the clone until the separate responsiveness
   worktree is coherent and reviewed;
4. address startup evidence inspection, if desired, as an independently scoped
   installation-classification performance task.

## Prompt 15 Working-Tree Finding

The uncommitted Prompt 15 edit is **not** only the approved six-node correction.
The committed file is the 34-line six-node correction. The working copy replaces
it with approximately 700 lines of the Complete Erase design prompt
(`697` additions and `25` deletions). It should not be committed as Prompt 15.
Prompt 16 also has an uncommitted documentation rewrite and should be reviewed
separately. Neither documentation edit was changed by this audit.

## Verification

Run from a clean extracted `a35f3edb` snapshot:

- Complete Erase architecture boundary test: passed;
- installation-state classifier tests: passed;
- startup installation-state surface tests: passed;
- architecture tripwires (`385` tests): passed.

The current working tree also passes `git diff --check`.

No app was launched, no Complete Erase operation was run, no archive was
modified, no code correction was made, and no commit was created.
