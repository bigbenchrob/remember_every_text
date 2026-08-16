---
tier: project
scope: presence-guidebook-lifecycle-architecture-audit
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: code
links:
  - 00-START-HERE.md
  - ../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md
  - ../../10-DATABASES/00-all-databases-accessed.md
  - ../../10-DATABASES/access_authority_documentation/010-DATABASE-ACCESS-IN-PLAIN-ENGLISH.md
tests:
  - test/architecture/forbidden_imports_test.dart
---

# Presence Guidebook Lifecycle Architecture Audit

## Conclusion

The current `presence.db` can be replaced wholesale when the guidebook
generation changes.

The audit found no current Presence table containing independently meaningful
human intent or irreplaceable application data. The database contains:

- application-supplied guidebook definitions and composition that can be
  reproduced from the edition shipped by MessageLens; and
- runs, checkpoints, completion, and trace whose meaning is local to that
  installed edition.

The smallest safe lifecycle is therefore:

```text
archive admitted
    -> inspect Presence installation before Presence runtime opens
    -> absent: create and install current edition
    -> current generation: open unchanged
    -> obsolete or unacceptable: replace the complete Presence database family
       with a validated current installation
    -> expose the installed database to runtime
```

Normal runtime then reads the installed guidebook. It does not build a second
complete Schedule graph and reconcile it against persisted definitions.

This conclusion is specific to Presence. It changes no durability rule for
MessageLens user data, Overlay intent, source data, graph data, or archived
attachments.

## Evidence Inspected

The audit followed the current code paths for:

- Drift schema creation and migrations in `PresenceDatabase`;
- physical opening through `presenceDatabaseProvider`;
- repository insertion, loading, runtime checkpoints, trace, and
  `installOrExtendDefinition`;
- production Onboarding guidebook construction and scheduler composition;
- the production Presence host;
- admitted archive paths and archive mutation authority;
- whole-archive checkpoints;
- Message Data reset and SQLite sidecar deletion;
- database health coverage; and
- current architecture tripwires.

The preceding
[Feature 23 handoff](../23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md)
is the historical entry point. Current code is authoritative where details
differ.

## Current Physical Lifecycle

### Archive And Path Authority

Application startup first admits one archive root. The persistent Presence
provider watches that admitted authority and resolves:

```text
<admitted archive root>/presence.db
```

It opens one keep-alive `PresenceDatabase` using Drift's background native
executor, enables foreign keys, and closes the database when its provider is
disposed.

Archive admission answers which MessageLens data folder this build may use. It
does not decide what Presence definitions mean or whether a guidebook is
current.

### Schema Creation

`PresenceDatabase.onCreate` creates the schema and append-only trace triggers.
It does not populate any Schedule, Trip, Step, occurrence, Agent, Choice, or
route data.

Drift schema version 9 describes the physical representation expected by the
current code. It is not a guidebook edition marker.

### Exact Current Fresh-Install Mechanism

The first production consumer is the Onboarding Presence host. Its scheduler
provider currently performs both installation and runtime preparation:

```text
Onboarding composes real specialist Agents and FDA-opening authority
    -> buildRequiredSourcesReadinessDefinition(...) constructs Schedule 6
       and its complete Trip/Step graph in Dart
    -> repository.installOrExtendDefinition(authored Schedule)
    -> PresenceScheduler(scheduleDefinitionId: 6)
    -> scheduler.initialize()
    -> repository starts or loads the latest run
```

On an empty database, `installOrExtendDefinition` delegates to
`insertDefinition`. The repository validates and inserts:

1. the Schedule definition;
2. reusable Trip definitions;
3. each Trip's ordered Step composition;
4. base Step rows and exactly one subtype representation;
5. opaque Test Agent declarations and routes;
6. Choice options and destinations; and
7. ordered Schedule Trip occurrences.

The same Onboarding provider does this during ordinary runtime, not at a
separate installation boundary.

## Current Runtime Reconciliation

When Schedule 6 already exists, `installOrExtendDefinition`:

1. loads the complete persisted Schedule;
2. returns if persisted and authored definitions compare equal;
3. otherwise validates an additive extension;
4. forbids Schedule identity changes and removed occurrences;
5. forbids an existing occurrence from changing Trip identity;
6. requires each existing Trip to retain identity, name, Step count, order,
   and compatible Step definitions;
7. permits existing generic Test Steps to retain identity/name/Agent while
   changing routes;
8. inserts newly added Trips and their composition;
9. mutates permitted existing Test routes; and
10. temporarily relocates occurrence positions before inserting and restoring
    the target ordered occurrence set.

The repository protects persisted semantic identities correctly under the
current premise. The problem is that ordinary runtime asks it to reconcile two
complete guidebooks.

### Why Step 6302 Failed

The persisted Trip 303 contained Step 6302 with its historical Tell text. The
current Dart-authored Trip supplied changed text under the same Step identity.
The repository's `_validateExistingTripExtension` compared the existing and
target Steps. Tell Steps permit no payload mutation, so it threw:

```text
Existing Step 6302 in Trip TripDefinitionId(303) cannot be redefined.
```

The guard was truthful. The lifecycle premise was incomplete.

Under generation replacement, the flow becomes:

```text
new build expects a new guidebook generation
    -> installed generation differs
    -> old presence.db and edition-local state are retired as one unit
    -> current schema and guidebook are installed
    -> runtime reads the new installed Step 6302
```

No old/new Tell comparison occurs. The proposed lifecycle therefore removes
the observed Step-6302 blocker completely.

### Reconciliation That Becomes Unnecessary At Runtime

Once installation is separate and `presence.db` is runtime authority, ordinary
runtime no longer needs:

- authored-versus-persisted full-Schedule equality checks;
- additive-extension validation as a startup compatibility strategy;
- special in-place Test route updates;
- occurrence-position reconciliation against a second authored graph; or
- Step payload redefinition checks between guidebook generations.

Validation and duplicate/conflict checks remain useful while constructing and
verifying one candidate installation. They cease to be a cross-generation
runtime migration system.

## Three Lifecycle Phases

### Installation

Installation owns creation of the current physical schema, deterministic
population of the complete shipped catalog, validation of its relational and
semantic integrity, and publication of the installed generation marker only
after success.

### Replacement

Replacement decides whether the installed guidebook is acceptable to the
current build. If obsolete, it closes or prevents opening of the active
Presence database, constructs and validates a complete current installation,
and promotes it as one unit. It does not translate old Trip position or trace.

### Runtime

Runtime opens an accepted installed edition, reconstructs Steps using opaque
Agent/action resolvers, and executes persisted geometry. Runtime does not
receive the authored installation graph.

These phases may share schema and validation code. They must not share
authority accidentally.

## Installed-Generation Marker Requirements

The representation remains undecided. A generation integer, catalog identity,
manifest identity, or content hash could work if it satisfies all of these
properties:

- the current build has one deterministic expected identity;
- a completed installed catalog has one unambiguous installed identity;
- the identity is checked before Presence runtime becomes available;
- missing, malformed, partial, or unexpected identity never admits the
  database as current;
- the marker is published only after schema creation, catalog installation,
  and validation succeed;
- the marker cannot truthfully describe a different catalog payload;
- direct replacement from any old generation to the current generation is
  possible; and
- same-generation restarts retain the database unchanged.

The marker may live inside the database or in a tightly bound installation
manifest. That choice requires the bootstrap to account for whether an old
schema can be inspected safely before Drift opens and migrates it. This audit
does not choose a format or location.

## Schema Version Is Not Guidebook Generation

The two identities answer different questions:

```text
schema version
    -> can current code interpret this physical representation?

guidebook generation
    -> is this the workflow edition shipped for this build?
```

A copy change can require a new guidebook generation without changing a table.
A storage refactor can change schema without changing guidebook meaning.

Under wholesale replacement, historical Presence schema migrations need not be
the normal cross-version path. A database whose schema or guidebook identity is
not acceptable can be replaced directly with the current schema and edition.
Current migrations remain necessary until that bootstrap owns pre-open
acceptance and replacement, and may remain useful for development or
same-generation schema corrections. They must not be removed prematurely.

## Table-By-Table Durability Audit

### Reproducible Guidebook Content

| Table | Current content | Classification |
| --- | --- | --- |
| `schedule_definitions` | Schedule identity and name | REPRODUCIBLE GUIDEBOOK CONTENT |
| `trip_definitions` | Trip identity and name | REPRODUCIBLE GUIDEBOOK CONTENT |
| `step_definitions` | Step identity, name, and subtype discriminator | REPRODUCIBLE GUIDEBOOK CONTENT |
| `schedule_trip_occurrences` | Schedule order and Schedule-to-Trip composition | REPRODUCIBLE GUIDEBOOK CONTENT |
| `trip_step_occurrences` | Trip order and Trip-to-Step composition | REPRODUCIBLE GUIDEBOOK CONTENT |
| `tell_step_definitions` | Tell payload | REPRODUCIBLE GUIDEBOOK CONTENT |
| `fixed_destination_step_definitions` | fixed routes | REPRODUCIBLE GUIDEBOOK CONTENT |
| `test_agent_definitions` | opaque Agent declarations | REPRODUCIBLE GUIDEBOOK CONTENT |
| `test_step_definitions` | Agent binding and Boolean routes | REPRODUCIBLE GUIDEBOOK CONTENT |
| `open_fda_settings_step_definitions` | specialist Step subtype marker | REPRODUCIBLE GUIDEBOOK CONTENT |
| `choice_step_definitions` | Choice subtype marker | REPRODUCIBLE GUIDEBOOK CONTENT |
| `choice_step_options` | ordered values, labels, and destinations | REPRODUCIBLE GUIDEBOOK CONTENT |
| `fda_test_step_definitions` | retired specialized Boolean grammar retained by schema history | REPRODUCIBLE GUIDEBOOK CONTENT |
| `contacts_source_readiness_step_definitions` | retired specialized Boolean grammar retained by schema history | REPRODUCIBLE GUIDEBOOK CONTENT |

The two retired subtype tables are migration residue, not durable user facts.
Whole-generation replacement makes preservation of their rows unnecessary.

### Edition-Local Execution State

| Table | Current content | Classification |
| --- | --- | --- |
| `schedule_runs` | latest run, current Trip occurrence, and completion represented by a null current occurrence | EDITION-LOCAL EXECUTION STATE |
| `execution_trace_events` | append-only run, Trip, Step, and route observations | EDITION-LOCAL EXECUTION STATE |

These rows refer directly to the installed definition graph. They remain useful
across quit, crash, and relaunch within one generation. They have no reliable
meaning after that graph is replaced.

### Potentially User-Meaningful Durable State

None exists in the current schema.

No current table stores an independently meaningful preference, commitment, or
user-authored fact. Schedule completion currently participates in Onboarding
readiness, but it means only that this guidebook edition's run completed. If
replacement causes the short readiness interaction to repeat before import,
that is mild repetition rather than user-data loss.

### Unknown / Needs Decision

None was found in the current table inventory.

Future Presence clients must repeat this classification when adding state. The
database's current replaceability is not a permanent license to store durable
human intent and discard it later.

## Same-Generation Contract

For an accepted installed generation, current behavior remains valuable:

- quitting and reopening resumes the current Trip;
- a crash or relaunch restarts at Trip granularity;
- the latest completed run remains completed;
- execution trace remains inspectable; and
- a deliberately started replacement run behaves according to current
  Schedule rules.

The lifecycle must not reset on every launch, app process, or ordinary build
restart. Generation mismatch, not mere startup, is the replacement trigger.

## Cross-Generation Human Consequence

A person halfway through generation 12 may begin generation 13 fresh after an
upgrade. A person who completed generation 12 readiness but has not built
browsing data may be asked those readiness questions again.

That is acceptable under the current workflow because:

- no Messages, Contacts, Overlay, graph, or attachment data is lost;
- current source facts are re-evaluated by current Agents;
- no operation is considered complete merely because an obsolete guidebook
  claimed it; and
- Onboarding Gate and import safety remain independently authoritative.

This conclusion would need reassessment if a future Schedule performs an
irreversible external commitment whose acceptance cannot be re-derived. Such a
fact would belong to the responsible domain, not to a numeric Presence
bookmark.

## Identity Policy

Numeric Schedule, Trip, Step, and occurrence IDs remain valuable within one
generation for foreign keys, routes, run checkpoints, traces, diagnostics, and
reviewable composition.

They do not need eternal cross-generation semantic identity under wholesale
replacement. The proposed rule is:

> Definition and occurrence IDs are stable and meaningful within a guidebook
> generation. Cross-generation compatibility exists only when explicitly
> designed; it is not implied by reusing a number.

Opaque Agent IDs are additionally contracts between the installed guidebook
and the current runtime resolver. The current edition must validate that all
required capabilities can be resolved. Their names may remain stable across
generations for authoring clarity, but old execution state does not survive on
that basis.

## Authoring And Installation Input

MessageLens must ship one source from which a fresh catalog can be installed.
This is authoring/install input. It is not runtime authority after installation.

Without choosing JSON, Dart, SQL, generated resources, or another format, the
source must deterministically represent:

- Schedule, Trip, and Step identity;
- Schedule Trip and Trip Step occurrence order;
- Tell text;
- Step subtype configuration;
- opaque Agent IDs;
- Test true/false destinations;
- fixed destinations;
- Choice values, labels, order, and destinations; and
- the expected guidebook generation.

Before shipping, tooling must be able to validate:

- unique IDs and names where the schema requires them;
- one active subtype per Step;
- non-empty Schedules, Trips, and required Choice options;
- unique occurrence positions;
- Schedule-local route destinations;
- resolvable opaque capability IDs;
- deterministic output;
- readable Git review and diffs; and
- deliberate generation-bump discipline when installed meaning changes.

The source may be convenient to author in one form and compiled into another.
Runtime must still consume only the installed database.

## Blank-Stare Ownership Audit

The generic Presence repository correctly reconstructs Test Steps from opaque
`TestAgentId` values and asks a supplied resolver for executable capability.
That boundary remains sound.

Current production composition violates the desired blank-stare boundary in
two places:

1. Onboarding owns and constructs the complete Schedule 6 graph, including all
   Schedule, Trip, Step, occurrence, text, and route identities.
2. Onboarding's accepted-readiness provider asks the Presence repository for
   completion of numeric Schedule ID 6.

These arrangements were appropriate while proving the grammar but should not
become the runtime lifecycle. The target boundary is:

```text
Presence installation
    owns installed guidebook catalog and generation

Presence runtime
    owns persisted geometry, run, checkpoint, and trace

Onboarding composition
    supplies opaque Agent/action capabilities and consumes a narrow semantic
    outcome without knowing guidebook geometry
```

Presence remains generic even when its installed edition contains Schedules
serving Onboarding and future clients. Consumers do not own catalog replacement.

## Database Safety And Operational Policy Audit

### Inventory And Path

`presence.db` is a named central app database inside the admitted archive root.
The path inventory recognizes it, but most operational services enumerate
specific database roles rather than all `AppDatabaseFile` values.

### Whole-Archive Checkpoint

The offline whole-archive checkpoint inventories regular files recursively,
checks every `.db` main file for SQLite health, and copies the archive payload.
It therefore includes `presence.db` and any present sidecars. Restoring such a
checkpoint may restore an obsolete guidebook; the next startup lifecycle should
then replace it if its generation is not current.

Because Presence is reproducible, a Presence-only generation replacement does
not inherently need preservation backup. It does require narrow file authority
that cannot reach Overlay or attachment payloads. Existing production mutation
policy may conservatively require a checkpoint depending on the operation used;
that policy must be decided deliberately rather than inherited accidentally.

### Message Data Reset

“Reset Message Data” uses an explicit allow-list containing only the active
source-scoped import and Conversation Graph databases plus retired cleanup
files. It deletes each selected main file, `-wal`, and `-shm` sidecars.

Presence, Overlay, and archived attachments are excluded. That is currently
correct. Guidebook replacement must not broaden Message Data reset. It needs a
separate Presence-owned operation with an equally explicit one-family allow-list.

### Database Health

The central database health audit currently covers retired cleanup files,
source-scoped import, Conversation Graph, and Overlay. It does not open or
report `presence.db`.

A guidebook installer must perform its own candidate integrity, schema, catalog,
and generation validation before promotion. Whether Presence later joins the
general health report is secondary; the current report cannot be treated as
replacement admission evidence.

### Reopen And Mutation Coordination

The Presence provider is keep-alive and closes only on provider disposal. The
archive mutation coordinator serializes named mutations, but no current
operation represents guidebook replacement and no replacement path invalidates
or closes the Presence provider.

Replacement therefore must gain an explicit pre-runtime close/open boundary.
It must not delete files behind a live Drift connection. It should occur after
archive admission and before any scheduler, repository, host, or completion
watch can consume the database. If replacement is ever initiated after runtime
availability, all Presence consumers must first be withdrawn and the provider
closed under one mutation authority.

### Sidecars

SQLite storage authority is the database family:

```text
presence.db
presence.db-wal
presence.db-shm
```

No future code may replace only the main file while a live or stale sidecar can
reintroduce old pages. Existing Message Data reset demonstrates the required
family-aware deletion pattern, but its allow-list must not be reused or widened.

## Atomic Replacement Requirements

The simplest safe future replacement is build-then-promote:

1. admit the archive and acquire one Presence-specific mutation authority;
2. prevent Presence providers and readers from opening;
3. create a candidate database in the same filesystem using the current Drift
   schema;
4. install the complete current catalog into the candidate;
5. validate foreign keys, SQLite integrity, catalog invariants, and generation;
6. close and checkpoint the candidate so promotion does not depend on live
   sidecars;
7. atomically promote the validated candidate while retiring the old Presence
   family; and
8. only then expose the central Presence provider.

Exact rename and rollback mechanics remain implementation work. The invariant
is that runtime sees either the previously accepted complete installation or a
new complete installation, never a partially seeded database.

If construction fails before promotion, the old accepted installation remains.
If no accepted installation exists, Presence remains unavailable and a later
startup can retry deterministic construction. Installation does not need its
own durable progress checkpoints, migration chain, background repair queue, or
partial resume protocol.

If interruption can occur between retiring the old database and promotion,
startup must treat every incomplete or markerless family as uninstalled and
reconstruct from the shipped source. It must fail closed rather than running an
unknown catalog.

## Failure Philosophy

The truthful failure state is:

```text
current guidebook cannot be installed or validated
    -> Presence cannot run
```

The failure must not fall back to an obsolete generation, silently run a
partially installed catalog, or ask runtime reconciliation to repair it. Other
MessageLens data remains untouched. Retry may reconstruct a fresh candidate
from deterministic installation input.

## Minimum Architecture

```text
Guidebook source:
    One deterministic, build-supplied installation input representing the
    complete current Presence catalog. Its storage/authoring format is open.

Installed-generation marker:
    One identity bound to a fully validated installed catalog, distinguishable
    from Drift schema version and published only after successful installation.

Fresh-install owner:
    A generic Presence installation boundary, not Onboarding and not the
    runtime scheduler provider.

Replacement owner:
    A generic Presence lifecycle boundary holding narrow authority over only
    the Presence SQLite family.

Replacement timing:
    After archive admission and before Presence database, repository,
    scheduler, host, or completion-watch availability.

Database-close/reopen boundary:
    Candidate construction happens off the runtime connection. Any existing
    Presence connection is closed before family promotion; the central provider
    opens only the accepted promoted database.

Runtime authority:
    The accepted installed presence.db is the sole guidebook authority.

Same-generation state:
    Keep runs, current Trip checkpoints, completion, and execution trace; resume
    according to current Trip-granular semantics.

Cross-generation state:
    Discard guidebook definitions and all edition-local execution state. Do not
    map old bookmarks onto the new edition.

Overlay boundary:
    Store only independently meaningful human intent in its owning domain.
    Never copy Presence runs, trace, completion flags, or definition IDs merely
    to preserve obsolete guidebook state.

Consumer/Agent boundary:
    Consumers contribute opaque specialist capabilities and consume narrow
    semantic outcomes. They do not know Schedule/Trip/Step geometry.

Current reconciliation code:
    installOrExtendDefinition, authored-versus-persisted equality, additive
    extension checks, Test-route mutation, and occurrence reconciliation remain
    temporarily necessary but are not the target runtime lifecycle.

Step-6302 consequence:
    A generation change replaces the old catalog before runtime, so changed
    Tell text is installed without redefining a live persisted Step.

Schema-migration consequence:
    Schema and guidebook generation remain separate. Once pre-open replacement
    is authoritative, unacceptable historical schemas can be reconstructed
    directly instead of requiring a sequential Presence migration chain.

Backup/reset consequence:
    Whole-archive checkpoints may contain Presence, but Message Data reset stays
    unchanged. Guidebook replacement receives narrow Presence-family authority
    and must remain mechanically unable to touch Overlay or attachments.

Failure behavior:
    Fail closed for Presence, preserve all non-Presence data, retain an old
    accepted installation until a candidate is valid when possible, and retry
    deterministic installation rather than migrate partial catalog state.
```

## Exactly One First Implementation Slice

Introduce a deterministic, side-effect-free **Presence guidebook catalog
contract and validator**, then express the current production guidebook through
that contract without changing runtime behavior yet.

This is the correct first slice because current fresh installation has no
catalog boundary: `requiredSourcesReadinessSchedulerProvider` constructs the
full authored Schedule while also composing runtime Agents and initializing the
scheduler. Generation bootstrap cannot safely install or validate a guidebook
until that definition graph is available independently of runtime execution.

The slice should prove only that one complete current catalog can be produced
deterministically and validated for IDs, occurrences, subtype consistency,
routes, Choices, and opaque capability declarations. It should not choose a
serialization format, add generation metadata, replace a database, remove
reconciliation, change schema, or alter Onboarding behavior.

After that boundary exists, a later lifecycle slice can install it into a
candidate database and bind it to a generation marker without making
Onboarding the persistence owner.

## Decisions And Open Implementation Details

### Settled By This Audit

- the whole current Presence database is replaceable at generation change;
- no current Presence row must survive that replacement;
- runtime database authority and authoring/install input are distinct;
- same-generation execution durability remains;
- cross-generation bookmark migration is unnecessary;
- definition IDs need compatibility within a generation, not eternal numeric
  continuity;
- replacement belongs to generic Presence lifecycle infrastructure;
- Onboarding should supply capabilities, not guidebook geometry; and
- replacement must be atomic, family-aware, pre-runtime, and mechanically
  isolated from preservation data.

### Intentionally Open

- catalog authoring and serialized representation;
- installed-generation marker representation and location;
- exact candidate filename and atomic promotion mechanics;
- whether a Presence-only production replacement requires a verified whole-
  archive checkpoint;
- whether Presence joins the general database health report; and
- the narrow semantic API by which clients consume guidebook outcomes without
  knowing Schedule IDs.

These are implementation choices within the lifecycle, not reasons to retain
runtime graph reconciliation.
