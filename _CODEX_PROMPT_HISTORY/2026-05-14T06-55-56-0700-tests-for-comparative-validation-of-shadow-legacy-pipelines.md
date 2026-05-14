---
created_at: 2026-05-14T06:55:56-07:00
title: "Tests for comparative validation of shadow/legacy pipelines"
tags: []
source: codex_prompt_history.html
---

# Tests for comparative validation of shadow/legacy pipelines

## Prompt

```text
Task: Add focused comparative-validation tests, especially PHASE SKEW classification

Context

The comparative validation layer is now functioning and producing:

- MATCH
- PHASE SKEW
- MISMATCH
- NOT COMPARABLE

Runtime validation confirmed an important architectural distinction:

temporary asynchronous execution timing
≠
durable semantic disagreement

The comparison layer now correctly distinguishes transient pipeline skew from true mismatch.

Before expanding further, we need focused tests locking down this behavior.

Goal

Add narrow, deterministic tests for comparative validation semantics.

Focus especially on:
- phase-skew detection
- durable mismatch detection
- causal comparison meaning

IMPORTANT

Do not add broad integration tests.
Do not involve production DBs.
Do not involve UI.
Do not involve polling timers.

Prefer:
- pure semantic derivation tests
- deterministic comparison classification tests
- explicit comparison-state coverage

Suggested test files

Likely locations:

test/essentials/incremental_update/application/comparison/integrators/
  incremental_update_comparison_integrator_test.dart

or similar based on current structure.

Required test coverage

1. MATCH classification

Validate:

legacy:
  incremental import not required

shadow:
  incremental import not required

→ ComparisonOutcome.match

Also validate:
- projection current vs projection current
- import required vs import required

2. PHASE SKEW classification

Validate transient asynchronous skew scenarios.

Examples:

Scenario A:

production:
  projection current

shadow:
  migration required

with:
  shadow projection lagging by 1 message

→ ComparisonOutcome.phaseSkew

Scenario B:

production:
  migration required

shadow:
  projection current

with:
  production projection lagging by 1 message

→ ComparisonOutcome.phaseSkew

Scenario C:

production import ahead of production projection
while shadow already caught up

→ phaseSkew

The goal is to prove:
“temporally offset but causally explainable”
is not treated as durable disagreement.

3. Durable MISMATCH classification

Validate true disagreement scenarios.

Example:

production:
  incremental import not required

shadow:
  incremental import required

with:
  no valid transitional explanation

→ ComparisonOutcome.mismatch

Also validate:
- production projection current
- shadow migration required
- but without explainable lag/skew conditions

4. NOT COMPARABLE classification

Validate:
- missing production facts
- incomplete shadow facts
- invalid/unknown comparison state

→ ComparisonOutcome.notComparable

5. Reason text validation

Ensure:
- phase-skew reasons are explanatory and causal
- mismatch reasons clearly describe disagreement
- logs remain human-readable

Architectural intent

These tests protect the distinction between:

temporary asynchronous execution phase
vs
durable architectural disagreement

This is epistemic safety, not just runtime correctness.

Guardrails

Do not:
- add UI
- add timers
- add polling
- touch production behavior
- add attachment comparison
- invoke legacy execution
- add database-heavy integration tests

Strong simplification preference

Prefer:
- explicit comparison meaning
- deterministic semantic inputs
- readable causal outputs

over:
- realistic timing simulation
- orchestration complexity

Verification

Run:
- dart analyze on changed files
- focused flutter test targets

Report:
- added test files
- tested comparison scenarios
- phase-skew heuristics covered
- mismatch scenarios covered
- example reason-text assertions
```

Added focused comparative-validation tests in incremental_update_comparison_integrator_test.dart.

Covered scenarios:

MATCH

legacy import not required + shadow import not required

legacy import required + shadow import required

production projection current + shadow projection current

PHASE SKEW

production projection current while shadow migration is required because shadow projection lags by 1

production migration required because production projection lags by 1 while shadow projection is current

MISMATCH

production says import not required while shadow says import required, with no phase explanation

production projection current while shadow says migration required, with no explainable lag

NOT COMPARABLE

missing production imported cursor

Reason-text assertions include checks like:

shadow projection lagging import by 1

production projection lagging import by 1

legacyReason=

production import/working max ids in mismatch reasons

The test is pure semantic classification: no DBs, providers, timers, polling, UI, or legacy execution paths.

Verification:

dart analyze on the new test passed.

Focused flutter test for the new comparison test passed.
