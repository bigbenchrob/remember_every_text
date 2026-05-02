UI FIX: Replace Spinner/Grouped Status Modal With Linear Step Progress Rows

Problem

The current Historical Messages import modal is still confusing during long-running work.

Observed issues:

- The current-step spinner stays on the same line for a long time.
- There is no visible evidence that work is progressing.
- Steps are grouped under “Completed” and “Waiting,” which makes the modal harder to scan.
- “Waiting: Complete” is especially confusing.
- The user cannot tell whether migration is still running normally or has hung.

Required UX Change

Replace the grouped modal layout with a single ordered list of pipeline steps.

Each step should appear once, in pipeline order.

Do not group steps under “Completed” or “Waiting.”

Required Step Row Format

Each row should show:

- step name
- current status
- progress bar
- short status text
- optional elapsed time

Example:

Reading archive source
Status: Complete
[████████████████████]
Read archive metadata successfully.

Normalizing records
Status: Complete
[████████████████████]
Normalized archive rows for canonical import.

Writing rows to macos_import.db
Status: Complete
[████████████████████]
Wrote archive rows to canonical ledger.

Running canonical migration
Status: Running · 1m 12s
[██████░░░░░░░░░░░░░░]
Rebuilding working.db from canonical ledger.

Refreshing app-visible data
Status: Waiting
[░░░░░░░░░░░░░░░░░░░░]
Waiting for migration to finish.

Complete
Status: Waiting
[░░░░░░░░░░░░░░░░░░░░]
Waiting for refresh.

Progress Bar Semantics

Use deterministic step-level progress, not fake fine-grained progress.

Acceptable values:

- waiting: 0%
- running: indeterminate or animated bar, but not a spinner
- succeeded: 100%
- failed: 100% with failed status

If no real percentage exists, use an indeterminate horizontal progress bar for the running step.

Do not use a spinner.

Long-Running Step Feedback

For the running step, show elapsed time.

Example:

Running canonical migration
Status: Running · 1m 08s

If a step runs longer than a threshold, e.g. 60 seconds, show a note:

This can take several minutes for large message histories.

If longer than a higher threshold, e.g. 3 minutes, show:

Still running. If this remains here for much longer, MessageLens may be waiting on database migration.

This is not a failure by itself, but the user needs feedback.

Dialog Layout

Make the modal wide enough to read comfortably.

Requirements:

- width around 640–760 px
- left-aligned text
- compact rows
- no centered long paragraphs
- no huge vertical spacing
- no grouped Completed/Waiting sections

Title Area

At top:

Importing Historical Messages

Below:

Current step: Running canonical migration
Elapsed: 1m 12s

Then the ordered step list.

Terminal Success State

On success, collapse to a concise summary:

Import Complete

New messages added: X
Already in current Mac data: Y
Already imported from archives: Z
Failed rows: N
Date range: 2012-07-25 → 2017-06-11

[Done]

Optionally show expandable “Show technical steps” if needed.

Terminal Failure State

On failure:

Import Failed

Failed step: Running canonical migration
Elapsed: 1m 42s
Error: {short error}

Then show the same ordered step list with the failed row marked clearly.

Acceptance Criteria

- There is no spinner in the modal.
- There are no “Completed” or “Waiting” grouped sections.
- Each pipeline step appears once in order.
- Each step has a visible status and progress bar.
- The running step shows elapsed time.
- Long-running work does not look identical for minutes with no changing information.
- “Waiting: Complete” or equivalent phrasing cannot appear.
