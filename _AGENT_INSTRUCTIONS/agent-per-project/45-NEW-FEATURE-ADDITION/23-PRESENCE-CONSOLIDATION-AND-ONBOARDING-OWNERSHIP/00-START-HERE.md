---
tier: project
scope: presence-onboarding-consolidation
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: doc
links:
  - ../21-PRESENCE-ITERATION-SIMPLE/30-SYSTEM-BOUNDARIES.md
  - ../22-SCHEDULE-TRiP-STEP-REAL-ONBOARDING/07-CONTACTS-SOURCE-READINESS-IMPLEMENTATION.md
  - ../../25-ONBOARDING-AND-ARCHIVE/README.md
  - 08-ONBOARDING-TEST-AGENT-COMPOSITION-IMPLEMENTATION.md
  - 09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md
  - 10-NEXT-REAL-WORKFLOW-CONCERN-PLAN.md
  - 11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md
  - 12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md
  - 13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md
  - 14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md
  - 15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md
  - 16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md
  - 17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md
  - 18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md
  - 19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md
  - 20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md
  - 21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - 22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md
  - 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md
  - 24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md
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
- implemented the pure generic `ChoiceValue`, `ChoiceOption`, and `ChoiceStep`
  domain grammar, including finite-choice validation and opaque
  value-to-destination lookup, without persistence, runtime, or presentation.
- added schema-v9 persistence for that generic Choice grammar, including
  ordered option rows, exactly-one-subtype accounting, Schedule-local
  destination validation, and additive migration coverage, while leaving
  runtime choice submission and presentation unimplemented.
- added a context-bound Choice runtime callable which accepts only the selected
  opaque value, rejects stale or repeated interactions, and reuses ordinary
  Trip checkpoint and trace machinery without adding presentation or active
  Onboarding usage.
- added permanent generic Presence Step presentation, including a
  destination-free Choice label:value projection and context-bound selection,
  while keeping workflow meaning, FDA presentation, and development
  diagnostics outside the generic presenter.
- added the real Messages-history sufficiency branch to the active Onboarding
  Schedule, including sparse-history guidance, generic Re-check / Import Anyway
  Choice routing, additive definition evolution, and existing-run preservation.
- made the permanent generic Presence runner the production renderer for the
  required-source Onboarding Schedule, including autonomous Test and fixed
  routing, destination-free Choice interaction, and explicit delegation of the
  remaining FDA Settings specialist Step to Onboarding.
- audited the exact post-readiness production handoff and found that Presence
  completion currently reveals an independently selected legacy readiness
  panel rather than advancing `OnboardingGate`; this loses the durable sparse-
  history `import_anyway` acceptance before the existing import action.
- repaired that handoff by exposing completion of the canonical required-
  sources Schedule as a narrow, read-only Onboarding acceptance fact and
  composing it with unchanged environment facts at the Environment Readiness
  surface boundary. Sparse accepted sources now expose the existing import
  action across restart; sparse unaccepted sources still expose only Re-check.
- audited the complete production lifecycle after that action and established
  that one admitted Gate operation resets derived data and then awaits one
  non-cancellable 17-stage controller build. The operation currently supports
  only coarse live progress, probe-based restart/recovery, and no truthful
  Abort behavior.
- removed the mechanically false **Abort Import** affordance and its dead
  presentation-only forwarding APIs. First-run and reimport progress are now
  explicitly non-cancellable while all reset, build, failure, recovery, and
  restart behavior remains unchanged.
- audited the complete production progress surface against facts currently
  exposed by the Gate and graph-build controller. The best supported design is
  minimal calm with indeterminate activity and explicit keep-open guidance;
  elapsed time and live stage narration are not yet earned.
- replaced the repetitive active-progress paragraph with shared, truthful
  guidance to keep MessageLens open while confirming that other applications
  may be used. First-run and direct-reimport progress retain their existing
  coarse headlines, indeterminate activity, and non-cancellable behavior.

> The generic Boolean Test architecture is complete. Read the
> [consolidation audit](09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md) for the
> current architectural result; read Slices 1-4 for implementation history.

## Explicit Non-Goals

The completed slices do not:

- change Step results, Trip, Scheduler, routing, checkpointing, or trace;
- change the `OnboardingGate`'s ownership of import, graph construction,
  recovery, or reimport operations;
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
- [ChoiceStep and generic Presence presentation proposal](12-CHOICESTEP-AND-WORKFLOW-PRESENTATION-PROPOSAL.md)
- [ChoiceStep pure domain implementation](13-CHOICESTEP-PURE-DOMAIN-IMPLEMENTATION.md)
- [ChoiceStep additive persistence implementation](14-CHOICESTEP-ADDITIVE-PERSISTENCE-IMPLEMENTATION.md)
- [ChoiceStep runtime completion implementation](15-CHOICESTEP-RUNTIME-COMPLETION-IMPLEMENTATION.md)
- [Generic Presence presentation implementation](16-GENERIC-PRESENCE-PRESENTATION-IMPLEMENTATION.md)
- [Onboarding Messages-history Choice workflow implementation](17-ONBOARDING-MESSAGES-HISTORY-CHOICE-WORKFLOW-IMPLEMENTATION.md)
- [Production generic Presence runner integration](18-PRODUCTION-GENERIC-PRESENCE-RUNNER-INTEGRATION.md)
- [Post-readiness Onboarding handoff audit](19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md)
- [Durable accepted-readiness import handoff implementation](20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md)
- [Initial import and graph-build lifecycle audit](21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md)
- [Remove misleading Abort Import implementation](22-REMOVE-MISLEADING-ABORT-IMPORT-IMPLEMENTATION.md)
- [Production import progress surface audit](23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md)
- [Truthful keep-open progress guidance implementation](24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md)

Prompts are retained under [`prompts/`](prompts/). Future response artifacts
may be collected under [`responses/`](responses/README.md).
