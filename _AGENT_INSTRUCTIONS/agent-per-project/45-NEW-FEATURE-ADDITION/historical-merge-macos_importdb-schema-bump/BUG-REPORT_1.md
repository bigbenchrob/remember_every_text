BUG: Historical Archive Import Reports Success But Contact Picker Is Empty

Observed behavior

After running Historical Archive import:

- A very narrow modal appears
- It shows a long vertical list of pipeline steps
- There is no useful live progress indicator
- After dismissing the modal, the contact picker is empty

The modal reports:

Import Complete

and claims:

- archive rows were written to db-import
- migrated into working.db
- timeline/search/heatmap were refreshed

But the contact picker being empty means app-visible data is not actually healthy.

Critical issue

The app must not report “Import Complete” unless normal app surfaces are usable afterward.

An empty contact picker after import means one of the following is true:

- migration did not actually rebuild all required working tables
- message/contact indexes were not rebuilt
- providers refreshed too early or incorrectly
- the execution gate / maintenance lock state is still affecting provider reads
- the contact-picker source query now returns zero because the working projection is incomplete

Required fix before UI polish

Add a post-migration health check before the modal can enter success state.

After archive import + canonical migration + refresh, verify at minimum:

1. working.db has projected messages
2. contact picker source has non-zero selectable contacts/chats
3. timeline metadata query returns usable rows
4. messageDataVersionProvider has been bumped only after migration is complete
5. execution gate / maintenance lock has been released

If any health check fails, show failure:

Import Completed But App Data Is Not Ready

Do not show Import Complete.

Immediate diagnostics to add

After migration completes, log/count:

- working linked message count
- working recovered message count
- contact picker candidate count
- chat/contact index count if applicable
- current execution gate owner
- whether messageDataVersionProvider was bumped

Modal UI issue

The modal is too narrow and unusable.

Replace the current narrow Cupertino dialog with a wider, readable modal.

Requirements:

- fixed reasonable max width, e.g. 620–720 px
- left-aligned text
- compact step rows
- no tall centered stacked paragraphs
- show only:
  - title
  - current stage / result
  - progress indicator or step list
  - concise summary
  - Done / Close button

Do not show long explanatory text for every completed step in the success state. On success, collapse steps or show a short checklist.

Progress display requirement

While running, the dialog should show meaningful progress:

- current stage prominently
- spinner or indeterminate progress bar
- optional step checklist
- short status line

Example:

Importing Historical Messages

Current step: Running canonical migration

[spinner/progress indicator]

Completed:
✓ Read archive source
✓ Wrote archive rows to import ledger

Waiting:
• Refresh app-visible data

Success modal should be short

Example:

Import Complete

Messages added: 2,369
Already present: 6,513
Source: Messages_2012
Date range: 2012-07-25 → 2017-06-11

Your timeline, search, and heatmap have been updated.

[Done]

Failure modal should be explicit

If contact picker would be empty or health checks fail:

Import Completed But App Data Is Not Ready

Archive rows were imported, but MessageLens could not confirm that normal app views refreshed correctly.

Show:

- failed health check
- recommended action
- Send Report
- Close

Priority

First fix correctness:

- no success state if contact picker/app-visible data is broken

Then fix modal layout.

Do not proceed to attachment import until this is resolved.
