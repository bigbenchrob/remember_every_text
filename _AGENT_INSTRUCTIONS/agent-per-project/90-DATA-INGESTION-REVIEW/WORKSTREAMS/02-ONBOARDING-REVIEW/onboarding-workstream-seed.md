# Workstream 2 — Onboarding Review

## Autonomous Current-State Audit And UX Assessment

## Agent Role

For this workstream, you are acting as an independent product engineer and UX reviewer.

Your first responsibility is to understand the onboarding experience exactly as it exists.

Your second responsibility is to document what the user experiences, where confidence is gained or lost, and which behaviours should change.

Implementation begins only after the current experience has been observed and described accurately.

Do not begin by redesigning onboarding from memory or from old planning documents.

Use the development application and disposable development archives to study the real behaviour.

---

# Background

Workstream 1 — Production Data Protection is complete enough for onboarding work to proceed safely.

The environment boundary is now:

```text
Production MessageLens
    -> production identity
    -> permanent production archive
    -> remains running and preserves live Messages and attachments

MessageLens Development
    -> development identity
    -> external development archive
    -> may be created, reset, discarded, and recreated for experiments
```

Production must not be involved in this workstream.

All onboarding investigation, implementation, reset, and repetition must occur in the Development environment.

Do not repoint Debug or Profile at production.

Do not modify, reset, migrate, inspect experimentally, or otherwise use the production archive as an onboarding fixture.

---

# Workstream Location

Create and maintain the workstream under:

```text
90-DATA-INGESTION-REVIEW/
  WORKSTREAMS/
    02-ONBOARDING-REVIEW/
```

Preserve the existing engineering-notebook convention.

Use the existing files where present and update them rather than creating parallel documents unnecessarily.

Expected documents include:

```text
README.md
00-task.md
CURRENT-STATE-AUDIT.md
PROPOSAL.md
IMPLEMENTATION-PLAN.md
VALIDATION.md
COMPLETION-REPORT.md
```

Create additional focused documents only when they serve a clear purpose.

---

# Primary Objective

Make onboarding calm, trustworthy, understandable, interruptible, recoverable, and pleasant to repeat.

The experience should communicate:

> MessageLens understands that this is important, knows what it is doing, and will not lose the user's history.

The goal is not merely to get through permissions and initial import.

The goal is to establish trust before, during, and after the first major data operation.

---

# Development Workflow

Use the following iterative cycle:

```text
Create or reset disposable development archive
    ↓
Launch MessageLens Development
    ↓
Experience onboarding as a new user
    ↓
Record observations
    ↓
Propose bounded improvements
    ↓
Implement
    ↓
Repeat from a fresh disposable archive
```

Prefer recreating or resetting disposable development archives over manually altering individual database files.

The development archive may be deleted and rebuilt whenever necessary.

Production data may not.

---

# Phase 1 — Current-State Audit

Begin with a read-only and observational audit.

Do not immediately change onboarding code.

Inspect:

- startup routing;
- first-launch detection;
- archive admission;
- onboarding state model;
- environment readiness;
- permission handling;
- database readiness checks;
- initial Messages import;
- Contacts import;
- Conversation graph construction;
- attachment archiving;
- progress reporting;
- interruption handling;
- restart and resume behaviour;
- failure handling;
- automatic recovery;
- completion transition into the normal application;
- developer reset paths.

Use code inspection and actual disposable-development runs.

Record verified behaviour rather than relying on historical documentation.

---

# User Experience Assessment

Evaluate the onboarding experience from the perspective of someone who knows nothing about MessageLens.

For every screen and phase, assess:

- What does the user think is happening?
- What is actually happening?
- What must the user do?
- Why must they do it?
- Is the next step obvious?
- Is the language understandable?
- Is the interface calm or busy?
- Does progress feel real?
- Can the user tell whether the app is waiting, working, blocked, or finished?
- Can the operation be interrupted safely?
- What happens after relaunch?
- Does the app explain recovery truthfully?
- Does the user know when it is safe to leave the app alone?
- Does the experience earn confidence?

Pay particular attention to moments where the user may wonder:

- “Has it frozen?”
- “Did I do something wrong?”
- “Can I quit?”
- “Is it copying my attachments?”
- “Will it resume?”
- “Why is this taking so long?”
- “What happens next?”

---

# Calm Progress Presentation

Review the current progress UI and identify opportunities to make major data operations feel less busy and more reassuring.

The desired tone is:

> “I’ve got this.”

That does not mean vague reassurance.

The interface must still communicate truthful state.

Prefer:

- clear phase names;
- one primary status message;
- restrained movement;
- meaningful progress;
- calm transitions;
- concise explanations;
- explicit interruption guidance;
- clear completion.

Avoid:

- rapidly changing technical counters with no interpretation;
- several competing progress indicators;
- logs presented as primary UI;
- unexplained pauses;
- false precision;
- cheerful language that conceals failures;
- excessive animation or urgency.

---

# Required Test Scenarios

At minimum, exercise onboarding against disposable development archives under these conditions:

## Clean start

- empty development archive;
- expected permissions available;
- live Messages source available;
- normal first import;
- normal attachment archiving;
- successful completion.

## Permission problems

- Full Disk Access unavailable;
- Contacts access unavailable where applicable;
- external development volume unavailable;
- user grants permission and relaunches;
- user does not grant permission.

## Interruption

- quit during source import;
- quit during graph construction;
- quit during attachment archiving;
- machine restart or simulated abrupt termination where safely testable;
- relaunch after interruption.

## Existing partial state

- import database present but incomplete;
- graph missing;
- graph incomplete;
- attachment archive partially populated;
- stale or interrupted onboarding evidence;
- recoverable and unrecoverable inconsistencies.

## Repeat and reset

- complete onboarding;
- reset development data;
- onboard again;
- repeat several times;
- prove that reset affects only the development archive.

## Scale

- representative large source;
- long-running initial import;
- attachment-heavy source;
- no-change or already-caught-up state.

Use synthetic, temporary, or approved read-only source material as appropriate.

Do not use production as the write target.

---

# Audit Deliverable

Update or create:

```text
CURRENT-STATE-AUDIT.md
```

It should include:

## Executive Summary

- current onboarding quality;
- strongest existing features;
- principal UX failures;
- principal operational risks;
- highest-priority improvements.

## Current Flow

Document the complete route from launch to normal application use.

Include:

- states;
- transitions;
- user actions;
- background work;
- persistence;
- restart behaviour;
- owning code.

## Screen-By-Screen Assessment

For each onboarding screen or major state:

- purpose;
- visible content;
- user action;
- actual system activity;
- strengths;
- confusion;
- trust impact;
- suggested direction.

## Recovery Matrix

Include a table such as:

| Interrupted phase | Persistent state left behind | Relaunch behaviour | Safe? | User explanation adequate? |
| ----------------- | ---------------------------- | ------------------ | ----- | -------------------------- |

## UX Findings

Classify findings by severity:

- blocking;
- high;
- moderate;
- polish.

## Questions Requiring Product Decisions

Keep these bounded and concrete.

Do not ask the user to decide matters that can be resolved through evidence or conservative UX judgment.

---

# Proposal Phase

After the audit is complete, prepare a coherent proposal.

The proposal should define:

- the intended onboarding narrative;
- screen and phase structure;
- progress presentation;
- permission flow;
- interruption and resume experience;
- recovery experience;
- completion experience;
- relationship between onboarding and normal application startup;
- developer reset/replay workflow.

Prefer the smallest coherent redesign.

Do not rewrite sound architecture merely to make the UI easier to implement.

---

# Implementation Authority

After the proposal and implementation plan are internally coherent, proceed autonomously with non-production implementation unless a genuine product decision requires user input.

You are authorized to:

- modify onboarding UI and state handling;
- refine copy;
- reorganize progress presentation;
- add or change development-only reset/replay tools;
- improve interruption and resume handling;
- improve recovery routing;
- add tests and disposable fixtures;
- update onboarding documentation;
- run repeated onboarding cycles;
- delete and recreate development archives;
- inspect live Apple source data read-only when the development identity has permission;
- update canonical documentation after behaviour is implemented and verified.

Do not return merely to report routine progress.

---

# Production Safety

Throughout this workstream:

- leave the production application running;
- do not stop it unless the user explicitly authorizes a production operation;
- do not write to the production archive;
- do not launch development against the production root;
- do not alter production archive identity;
- do not use production attachments as disposable test output;
- do not interpret access to live `chat.db` as permission to write production state.

If a development operation resolves the production root or production marker, stop immediately and report the exact cause.

---

# Decision Policy

Resolve routine implementation decisions autonomously using this order:

1. Production Readiness master-plan invariants.
2. Production Data Protection boundary.
3. Verified onboarding behaviour.
4. Existing MessageLens architecture and ownership.
5. The smallest calm and recoverable UX.
6. Clear ordinary language.
7. Conservative fail-closed behaviour.

When several designs are reasonable, prefer the one that:

- is easiest for a new user to understand;
- makes actual state visible;
- minimizes decisions during long-running work;
- recovers cleanly after interruption;
- avoids technical terminology;
- preserves existing ownership boundaries;
- is easiest to test repeatedly.

---

# Communication Style

Use plain English in reports and user-facing copy.

Do not invent elaborate terms for ordinary concepts.

Prefer:

- “backup” over “checkpoint” in user-facing operational language;
- “development data” over “non-production payload”;
- “MessageLens is importing your messages” over internal pipeline terminology;
- “You can safely quit; MessageLens will continue from here next time” when that statement is actually true.

Technical precision belongs in implementation documents.

User-facing onboarding language should be understandable without knowledge of SQLite, graph projection, archive admission, cursors, providers, or migrations.

---

# Do Not Return For

Do not pause merely because:

- a label or screen title must be chosen;
- a disposable archive must be reset;
- tests reveal routine defects;
- copy needs several iterations;
- layout must be adjusted;
- a state class must be refactored;
- a recovery case needs a fixture;
- documentation must be synchronized;
- generated code or snapshots must be updated.

These are part of the assignment.

---

# Mandatory Stop Conditions

Stop and report only if:

1. A required next action would contact or mutate the production archive.
2. Production preservation is no longer running or fresh evidence shows it has failed.
3. Development unexpectedly resolves production identity or storage.
4. A safe test cannot be performed without production contact.
5. Repository evidence contradicts a hard architectural invariant.
6. A product decision would materially change the onboarding philosophy rather than a routine implementation detail.
7. Unrelated user changes would be overwritten.
8. Credentials or permissions unavailable to you are required.
9. The implementation reaches a state ready for user UX review and subjective judgment is now the limiting factor.
10. All authorized audit, proposal, implementation, and validation work is complete.

When stopping, provide:

- what is complete;
- the exact issue or review question;
- relevant screenshots or evidence;
- the smallest decision required;
- the safest next step.

---

# Success Criteria

Workstream 2 is complete when:

- onboarding can be repeated safely against disposable development archives;
- the entire first-run path is understandable to a new user;
- permissions are explained clearly;
- long operations feel calm and truthful;
- interruption and restart behaviour are defined and tested;
- recovery paths are reliable and comprehensible;
- attachment archiving is visible and trustworthy;
- completion transitions cleanly into normal use;
- reset and replay affect development only;
- production remains continuously preserved and untouched;
- canonical onboarding documentation reflects implemented behaviour;
- the user is confident enough to polish and repolish the experience without fearing the archive.

Begin with the current-state audit and actual onboarding runs in MessageLens Development. Continue autonomously through proposal and implementation where safe, returning when the experience is ready for informed user review.
