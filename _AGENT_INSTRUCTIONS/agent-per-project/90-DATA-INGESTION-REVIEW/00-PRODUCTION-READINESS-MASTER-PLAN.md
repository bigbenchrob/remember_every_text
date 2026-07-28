---
tier: project
scope: production-readiness-data-ingestion
owner: agent-per-project
last_reviewed: 2026-07-28
source_of_truth: doc
status: current
links:
  - ./global-project-seed.md
  - ./WORKSTREAMS/README.md
  - ./WORKSTREAMS/00-WORKSTREAMS-ORGANIZATION.md
  - ./WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md
  - ../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../25-ONBOARDING-AND-ARCHIVE/README.md
  - ../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests: []
---

# MessageLens Production Readiness Master Plan

## Purpose

The Production Readiness project prepares MessageLens to become a trustworthy,
long-lived personal archive.

This phase is not primarily about adding major product features. It is about
ensuring that every operation affecting a user's permanent communication
history is predictable, recoverable, observable, and worthy of trust.

MessageLens begins with Apple Messages as its primary source, but its long-term
responsibility is larger: preserve and progressively enrich a person's
conversation history across current devices, historical sources, recovered
archives, attachments, and user-authored meaning.

This folder coordinates that work.

> **The production archive is never a development laboratory.**

Normal production sync and approved ingestion must continue to modify the
archive. "Protected" therefore does not mean frozen. It means that production
state changes only through intentional production workflows with defined
authority, validation, recovery, and evidence. Development experiments,
fixtures, destructive tests, and incomplete migration designs run elsewhere.

## Authority Of This Document

This document is authoritative for:

- the purpose and boundaries of the Production Readiness project;
- the separation of development and production environments;
- the shared safety and evidence requirements for every workstream;
- the project workstreams and their relationships;
- the progression from investigation to production use;
- the project-wide definition of success.

It does not replace the current implementation authorities:

- [`20-DATA-IMPORT-MIGRATION/`](../20-DATA-IMPORT-MIGRATION/) documents the
  current source-scoped import and graph lifecycle;
- [`25-ONBOARDING-AND-ARCHIVE/`](../25-ONBOARDING-AND-ARCHIVE/) documents the
  current onboarding and attachment archive;
- [`10-DATABASES/`](../10-DATABASES/) owns database identity and access rules;
- [`50-ENVIRONMENT-SAFETY/`](../50-ENVIRONMENT-SAFETY/) owns current snapshot,
  recovery, and experimental procedures;
- the Architectural Constitution governs cross-project invariants.

Future workstream documents may propose changes to those systems. Until a
change is implemented, validated, and promoted into canonical documentation,
the current code and current canonical documents remain the authority for
runtime behavior.

## The Archive Is A Logical System

The production archive is not synonymous with one database file. It is the
combined logical record MessageLens is responsible for preserving.

Its parts have different rebuild and preservation properties:

| Category | Examples | Preservation posture |
| --- | --- | --- |
| External source evidence | live or historical `chat.db`, AddressBook data, source attachment folders | Read-only. MessageLens never writes to Apple-owned or user-supplied source material. |
| Durable user and archive state | `user_overlays.db`, archived attachment files, user-confirmed identity and intent | Irreplaceable application state. Preserve across all rebuilds and imports. |
| Imported source facts and provenance | source-scoped import batches, source identity, archive-source inventory | Preserve unless a verified process proves the source remains reproducible and the replacement retains equivalent provenance. Historical sources may no longer be available later. |
| Derived graph state | current conversation graph projection and indexes | Rebuildable from authoritative imported facts, but mutated only by its owning lifecycle. |
| Operational evidence | plans, validation results, counts, warnings, errors, completion reports | Durable audit evidence for significant operations. Do not treat logs as disposable noise when they are the only record of what occurred. |

The project must not apply one simplistic rule such as "all databases are
permanent" or "all projections are disposable" to every category. Each
workstream must identify the authority, rebuildability, retention requirement,
and recovery path of every data class it touches.

## Guiding Principles

### Production Data Is Sacred

The active MessageLens data folder is production state. It is not used for
experimental schema work, destructive testing, speculative reconciliation, or
debugging shortcuts.

The non-production archive boundary now makes ordinary Debug/Profile and test
writes mechanically separate from production. Operational discipline remains
mandatory for production adoption and other deliberately authorized production
work.

### Preservation Over Convenience

MessageLens is fundamentally archival.

When preservation and convenience conflict, preservation wins. New evidence
enriches the archive rather than casually replacing older evidence. Records
are not suppressed merely because they are incomplete, anomalous, duplicated,
or difficult to interpret.

### Structural Safety Over Remembered Cleanup

Apply the
[Mechanical Impossibility Principle](../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md#the-mechanical-impossibility-principle)
where practical.

Prefer an architecture in which:

- a development build cannot accidentally resolve the production write root;
- a read-only source cannot be opened through a write-capable ingestion port;
- an operation cannot commit before its plan and validation exist;
- incompatible source data cannot silently enter a production batch;
- concurrent writers cannot both acquire execution authority.

Operational warnings remain useful, but they are weaker than structural truth.

### Every Operation Should Inspire Confidence

Onboarding, historical import, archive reconciliation, and repair should feel
calm and deliberate. The user should understand:

- what source is being examined;
- what MessageLens intends to change;
- which phase is active;
- whether work may be interrupted safely;
- what completed;
- what did not complete;
- what the user should do next.

The application should communicate: "I've got this."

### Live Production Preservation Is A Blocking Prerequisite

Every implementation slice must preserve uninterrupted responsibility for
newly arriving production data.

Before a slice begins, it must identify the production archive identity holding
preservation authority, provide fresh evidence from the process exercising
that authority, and explain how continuity remains intact throughout the work.
Any required handoff must avoid an interval in which no process owns
preservation. If continuity cannot be demonstrated, the slice is blocked.

This requirement is owned by
[`PRODUCTION-PRESERVATION-AUTHORITY.md`](WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/PRODUCTION-PRESERVATION-AUTHORITY.md).
It is not deferred to Production Health.

### Evidence Is Never Assumed

Every significant ingestion operation produces objective evidence. At minimum,
the evidence must answer:

- which source and source version were examined;
- how many records were scanned;
- how many were accepted, skipped, duplicated, ambiguous, or rejected;
- how many attachments were found, copied, already present, or missing;
- which warnings and errors occurred;
- whether the operation committed;
- how long the operation took;
- whether rerunning it is safe.

The exact report varies by workstream. The obligation to produce evidence does
not.

### Production Changes Are Intentional

Whenever practical, a production operation follows:

```text
Source
  -> Analysis
  -> Proposed change plan
  -> Validation
  -> User or policy review
  -> Commit
  -> Post-commit verification
  -> Durable evidence
```

`Commit` means the controlled mutation phase of the operation. It does not
promise that a multi-database and filesystem workflow can always be one SQLite
transaction. Each workstream must define its actual atomicity, checkpoint,
interruption, resumption, and rollback semantics.

## Development And Production Separation

Development/production separation is a project-wide prerequisite, not one
workstream's private concern.

### Production Environment

Production is the environment entrusted with the user's active archive. It
uses the stable production app identity and production data location, receives
normal live synchronization, and permits only reviewed production operations.

Production guarantees must include:

- stable bundle/signing identity where required for Full Disk Access
  continuity;
- one admitted application process before writable providers start;
- named execution authority for graph and archive mutations;
- snapshots or equivalent recovery evidence before high-risk changes;
- no ad hoc SQL mutation as an operational shortcut;
- no development-only reset, simulation, or fixture behavior.

### Development And Test Environments

Development, tests, and experiments use disposable state isolated from the
production write root.

Their source material may be:

- synthetic fixtures;
- privacy-safe test archives;
- read-only snapshots of real sources;
- deliberately selected live read-only source databases.

Even when a development build reads the live macOS Messages source, its
app-owned write targets must remain isolated from production.

### Promotion Rule

Production is not updated by copying an experimental data folder into place.

The implementation and procedure are promoted:

1. prove behavior in a disposable environment;
2. preserve the test evidence;
3. review the production plan and recovery path;
4. run the approved procedure against production through production-owned
   services;
5. verify and record the result.

### Current Implementation Boundary

Production Data Protection Slices 0-10 are implemented. Debug/Profile and tests
cannot derive the production writable root through ordinary provider
construction. Persistent stores require admitted archive authority, protected
mutations require operation authority, and disposable checkpoint restoration
has automated evidence.

The existing production archive was adopted in place through the separately
authorized runbook on 2026-07-28. The current signed and notarized production
application now operates against it and has demonstrated startup catch-up and
live attachment preservation. A bounded residual of 12 non-image attachments
from the interrupted initial catch-up remains explicit reconciliation work.
See
[`WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/COMPLETION-REPORT.md`](WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/COMPLETION-REPORT.md).

## Shared Requirements Across All Workstreams

Every workstream must address the following concerns explicitly.

### Source Identity And Provenance

Source identity must survive beyond a filename or transient mounted path.
Imported facts require enough provenance to explain where they came from,
which snapshot or installation they represented, and how they relate to
already imported evidence.

### Idempotency And Duplicate Handling

Rerunning a completed or interrupted operation must not silently duplicate
records or attachment files. "Duplicate" must be defined by stable source or
canonical identity, not merely by similar content.

### Interruption And Resumption

Every long-running workflow must state:

- what happens if the app quits;
- what happens if the machine restarts;
- which partial effects may exist;
- how the next launch detects them;
- whether the operation resumes, rolls back, or requests review.

### Validation Before Mutation

Read-only discovery and analysis should precede mutation. A source should be
rejected or quarantined before commit if its identity, schema, compatibility,
or integrity cannot be established.

### Ownership

This project coordinates review; it does not become a runtime mega-owner.

- Onboarding coordinates and presents first-run workflow.
- Source-scoped import owns ingestion of source facts.
- Conversation Graph owns projection and graph lifecycle.
- Attachments owns archive ingestion, resolution, integrity, and recovery.
- Overlay owns durable user intent and archive metadata.
- Navigation and ViewSpecs own presentation routing according to existing
  contracts.
- Database essentials own physical provider construction and maintenance
  authority.

Workstream implementations must use these owners or deliberately revise the
canonical architecture. They must not create a parallel "production readiness"
service that absorbs their responsibilities.

### Objective Evidence

Tests prove implementation behavior. Operation evidence proves what happened
to a particular source and archive. Both are required; neither substitutes for
the other.

## Workstreams

The project consists of seven focused but related workstreams.

They are numbered by architectural dependency. Production Data Protection is
first because every later workstream must know which environment and archive
it may modify before it can safely perform production work.

### 1. Production Data Protection

Define and enforce the boundary between production and development:

- runtime data-root isolation;
- production and development app identities;
- source access;
- snapshots and rollback;
- migration safety;
- operational permissions;
- developer and agent workflow;
- production execution authority.

This workstream is foundational. Other workstreams may investigate in parallel,
but no risky production procedure should ship without this boundary.

Active folder:
[`WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/`](WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/)

### 2. Onboarding Review

Review and refine the complete first-run path:

- first launch and permissions;
- environment readiness;
- initial database creation;
- first Messages and Contacts ingestion;
- initial attachment archiving;
- progress and phase presentation;
- interruption and restart recovery;
- completion and transition into the application.

The result should be calm, informative, and resilient.

Planned folder: `WORKSTREAMS/02-ONBOARDING-REVIEW/`

### 3. Historical Messages Import

Develop a repeatable process for importing Apple Messages history from:

- older Macs;
- Time Machine snapshots;
- archived Messages folders;
- recovered drives;
- other valid Apple Messages installations.

The design must address source identity, source-scoped IDs, duplicate
detection, message topology, attachments, provenance, incremental enrichment,
and repeatable validation.

Planned folder: `WORKSTREAMS/03-HISTORICAL-MESSAGES-IMPORT/`

### 4. Archived MessageLens Import

Define how a previous MessageLens archive may contribute to the current
production archive.

This is not automatically equivalent to importing an Apple Messages source.
The workstream must classify:

- source-derived facts;
- graph projections;
- overlay intent;
- attachment archive content;
- provenance and operation evidence;
- retired or incompatible schemas.

It must then define which information may be merged, rebuilt, imported,
reconciled, or only inspected.

Planned folder: `WORKSTREAMS/04-ARCHIVED-MESSAGELENS-IMPORT/`

### 5. Attachment Integrity

Ensure MessageLens can account for every attachment referenced by imported
message evidence:

- archive discovery;
- content identity and deduplication;
- missing-file detection;
- checksum verification;
- source and archive reconciliation;
- repair opportunities;
- backup assumptions.

The output is an integrity model and trustworthy reconciliation procedure, not
merely a count of files.

Planned folder: `WORKSTREAMS/05-ATTACHMENT-INTEGRITY/`

### 6. Import Validation

Define the common evidence contract for ingestion:

- scanned and imported counts;
- duplicate and conflict classification;
- attachment outcomes;
- warnings and failures;
- timing and phase evidence;
- pre-commit plan;
- post-commit verification;
- report retention and support export.

This workstream should identify reusable evidence concepts without forcing
unrelated importers into one implementation.

Planned folder: `WORKSTREAMS/06-IMPORT-VALIDATION/`

### 7. Production Health

Provide ongoing, user-comprehensible confidence in:

- database integrity;
- import and graph freshness;
- attachment integrity;
- overlay integrity;
- archive completeness;
- storage use;
- known historical sources;
- unresolved warnings and recovery opportunities.

Production health observes and explains. It must not silently repair or mutate
the archive merely because it detected an inconsistency.

Production Health may surface preservation-authority heartbeat and operation
evidence. It does not establish preservation authority, guarantee continuity,
or make continuity an optional later enhancement.

Planned folder: `WORKSTREAMS/07-PRODUCTION-HEALTH/`

## Workstream Package Contract

Workstream subfolders live under [`WORKSTREAMS/`](WORKSTREAMS/) and are created
when their work begins, not pre-populated merely to make the tree look
complete.

Each workstream should normally establish:

- `README.md` — scope, status, dependencies, and reading order;
- `00-task.md` — permanent mission statement, frozen once investigation begins;
- `CURRENT-STATE-AUDIT.md` — verified code and runtime behavior;
- `PROPOSAL.md` — approved architectural and product direction;
- `DECISIONS.md` or focused decision records — settled choices and rationale;
- `IMPLEMENTATION-PLAN.md` — bounded phases and ownership;
- `VALIDATION.md` — automated, sandbox, interruption, and production checks;
- `COMPLETION-REPORT.md` — implemented behavior, evidence, and remaining risk.

Use only the documents the workstream actually needs. Detailed reasoning stays
with the workstream that owns it; this master plan records shared rules and
cross-workstream decisions.

When a workstream changes durable project architecture, update the existing
canonical folder as part of completion. Sequence 90 must not become the only
place where shipped behavior is explained.

## Project Progression

Every workstream follows the same broad progression:

1. Inspect current code, data flow, user experience, and operational behavior.
2. Record verified behavior without confusing historical plans with current
   implementation.
3. Identify deficiencies and risks.
4. Propose the smallest coherent improvement.
5. Resolve architectural and product questions.
6. Implement in a disposable development environment.
7. Test normal, failure, interruption, restart, and idempotent rerun behavior.
8. Produce objective evidence.
9. Review the production procedure and recovery path.
10. Apply to production only after the preceding steps succeed.
11. Promote completed behavior into canonical documentation.

Investigation may proceed in parallel where dependencies permit. Production
application remains deliberately sequenced.

## Project-Wide Hard Invariants

1. Apple-owned and user-supplied source databases and attachment folders are
   read-only.
2. Development and experimental writes never target the production archive.
3. High-risk production operations require a verified recovery path.
4. User intent remains in overlay storage and is never copied into graph
   projection.
5. Imported and projected records are not suppressed because they are
   anomalous.
6. Historical source identity and provenance remain explicit.
7. Graph projection does not consult overlay state.
8. Ingestion and reconciliation are idempotent or explicitly refuse unsafe
   reruns.
9. Long-running workflows define interruption and restart semantics.
10. Significant operations produce durable, inspectable evidence.
11. No new cross-process or in-process writer bypasses the established
    execution authorities.
12. Recovery is preferred over manual in-place repair.

## Non-Goals

This project does not:

- create one universal importer for every possible archive;
- collapse onboarding, import, graph projection, attachment archive, and
  health into one owner;
- treat retired MessageLens databases as automatically authoritative;
- infer identity from content similarity when stable source identity is
  required;
- use production data to accelerate development testing;
- hide anomalies to make validation reports look clean;
- promise that every damaged or incomplete historical source can be recovered.

## Definition Of Success

The Production Readiness project is complete when:

- production and development write environments are reliably separated;
- onboarding is calm, informative, interruptible, and recoverable;
- current and historical ingestion is repeatable, provenance-preserving, and
  idempotent;
- previous MessageLens archives can be safely classified and incorporated
  where appropriate;
- attachment preservation and integrity are objectively verifiable;
- every significant operation reports what it planned and what it did;
- production health explains the archive's condition without unsafe implicit
  repair;
- the user can expand the archive without fearing silent loss, duplication, or
  corruption.

## Long-Term Vision

MessageLens is evolving beyond a viewer for today's Messages database.

Its purpose is to become a permanent, continuously improving archive of a
person's digital conversations. As historical sources are discovered over the
years, they should enrich the archive rather than complicate it.

Every recovered message, attachment, relationship, and Conversation restores
another piece of personal history.

The final measure of success is not merely that MessageLens imports data
correctly. It is that the user entrusts MessageLens with a lifetime of
conversations without hesitation.
