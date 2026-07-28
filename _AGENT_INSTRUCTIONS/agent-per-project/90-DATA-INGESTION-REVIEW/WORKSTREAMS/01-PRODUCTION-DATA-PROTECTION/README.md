---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: index
status: production-adopted-with-bounded-attachment-follow-up
links:
  - ../../00-PRODUCTION-READINESS-MASTER-PLAN.md
  - ../00-WORKSTREAMS-ORGANIZATION.md
  - ./00-task.md
  - ./CURRENT-STATE-AUDIT.md
  - ./PROPOSAL.md
  - ./QUESTIONS.md
  - ./IMPLEMENTATION-PLAN.md
  - ./VALIDATION.md
  - ./COMPLETION-REPORT.md
  - ./DELAYED-ATTACHMENT-RETRY.md
  - ./PRODUCTION-ADOPTION-RUNBOOK.md
  - ./PRODUCTION-PRESERVATION-AUTHORITY.md
  - ./PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md
  - ./PRODUCTION-PRESERVATION-HANDOFF-PLAN.md
  - ./03-REDIRECTION_RE_PRODUCTION_DB.md
  - ./04-REVISED-OPERATIONAL-STATE.md
  - ./VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md
  - ./VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md
  - ./VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md
  - ./VALIDATION-RESULTS/production-cutover-2026-07-28.md
  - ../../../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../../../10-DATABASES/00-all-databases-accessed.md
  - ../../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# Workstream 1 — Production Data Protection

## Purpose

Establish whether any development or test path can reach the production
MessageLens archive and identify where production safety is mechanically
enforced versus dependent on developer discipline.

This is the keystone Production Readiness workstream. It establishes the
environment and mutation boundary required by onboarding, historical import,
attachment reconciliation, validation, and production health.

## Current Status

**Phase:** Slices 0-10 implemented; production adoption executed  
**Mode:** Current signed production application operating against the adopted
production archive  
**Production adoption:** Completed 2026-07-28  
**Residual:** Three conventional QuickTime attachments await recovery by a
production build containing generalized delayed retry; nine opaque NULL-MIME
plugin payloads await an explicit preservation policy

## Reading Order

1. [`../../00-PRODUCTION-READINESS-MASTER-PLAN.md`](../../00-PRODUCTION-READINESS-MASTER-PLAN.md)
2. [`../00-WORKSTREAMS-ORGANIZATION.md`](../00-WORKSTREAMS-ORGANIZATION.md)
3. [`00-task.md`](00-task.md)
4. [`CURRENT-STATE-AUDIT.md`](CURRENT-STATE-AUDIT.md)
5. [`PROPOSAL.md`](PROPOSAL.md)
6. [`QUESTIONS.md`](QUESTIONS.md)
7. [`IMPLEMENTATION-PLAN.md`](IMPLEMENTATION-PLAN.md)
8. [`VALIDATION.md`](VALIDATION.md)
9. [`COMPLETION-REPORT.md`](COMPLETION-REPORT.md)
10. [`DELAYED-ATTACHMENT-RETRY.md`](DELAYED-ATTACHMENT-RETRY.md)
11. [`PRODUCTION-ADOPTION-RUNBOOK.md`](PRODUCTION-ADOPTION-RUNBOOK.md)
12. [`PRODUCTION-PRESERVATION-AUTHORITY.md`](PRODUCTION-PRESERVATION-AUTHORITY.md)
13. [`PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md`](PRESERVATION-AUTHORITY-IMPLEMENTATION-PLAN.md)
14. [`03-REDIRECTION_RE_PRODUCTION_DB.md`](03-REDIRECTION_RE_PRODUCTION_DB.md)
15. [`04-REVISED-OPERATIONAL-STATE.md`](04-REVISED-OPERATIONAL-STATE.md)
16. [`PRODUCTION-PRESERVATION-HANDOFF-PLAN.md`](PRODUCTION-PRESERVATION-HANDOFF-PLAN.md)
17. [`VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md`](VALIDATION-RESULTS/production-candidate-and-adoption-rehearsal-2026-07-27.md)
18. [`VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md`](VALIDATION-RESULTS/preservation-continuity-admission-2026-07-27.md)
19. [`VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md`](VALIDATION-RESULTS/final-cutover-preparation-2026-07-28.md)
20. [`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md)

## Current Finding

The original audit found that a normal macOS debug launch could resolve and
mutate the production archive. That escape path has been removed:

- Debug and Profile artifacts use `MessageLens Development` and the
  development bundle identifier;
- Dart persistent providers require an admitted `ArchiveAccessAuthority`;
- development, production, and test roots fail closed on identity mismatch;
- protected mutations enter one archive-scoped operation coordinator;
- high-risk production operations require verified checkpoint evidence.

The existing production archive was adopted in place on 2026-07-28. The
installed signed and notarized `MessageLens.app` now uses archive identity
`b81abc1e-e5ea-4d5a-bea7-1d4126e0c01a`, retains Full Disk Access, completed
startup catch-up, and has demonstrated one-for-one preservation of later live
message attachments.

The first post-adoption launch exposed an overlay migration defect after
catch-up writes began. Marker rollback was therefore correctly refused. The
database remained healthy, the migration was fixed and tested, and
`0.2.17+35` completed the migration without loss of overlay state.

The maintenance sweep recovered all 12 image attachments from that interrupted
catch-up. Source code now generalizes delayed retry to conventional attachments
with declared MIME types, including the three residual QuickTime videos. That
recovery remains pending until a production build containing the correction is
installed and its sweep is verified. The remaining nine NULL-MIME plugin
payloads are deliberately excluded pending an explicit preservation policy.
The complete original operation and evidence are recorded in
[`VALIDATION-RESULTS/production-cutover-2026-07-28.md`](VALIDATION-RESULTS/production-cutover-2026-07-28.md).

The primary development machine now supplies a machine-local, development-only
root override for the complete development archive:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/
```

Native and Dart admission agree on that canonical root before startup. A
missing external volume or root fails closed. The previous internal development
archive remains preserved unchanged; production and test root policy are
unaffected.

## Proposed Boundary

The proposal establishes:

- stable existing production identity and archive location;
- a separate development app identity and writable root;
- explicit temporary/in-memory test archives;
- fail-closed archive identity validation before persistent providers;
- archive-scoped native process admission;
- complete operation-specific mutation authority;
- verified recovery evidence for high-risk production maintenance.

The boundary is active for production, development, and tests. Adoption was a
separately authorized one-time transition and is now complete.

## Next Gate

Keep the current production application running as the admitted preservation
process, retain the verified recovery backup and cutover inventory, install a
production build containing generalized delayed retry through the normal
release process, and verify recovery of the three QuickTime rows. Keep the nine
opaque plugin payloads bounded and inventoried until their preservation policy
is decided.

All later Production Readiness slices must demonstrate fresh production
preservation evidence before beginning. Debug/Profile remains confined to the
development identity and external development archive.

## Expected Evolution

```text
00-task.md
  -> CURRENT-STATE-AUDIT.md
  -> PROPOSAL.md
  -> QUESTIONS.md
  -> IMPLEMENTATION-PLAN.md
  -> VALIDATION.md
  -> COMPLETION-REPORT.md
```

Only documents required by the investigation should be created. Completed
decisions must be promoted to the canonical database, environment-safety,
build, onboarding, or operational documentation that owns the resulting
behavior.
