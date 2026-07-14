CURRENT CONFORMANCE NOTE (2026-06-19):

This addition is preserved as historical UX/flow planning. Its concrete
`ledger -> migration -> working.db` language is superseded by source-scoped
archive import, conversation graph projection, and Message Evidence Spine
visibility. Retained legacy databases may be inspected only as explicitly named
archive/recovery compatibility storage, not as ordinary app authority.

ADDITION TO V2 PLAN: Durable Historical Archive Import Surface

Purpose

Historical archive import must be implemented as a durable Settings choice with a visible step-by-step control surface, not as a one-shot transient action.

This is both a UX requirement and an implementation guardrail.

The user must be able to see:

- what archive sources are known
- what folder was selected
- what preflight detected
- whether import has begun
- whether ledger ingestion succeeded
- whether migration into working.db succeeded
- whether historical messages are now app-visible

Settings Placement

Settings → Support → Historical Archives

This should be a durable Settings menu choice, not an ephemeral support action.

Sidebar Behavior

The sidebar should show one or more stable info cards explaining:

- Older Messages folders may contain message records that are not present in the current Mac chat.db
- MessageLens can import those records into its canonical message ledger
- Once imported and migrated, those messages become part of the normal MessageLens timeline/search/heatmap
- Archive import is additive and does not replace current message data

Below the info cards, show:

- List of previously added archive folders, if any
- Source label
- Date range
- Message count
- Import status
- Last imported date/time

Then show:

Add an Archive Folder

Center Panel Behavior

The center panel owns the workflow controls.

Panel 1: Choose Messages Folder

Controls:

Choose Messages Folder…

After selection, keep the selected folder visible.

Show:

- folder path
- whether chat.db was found
- whether Attachments/ was found
- source label / proposed archive name

Panel 2: Preflight Summary

This panel exists before selection, but is empty/disabled until folder selection completes.

After folder selection, update it with:

- total messages
- total chats
- total handles
- total attachments / attachment joins if available
- earliest message date
- latest message date
- rows with missing GUIDs
- likely duplicates already in ledger
- likely new rows

This is read-only evidence before import.

Panel 3: Begin Import

Button:

Begin Import

Enabled only after valid preflight.

Button should not be enabled if:

- no chat.db
- preflight failed
- another import/migration/reset owns the execution gate

Panel 4: Progress

Show progress as a series of explicit phases, similar to the existing chat.db import/migration flow:

1. Reading archive source
2. Normalizing records into canonical ledger format
3. Writing archive rows to db-import
4. Running full canonical migration
5. Rebuilding indexes/search/heatmap support tables
6. Refreshing app-visible data
7. Complete

Each phase should show:

- waiting
- running
- succeeded
- failed
- skipped, if applicable

Progress must distinguish:

- ledger import progress
- migration progress
- index rebuild progress
- UI refresh completion

Panel 5: Result Summary

After completion, show:

- archive source label
- folder path
- staged/imported rows
- projected rows
- skipped/deduplicated rows
- failed rows
- earliest/latest message date
- whether messages are now visible in normal app surfaces

User-facing success should only be shown if the canonical migration and required rebuild steps completed.

Architectural Guardrail

The UI must not perform import logic.

The UI displays workflow state from a durable workflow model.

The service layer owns:

- preflight
- ledger ingestion
- migration trigger
- progress reporting
- final accounting

The center panel is a deterministic observer/controller, not an importer.

Implementation Strategy

Build this surface first, before implementing the full archive import.

Recommended phased implementation:

1. Add durable Settings menu entry and stable sidebar/center panel shell
2. Add folder picker and selected-folder display
3. Add preflight-only analysis
4. Add archive source list / known archives model
5. Add progress-state model with fake/no-op phases for UI validation
6. Wire real ledger import phase
7. Wire full migration phase
8. Wire final result accounting

Each phase should be independently testable and visible.

Key Rule

No more invisible one-button imports.

Every step must expose enough state that the developer and user can tell where the workflow is:

- before import
- during import
- after ledger import
- after migration
- after app visibility refresh

This prevents the previous failure mode where the only way to know what happened was to inspect SQLite manually.
