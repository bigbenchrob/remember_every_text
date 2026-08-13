---
tier: project
scope: presence-onboarding-consolidation
owner: agent-per-project
last_reviewed: 2026-08-12
source_of_truth: doc
links:
  - ../21-PRESENCE-ITERATION-SIMPLE/30-SYSTEM-BOUNDARIES.md
  - ../22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/07-CONTACTS-SOURCE-READINESS-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/README.md
  - 08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md
  - 09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
  - 10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md
  - 11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md
tests: []
---

# Presence Consolidation And Onboarding Ownership

## Why This Package Exists

The Presence proof-of-concept has established working Schedule, Trip, Step,
routing, checkpoint, restart, trace, diagram, and live-visualization behavior.
The real Messages and Contacts readiness experiment has also established a
truthful onboarding workflow.

The next task is consolidation: separate generic workflow machinery from the
meaning of onboarding without changing the proven execution model.

> A shared `presence.db` can store definitions for many workflows without
> making Presence the semantic owner of those workflows.

## Current Ownership Conjecture

```text
lib/essentials/presence/
    generic workflow machinery

lib/essentials/onboarding/
    onboarding workflow meaning and integration

specialist features and essentials
    concrete domain expertise requested by onboarding

lib/features/presence_iteration_simple/
    disposable development and inspection harness
```

Presence owns how definitions execute. Onboarding owns what the onboarding
definition means. Specialists own how factual work is performed.

## Current Progress

The consolidation has now:

- inventoried current ownership;
- given proven onboarding workflow code a permanent home;
- made only mechanically safe file moves;
- introduced the generic opaque Test Agent contracts and immutable resolver;
- added the generic persisted Boolean Test grammar;
- cut active Boolean-test reconstruction over to generic `TestStep` and
  Schedule-scoped opaque Agent resolution;
- made Onboarding the permanent owner of its Agent IDs, concrete Test Agents,
  and binding contribution;
- moved immutable resolver construction to the current application-composition
  boundary and retired the temporary readiness-authority bridge;
- completed a post-Slice-4 audit confirming the generic Boolean Test runtime,
  persistence, ownership, and dependency boundaries;
- identified `OpenFdaSettingsStep` and `FdaSettingsOpeningAuthority` as the
  sole remaining active domain-specific debt inside generic Presence.
- traced the next real production concern to local Messages history
  sufficiency and identified one concrete, still-unimplemented user-choice
  requirement without generalizing an operation abstraction.
- implemented and bound the Onboarding-owned local-history sufficiency Agent
  with production-parity `COUNT(*)` semantics, truthful unknown-count failure,
  and fresh reads, without adding it to the active Schedule.

> The generic Boolean Test architecture is complete. Read the
> [consolidation audit](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md) for the
> current architectural result; read Slices 1-4 for implementation history.

## Explicit Non-Goals

The completed slices do not:

- change Step results, Trip, Scheduler, routing, checkpointing, or trace;
- change production `OnboardingGate` behavior;
- generalize the still-transitional FDA Settings-opening Step;
- extend onboarding with another blocker;
- redesign the development host.

## Documents

- [Current ownership inventory](01-CURRENT-OWNERSHIP-INVENTORY.md)
- [Target ownership proposal](02-TARGET-OWNERSHIP-PROPOSAL.md)
- [First mechanical moves](03-FIRST-MECHANICAL-MOVES.md)
- [Generic TestStep and opaque Agent resolution proposal](04-GENERIC-TESTSTEP-AND-OPAQUE-AGENT-RESOLUTION-PROPOSAL.md)
- [Generic Test Agent contracts implementation](05-GENERIC-TEST-AGENT-CONTRACTS-IMPLEMENTATION.md)
- [Generic TestStep additive schema implementation](06-GENERIC-TESTSTEP-ADDITIVE-SCHEMA-IMPLEMENTATION.md)
- [Generic TestStep runtime cutover implementation](07-GENERIC-TESTSTEP-RUNTIME-CUTOVER-IMPLEMENTATION.md)
- [Onboarding Test Agent composition implementation](08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md)
- [Presence TestStep consolidation audit](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md)
- [Next real workflow concern plan](10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md)
- [Messages source history sufficiency TestAgent implementation](11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md)

Prompts are retained under [`prompts/`](prompts/). Future response artifacts
may be collected under [`responses/`](responses/README.md).
