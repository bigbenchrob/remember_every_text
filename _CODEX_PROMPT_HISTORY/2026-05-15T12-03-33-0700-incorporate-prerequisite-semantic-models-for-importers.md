---
created_at: 2026-05-15T12:03:33-07:00
title: "Incorporate prerequisite semantic models for importers"
tags: []
source: codex_prompt_history.html
---

# Incorporate prerequisite semantic models for importers

## Prompt

```text
Next architectural slice: introduce explicit prerequisite semantics WITHOUT execution orchestration yet.

Context

The shadow incremental-update architecture now has independently validated concern slices for:

* messages
* handles
* chats

Each currently follows the same architecture grammar:

facts
→ delta
→ semantic state
→ policy decision

Messages already have a validated importer execution path.

Handles and chats currently remain mutation-free observation/reconciliation slices.

The architecture now clearly exposes the future dependency topology:

handles
→ messages
/
chats

The next goal is NOT:

* importer graph execution
* topological sorting
* runtime orchestration planning
* automatic dependency scheduling

The next goal IS:
prove that prerequisite-bearing policy meaning composes cleanly before execution complexity is introduced.

Goal

Introduce explicit prerequisite semantics as pure semantic/policy meaning.

This slice should remain mutation-free and orchestration-light.

We want to answer:

How should import policy meaning express:
“I cannot safely import this concern yet because prerequisite concerns are not ready?”

without introducing execution graph machinery yet.

Desired direction

Introduce a lightweight prerequisite semantic layer that can express states like:

messages blocked pending handles
messages blocked pending chats
messages blocked pending multiple prerequisites

IMPORTANT:
This is semantic/policy meaning only.

No orchestration graph yet.
No runtime scheduling yet.
No automatic execution ordering yet.

Suggested approach

Add a lightweight prerequisite evaluation model.

Possible examples:

ImportPrerequisiteStatus:

* satisfied
* unsatisfied
* unknown

or

ImportBlocker:

* handlesNotReady
* chatsNotReady

Keep this intentionally simple and human-readable.

Potential location

domain/models/
or
domain/sealed_unions/

Apply initially ONLY to messages.

Messages are the first concern that conceptually depends on:

* handles
* chats

Possible semantic shape

Examples only — do not overfit mechanically.

MessageImportDecision may eventually express:

* doNothing
* considerIncrementalImport
* blockedPendingPrerequisites
* blockAndReportLedgerAhead

Possible blocker examples:

missingHandles
missingChats
multiplePrerequisitesMissing

or similar.

The important thing is:
explicit causal policy meaning.

How prerequisites should initially work

For now, prerequisite evaluation can remain intentionally conservative/simple.

Examples:

* handles source/ledger match required
* chats source/ledger match required

before messages may be considered “safe to import”

This is intentionally temporary and architecture-proving.

Do NOT attempt:

* perfect dependency scheduling
* dynamic graph evaluation
* orchestration planning
* importer execution ordering
* runtime graph mutation

Architectural constraints

DO NOT:

* add importer graph execution
* add topological sorting
* add runtime scheduling
* add automatic orchestration ordering
* add handle/chat mutation yet
* alter current message importer execution behavior
* alter polling cadence
* alter endurance logging
* alter comparative validation semantics

DO:

* preserve architecture symmetry
* preserve semantic clarity
* preserve causal explainability
* preserve human readability
* keep prerequisite meaning explicit

Tests

Add focused tests for:

* prerequisite satisfied
* prerequisite missing
* multiple prerequisite blockers
* message import decision derivation with blockers
* stable semantic composition behavior

No dev panel changes required yet.
No endurance logging changes required yet.

Architectural intent

This slice exists to validate:

Can prerequisite-bearing policy meaning remain explicit, composable, and understandable BEFORE importer graph execution exists?

We are validating semantic architecture first, not orchestration machinery.

Report back with:

* new prerequisite semantic models introduced
* how blockers are represented
* how message policy meaning changed
* whether runtime behavior changed
* whether orchestration complexity was intentionally deferred
```

---

Added a mutation-free prerequisite semantics layer for message import policy.

New semantic models:

MessageImportBlocker
handlesNotReady
chatsNotReady
MessageImportPrerequisiteAssessment
holds ordered blockers
exposes isSatisfied / isBlocked
PrerequisiteAwareMessageImportDecision
doNothing
considerIncrementalImport
blockedPendingPrerequisites
blockAndReportLedgerAhead
New integrators/providers:

MessageImportPrerequisiteAssessmentIntegrator
evaluates handle/chat sync states
requires both handles and chats to have source/ledger cursors matched
messageImportPrerequisiteAssessmentProvider
PrerequisiteAwareMessageImportDecisionIntegrator
composes existing ImportDecision with prerequisite assessment
prerequisiteAwareMessageImportDecisionProvider
Important runtime boundary: existing importDecisionProvider and ShadowImportExecutionOrchestrator are unchanged. Shadow message execution still uses the old validated decision path, so runtime behavior did not change.

Tests added:

prerequisites satisfied
handles missing
chats missing
multiple blockers
message decision derivation with blockers
ledger-ahead safety still wins
provider-chain semantic composition
Verification passed:

dart analyze on the prerequisite slice
focused flutter test for the new prerequisite tests
No importer graph execution, topological sorting, scheduling, or handle/chat mutation was added.
