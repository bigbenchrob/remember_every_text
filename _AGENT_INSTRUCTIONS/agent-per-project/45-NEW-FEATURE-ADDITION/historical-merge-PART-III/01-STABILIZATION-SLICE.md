Stabilization Slice

Extract Proven Infrastructure Only

Goal

Create a stable pipeline by extracting only safe, invariant improvements from Ftr.archive-ledger-provenance.

⸻

Allowed Changes

The agent may KEEP and VERIFY the following:

1. Projection State

- working.db.projection_state
- complete vs incomplete tracking
- startup detection of incomplete projection

⸻

2. Onboarding / Recovery Gating

- blocking UI when projection incomplete
- distinction between:
  - incomplete working.db with ledger present
  - incomplete working.db with missing ledger

⸻

3. Chat DB Monitor Gating

- chatDbChangeMonitorProvider must NOT:
  - initialize before onboarding is complete
  - create macos_import.db prematurely

⸻

4. Contact Picker Invalidation

- explicit invalidation after successful rebuild:
  - contactsListRepositoryProvider
  - groupedContactsProvider
  - filteredPickerSectionsProvider
  - contactChooserSnapshotProvider

⸻

5. Timestamp Conversion (Conditional)

KEEP only if:

- all conversions are centralized
- tests pass
- no behavioral regressions

Otherwise REMOVE.

⸻

Explicitly Forbidden

The agent MUST NOT include:

- archive import execution logic
- archive workflow UI
- provenance-based logic tied to archive import
- surrogate ID changes tied to archive behavior
- migration changes required only for archive import

⸻

Required Actions

1. Create a new branch from pre-archive baseline
2. Cherry-pick ONLY the allowed components above
3. Remove or disable any archive-dependent code paths
4. Ensure compilation and tests pass

⸻

Verification

The agent must validate:

- Fresh install → import → migration → UI works
- Cancel mid-migration → restart → recovery → rebuild works
- No DB locked errors
- No provider-triggered DB creation during onboarding
- Contact picker works immediately after rebuild

⸻

Output

Produce:

- STABILIZATION_SUMMARY.md
  - what was kept
  - what was removed
  - any risks or uncertainties

Do not proceed to new features.
