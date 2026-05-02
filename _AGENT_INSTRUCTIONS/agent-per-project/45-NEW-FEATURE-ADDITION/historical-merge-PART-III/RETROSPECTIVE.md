# Historical Archive Import V2 Retrospective

Branch: `Ftr.archive-ledger-provenance`

## 1. What currently works reliably?

- The core two-stage model is still sound: source-derived canonical ledger in `macos_import.db`, then projection into `working.db`.
- `working.db` completion tracking via `projection_state` is a real improvement. It exposes incomplete projection as a first-class state instead of silently trusting stale UI data.
- Missing-ledger recovery classification is materially better than before. The app can now distinguish:
  - incomplete `working.db` with valid ledger
  - incomplete `working.db` with missing ledger
- Gating `chatDbChangeMonitorProvider` behind onboarding readiness is a real fix. It prevents premature `macos_import.db` creation and avoids masking recovery states.
- `messageDataVersionProvider` remains the right refresh primitive for post-migration UI refresh without forcibly closing the Drift connection.
- The canonical timestamp conversion work appears directionally correct and worth preserving if it truly consolidates all Apple timestamp handling into one tested utility.

## 2. What architectural assumptions were exposed as weak?

- The branch stretched too many concerns at once:
  - canonical ledger provenance
  - surrogate identity changes
  - timestamp conversion
  - onboarding recovery
  - archive execution wiring
  - migration/index rebuild behavior
- The assumption that `working.db` could still be safely opened by ambient providers while projection was incomplete was false. This broke the stated invariant.
- The assumption that provenance could be layered onto the existing ledger row model without revisiting dedupe semantics was weak. Shared-GUID `INSERT OR REPLACE` style behavior is structurally at odds with accurate multi-source provenance.
- The assumption that archive import execution could be enabled before the live import/migration/read-blocking pipeline was fully hardened was also weak.
- The assumption that index-maintenance triggers could coexist with long rebuild windows and ambient readers was weak.

## 3. Which recent fixes are genuine invariant improvements worth keeping?

- `working.db` `projection_state` completion marker.
- Recovery classification for incomplete projection vs missing ledger.
- Onboarding blocking behavior that keeps message surfaces and picker data hidden until projection is complete.
- `chatDbChangeMonitorProvider` startup gating.
- Contact-picker refresh invalidation after successful rebuild/reimport.
- Timestamp conversion centralization, if retained as one canonical utility rather than repeated ad hoc conversions.

## 4. Which fixes are likely patchwork or should be reconsidered?

- Onboarding/recovery UI and classifier logic has accumulated several special cases. Much of it is useful, but some of it is compensating for deeper execution-order problems.
- The “fresh empty `working.db` with default incomplete projection” handling is necessary now, but it is still compensating for the fact that providers can recreate and inspect `working.db` too early.
- Archive execution wiring in the settings workflow looks premature. The execution layer is now coupled to pipeline gate state, provenance, duplicate estimation, cleanup, and UI workflow before the lower-level model is stable.
- The current global/message/contact index trigger design should be reconsidered. Full-table rebuild logic embedded in trigger bodies is not a good steady-state maintenance strategy.

## 5. What is the smallest safe rollback point?

Smallest safe rollback point:

- Keep:
  - `projection_state`
  - onboarding recovery classification/blocking
  - chat DB monitor gating
  - contact-picker invalidation
  - timestamp conversion cleanup if it is independently correct
- Roll back or disable:
  - historical archive import execution
  - provenance-dependent archive workflow behavior
  - any surrogate-ID/provenance rewrites that require the new archive path to make sense

In practice, the safest rollback target is:

- preserve the hardened live `chat.db -> ledger -> working.db -> UI` pipeline
- leave archive import planning/preflight UI only
- turn off real archive execution until provenance and migration-read isolation are redesigned cleanly

## 6. What would a cleaner v3 strategy look like?

1. Stabilize the live pipeline first.
   - Enforce the invariant that no normal provider reads `working.db` until `projection_state = complete`.
   - Remove schema-lock contention around post-migration trigger/index work.

2. Split durable infrastructure from archive execution.
   - Land and verify:
     - `projection_state`
     - monitor gating
     - recovery model
     - timestamp conversion unification
   - Keep archive execution disabled while those pieces prove stable in the live path.

3. Re-scope provenance.
   - Decide whether provenance is:
     - row-owned, single-source metadata
     - or additive observation history across sources
   - If the real requirement is source coexistence and source-specific deletion, a proper observation model is cleaner than patching the current shared-row overwrite behavior.

4. Revisit surrogate IDs only after provenance semantics are settled.
   - Surrogate IDs should support stable joins and projection, not carry provenance ambiguity.

5. Rebuild archive import from a thinner execution layer.
   - Start with:
     - archive source registration
     - preflight
     - ledger import into an isolated provenance-safe contract
   - Only then re-enable full migration into the normal app surfaces.

6. Treat index rebuild and trigger creation as post-completion maintenance.
   - Full migration should explicitly rebuild derived indexes.
   - Trigger creation should happen only after projection is complete and normal readers are allowed back in.

## Topic-by-topic assessment

- Canonical ledger provenance changes:
  - Important problem to solve.
  - Current direction looks incomplete because shared-row dedupe and provenance accuracy still conflict.

- Surrogate ID changes:
  - Potentially necessary, but too entangled with provenance and archive execution right now.
  - Should not be the foundation of v2 stabilization.

- Integer timestamp conversion:
  - Worth keeping if unified and tested.
  - Not a reason by itself to keep the rest of this branch intact.

- `working.db` `projection_state`:
  - Strong infrastructure improvement. Keep.

- Onboarding recovery changes:
  - Mostly worth keeping.
  - Some logic is compensatory, but the underlying blocked-surface model is correct.

- `chatDbChangeMonitor` gating:
  - Strong improvement. Keep.

- Archive import execution:
  - Not stable enough to keep driving forward on this branch as the main track.
  - Best candidate to disable and rethink.

- Migration trigger/index rebuild locking:
  - Exposes a real architectural flaw in reader isolation and trigger strategy.
  - Needs redesign, not another local patch.

- Contact picker invalidation:
  - Narrow, useful fix. Keep.

## Recommendation

Do not continue this branch as a single integrated archive-import effort.

Recommended path:

- split out the stable infrastructure work
- abandon or disable the current archive execution layer
- restart historical archive import from a smaller foundation once the live pipeline invariants are enforced

Short version:

- Keep the live-pipeline hardening.
- Stop treating archive execution as nearly ready.
- Re-enter with a v3 plan centered on provenance semantics, strict read blocking until projection completion, and a thinner archive execution surface.
