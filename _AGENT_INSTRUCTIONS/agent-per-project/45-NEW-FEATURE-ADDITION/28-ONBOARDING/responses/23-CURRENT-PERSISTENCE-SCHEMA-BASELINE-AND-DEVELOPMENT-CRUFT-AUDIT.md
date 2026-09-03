---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-30
source_of_truth: audit-record
---

# Current Persistence Schema Baseline And Development Cruft Audit

## Decision

**Do not renumber the current databases to schema `1` before the
`0.2.99+117` tester release.**

The current physical schemas can already be created directly without replaying
their histories. The remaining migration chains contain substantial
development archaeology, but changing the version numbers is not the useful
part of removing it.

The safe modern baseline is the existing tuple:

```text
macos_import_ss.db  10
working_ss.db        2
user_overlays.db     8
presence.db          9
```

Those numbers should be treated as opaque generation identifiers for the first
supported source-scoped architecture. After the release, the migration code
below those exact versions can be reviewed for removal and replaced by an
explicit fail-closed lower-version policy. The next real shipped schema changes
would then be `10 -> 11`, `2 -> 3`, `8 -> 9`, and `9 -> 10`.

This preserves a hard distinction:

- the April tester fingerprint `4/3/3` remains historical evidence used by the
  exact legacy inspector;
- attachment-recovery donor tuples remain supported read-only evidence;
- development-era migrations are not mistaken for supported upgrade paths;
- valuable current archives are not relabelled merely to make their version
  numbers look tidier.

## Scope And Method

This was a read-only audit. It inspected:

- current schema authorities and migration implementations;
- migration and archive-compatibility tests;
- Feature 26, 27, and 28 persistence assumptions;
- Git history establishing when the schema generations appeared;
- the stopped production archive at
  `~/Library/Application Support/com.bigbenchsoftware.MessageLens`, using
  immutable/read-only SQLite inspection.

The production MessageLens process was confirmed stopped before the live
archive inspection. No database, archive marker, payload, schema, migration, or
application file was changed.

## Current Persistence Inventory

| Store or artifact | Current version | Authority | Migration history | Supported external dependency? |
| --- | ---: | --- | --- | --- |
| `macos_import_ss.db` | 10 | `import_database_provider.dart` (`openDatabase(version: 10)`) | Versions 1-10 | Yes. Source registry, import ledger, Historical Archives, graph projection, current production, and attachment recovery |
| `working_ss.db` | 2 | `ConversationGraphDatabase.schemaVersion` | Versions 1-2, plus version-0 fixture handling | Yes. Current production and all browsing projections |
| `user_overlays.db` | 8 | `OverlayDatabase.schemaVersion` | Versions 1-8 | Yes. User-authored intent, preferences, archive metadata, archived-attachment records, and current production |
| `presence.db` | 9 | `PresenceDatabase.schemaVersion` | Versions 1-9 | Yes within the current architecture. Durable Presence and Onboarding state is preserved by Start Fresh, even though this production archive predates the file |
| Archive marker | format 1 | `ArchiveMarker.currentFormatVersion` | One current format | Yes. Archive identity and development/production admission |
| Archive checkpoint manifest | format 1 | `ArchiveCheckpointManifest.currentFormatVersion` | One current format | Yes. Checkpoint verification |
| Production adoption inventory | format 1 | `ProductionArchiveAdoptionInventory.currentFormatVersion` | One current format | Yes. Production cutover evidence |
| Complete-installation erase transaction | format 1 | `CompleteInstallationEraseTransaction.currentFormatVersion` | One current format | Yes. Crash-safe destructive-operation recovery |
| Onboarding operation snapshot | format 1 | `OnboardingOperationSnapshot.currentFormatVersion` | One current format | Yes. Durable Onboarding progress and reconciliation |
| Attachment controlled-loss manifest | schema 1 | `generate_message_lens_attachment_recovery_controlled_loss_manifest.dart` | One tool format | Yes for the bounded recovery procedure; not an application database |
| Database health report | schema `1.0.0` | `database_health_audit_service.dart` | One report format | Diagnostic contract only |
| Source registry | part of import schema 10 | `source_registry` in `macos_import_ss.db` | Follows import-store schema | Yes. Canonical source-scoped identity and lineage |
| Attachment archive payloads | no independent format number | Filesystem archive plus import/graph/overlay metadata | No payload migration chain | Yes. Preservation data; never a reset/rebuild target |
| Preferences and window/sidebar state | no independent serialization version found | Overlay settings and preferences repositories | Key-specific evolution | Yes. Current production contains durable user state |

No separate search/index SQLite schema authority was found. Search and coverage
queries consume the source-scoped import and graph stores. No checked-in Drift
schema snapshot directory or `.drift` migration bundle exists; build-tool JSON
under `.dart_tool` is generated cache, not a repository compatibility contract.

## Migration Archaeology

### Source-Scoped Import Database

Authority:

```text
lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart
```

| Version | Change represented |
| ---: | --- |
| 1 | Initial source registry, import batches, and source-scoped messages |
| 2 | Chats and chat-to-message relationships |
| 3 | Chat schema rebuild |
| 4 | Further chat schema correction/rebuild |
| 5 | Handles and chat-to-handle relationships |
| 6 | Contacts and contact channels |
| 7 | Expanded source/semantic fields |
| 8 | Attachments and message-to-attachment relationships |
| 9 | Incremental-update indexes |
| 10 | Canonical `handles.is_me` identity |

Versions 1-5 appeared during the source-scoped proof of concept in May 2026;
versions 6-8 followed during the same development cycle; version 9 appeared in
June; version 10 appeared on July 26. They post-date the April tester build and
were not part of its legacy database generation.

`onCreate` already constructs the complete version-10 schema. The v1-v9 chain
is therefore upgrade archaeology, not required to create a new current store.

### Conversation Graph Database

Authority:

```text
lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart
```

| Version | Change represented |
| ---: | --- |
| 1 | Initial current source-scoped Conversation Graph schema |
| 2 | Canonical `handles.is_me` identity |

The current Drift migration uses additive current-schema creation for both
creation and upgrade. Version 2 appeared on July 26. New stores already receive
the complete version-2 shape.

### Overlay Database

Authority:

```text
lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart
```

| Version | Change represented |
| ---: | --- |
| 1 | Original overlay/user-intent schema |
| 2 | Archived attachment records |
| 3 | Message user flags and tags |
| 4 | Retired nickname field removed |
| 5 | Graph-message intent overlays |
| 6 | Retired contact naming fields removed |
| 7 | Conversation tags and assignments |
| 8 | Visibility policy |

Overlay versions 1-3 include history that reached the April tester generation,
but that tester is not upgraded: it is recognized only by the exact legacy
`4/3/3` installation fingerprint and deleted after explicit authorization.
Versions 4-8 are development/current-production evolution. `onCreate` already
creates the full version-8 schema.

### Presence Database

Authority:

```text
lib/essentials/presence/infrastructure/data_sources/local/presence_database.dart
```

| Version | Change represented |
| ---: | --- |
| 1 | Initial Presence definitions and execution state |
| 2 | Fixed-destination routing |
| 3 | Full Disk Access test support |
| 4 | Append-only execution trace |
| 5 | Open-FDA-settings step support |
| 6 | Contacts-readiness support |
| 7 | Generic Test-step grammar |
| 8 | Generic Test activation |
| 9 | Choice-step schema |

Versions 1-8 were introduced during the August 13 Presence consolidation;
version 9 followed on August 14. This is entirely development-era history. A
new database is created directly at version 9.

That does not make an immediate renumber safe or valuable. Current development
and staging archives may carry durable version-9 Journey history, and Start
Fresh intentionally preserves Presence. The current production archive happens
not to contain `presence.db`; that absence is not authority to discard Presence
state elsewhere.

## What Actually Shipped

The only earlier tester generation established by the release and legacy audit
is `0.1.16+17` from April 27, 2026:

```text
macos_import.db    4
working.db         3
user_overlays.db   3
```

It had:

- no current archive marker;
- no `macos_import_ss.db`;
- no `working_ss.db`;
- no `presence.db`.

`ReadOnlySqliteLegacyTesterInstallInspector` requires that exact file,
version, and table fingerprint. The supported behavior is deletion and fresh
Onboarding, not migration into the source-scoped architecture.

Repository history contains many intermediate modern versions, but no evidence
establishes them as supported tester distributions. An ad hoc development build
cannot be disproved from Git history alone; it also does not create a product
compatibility promise. If a future support decision admits such an archive, it
must do so from a positive fingerprint, not by retaining every development
migration indefinitely.

## Read-Only Production Evidence

The production archive marker is valid format 1:

```text
environment: production
archive instance: b81abc1e-e5ea-4d5a-bea7-1d4126e0c01a
```

### Active stores

| Store | Version | Integrity | Material evidence |
| --- | ---: | --- | --- |
| `macos_import_ss.db` | 10 | `quick_check=ok`, `integrity_check=ok` | 137,602 messages; 40,346 attachments; 261 handles; 258 chats; 113 contacts; 2 source registrations |
| `working_ss.db` | 2 | `quick_check=ok`, `integrity_check=ok` | 137,602 messages; 40,346 attachments; 261 handle aliases; 223 canonical handles; 258 chats; 97 contacts |
| `user_overlays.db` | 8 | `quick_check=ok`, `integrity_check=ok` | 33,741 archived-attachment records; 38 favorites; 12 dismissed handles; 8 conversation assignments; 4 conversation tags; 26 settings records |
| `presence.db` | absent | Not applicable | This production installation predates the current Presence store |

The production archive also contains approximately 36 GB / 26,414 files in
`attachment_archive/`. Those files and their overlay metadata are preservation
data, not rebuildable cache.

The overlay contains user-authored and operational state, including favorites,
tags, participant overrides, message flags, window/sidebar preferences,
diagnostic state, archive workflow metadata, and Onboarding failure/result
records. The keys `onboarding_last_import_result` and
`onboarding_last_migration_result` remain active in
`OverlayOnboardingFailureStorage`; they are not stale solely because their names
sound historical.

### Retained old files

The production root also contains:

| File | Version | Current runtime role |
| --- | ---: | --- |
| `macos_import.db` | 4 | Retired generation; retained as evidence/cleanup input |
| `working.db` | 3 | Retired generation; retained as evidence/cleanup input |
| `macos_import_shadow.db` | 10 | No active filename reference found |
| `working_shadow.db` | 3 | No active filename reference found |
| `user_overlays.db.before-stale-failure-clear` | 3 | No active filename reference found |

The current marker and current stores prevent this production root from being
mistaken for an April legacy install. The shadow/backup files are plausible
filesystem cruft, but removing production residue is a separate checkpointed,
explicitly authorized operation. It is not part of schema-baseline cleanup.

## Why Renumbering Is Not A Pure Code Cleanup

At the physical schema level, the current table shapes do not need rewriting.
SQLite can change `PRAGMA user_version` without rewriting every row. That makes
the proposal look like a pure version relabel, but the application-level
consequences are broader:

1. `sqflite` would open a version-10 import database with requested version 1
   as a downgrade, not as the same schema under a prettier name.
2. Drift would see on-disk versions 2, 8, and 9 as newer than the code's
   `schemaVersion` 1 and enter downgrade/unsupported-version behavior.
3. `SqliteMessageLensInstallationEvidenceReader` currently admits versions
   through `10/2/8/9`. Changing its maxima to 1 would classify current archives
   as unsupported until every relevant file was relabelled.
4. Attachment recovery intentionally recognizes historical pre-marker tuples
   `(8,5,1)`, `(9,5,1)`, and `(10,1,2)`. Those numbers are evidence, not merely
   local implementation counters.
5. Start Fresh rebuilds import and graph stores but preserves overlay and
   Presence. It cannot incidentally normalize every store to a new numbering
   system.
6. A crash between relabelling individual stores could leave a mixed tuple that
   neither old nor new code admits.

A safe relabel would therefore require a one-time, archive-wide adoption
operation with:

- exact physical-schema fingerprints;
- archive mutation authority;
- a checkpoint and rollback/convergence contract;
- all-store atomicity or durable resumability;
- updated installation classification;
- updated recovery qualification;
- tests for interruption at every store boundary.

That machinery would introduce more risk and cognitive load than retaining four
non-pretty integers.

## Generated Code And Test Consequences

Changing only Drift `schemaVersion` constants does not inherently require a new
table-generated API. There are no checked-in Drift schema snapshots to rebase.
Code generation would still be run because the annotated database inputs
changed, but the generated table surface should remain structurally identical.

The important cost is migration behavior and tests:

- source import provider test: 901 lines;
- graph database test: 282 lines;
- overlay database test: 564 lines;
- Presence v5 migration test: 169 lines;
- Presence v7 migration test: 521 lines;
- Presence v9 migration test: 287 lines.

These files contain roughly 2,724 lines in total. Not all are disposable:
current-schema creation, constraints, and repository behavior still need tests.
The migration-specific corpus is approximately 1,300-1,500 lines and would need
replacement coverage for:

- fresh current-schema creation;
- exact modern-baseline admission;
- fail-closed handling below the supported baseline;
- fail-closed handling above the supported version;
- legacy `4/3/3` recognition;
- historical recovery-donor recognition.

The migration implementations themselves contain roughly 150 immediately
visible version-gated lines, plus helper methods and migration-specific semantic
logic. Removing them later would be a meaningful simplification; renumbering is
not required to obtain that benefit.

## Feature And Recovery Consequences

### Historical Archives and source identity

Historical Archives depends on the current source registry and source-scoped
message schema. It is mostly structurally qualified, but import and graph
repositories expect the current tables and canonical source identity. No
benefit arises from calling that structure version 1.

### Attachment recovery

The recovery donor qualifier intentionally preserves these pre-marker tuples:

```text
(import 8, overlay 5, graph 1)
(import 9, overlay 5, graph 1)
(import 10, overlay 1, graph 2)
```

The domain also names import donor generations 8, 9, and 10. These must remain
as historical read-only evidence even if current migration code below the
modern baseline is removed.

Marked current archives use archive identity plus structural read-only
validation rather than one universal exact database tuple. Marker format 1 is
independent of database schema renumbering and has no reason to change.

### Message History Coverage

Coverage consumes the current source registry and graph projection. It does not
introduce a separate schema generation. Its correctness depends on source
identity and current table structure, not on numerically rebasing those stores.

### Start Fresh and Complete Erase

Start Fresh deletes/rebuilds only enumerated derived stores and preserves
overlay, Presence, archive identity, and attachment preservation data. A
version-number transition cannot rely on Start Fresh to make the archive
uniform.

Complete Erase is a deliberately destructive clean-install operation, not a
normal schema adoption path. It cannot justify invalidating a healthy archive
for version aesthetics.

### Legacy tester deletion

The exact `4/3/3` constants, table fingerprints, tests, and retired filenames
remain required safety authority. They are not migration support and are not
cruft.

## Cruft Inventory

| Cruft candidate | Why it exists | Still reachable? | Safe to remove now? | Risk |
| --- | --- | --- | --- | --- |
| Import v1-v9 upgrade branches | Source-scoped architecture evolved in development | Reachable if an intermediate DB is opened | **Not before release.** Candidate for post-release baseline freeze | Removing without explicit lower-version rejection could produce ambiguous opens or unsupported ad hoc archives |
| Graph v0/v1 upgrade handling | Early graph fixtures and development stores | Reachable by migration tests and old dev archives | **Not before release.** Candidate for baseline freeze | Graph is rebuildable, but asymmetric treatment complicates classifier and tests |
| Overlay v1-v7 migrations | Long-lived overlay evolution | Reachable by old dev DBs; April v3 is handled separately by deletion | **Not before release** | Overlay contains irreplaceable user intent and preservation metadata |
| Presence v1-v8 migrations | Rapid Presence development | Reachable by current development/staging archives | **Not before release.** Strong post-release candidate | Start Fresh preserves Presence; losing Journey history would violate current semantics |
| Migration-specific tests | Protect the above paths | Yes | Replace only alongside an approved baseline freeze | Wholesale deletion would remove current-schema and safety coverage |
| Legacy `4/3/3` inspector/constants/tests | Positively recognizes the shipped April tester | Yes, at startup on unmarked production roots | **No** | Removal would eliminate the only safe authorization boundary for legacy deletion |
| Pre-marker attachment donor tuples and enums | Qualify real recovery donors | Yes | **No** | Historical payload recovery would be lost or weakened |
| Retired `macos_import.db` / `working.db` filenames | Legacy inspection, diagnostics, and enumerated cleanup | Yes | **No** | Deletion could break legacy containment and health reporting |
| Shadow database files in the production root | Earlier shadow/rebuild experiments | No active runtime filename reference found | Code/docs may be reviewable later; files require a separate authorized cleanup | Production mutation and forensic-evidence loss |
| `user_overlays.db.before-stale-failure-clear` | One-time production backup | No active runtime filename reference found | Not in this cleanup | Could be the only rollback/forensic copy |
| Archive marker/checkpoint/adoption/erase format 1 contracts | Current archive safety system | Yes | **No** | Breaks admission, recovery, or destructive-operation convergence |
| Onboarding operation snapshot format 1 | Durable operation reconciliation | Yes | **No** | Breaks restart-safe Onboarding |
| Onboarding last-result overlay keys | Failure/recovery history | Yes; current storage and tripwires reference them | **No** | Would silently remove typed failure evidence |
| Generated `.dart_tool` Drift JSON | Build cache | Recreated by tooling | Not a repository cleanup target | Deleting it provides no source simplification |
| Stale historical documentation | Records development decisions | Historical evidence | Mark historical rather than delete wholesale | Erases rationale still needed for forensic work |
| Duplicate database-opening helpers | Suspected from age/name alone | No inappropriate duplicate current-store authority found | No candidate established | One-off source/probe read-only openers are intentional and close before returning |

## Per-Store Verdicts

| Store | Verdict | Reason |
| --- | --- | --- |
| `macos_import_ss.db` | **KEEP CURRENT VERSION (10)** | Live production source ledger, Historical Archives, recovery tuples, and sqflite downgrade behavior make relabelling high risk |
| `working_ss.db` | **KEEP CURRENT VERSION (2)** | Rebuildable, but part of current archive classification and recovery evidence; isolated renumbering has negligible benefit |
| `user_overlays.db` | **KEEP CURRENT VERSION (8)** | Contains irreplaceable user intent and attachment-preservation metadata; must not be subjected to an aesthetic adoption operation |
| `presence.db` | **KEEP CURRENT VERSION (9)** | Entire history is development-era, but current durable state is preserved across Start Fresh and may exist in staging/development archives; release-eve churn has no compensating value |

Current production therefore blocks an all-store rebase. Even though no row
transformation is required, three valuable live databases would need a risky
coordinated version adoption. Presence cannot justify breaking symmetry or
introducing a separate one-off policy merely because it is absent from this one
production root.

## Clean Baseline Model

The recommended clean baseline is conceptual rather than numeric:

```text
First supported modern MessageLens persistence generation

  source-scoped import: 10
  Conversation Graph:    2
  overlay:               8
  Presence:              9
```

After the first `0.2.99+117` cohort is established:

1. Document `10/2/8/9` as the minimum supported modern tuple.
2. Preserve April `4/3/3` only in the exact legacy inspector and fixtures.
3. Preserve attachment recovery donor tuples only in recovery qualification and
   fixtures.
4. Replace lower-version migration chains with explicit unsupported-generation
   outcomes, unless a positively identified real archive requires one.
5. Keep each complete `onCreate` definition as the single current physical
   schema authority.
6. Let the next real shipped schema change increment the existing number.

This produces the desired hard separation between supported history and build
history without rewriting live archive metadata.

## Cost And Benefit

### Renumber-to-1 proposal

Estimated work:

- four database authorities and their generated outputs;
- installation evidence/classification;
- archive-wide adoption/relabel operation;
- recovery donor qualification;
- Start Fresh and restart convergence;
- migration and interruption tests;
- release and support documentation.

Risk: high. Benefit: cosmetic version symmetry plus a misleading appearance
that the architecture has no history.

### Baseline-freeze proposal

Estimated eventual simplification:

- roughly 150 direct version-gated migration lines plus related helpers;
- approximately 1,300-1,500 migration-focused test lines replaced by a smaller
  current-baseline/support-boundary suite;
- four clearer store contracts;
- simpler documentation that distinguishes exact legacy/recovery evidence from
  current supported opening behavior.

Risk: moderate if done after release with positive support evidence. Benefit:
real reduction in future reasoning and accidental support of arbitrary
development databases.

## Release Timing

**Ship `0.2.99+117` as-is.**

The release candidate has already been built, signed, notarized, stapled, and
verified. A version rebase would invalidate that evidence and introduce a new
archive-adoption surface immediately before tester distribution. The stop
conditions in Prompt 25 are met:

- production would require a coordinated relabel;
- version numbers participate in recovery evidence and installation support;
- overlay/preservation state cannot be discarded;
- cleanup would require broad archive-transition machinery.

The persistence baseline should be cleaned immediately after release, but by
freezing the existing tuple, not by renumbering it.

## Recommended Next Implementation Slice

After `0.2.99+117` is published and the first tester installs are observed:

1. Create a support-matrix document declaring:
   - modern baseline `10/2/8/9`;
   - legacy deletion fingerprint `4/3/3`;
   - attachment recovery donor tuples `8/5/1`, `9/5/1`, and `10/1/2`.
2. Add focused tests proving:
   - exact modern baseline opens;
   - future versions fail closed;
   - unsupported lower modern versions fail closed;
   - legacy and recovery fingerprints remain separately recognized.
3. Remove one store's pre-baseline migration chain at a time, starting with
   Presence because its v1-v8 history is purely developmental.
4. Retain current version numbers and current `onCreate` schemas.
5. Run release-shaped archive classification, Start Fresh, recovery, and
   Onboarding verification after each store is simplified.

This slice should not delete shadow/backup files from any real archive. A
separate production-residue audit may inventory them and propose a checkpointed
cleanup if there is a concrete operational benefit.

## Verification

The focused valid schema/archive suite completed with 91 passing tests after a
mistyped nonexistent test path in the first command was removed. Coverage
included:

- source-scoped import schema/provider behavior;
- Conversation Graph creation and migration behavior;
- overlay creation and migration behavior;
- Presence v5, v7, and v9 migrations;
- installation evidence classification;
- legacy tester recognition;
- Historical Archives and attachment-recovery qualification.

Production SQLite inspection used immutable/read-only connections and reported
`quick_check=ok` and `integrity_check=ok` for every active production database.
No destructive migration experiment was run.

## Final Answer

MessageLens can honestly define a first supported modern persistence baseline,
but that baseline should be **the current tuple `10/2/8/9`, not four databases
renumbered to `1`**.

The valuable cleanup is deletion of unsupported development migration paths
after the tester release, while preserving exact historical evidence wherever
real data may still be encountered. Renumbering would add a dangerous adoption
problem without reducing the underlying complexity.
