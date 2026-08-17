ADDENDUM TO PROMPT BELOW:

Capture the exact source of the two displayed facts “Imported message data: Not prepared yet” and “Conversation browsing data: Not prepared yet.” Identify the provider/query/result that produced each one on this cold start, and compare those values directly against the on-disk counts in macos_import_ss.db and working_ss.db.

PROMPT:

Work on branch Ftr.archive-recovery.

We now have a clean cold-start observation that must be investigated before any further Historical Archives rehearsal.

The development staging app was launched normally after the previously verified successful historical reimport.

On fresh launch, before the user clicked anything, MessageLens opened directly on Environment Readiness / Onboarding.

The user has now quit the app without pressing Import My Messages, Re-check, or any other onboarding/recovery action.

Do not modify any database or run any import, removal, recovery, reset, or GUI operation.

Use the existing disposable staging archive only:

/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING/com.bigbenchsoftware.MessageLens

Read Feature 26 responses 08 and 09 plus the canonical OnboardingGate / Environment Readiness documentation.

Known durable baseline from Audit 09:

- source-1 ledger messages: 136,943
- source-3 ledger messages: 8,882
- source-1 graph messages: 136,943
- source-3 graph messages: 8,882
- total graph messages: 145,825
- databases passed integrity checks
- no mutation was active at the end of the previous run

This new observation occurred on a genuinely fresh process launch, with no user action.

FIRST perform a strictly read-only cold-start forensic audit.

Determine:

1. What durable database state exists now?
   - import ledger counts by source
   - graph counts by source
   - graph readiness/projection state
   - persisted onboarding/import/graph failure records
   - archive mutation state if any durable equivalent exists
   - source registry state
   - database integrity
2. What exact startup code path decides whether the application opens ordinary Messages or Environment Readiness?

Trace from process startup through:

- OnboardingEnvironmentReport
- OnboardingGate
- any persisted failure store
- any workflow override
- application panel/center-panel synchronization

3. What exact factual state did the fresh process classify?

Identify the specific value that caused:

- Gate != notNeeded
- Environment Readiness to become the selected panel

4. Did startup initially observe an incomplete/transitional provider state and then latch it?

Check whether:

- graph readiness is asynchronous or temporarily unavailable during startup;
- a first “not prepared” result is emitted before the real graph state is known;
- OnboardingGate or panel synchronization retains that initial state after later facts become ready.

5. Does any persisted failure or workflow record survive restart and override current healthy database truth?

If yes, identify:

- exact store/key/row;
- when it was written;
- why startup trusts it;
- whether current healthy graph evidence should supersede it.

6. Does the corrected maintenanceInProgress logic matter here?

There is no active archive mutation on a fresh launch, so do not attribute this to maintenance unless evidence proves otherwise.

GOVERNING INVARIANT

A fresh process must derive application admission from current durable truth.

If the import ledger and graph are populated and healthy, no mutation is active, and there is no still-valid operational failure requiring intervention, startup should produce:

OnboardingGate = notNeeded

and open ordinary MessageLens.

Previous screen selection or transient in-memory maintenance state must not survive process restart as authority.

Do not implement yet.

Create the next Feature 26 audit under responses/ documenting:

- exact cold-start state;
- exact Gate decision path;
- why Environment Readiness was selected;
- whether the cause is stale persisted failure, startup race, provider initialization order, latched UI state, or something else;
- smallest recommended correction.

Do not touch production, donor data, frozen snapshots, attachment payloads, or staging databases.

Run only non-mutating inspection/tests and git diff –check.

STOP and report before implementation.
