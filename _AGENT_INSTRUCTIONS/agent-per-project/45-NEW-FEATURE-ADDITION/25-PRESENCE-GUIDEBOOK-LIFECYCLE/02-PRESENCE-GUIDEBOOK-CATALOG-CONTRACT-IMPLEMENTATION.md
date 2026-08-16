---
tier: project
scope: presence-guidebook-lifecycle
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: implementation-record
links:
  - 00-START-HERE.md
  - 01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
tests:
  - test/essentials/presence/application/current_presence_guidebook_catalog_test.dart
  - test/essentials/presence/domain/services/presence_guidebook_catalog_validator_test.dart
  - test/essentials/onboarding/application/required_sources_readiness_schedule_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Presence Guidebook Catalog Contract Implementation

## Result

MessageLens now has one side-effect-free answer to:

> What guidebook does this build ship?

`currentPresenceGuidebookCatalog()` returns the complete current production
guidebook as immutable in-memory data. It requires no provider container,
database, repository, scheduler, Agent resolver, archive root, filesystem, or
runtime state.

The catalog is owned by generic Presence. It currently contains Schedule 6,
its eleven Trips, ordered Schedule occurrences, ordered Steps, Tell text,
routes, Choice configuration, FDA-opening Step declaration, and four opaque
Onboarding capability identifiers.

## Contract

The bounded contract is:

```text
PresenceGuidebookCatalog
    PresenceGuidebookSchedule
        PresenceGuidebookTripOccurrence
            PresenceGuidebookTrip
                PresenceGuidebookStep
```

Only Step shapes already used by the production guidebook exist:

- Tell;
- fixed destination;
- Boolean Test with opaque `TestAgentId`;
- Choice with ordered `ChoiceOption` values, labels, and destinations; and
- open Full Disk Access Settings.

The existing executable `Step` hierarchy could not itself be the pure catalog
contract because `TestStep` requires a concrete `TestAgent` and
`OpenFdaSettingsStep` requires an executable settings-opening authority. The
catalog therefore introduces the smallest data-only counterparts needed to
separate authored content from runtime capability. It does not duplicate
Journey execution, repository behavior, or speculative Step types.

Trip Step occurrence position is mechanically the immutable list index. The
catalog does not add a second explicit position field that could disagree with
list order. Schedule Trip occurrences retain their existing explicit identity
and position.

## Structural Validation

`PresenceGuidebookCatalogValidator` is pure and deterministic. It validates:

- non-empty catalog, Schedule, Trip, Step, Tell, and Agent-ID data;
- unique Schedule identities and names;
- unique Schedule occurrence identities and positions;
- non-negative Schedule occurrence positions;
- one canonical Trip occurrence per Schedule;
- coherent canonical Trip and Step definitions;
- at least one Trip per Schedule and one Step per Trip;
- no conflicting Step subtype or payload under one canonical Step identity;
- schedule-local route destinations;
- terminal placement of routing Steps;
- at least two Choice options;
- unique Choice values; and
- valid ordered Choice destinations.

Structural validation answers whether the guidebook is coherent. It does not
resolve a Test Agent or prove that the running application can supply every
capability. Runtime capability validation remains separate.

## Determinism

Catalog construction uses fixed IDs, fixed list order, fixed occurrence
positions, fixed text, fixed opaque Agent IDs, and fixed route configuration.
It consults no clock, random source, map iteration, database, provider, or
runtime fact. Value equality covers the complete catalog graph, and focused
tests prove two constructions are equal while also asserting the production
topology, Choice order, routes, Tell text, and Agent declarations.

## Ownership Change

Before this slice, Onboarding runtime composition authored Schedule 6 while
also supplying the capabilities that execute its specialist questions. The
authored graph and the specialist implementation were therefore colocated.

After this slice:

```text
Presence guidebook catalog
    owns Schedule, Trip, Step, occurrence, text, route, Choice,
    and opaque capability declarations

Onboarding runtime composition
    owns concrete source-readiness Agents, Agent bindings,
    and FDA Settings-opening authority
```

The prior Onboarding schedule entry point remains only as a transitional
materialization adapter for existing runtime callers and tests. The Agent-ID
file similarly re-exports catalog-owned declarations while Onboarding retains
the executable bindings.

## Runtime Compatibility

Current production behavior is intentionally unchanged:

```text
current catalog Schedule
    -> materialize with Onboarding runtime capabilities
    -> installOrExtendDefinition()
    -> initialize current Scheduler
```

The materializer performs no persistence or scheduling. It converts pure
catalog Steps to today's executable Step definitions by resolving Test Agents
and attaching the FDA Settings-opening authority supplied by Onboarding.

`installOrExtendDefinition()` and all existing definition reconciliation remain
in force. The current `presence.db` schema and contents are unchanged.

## Deferred Work

This slice deliberately does not:

- add a guidebook-generation marker;
- install or atomically replace a Presence database;
- remove runtime definition reconciliation;
- choose JSON, YAML, SQL, binary, generated, or bundled serialization;
- change Drift schema or migration history;
- move run or trace state to Overlay;
- alter Agent, Choice, Gate, Scheduler, or Onboarding behavior; or
- change attachment preservation.

The Step 6302 conflict remains valid transitional evidence. The immutability
guard is unchanged, so an existing database with different text under that
identity may still reject the current definition until generation replacement
is implemented.

The accepted-readiness boundary still consumes numeric Schedule ID 6. That
blank-stare leak remains deferred to a later semantic-outcome slice.

No serialization choice and no generation marker were introduced.

## Verification

Focused tests prove:

- construction without runtime infrastructure;
- complete deterministic equality;
- expected current production topology and content;
- opaque Agent declarations without executable implementations;
- all required validator rejection cases;
- unchanged runtime Agent resolution and Schedule execution; and
- the dependency boundary between catalog declarations and generic runtime.

The implementation follows Audit 01 without architectural deviation. The only
representational refinement is the deliberately small data-only Step contract
required because current executable Steps carry runtime capabilities.
