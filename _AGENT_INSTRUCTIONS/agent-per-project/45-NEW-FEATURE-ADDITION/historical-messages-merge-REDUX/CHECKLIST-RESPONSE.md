What Still Needs Tightening (Important)

These are small additions, but they prevent subtle regressions.

⸻

🔴 1. Add a “NO PARTIAL LEDGER WRITE” rule

Right now you enforce atomicity at working.db, but not at ledger ingestion.

That’s dangerous.

You could end up with:

- half-imported archive batches
- inconsistent dedupe state
- replay ambiguity

Add to Phase 5:

- Ledger ingestion must be atomic per batch; partial writes must not persist if ingestion fails

⸻

🔴 2. Add explicit “batch identity” requirement

You mention provenance, but not explicitly:

- every import run must be identifiable as a unit

You will need this for:

- rollback reasoning
- debugging
- dedupe auditing

Add:

- Every archive import run must produce a unique import_batch_id applied to all ledger rows

⸻

🔴 3. Add “idempotent re-import” guarantee

This is critical and currently implicit.

You need to guarantee:

Running the same archive import twice does not change the system state.

Add:

- Archive import must be idempotent; re-importing the same source must not duplicate or mutate existing canonical ledger rows

⸻

🔴 4. Add “no UI blocking on long phases”

You’ve seen this already with:

- frozen sidebar
- dead picker
- unresponsive heatmap

Add to Phase 4/9:

- Long-running phases must report progress without blocking UI interaction outside the maintenance lock scope

⸻

🔴 5. Add “preflight must not attach DBs”

You already fixed DETACH issues, but prevent regression:

Add to Phase 3:

- Preflight must not rely on ATTACH/DETACH; it must operate via direct read access or isolated connection

⸻

🔴 6. Add “migration must be restartable”

Given how complex this is, you will hit failures.

Add:

- Migration must be restartable from a clean state without requiring manual DB intervention

⸻

🧠 One Strategic Suggestion (Optional but Powerful)

You might consider:

Phase 4.5 — “Dry Run Import”

Before real ingestion:

- simulate ledger insertion
- simulate dedupe
- produce projected counts

This gives you:

- extremely high confidence before committing anything
- a perfect debugging surface
