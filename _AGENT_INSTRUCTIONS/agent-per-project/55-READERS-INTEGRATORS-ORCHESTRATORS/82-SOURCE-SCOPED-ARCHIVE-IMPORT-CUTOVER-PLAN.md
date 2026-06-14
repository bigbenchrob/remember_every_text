---
tier: project
scope: source-scoped-graph-migration
status: implemented-in-slices
last_reviewed: 2026-06-08
depends_on:
  - 75-ARCHIVE-RECOVERY-IDENTITY-PLAN.md
  - 81-LEGACY-STORAGE-RETENTION-REGISTER.md
---

# 82 - Source-Scoped Archive Import Cutover Plan

## Purpose

This plan defines the next high-leverage graph migration slice:

```text
historical Messages folder
→ macos_import_ss.db
→ working_ss.db
→ Message Evidence Spine
```

The goal is to replace the retained legacy archive import/projection bridge
without risking historical data or archived attachment reachability.

This is intentionally a cutover plan, not a broad redesign.

## Implementation Status

As of 2026-06-06, the Historical Archives workflow defaults to the
source-scoped archive path for both import and removal:

- forward import runs `SourceScopedArchiveGraphImportService`
- removal runs `SourceScopedArchiveGraphRemovalService`
- archive source facts live in `macos_import_ss.db`
- projected archive rows live in `working_ss.db`
- retained `macos_import.db` / `working.db` archive paths remain storage and
  diagnostic-retirement questions, not the ordinary Historical Archives
  execution path

As of 2026-06-07, the retained legacy archive pipeline provider and old
import-progress/detail widgets have also been removed. The standalone
import-control panel, `ImportSpec`, and `ViewSpec.import` route are retired.
Reset/clear maintenance remains owned by active `MessageDataResetService`
callers rather than a dedicated import surface.

The staged plan below is preserved as historical design context. Instructions
such as "do not remove retained legacy path" describe the pre-cutover safety
posture and should not be read as the current default execution path. As of
2026-06-08, the retained archive import/projection execution path has been
removed from production code; retained `macos_import.db` / `working.db` are
storage/reference-retirement questions only.

## Current State

The ordinary app path and Historical Archives import/removal path are now
graph-backed:

```text
archive chat.db
→ macos_import_ss.db
→ working_ss.db
→ Message Evidence Spine
```

The retained bridge no longer blocks ordinary archive execution. Remaining
work is storage/reference cleanup:

- retained `macos_import.db` archive-source metadata compatibility
- retained `working.db` historical/recovered-message reference storage
- retained schema/health diagnostics that inventory those files
- overlay archive rows that still use the old `(message_guid,
  import_attachment_id)` key shape

The source-scoped import schema already has the right shape:

- `source_registry`
- `source_id`
- `source_rowid`
- `SourceScopedRowKey.pack(source_id, source_rowid)`
- import tables for messages, chats, handles, contacts, attachments, and
  topology edges

The missing production piece is archive-source registration and a small
archive-specific orchestration path.

## Hard Invariants

1. Do not mutate historical archive source folders.
2. Do not write archive source facts into overlay.
3. Do not make GUIDs canonical identity.
4. Do not dedupe archive rows against live rows during import.
5. Preserve occurrence identity: same Apple GUID in two sources means two
   graph rows with different `ss_id` values.
6. Preserve existing attachment archive overlay rows and files.
7. Do not reintroduce retained archive import/projection as an execution
   fallback; graph archive import/removal is now the production path.
8. The first graph archive import slice should be idempotent and reversible.

## Proposed Source Identity

Add archive sources to `source_registry`:

```text
source_kind = historical_messages_archive
source_key  = deterministic key for selected archive folder/chat.db
source_label = user-visible archive folder label
```

`source_id` must be stable for a given archive source. It should not be a rowid
from the archive database, and it should not be derived from Apple GUIDs.

Recommended first implementation:

1. Add an import DB helper:

   ```text
   getOrCreateSource(
     sourceKey,
     sourceKind,
     sourceLabel,
   ) -> source_id
   ```

2. Allocate source IDs from the database:

   ```text
   SELECT COALESCE(MAX(source_id), 2) + 1
   FROM source_registry
   ```

3. Use a deterministic `source_key` such as:

   ```text
   historical-messages-archive:<normalized chat.db path or durable folder id>
   ```

This is sufficient for the first slice. Later, a stronger source fingerprint
can be added if archive folders are expected to move frequently.

## First Slice Scope

Historical implementation note: the first graph-native archive slice was
originally scoped as:

1. register archive source in `macos_import_ss.db.source_registry`
2. import archive `chat.db` source facts into `macos_import_ss.db`
3. project imported rows into `working_ss.db`
4. leave retained archive pipeline available during parity review
5. do not yet delete retained DB files

That first slice has been superseded by the current source-scoped archive graph
workflow. Historical Archives import/removal now uses the graph path; retained
`macos_import.db` / `working.db` files remain only as storage/reference
compatibility until final storage retirement.

## Import Strategy

The existing source-scoped importers already accept `sourceId` and `chatDbPath`
for most source facts. Reuse those classes rather than copying legacy
importers.

Likely reusable importers:

- `MessageImporter`
- `ChatImporter`
- `HandleImporter`
- `AttachmentImporter`
- `ChatMessageJoinImporter`
- `ChatHandleJoinImporter`
- `MessageAttachmentJoinImporter`

Contacts are different:

- live contacts come from AddressBook, not archive `chat.db`.
- historical Messages archives may not carry AddressBook data.
- do not fabricate contacts during archive import.
- archive handles are sufficient for graph topology and evidence display.

First archive import should therefore import:

- messages
- chats
- handles
- attachments
- chat/message edges
- chat/handle edges
- message/attachment edges

and skip contacts unless a corresponding archived AddressBook source is
explicitly provided later.

## Projection Strategy

Projection should use the same graph projectors but targeted at the archive
source.

Important current constraint:

`ConversationGraphBuildService` is optimized for the live source and contains
live-source constants in incremental projection paths. The first archive import
slice should avoid relying on those incremental branches.

Safer first implementation:

- run archive import for one source id.
- run full graph projection methods that are already idempotent.
- do not use live-source incremental projection shortcuts for archive sources.

After proof:

- parameterize graph build orchestration by source id.
- allow source-specific incremental graph builds.
- keep live polling on the live-source optimized path.

## Rich Text Strategy

Rich text enrichment already supports:

```text
source_id
started_after_source_rowid
```

For archive source import:

- run enrichment for the archive source after message import.
- use imported `attributed_body_blob` from `macos_import_ss.db.messages`.
- do not open archive `chat.db` again for text enrichment.

If first slice runs full projection, enrichment can still be source-scoped to
avoid touching unrelated rows.

## Attachment Strategy

Archive import should preserve attachment source facts:

- source attachment rowid
- GUID
- filename/path hint
- transfer name
- UTI/MIME
- byte count

Do not immediately copy or rearchive every attachment as part of source-fact
import. That is a separate evidence/archive-file operation.

Graph attachment evidence should be able to say:

- graph attachment exists
- source path hint exists
- archive file exists
- current archive file missing
- recoverable from selected source folder

The archive file copy step should remain idempotent and use the existing
archive resolver/copy semantics where possible.

## Historical Archive UI Cutover Strategy

Current Historical Archives workflow calls:

```text
RetainedLegacyArchivePipeline.importArchiveSource(...)
RetainedLegacyArchivePipeline.rebuildLegacyProjectionAndGraph(...)
```

Cutover should happen in stages:

### Stage 1 - Add Graph Archive Import Service

Create a named service such as:

```text
SourceScopedArchiveImportService
```

Responsibilities:

- validate selected folder/chat.db path
- register/get archive source id
- run source-scoped importers for that source
- run source-scoped rich text enrichment
- run full graph projection
- return typed report

No UI replacement yet.

### Stage 2 - Add Diagnostic Alternate Path

Expose the graph archive import path in Historical Archives as a diagnostic or
developer-only path.

Compare:

- imported messages
- imported chats
- imported handles
- imported attachments
- topology edges
- projected graph rows
- evidence visibility

Historical pre-cutover note: this step originally required keeping the
retained archive path available. That path has since been retired after
source-scoped graph archive import/removal became the default.

### Stage 3 - Make Graph Archive Import Default

After real-data verification, switch Historical Archives default import to the
source-scoped archive service.

Historical pre-cutover note: this step originally made the retained path a
fallback/diagnostic path. That fallback has since been removed from production
code; diagnostics now inspect retained files as historical/reference storage.

### Stage 4 - Retire Retained Legacy Bridge

Historical pre-cutover note: this stage is complete for execution code.
`RetainedLegacyArchivePipeline`, unused retained importers/migrators, and their
execution-path tests have been removed from production code. The remaining
question is storage/reference policy: decide whether retained
`macos_import.db` / `working.db` files remain historical storage or are deleted
by reset/cleanup after the retention criteria are satisfied.

## Tests Needed

Add focused tests for:

- archive source registration is deterministic and idempotent.
- same archive source gets same `source_id`.
- different archive sources get different `source_id`.
- duplicate Apple GUIDs across live and archive sources are allowed.
- imported archive messages get `ss_id = pack(archive_source_id, ROWID)`.
- archive chat/message topology projects to graph endpoints.
- archive message/attachment topology projects to graph endpoints.
- source-scoped rich-text enrichment only touches selected archive source.
- full projection is idempotent after archive import.
- retained archive import/removal is graph-backed; retained files remain only
  as storage/reference compatibility until final storage retirement.

## Do Not Do Yet

Do not:

- delete `macos_import.db` or `working.db`.
- migrate overlay archive rows to new keys.
- add heuristic deduplication.
- merge archive messages into live-source messages.
- require AddressBook import for archive source proof.
- run source-scoped archive import automatically during live polling.

## Recommended First Implementation Task

Implement only the source registry helper and focused tests:

```text
ImportDatabase.getOrCreateSource(...)
```

Then add a tiny archive import service shell that can register a selected
archive source and report the source id without importing rows.

This creates the stable identity base needed for the full archive import path
without touching the existing Historical Archives production workflow.
