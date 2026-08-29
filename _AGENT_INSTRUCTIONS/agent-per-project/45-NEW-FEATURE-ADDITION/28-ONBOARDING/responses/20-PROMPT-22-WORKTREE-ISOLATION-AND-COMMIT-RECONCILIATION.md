---
tier: project
scope: prompt-22-worktree-isolation
owner: agent-per-project
last_reviewed: 2026-08-29
source_of_truth: reconciliation-record
links:
  - ../prompts/23-WORKTREE-CLEANUP.md
  - ./19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md
---

# Prompt 22 Worktree Isolation And Commit Reconciliation

## Result

The worktree contained three coherent bodies of intentional work and two
proven stale experiments. They were separated without discarding any unknown
hunk:

1. the completed-installation responsiveness correction;
2. the intervening Complete Erase and legacy-signature audit history;
3. the Prompt 22 legacy-tester recognition implementation.

The accidental Prompt 15 and Prompt 16 replacements were restored to their
committed documents. The later unowned startup-admission integrity experiment
was also restored. No archive, database, source data, or tester installation
was opened or mutated during reconciliation.

## Committed Baseline

The dirty worktree began at:

```text
a35f3edb add complete installation erase
```

The relevant preceding release boundary was:

```text
460d571e Close Feature 28 onboarding conformance
```

No commit followed `a35f3edb` before this reconciliation. The branch and its
remote both pointed to `a35f3edb`.

## Initial Dirty-File Inventory

| File | Diff summary | Likely origin | Prompt 22 required? | Action |
| --- | --- | --- | --- | --- |
| `CHANGELOG.md` | Responsiveness and legacy-recognition release notes | Mixed earlier correction / Prompt 22 | Mixed | Split by hunk across the two implementation commits |
| `28-ONBOARDING/README.md` | Added audit and Prompt 22 records; revised current status | Mixed audit history / Prompt 22 | Mixed | Split index history from Prompt 22 status |
| `prompts/15-FEATURE-28-FINAL-ONBOARDING-RELEASE-READINESS-AND-CONFORMANCE.MD` | Replaced the approved six-node correction with Complete Erase material | Stale accidental replacement | No | Restored from `HEAD` |
| `prompts/16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA.MD` | Replaced Prompt 16 with the later containment-audit prompt | Stale accidental replacement | No | Restored from `HEAD`; audit retained in Response 17 |
| `DOCUMENTATION_PASS_LOG.md` | Responsiveness and Prompt 22 entries | Mixed earlier correction / Prompt 22 | Mixed | Split by section across commits |
| `archive_environment/application.dart` | Exported the inspector contract | Prompt 22 | Yes | Prompt 22 commit |
| `archive_admission_service.dart` | Replaced broad unmarked-root authority with typed inspection | Prompt 22 | Yes | Prompt 22 commit |
| `archive_mutation_coordinator_provider.dart` | Denied every mutation under recognition-only authority | Prompt 22 | Yes | Prompt 22 commit |
| `archive_environment/domain.dart` | Exported typed inspection result | Prompt 22 | Yes | Prompt 22 commit |
| `archive_access_authority.dart` | Added restricted recognition-only mode | Prompt 22 | Yes | Prompt 22 commit |
| `archive_admission_exception.dart` | Added typed inspection-failure admission result | Prompt 22 | Yes | Prompt 22 commit |
| `archive_environment/infrastructure.dart` | Exported the read-only SQLite inspector | Prompt 22 | Yes | Prompt 22 commit |
| `chat_db_change_monitor_provider.dart` | Released graph authority before attachment preservation | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `panel_widget_providers.dart` | Used native sidebar flow during transient missing Track matrix | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `message_lens_installation_evidence_reader.dart` | Added startup/comprehensive inspection modes | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `message_lens_installation_state_classifier.dart` | Allowed startup classification without derived-store quick checks | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `message_lens_installation_state_provider.dart` | Requested the reduced startup inspection mode | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `message_lens_installation_state.dart` | Added integrity-status and inspection-mode model | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `sqlite_message_lens_installation_evidence_reader.dart` | Skipped derived-store quick checks at startup | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `filesystem_attachment_archive_file_store.dart` | Rejected unsafe extensions before hashing and moved hashing off the UI isolate | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `sqlite_graph_attachment_archive_candidate_reader.dart` | Excluded opaque NULL/blank-MIME payloads from live preservation | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `lib/main.dart` | Injected inspector and projected restricted startup view before store providers | Prompt 22 | Yes | Prompt 22 commit |
| `pubspec.yaml` | Version `0.2.98+116` | Earlier responsiveness release metadata | No | Commit `3926ec6d` |
| `forbidden_imports_test.dart` | Allowed only the bounded inspector dependencies and terminology | Prompt 22 | Yes | Prompt 22 commit |
| `archive_admission_service_test.dart` | Proved positive recognition and fail-closed unmarked roots | Prompt 22 | Yes | Prompt 22 commit |
| `archive_mutation_coordinator_provider_test.dart` | Proved recognition grants no mutation | Prompt 22 | Yes | Prompt 22 commit |
| `chat_db_change_monitor_provider_test.dart` | Proved graph authority ends before attachment work | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `panel_widget_providers_test.dart` | Proved native flow without a mounted Track matrix | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `message_lens_installation_state_classifier_test.dart` | Adapted tests to the unowned integrity-mode model | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `start_fresh_service_test.dart` | Adapted fake reader to the unowned inspection mode | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `sqlite_message_lens_installation_evidence_reader_test.dart` | Adapted assertions to the unowned integrity-mode model | Unowned post-STOP experiment | No | Restored from `HEAD` |
| `sqlite_graph_attachment_archive_candidate_reader_test.dart` | Proved opaque live candidates are excluded | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `startup_installation_state_surface_test.dart` | Proved restricted startup does not read current stores | Prompt 22 | Yes | Prompt 22 commit |
| `prompts/18-STOP-AND-AUDIT-COMPLETE-ERASE.md` | Saved containment-audit prompt | Earlier intentional documentation | No | Commit `ec6687fb` |
| `prompts/19-DISK-SPACE-AUDIT.md` | Saved internal-disk audit prompt | Earlier intentional documentation | No | Commit `ec6687fb` |
| `prompts/20-RECOMMENDED-DELETION.md` | Saved bounded internal cleanup prompt | Earlier intentional documentation | No | Commit `ec6687fb` |
| `prompts/21-LEGACY-INSPECTION.md` | Saved read-only tester-build audit prompt | Earlier intentional documentation | No | Commit `ec6687fb` |
| `prompts/22- PRE-INSTALL-INSPECTION-DELETION.md` | Saved Prompt 22 implementation instruction | Prompt 22 | Yes | Prompt 22 commit |
| `prompts/23-WORKTREE-CLEANUP.md` | Saved this reconciliation instruction | Current cleanup record | No | Prompt 22 reconciliation commit |
| `responses/17-COMPLETE-ERASE-CONTAINMENT-AND-KNOWN-GOOD-ONBOARDING-AUDIT.md` | Read-only containment audit | Earlier intentional documentation | No | Commit `ec6687fb` |
| `responses/17-COMPLETE-ERASE-VALIDATION-RESPONSIVENESS-CORRECTION.md` | Runtime responsiveness correction record | Earlier responsiveness correction | No | Commit `3926ec6d` |
| `responses/18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md` | Read-only distributed-build forensic audit | Earlier intentional documentation | No | Commit `ec6687fb` |
| `responses/19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md` | Prompt 22 implementation record | Prompt 22 | Yes | Prompt 22 commit |
| `legacy_tester_install_inspector.dart` | Inspector contract and rejecting default | Prompt 22 | Yes | Prompt 22 commit |
| `legacy_tester_install_inspection.dart` | Typed inspection outcomes | Prompt 22 | Yes | Prompt 22 commit |
| `read_only_sqlite_legacy_tester_install_inspector.dart` | Exact read-only `4/3/3` fingerprint implementation | Prompt 22 | Yes | Prompt 22 commit |
| `legacy_tester_install_detected_view.dart` | Non-destructive restricted startup presentation | Prompt 22 | Yes | Prompt 22 commit |
| `legacy_tester_install_inspection_boundary_test.dart` | Architectural dependency and mutation tripwires | Prompt 22 | Yes | Prompt 22 commit |
| `read_only_sqlite_legacy_tester_install_inspector_test.dart` | Positive, negative, corruption, and byte-fidelity tests | Prompt 22 | Yes | Prompt 22 commit |

No hunk remained in category D after comparison with the commits, saved prompts,
response records, tests, and the chronological stop boundary.

## Stale Repairs

### Prompt 15

The committed file is the approved correction:

```text
Messages -> History -> Contacts -> Ready -> Import -> Start
```

The working copy had replaced it with approximately 700 lines of Complete
Erase design material. It was restored exactly from `HEAD`; the six-node
document was not rewritten.

### Prompt 16

The working copy contained the later Complete Erase containment-audit prompt.
The original Prompt 16 was restored exactly from `HEAD`. The audit remains in
its proper Response 17 file.

### Startup integrity experiment

The uncommitted inspection-mode cluster made startup skip `quick_check` for the
two derived stores. It postdated the responsiveness record, had no owning
prompt after the explicit stop, and contradicted that record's invariant that
no integrity requirement was removed. The complete cluster and only its test
adaptations were restored from `HEAD`.

## Prompt 22 Patch Boundary

The isolated Prompt 22 patch contains only:

- the typed inspection result and inspector contract;
- the exact read-only SQLite legacy fingerprint;
- archive admission and restricted authority changes;
- mutation denial for the recognition-only state;
- the bounded startup presentation;
- required exports and startup composition;
- focused and architecture tests;
- Prompt 22, Response 19, index, changelog, and documentation-log records;
- this reconciliation record.

It does not contain Complete Erase execution, deletion, migration, current
store opening, tester data access, or the earlier responsiveness runtime work.

## Commit Strategy

| Commit | Purpose |
| --- | --- |
| `3926ec6d` | Preserve the earlier verified completed-archive responsiveness correction |
| `ec6687fb` | Preserve the intervening read-only audits and saved prompts |
| This commit | Prompt 22 legacy-tester recognition plus reconciliation |

## Verification

- Responsiveness focused tests: 41 passed after isolation.
- Prompt 22 focused inspector, admission, startup, and Complete Erase
  regression tests: 67 passed.
- Architecture tripwires: 385 passed.
- Full Flutter suite: 2,152 passed.
- Analyzer: no issues.
- `git diff --check`: clean after final staging.
- macOS debug build: not repeated because no Prompt 22 production hunk was
  reconstructed; the same isolated production code had already passed the
  Prompt 22 debug build.

## Final State

At completion, Prompt 22 has no dirty hunk and no unknown work remains. The
worktree cleanup changed no application behavior beyond preserving the already
reviewed responsiveness and Prompt 22 implementations in separate commits.
