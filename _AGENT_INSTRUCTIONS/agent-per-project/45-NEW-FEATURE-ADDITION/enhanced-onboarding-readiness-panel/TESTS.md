# Environment Readiness Center Panel Tests

## Current Conformance Note (2026-06-06)

This test plan is historical. Current tests should focus on graph-era
readiness evidence, source probes, AddressBook readiness, and presentation
separation. Retained import/projection diagnostics are compatibility evidence.

## Unit Tests

### Snapshot And Sequencing

- first failing step becomes active
- earlier passing steps render as success
- later untouched steps render as pending
- all-passing snapshot reports fully ready
- mixed pass/fail results preserve deterministic ordering

### Step Classification

- missing Full Disk Access activates the FDA step
- readable Messages DB with sparse local history activates the Messages step
- unreadable or unresolved Contacts source activates the Contacts step
- all sources healthy with import storage not yet ready activates source-scoped
  import readiness
- populated source-scoped import with incomplete working graph activates graph
  readiness

### Action Mapping

- FDA step exposes Open System Settings plus Re-check
- Messages step exposes Re-check and guidance-only content
- Contacts step exposes Re-check and guidance-only content
- completed step does not expose repair actions unless explicitly designed

### Reuse Of Existing Evidence

- readiness resolver maps current onboarding environment report into step state correctly
- pipeline failure evidence does not falsely masquerade as permission failure
- graph build/projection failure evidence does not masquerade as source-scoped
  import failure
- inferred local-history scarcity remains marked as inferred in the view model

## Provider / Resolver Tests

### Routing

- app-level routing shows readiness surface when environment is not ready
- readiness route uses dedicated `ViewSpec.environmentReadiness(...)` rather than an onboarding-owned readiness variant
- sidebar is empty or suppressed while readiness surface is active
- ready environment transitions to import/bootstrap route cleanly

### Re-Check Behavior

- Re-check recomputes from source truth rather than cached widget state
- a passing re-check advances active step to the next failure
- a still-failing re-check leaves the same step active with stable copy

### Resumption

- restarting the app recomputes readiness correctly without a persisted wizard index
- if the machine becomes not-ready again later, the readiness surface can be shown again

## Manual Test Matrix

### Full Disk Access Missing

- launch without FDA
- use Open System Settings from the readiness step
- grant access and return
- re-check

Expected:

- FDA step is active first
- copy explains why access is needed and reassures read-only behavior
- step turns green after success
- next failing step becomes active

### Messages Local History Missing Or Sparse

- use a Mac with little or no local Messages history
- or simulate sparse-source conditions in dev mode

Expected:

- Messages step becomes active after FDA passes
- copy explains local-history need without overstating iCloud certainty
- step remains distinct from import failure

### Contacts Unavailable

- make Contacts source unreadable or unresolved

Expected:

- Contacts step becomes active when earlier steps pass
- copy explains why contact data helps and how to proceed

### Healthy Path

- run with all readiness checks satisfied

Expected:

- all steps show success
- transition into import/bootstrap is clean
- no dialog interruption is required

### Partial Progression

- fix one failing step at a time and re-check after each fix

Expected:

- progression is stable and deterministic
- the user is not yanked away before success registers
- later steps remain pending until reached

### Regression Checks

- source-scoped import ownership remains in existing import systems
- graph build/projection ownership remains in graph orchestration
- retained compatibility diagnostics do not become readiness authority
- DB access invariants remain intact
- widgets do not independently probe the machine
- app-level routing remains ViewSpec-driven
