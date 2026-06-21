# Enhanced Onboarding Flow Proposal

## Current Conformance Note (2026-06-06)

This proposal remains conceptually relevant for environment readiness: setup
must distinguish permissions, source availability, AddressBook readiness,
local-history sparsity, and app-owned data health. The pipeline authority has
changed since this was written.

Current onboarding/reimport success is based on source-scoped import and
conversation graph build/readiness. Retained `db_importers` / `db_migrate`
`macos_import.db` -> `working.db` flows are retired historical references and
cleanup/diagnostic storage, not the ordinary production setup path.

## Problem

The current onboarding gate answers only two questions:

- can the app read `~/Library/Messages/chat.db`?
- do the app-owned databases appear to exist?

That is not enough to support real users on heterogeneous Macs.

Current failure modes that are not distinguished clearly:

- Full Disk Access is missing
- Messages database exists but local history is sparse or absent
- This Mac is not meaningfully participating in Messages sync
- AddressBook access or path resolution is unavailable
- source-scoped import succeeded partially but graph projection failed
- app-owned databases exist but are stale, empty, or inconsistent
- startup blockers are caused by pipeline errors rather than permissions

The result is a bootstrap experience that can strand the user behind a blank or
ambiguous state, and a support experience that relies too much on guesswork.

## Goal

Create an enhanced onboarding/bootstrap flow that evaluates the local macOS
environment as thoroughly as practical and presents:

- the current readiness state
- concrete blockers
- actionable user advice
- explicit uncertainty when a condition can only be inferred

This flow should help the user get MessageLens into a usable state without
requiring developer intervention for ordinary setup failures.

## Non-Goals

- replacing the source-scoped import or graph-build systems
- silently modifying macOS privacy settings
- guaranteeing authoritative knowledge of Apple's iCloud sync state
- building a long wizard with many user-driven steps
- introducing feature-local navigation outside the existing ViewSpec system

## Product Framing

This is a bootstrap readiness gate, not a traditional onboarding wizard.

The flow should answer:

- can MessageLens access the required source data?
- does this Mac appear to have useful Messages data locally?
- can the app source-scope and project that data into the conversation graph?
- if not, what should the user do next?

## Existing Architecture Summary

The app already has an essentials-owned onboarding gate and overlay:

- `OnboardingGate` classifies the startup state
- `OnboardingOverlay` blocks the app and renders the current phase
- source-scoped import and graph build remain owned by their existing systems
- panel routing is ViewSpec-based and feature-dispatched

This proposal keeps that architecture intact:

- onboarding coordinates
- source-scoped import imports
- graph build/projection projects
- onboarding presents a user-safe projection of environment and pipeline state

## Proposed Outcome

Introduce an environment evaluation layer that produces a structured onboarding
readiness report before and during bootstrap.

That report should evaluate, at minimum:

- Messages database readability
- AddressBook readability or path-resolution readiness
- presence of local Messages history
- rough health of source row counts
- existence and health of source-scoped import and conversation graph databases
- source-scoped import failure state
- graph build/projection failure state
- retained compatibility database diagnostics when explicitly labeled
- likely sync/data-availability state for this Mac

The onboarding UI then renders a diagnosis-oriented experience instead of a
binary permission/import gate.

## User-Facing State Categories

The enhanced flow should classify startup into stable, user-facing buckets:

1. Permission blocked
2. Source data unavailable
3. Source data accessible but sparse or likely unsynced
4. Ready to import
5. Import in progress
6. Import blocked or failed
7. Graph build in progress
8. Graph build blocked or failed
9. Ready / healthy

These are user-facing categories, not a mirror of every internal pipeline step.

## Key Principles

### 1. Conservative diagnosis

If a condition cannot be known directly, the system must say that it is likely
or inferred.

### 2. Evidence-backed advice

Every recommendation should be tied to a concrete signal, such as:

- file unreadable
- file absent
- source row counts near zero
- source-scoped import database empty after import attempt
- conversation graph projection state incomplete

### 3. No architectural leakage

The user should see a clear readiness assessment, not raw internal exceptions
unless a diagnostic details surface explicitly asks for them.

### 4. Preserve ownership boundaries

Onboarding may inspect environment and project pipeline health, but must not
take over source-scoped import or graph-build responsibilities.

## Recommended First Delivery

Phase 1 should focus on environment evaluation and blocker clarity, not a full
UI redesign.

Recommended first slice:

- define the environment report model
- define readiness categories
- add a diagnostics evaluator in onboarding application code
- upgrade the current onboarding surface to render diagnosis and advice

This keeps diffs smaller while solving the main user problem.

## Risks

### iCloud inference risk

The app cannot reliably know Apple's cloud-side state. It can only infer likely
local sync absence from local evidence such as empty or tiny source databases.

### False reassurance risk

If the app collapses several failure modes into a single "ready" state, users
will still encounter confusing blank or sparse experiences.

### Over-coupling risk

If onboarding directly embeds importer/migrator logic rather than projecting it,
the bootstrap flow will become brittle and hard to evolve.

## Success Criteria

This work is successful when the app can clearly tell a user:

- whether permissions are missing
- whether this Mac actually has useful local Messages data
- whether the source databases are reachable
- whether source-scoped import or graph build is the current blocker
- what action the user should take next

## Deliverables

- `DESIGN_NOTES.md` with the proposed evaluator and state model
- `CHECKLIST.md` with implementation phases
- `TESTS.md` with unit and manual verification scenarios
