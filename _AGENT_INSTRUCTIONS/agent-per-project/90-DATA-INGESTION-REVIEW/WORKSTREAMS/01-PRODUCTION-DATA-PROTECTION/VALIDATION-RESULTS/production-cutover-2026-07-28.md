---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: validation-record
status: completed-with-documented-residual
links:
  - ../PRODUCTION-ADOPTION-RUNBOOK.md
  - ../PRODUCTION-PRESERVATION-AUTHORITY.md
  - ./final-cutover-preparation-2026-07-28.md
tests:
  - flutter test test/essentials/db/infrastructure/data_sources/local/overlay/overlay_database_test.dart
  - flutter test test/architecture/forbidden_imports_test.dart
  - flutter analyze
---

# Production Cutover - 2026-07-28

## Decision

The user explicitly authorized the production cutover. The existing production
archive was adopted in place, and the current signed and notarized production
application now operates against it.

The operation did not move, rebuild, or replace the archive.

## Adopted Production Archive

Canonical root:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens
```

Archive marker:

```json
{
  "formatVersion": 1,
  "environment": "production",
  "archiveInstanceId": "b81abc1e-e5ea-4d5a-bea7-1d4126e0c01a",
  "createdAtUtc": "2026-07-28T16:21:59.055563Z"
}
```

Fresh cutover inventory:

```text
build/production-adoption-inventory-cutover-2026-07-28
```

- inventory ID:
  `b81abc1e-e5ea-4d5a-bea7-1d4126e0c01a-1785255719055563`;
- manifest SHA-256:
  `e76adeea1e9fc9cf0836bb1a9d70807d1940494e597620dea4ba817976a8de4e`;
- file records: 25,982;
- recorded bytes: 37,787,899,338;
- SQLite databases: seven, all healthy.

The adoption tool created the planned marker, and `verify-admission` accepted
the resulting production archive.

## Recovery Evidence

The verified recovery backup remains at:

```text
/Volumes/WD_ELEMENTS/DATA_FOLDER_27-07-2026/com.bigbenchsoftware.MessageLens
```

The previously installed application was preserved before replacement:

```text
/Volumes/WD_ELEMENTS/MessageLens Cutover 2026-07-28/MessageLens-legacy-installed-2026-03-11.zip
```

SHA-256:

```text
c0ff47480a187394fe31f6301e9ca4499c9bd8f6c2c7c58026e66faf897afb5c
```

These artifacts remain recovery evidence. They are not active archives or
preservation authorities.

## Installed Production Artifact

Installed application:

```text
/Applications/MessageLens.app
```

- version: `0.2.17`;
- build: `35`;
- bundle identifier: `com.bigbenchsoftware.MessageLens`;
- signing team: `FQHT2QP3NE`;
- notarization submission:
  `d07385e3-2d7f-4e84-aa7f-45080d6eed1e`;
- notarization result: accepted;
- DMG: stapled;
- DMG SHA-256:
  `e4ad15b4a02a0b55b3b4da7c3f22658ecf9a9608a7a7f97cd0ebeeab88ddd612`.

Strict code-signature and Gatekeeper verification passed before installation
and launch. A later `spctl` query against the running installed application
returned a macOS Code Signing subsystem internal error; that later query is not
used as contrary evidence because the artifact had already passed the
pre-launch checks.

## Initial Launch Incident And Correction

The first adopted-archive launch used version `0.2.16+34`. It exposed a real
overlay migration defect: Drift attempted to drop a legacy `nickname` column
from a version-1 overlay database in which that column was already absent.

The application was stopped after production catch-up writes had begun.
Marker-only rollback was therefore correctly unavailable. Database health
remained intact, and overlay row counts were preserved.

The migration was corrected so column removal is conditional on actual schema
presence. Focused overlay tests, architecture tests, and analyzer then passed.
Version `0.2.17+35` was built, notarized, stapled, installed, and launched.
The production overlay advanced to schema version 8 without losing user state.

## Catch-Up And Live Preservation Evidence

Pre-cutover imported state:

- messages: 135,861;
- latest source message row: 152,006;
- attachments: 39,577.

Current production state after catch-up and later live arrivals:

- imported messages: 135,899;
- graph messages: 135,899;
- latest source message row: 152,044;
- imported attachments: 39,604;
- graph attachments: 39,604;
- latest source attachment row: 45,826;
- archived-attachment overlay records: 33,019.

Startup reported:

- environment ready;
- Full Disk Access present;
- populated import and graph databases;
- no reset required.

Three attachments arriving after corrected launch were each preserved
one-for-one:

```text
Graph attachment archive completed: 1 archived, 0 skipped, 0 failed.
```

The periodic maintenance pass subsequently reported:

```text
Attachment maintenance sweep completed: 12 archived, 88 skipped, 0 failed.
```

This recovered all 12 image attachments from the initial interrupted catch-up
range.

## Bounded Attachment Residual

The initial interrupted catch-up included 24 attachment rows, source IDs
45,800 through 45,823.

- 12 image attachments were recovered by the maintenance sweep.
- 12 non-image rows remain without archive-overlay records:
  - nine plugin payload attachments;
  - three QuickTime videos.

This is not hidden or classified as successful preservation. It is the concrete
instance of the already documented limitation that maintenance recovery
revisits images but does not yet provide equivalent delayed retry for
non-image attachments.

All attachment arrivals observed after the corrected production launch were
preserved successfully. The residual is bounded to the interrupted initial
catch-up range and remains follow-up work for attachment reconciliation.

## Overlay Preservation

The production overlay is at schema version 8. Post-cutover counts include:

- conversation tags: 4;
- conversation tag assignments: 8;
- dismissed handles: 12;
- favourite contacts: 37;
- participant overrides: 3;
- message user flags: 2;
- message user tags: 1;
- overlay settings: 26;
- archived attachments: 33,019.

The migration did not replace or recreate the overlay.

## Development Isolation

Debug was launched separately with the machine-local development override:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

The launch:

- wrote its log only beneath that external root;
- retained development archive identity
  `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`;
- did not modify the internal development fallback archive during the
  verification interval;
- failed at the Full Disk Access onboarding gate, as expected for the
  development identity on this machine;
- did not contact the production archive.

The debug process was stopped after verification. The production process
remained running.

## Final Status

Production adoption is complete. The installed current production application
is the active preservation process for the adopted production archive.

The cutover is accepted with one explicit residual: delayed retry parity for
non-image attachments is not yet implemented, leaving the bounded 12-row gap
described above. That limitation must remain visible until attachment
reconciliation closes it.
