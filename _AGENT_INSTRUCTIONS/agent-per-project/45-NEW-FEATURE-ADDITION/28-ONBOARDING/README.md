---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-23
source_of_truth: feature-work-package-index
---

# Feature 28: Onboarding

This work package reconstructs the complete first-launch-to-usable-application
Journey before further Onboarding implementation begins.

## Start

- [Opening seed](seed.md)

## Responses

1. [Journey, failure, recovery, and Start Fresh audit](responses/01-ONBOARDING-JOURNEY-FAILURE-RECOVERY-AND-FRESH-START-AUDIT.md)
2. [Durable typed operation snapshot and liveness foundation](responses/02-DURABLE-TYPED-ONBOARDING-OPERATION-SNAPSHOT-AND-LIVENESS-FOUNDATION-IMPLEMENTATION.md)
3. [Stall-detection liveness inventory and implementation blocker](responses/03-ONBOARDING-STALL-DETECTION-AND-STAGE-SPECIFIC-LIVENESS-CONTRACTS-BLOCKER.md)

## Current Status

**BLOCKED ON TRUTHFUL LIVENESS EVIDENCE.** The typed durable operation snapshot
and restart reconciliation are implemented. Stall/watchdog classification did
not proceed because current macOS lifecycle signals do not identify sleep or
process suspension and current Onboarding stages lack measured, defensible
no-progress bounds. The next prerequisite is execution-opportunity and real
progress instrumentation; Start Fresh and record quarantine remain explicitly
deferred.
