---
tier: project
scope: onboarding
owner: essentials-onboarding
last_reviewed: 2026-08-26
source_of_truth: feature-implementation-record
---

# Start Fresh Startup Admission Correction

## Observed Failure

After a completed installation authorized Start Fresh, the reset successfully
deleted only the enumerated rebuildable stores and verified a virgin state.
Onboarding then recreated valid empty import and graph stores. A concurrent
installation inspection encountered transient SQLite contention and classified
the evidence as remediation-required. The still-mounted startup gate reclaimed
the entire window and presented **This MessageLens setup needs attention**.

The screenshot therefore did not represent a failed reset or damaged archive.
It represented a stale startup authority acting after application admission.

## Root Cause

Two independent mistakes combined:

1. `StartupApp` displayed the admitted application for a healthy initial
   classification but did not latch that admission. It continued observing
   later installation-state invalidations for the process lifetime.
2. The installation classifier treated the mere existence of derived database
   files as consequential installation evidence. Valid, current-schema, empty
   stores recreated for Onboarding were therefore classified as abandoned on a
   later clean inspection.

## Correction

Startup admission is now one-shot for a process:

- the initial classification may still fail closed;
- an initial abandoned or remediation-required state still owns startup;
- once a healthy state admits the application, `StartupApp` latches that
  decision after the admitted presentation's first frame;
- later provider invalidations cannot make the startup gate reclaim an active
  application.

Virgin classification now follows consequential durable evidence rather than
file existence. An idle operation with no historical sources or retired
artifacts is virgin when each present derived store is usable and contains zero
messages and zero graph topology. Absent stores, one valid empty store, or both
valid empty stores are all truthful pre-import states. Non-empty, unreadable,
unsupported, historical, or contradictory evidence retains its previous
fail-closed classification.

Installation-state diagnostics now record the resolved state kind and reason
alongside inspection duration.

The verified Start Fresh operation surface also remains visible for the single
ownership-reconciliation frame in which Onboarding closes the previously open
normal sidebar. Onboarding is revealed only after that post-frame sidebar
transition, preventing the old Settings sidebar from flashing open and then
closing as the ready-to-import Episode appears.

## Invariants

- Startup classification decides whether this process may enter the
  application; it is not an ongoing in-app navigation authority.
- A new process always performs a fresh initial classification.
- File existence alone is not proof that consequential installation work has
  begun.
- Valid empty derived stores do not make a preservation-safe reset inconsistent.
- Preserved stores, attachment payloads, archive identity, and reset allow-list
  behavior are unchanged.
- No database schema, source data, or persistent state was modified by this
  correction.
- Presentation handoff hides native sidebar reconciliation; it does not change
  sidebar ownership or persist a visibility preference.

## Coverage

Focused tests prove:

- healthy startup admission survives a later remediation classification;
- remediation present at initial startup still blocks admission;
- absent, partially created, and fully created valid empty derived stores are
  virgin;
- the exact post-reset shape with preserved stores remains virgin;
- consequential rows and retired artifacts remain non-virgin.
- the verified operation surface covers the sidebar-reconciliation frame and
  then yields normally to Onboarding.
