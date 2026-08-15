# Center-Panel Responsibility Correction: Completion Report

Date: 2026-07-20

## Result

The narrow ownership repair is complete. `MessagesSpec.handleLens`, its Track
occupants, and every user-facing widget remain Messages-owned. Handles now owns
the canonical source identity projection and the meaning of source-review
workflows. Contacts continues to own the Contact primitives used by those
workflows. Navigation composition was unchanged.

## Handles-Owned Source-Review Facade

`handleSourceReviewActionsProvider` exposes:

```text
associateSourceWithExistingContact(handleId, participantId)
createContactAndAssociateSource(handleId, displayName)
dismissSource(handleId)
```

The facade canonicalizes handle identity and owns workflow ordering,
normalization, review persistence, and Handles read-model invalidation.

It delegates these Contact primitives to Contacts:

- `ManualHandleLinkService.linkHandleToParticipant`;
- `ManualHandleLinkService.createVirtualParticipant`;
- `ManualHandleLinkService.linkHandleToVirtualParticipant`.

The existing Contacts-owned `ContactPickerDialog` remains directly consumed by
the Messages presentation.

### Dependency-cycle note

The facade consumes the smallest existing Contacts public seam:
`manualHandleLinkServiceProvider`. A pre-existing reverse dependency remains in
Contacts infrastructure and its manual-link service, which consume Handles
canonical identity helpers and invalidate Handles read models. The resulting
feature-level cycle was not expanded with another private import or duplicated
business rule, but it cannot be removed safely inside this narrow correction.
Eliminating it later would require giving canonical handle identity a neutral
owner and returning Handles invalidation fully to the Handles facade.

## Per-Source Presentation API

`handleSourcePresentationProvider(handleId)` returns a
`HandleSourcePresentation` containing only the facts currently required by the
ViewSpec:

- `canonicalHandleId`;
- `primaryDisplayLabel`;
- optional `rawEndpoint`;
- `statusLabel`;
- `messageCount`.

Handles performs a direct lookup by one canonical handle ID and owns the display
fallback chain:

```text
resolved display identity
-> raw endpoint
-> Handle #<canonical id>
```

It does not scan the active unfamiliar-source investigation list.

## Corrected Dismiss Semantics

The Messages button labelled `Dismiss` now calls the Handles-owned
`dismissSource` workflow. That workflow resolves and normalizes the endpoint,
uses the overlay-backed dismissed-source store, invalidates Handles projections,
removes the source from active review, and leaves it available through the
dismissed/recovery path.

It no longer invokes `markReviewed`. Regression coverage confirms that dismissal
does not create a reviewed-only handle override.

### Follow-up: complete dismissal transition

The initial ownership correction persisted the right disposition but left two
user-visible lifecycle defects: it invalidated the complete active-source
aggregation, briefly replacing the sidebar list with loading, and it left the
dismissed source's center evidence compatible with the current investigation.

The completed transition now has this order:

```text
Messages handle-lens interaction
-> Handles persists normalized dismissal in overlay
-> loaded active projection removes that source without leaving AsyncData
-> Messages advances unfamiliar-source investigation provenance
-> Navigation compatibility makes the originating center evidence ineffective
```

No widget clears a panel. The selected evidence remains stored with its
originating provenance, but cannot project while a newer investigation is
current. If Handles reports a dismissal failure, neither the investigation nor
the center evidence changes.

## Duplicated Messages Logic Removed

Both Messages presentation paths now consume the same Handles payload:

- `handle_lens_view.dart`;
- `unfamiliar_sources_message_track_occupants.dart`.

They no longer watch and scan `strayHandlesProvider`, assemble their own display
fallbacks, or hardcode source identity wording. The retired Messages-owned
`handle_lens_actions_provider.dart` workflow was removed.

## Files Changed For This Slice

### Handles

- `application/read_models/handle_source_presentation.dart`;
- `application/read_models/handle_source_presentation_provider.dart`;
- `application/read_models/stray_handles_read_repository.dart`;
- `infrastructure/repositories/graph_stray_handles_read_repository.dart`;
- `application/source_review/handle_source_review_actions_provider.dart`;
- `feature_level_providers.dart`;
- generated Riverpod companions for the new providers.

### Messages

- `presentation/view/handle_lens_view.dart`;
- `presentation/layout/unfamiliar_sources_message_track_occupants.dart`;
- removed `application/handle_lens/handle_lens_actions_provider.dart` and its
  generated companion.

### Tests And Guards

- `test/features/handles/application/handle_source_presentation_provider_test.dart`;
- `test/features/handles/application/handle_source_review_actions_provider_test.dart`;
- `test/features/handles/application/stray_handles_provider_test.dart`;
- `test/features/messages/presentation/view/handle_lens_view_test.dart`;
- `test/architecture/forbidden_imports_test.dart`.

### Documentation And Release Metadata

- Updated Handles and Messages feature charters.
- Updated the Unknown Sources proposal.
- Recorded the correction in `CHANGELOG.md` and version `0.2.9+27`.

## Verification

Automated verification:

- focused source-presentation, workflow, Messages rendering, and stray-source
  tests: passed;
- focused dismissal-transition tests verify no active-list loading reset and
  no compatible stale center evidence;
- complete architecture tripwire suite: all 350 tests passed;
- `flutter analyze`: passed with no issues.

The automated tests verify:

- Create Contact coordinates virtual Contact creation and association;
- Link to Existing delegates the Contact association primitive;
- Dismiss moves an active source to the recoverable dismissed projection;
- reviewed-only state is not mistaken for dismissal;
- resolved, raw-endpoint, and final-ID title fallbacks;
- unchanged Messages-owned handle-lens rendering and controls.

No interactive macOS manual verification was performed during this code pass.
The implementation should still be checked in the running application for the
three button workflows and visible active/dismissed list transitions before a
release build.
