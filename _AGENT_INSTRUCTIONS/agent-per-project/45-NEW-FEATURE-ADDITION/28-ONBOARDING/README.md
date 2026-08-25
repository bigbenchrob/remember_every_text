---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-25
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
4. [Stage observability and real progress instrumentation](responses/04-ONBOARDING-STAGE-OBSERVABILITY-AND-REAL-PROGRESS-INSTRUMENTATION-IMPLEMENTATION.md)
5. [Production-shaped profiling and liveness evidence](responses/05-PRODUCTION-SHAPED-ONBOARDING-PROFILING-AND-LIVENESS-EVIDENCE.md)
6. [Dependency-aware source anomaly handling: handles](responses/06-DEPENDENCY-AWARE-SOURCE-ANOMALY-HANDLING-STARTING-WITH-HANDLES-IMPLEMENTATION.md)
7. [Dependency-aware anomaly policy for remaining source domains](responses/07-DEPENDENCY-AWARE-ANOMALY-POLICY-FOR-REMAINING-ONBOARDING-DOMAINS-IMPLEMENTATION.md)
8. [Production-shaped anomaly validation](responses/08-PRODUCTION-SHAPED-ONBOARDING-ANOMALY-VALIDATION.md)
9. [Installation state and preservation-safe Start Fresh](responses/09-INSTALLATION-STATE-CLASSIFICATION-AND-PRESERVATION-SAFE-START-FRESH-IMPLEMENTATION.md)

## Current Status

**PRESERVATION-SAFE START FRESH IMPLEMENTED FOR LOCAL VALIDATION.** Startup now
classifies admitted installations as virgin, resumable, completed, abandoned,
or remediation-required from durable evidence. Abandoned installs can reset
only the canonical rebuildable import/graph allow-list under mutation
authority; overlays, Presence history, archive identity, logs, preferences,
and attachment payloads remain preserved. The old option-launch reset no-op is
gone. External tester use remains blocked pending disposable-archive manual
validation.
