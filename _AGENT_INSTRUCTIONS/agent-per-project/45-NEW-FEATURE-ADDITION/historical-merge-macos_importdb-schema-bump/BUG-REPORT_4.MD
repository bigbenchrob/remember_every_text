Diagnostic Slice: Build working messages stalls at 109000 / 112065

Observed behavior

During Historical Archive import migration, the modal reaches:

Build working messages
Processed: 109000 / 112065 messages
Status: Running for >1 minute
No further progress reported

The step appears stalled near the end of the message projection set.

Interpretation

This is now a targeted migration bug, not a generic UI problem.

The row-progress reporting is working. It shows the migration gets through most messages and then stops or blocks near a specific region of the source set.

Required task

Diagnose the exact row or sub-step where Build working messages stops.

Do not refactor migration broadly.

Do not change archive import logic yet.

Questions to answer

1. Is the migrator stuck inside the chunk insert loop?
2. Is it stuck after the chunk loop during:
   - sender-handle backfill
   - per-chat last-message metadata update
   - post-validation
3. What is the last GUID or row id successfully reported?
4. What is the next row/chunk after 109000?
5. Are the remaining rows archive-derived, recovered/unlinked, missing chat links, or otherwise unusual?

Add narrow diagnostics

Enhance the existing progress/debug output for messages_migrator only.

At minimum, log/report:

- current chunk start/end offsets
- last processed canonical message id
- last processed GUID
- source_id of current/last row
- whether the current row came from current_mac or historical_archive
- whether progress is currently in:
  - chunk insert loop
  - sender handle backfill
  - chat metadata update
  - postValidate

Important

The UI currently reports 109000 / 112065, but that number alone is not enough. We need to know whether the stall occurs:

- while processing message rows
- or after the progress count has reached 109000 but before the next progress event

Non-goals

- Do not modify the overall migration architecture.
- Do not add archive-specific projection.
- Do not patch around the stuck rows.
- Do not hide the issue in the UI.
- Do not proceed to attachment import.

Acceptance criteria

After the diagnostic slice:

- We know the exact operation where the migrator stalls.
- We know whether the stall is row-specific or post-loop.
- We know whether affected rows are archive-derived.
- No broad behavior changes are made.
