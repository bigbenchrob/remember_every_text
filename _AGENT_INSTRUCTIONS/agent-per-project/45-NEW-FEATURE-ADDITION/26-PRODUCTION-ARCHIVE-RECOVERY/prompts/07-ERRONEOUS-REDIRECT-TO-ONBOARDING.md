Work on branch Ftr.archive-recovery.

We have a new staging observation immediately after using Historical Archives → Remove Imported Archive Data.

Do not modify any database or run any import/removal/recovery operation.

The development app is stopped. Inspect only the disposable staging archive:

/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING/com.bigbenchsoftware.MessageLens

Observed sequence:

1. Historical source 3 had previously been imported successfully.
2. User chose Remove Imported Archive Data for that historical source.
3. The UI immediately navigated to Environment Readiness / Onboarding.
4. Returning to Historical Archives showed the same selected folder, but its dry-run now reported:
   - likely already imported: 0
   - likely new: 8882
     This suggests source-3 removal itself may have occurred.
5. MessageLens was quit and relaunched.
6. After relaunch, Environment Readiness persistently reports:
   - Imported message data: Not prepared yet
   - Conversation browsing data: Not prepared yet
   - Ready To Import
   - Import My Messages
7. Before historical removal, the staging archive contained well over 100,000 source-1/current-Mac messages. The user did NOT authorize removal or reset of those records.

This is not the transient maintenanceInProgress behavior fixed in Audit/Implementation 08 because it persists after application relaunch.

FIRST: FORENSIC STATE AUDIT ONLY

Establish exactly what remains on disk.

Report:

- macos_import_ss.db exists?
- working_ss.db exists?
- user_overlays.db exists?
- source_registry rows and identities
- source-1 import counts for every relevant table
- source-3 import counts for every relevant table
- source-1 graph counts for every relevant table
- source-3 graph counts for every relevant table
- total graph message count
- projection/readiness state or equivalent persisted markers
- latest import/reprojection/removal operation metadata
- SQLite integrity checks
- whether attachment_archive and overlay data remain intact

Compare source-1 counts with the last known staging baseline where possible.

DO NOT repair anything yet.

THEN TRACE THE REMOVAL PATH

Determine exactly what Historical Archives removal did.

Answer:

1. Did removal correctly delete only source-3 ledger rows?
2. Did it delete or otherwise disturb any source-1 ledger rows?
3. Did it intentionally clear/recreate working_ss.db as part of full reprojection?
4. If so, was working_ss.db successfully rebuilt from the remaining source-1 ledger?
5. If the source-1 ledger and graph are actually intact, why does onboarding report “Imported message data: Not prepared yet” and “Conversation browsing data: Not prepared yet”?
6. If the graph is absent/empty, identify the exact point where source-scoped removal failed to reproject the remaining ledger.
7. Check whether the removal path reuses any broad message-data reset primitive. If so, determine whether that primitive’s semantics are too broad for source-scoped historical removal.
8. Determine why clicking Remove Imported Archive Data navigated into Onboarding despite the owner-aware maintenanceInProgress correction.

Do not assume the navigation and the persistent readiness failure share the same cause; prove the causal path for each.

IMPORTANT

The user authorized removal only of the selected historical archive source.

The invariant is:

Removing historical source N may remove that source’s source-scoped import facts and then rebuild derived graph state from all remaining sources.

It must never destroy or require reimport of unrelated source-1/current-Mac ledger facts.

Do not click or invoke Import My Messages.

Do not run automatic recovery.

Do not manually edit databases.

Do not recreate the staging clone yet.

Do not touch production, frozen snapshots, donors, or attachment payloads.

DOCUMENTATION

Create the next Feature 26 audit under responses/ describing:

- actual post-removal persistent state;
- whether source-1 ledger data survived;
- whether graph data survived;
- exact removal/reprojection path;
- exact reason Onboarding appears;
- whether this is data loss, projection loss, readiness misclassification, or some combination;
- smallest recommended correction.

STOP after investigation and report before implementing anything.

⸻
