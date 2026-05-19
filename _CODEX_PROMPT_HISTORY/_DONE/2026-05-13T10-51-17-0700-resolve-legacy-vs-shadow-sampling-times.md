---
created_at: 2026-05-13T10:51:17-07:00
title: "resolve legacy vs shadow sampling times"
tags: []
source: codex_prompt_history.html
---

# resolve legacy vs shadow sampling times

## Prompt

```text
Task: Refine comparative validation semantics to distinguish durable mismatches from transient phase skew

Context

The comparative validation layer is now working and comparing:

legacy production incremental-update behavior
vs
shadow incremental-update behavior

Current comparison outcomes:
- match
- mismatch
- notComparable

Runtime logs show an important nuance:

Example:

[comparison][migration projection]
MISMATCH:
  legacy=projection current
  shadow=migration required

followed shortly later by:

[comparison][migration projection]
MISMATCH:
  legacy=migration required
  shadow=projection current

The underlying facts show:

productionImportMaxMessageId=135922
productionWorkingMaxMessageId=135921

This strongly suggests:
- the systems are being sampled at different moments in their valid execution pipeline
- not a true semantic disagreement

This is an expected asynchronous timing phenomenon, not necessarily an architectural mismatch.

Goal

Refine comparison semantics to distinguish:

durable semantic disagreement
vs
temporary pipeline phase skew

New comparison outcome

Add:

ComparisonOutcome.phaseSkew

Meaning:

The compared systems appear to be in valid but temporally offset pipeline phases.

Examples:
- production import advanced before production projection
- shadow projection caught up before production projection
- production projection caught up before shadow projection

Architectural intent

The comparison layer should help answer:

Do these systems fundamentally disagree?
or
Are they simply being observed at different moments in asynchronous execution?

We want:
- causal traceability
- epistemic clarity
- lower false-positive mismatch noise

Requirements

1. Extend comparison semantics

Update comparison outcome modeling to include:

- match
- mismatch
- phaseSkew
- notComparable

Prefer sealed-union semantics if already used elsewhere.

2. Add explicit phase-skew detection logic

Detect likely transient asynchronous skew conditions.

Examples may include:
- production import ahead of production working projection by small delta
- shadow import ahead of shadow projection by small delta
- one system caught up while the other is still in-flight

The goal is not perfect temporal modeling.
The goal is to avoid labeling obvious transient execution windows as durable architectural disagreement.

3. Logging refinement

Preferred logging style:

[comparison][migration projection]
PHASE SKEW:
  legacy=projection current
  shadow=migration required
  reason=production projection lagging import by 1 message

or:

[comparison][migration projection]
PHASE SKEW:
  legacy=migration required
  shadow=projection current
  reason=production projection catching up asynchronously

Durable semantic disagreement should still log as:

MISMATCH

4. Preserve current architecture

Prefer:
Readers
→ comparison integrators
→ comparison semantic meaning
→ comparison orchestrator/logging

Do not collapse logic into one large orchestrator.

5. Keep implementation narrow

Do not:
- synchronize production/shadow timing
- change production behavior
- change polling cadence
- add retries/debounce
- add UI yet
- add attachment comparison yet

This is only semantic classification refinement.

Strong simplification preference

Prefer:
- explicit comparison meaning
- understandable heuristics
- readable logs

over:
- perfect temporal modeling
- heavy orchestration

Verification

Run:
- dart analyze on changed files

Then run the app and demonstrate:
- MATCH logs
- PHASE SKEW logs during transient import/projection transitions
- MISMATCH logs only for durable disagreement

Report:
- updated comparison semantics
- phase-skew detection heuristics
- example runtime logs
- confirmation that production behavior remains unchanged
```
