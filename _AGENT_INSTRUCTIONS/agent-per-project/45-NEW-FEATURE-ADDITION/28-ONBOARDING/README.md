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

## Current Status

**PRODUCTION-SHAPED ANOMALY VALIDATION COMPLETE.** A fresh corrected
137,373-message first import reconciled exactly with the Conversation Graph
and Feature 27 coverage: 116,633 conversation-linked, 20,740 recovered, and
zero unaccounted. The completed durable snapshot records exactly 7 unresolved
reaction targets after shared Apple `p:`/`bp:` reference interpretation, down
from the false pre-correction count of 6,032 without changing preserved
evidence. Exact typed totals remain PII-free and bounded. Watchdog, Start
Fresh, and user-facing anomaly presentation remain deferred.
