---
tier: project
scope: presence-onboarding-consolidation
owner: agent-per-project
last_reviewed: 2026-08-15
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
  - 25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md
  - 26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md
  - 27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - 28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md
  - 29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md
  - 30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - 31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md
  - 32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md
  - 33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md
  - 34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md
  - 35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md
  - 36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md
  - 40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md
  - 38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md
  - 39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md
  - 41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md
  - 50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md
  - 51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md
  - 52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md
  - 53-USER-INITIATED-SETUP-MUTATION-BUSY-FEEDBACK-AUDIT.md
  - 54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md
  - 55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md
  - 56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md
  - 57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md
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
- audited the remaining gap before that progress surface and established that
  the Gate stays `awaitingUserAction` through admission, its current cached FDA
  guard, and the complete destructive reset. The existing **Preparing setup…**
  overlay can truthfully begin after admission/FDA readiness and before reset;
  no new loading authority or persisted state is needed.
- moved the existing first-run `importing` presentation ahead of derived-data
  reset, so **Preparing setup…** now acknowledges admitted work while reset is
  active. Reset failure restores readiness and rethrows, while Gate preparation
  takes temporary presentation precedence over stale controller terminal state.
- established archived attachment payloads as preservation data outside every
  ordinary reset/reimport/recovery boundary, documented the current reset
  allow-list, and added tripwires against broad directory deletion or preserved
  store authority.
- audited the initial-setup completion surface and established that the human
  primarily needs readiness rather than import/projection diagnostics. The
  preferred next slice is one calm readiness handoff with the existing explicit
  action and without primary metric chips; completion remains transient and
  attachment archival completeness remains outside its truth budget.
- replaced the production diagnostic completion body with **MessageLens is
  ready**, one bounded local-browsing-data statement, and the unchanged **Get
  Started** / **Done** handoff. Technical counts remain available to diagnostics
  and the development panel; completion durability and operation behavior are
  unchanged.
- audited every current setup failure and recovery boundary, including
  uncaught admission/reset errors, caught controller errors, abrupt termination,
  automatic cleanup, retry, and support-report export. The audit establishes
  that existing coarse operation truth is enough for a calm primary failure
  surface and recommends one next slice: prevent raw controller exceptions from
  becoming the active-progress headline.
- replaced that transient raw exception headline with the fixed, phase-neutral
  statement **MessageLens couldn't finish preparing browsing data.** First-run
  setup and direct reimport now share the bounded presentation while raw error
  evidence remains unchanged in controller state and diagnostics.
- unified the stable import- and graph-failure primary narratives as
  **MessageLens couldn't finish setup** with one bounded retry explanation.
  Persistence buckets, branch-specific retry labels, support reporting, raw
  diagnostic notes, and all operation mechanics remain unchanged.
- audited every secondary item still shown on the stable failure surface and
  established **calm primary + secondary support** as the preferred hierarchy.
  Raw errors, timestamps, environment probes, and internal store facts already
  survive in support diagnostics and do not select a different human action;
  the next bounded slice is removal of the misleading **What to check** card
  from the two stable failure branches without adding Technical Details.
- removed that **What to check** card from the stable import- and graph-failure
  branches without changing persistence, support reporting, Environment
  Summary, retry, recovery, reset, or attachment preservation. The reduced
  surface now fits the existing overlay at default test typography without a
  scrolling or geometry workaround.
- removed **Environment summary** from only the stable import- and graph-
  failure branches. All report/probe evidence, retry and support behavior, and
  every other Environment Summary use remain unchanged; the stable surface
  still fits at default typography without a geometry workaround.
- removed the pre-action email/Finder transport caption from those stable
  failures while preserving **Send Report To Developer**, report generation,
  and all result-specific post-action feedback. The ordinary reading order is
  now limited to human orientation and the two supported actions.
- audited automatic-recovery presentation, removed its diagnostic reason card,
  and replaced unsupported prior-attempt and broad deletion language with calm,
  bounded browsing-data preparation copy while preserving recovery mechanics.
- audited failures around admission, pre-build reset, automatic recovery,
  direct reimport, and explicit Settings reset. The audit distinguishes
  prerequisite blocking, busy denial, other pre-action admission failure, and
  admitted reset failure; recommends one process-local Onboarding preparation-
  failure state as the next slice; and leaves filesystem probes as the sole
  durable restart authority.
- implemented that process-local preparation-failure state for admitted first-
  run reset failure, admitted automatic-recovery reset failure, and non-
  contention automatic-recovery admission error. Retry reuses the ordinary
  setup entry point, refresh/restart restore environment authority, and FDA,
  busy denial, controller persistence, Settings reset, Presence, and attachment
  preservation remain unchanged.
- audited automatic-recovery mutation contention and proved that the current
  denial/self-invalidation path can immediately retry from the same unchanged
  report. The coordinator already publishes the required locked-to-idle seam;
  the next bounded slice should defer inside the Gate, re-probe environment
  truth on release, and publish recovery only after admission, without timers,
  queueing, persistence, new status, or human-facing busy UI.
- implemented event-driven automatic-recovery deferral. Busy denial now waits
  silently for a real locked-to-idle transition, invalidates Environment
  Readiness, rejects Riverpod's retained refreshing value as stale, and acts
  only on the completed fresh report. Recovery presentation begins only after
  admission; timers, queues, persistence, status/UI additions, reset changes,
  and mutation-policy changes remain absent.
- validated the real production onboarding composition and realistic automated
  journeys end to end. Ordinary debug and release composition now reach the
  real Gate and authored Onboarding Schedule; the Presence harness is explicit
  opt-in tooling. Validation found one remaining P1: a missing or invalid
  Messages source is represented as FDA denial and can loop on incorrect
  permission guidance. No production archive was used.
- corrected that P1 by preserving explicit filesystem access-denial evidence,
  projecting one bounded specialist result through adjacent generic Boolean
  TestAgents, and routing every non-FDA failure to calm source-unavailable
  guidance. Retry performs a fresh protected read, and Gate, history Choice,
  reset, recovery, and attachment behavior remain unchanged.
- corrected the production-observed Step 6302 installation blocker without
  resetting Presence state or weakening definition immutability. The authored
  Schedule again matches Step 6302's persisted Tell payload; the exact
  historical fixture, active FDA checkpoint, additive Slice 55 Trips, and
  genuine-redefinition rejection are now protected by focused tests.

## Package Closure

Feature Addition 23 has reached a natural architectural boundary. The
production-observed Step 6302 conflict challenged the premise that normal
runtime should reconcile a second Dart-authored guidebook against persisted
definitions record by record.

The [guidebook lifecycle handoff](57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md)
records the agreed next direction: `presence.db` is the installed runtime
guidebook authority; Presence state may be durable within one guidebook
generation and disposable when that generation changes; Onboarding remains
ignorant of Schedule, Trip, Step, occurrence, and routing geometry.

Guidebook installation, generation/replacement, runtime definition authority,
removal of runtime reconciliation, and cross-version Presence-state policy now
belong to a new sibling feature addition. This package may receive factual
corrections, but it is no longer the working home for that architecture.

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
- [Pre-overlay import-start acknowledgement audit](25-PRE-OVERLAY-IMPORT-START-ACKNOWLEDGEMENT-AUDIT.md)
- [Pre-reset preparation progress implementation](26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md)
- [Attachment preservation safety invariant](27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md)
- [Initial setup completion surface audit](28-INITIAL-SETUP-COMPLETION-SURFACE-AUDIT.md)
- [Calm initial setup completion handoff implementation](29-CALM-INITIAL-SETUP-COMPLETION-HANDOFF-IMPLEMENTATION.md)
- [Initial setup failure and recovery surface audit](30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md)
- [Bounded active-progress failure headline implementation](31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md)
- [Phase-neutral stable setup failure copy implementation](32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md)
- [Failure diagnostic information hierarchy audit](33-FAILURE-DIAGNOSTIC-INFORMATION-HIERARCHY-AUDIT.md)
- [Remove What to check from stable failure implementation](34-REMOVE-WHAT-TO-CHECK-STABLE-FAILURE-IMPLEMENTATION.md)
- [Remove Environment Summary from stable failure implementation](35-REMOVE-ENVIRONMENT-SUMMARY-STABLE-FAILURE-IMPLEMENTATION.md)
- [Remove support transport caption from stable failure implementation](36-REMOVE-SUPPORT-TRANSPORT-CAPTION-STABLE-FAILURE-IMPLEMENTATION.md)
- [Automatic recovery presentation audit](40-AUTOMATIC-RECOVERY-PRESENTATION-AUDIT.md)
- [Remove automatic-recovery diagnostic reason implementation](38-REMOVE-AUTOMATIC-RECOVERY-DIAGNOSTIC-REASON-IMPLEMENTATION.md)
- [Calm, truthful automatic-recovery copy implementation](39-CALM-TRUTHFUL-AUTOMATIC-RECOVERY-COPY-IMPLEMENTATION.md)
- [Recovery and pre-build failure state audit](41-RECOVERY-AND-PRE-BUILD-FAILURE-STATE-AUDIT.md)
- [Process-local Onboarding preparation failure implementation](50-PROCESS-LOCAL-ONBOARDING-PREPARATION-FAILURE-IMPLEMENTATION.md)
- [Automatic recovery mutation-busy deferral audit](51-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-AUDIT.md)
- [Automatic recovery mutation-busy deferral implementation](52-AUTOMATIC-RECOVERY-MUTATION-BUSY-DEFERRAL-IMPLEMENTATION.md)
- [User-initiated setup mutation-busy feedback audit](53-USER-INITIATED-SETUP-MUTATION-BUSY-FEEDBACK-AUDIT.md)
- [End-to-end production onboarding validation](54-END-TO-END-PRODUCTION-ONBOARDING-VALIDATION.md)
- [Truthful Messages source vs FDA readiness implementation](55-TRUTHFUL-MESSAGES-SOURCE-VS-FDA-READINESS-IMPLEMENTATION.md)
- [Observed Onboarding Step-redefinition blocker implementation](56-OBSERVED-ONBOARDING-STEP-REDEFINITION-BLOCKER-IMPLEMENTATION.md)
- [Presence guidebook lifecycle handoff](57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md)

Prompts are retained under [`prompts/`](prompts/). Future response artifacts
may be collected under [`responses/`](responses/README.md).
