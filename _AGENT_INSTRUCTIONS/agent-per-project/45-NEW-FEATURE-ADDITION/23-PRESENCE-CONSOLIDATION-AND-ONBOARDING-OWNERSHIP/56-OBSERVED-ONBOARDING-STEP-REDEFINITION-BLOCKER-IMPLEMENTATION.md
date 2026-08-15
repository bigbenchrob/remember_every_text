---
tier: project
scope: onboarding-definition-evolution
owner: agent-per-project
last_reviewed: 2026-08-15
source_of_truth: implementation-record
links:
  - 54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md
  - 55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md
  - ../21-PRESENCE-ITERATION-SIMPLE/16-PRESENCE-DATABASE-SCHEMA-WALKTHROUGH.md
tests:
  - test/essentials/onboarding/application/required_sources_readiness_definition_extension_test.dart
---

# Observed Onboarding Step-Redefinition Blocker Implementation

## Observed Blocker

The real production-shaped Onboarding journey reached Environment Readiness and
then stopped while installing the authored Schedule:

```text
Bad state: Existing Step 6302 in Trip TripDefinitionId(303)
cannot be redefined.
```

This was an existing-installation upgrade failure. `presence.db` was neither
deleted nor reset.

## Exact Identity Trace

Trip 303 is `required_sources_messages_remediation`, the FDA guidance Trip.
Step 6302 is its second Step, the Tell named
`explain_required_sources_full_disk_access_action`. It was introduced in commit
`9ac502ad` at app version `0.2.18+36`.

The stored and newly authored definitions differed only in their Tell payload:

```text
Persisted Step 6302
    type: TellStep
    Trip: 303
    position: 1
    name: explain_required_sources_full_disk_access_action
    text: In Full Disk Access, add or enable MessageLens Development. ...

Slice 55 authored Step 6302
    type: TellStep
    Trip: 303
    position: 1
    name: explain_required_sources_full_disk_access_action
    text: In Full Disk Access, add or enable MessageLens. ...
```

Slice 55 did not change this Step's type, ID, name, Trip membership, position,
Agent, or destination. It changed the human instruction under the existing
canonical identity.

## Classification And Correction

This was **authored identity reuse**. The persistence guard was correct:
canonical Step identity 6302 already meant the development-specific Tell and
could not silently acquire different historical meaning.

The production-name edit was incidental to Slice 55's P1 source-classification
repair. It was not required by the new `readable` / `accessDenied` /
`unavailable` behavior. The smallest safe correction therefore restores the
original Step 6302 payload in the authored definition.

No new Step, Trip, or occurrence IDs were allocated. A replacement FDA Trip
would have changed default-next behavior around its terminal
`OpenFdaSettingsStep` and added migration topology solely for copy. That would
have been less safe than retaining the established semantic identity.

## Preserved Evolution

The valid additive parts of Slice 55 remain:

- Trips 310 and 311 and occurrences 6110 and 6111 are inserted;
- new Steps 7001, 7101, and 7102 are inserted;
- existing TestSteps 6201 and 6402 retain their Agent identities while their
  Schedule-local routes are reconciled to Trip 310;
- occurrence 6107 retains its identity and moves to final position 10;
- source retries still perform a fresh probe;
- only explicit permission denial routes to FDA guidance.

The repository continues to permit identical definitions, new definitions,
Schedule-local Test-route updates, and occurrence-position reconciliation. It
continues to reject arbitrary mutation of existing Step meaning.

## Existing Runs And History

Runs persist the current Trip occurrence, not the current Step. The correction
does not change any existing Trip or occurrence identity. A run checkpointed at
historical FDA occurrence 6103 therefore reloads the same Trip, restarts it at
Step 1 under the established Trip-granular rule, and continues to verification
occurrence 6104 after the terminal Settings Step.

Completed runs remain complete. Existing execution trace retains its original
Step and Trip meaning. New and active runs both use the extended source-
classification topology without rewriting historical definitions.

## Regression Proof

The focused upgrade fixture now persists the exact pre-Slice-55 Schedule,
including the original Step 6302 text, before installing the current authored
definition. It proves:

- the real historical upgrade succeeds;
- Step 6302 remains unchanged;
- new Trips and Steps are present;
- an active checkpoint at occurrence 6103 survives and continues to 6104;
- an active checkpoint elsewhere survives;
- completed runs stay complete;
- identical reinstallation succeeds;
- a genuine changed payload under Step 6302 still fails;
- occurrence remapping remains prohibited.

No schema, migration, Presence grammar, generic TestStep, Gate/harness routing,
Choice/history behavior, reset behavior, browsing database, source database,
or attachment behavior changed.

## Verification

- The focused historical-definition extension suite passed all 8 tests.
- The related source-readiness, Agent-binding, Presence repository, onboarding
  gate, and production-host suites passed.
- The complete Flutter suite passed all 1,722 tests.
- The architecture tripwire suite passed all 374 checks.
- `flutter analyze` reported no issues.
- `flutter build macos --debug` produced
  `build/macos/Build/Products/Debug/MessageLens Development.app` without
  launching it. Xcode continued to emit the existing empty-build-number and
  `volume_controller` privacy-manifest processing warnings.
- `git diff --check` passed.

## Manual Re-Test

Automated proof covers the exact stored-definition shape. Manual confirmation
still requires launching the same development installation without deleting
`presence.db` and verifying that Onboarding passes the former Step 6302
installation blocker. This document does not claim that check has already been
performed.
