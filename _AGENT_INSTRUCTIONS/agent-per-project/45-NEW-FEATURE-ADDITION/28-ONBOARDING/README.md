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

## Current Status

**IMPLEMENTATION ACTIVE.** The first release-blocker slice establishes one
typed, durable Onboarding operation snapshot and restart reconciliation without
a schema change. The next bounded concern is stall/watchdog classification;
Start Fresh and record quarantine remain explicitly deferred.
