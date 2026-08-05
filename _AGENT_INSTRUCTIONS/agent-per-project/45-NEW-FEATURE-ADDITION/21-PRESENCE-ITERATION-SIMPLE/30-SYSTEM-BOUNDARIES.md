# Presence Iteration System Boundaries

## Purpose

This document prevents responsibility creep.

It answers one question:

> What does each part know, and what must it never know?

## Status

This document evolves with the implementation.

It is the current architectural authority for the iterative Presence
implementation.

`43-PRESENCE` remains valuable historical design work. It is not authoritative
for the current implementation.

Implementation discoveries may change this document. Boundaries change only
through explicit architectural decisions, never through silent exceptions.

## Boundary Philosophy

1. Each part owns one responsibility.
2. Every part knows only enough to perform its responsibility.
3. System capability emerges from the interaction of simple parts.
4. Complexity belongs locally inside specialists. Simplicity belongs globally.
5. When a new requirement appears, move the responsibility to its natural
   owner. Do not broaden another component merely because it is convenient.

## Boundary Rules Are Invariants

Implementation convenience never justifies crossing a boundary.

No component may inspect or duplicate another component's private
responsibility "just this once."

If implementation reveals that a boundary cannot support required behavior:

- stop;
- discuss it;
- revise the boundary explicitly;
- record the revision.

Silent exceptions are prohibited.

## Current Proven Boundaries

### JourneyDefinitionStore

Knows:

- relational Journey definitions;
- relational Step definitions.

Knows nothing about:

- Journey progression;
- presentation;
- widgets;
- animation;
- onboarding.

### DriftJourneyRepository

Knows:

- how to construct Journey and Step domain objects.

Knows nothing about:

- presentation;
- Journey progression;
- onboarding.

### Journey

Knows:

- ordered Steps.

Knows nothing about:

- presentation;
- current position;
- timing;
- how any Step succeeds;
- onboarding.

### JourneyProgress

Knows:

- current Step;
- advancing;
- Done.

Knows nothing about:

- Tell;
- Ask;
- auditing;
- presentation;
- animation.

### JourneyView

Knows:

- current Step;
- JourneyProgress;
- which Step presentation component to create;
- advancing after successful Step completion.

Knows nothing about:

- repositories;
- Drift;
- onboarding logic;
- how individual Step types complete.

### TellStep

Knows:

- its text;
- whether it completes automatically;
- its visible hold duration as part of its own completion rule.

Knows nothing about:

- Journey;
- progression;
- presentation execution;
- fade or pause timing;
- onboarding.

### TellStepViewModel

Knows:

- one Tell Step.
- how to expose that Tell's presentation data, including its Tell-owned visible
  hold duration.

Knows nothing about:

- Journey;
- progression;
- animation;
- sibling Steps.

### TellStepView

Knows:

- Tell presentation;
- how to execute the standardized fade, supplied visible hold duration, and
  pause lifecycle;
- when Tell has completed its own presentation lifecycle.

It consumes the visible hold duration owned by the Tell definition. It does
not define that duration.

Knows nothing about:

- Journey;
- progression;
- siblings;
- repositories;
- onboarding.

### AskStepViewModel

Knows:

- one Ask Step.

### AskStepView

Knows:

- presenting the question;
- collecting one answer;
- local acceptance;
- reporting one accepted answer.

Knows nothing about:

- Journey;
- progression;
- meaning of the answer.

### PresenceIterationSimpleHost

Knows:

- loading one Journey;
- owning temporary laboratory state;
- receiving Ask answers.

Knows nothing about:

- Journey progression;
- Step presentation;
- answer meaning.

## Recent Discoveries

Journey knows almost nothing.

Each Step defines its own meaning of success.

Journey advances only after the current Step reports success.

Journey never determines how a Step succeeds.

Tell owns its visible hold duration as part of its completion rule.

Tell presentation executes the standardized lifecycle using that supplied
duration.

Ask owns collection of one answer.

Successful verification Steps may produce no retained data.

Journey sequences.

Specialists specialize.

## Questions Still Open

- How should Journey receive heterogeneous Step results?
- Do successful values belong to Journey or directly to the owning feature?
- How do auditing Steps locate their AuditingAgent?
- How will production onboarding request Journeys from OnboardingGate?
