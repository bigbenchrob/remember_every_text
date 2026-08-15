---
tier: project
scope: presence-teststep-consolidation
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: code-audit
links:
  - ./00-START-HERE.md
  - ./02-TARGET-OWNERSHIP-PROPOSAL.md
  - ./08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/15-PRESENCE-DATABASE-IN-PLAIN-ENGLISH.md
  - ../21-PRESENCE-ITERATION-SIMPLE/16-PRESENCE-DATABASE-SCHEMA-WALKTHROUGH.md
tests:
  - test/architecture/forbidden_imports_test.dart
  - test/essentials/presence/
  - test/essentials/onboarding/
  - test/features/presence_iteration_simple/
---

# Presence TestStep Consolidation Audit

## 1. Executive Result

The generic Boolean Test architecture is complete and coherent.

```text
Presence knows:
    TestStep
    TestAgentId
    TestAgent
    TestAgentResolver
    Boolean routing

Onboarding knows:
    what its tests mean
    which Agents to bind
    where results lead

Specialists know:
    how to establish facts

Application composition knows:
    which binding contributions form one resolver

The development harness knows:
    how to exercise and inspect the workflow
```

Presence cannot explain what the Messages-readiness or Contacts-readiness
Agents test. It can only resolve an opaque Agent identity, ask that Agent for a
Boolean result, and map the result to a configured destination.

No accidental active onboarding dependency was found in the generic Test
path. The sole active domain-specific concept remaining inside Presence is the
separate `OpenFdaSettingsStep` and its `FdaSettingsOpeningAuthority`. That is
temporary tolerated debt and is the next bounded architectural question.

## 2. Final Generic Test Runtime Path

The active persisted-to-runtime chain is:

```text
presence.db
    step_definitions.type = test
        -> test_step_definitions
        -> test_agent_definitions
        -> DriftPresenceScheduleRepository.loadDefinition()
        -> _loadTrip()
        -> _loadStep()
        -> TestAgentId
        -> injected TestAgentResolver.resolve()
        -> TestStep
        -> TestAgent.evaluate()
        -> configured true/false TripDefinitionId?
        -> Trip.completeCurrentStep()
        -> PresenceScheduler.completeCurrentStep()
        -> repository checkpoint and trace
```

The relevant implementation boundaries are:

- `presence_database.dart` defines the generic persisted grammar.
- `drift_presence_schedule_repository.dart` validates rows and reconstructs
  the executable definition.
- `test_agent_id.dart`, `test_agent.dart`, and `test_agent_resolver.dart`
  define opaque identity, Boolean evaluation, and immutable resolution.
- `step.dart` maps the Agent result to the configured routing arm.
- `trip.dart` consumes only Step completion.
- `presence_scheduler.dart` consumes only Trip completion and performs routing,
  checkpointing, and trace recording.

There is no workflow-specific test branch in active repository
reconstruction. `Trip` and `PresenceScheduler` do not inspect Agent identity,
Agent meaning, or the concrete `TestStep` subtype.

## 3. Presence Ownership Audit

Presence owns the permanent generic machinery listed in the executive result.
Its active Test contracts contain no Messages, Contacts, Address Book,
`chat.db`, FDA, or onboarding meaning.

`step.dart` remains appropriately small. Its current concrete classes are:

```text
TellStep
FixedDestinationStep
TestStep
OpenFdaSettingsStep
```

A mechanical split would add navigation without clarifying ownership. No file
split was made.

The repository requires an injected resolver and fails while reconstructing
the requested Schedule if a required Agent identity is unavailable. It does
not create a partially executable run and defer failure until a test happens
to execute.

## 4. Onboarding Ownership Audit

Onboarding owns:

- the required-sources Schedule definition and copy;
- stable Messages- and Contacts-readiness `TestAgentId` values;
- concrete Messages and Contacts `TestAgent` adapters;
- the onboarding binding contribution;
- routing destinations and remediation meaning;
- the current FDA Settings-opening adapter.

The concrete Test Agents establish Boolean facts only. They do not know Trip
IDs, Schedule topology, or routing arms. No onboarding-owned workflow file
that belongs in the permanent Onboarding subsystem remains stranded in the
development harness or generic Presence.

## 5. Specialist Ownership Audit

Specialist expertise remains with its existing owner:

- Conversation Graph owns read-only `chat.db` probing through
  `ChatDbSourceProbeReader` and `SqliteChatDbSourceProbeReader`.
- Address Book owns source discovery and readability through
  `AddressBookFolderRepository` and its infrastructure.
- Onboarding's macOS infrastructure owns FDA state and opening System Settings
  through `MacosFullDiskAccess`.

Onboarding Test Agents delegate to these seams. They contain no duplicate SQL,
Address Book path-ranking rules, or platform-settings implementation.

## 6. Application Composition Audit

The current development composition root is
`presenceExperimentTestAgentResolverProvider`.

It obtains the onboarding binding contribution, applies the development-only
Contacts source substitution, and constructs one
`ImmutableTestAgentResolver`. This is client/application composition, not a
Presence service locator:

- Presence does not import the harness or Onboarding.
- Additional workflow owners can contribute bindings without changing
  Presence contracts.
- duplicate identities fail mechanically during immutable resolver
  construction;
- the resolver cannot be mutated after construction.

This composition point is adequate for the development experiment. It is not
declared to be the eventual production-wide composition root.

## 7. Persistence And Migration-Evidence Audit

Schema version 8 uses these tables as active Boolean-test truth:

```text
test_agent_definitions
test_step_definitions
```

The base `step_definitions.type = test` discriminator selects the generic
subtype. Active repository reconstruction reads only that subtype.

The following tables are frozen migration evidence:

```text
fda_test_step_definitions
contacts_source_readiness_step_definitions
```

They preserve identity and migration continuity. They are consulted by
migration tests and retained by schema history, but no active repository path
reads from or writes to them.

Generated Drift table and companion APIs for these frozen tables remain
available because the tables remain part of the physical schema. Mechanically
prohibiting all possible writes through generated APIs would require a
schema-level change or a broader database-access redesign. Neither is
justified in this consolidation pass. The active writer boundary is the
repository, and it does not use those APIs.

Repository integrity checks continue to prove that the base discriminator has
exactly one active subtype. Frozen rows are excluded from that active-subtype
calculation.

## 8. Transitional Code Retired

Slices 3 and 4 had already retired the demonstrably obsolete code:

- specialized FDA and Contacts Boolean Step classes;
- active specialized repository reconstruction branches;
- Messages- and Contacts-readiness authority interfaces;
- transitional provider adapters for those authorities;
- resolver construction inside the onboarding Schedule builder.

This audit found no additional dead production source to delete. It replaced
architecture tests centered on retired class names with positive checks of
the permanent dependency boundaries.

Historical implementation documents and migration tests were deliberately not
deleted. They explain how existing databases reached the current state.

## 9. Public API Cleanup

`lib/essentials/presence/feature_level_providers.dart` exposes only the generic
Presence repository provider seam. It exports no onboarding Test Agent IDs,
specialized test authorities, specialist readers, or harness providers.

No stale specialized export remained, and no public API expansion was needed.

## 10. Architecture-Tripwire State

The architecture suite now protects the current model directly:

- Presence remains independent of MessageLens features.
- generic Test Agent contracts remain specialist-agnostic;
- generic `TestStep` and repository reconstruction remain workflow-agnostic;
- Onboarding Test Agents remain routing-agnostic;
- specialist source readers do not depend on Presence routing;
- Presence and Onboarding do not depend on the development harness;
- the active repository ignores frozen Boolean subtype tables;
- application composition constructs the immutable resolver;
- `Trip` and `PresenceScheduler` depend only on Step completion.

Obsolete assertions about deleted FDA/Contacts readiness-authority files were
removed. The new tests guard dependencies and responsibilities rather than
historical filenames.

## 11. Documentation Reconciliation

Current-facing package navigation and the two plain-English database guides
now lead with the generic persisted/runtime join:

```text
presence.db stores:
    Test Agent identities
    Test Steps that reference them

runtime composition supplies:
    actual TestAgent objects

Presence joins the two by TestAgentId
without knowing what the Agent does
```

The Slice 1-4 documents remain unchanged as implementation evidence, apart
from historical-status notices on the pre-generic inventory and first-move
record. They are not current architecture specifications.

## 12. Remaining Domain-Specific Debt

| Concept | Classification | Reason |
| --- | --- | --- |
| `OpenFdaSettingsStep` | Temporary tolerated debt | Active Presence Step names one onboarding/platform action. |
| `FdaSettingsOpeningAuthority` | Temporary tolerated debt | Generic Presence currently receives an FDA-specific operation capability. |
| `open_fda_settings_step_definitions` | Temporary tolerated debt | Active subtype persistence supports the same specialized Step. |
| old FDA/Contacts Boolean discriminators and subtype tables | Migration/history only | Required for schema and migration continuity; inactive at runtime. |
| onboarding Agent IDs and concrete Test Agents | Correct client ownership | They live under Onboarding and enter Presence only as opaque bindings. |

No other active domain-specific concept was found inside generic Presence.

## 13. Files Deliberately Left Unchanged

This pass deliberately did not change:

- `presence.db` schema version, tables, constraints, or migrations;
- generated Drift APIs for frozen legacy subtype tables;
- Step, Trip, Scheduler, resolver, repository, checkpoint, or trace behavior;
- required-sources Schedule topology, IDs, or copy;
- development source substitution or harness behavior;
- production `OnboardingGate` integration;
- `OpenFdaSettingsStep` or its authority;
- checked migration and Slice 1-4 implementation evidence.

No `ActionStep`, `ActionAgent`, Agent supertype, or generic operation result was
introduced.

## 14. Verification

The consolidation verification covers:

- complete Presence tests, including schema and migration continuity;
- complete Onboarding tests;
- development-harness tests;
- all architecture tripwires;
- static analysis;
- formatting and whitespace validation;
- checked Schedule diagram regeneration;
- a macOS Debug build.

The final command results are recorded in the completion log for this pass.
No code generation was required because this audit changed no generated source
inputs.

## 15. Recommended Next Architectural Question

The next question should be narrowly stated:

> Why does generic Presence currently need to know that one Step opens Full
> Disk Access Settings, and what is the smallest truthful ownership boundary
> for that operation?

That inquiry should begin from `OpenFdaSettingsStep` and
`FdaSettingsOpeningAuthority`. It should not assume that `ActionStep`, a common
Agent supertype, or any other generalization is already earned.
