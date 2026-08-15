---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: proposal
status: implemented-through-non-production-boundary
links:
  - ./README.md
  - ./CURRENT-STATE-AUDIT.md
  - ../../00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ../../../10-DATABASES/00-all-databases-accessed.md
  - ../../../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# Production Data Protection Proposal

## Purpose

This proposal defines the architectural boundary that prevents development,
tests, experiments, and incomplete maintenance workflows from mutating the
permanent MessageLens archive.

It responds to the verified current-state finding:

> A normal debug launch can resolve and mutate the production MessageLens
> archive.

The goal is not to make production read-only. Production must continue to
receive live synchronization and approved archive operations. The goal is to
ensure that every production write follows mechanically from an admitted
production identity and an authorized production operation.

This document remains the architectural owner of the boundary. Slices 0-8 are
implemented and validated without contacting the production archive.
Production marker adoption remains separately prohibited.

## Governing Decision

> **Archive identity must be explicit, immutable for the life of the process,
> and resolved before any app-owned persistent resource becomes writable.**

MessageLens will distinguish:

- build mode;
- bundle and signing identity;
- archive environment;
- archive instance;
- writable data root;
- application-process admission;
- operation-specific mutation authority.

None of these concepts substitutes for another.

In particular:

- `kDebugMode` is not an archive identity;
- a release build is not automatically safe;
- Full Disk Access grants source-reading capability, not archive-write
  authority;
- opening a database provider does not authorize an arbitrary mutation;
- holding one operation lease does not authorize another operation.

## Mechanical Impossibility Target

The target invariant is:

> An ordinary development or test process cannot resolve, open, or mutate the
> production MessageLens archive.

This must remain true even if:

- a developer forgets to create a snapshot;
- a feature accidentally requests a production database provider;
- background synchronization starts automatically;
- a test invokes more application infrastructure than intended;
- a debug build has Full Disk Access;
- a second app copy is installed;
- an operation throws or the process exits unexpectedly.

Warnings and confirmations remain useful for deliberate production operations.
They are not the primary development/production boundary.

## Architecture Overview

```text
Build artifact identity
        +
Launch/test configuration
        ↓
Archive environment resolution
        ↓
Archive identity validation
        ↓
Application-process admission
        ↓
ArchiveAccessAuthority
        ↓
Environment-scoped providers and stores
        ↓
Operation-specific mutation authority
        ↓
Feature-owned mutation workflow
        ↓
Validation and durable operation evidence
```

Two different authorities are required:

1. **Archive access authority:** this process may open this archive root in this
   environment.
2. **Operation authority:** this workflow may perform this class of mutation
   now.

The first protects environments. The second protects the admitted archive from
conflicting or unreviewed operations.

## Archive Environments

### Production

Production is the environment entrusted with the permanent archive.

It retains:

- bundle identifier `com.bigbenchsoftware.MessageLens`;
- the established production signing team and identity;
- the existing production Application Support location;
- normal live synchronization;
- reviewed production maintenance workflows.

Production identity must not change merely to obtain development isolation.
Preserving it protects Full Disk Access continuity and the existing archive
location.

### Development

Ordinary development uses a distinct application identity and a distinct
writable root.

It may read:

- synthetic sources;
- privacy-safe fixtures;
- selected historical snapshots;
- the live Apple Messages and Contacts sources when separately granted
  read-only access.

It must write only to its development archive.

A development build that cannot resolve and validate its development root must
fail closed. It must never fall back to production.

### Test

Tests use an explicitly supplied temporary or in-memory archive.

A test environment has no default persistent root. If a test asks for a
persistent provider without first supplying a test archive identity and root,
construction fails.

This converts current test convention into a mechanical guarantee.

### Disposable experiments

An experiment is a disposable archive instance within the non-production
boundary, not an alternate route into production.

Experiments may use unique archive instance identifiers so several datasets can
coexist. They remain subordinate to the development/test identity and cannot be
promoted by copying their files over production.

## Build And Application Identity

### Required configuration model

The macOS project must provide explicit application configurations for:

| Configuration class | Archive environment | App identity | Writable root |
| --- | --- | --- | --- |
| Production distribution | Production | Stable production bundle/signing identity | Existing production root |
| Ordinary debug/profile | Development | Distinct development bundle identity | Development root |
| Optimized local development testing | Development Profile | Distinct development identity | Development root |
| Unit/widget/integration test | Test | Test harness identity | Explicit temporary/in-memory root |

The exact scheme and flavor names are implementation details. The invariant is
not. The current implementation uses Debug and Profile for development.
Release remains production-shaped and cannot receive production authority
unless native production-signature validation succeeds. A separate
development Release configuration was not needed to establish the boundary.

An ordinary `flutter run -d macos` must select development. The production
build/notarization pipeline must explicitly select production.

### Cross-validation

Startup must validate that these facts agree:

- declared archive environment;
- effective bundle identifier;
- build configuration;
- canonical writable root;
- archive identity marker;
- native process-admission identity.

Examples of invalid combinations:

- development environment with the production bundle identifier;
- test environment with an Application Support root;
- production environment with an arbitrary path override;
- development process pointed at a production-marked archive;
- production process pointed at an unrecognized or development-marked root.

Invalid combinations terminate before persistent providers start.

Build mode alone is insufficient. Cross-validation makes configuration mistakes
visible rather than silently selecting the wrong archive.

## Archive Identity

### Resolved identity

Every process receives one immutable resolved archive identity containing at
least:

- environment (`production`, `development`, or `test`);
- archive instance identifier;
- canonical writable root;
- effective bundle identifier;
- build/configuration identity.

The resolved identity is created once during startup and injected into
infrastructure. The current mutable process-global directory path is not the
long-term authority.

### Archive marker

Each persistent archive root carries a small identity marker.

The marker records:

- archive environment;
- stable archive instance identifier;
- identity-format version.

It does not replace database schema versions and should not contain user data.

The marker protects against path mistakes:

- development refuses a production marker;
- production refuses a development marker;
- an existing marker cannot be silently rewritten to another environment;
- a missing or malformed marker follows an explicit adoption/recovery path.

### Existing production archive adoption

The current production archive predates the marker. Its adoption must be a
one-time, production-owned procedure that:

1. proves the root is the canonical existing production location;
2. inspects expected database/archive contents read-only;
3. records a pre-adoption recovery checkpoint;
4. writes the production identity marker;
5. verifies that subsequent production startup resolves the same identity.

A development build may never claim an unmarked existing root as development
when that path is the canonical production location.

## Startup And Admission

### Required order

The production-safe startup sequence is:

```text
1. Read immutable build/application identity
2. Resolve intended archive environment
3. Resolve canonical root
4. Validate root and archive marker
5. Acquire native one-process authority for that archive
6. Create ArchiveAccessAuthority
7. Initialize environment-scoped logging/preferences
8. Construct providers
9. Start background ingestion
10. Render the application
```

Before step 6, only console/ephemeral diagnostics and read-only identity probes
are allowed. No app database, attachment archive, persistent log, preference
store, window-state store, or background monitor may write.

### Process admission

The existing native pre-Flutter single-instance mechanism remains the correct
layer.

Its authority becomes archive-scoped:

> At most one admitted process may hold writable authority for one archive
> identity.

Production and development may run simultaneously because they own different
archive identities and roots. Two processes targeting the same environment and
archive instance must contend for the same native lock.

The lock path and running-application check must derive from the native
application/archive identity contract rather than remain hard-coded to
production.

Native admission and Dart archive validation must agree. Neither layer may
independently select a different archive.

## Provider And Store Boundaries

### Archive access authority

Every app-owned persistent provider consumes the resolved archive access
authority rather than a free global path.

This includes:

- source-scoped import database;
- Conversation graph database;
- overlay database;
- attachment archive;
- pipeline audit and incident evidence;
- persistent app logs;
- preferences and window state where they are archive/environment-sensitive.

The authority provides canonical locations. Feature code does not construct
paths or infer environments.

### Fail-closed construction

Persistent provider construction fails when:

- archive admission has not completed;
- identity validation failed;
- the requested store is outside the admitted root;
- a test did not supply a test root;
- the requested access conflicts with current maintenance authority.

There is no production fallback.

### Existing database ownership

Environment protection does not change database ownership:

- source import still owns imported source facts;
- graph projection still owns derived graph state;
- overlay still owns durable user intent;
- attachments still owns archived files and attachment integrity;
- logging still owns operational evidence.

The production-protection layer grants access and operation authority. It does
not become a database or feature mega-owner.

## Source Access

Apple-owned and user-supplied source databases remain read-only in every
environment.

Source authority is independent of archive authority:

```text
Development process
    may read live chat.db
    must write development archive

Production process
    may read live chat.db
    may write production archive through production workflows
```

Full Disk Access grants the operating-system capability to read protected
sources. It does not identify the writable MessageLens archive.

The development application identity may require its own FDA grant. That
additional setup is preferable to sharing production write identity.

Source database openers continue to enforce:

- read-only SQLite mode;
- query-only pragma;
- guarded read-only SQL;
- no mutation fallback.

## Operation-Specific Mutation Authority

### Governing rule

Archive admission answers:

> May this process open this archive?

Operation admission answers:

> May this workflow perform this mutation now?

Every significant mutation workflow must acquire named authority from one
coordinator before its first write and release it in `finally`.

### Initial protected operations

The contract must cover at least:

- live incremental source import and graph update;
- full graph build;
- onboarding import;
- reimport and automatic recovery;
- message-data reset;
- historical archive import;
- historical archive removal;
- attachment archive reconciliation;
- attachment archive clearing;
- schema/data migration requiring maintenance.

The first implementation should prefer conservative serialization over a
speculative compatibility matrix. Resource-specific concurrency may be
introduced later only with evidence that it is safe.

Ordinary overlay user-intent transactions remain owned by overlay services and
SQLite transaction semantics. If a maintenance operation requires overlay
exclusion, that requirement must be declared by the operation rather than
assumed.

### Coordinator responsibility

The coordinator:

- grants or rejects named operation authority;
- records owner, environment, archive identity, resource scope, and timing;
- exposes current authority to diagnostics;
- guarantees release on completion/failure.

It does not:

- perform imports;
- build the graph;
- reset databases;
- interpret attachment or overlay business rules.

Feature and essential owners continue to perform their operations.

### Existing mechanisms

`GraphMaintenanceExecutionGate` and `DbMaintenanceLock` are useful current
mechanisms, but their current coverage is incomplete.

Implementation planning must decide whether to evolve or replace them. The
architectural requirement is one complete admission chain, not preservation of
either current class.

## Production Mutation Classes

Not every production write requires the same ceremony.

### Routine production mutation

Examples:

- incremental import of newly arrived live messages;
- normal graph update;
- user-authored overlay intent.

Requirements:

- admitted production process;
- valid production archive authority;
- appropriate operation authority;
- source/provenance checks;
- transactional write behavior;
- post-operation evidence appropriate to the operation.

Routine sync does not require a new full snapshot for every polling cycle.

### High-risk production maintenance

Examples:

- destructive reset/reimport;
- schema or data migration with destructive potential;
- historical archive removal;
- attachment archive clearing/reconciliation;
- repair that rewrites durable archive metadata.

Requirements:

```text
Read-only analysis
  -> explicit change plan
  -> verified recovery evidence
  -> user/policy authorization
  -> exclusive operation authority
  -> controlled mutation
  -> post-commit validation
  -> durable completion evidence
```

An operation may not infer that "a backup probably exists."

## Snapshot And Recovery Evidence

### Recovery checkpoint

High-risk production maintenance requires a verifiable recovery checkpoint tied
to:

- production archive instance;
- checkpoint time;
- included data classes;
- excluded data classes;
- operation that requires it;
- validation result.

The checkpoint must account for:

- import database and sidecars;
- graph database and sidecars;
- overlay database and sidecars;
- archive-source metadata;
- attachment archive or an explicit independently verified attachment recovery
  source;
- operational evidence needed to explain the operation.

### Procedural compatibility

The current quit-and-`rsync` procedure remains the interim operational rule.
It is not yet mechanical recovery evidence.

The implementation phase may begin by producing and validating a manifest for
that procedure before introducing automated snapshots. The proposal requires
proof, not a particular backup technology.

### Recovery authority

Recovery is a production maintenance operation. It requires:

- an admitted production recovery mode;
- exclusive archive authority;
- a selected checkpoint;
- validation before normal providers/background sync resume.

Restoration must not occur beneath a running normal application process.

## Logging And Operational Evidence

Every significant operation record should include:

- archive environment and instance;
- application/build identity;
- operation name and owner;
- source identity;
- start/end time;
- admission result;
- counts, warnings, errors, and commit status;
- recovery checkpoint reference when required.

Development and production logs must not be silently mixed. Environment identity
must be visible in diagnostics and support bundles.

Pre-admission diagnostics use console or explicitly ephemeral storage so logging
cannot become the first accidental production write.

## Tests, Tools, And Agent Workflows

### Tests

Tests must receive an explicit test archive context.

Architecture tests should reject:

- normal Application Support resolution in test mode;
- persistent provider construction without a test root;
- production marker acceptance by test/development;
- direct database/path construction outside approved seams.

### Developer launch configuration

Repository launch configurations must default to development identity and root.
Production startup must require a deliberate production build/run path.

### Maintenance tools

Standalone scripts must use the same archive identity and admission contract or
operate only on explicitly supplied disposable/offline copies.

Hard-coded writable database paths are not an accepted production operation
interface.

### Agent workflow

Agents may inspect production code and read documentation freely. Any data
operation follows the selected environment:

- tests and experiments use disposable roots;
- read-only production diagnosis uses approved probes;
- production mutation occurs only through reviewed production workflows.

No instruction prompt or developer habit substitutes for the runtime boundary.

## Migration Strategy

The change must be introduced without moving or re-identifying the current
production archive accidentally.

### Phase 1: Identity infrastructure

- define environment and archive identity;
- add native/build configuration identities;
- resolve roots without opening stores;
- add archive marker reading and validation;
- preserve current production path unchanged.

### Phase 2: Development isolation

- make ordinary Debug/Profile/Development Release use development app identity;
- create the development root;
- update native locks and launch configurations;
- verify optional read-only FDA access for development;
- prevent production fallback.

This is the first phase that closes the primary escape path.

### Phase 3: Provider admission

- replace global free-path access with admitted archive authority;
- migrate databases, attachments, logging, preferences, and window state;
- prohibit pre-admission persistent writes;
- add architecture tripwires.

### Phase 4: Complete operation authority

- route monitor, onboarding, graph build, reset, historical archives, and
  attachment maintenance through one operation-admission contract;
- remove partial bypasses and duplicate local authority;
- add concurrency and failure tests.

### Phase 5: Recovery evidence

- verify or replace the snapshot procedure;
- add checkpoint manifests and post-restore validation;
- require evidence for high-risk production maintenance.

### Phase 6: Production adoption and validation

- snapshot the existing production archive;
- adopt it with a production marker through a reviewed procedure;
- verify production build/signing/FDA continuity;
- verify development can no longer resolve production;
- record completion evidence.

Each phase requires its own implementation plan and validation. No phase may
silently migrate production as a side effect of ordinary debug startup.

## Architectural Invariants

1. Production keeps its stable bundle/signing identity and existing archive
   location.
2. Ordinary development and test processes cannot resolve the production root.
3. Archive environment is explicit and immutable for the process lifetime.
4. Bundle/build/root/marker identities must agree before persistent providers
   start.
5. A missing development/test root never falls back to production.
6. One native process holds write admission for one archive instance.
7. Every app-owned persistent store derives its location from admitted archive
   authority.
8. Source databases remain read-only in every environment.
9. Significant mutations require named operation authority.
10. High-risk production maintenance requires verified recovery evidence.
11. Overlay/graph/import/attachment ownership remains with existing domain
    owners.
12. Development artifacts are never promoted by copying their archives over
    production.
13. Environment and operation identity appear in durable evidence.
14. Failure to prove safety stops startup or the operation before mutation.

## Non-Goals

This proposal does not:

- redesign onboarding;
- redesign source-scoped import or graph projection;
- choose a final automated backup technology;
- allow arbitrary production archive selection;
- make source databases writable;
- merge overlay and derived data lifecycles;
- make the Production Readiness project a runtime mega-owner;
- define all possible concurrent operation combinations;
- authorize a production migration.

## Decisions Required Before Implementation Planning

The architecture is stable, but implementation planning must settle:

1. the exact development bundle identifier, display name, schemes, and Flutter
   launch commands;
2. the native-to-Dart handoff for one agreed environment/archive identity;
3. the marker format and safe adoption ceremony for the existing production
   root;
4. whether environment-scoped preferences/logs use the archive root, bundle
   identity, or another explicitly derived location;
5. the initial conservative resource scope of the operation coordinator;
6. the minimum acceptable recovery checkpoint evidence for the first
   high-risk production operation.

These are implementation decisions within the proposed boundary. None should
reopen the requirement for mechanically isolated writable roots.

## Acceptance Criteria

The proposal is successfully implemented when objective tests can prove:

- `flutter run -d macos` cannot resolve the production archive;
- tests cannot resolve any persistent root without explicit injection;
- production retains its existing bundle/signing identity and archive;
- development and production can run concurrently without sharing writable
  state;
- two processes cannot acquire authority for the same archive;
- every persistent provider rejects pre-admission construction;
- all protected mutation entry points acquire operation authority;
- a failed or competing operation cannot proceed by omission;
- a high-risk production operation cannot commit without required recovery
  evidence;
- diagnostics identify the environment, archive, process, and operation;
- source databases remain read-only;
- recovery has been demonstrated from a verified checkpoint.

## Conclusion

The current code already centralizes most persistent resource construction.
That is the correct leverage point.

The required change is to place an explicit, validated archive identity and
authority in front of those providers, then require complete operation
admission behind them.

The resulting rule is simple:

> Development may inspect production sources when explicitly permitted, but it
> cannot write production state. Production may write production state only
> through an admitted production process and an authorized operation.

Once this boundary is mechanically enforced, onboarding, historical ingestion,
attachment reconciliation, and future archive maintenance can be developed and
tested repeatedly without treating the permanent archive as a laboratory.
