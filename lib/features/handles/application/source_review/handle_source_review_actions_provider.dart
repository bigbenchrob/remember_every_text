import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../contacts/feature_level_providers.dart'
    show manualHandleLinkServiceProvider;
import '../../domain/utilities/handle_normalizer.dart';
import '../read_models/handle_identity.dart';
import '../read_models/handle_source_presentation_provider.dart';
import '../review/handle_review_provider.dart';

part 'handle_source_review_actions_provider.g.dart';

/// Handles-owned workflows for reviewing one canonical source.
///
/// Messages owns the complete handle-lens ViewSpec presentation. Handles owns
/// the meaning and ordering of these source-review workflows. Contact creation
/// and linking remain Contacts-owned primitives delegated to from this facade.
@riverpod
class HandleSourceReviewActions extends _$HandleSourceReviewActions {
  @override
  FutureOr<void> build() {}

  Future<String?> associateSourceWithExistingContact({
    required int handleId,
    required int participantId,
  }) async {
    final canonicalHandleId = canonicalHandleIdentityKey(handleId);
    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .linkHandleToParticipant(
          handleId: canonicalHandleId,
          participantId: participantId,
        );

    return result.fold((failure) => failure.message, (_) {
      _invalidateSourcePresentation(canonicalHandleId);
      return null;
    });
  }

  Future<String?> createContactAndAssociateSource({
    required int handleId,
    required String displayName,
  }) async {
    final canonicalHandleId = canonicalHandleIdentityKey(handleId);
    final service = ref.read(manualHandleLinkServiceProvider.notifier);
    final createResult = await service.createVirtualParticipant(
      displayName: displayName,
    );

    return createResult.fold((failure) async => failure.message, (
      virtualParticipantId,
    ) async {
      final linkResult = await service.linkHandleToVirtualParticipant(
        handleId: canonicalHandleId,
        virtualParticipantId: virtualParticipantId,
      );
      return linkResult.fold((failure) => failure.message, (_) {
        _invalidateSourcePresentation(canonicalHandleId);
        return null;
      });
    });
  }

  Future<String?> dismissSource({required int handleId}) async {
    final canonicalHandleId = canonicalHandleIdentityKey(handleId);
    final source = await ref.read(
      handleSourcePresentationProvider(handleId: canonicalHandleId).future,
    );
    final rawEndpoint = source.rawEndpoint;
    if (rawEndpoint == null || rawEndpoint.isEmpty) {
      return 'Unable to dismiss a source whose endpoint is unavailable.';
    }

    await ref
        .read(handleReviewActionsProvider.notifier)
        .dismissUnfamiliarHandle(normalizeHandleIdentifier(rawEndpoint));
    _invalidateSourcePresentation(canonicalHandleId);
    return null;
  }

  void _invalidateSourcePresentation(int handleId) {
    ref.invalidate(handleSourcePresentationProvider(handleId: handleId));
  }
}
