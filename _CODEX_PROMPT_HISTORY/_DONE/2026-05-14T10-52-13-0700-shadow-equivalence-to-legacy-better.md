---
created_at: 2026-05-14T10:52:13-07:00
title: "shadow equivalence to legacy: better?"
tags: []
source: codex_prompt_history.html
---

# shadow equivalence to legacy: better?

## Prompt

```text
Task: Begin shadow behavioral-equivalence assessment against production incremental-update behavior

Context

The shadow incremental-update architecture is now:

- functionally operational
- endurance-tested
- observable
- test-covered
- comparatively validated
- semantically classified with:
  - MATCH
  - PHASE SKEW
  - MISMATCH
  - NOT COMPARABLE

Recent endurance logs show an important emerging pattern:

The shadow pipeline often reaches:
- projectionCaughtUp
- MATCH

before the production migration pipeline catches up.

Example recurring runtime pattern:

legacy=migration required
shadow=projection current

classified as:
PHASE SKEW

This suggests the comparison layer is now exposing real operational behavior differences between:
- the legacy production architecture
- the shadow architecture

We are now transitioning from:

“Does the shadow architecture work?”

to:

“How does shadow behavior differ from production behavior under real runtime conditions?”

Goal

Begin a behavioral-equivalence assessment layer.

This phase is observational and analytical only.

Do not promote shadow into production ownership.

Do not replace legacy behavior.

Primary objectives

Identify:
- intentional behavioral differences
- accidental behavioral differences
- latency/cadence differences
- architectural consequences of those differences

We want to understand:

- Is the shadow architecture behaviorally equivalent?
- If not, why?
- Which behavior is preferable?
- Are differences due to:
  - polling cadence
  - orchestration structure
  - invalidation boundaries
  - batching behavior
  - execution timing
  - legacy architectural constraints
  - or semantic bugs?

Scope

Documentation + observability enhancement only.

Do not modify production execution behavior.

Suggested implementation

1. Introduce behavioral assessment terminology

Define/document concepts such as:

- behavioral equivalence
- acceptable transient skew
- operational divergence
- cadence divergence
- scheduling divergence
- convergence latency
- steady-state equivalence

2. Add lightweight latency/convergence instrumentation

Capture timing metrics such as:
- time from source change → shadow import caught up
- time from shadow import → shadow projection caught up
- total shadow convergence duration
- comparable production convergence duration if observable

Prefer:
- timestamps
- durations
- observational metrics

Do not:
- add performance optimization yet
- synchronize pipelines
- alter polling cadence

3. Extend endurance logging

Add optional observational fields such as:
- convergence duration
- ticks-to-convergence
- production convergence still pending?
- shadow convergence completed?

Do not overbuild analytics infrastructure.

4. Add a behavioral assessment section to docs

Document:
- observed runtime differences
- recurring PHASE SKEW patterns
- possible architectural causes
- questions still unresolved
- criteria for future promotion decisions

5. Preserve architecture boundaries

Do not:
- change production import/migration scheduling
- change polling cadence
- optimize shadow execution yet
- add retries/debounce
- add attachment processing
- add production mutation paths
- replace legacy orchestration

Architectural intent

The comparison system is now mature enough to study:
- operational characteristics
- causal timing behavior
- convergence properties

not just correctness.

This is an architectural observability phase.

Verification

Run:
- dart analyze on changed files

Then rerun endurance scenarios:
- isolated messages
- overlapping bursts
- staggered bursts across ticks

Observe and report:
- shadow convergence duration
- production convergence duration if inferable
- recurring divergence patterns
- whether shadow consistently converges earlier/later than production

Report:
- files changed
- instrumentation added
- terminology introduced
- example behavioral assessment observations
- documentation updates
- confirmation that production behavior remains unchanged
```

Implemented the first behavioral-equivalence assessment layer as observability only.

Changed files:

shadow_polling_endurance_log_writer.dart

00-TERMINOLOGY.md

30-INVARIANTS.md

50-INCREMENTAL-UPDATE-PILOT.md

Instrumentation added to the endurance log:

shadow_convergence_completed

shadow_import_convergence_duration

shadow_import_ticks_to_convergence

shadow_migration_convergence_duration

shadow_migration_ticks_to_convergence

shadow_total_convergence_duration

shadow_total_ticks_to_convergence

production_convergence_pending

production_pending_duration

last_production_convergence_duration

Terminology introduced:

behavioral equivalence

operational divergence

convergence latency

acceptable transient skew

cadence divergence

scheduling divergence

steady-state equivalence

The tracker treats “first observed non-steady shadow state” as the observable start of a convergence episode. It does not infer the real Messages.app send time. Production pending duration is inferred only from comparison outcomes where production appears to still require work while shadow is already current.

Example expected log shape:

text

### Behavioral assessment

- shadow_convergence_completed: true
- shadow_import_convergence_duration: 15012ms
- shadow_import_ticks_to_convergence: 1
- shadow_migration_convergence_duration: 15018ms
- shadow_migration_ticks_to_convergence: 1
- shadow_total_convergence_duration: 30041ms
- shadow_total_ticks_to_convergence: 2
- production_convergence_pending: true
- production_pending_duration: 15005ms

Production behavior remains unchanged. This does not alter polling cadence, retries, scheduling, import/migration execution, or ownership. It only records observational metrics in the shadow endurance log.

Verification:

dart analyze lib/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer.dart

Result: no issues found.

I did not rerun the live endurance scenarios from here, so isolated/overlapping/staggered burst observations still
