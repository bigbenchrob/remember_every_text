# Enhanced Onboarding Flow Tests

## Unit Tests

### Classification Tests

- Messages DB unreadable -> classify as permission blocked
- Messages DB readable, AddressBook unresolved -> classify as source unavailable or degraded
- Messages DB readable with extremely low row counts -> classify as sparse or likely unsynced
- Messages DB and AddressBook readable with meaningful row counts, app DBs absent -> classify as ready to import
- import database populated, working database empty after failed migration -> classify as migration failed
- import result error present -> classify as import failed
- all checks healthy -> classify as ready

### Inference Tests

- sparse-source inference is marked as inferred, not definitive
- unknown sync state remains unknown when evidence is mixed
- recommendation list changes with blocker category

### Provider / Evaluator Tests

- evaluator combines filesystem, provider-backed DB, and pipeline evidence correctly
- evaluator degrades gracefully when an individual probe throws
- onboarding gate reacts to updated report state without entering loops

## Manual Test Matrix

### Permissions

- Launch with Full Disk Access denied
- Grant Full Disk Access and relaunch
- Revoke Full Disk Access after prior success

Expected:

- app shows permission-blocked diagnosis
- advice points to System Settings
- no ambiguous blank startup state

### Sparse / Unsynced Local History

- Launch on a Mac with Messages enabled but little or no local history
- Launch on a Mac that has not meaningfully synced Messages yet

Expected:

- app does not claim import failure when source data is merely sparse
- app explains that this Mac appears to have little or no local message history
- user is given concrete next steps

### AddressBook Readiness

- Messages readable, AddressBook unavailable or unresolved

Expected:

- app identifies the degraded source state clearly
- guidance separates contact-readiness issues from Messages-readiness issues

### Import Failure

- Trigger a known import failure path

Expected:

- app reports import as the blocker
- app does not fall back to generic FDA or "setup incomplete" language
- retry path remains available when appropriate

### Migration Failure

- Trigger a known migration failure path

Expected:

- app reports migration as the blocker
- app distinguishes this from source-data issues

### Healthy First Run

- Launch with permissions granted and meaningful local source data available

Expected:

- app reports readiness accurately
- import and migration proceed through clear progress phases

### Healthy But Sparse Archive

- Launch on a Mac whose true local archive is small but valid

Expected:

- app avoids declaring failure
- language reflects low volume without implying corruption

## Regression Checks

- existing import/migration ownership boundaries remain intact
- onboarding does not bypass centralized DB providers
- overlay/working DB separation is not violated by diagnostics code
- onboarding UI still blocks the app safely during required bootstrap states