Replace Historical Archives Progress Panels With Modal Import Workflow

Problem

The Historical Archives screen currently exposes too many overlapping status surfaces:

- top “Execution Gate” status
- Preflight status card
- Activity Log
- Progress panel
- Result Summary
- sidebar status

During import/migration, these surfaces update subtly, inconsistently, or not visibly enough. The user cannot tell what is happening, whether the operation is stuck, or whether it completed.

The backend pipeline is now much stronger. The remaining issue is the presentation model.

Product Decision

Historical archive import is a data transaction, not a passive sidebar state.

It should behave more like onboarding/import/migration:

1. user chooses folder
2. user reviews preflight
3. user clicks Begin Import
4. app shows a blocking modal progress dialog
5. dialog shows real pipeline steps
6. dialog ends in success or failure
7. user closes dialog and returns to the app

Required UI Refactor

Keep the Historical Archives page as a static setup/review screen.

The page should show:

- Choose Messages Folder
- selected folder path
- chat.db found/readable
- Attachments folder found/missing
- source label
- preflight summary
- Begin Import button
- known archive sources / prior import records where available
- developer/testing cleanup controls where appropriate

Remove or greatly de-emphasize from the page:

- live Activity Log
- live Progress panel
- repeated “Execution Gate” status boxes
- multiple simultaneous status indicators saying “migration running”

The import operation itself should be represented by one modal dialog.

Modal Dialog: Importing Historical Messages

When the user clicks Begin Import, show a blocking dialog immediately.

Title:

Importing Historical Messages

Body should show a step list tied to real backend stages, not vague user-friendly descriptions.

Suggested steps:

1. Reading archive source
2. Normalizing archive rows
3. Writing rows to macos_import.db
4. Running canonical migration
5. Rebuilding indexes/search/heatmap data
6. Refreshing app-visible data
7. Complete

Each step should have one of these states:

- waiting
- running
- succeeded
- failed

Only one place in the UI should indicate live progress: this dialog.

Do not require the user to watch the underlying Settings page for progress.

Modal Success State

When all required work completes, show:

Import Complete

Then show concise counts:

- New messages added
- Messages already present
- Failed rows
- Date range
- Source label

Also show:

Your timeline, search, and heatmap have been updated.

Button:

Done

Closing Done returns the user to the app.

Modal Failure State

If archive ledger import succeeds but migration fails, show:

Import Could Not Be Made Visible

Then explain:

MessageLens wrote archive rows into the canonical import ledger, but could not complete migration into the app-visible working database.

Show:

- source label
- stage that failed
- error summary
- whether cleanup is available

Buttons:

- Close
- Send Report
- Delete Failed Import Records

If ledger import itself fails before rows are written, show:

Archive Import Failed

with stage and error summary.

Critical Result Semantics

Do not report “success” unless:

1. archive source scan succeeded
2. canonical ledger import succeeded
3. canonical migration succeeded
4. required index/search/heatmap rebuild completed
5. app-visible refresh completed

Ledger import success alone is not user-facing success.

Developer / User Cleanup Requirement

Users need a way to remove records from failed or unwanted archive imports.

Add a clear cleanup control.

Cleanup Name

Delete Imported Archive Records

or, when scoped to a failed batch:

Delete Failed Import Records

Avoid ambiguous labels like:

- Clear Selection
- Clear Cache

Those mean different things.

Cleanup Semantics

Cleanup must support at least two cases:

Case 1: Delete failed import batch

If a ledger import created archive rows but migration failed, the user should be able to delete the rows associated with that failed archive import.

This should remove archive-derived rows from macos_import.db for that source/batch, then run or require a canonical migration/rebuild so working.db returns to a consistent state.

Case 2: Delete all imported archive records for a source

For an archive source listed in Known Archive Sources, provide:

Delete Imported Records

This deletes archive-derived ledger rows owned by that source, without touching current Mac rows or user overlays.

Cleanup Confirmation

Always show a confirmation dialog before deleting imported archive records.

Suggested copy:

Delete imported records from this archive?

This will remove messages imported from:

{source label}

This will not delete or modify the original archive folder.

This will not delete your current Mac Messages data.

This will not delete user notes, labels, or overlay data.

Buttons:

Cancel

Delete Imported Records

Cleanup Guardrails

Cleanup must not:

- delete the source archive folder
- modify Apple’s Messages folder
- delete current_mac ledger rows
- delete user_overlays.db data
- directly patch working.db as the source of truth

Cleanup should operate on canonical ledger ownership:

- source_id
- import batch id
- source_kind = historical_archive

Then working.db should be rebuilt through the canonical migration path.

Edge Case: Failed Import With No Registry

The current development state may include records from a failed or pre-registry import.

For development/testing only, provide a guarded action:

Delete All Historical Archive Ledger Records

This action should:

- delete only rows whose source kind is historical_archive
- leave current_mac rows untouched
- leave overlays untouched
- trigger full canonical migration afterward

Label it clearly as destructive/testing-oriented.

Suggested text:

Developer/testing cleanup: delete all historical archive records from the canonical ledger and rebuild the app timeline.

This is for cleaning up failed development imports.

Implementation Constraints

Do not change the backend archive pipeline unless required to expose progress and cleanup states.

Do not introduce a custom archive projector.

Do not read archive data directly from UI providers.

Do not write directly to working.db for cleanup.

Use existing canonical services:

- archive ledger import
- canonical migration orchestrator
- message data version refresh
- execution gate / maintenance lock

Workflow State Model

Create or refine a single workflow state model that can drive the modal.

It should include:

- selected source label
- selected folder path
- current stage
- stage states
- source/preflight counts
- import counts
- migration result
- failure stage
- failure message
- cleanup availability
- affected source id
- affected batch id

The Settings page should not infer progress independently.

The modal should observe this workflow state.

Acceptance Criteria

After this refactor:

1. Historical Archives page is a setup/review surface, not a live progress dashboard.
2. Clicking Begin Import opens a modal dialog immediately.
3. Progress is shown in exactly one place.
4. Progress steps map to real backend stages.
5. Success appears only after app-visible migration/rebuild completes.
6. Failure clearly says which stage failed.
7. Failed imported records can be deleted safely.
8. Source-level archive records can be deleted safely.
9. Cleanup never touches current Mac rows or overlays.
10. After cleanup + rebuild, timeline/search/heatmap return to a consistent state.
