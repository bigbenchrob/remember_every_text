---
tier: project
scope: source-scoped-graph-migration
status: active-audit
last_reviewed: 2026-06-28
depends_on:
  - 69-MESSAGE-EVIDENCE-SPINE-INVARIANT.md
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 81-LEGACY-STORAGE-RETENTION-REGISTER.md
  - 82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
  - 83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md
---

# 84 - Attachment Reachability Audit

## Purpose

This audit proves the current attachment reachability path before any further
retired `macos_import.db` / `working.db` reference cleanup.

The policy premise is:

```text
macos_import.db and working.db may remain on disk for now.
They are retired transitional storage, not ordinary app authority.
```

The practical question is whether ordinary graph-era attachment evidence can
reach archived files without consulting retired database tables.

## Current Runtime Evidence Path

For ordinary message evidence, the attachment path is:

```text
MessageEvidenceScope
-> messageEvidenceAttachmentsProvider
-> ChatSummaryReader.readMessageAttachments(...)
-> SqliteChatSummaryRepository
-> working_ss.message_to_attachment / working_ss.messages / working_ss.attachments
-> GraphAttachmentArchiveLookup
-> OverlayArchiveCompatibilityLookup
-> user_overlays.archived_attachments
-> attachment_archive/<archive_relative_path>
-> MessageAttachmentEvidence
-> shared media/fallback evidence tiles
```

This path uses:

- graph message identity: `message_ss_id`
- graph attachment identity: `attachment_ss_id`
- graph topology: `message_to_attachment`
- overlay archive metadata: `archived_attachments`
- filesystem archive root: `attachment_archive`

It does not read `macos_import.db` or `working.db`.

## Current Archive Sweep Path

For living archive maintenance, the sweep path is:

```text
ChatDbChangeMonitor / AttachmentArchiveService
-> SqliteGraphAttachmentArchiveCandidateReader
-> working_ss.messages / working_ss.message_to_attachment / working_ss.attachments
-> ArchiveCompatibilityKey
-> user_overlays.archived_attachments
-> attachment_archive file store
```

The graph archive candidate reader selects attachment candidates from
`working_ss.db` graph facts and topology. It does not depend on
`working.db.attachments`.

## Compatibility Key Boundary

The existing overlay archive table is still keyed by the retained archive tuple:

```text
(message_guid, import_attachment_id)
```

In graph-era code this tuple is not treated as canonical identity. It is a
named compatibility boundary represented by `ArchiveCompatibilityKey`.

For live `chat.db` rows:

```text
attachment_ss_id = SourceScopedRowKey.pack(live_source_id, attachment.ROWID)
```

Therefore:

```text
ArchiveCompatibilityKey.fromLiveAttachmentSsId(...)
```

can derive the current archive compatibility attachment id from the live-source
attachment `ss_id`.

The bridge is deliberately narrow:

- `OverlayArchiveCompatibilityLookup` rejects non-live source ids.
- It rejects mixed-source message/attachment endpoints.
- It requires graph topology to link the message and attachment endpoints.
- It validates archive-relative paths against the archive root to prevent path
  escape.

This means the retained archive tuple remains usable for the current living
archive without becoming a source-scoped universal key.

## Source-Scoped Identity Interpretation

Current live attachment reachability can be explained as:

```text
message_ss_id
-> working_ss.messages.guid
-> attachment_ss_id
-> live source attachment ROWID
-> ArchiveCompatibilityKey(message_guid, live attachment ROWID)
-> overlay archived_attachments row
-> archive-relative filesystem path
```

The graph remains the ordinary authority for message/attachment topology.
Overlay remains the authority for archived-file metadata and user/workflow
state.

## Retired Database Dependency Classification

### working.db

No ordinary attachment evidence path was found that requires `working.db`.

Current attachment evidence and archive sweeps use graph tables plus overlay
archive metadata. Existing `working.db` files may remain on disk as retired
cleanup/diagnostic inventory, but they are not attachment reachability
authority.

### macos_import.db

No ordinary live attachment evidence path was found that requires
`macos_import.db`.

Historical archive source metadata has already moved to overlay storage. Older
`macos_import.db` files may still contain historical rows useful for manual
audit, but current attachment reachability does not depend on them.

## Final Dependency / Retention Scan

Scan date: 2026-06-28.

Active-code scan pattern:

```text
macos_import.db
working.db
retiredMacosImport
retiredWorking
AppDatabaseFile.retiredMacosImport
AppDatabaseFile.retiredWorking
retainedArchiveMetadataStoreProvider
RetainedArchiveMetadataDatabase
WorkingDatabase(
```

Scan scope:

```text
lib test
```

Classification:

| Category | Current result | Disposition |
| --- | --- | --- |
| Central physical file identity | `lib/essentials/db/app_database_files.dart` | Legitimate. This is the single physical filename source for retired cleanup targets. |
| Reset / maintenance cleanup | `lib/essentials/onboarding/application/message_data_reset_service.dart` | Legitimate. Reset deletes retired files if present but does not treat them as app authority. |
| Diagnostic / support health | `lib/essentials/db/feature_level_providers/database_health_audit_service_provider.dart` plus database health query layers | Legitimate. Read-only diagnostics may inspect retired-file existence/schema without creating app providers. |
| Tests / architecture tripwires | `test/**` | Legitimate. Tests prove retired files do not satisfy readiness, are cleanup-only, or remain guarded by architecture tests. |
| Ordinary app read/write paths | None found | No demotion/deletion required from this scan. |
| Retired provider resurrection | None found | `retainedArchiveMetadataStoreProvider`, `RetainedArchiveMetadataDatabase`, and retained `WorkingDatabase` construction are not active production dependencies. |

Conclusion:

```text
No unsupported retired DB dependency was found in ordinary attachment evidence,
archive sweep, contact/message/conversation evidence, or feature presentation
paths.
```

The remaining retired-file references are bounded to central filename identity,
reset cleanup, diagnostics, and tests. They should stay until a deliberate
retired-file cleanup/export/discard policy removes the need to name existing
old files at all.

## Proof Tests

The focused proof surface is:

- `test/features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup_test.dart`
  - resolves an existing archive row from graph attachment identity
  - rejects non-live source ids
  - rejects mixed-source endpoints
  - rejects unlinked graph topology
  - rejects archive-relative path escape
- `test/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader_test.dart`
  - proves graph-backed archive candidate selection and existing archive-row
    filtering
- `test/essentials/conversation_graph/application/chat_summaries/chat_summary_reader_test.dart`
  - proves message attachment summaries carry archive availability through the
    graph reader
- `test/features/messages/application/message_evidence/message_attachment_evidence_test.dart`
  - proves archived image/video, missing/unavailable attachment, URL preview,
    and text-only evidence rendering decisions

## Remaining Caveats

1. The current compatibility tuple is live-source only.

   It must not be generalized to historical archive sources or arbitrary
   multi-source attachment identity.

2. Historical archive attachment reachability still requires a source-scoped
   archive import/recovery strategy.

   Historical sources should use source-scoped identity and an explicit bridge
   or future archive key, not implicit reuse of the live-source compatibility
   tuple.

3. Retired files may remain useful as diagnostic/audit inventory.

   That does not make them production attachment authority.

## Retirement Implication

This audit supports the following conclusion:

```text
Ordinary graph-era attachment evidence and living archive sweeps do not require
macos_import.db or working.db.
```

Therefore, future cleanup should:

1. leave existing retired DB files in place unless a proven cleanup action is
   being executed;
2. keep reset/diagnostic references only where they are explicitly classified;
3. avoid deleting archive compatibility code until a source-scoped archive key
   replacement exists;
4. reject any new ordinary app path that reads retired DBs to resolve
   attachments.

## Done Means

Attachment reachability is considered graph-era sufficient for ordinary live
message evidence when:

- message attachment summaries resolve from `working_ss.db`;
- archive availability resolves through overlay `archived_attachments`;
- media evidence uses the shared Message Evidence Spine;
- focused archive lookup/candidate/evidence tests pass;
- dependency scans show no ordinary attachment UI/read path consulting
  `macos_import.db` or `working.db`.

As of the 2026-06-28 scan, these ordinary live attachment evidence criteria are
satisfied. This does not retire the archive compatibility bridge itself; it
only proves that retired databases are not required for the current ordinary
attachment path.
