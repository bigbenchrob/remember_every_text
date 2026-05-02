CRITICAL: Recovery State With Missing macos_import.db

Observed:

1. Deleted macos_import.db and working.db
2. Started import
3. Import quickly reached stall point
4. Canceled import
5. App beachballed on quit; force quit required
6. Relaunch opened onboarding
7. App data folder now contains:
   - working.db
   - no macos_import.db

working.db.projection_state exists and says:

completion_status = incomplete

Most working tables are empty.

Interpretation

This is not just incomplete projection.

This is:

- missing canonical ledger
- incomplete working projection
- likely app state after cancellation during or before ledger recreation/import

The recovery system must not assume macos_import.db exists.

Required behavior

If working.db is incomplete AND macos_import.db is missing:

- show blocking recovery/onboarding state
- do not allow Messages/contact picker
- explain that the import ledger is missing and message data must be rebuilt
- offer normal re-import/rebuild path from source data
- keep Send Report available

Questions to answer

1. Why was macos_import.db not present after cancellation?
2. Was it deleted/recreated during import startup and left absent because of cancellation?
3. Is the import DB opened lazily and not recreated before migration begins?
4. Did force quit happen before import DB creation completed?
5. Does recovery currently distinguish:
   - incomplete working projection with valid ledger
   - incomplete working projection with missing ledger?

Required fix direction

Add explicit environment/recovery handling for:

- missing macos_import.db
- incomplete working.db
- both together

Do not assume incomplete working.db can be repaired by migration unless macos_import.db exists and is readable.

Non-goals

- Do not optimize the archive stall yet.
- Do not change archive import semantics.
- Do not allow normal app surfaces.
- Do not silently create empty macos_import.db and treat it as valid.

Acceptance criteria

After this state:

- app opens to recovery/onboarding
- recovery message correctly identifies missing import ledger
- user can rebuild from current Mac source
- Send Report works
- no partial Messages UI appears
