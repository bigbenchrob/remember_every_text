---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-20
source_of_truth: architecture-audit
links:
  - ../prompts/39-PAUSE-AND-REVIEW-FOR-ARCHITECTURE-VIOLATIONS.md
  - ./07-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-AUDIT.md
  - ./08-ARCHIVE-MUTATION-OWNER-AWARE-DATABASE-ADMISSION-IMPLEMENTATION.md
  - ./10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
  - ./39-STABLE-NARRATOR-TRACK-REMOVAL-JOURNEY-AND-TERMINAL-PERCEPTION-IMPLEMENTATION.md
---

# Historical Archives Architecture-Conformance Audit

## Purpose

This is an evidence-first audit of the Mac Messages Historical Archives arm
after the Feature 26 implementation sequence. It distinguishes architecture
violations from bounded local implementation, legitimate feature-specific
decisions, and questions that require a later design decision.

No production, staging, donor, source, or attachment data was opened or
modified for this audit.

## Canonical Material Read

The audit used the project constitution and implementation checklist; the
project architecture overview; database access, mutation authority,
maintenance, overlay independence, attachment preservation, and Apple
timestamp rules; the Spec and ViewSpec ownership documents; center-panel and
sidebar composition guidance; the Cross-Column Layout contract and
column-specific shared-boundary documents; Presence rendering and feature
integration contracts; architecture-tripwire guidance; and the Feature 26
audit/implementation records from the maintenance-lock correction through the
stable Narrator Track implementation.

The controlling principles were:

- presentation renders; application code orchestrates; infrastructure owns
  persistence and source inspection;
- `ArchiveMutationCoordinator` is the process-local mutation authority;
- database construction and admission remain centralized;
- unrelated observation must not reopen protected stores during maintenance;
- `DateConverter` is the sole Apple timestamp authority;
- source identity, durable membership, selection, and presentation occurrence
  are different facts;
- Tracks coordinate geometry and have no feature semantics;
- Narrator interprets typed operation state and Directed Instrumentation
  reports real work;
- stale asynchronous work must be mechanically unable to alter a later
  presentation session.

## Audit Checklist

The implementation was traced against these questions:

1. Does each layer perform only its owned responsibility?
2. Is each semantic fact derived from one canonical authority?
3. Are invalid states excluded structurally rather than repaired later?
4. Does every mutation enter through the coordinator with caller-specific
   resource admission?
5. Can any ordinary provider construct or inspect a protected database during
   maintenance?
6. Does every Apple Messages date flow through `DateConverter`?
7. Is one canonical source key used for inspection, membership, reference,
   selection, import, and removal?
8. Are registration, preflight, import membership, import progress, and
   removal represented as distinct facts?
9. Do source and graph comparisons use compatible distinct-GUID arithmetic?
10. Are import/removal shared concepts genuinely shared without forcing the
    two operations through one false generic engine?
11. Is Narrator derived from typed human-meaning transitions and silent when
    its interpretation expires?
12. Does every displayed progress value correspond to real execution work?
13. Do Historical Archives Tracks use the page Matrix rather than offsets or
    hidden padding?
14. Are sidebar, center, and modal responsibilities distinct?
15. Are delayed inspection, modal, reference, and dwell callbacks guarded by
    both presentation session and occurrence/operation identity?
16. Can provider invalidation create a transient impossible workflow state?
17. Does readiness report maintenance rather than setup failure, without
    opening protected stores?
18. Is SQLite busy timeout only bounded contention tolerance?
19. Are exceptions preserved and attributable rather than silently converted
    to plausible evidence?
20. Are sequencing dependencies presentation/transaction boundaries rather
    than database-authority workarounds?
21. Are established visual grammars reused without inventing broad feature
    abstractions?
22. Can superseded UI be proven unreachable before deletion?
23. Do tests protect architecture, not merely widget shape?
24. Do current canonical documents match the settled implementation?

## Historical Archives State And Transition Audit

The current implementation expresses state with a presentation context, a
presentation stage, operation progress, selected/candidate identities, and
ephemeral notices. The following are the coherent combinations used by the
current action paths.

| State | Required durable facts | Required transient facts | Sidebar | Center | Allowed controls | Authority / next transition |
| --- | --- | --- | --- | --- | --- | --- |
| Hub | imported-source ledger may contain zero or more sources | current presentation session | source arm, known-source cartouches, add action | hub identity | select source; add folder | no mutation; explicit selection -> existing source; explicit add -> folder chooser |
| Existing source | registered source plus positive source-scoped message count | explicit selected source key in this session | selected cartouche and add action | source story and management | remove; add another folder | remove requires confirmation then `historicalArchiveRemoval`; navigation/add clears selection |
| Inspecting candidate | none required | chosen folder, inspection occurrence, add context | add-flow context; add action hidden | inspection Narrator/instrumentation | cancel | read-only source inspection; success -> ready, duplicate -> modal boundary, missing -> invalid modal, read failure -> retryable failure |
| Ready to add | readable inspection evidence and fresh canonical source key | candidate and session identity | add-flow context | decision evidence | add; cancel; details | explicit add -> `historicalArchiveImport` |
| Importing | source registration/import rows may emerge during operation | operation identity and typed import progress | stable source arm | Narrator + Directed Instrumentation | details only | coordinator owns `historicalArchiveImport`; terminal durable verification -> dwell -> success notice/hub; failure -> import failure |
| Import failure | durable partial facts are whatever the failed stage truthfully committed | candidate evidence, failure detail, operation identity | stable source arm | failed operation evidence | retry; choose/cancel as offered by typed failure | retry is a fresh explicit command; no automatic import |
| Removing source | selected source remains durably present until deletion completes | removal target, operation identity, typed progress | target cartouche remains visible | Narrator + Directed Instrumentation | details only | coordinator owns `historicalArchiveRemoval`; success -> dwell -> hub; failure -> removal failure |
| Removal failure | source membership reflects actual committed result | target and failure detail | source remains if still durably imported | failed operation evidence | retry/return according to durable truth | no fabricated rollback; fresh explicit command required |
| Duplicate notice | existing imported source membership | notice occurrence, source key, presentation session | existing cartouche ordinary until dismissal | hub behind modal | dismiss modal | no mutation; guarded dismissal creates a new orange reference occurrence only in the same session |
| Invalid notice | none | notice occurrence and presentation session only | hub | hub behind modal | dismiss modal | no persistence, source identity, or later evidence reuse |
| Success notice | terminal import membership already true | notice occurrence and presentation session | newly imported cartouche ordinary | hub behind modal | dismiss | acknowledgement only; no mutation |
| Orange reference | existing canonical source key | process-only reference occurrence and session | matching cartouche pulses orange | unchanged | normal navigation | timer may clear only its own occurrence in its own session |
| Completion dwell | terminal operation result already true and mutation authority released | operation identity and presentation session | stable | all-Done instrumentation | none | after 1.5 seconds, guarded transition to hub/acknowledgement |

### State-model conclusion

The action paths construct coherent states, and the tests cover the most
important session and operation transitions. However, the type itself permits
contradictory combinations because context, stage, notices, selected source,
candidate evidence, and progress are independent fields. A sealed state model
could make more invalid combinations impossible, but that is a broad workflow
redesign. It is classified as a future architecture gap, not repaired in this
bounded pass.

## Database Lifecycle Audit

| Operation | Source `chat.db` | Source-scoped import ledger | Conversation graph | Overlay/archive metadata | Failure behavior |
| --- | --- | --- | --- | --- | --- |
| Startup/readiness | source not opened | observational read only when maintenance is inactive | observational readiness read only when maintenance is inactive | ordinary admitted read | maintenance must project `maintenanceInProgress`, not source/graph failure |
| Folder inspection | one-off read-only SQLite handle, query-only, closed in `finally` | no write | optional admitted read for distinct-GUID comparison | no write until qualification permits metadata | read failure remains typed failure evidence |
| Preflight | consumes inspection result | read-only comparison | admitted read only | eligible metadata persistence remains application-owned | duplicate/missing cannot reach import control |
| Historical import | read-only source handle owned by importer | admitted source registration and source-scoped inserts | admitted owner-specific projection | workflow metadata only | deterministic partial state remains retryable; no attachment mutation |
| Graph preparation | source not opened | admitted read of imported facts | admitted reset/reprojection | no user-intent write | unrelated graph construction remains denied |
| Historical removal | source not required | one transaction removes only target source facts | admitted reset/reprojection from remaining sources | source metadata follows durable operation result | failure reports committed truth; no broad reset |
| Message reset | authoritative external sources untouched | only explicitly rebuildable stores | only explicitly rebuildable stores | preservation/user-intent data retained | attachment archive is never a deletion target |

Canonical construction is retained through the persistent providers. The
three-second import-ledger busy timeout is configured at canonical connection
creation and remains contention tolerance, not admission. The owner-aware
coordinator allows the admitted import/removal operation to use its required
graph resources while denying unrelated callers.

One remaining violation was found: the ordinary conversation-graph readiness
provider directly opened `working_ss.db` after a message-data invalidation
without first observing the maintenance suppression decision. This is listed
as A2 below.

## A. Confirmed Architectural Violations

### A1 / P2: display strings control source qualification

**Location:** `archive_source_inspection.dart`,
`archive_source_inspection_repository.dart`, and
`historical_archives_workflow_panel_model_provider.dart`.

**Rule:** workflow meaning must come from typed application evidence; labels
are presentation.

**Current behavior:** the repository emits labels such as `Missing`, `Read
failed`, and `Found and readable`. Application decisions compare those exact
strings to distinguish an invalid folder, retryable read failure, import
eligibility, metadata persistence, and imported-source matching.

**Risk:** copy editing or localization can silently change workflow behavior.

**Bounded remedy:** add one typed inspection status to the existing inspection
result and propagate it through preflight/evidence. Retain labels solely for
presentation and persisted historical display metadata. No schema or stored
format changes are required.

### A2 / P1: graph readiness can reopen the protected graph during maintenance

**Location:**
`conversation_graph_readiness_provider.dart`.

**Rule:** during admitted maintenance, unrelated observational providers must
not open `working_ss.db`; readiness must report maintenance truth instead.

**Current behavior:** the provider watches message-data version and immediately
runs a one-off SQLite readiness check. It does not observe the maintenance
read-suppression decision. Import/removal completion invalidation can therefore
cause an unrelated graph open while the operation still owns maintenance.

**Risk:** contention, false readiness/failure projection, and erosion of the
caller-specific resource-admission boundary.

**Bounded remedy:** observe the compatibility maintenance read-suppression
provider and return an explicit not-ready maintenance result before deriving a
path or opening SQLite. This does not alter owner-aware persistent database
admission or use busy timeout as a substitute for authority.

### A3 / P2: removal depends on import-owned projection observation types

**Location:** `source_scoped_archive_graph_removal_service.dart` imports
projection unit/progress from `source_scoped_archive_graph_import_service.dart`.

**Rule:** shared abstractions must be genuinely shared and owned at the common
boundary; removal must not depend on import merely because both project the
same graph units.

**Current behavior:** recent truthful removal instrumentation reuses the right
semantic data but imports its contracts from the import service file.

**Risk:** future import changes can accidentally alter removal's contract and
encourage a false combined import/removal engine.

**Bounded remedy:** extract only the graph projection unit/progress value types
to a neutral archive graph-projection observation module. Import and removal
keep distinct stages, observers, results, and algorithms.

## B. Expedient But Bounded Implementations

### B1: the workflow provider is a large mixed application projection

The provider combines workflow orchestration, state transitions, Narrator and
instrumentation projection, old control-panel view-model fields, and copy. Its
responsibilities remain in the application layer and widgets still delegate
actions, so this is not presently a layer violation. Splitting it would be a
substantial state-model change and is deferred.

### B2: source-key reconstruction has two normalization entry points

Folder inspection can use the filesystem resolver, while persisted metadata
must remain readable when the original folder is absent. The repository
therefore reconstructs a key from persisted `sourceChatDb`. Consolidating this
without losing offline metadata semantics requires a deliberately pure source
identity contract or persistence change. No path/identity change is made here.

### B3: superseded control-panel code remains as defensive fallback

The current coherent states all select hub, existing-source, or Narrator
presentation before the legacy panel. The state type still permits invalid
context/stage combinations, however, so the fallback is not mechanically
unreachable. Deleting it before closing that type-level gap would hide rather
than solve the state-model problem.

## C. Legitimate Local Decisions

- The `endOfFrame` barrier after an import command is a presentation
  acknowledgement boundary. It does not order database authority.
- The 1.5-second completed-state dwell begins after mutation authority is
  released and changes perception only; it does not manufacture progress.
- Orange-reference occurrences are process/presentation state, distinct from
  source identity and guarded by session plus occurrence.
- Modal completion and folder-inspection Futures use presentation-session and
  occurrence checks so abandoned work cannot revive a later screen.
- Import and removal share only truthful graph projection observations. Their
  mutation stages and algorithms remain distinct.
- Source fact removal remains one efficient set-based transaction rather than
  row-by-row work invented for animation.
- Directed Instrumentation numeric values come from projector callbacks with
  real numerators/denominators; composite units remain honestly coarse.
- Folder inspection owns a one-off read-only source handle and closes it. It is
  not a persistent feature-owned database instance.
- Fixed Narrator allocation is page Track geometry; rendering silence inside
  that allocation does not hide a source record or create fake vertical
  padding.

## D. Architectural Gaps Requiring Future Design

### D1: the workflow state does not make contradictory combinations impossible

The current independent context/stage/nullable-field model relies on action
methods to construct coherent combinations. A sealed workflow state is a
plausible future direction, but changing it now would broaden behavior and
tests substantially.

### D2: Historical Archives has a state-dependent center shared-track boundary

Operation presentation consumes center Tracks A-I, while existing-source
presentation leaves the shared Matrix after E. The page Track contract says a
column's shared boundary is stable page composition, not transient selected or
loading state. The center-only Narrator Tracks are truthful geometry, but the
state-dependent consumption boundary creates tension with that rule. Fixing it
could disturb the approved existing-source/cartouche-list alignment and needs
a page-composition decision. No layout change is made in this audit.

### D3: source identity reconstruction should have one offline-capable contract

Inspection, persisted metadata, and absent-folder rendering need one canonical
identity rule that does not require the source to exist. The current values are
compatible, but the authority is duplicated. This should be designed before
the future MessageLens-folder arm.

### D4: generated Drift APIs cannot prohibit legacy-table writes

The frozen legacy subtype tables remain mechanically writable through
generated APIs. Prohibiting that would require a schema-level change and is not
part of Feature 26 remediation.

## Date, Identity, Membership, And GUID Results

- Repository search found no private Apple-epoch conversion competing with
  `DateConverter`. Historical source date inspection uses `DateConverter`.
- Source and graph dry-run populations both use distinct GUID semantics; no UI
  clamping hides impossible arithmetic.
- Sidebar membership requires durable source registration plus a positive
  source-scoped imported-message lookup. Merely inspected, failed, and removed
  zero-row sources do not qualify.
- Transient cartouche retention during removal is presentation truth about the
  in-progress selected object and does not rewrite durable membership.
- Selection uses blue, cross-UI correspondence uses orange, and neither is
  durable source identity.

## Remediation Boundary

This pass implemented A1-A3 only. D1-D4 remain recorded rather than silently
resolved because they require broader state, layout, identity, or schema
decisions.

## Completed Remediation

### Typed source qualification

`ArchiveSourceInspectionStatus` now carries `missing`, `readable`,
`readFailed`, and `unavailable`. Its label getter is presentation only.
Readability derives from the typed value, and the status now travels through
preflight, workflow state, and inspection evidence. Invalid-folder routing,
retry eligibility, source matching, metadata eligibility, final verification,
and instrumentation all consume the typed status.

An architecture tripwire rejects equality/inequality decisions made from
`chatDbStatusLabel` in the Historical Archives workflow.

### Maintenance-time graph observation suppression

`conversationGraphReadinessProvider` now observes the compatibility
maintenance suppression signal before resolving the archive authority/path or
invoking the SQLite checker. During maintenance it returns the truthful
not-ready reason `database maintenance is active` with no observational
counts.

The behavior test deliberately supplies only the maintenance override. It
therefore also proves that the provider does not proceed far enough to require
archive admission or graph construction. A static tripwire preserves the
guard-before-check ordering.

### Neutral graph projection observations

`SourceScopedArchiveGraphProjectionUnit` and
`SourceScopedArchiveGraphProjectionProgress` now live in
`source_scoped_archive_graph_projection_observation.dart`. Import and removal
both consume that neutral value contract. Their operation stages, observers,
results, source-fact algorithms, and error behavior remain separate.

A tripwire prohibits the removal service from depending on the import service.

## Dead And Superseded Code Result

No code was removed. The old control-panel fallback looks superseded for all
currently coherent states, but the present state type does not make it
unreachable. Removing it before addressing D1 would trade visible defensive
behavior for an unproved assumption.

## Verification

- Focused typed-inspection, graph-readiness, graph import/removal, and workflow
  tests: 48 passed.
- Complete Settings suite: 129 passed.
- Mutation authority, archive graph, owner admission, Onboarding readiness,
  Track, and DateConverter regressions: 79 passed.
- Architecture tripwires: 377 passed.
- Full Flutter test suite: 1,828 passed.
- `flutter analyze`: no issues.
- macOS debug build: succeeded at
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- `git diff --check`: clean before commit.

## Template Assessment

The current Mac Messages arm is architecturally conformant enough to remain the
behavioral reference for future archive-source work in its proven areas:
caller-aware mutation admission, typed operation observations, truthful
progress, source-scoped provenance, DateConverter authority, preservation, and
session-safe presentation.

It should not yet be copied mechanically as the structural template for a
MessageLens-folder arm. D1-D3 must be resolved first so a second source arm
does not duplicate the permissive workflow-state shape, the state-dependent
Track-boundary tension, or the offline source-key reconstruction split.
