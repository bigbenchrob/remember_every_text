Goal

Ensure that no import batch remains permanently in status = 'running' after an app restart.

Any batch that was in progress but no longer has a live execution owner must be marked as failed.

⸻

Scope

- Only touch:
  - canonical ledger database access layer (sqflite_import_database.dart or equivalent)
  - app startup / initialization path (where database is opened or services are initialized)
- Add a reconciliation step that runs once at app startup:
  - find all import_batches where status = ‘running’
  - mark them as:
    - status = ‘failed’
    - completed_at_utc = now
    - optional: add a reason like “orphaned_on_startup”

⸻

Non-goals (strict)

- Do NOT modify:
  - import execution logic
  - migration logic
  - UI
  - progress reporting
  - schema (no migrations, no new columns)
- Do NOT attempt cleanup of partial data
  - this step is only about batch status correctness

⸻

Acceptance Criteria

- After force-quitting the app mid-import and relaunching:
  - no import_batches rows remain in status = 'running'
  - previously running batches are now marked failed
- Normal successful import flow remains unchanged
- Existing tests continue to pass
