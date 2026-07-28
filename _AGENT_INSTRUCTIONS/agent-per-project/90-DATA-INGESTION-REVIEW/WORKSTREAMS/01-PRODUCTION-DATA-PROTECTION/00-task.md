---
workstream: "01"
title: Production Data Protection
phase: Current-State Audit
status: active
owner: Codex
mode: read-only investigation
last_updated: 2026-07-27
---

# Workstream 1 — Production Data Protection

## Phase 1: Current-State Audit (Read-Only)

You are beginning Workstream 1 of the MessageLens Production Readiness project.

Before proposing architectural changes, you must establish an accurate understanding of the current implementation.

This is a **read-only investigation**.

Do **not** modify production code.

Do **not** implement fixes.

Do **not** refactor.

Your responsibility is to discover, verify and document the current behaviour of the system.

---

# Background

The Production Readiness project has established that the user's active MessageLens data folder is now considered the permanent production archive.

It is no longer acceptable to use that archive for experimentation.

Before any onboarding, archival import or reconciliation work proceeds, we must understand exactly how MessageLens currently determines:

- which environment it is running in;
- which archive it may modify;
- who has authority to mutate that archive;
- what protections currently exist;
- where the system still depends upon developer discipline rather than structural guarantees.

This audit forms the foundation for every remaining Production Readiness workstream.

---

# Primary Question

Answer one question:

> **Can any current development or test path reach the production archive, directly or indirectly?**

The answer must be based upon verified code and runtime behaviour, not assumptions.

---

# Investigation Scope

Trace the complete path by which MessageLens determines:

1. Which build and runtime configuration it is using.

2. Which archive environment it is running in.

3. Which data folder becomes the active MessageLens archive.

4. Which databases may be opened.

5. Which attachment and operational-evidence directories may be accessed.

6. Which resources are opened read-only.

7. Which resources are opened writable.

8. Which providers or services own mutation authority.

9. Which mechanisms admit one application process.

10. Which mechanisms serialize individual mutation operations.

11. Which snapshot or recovery mechanisms currently exist.

12. Which debug, onboarding, migration, reset, simulation, testing, build or
    maintenance paths alter any of the above.

13. Where developer judgement currently substitutes for structural enforcement.

Do not treat these concepts as interchangeable:

- Flutter debug/profile/release build mode;
- bundle identifier and signing identity;
- archive-environment identity;
- selected data root;
- application-process admission;
- operation-specific mutation authority.

A debug build may read a live Apple source while remaining isolated from every
production app-owned write target. Conversely, a release build is not safe
merely because it is a release build.

The audit includes non-Dart entry points that can affect environment or archive
selection, including:

- Xcode build configurations, entitlements, bundle identifiers and signing;
- launch and debug configurations;
- build, packaging, notarization and maintenance scripts;
- test fixtures and temporary-root selection;
- database migration and reset tooling;
- spawned processes or command-line helpers.

---

# Deliverable

Create:

```
WORKSTREAMS/
    01-PRODUCTION-DATA-PROTECTION/
        CURRENT-STATE-AUDIT.md
```

The document should contain the following sections.

---

# Executive Summary

Summarize:

- current safety posture;
- principal risks;
- strongest existing protections;
- highest-priority unknowns.

---

# Environment Resolution

Describe exactly how MessageLens determines:

- build mode;
- bundle and signing identity;
- archive environment;
- runtime configuration and overrides;
- data root;
- archive identity.

Include source code references.

Do not infer archive identity solely from build mode or bundle identity. Trace
the actual path that selects writable locations.

---

# Mutation Authority

Document:

- every writable database;
- writable filesystem locations;
- services responsible for writes;
- ownership boundaries;
- application-instance admission;
- operation-specific locking behaviour;
- concurrency assumptions.

Distinguish source access from archive mutation. Record whether a development
process can read live Apple sources separately from whether it can resolve or
write the production MessageLens archive.

---

# Production Safety

Document every existing safeguard including:

- snapshots;
- recovery;
- migration protections;
- execution locks;
- provider boundaries;
- startup checks.

---

# Escape Paths

Identify every known path by which development or experimental code could currently affect the production archive.

These are observations, not criticisms.

---

# Required Runtime Verification

List any behaviour that cannot be confirmed by static inspection alone.

Describe the runtime experiment required to verify it.

Do not perform those experiments.

---

# Audit Matrix

Provide a table similar to:

| Concern | Current mechanism | Code authority | Mechanically enforced? | Production risk | Evidence |
| ------- | ----------------- | -------------- | ---------------------- | --------------- | -------- |

Include at minimum:

- Environment identity
- Build, bundle and signing identity
- Data-root selection
- Archive identity
- Database providers
- Attachment archive
- Operational-evidence storage
- Write authority
- Application-instance admission
- Operation-specific execution authority
- Snapshot requirements
- Recovery mechanisms
- Test isolation
- Onboarding reset paths
- Build and maintenance tooling

---

# Conclusions

Finish with five sections:

- Verified protections
- Unverified assumptions
- Known escape paths
- Questions requiring runtime testing
- Minimum conditions required before Workstream 2 (Onboarding Review) begins

---

# Constraints

This audit is descriptive.

It is not a design proposal.

It is not an implementation plan.

It is not a refactoring exercise.

If the code and the documentation disagree, treat the code as the current implementation and document the discrepancy.

Where documentation makes a claim, verify it rather than assuming it is correct.

Classify evidence explicitly:

- verified by static code or configuration inspection;
- documented intention not yet verified;
- requires runtime verification;
- unresolved.

This phase may specify read-only or disposable-environment runtime experiments,
but it must not run them. A safeguard requiring runtime evidence remains
unverified until that later evidence exists.

---

# Success Criteria

The audit is complete when another developer can answer, solely by reading `CURRENT-STATE-AUDIT.md`:

- Which environment am I running?
- Which archive can this process modify?
- Who currently holds mutation authority?
- What recovery evidence exists?
- Can this operation safely proceed?

Only after those questions can be answered from verified evidence, or their
remaining runtime verification is explicitly bounded, should Workstream 1 move
on to architectural proposals.
