---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-29
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
12. [Live Onboarding Journey path](responses/13-LIVE-ONBOARDING-JOURNEY-PATH-IMPLEMENTATION.md)
13. [Start Fresh startup-admission correction](responses/14-START-FRESH-STARTUP-ADMISSION-CORRECTION.md)
14. [Journey node semantics and verification gate](responses/14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md)
15. [Final release readiness and conformance](responses/15-FEATURE-28-FINAL-ONBOARDING-RELEASE-READINESS-AND-CONFORMANCE.md)
16. [Complete legacy-tester installation erasure](responses/16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA-IMPLEMENTATION.md)
17. [Complete Erase containment and known-good Onboarding audit](responses/17-COMPLETE-ERASE-CONTAINMENT-AND-KNOWN-GOOD-ONBOARDING-AUDIT.md)
18. [Complete Erase validation responsiveness correction](responses/17-COMPLETE-ERASE-VALIDATION-RESPONSIVENESS-CORRECTION.md)
19. [Last distributed tester-build legacy signature audit](responses/18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md)
20. [Legacy tester inspector and startup classification](responses/19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md)
21. [Legacy tester deletion authorization and Onboarding handoff](responses/21-LEGACY-TESTER-DATA-DELETION-AUTHORIZATION-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md)

## Current Status

**LIVE SINGLE-AUTHORITY JOURNEY IMPLEMENTED.**
`OnboardingJourneyCoordinator` selects the sole active typed Episode from
coherent prerequisite evidence, durable operation truth, and explicit human
intent. A compact six-node human path now projects meaningful prerequisite,
authorization, operation, and terminal Episodes without mirroring the internal
durable-verification gate or inferring progress from widgets and counters.
First-run ownership continues through terminal OK, which removes the path and
releases the normal application sidebar.

The final conformance pass classifies Feature 28 as **ready with deferred
non-blockers**. Start remains mechanically unavailable until the mandatory
internal durable-verification gate succeeds; verification failure remains on
Import and never exposes Start.

The generalized **Erase MessageLens Setup and Start Over** action is no longer
offered in Settings. Its low-level crash-convergent root-replacement machinery
remains internal. The exact pre-source-scoped tester generation is recognized
read-only and receives one dedicated compatibility gate. Only explicit human
authorization can admit deletion of that exact canonical legacy root; success
installs and verifies a virgin identity, then automatically relaunches into the
ordinary six-node Onboarding Journey. Ordinary preservation-safe Start Fresh
remains unchanged.

Startup classification is a one-shot process admission decision. Once the
application has been admitted, later installation-state refreshes cannot
reclaim its presentation. Valid empty derived stores are classified as virgin
from their durable contents rather than treated as consequential merely because
their files exist.
