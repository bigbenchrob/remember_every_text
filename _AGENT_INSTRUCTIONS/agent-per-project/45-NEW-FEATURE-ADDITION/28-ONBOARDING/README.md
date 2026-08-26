---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-26
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
10. [Environment Readiness guided Episode and application handoff](responses/11-ENVIRONMENT-READINESS-AS-GUIDED-PRESENCE-EPISODE-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md)
11. [Single-authority typed Onboarding Journey Coordinator](responses/12-SINGLE-AUTHORITY-TYPED-ONBOARDING-JOURNEY-COORDINATOR-IMPLEMENTATION.md)

## Current Status

**SINGLE JOURNEY AUTHORITY IMPLEMENTED.** `OnboardingJourneyCoordinator` now
selects the sole active typed Episode from coherent prerequisite evidence,
durable operation truth, and explicit human intent. Environment Readiness and
Presence no longer advance production Onboarding independently. First-run
ownership continues through durable verification and terminal OK, which then
releases the normal application sidebar.
