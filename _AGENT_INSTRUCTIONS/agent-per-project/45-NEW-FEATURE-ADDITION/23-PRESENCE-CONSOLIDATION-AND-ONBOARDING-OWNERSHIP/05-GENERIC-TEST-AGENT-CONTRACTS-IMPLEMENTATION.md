---
tier: project
scope: presence-test-agent-contracts
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: implementation
links:
  - 00-START-HERE.md
  - 04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md
tests:
  - ../../../../test/essentials/presence/domain/entities/test_agent_id_test.dart
  - ../../../../test/essentials/presence/domain/services/test_agent_resolver_test.dart
  - ../../../../test/architecture/forbidden_imports_test.dart
---

# Generic Test Agent Contracts Implementation

## Scope

This record closes Slice 1 of the approved generic TestStep and opaque Agent
resolution proposal. It introduces only the generic identity, Boolean Agent
contract, and immutable resolver. Existing Presence and Onboarding execution
paths do not use these types yet.

No schema, persisted Step, repository reconstruction, provider composition, or
onboarding behavior changed in this slice.

## Implemented Types

| Type | Location | Responsibility |
| --- | --- | --- |
| `TestAgentId` | `lib/essentials/presence/domain/entities/test_agent_id.dart` | Durable opaque identity for one Boolean Test Agent |
| `TestAgent` | `lib/essentials/presence/domain/services/test_agent.dart` | Establish one fully configured Boolean fact asynchronously |
| `TestAgentBinding` | `lib/essentials/presence/domain/services/test_agent_resolver.dart` | Pair one identity with one runtime Agent during explicit composition |
| `TestAgentResolver` | `lib/essentials/presence/domain/services/test_agent_resolver.dart` | Resolve an opaque identity to a Boolean Agent |
| `ImmutableTestAgentResolver` | `lib/essentials/presence/domain/services/test_agent_resolver.dart` | Hold a fixed, validated set of explicit Agent bindings |
| `DuplicateTestAgentBindingException` | `lib/essentials/presence/domain/services/test_agent_resolver.dart` | Report duplicate composition as a configuration defect |
| `MissingTestAgentBindingException` | `lib/essentials/presence/domain/services/test_agent_resolver.dart` | Report unresolved identity as a configuration defect |

## Identity Representation

`TestAgentId` wraps one owner-qualified stable string. Presence preserves and
compares the complete string; it does not parse owner, meaning, or version from
it. The type rejects only empty or whitespace-only values, which is the
mechanical identity integrity Presence can truthfully own. It deliberately does
not impose domain-specific naming rules or normalize the supplied value.

## Boolean Agent Contract

The complete permanent contract introduced by this slice is:

```dart
abstract interface class TestAgent {
  Future<bool> evaluate();
}
```

The Agent receives no Step, Trip, Schedule, destinations, retry state, routing
information, or shared context bag. Its configured implementation owns the
dependencies needed to establish its one fact.

## Resolver Contract

The generic resolver API is:

```dart
abstract interface class TestAgentResolver {
  TestAgent resolve(TestAgentId id);
}
```

`ImmutableTestAgentResolver` accepts an iterable of `TestAgentBinding` values,
copies them at construction, rejects duplicate identities, and exposes no
registration or replacement operation. A binding list was chosen instead of a
map because map construction can silently erase duplicate keys before the
resolver receives them. The explicit binding shape makes invalid composition
observable and rejectable.

Resolving an absent identity throws `MissingTestAgentBindingException`.
Supplying the same identity more than once throws
`DuplicateTestAgentBindingException` while the resolver is constructed. These
failures remain distinct from an Agent returning `false`, which is an ordinary
workflow fact. Exceptions thrown by an Agent also remain exceptions; the
resolver does not reinterpret them as `false`.

## Why Resolution Is Immutable

Agent availability is application composition, not mutable workflow state.
Fixing bindings at construction prevents order-dependent replacement and
"last registration wins" behavior. Defensive copying also ensures that later
mutation of the caller's binding collection cannot change resolution.

## Runtime Status

Nothing currently executes through these contracts. The existing FDA and
Contacts readiness Steps, specialist authorities, repository reconstruction,
and provider composition remain unchanged. This deliberate isolation proves
the generic primitive before persisted Test Steps or onboarding bindings are
introduced.

## Verification

Focused tests cover:

- stable identity, equality, hashing, distinction, and empty-value rejection;
- asynchronous `true` and `false` Agent results;
- one and multiple independent bindings;
- explicit missing and duplicate failures;
- preservation of ordinary `false` results and Agent exceptions;
- defensive copying and absence of later registration or replacement;
- architecture protection against workflow, specialist, SQL, and Flutter
  knowledge entering the three generic contract files.

The complete Presence and Onboarding suites remain unchanged in behavior.

## Deviation From Approved Slice 1

There is no architectural or behavioral deviation from proposal section 21,
Slice 1. The concrete `TestAgentBinding` value was added as the proposal
permitted because it is the smallest representation that preserves duplicate
detection during resolver construction.

Schema work, generic `TestStep`, onboarding Agent identities, runtime bindings,
and migration of the existing specialized Steps remain later, separately
approved slices.
