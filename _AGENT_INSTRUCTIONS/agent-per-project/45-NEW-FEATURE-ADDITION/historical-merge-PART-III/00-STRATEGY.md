Historical Merge – Part III

Strategy Reset

Context

The previous branch Ftr.archive-ledger-provenance attempted to introduce historical archive import into the existing pipeline:

source → canonical ledger → migration → working.db → UI

While valuable infrastructure improvements were made, the branch introduced instability across:

- migration execution
- database locking
- onboarding/recovery classification
- provider lifecycle ordering
- UI data consistency (contact picker, partial projections)

This indicates that archive import was introduced before pipeline invariants were fully enforced.

⸻

Decision

We are not continuing the archive-import implementation from this branch.

Instead, we will:

1. Extract and stabilize proven infrastructure improvements
2. Restore a fully reliable live pipeline
3. Reintroduce archive import as a new V3 feature from first principles

⸻

Principles

1. Protect pipeline invariants

The following must always be true:

- working.db is never used unless projection is complete
- no provider may open or create databases during recovery/onboarding
- migration must be safe to interrupt and restart
- no UI surface may render partial or stale data

⸻

2. Separate concerns

Do not mix:

- pipeline stabilization
- provenance model changes
- archive execution
- UI workflow

Each must be validated independently.

⸻

3. No patch-driven development

Do not:

- fix bugs by layering new conditions
- introduce special-case recovery logic
- expand onboarding logic to compensate for deeper issues

If a fix requires multiple unrelated changes, stop and reassess.

⸻

4. Archive import is disabled for now

- No new archive import execution work
- No migration changes for archive support
- No UI wiring for archive execution

Archive import will be reintroduced only after stabilization.

⸻

Immediate Goal

Produce a stable application equivalent to the pre-archive branch, with improved:

- projection safety
- recovery handling
- provider ordering

⸻

Out of Scope

- Historical archive import execution
- Provenance model redesign (for now)
- Deduplication redesign
- UI expansion

⸻

Success Criteria

- Clean onboarding → import → migration → UI
- Cancel + restart behaves correctly
- No database lock errors
- No partial UI states
- Contact picker stable across rebuilds

Only after this is achieved will Part III proceed to V3 design.
