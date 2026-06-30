---
tier: project
scope: release-exit
status: active-plan
last_reviewed: 2026-06-29
depends_on:
  - 70-GRAPH-SYSTEM-COMPLETION-ROADMAP.md
  - 73-GRAPH-MIGRATION-EXECUTION-CHECKLIST.md
  - 82-SOURCE-SCOPED-ARCHIVE-IMPORT-CUTOVER-PLAN.md
  - 83-LEGACY-DATABASE-RETIREMENT-ASSESSMENT.md
  - 84-ATTACHMENT-REACHABILITY-AUDIT.md
---

# 85 - Release Exit Plan

## Purpose

This document converts the graph-migration cleanup phase into a release plan.

The source-scoped graph architecture is now sufficiently proven and hardened.
Further opportunistic hardening, tripwire expansion, naming cleanup, or
esoteric retained-storage cleanup should stop unless it directly unblocks one
of the release goals below.

The goal is to get MessageLens out the door with:

```text
chat.db / AddressBook
→ macos_import_ss.db
→ working_ss.db
→ graph read models
→ Message Evidence Spine
→ overlay intent
```

as the ordinary production path.

## Release-Blocking Goals Only

New work must advance at least one of these goals:

1. archival data import
2. readiness evaluation
3. onboarding
4. archive/recovery verification
5. final release smoke testing

Before doing any new hardening, explicitly state which goal it unblocks.

If the answer is "none", defer it.

## Stop Rule

Do not continue searching for additional cleanup opportunities merely because
they exist.

Examples of deferred work unless tied to a release blocker:

- additional architecture tripwires
- further terminology cleanup
- broad retained-storage scans
- speculative symlink/path hardening
- optional UI polish
- cleanup of inactive reference material
- code organization improvements that do not affect release readiness

## Current Release Interpretation

The app is functionally graph-first:

- ordinary message evidence uses the Message Evidence Spine.
- ordinary conversations and contacts are graph-backed.
- live incremental graph updates work.
- search routes graph evidence scopes.
- attachment evidence uses graph topology plus overlay archive metadata.
- retired `macos_import.db` / `working.db` are no longer ordinary app
  authorities.

The remaining release work is not proving the graph again.

The remaining work is making the release path understandable, safe, repeatable,
and testable.

## Phase 1 - Release Readiness Evaluation

Goal:

Establish one authoritative readiness answer:

```text
Can this installation run MessageLens normally right now?
```

Work:

- Review the current readiness providers and UI surfaces.
- Ensure readiness reports:
  - live `chat.db` access
  - AddressBook access
  - source-scoped import DB availability
  - working graph DB availability
  - overlay DB availability
  - attachment archive directory availability
  - graph build status
  - last successful live update
- Ensure readiness distinguishes:
  - blocking setup failures
  - warnings
  - informational diagnostics
  - retired-file cleanup inventory
- Ensure readiness does not depend on retired `macos_import.db` or
  `working.db` existing.

Exit criteria:

- a normal install can show "ready" without opening developer panels.
- missing Full Disk Access / missing source DB / broken graph DB produce clear
  user-facing guidance.
- retired DB presence or absence does not affect readiness except as cleanup
  inventory.

Verification:

- focused readiness tests.
- app smoke test from cold launch.

## Phase 2 - Onboarding Path

Goal:

Make first launch and reset/rebuild paths production-safe.

Work:

- Validate the user-facing onboarding sequence:
  - source access
  - AddressBook access
  - graph build
  - archive setup
  - readiness transition into the app
- Ensure onboarding starts or requests the graph build through lifecycle
  orchestration, not ad hoc widget repair.
- Ensure reset/rebuild explains what it deletes:
  - graph derived DBs
  - overlay intent preservation or reset behavior
  - retired cleanup files if applicable
- Ensure the app opens to a useful default after first readiness succeeds.

Exit criteria:

- a clean data folder can be initialized without developer-only panels.
- reset/rebuild can recover from a bad graph state.
- onboarding failures produce actionable messages.

Verification:

- fresh-data-folder smoke test.
- reset/rebuild smoke test.
- focused onboarding/readiness tests.

## Phase 3 - Archival Data Import

Goal:

Make historical Messages archive import usable through the graph-era path.

Work:

- Validate the Historical Archives workflow end to end:
  - select archive source
  - inspect source
  - import source facts into `macos_import_ss.db`
  - project into `working_ss.db`
  - surface archive messages through Message Evidence Spine
  - remove archive source if needed
- Confirm source-scoped archive imports preserve occurrence identity:
  same GUID in live and archive sources must produce distinct `ss_id` rows.
- Confirm archive import does not consult overlay to decide graph truth.
- Confirm archive-source metadata no longer depends on retired
  `macos_import.db`.

Exit criteria:

- one known historical Messages folder can be imported and inspected in the app.
- imported archive messages are searchable/browsable as graph evidence.
- removal is idempotent and does not disturb live-source evidence.

Verification:

- focused archive import/projection tests.
- manual import of a known archive folder.
- graph health after import/removal.

## Phase 4 - Archive/Recovery Verification

Goal:

Prove attachment reachability and recovery behavior before release.

Work:

- Run the attachment reachability audit against current data.
- Verify ordinary evidence paths:
  - current live attachments
  - existing `attachment_archive` records
  - missing source files with archive fallback
  - URL/plugin payload attachments
  - image/video preview paths
- Verify historical archive imports do not break archive lookup.
- Decide what, if anything, the release needs to expose about missing
  attachments:
  - silent fallback
  - unavailable evidence tile
  - diagnostic report only
- Confirm retired `working.db` / `macos_import.db` are not needed to explain
  ordinary attachment reachability.

Exit criteria:

- common attachment evidence renders from graph + overlay archive metadata.
- missing attachment cases render visibly and calmly.
- archive health report can explain known gaps.
- no release-critical recovery path requires retired DB authority.

Verification:

- focused attachment evidence tests.
- graph health report.
- manual inspection of known image/video conversations.

## Phase 5 - Retired DB Retirement Readiness

Goal:

Move retired databases from "still considered" to "safe cleanup inventory".

Work:

- Run final dependency scan for ordinary `macos_import.db` / `working.db`
  reads or writes.
- Confirm remaining references are only:
  - central filename constants
  - reset cleanup
  - read-only diagnostics
  - tests
  - historical reference docs
- Decide release behavior for old files:
  - leave in place
  - delete during reset only
  - offer explicit cleanup later
- Do not require physical deletion before release unless their presence causes
  user-visible confusion or data-risk.

Exit criteria:

- working.db is retired as app authority.
- macos_import.db is retired as app authority.
- release notes can accurately say the app uses the source-scoped graph path.

Verification:

- dependency scan.
- architecture test.
- reset smoke test.

## Phase 6 - Final Release Smoke Testing

Goal:

Confirm the app behaves as a user-facing product, not a migration demo.

Smoke paths:

- cold launch with existing data
- cold launch after graph-ready state
- Conversations default view
- Contacts view
- Contact all messages
- Contact by conversation
- handle-filtered contact messages
- global search
- conversation search
- unfamiliar sources
- recovered/deleted message views if still exposed
- image/video attachment rendering
- URL preview rendering
- live incremental message arrival
- live incremental message arrival with attachment
- Historical Archives source inspection/import if included in release
- reset/rebuild path
- diagnostic/status panel

Exit criteria:

- no developer-only workflow is required for ordinary operation.
- no ordinary surface reads retired DBs.
- no known release-blocking crash, spinner hang, or stale-state issue remains.
- version and changelog are updated if this becomes a release build.
- production build preserves macOS Full Disk Access continuity.

Verification:

- `flutter analyze`
- focused tests for touched release areas
- architecture tripwire
- manual smoke checklist
- `flutter build macos` when ready for release candidate

## Recommended Execution Order

1. Readiness evaluation.
2. Onboarding path.
3. Archival data import.
4. Archive/recovery verification.
5. Retired DB retirement readiness.
6. Final release smoke testing.

Rationale:

- Readiness and onboarding define whether the app can be used without
  developer knowledge.
- Archive import is user-visible and data-integrity sensitive.
- Archive/recovery verification proves the fragile asset: attachments.
- Retired DB retirement should follow proof, not precede it.
- Final smoke testing should happen after release paths stop moving.

## Hardening Authorization Rule

Harden only when it directly unblocks one of the release goals.

Acceptable examples:

- readiness cannot distinguish a broken source path from a warning.
- onboarding can leave the app in an unrecoverable graph state.
- archive import can mutate or misclassify a selected historical source.
- attachment reachability can be incorrectly reported for release-critical
  evidence.
- retired DB retirement cannot be proven without a targeted guard.

Deferred examples:

- additional general filesystem hardening unrelated to release paths.
- new architecture tripwires for already-stable boundaries.
- cleanup of inactive proof-era docs.
- terminology sweeps with no release effect.

## Release Decision Gate

The app is ready for release candidate work when:

- readiness says ready on the real installation;
- onboarding/reset can recover a clean or broken state;
- live incremental import works without manual developer action;
- ordinary conversations, contacts, search, and attachments work from graph
  evidence;
- archive import/recovery behavior is either release-ready or explicitly
  deferred behind clear UI/state;
- retired DB files are not ordinary app authority;
- final smoke paths pass.
