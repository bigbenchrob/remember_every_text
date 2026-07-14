# Enhanced Onboarding Flow Tests

## Current Conformance Note (2026-06-06)

This test plan is historical. Current tests should prove graph readiness and
source-scoped build failure reporting for ordinary setup; retained
import/projection failure tests belong only to archive/recovery compatibility
surfaces.

## Unit Tests

### Classification Tests

- Messages DB unreadable -> classify as permission blocked
- Messages DB readable, AddressBook unresolved -> classify as source unavailable or degraded
- Messages DB readable with extremely low row counts -> classify as sparse or likely unsynced
- Messages DB and AddressBook readable with meaningful row counts, app DBs absent -> classify as ready to import
- source-scoped import database populated, graph database empty after failed
  projection -> classify as graph build failed
- source-scoped import result error present -> classify as import failed
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

### Source-Scoped Import Failure

- Trigger a known source-scoped import failure path

Expected:

- app reports import as the blocker
- app does not fall back to generic FDA or "setup incomplete" language
- retry path remains available when appropriate

### Graph Build Failure

- Trigger a known graph build/projection failure path

Expected:

- app reports graph build/projection as the blocker
- app distinguishes this from source-data issues

### Healthy First Run

- Launch with permissions granted and meaningful local source data available

Expected:

- app reports readiness accurately
- source-scoped import and graph build proceed through clear progress phases

### Healthy But Sparse Archive

- Launch on a Mac whose true local archive is small but valid

Expected:

- app avoids declaring failure
- language reflects low volume without implying corruption

## Regression Checks

- existing source-scoped import / graph-build ownership boundaries remain intact
- onboarding does not bypass centralized DB providers
- overlay / graph projection separation is not violated by diagnostics code
- retained compatibility database diagnostics do not become ordinary readiness
  authority
- onboarding UI still blocks the app safely during required bootstrap states
