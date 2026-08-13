---
tier: project
scope: messages-source-history-sufficiency-test-agent
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: code
links:
  - 00-START-HERE.md
  - 10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md
  - ../../25-ONBOARDING-AND-ARCHIVE/20-environment-readiness.md
tests:
  - test/essentials/onboarding/application/messages_source_history_sufficiency_test_agent_test.dart
  - test/essentials/onboarding/application/messages_source_history_sufficiency_policy_test.dart
  - test/essentials/onboarding/application/real_messages_source_history_sufficiency_test_agent_provider_test.dart
  - test/essentials/onboarding/application/onboarding_test_agent_bindings_test.dart
  - test/architecture/forbidden_imports_test.dart
---

# Messages Source History Sufficiency TestAgent Implementation

## Result

Onboarding now owns one proven factual Agent for this question:

```text
Is the local Messages history sufficiently populated
for initial onboarding purposes?
```

The implementation deliberately stops at the Agent boundary. The Agent is
bound into the development resolver, but no active Schedule refers to its ID.
No user-choice grammar or sparse-history workflow was added.

## 1. Selected Count Semantics

The Agent preserves current production semantics exactly:

```sql
SELECT COUNT(*)
FROM message
```

The implementation continues to count every row in `chat.db.message`. It does
not substitute `ChatDbSourceProbeReader.readImportableMessageCount()`, whose
non-empty-GUID filter measures a different fact.

The existing generic `OnboardingDatabaseProbeReader.readTableCount()` remains
the SQLite implementation owner. The new narrow reader adapter selects the
production `message` table count with `queryOnly: true`; it contains no new
SQLite open or query implementation.

## 2. Why This Measurement Was Chosen

The purpose of this slice is parity with the production sparse-history
classifier, not redefining source completeness. No repository evidence showed
that the current all-row count was erroneous.

The all-row contract is now protected by a disposable SQLite fixture containing
rows with `NULL` GUID values. Eleven such rows evaluate as sufficient. This
would fail if the implementation silently switched to the importable-message
count.

## 3. Stable TestAgentId

Onboarding owns the opaque identity:

```text
onboarding.messages-source-history-sufficient
```

It is defined beside the existing Messages-readability and Contacts-readability
IDs. Generic Presence neither defines nor interprets it.

## 4. Concrete Agent

`MessagesSourceHistorySufficiencyTestAgent`:

1. requests a fresh integer count from `MessagesSourceHistoryCountReader`;
2. applies the Onboarding sufficiency policy;
3. returns `true` or `false`.

It knows no Trip, Schedule, destination, routing arm, remediation copy,
checkpoint, SQL, database path, or user choice.

## 5. Specialist Dependency

The dependency chain is:

```text
MessagesSourceHistorySufficiencyTestAgent
    -> MessagesSourceHistoryCountReader
    -> ProbeMessagesSourceHistoryCountReader
    -> OnboardingDatabaseProbeReader.readTableCount()
    -> read-only SQLite count fact
```

`ProbeMessagesSourceHistoryCountReader` owns the translation from the generic
database probe to the specific Messages-history fact. Application composition
supplies the Messages database path from the existing `FullDiskAccess`
boundary. The Agent sees neither path nor table mechanics.

## 6. Exact Threshold

The Onboarding-owned policy is:

```text
0 through 10 rows
    -> false

11 or more rows
    -> true
```

Production environment classification and the new Agent consume the same pure
Onboarding policy. The production state names, blocker precedence, gate, and
presentation behavior are unchanged.

## 7. Failure Semantics

`OnboardingDatabaseProbeReader.readTableCount()` historically returns `null`
when the file or count query is unavailable. The narrow reader converts that
unknown fact into `MessagesSourceHistoryCountUnavailableException`.

The Agent allows that failure to propagate. It never converts unknown into:

- `true`;
- `false`;
- zero.

This is intentionally stricter than the current production environment
classifier, which does not classify a null count as sparse. Production behavior
was not changed in this slice. The development Test Agent instead preserves
the generic `TestStep` rule that an Agent evaluation failure remains a failure.

No new Presence error model was introduced.

## 8. Fresh-Read Behavior

The Agent stores no result. Every `evaluate()` call invokes its reader again.

Tests establish both forms of fresh evidence:

- a mutable narrow reader changes from 10 to 11 between calls;
- a real temporary SQLite database gains its eleventh row between calls.

Both change the result from `false` to `true`. No Boolean is cached in the
Agent, Onboarding, Presence, or `presence.db`.

## 9. Binding Contribution

`buildOnboardingTestAgentBindings()` now requires and contributes exactly three
Onboarding Agents:

```text
onboarding.messages-source-readable
onboarding.contacts-source-readable
onboarding.messages-source-history-sufficient
```

The development application-composition provider obtains the real
source-history Agent and includes it when constructing the existing
`ImmutableTestAgentResolver`. Generic resolver contracts and semantics did not
change.

Binding tests prove:

- all three IDs have their exact stable values;
- all three IDs are distinct;
- exactly one binding is contributed per ID;
- the immutable resolver resolves the new Agent;
- duplicate contributions still fail mechanically.

## 10. Production-Parity Result

Parity is mechanical for known counts because production classification and
the Agent use the same Onboarding policy:

```text
production sparse at 10
    <=> Agent false at 10

production sufficiently populated at 11
    <=> Agent true at 11
```

The only deliberate discrepancy is unknown-count handling:

- production currently continues classification when the optional count is
  unavailable;
- the Boolean Agent fails because unknown cannot truthfully become either
  Boolean arm.

That discrepancy is documented rather than hidden or used to change
production behavior.

## 11. Tests And Verification

Coverage added or extended includes:

- exact `0`, `1`, `10`, `11`, and larger-count results;
- real SQLite `COUNT(*)` behavior;
- inclusion of rows with no importable GUID;
- unavailable-count failure propagation;
- repeated fresh evaluation;
- provider composition through the existing probe and Messages path;
- exact ID and binding contribution;
- immutable resolver composition;
- routing-agnostic Onboarding Agent boundaries;
- Presence ignorance of the Onboarding Agent identity;
- specialist independence from Presence routing.

Verification completed:

- 17 focused Agent, policy, provider, binding, and composition tests;
- 82 complete Onboarding tests;
- 61 complete Presence tests;
- 14 development-harness tests;
- 362 architecture tripwires;
- clean `flutter analyze`;
- Riverpod code generation;
- checked Schedule diagram regeneration with unchanged topology;
- successful macOS Debug build;
- Dart formatting and `git diff --check`.

## 12. No Schedule Change

`required_sources_readiness_schedule.dart` was not changed.

The slice allocated no Schedule, Trip, occurrence, or Step identity. It did not
change the checked Mermaid topology, routing, checkpoints, trace, copy, or
presentation. The new Agent is available to application composition but is not
executed by the active Schedule.

The next design question remains the two-destination user-choice requirement
identified by the planning pass. This implementation does not answer it.
