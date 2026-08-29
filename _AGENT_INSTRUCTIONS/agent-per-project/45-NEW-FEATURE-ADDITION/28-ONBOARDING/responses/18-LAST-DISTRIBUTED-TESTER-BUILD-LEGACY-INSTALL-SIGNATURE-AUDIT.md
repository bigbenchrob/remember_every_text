---
tier: project
scope: last-distributed-tester-build-legacy-install-signature-audit
owner: agent-per-project
last_reviewed: 2026-08-29
source_of_truth: forensic-audit-record
links:
  - ../prompts/21-LEGACY-INSPECTION.md
  - 16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA-IMPLEMENTATION.md
---

# Last Distributed Tester Build Legacy Install Signature Audit

## Decision

The last tester-distributed artifact was **MessageLens 0.1.16, build 17**, with
bundle identifier `com.bigbenchsoftware.MessageLens`. The website published it
on April 27, 2026 as a production tester build.

The persistent data created by this build does not contain its app version or
build number. Current Onboarding therefore cannot prove from a data folder
alone that one particular folder was written by exactly `0.1.16+17`.

It can, however, recognize the narrow pre-source-scoped database generation to
which that build belongs. The recommended gate requires positive fingerprints
for all three legacy databases, excludes every current archive/database
signature, admits only the canonical production root in restricted erase-only
mode, and requires explicit human authorization before deletion.

This is sufficient for the three known early testers. It does not justify a
general historical migration or destructive-installation taxonomy.

## Safety And Method

The distributed DMG was mounted read-only and never launched. The audit used:

- the DMG bundle metadata and code-signing metadata;
- the tester website's build and changelog records;
- the project Git history around the publication time;
- the matching source tree's database definitions and persistence paths;
- the current archive-admission and installation-classification code.

The DMG checksum was verified with `hdiutil` and the volume was detached after
inspection. No application data, website content, DMG content, current archive,
Apple source database, or application code was modified.

## Distributed Build Identity

| Evidence | Result |
| --- | --- |
| DMG | `/Users/rob/Development/website/MessageLens/assets/downloads/MessageLens-latest.dmg` |
| DMG SHA-256 | `f679faf410dd8d691e51993716153f141beceea71063b44a43ad546c8dcfbb02` |
| DMG integrity | `hdiutil verify` passed |
| App bundle | `MessageLens.app` |
| Bundle identifier | `com.bigbenchsoftware.MessageLens` |
| Short version | `0.1.16` |
| Build number | `17` |
| Executable architectures | `arm64`, `x86_64` |
| Website channel | `Production tester build` |
| Website publication time | April 27, 2026 at 11:45 AM PDT |
| Website publication commit | `9c12e0b7b36e25e8b34db492bfe5a4520de80523` |
| Data reset advertised | Not required |

The bundle contains a hardened-runtime code signature with Team ID
`FQHT2QP3NE` and designated identifier
`com.bigbenchsoftware.MessageLens`. Its recorded CDHash is
`8ebeb386293486927e3ca6f74b1857ef1321df7c`. Strict `codesign` verification of
the app as stored in the DMG failed, and `stapler` could not validate the
mounted bundle. The audit therefore does not claim independently proven
notarization or a currently valid sealed signature. That finding does not
affect the persistent-data analysis.

## Source Revision Evidence

The strongest matching source revision is:

```text
479f75b0d3e939e06783af2c67055a1d3bb94b1e
2026-04-27 11:43:43 PDT
refine sidebar settings and window stability
```

Evidence:

- its `pubspec.yaml` declares `0.1.16+17`;
- it is the final repository commit before the DMG's 11:45 publication time;
- the tester website was updated at 11:47 to publish `0.1.16`;
- the website changelog describes the same sidebar and window-stability work;
- no later repository commit predates the distributed artifact.

The bundle does not embed a Git hash, so this is a **probable matching
revision**, not cryptographic proof that the build tree contained no local
uncommitted changes.

## Legacy Production Root

The build obtained its root from `getApplicationSupportDirectory()`. With the
distributed production identity, the expected normal root was:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens/
```

The three primary stores were:

```text
macos_import.db
working.db
user_overlays.db
```

SQLite could also leave normal `-wal` and `-shm` sidecars beside these files.

### Database Generation

| Database | Technology | Version | Positive structural evidence |
| --- | --- | ---: | --- |
| `macos_import.db` | Sqflite | 4 | `schema_migrations`, `import_batches`, `source_files`, `import_logs`, `contacts`, `handles`, `chats`, `messages`, `attachments`, reactions and join tables |
| `working.db` | Drift | 3 | projection state/settings, canonical handles, participants, chats, messages, message indexes, attachments, reactions, read state and sync tables |
| `user_overlays.db` | Drift | 3 | overrides, annotations, flags, tags, virtual participants, overlay settings, favourites, visibility/dismissal state and archived-attachment metadata |

The same `4/3/3` schema generation is present in the immediately preceding
`0.1.14` and `0.1.15` source trees. Database evidence therefore identifies a
narrow legacy generation, not uniquely version `0.1.16`.

## Persistent Artifact Inventory

| Artifact | Exists in old tester build? | Name or path | Meaning | Still current? |
| --- | --- | --- | --- | --- |
| Import database | Yes | `macos_import.db` | Single-source import ledger and imported source records | No; retired derived file |
| Working/graph database | Yes | `working.db` | UI projection and conversation graph | No; retired derived file |
| Overlay database | Yes | `user_overlays.db` | User intent, preferences, onboarding failure summaries, attachment archive metadata | Filename remains current; old schema v3 is not current |
| Presence database | No | `presence.db` | Current durable Presence/Schedule state | Yes, current-only |
| Archive marker | No | `.messagelens-archive.json` | Current archive environment and identity | Yes, current-only |
| Attachment archive | Supported, lazily created | `attachment_archive/` | MessageLens-preserved attachment payloads | Yes; preservation data |
| Derived media | Supported, lazily created | `derived_media/video_thumbnails/` | Rebuildable video thumbnails | Yes |
| Pipeline logs | Created when relevant | `import_log`, `migrate_log`, `pipeline_incident_log` in the archive root | Import/migration diagnostics | Current logging organization has changed |
| App log | Created during normal logging | `~/Library/Logs/MessageLens/app.log` and `app.log.1` | Rotating application diagnostics outside the archive root | Historical location |
| Shared preferences | Used | Platform SharedPreferences store for bundle identity | Window geometry and search-index metrics | The mechanism existed outside the archive root |
| Typed onboarding operation snapshot | No | None | Current durable operation stage/progress/failure | Yes, current-only |
| Legacy onboarding evidence | Yes, when recorded | `onboarding_last_import_result` and `onboarding_last_migration_result` rows in `user_overlays.db` | Last import/migration result, not a complete operation snapshot | No |
| Source registry | No | No `source_registry` table | Current source-scoped identity and lineage | Yes, current-only |
| Legacy source metadata | Yes | `import_batches` and `source_files` in `macos_import.db` | Run/file metadata without current source-scoped registry semantics | No |
| Source-scoped import database | No | `macos_import_ss.db` | Current multi-source import ledger | Yes, current-only |
| Current graph database | No | `working_ss.db` | Current source-scoped graph projection | Yes, current-only |
| Instance lock | No evidence | `MessageLens.instance.lock` absent from matching tree | Current single-process archive lock | Yes, current-only |

An old installation could legitimately have either of these shapes:

```text
legacy databases only
```

or:

```text
legacy databases
+ attachment_archive/
+ derived_media/
+ one or more diagnostic logs
```

The optional directories depended on feature use and attachment availability.

## Current Versus Legacy Shape

The important architectural transition is not one missing folder. It is the
replacement of a single-source, unmarked data root with an admitted,
source-scoped archive:

| Concern | Legacy tester generation | Current generation |
| --- | --- | --- |
| Archive identity | Inferred from Application Support path | Format-v1 `.messagelens-archive.json` plus native claim/admission |
| Import storage | `macos_import.db` v4 | `macos_import_ss.db` with `source_registry` |
| Graph storage | `working.db` v3 | `working_ss.db` |
| Overlay | `user_overlays.db` v3 | `user_overlays.db` with current schema |
| Presence | None | `presence.db` |
| Onboarding durability | Last result summaries only | Typed durable operation snapshot |
| Historical source identity | No canonical source registry | Source-scoped lineage and registration |
| Mutation authority | Maintenance lock and feature orchestration | Archive admission plus typed mutation authority |

## Candidate Signature Audit

### Missing `attachment_archive/`

**Rejected.** The old build already supported the archive but created payload
directories only when archiving occurred. A current virgin installation or a
current installation that has never preserved an attachment may also lack the
directory. Its absence is neither positive legacy evidence nor safe deletion
authority.

### Missing `.messagelens-archive.json`

**Rejected alone.** Every old tester install lacks the marker, but so can a
damaged current installation or a non-MessageLens directory. Absence proves
only that ordinary current archive admission cannot proceed.

### Presence of old filenames

**Insufficient alone.** Current code recognizes `macos_import.db` and
`working.db` as retired derived artifacts. They may remain after an upgrade or
interrupted cleanup. The unchanged overlay filename is especially ambiguous
without its schema fingerprint.

### Exact legacy database trio and schema fingerprints

**Strong positive evidence.** Requiring all of these narrows the root to the
legacy generation:

- readable `macos_import.db`, schema version 4, with its required legacy
  ledger tables;
- readable `working.db`, schema version 3, with its required projection
  tables;
- readable `user_overlays.db`, schema version 3, with its required overlay
  tables;
- no current source-scoped import or graph database;
- no current Presence database;
- no archive marker.

This should be evaluated read-only and without opening the databases through
ordinary current providers, which could migrate or reinterpret them.

## False-Positive Analysis

| Candidate condition | Healthy current installation | Ordinary Start Fresh | Damaged current installation | Other historical generation |
| --- | --- | --- | --- | --- |
| Missing attachment archive | Possible | Possible | Possible | Possible |
| Missing marker | No | No; marker is preserved | Possible | Expected before marker architecture |
| One retired DB exists | Possible after upgrade | Possible if already present | Possible | Likely |
| Legacy trio exists | Possible only as upgrade residue alongside current evidence | Start Fresh does not restore overlay to v3 or remove the marker | Possible after severe/manual damage | Possible |
| Legacy trio has exact `4/3/3` schema/table fingerprints and all current identity/stores are absent | Not a normal healthy state | Not produced by Start Fresh | Theoretical after highly specific destructive damage | Yes, for adjacent pre-marker builds in the same generation |

No persistent fact in this generation records `0.1.16+17`. The narrowest honest
claim is therefore:

> This is a legacy, pre-marker, pre-source-scoped MessageLens installation of
> the database generation used by the last tester-distributed build.

The residual false-positive is a current root damaged into exactly that old
shape or another pre-marker build with the same schemas. For this cohort, both
are bounded by the same product truth: the three known testers have disposable
test data and must explicitly authorize deletion. The gate must not silently
delete anything.

## Recommended Smallest Discriminator

Define one bounded classification, not a generalized historical taxonomy:

```text
canonical production MessageLens root
+ root is non-empty and unmarked
+ macos_import.db has the exact legacy-v4 fingerprint
+ working.db has the exact legacy-v3 fingerprint
+ user_overlays.db has the exact legacy-v3 fingerprint
+ macos_import_ss.db is absent
+ working_ss.db is absent
+ presence.db is absent
-------------------------------------------------------
legacyTesterInstall
```

Additional root contents such as `attachment_archive/`, `derived_media/`,
logs, SQLite sidecars, or unknown old files neither establish nor invalidate
the classification.

The resulting authority must be restricted:

- no ordinary database provider may open the legacy stores;
- no migration may run;
- no logger or feature may treat the root as a current admitted archive;
- only the legacy inspection and explicitly authorized erase path may use the
  classification;
- cancellation or inspection failure must leave every file untouched.

## Product Recommendation

The three early testers can be handled by a narrow Onboarding path:

1. detect `legacyTesterInstall` using the positive read-only fingerprint;
2. explain that MessageLens found data from an older test version;
3. state that Apple Messages and Contacts are not affected;
4. request explicit permission to delete the old MessageLens-owned data;
5. on authorization, erase only the exact canonical MessageLens root under
   archive mutation authority;
6. establish a fresh current archive identity;
7. mechanically verify virgin installation state;
8. continue through ordinary Onboarding.

No migration or preservation of this cohort's old MessageLens state is
required.

The generalized Complete Erase implementation is **not required for this
tester rollout**. Keep its code quarantined while the narrow gate is built and
validated, but hide it from the tester-facing rollout. Do not use broad
"non-empty unmarked production root" admission as a substitute for the
positive legacy signature. Removal of the generalized feature can be decided
separately after the narrow path has been proven.

## Exact Next Implementation Slice

Implement only a read-only `LegacyTesterInstallInspector` and its startup
projection:

1. accept only the canonical production archive root carried by the native
   claim;
2. inventory only the named current and legacy root artifacts;
3. open the three legacy databases read-only without current database
   providers or schema migration;
4. verify exact schema versions and required table fingerprints;
5. return a typed `legacyTesterInstall` result only when every positive and
   negative condition matches;
6. otherwise preserve the current fail-closed remediation behavior;
7. replace the broad erase-only admission trigger with this typed proof;
8. add tests for healthy current, ordinary Start Fresh, partial legacy,
   schema-mismatched legacy, current-plus-retired residue, markerless damaged
   current, and exact legacy fixture shapes with and without optional archive
   directories;
9. expose one explicit Onboarding authorization surface for the three-testers
   cohort;
10. do not change the current database schemas or add migration behavior.

STOP before implementing deletion until the inspector and its false-positive
tests have been reviewed.

## Conclusion

The April tester DMG is well identified. Its source tree and persistent shape
are recoverable with high confidence. The old build already included attachment
preservation and derived media, so missing folders cannot be used as a gate.

The safe discriminator is the complete positive `macos_import.db` v4 +
`working.db` v3 + `user_overlays.db` v3 fingerprint, combined with absence of
all current archive identity and database artifacts. That is narrow enough for
the three known testers when paired with explicit authorization, while
remaining honest that the data folder cannot prove one exact app build.
