# 25 — Onboarding, Bootstrap, and Attachment Archive

This folder documents the full lifecycle from first launch through ongoing
attachment preservation. It covers how MessageLens evaluates the macOS
environment, gates access, imports and migrates data, and maintains a durable
image archive independent of Apple's volatile storage.

## Reading Order

| Doc | Purpose |
|-----|---------|
| [`00-overview.md`](00-overview.md) | Evolution narrative — how the onboarding system grew from a simple gate to a comprehensive bootstrap and archive pipeline |
| [`10-onboarding-gate.md`](10-onboarding-gate.md) | The `OnboardingGate` state machine, overlay rendering, phase transitions, and status enum |
| [`20-environment-readiness.md`](20-environment-readiness.md) | Environment evaluation: FDA checks, source database probes, sync plausibility, readiness classification |
| [`30-import-migration-coordination.md`](30-import-migration-coordination.md) | How onboarding coordinates with `db_importers` and `db_migrate` without owning their logic |
| [`40-attachment-archive.md`](40-attachment-archive.md) | Living attachments archive: overlay schema, content-addressable storage, resolution pipeline, import-time archiving |
| [`50-deterministic-recovery.md`](50-deterministic-recovery.md) | Deterministic historical recovery from Time Machine or backup snapshots via GUID-based mapping |
| [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) | Re-import flow, `ChatDbChangeMonitor` auto-sync, and how the archive stays current |

## Key Ownership Boundaries

- **`lib/essentials/onboarding/`** — bootstrap gate, environment evaluation, overlay presentation
- **`lib/essentials/db_importers/`** — import orchestration and table importers (NOT owned by onboarding)
- **`lib/essentials/db_migrate/`** — migration orchestration and table migrators (NOT owned by onboarding)
- **`lib/features/attachments/`** — archive service, resolver, deterministic recovery, settings
- **`lib/essentials/db/`** — overlay database schema including `archived_attachments` table

## Hard Invariants

1. Onboarding **coordinates and presents** — it does not own import or migration logic.
2. Archive metadata is **user intent** — written only to the overlay database.
3. The working database is a **pure projection** of `chat.db` — rebuilt every migration cycle.
4. Providers **merge** working + overlay at read time; overlay wins on conflict.
5. No attachment record is ever suppressed because its file is missing — the record renders with an availability state.
6. The Messages Attachments folder is **never written to** by MessageLens.
7. Historical snapshots are opened **read-only** — never mutated.

## Related Documentation

- [`10-DATABASES/00-all-databases-accessed.md`](../10-DATABASES/00-all-databases-accessed.md) — database locations and access patterns
- [`10-DATABASES/INVIOLATE_RULES.md`](../10-DATABASES/INVIOLATE_RULES.md) — overlay/working separation, no suppression
- [`20-DATA-IMPORT-MIGRATION/01-overview.md`](../20-DATA-IMPORT-MIGRATION/01-overview.md) — import and migration pipeline details
- [`60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`](../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md) — FDA grant preservation across builds
