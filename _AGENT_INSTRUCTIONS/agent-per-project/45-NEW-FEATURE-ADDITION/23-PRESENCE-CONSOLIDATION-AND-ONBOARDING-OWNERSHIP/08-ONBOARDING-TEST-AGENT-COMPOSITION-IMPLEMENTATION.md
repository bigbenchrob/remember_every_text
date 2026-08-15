---
tier: project
scope: onboarding-test-agent-composition
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: implementation
links:
  - 00-START-HERE.md
  - 04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
  - 07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md
tests:
  - ../../../../test/essentials/onboarding/application/onboarding_test_agent_bindings_test.dart
  - ../../../../test/features/presence_iteration_simple/application/presence_experiment_test_agent_resolver_provider_test.dart
---

# Onboarding Test Agent Composition Implementation

## Scope

This record closes Slice 4 of the generic TestStep proposal. It replaces the
temporary runtime bridge with permanent ownership boundaries while preserving
the proven required-sources Schedule and generic Presence execution path.

No `presence.db` schema, Schedule topology, route, checkpoint, trace, copy, or
production `OnboardingGate` behavior changed.

## Onboarding-Owned Identities

`onboarding_test_agent_ids.dart` is the single owner of the two persisted
identities:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
```

Presence stores and resolves those values opaquely. It does not define, parse,
or interpret them.

## Concrete Test Agents

`MessagesSourceReadinessTestAgent` implements the generic Boolean `TestAgent`
contract and delegates to the existing `FullDiskAccess` source-read boundary.
The real provider behind that boundary uses `ChatDbSourceProbeReader` to run a
truthful read against the protected Messages database. Read failures remain a
`false` result according to the existing specialist contract; unexpected
specialist exceptions are not reinterpreted by the Agent.

`ContactsSourceReadinessTestAgent` implements the same generic contract and
delegates each evaluation to a fresh
`AddressBookFolderRepository.getFinalFolderAggregate()` call. It translates a
successful aggregate into `true` and an unavailable source into `false` while
leaving Address Book path and discovery knowledge in its specialist feature.

Both Agents establish one fact only. Neither knows Trips, Schedules,
destinations, routing, or `TestStep`.

## Retired Transitional Authorities

`MessagesSourceReadinessAuthority` and `ContactsSourceReadinessAuthority` were
retired. At this boundary each had become an alias for one asynchronous Boolean
operation between `TestAgent` and the same specialist. They no longer protected
an independent responsibility.

The settings-opening contract was not retired. `OpenFdaSettingsStep` still
depends on `FdaSettingsOpeningAuthority`, and `FdaSettingsOpeningAdapter`
delegates that operation to onboarding's existing FDA service. Generalizing
that Step is outside this slice.

## Binding Contribution

Onboarding contributes exactly two explicit bindings through:

```text
buildOnboardingTestAgentBindings(...)
```

The function pairs the Onboarding-owned IDs with already-constructed Agents
and returns an unmodifiable list. It deliberately does not construct a global
resolver. Duplicate contributions remain mechanically invalid when application
composition constructs `ImmutableTestAgentResolver`.

## Application Composition

The current development application boundary is
`presenceExperimentTestAgentResolverProvider` under the Presence experiment
client. It obtains Onboarding's Messages Agent and the development-selected
Contacts Agent, gathers the Onboarding binding contribution, and constructs the
immutable resolver supplied to the generic Presence repository provider.

This provider is the current client composition root, not a Presence service
locator. Future workflow owners can contribute additional binding lists at an
application boundary without modifying Presence.

The required-sources Schedule remains under Onboarding. It authors generic
Test Steps using Onboarding-owned IDs and receives the completed resolver; it
does not construct specialist Agents or the resolver.

## Development Contacts Substitution

The experiment retains its real/unavailable Contacts source control. A
development-owned `DevelopmentContactsSourceReadinessTestAgent` selects the
current concrete Contacts Agent for every evaluation, then delegates the
Boolean test. Switching back to the real source therefore affects the next
retry without placing development mode knowledge in `TestStep`, `TestAgentId`,
Presence, or `presence.db`.

## Final Dependency Direction

```text
Conversation Graph source probe
    -> MessagesSourceReadinessTestAgent
        \
         \
Address Book repository
    -> ContactsSourceReadinessTestAgent
          \
           \
        Onboarding TestAgent bindings
                 |
                 v
        application composition
                 |
                 v
      ImmutableTestAgentResolver
                 |
                 v
              Presence
                 |
                 v
             TestStep
```

Presence cannot answer which feature supplies
`onboarding.contacts-source-readable`; it sees only an opaque identity and an
already-constructed resolver.

## Verification

Focused coverage proves exact and distinct IDs, one binding per Agent, resolver
composition, duplicate-binding rejection, true/false specialist delegation,
exception behavior, fresh Contacts reads, development source substitution, and
unchanged required-sources routing and restart behavior.

Architecture tripwires prove that Presence does not import Onboarding, the
retired readiness authorities remain absent, specialist Agents do not import
Presence routing machinery, and resolver construction remains at application
composition.

Verification completed with 145 Presence, Onboarding, and development-harness
tests; all 359 architecture tripwires; a clean analyzer; current generated
outputs; checked Mermaid regeneration; a successful macOS Debug build;
formatting; and `git diff --check`.

## Remaining Domain-Neutrality Debt

The generic Boolean Test path is domain-neutral. The remaining known
Onboarding-specific dependency inside Presence is the unchanged
`OpenFdaSettingsStep` and its `FdaSettingsOpeningAuthority`. No Action Step or
general Agent hierarchy was introduced to address that separate question.
