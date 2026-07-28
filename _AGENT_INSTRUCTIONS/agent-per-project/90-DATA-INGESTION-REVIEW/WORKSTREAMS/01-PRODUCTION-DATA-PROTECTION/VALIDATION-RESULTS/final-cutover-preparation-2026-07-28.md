---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: validation-record
status: blocked-on-notarization-agreement
links:
  - ../05-BACKUP-REDIRECT.md
  - ../PRODUCTION-ADOPTION-RUNBOOK.md
  - ../PRODUCTION-PRESERVATION-HANDOFF-PLAN.md
tests:
  - flutter test test/essentials/archive_environment/infrastructure/file_system_production_archive_adoption_service_test.dart
  - flutter test test/tool/verify_macos_archive_identity_test.dart
---

# Final Cutover Preparation — 2026-07-28

> Historical preparation record. The agreement blocker was resolved and the
> user subsequently authorized the cutover. See
> [`production-cutover-2026-07-28.md`](production-cutover-2026-07-28.md) for
> the executed operation and current state.

## Decision

The external folder is the operational recovery backup. The production root
remains the in-place adoption target. A separate read-only inventory records
the exact pre-adoption state and planned marker identity without copying the
archive.

No production marker was created. No production application was installed or
launched. Neither the production archive nor the external backup was modified.

## Production Artifact

Fresh artifact:

```text
/Users/rob/Desktop/MessageLens-latest.dmg
```

- size: 47,114,987 bytes;
- SHA-256:
  `56539492eefe3a248fc159952a1e4ae25b0f12d55f18e437a16de35efb18ec57`;
- production bundle, product, environment, signing, entitlements, canonical
  root policy, and FDA-continuity contract: verified;
- signed: yes;
- notarized and stapled: no;
- installed or launched: no.

Apple notarization returned HTTP 403:

```text
A required agreement is missing or has expired.
```

The DMG is therefore preparation evidence, not the final cutover artifact.
Cutover remains blocked until the developer-account agreement is accepted or
renewed and artifact-only packaging completes notarization and stapling.

## Existing Recovery Backup

Operator-provided backup container:

```text
/Volumes/WD_ELEMENTS/DATA_FOLDER_27-07-2026
```

Archive root within it:

```text
/Volumes/WD_ELEMENTS/DATA_FOLDER_27-07-2026/com.bigbenchsoftware.MessageLens
```

Verification:

- 25,982 files in both backup and current production;
- 25,808 attachment files, 37,026,053,675 bytes, exact checksum match;
- 162 derived-media files, 10,217,477 bytes, exact checksum match;
- all seven SQLite databases pass `PRAGMA integrity_check`;
- no symbolic links;
- no archive marker or process lock.

A full checksum comparison found only three changed top-level files:

- `.DS_Store`;
- `user_overlays.db`;
- retired `macos_import.db`.

The overlay difference is limited to a later favourite interaction timestamp
and window position in current production. Canonical import, graph, tags,
attachments, and user intent otherwise match. The retired import database has
later diagnostic/import contents in current production and is not the
source-scoped import authority.

Conclusion: the backup is complete and suitable for recovery. Creating a
second 35 GB copy is neither necessary nor authorized.

## Read-Only Production Inventory

Inventory folder:

```text
build/production-adoption-inventory-2026-07-28
```

Manifest:

```text
build/production-adoption-inventory-2026-07-28/.messagelens-adoption-inventory.json
```

- manifest size: 5.8 MB;
- manifest SHA-256:
  `53f0753d4e58fbeca06086a9d64c7bd35669a0443ce4aa7c3624210ec5729d94`;
- inventory ID:
  `def08f84-a7dc-4697-a721-fbaac22c433b-1785250268900576`;
- planned archive instance:
  `def08f84-a7dc-4697-a721-fbaac22c433b`;
- created:
  `2026-07-28T14:51:08.900576Z`;
- file records: 25,982;
- recorded bytes: 37,787,899,338;
- SQLite databases: seven, all healthy;
- archive payload copied into inventory: none.

Canonical import/graph state:

- messages: 135,861;
- attachments: 39,577;
- latest committed message timestamp:
  `2026-07-27T16:54:24.000Z`;
- latest source row: 152,006;
- latest import batch: 10,811.

Direct comparison with Apple's live `chat.db` could not be performed from the
Codex host because it lacks Full Disk Access. The signed production app or an
FDA-enabled Terminal must perform that final source-cursor comparison during
cutover.

## Cutover Sequence

1. Accept or renew the Apple developer agreement.
2. Rerun `./tool/build_and_notarize.sh --artifact-only`.
3. Verify signing, notarization, stapling, and production identity.
4. Confirm the external recovery backup is mounted and readable.
5. Confirm no process or lock owns the production root.
6. Refresh the read-only adoption inventory.
7. Obtain explicit cutover authorization.
8. Adopt the unchanged production root from the inventory plan.
9. Verify production admission.
10. Install and launch the verified artifact.
11. Verify Full Disk Access, catch-up import, overlay state, and attachment
    preservation.

Before the first post-adoption archive write, exact marker rollback is
available if the payload still matches the inventory. After catch-up or any
other write, recovery requires stopping the app and restoring the verified
external backup through a reviewed recovery procedure.

## Authorization Status

Not authorized. The remaining external blocker is Apple notarization agreement
status. Production preservation remains interrupted until a separately
authorized cutover succeeds.
