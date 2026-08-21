---
tier: project
scope: production-archive-recovery
owner: agent-per-project
last_reviewed: 2026-08-21
source_of_truth: implementation-record
links:
  - ../prompts/40-RESPONSE-TO-AUDIT-01.md
  - ./40-HISTORICAL-ARCHIVES-ARCHITECTURE-CONFORMANCE-AUDIT.md
tests:
  - test/architecture/historical_archives_typed_presentation_state_test.dart
  - test/features/settings/application/historical_archives_workflow_panel_model_provider_test.dart
  - test/features/settings/presentation/view/historical_archives_panel_test.dart
---

# Historical Archives Typed Presentation State

## Result

Historical Archives now represents each current workflow meaning as one sealed
presentation-state variant. The workflow envelope stores only that variant.
It no longer stores independently combinable context, stage, selected source,
candidate evidence, import progress, removal progress, notice, and reference
fields.

The old field bag permitted combinations such as:

- hub plus selected source;
- existing source plus import progress;
- ready candidate plus removal progress;
- importing plus duplicate notice;
- removing plus candidate inspection evidence;
- an orange source reference attached to an unrelated operation.

Action methods avoided those combinations by convention. The new type shape
makes them unrepresentable through the public workflow-state constructor.

## State Architecture

`HistoricalArchivesWorkflowState` owns exactly one
`HistoricalArchivesPresentationState`. The sealed variants are:

- `HistoricalArchivesHubState`;
- `HistoricalArchivesDuplicateNoticeState`;
- `HistoricalArchivesInvalidNoticeState`;
- `HistoricalArchivesImportSuccessNoticeState`;
- `HistoricalArchivesKnownSourceReferenceState`;
- `HistoricalArchivesInspectingCandidateState`;
- `HistoricalArchivesInspectionFailedState`;
- `HistoricalArchivesReadyToAddState`;
- `HistoricalArchivesExistingSourceState`;
- `HistoricalArchivesImportingState`;
- `HistoricalArchivesImportFailedState`;
- `HistoricalArchivesRemovingState`;
- `HistoricalArchivesRemovalFailedState`.

Read-only projection getters preserve the existing widget/provider contract.
They derive evidence, source selection, notices, references, and progress by
pattern matching the active variant. They are not independent stored fields.

## State And Transition Table

| State | Required transient data | Durable authority consulted | Visible responsibility | Allowed transitions | Mutation authority |
| --- | --- | --- | --- | --- | --- |
| Hub | none | source ledger may list known archives | empty center; ordinary sidebar | inspect folder; select known source | inactive |
| Duplicate notice | source key plus notice/session occurrence | successful imported membership | hub behind modal | dismissal -> source reference | inactive |
| Invalid notice | notice/session occurrence only | none | hub behind modal | dismissal -> hub | inactive |
| Import success notice | notice/session occurrence only | finalized import already verified | hub behind acknowledgement | dismissal -> hub | inactive |
| Known-source reference | source key plus reference occurrence | imported source exists | hub; matching cartouche pulses orange | timer/navigation -> hub | inactive |
| Inspecting candidate | presentation data plus inspection occurrence | source inspector | inspection presentation | ready; inspection failure; duplicate notice; invalid notice | inactive |
| Inspection failed | candidate evidence plus failure projection | source inspector result | retryable or terminal inspection failure | retry -> inspecting; cancel -> hub | inactive |
| Ready to add | qualified candidate evidence | fresh inspection/preflight evidence | Add, Cancel, Details | authorize -> importing; cancel -> hub | inactive |
| Existing source | imported-source facts | registry plus positive source-scoped count | blue selection and management story | remove -> removing; clear/add -> hub/inspection | inactive |
| Importing | candidate evidence plus import progress | coordinator and import/graph services | Narrator and import instrumentation | progress; failure; verified completion -> success notice | active |
| Import failed | candidate evidence, preserved import progress, failure detail | committed import/graph truth | failure evidence and supported retry | retry -> importing; abandon -> hub | inactive |
| Removing | imported-source facts plus removal progress | coordinator and removal/graph services | Narrator and removal instrumentation | progress; failure; verified completion -> hub | active |
| Removal failed | imported-source facts, preserved removal progress, failure detail | remaining durable membership | failure evidence and supported recovery | retry/select/clear according to durable truth | inactive |

Every transition publishes one complete variant. In particular,
`readyToAdd -> importing` and `existingSource -> removing` have no intermediate
provider state in which evidence or controls have disappeared while the new
operation meaning has not yet appeared.

## Truth Ownership

The union owns current presentation and workflow context only. Durable truth
remains in the established source registry, source-scoped import ledger,
Conversation Graph, and archive metadata repositories.

Candidate inspection facts use `HistoricalArchivesInspectionEvidence` and
exist only in inspection, ready, importing, and import-failure variants.
Selected/imported archive facts use `HistoricalArchivesImportedSourceFacts`
and exist only in existing-source, removing, and removal-failure variants.
The selected-source model therefore cannot accidentally retain candidate
preflight evidence.

## Notices And Correspondence

Duplicate, invalid-folder, and successful-import notices are exclusive
hub-family variants. Orange correspondence is a fourth exclusive hub-family
variant. They cannot coexist with one another or with candidate, selection,
import, or removal state.

The process-only occurrences retain their established meanings:

- a notice occurrence identifies one modal presentation;
- a reference occurrence identifies one fresh orange pointing gesture;
- an inspection occurrence identifies one in-flight inspection;
- the presentation-session occurrence rejects work belonging to an abandoned
  Historical Archives visit.

None is persisted or used as archive identity. Duplicate dismissal creates a
new reference occurrence; invalid and success dismissal return directly to
hub. An old reference timer clears only its own active reference variant.

## Progress And Narrator

Import progress is required only by importing and import-failure variants.
Removal progress is required only by removing and removal-failure variants.
No state can contain both.

Narrator and Directed Instrumentation remain projections of the active typed
variant and its progress. Source addition, combined-history preparation,
verification silence, removal scope, failures, and the terminal dwell keep
their validated behavior. No free-form Narrator string became workflow truth.

## Transition Surface

The existing application commands remain the public transition surface:

- `chooseMessagesFolder` / `loadFolder`;
- `showKnownSource`;
- `cancelAddArchive` / `clearSelection`;
- `retrySelectedFolderInspection`;
- `beginImportForSelectedSource`;
- `removeImportedArchiveDataForSelectedSource`;
- typed notice dismissal methods;
- `resetPresentationContext`.

Internal observation handlers replace the active import/removal variant with a
new variant containing updated typed progress. Session, inspection, operation,
modal, reference, and completion-dwell guards continue to reject stale work.

## Mechanical Guarantees

The type structure now prevents these combinations:

- hub with candidate evidence or selected source;
- existing source with either operation progress type;
- ready candidate with removal progress;
- importing with removal progress or ready controls;
- removing with import progress or candidate evidence;
- simultaneous import and removal terminal states;
- any notice with an operation or selected-source state;
- invalid notice with a source reference;
- duplicate reference with blue selection;
- stale orange correspondence attached to an unrelated state.

The architecture tripwire verifies the sealed variants, the single-field
workflow envelope, exclusive notice/reference variants, and disjoint import
and removal progress ownership. Behavioral tests retain race, navigation,
modal, retry, import, removal, Narrator, sidebar, and panel coverage.

## Preserved Boundaries

- No database schema or persistence format changed.
- `ArchiveMutationCoordinator`, database admission, and maintenance authority
  are unchanged.
- Source identity and canonical source-key behavior are unchanged.
- Tracks A-I and their existing state-dependent center boundary are unchanged.
- Copy, layout, controls, timing, modals, references, and archive behavior are
  unchanged.

This resolves audit finding D1. Findings D2 (Track-boundary composition), D3
(offline-capable source identity authority), and D4 (legacy generated Drift
write APIs) remain separate.

## Verification

- Typed workflow, panel, sidebar, and architecture tests: 91 passed.
- Complete Settings test suite: 134 passed.
- Maintenance, Onboarding, import, and Track regression set: 142 passed.
- Complete architecture suite: 383 passed.
- Complete Flutter test suite: 1,837 passed.
- `flutter analyze`: no issues found.
- `flutter build macos --debug`: succeeded and produced
  `build/macos/Build/Products/Debug/MessageLens Development.app`.
- `git diff --check`: clean.

The debug build retained the existing Xcode empty-build-number diagnostic and
the `volume_controller` `PrivacyInfo.xcprivacy` processing warning. Neither
prevented the build from succeeding, and neither was introduced by this state
refactor.
