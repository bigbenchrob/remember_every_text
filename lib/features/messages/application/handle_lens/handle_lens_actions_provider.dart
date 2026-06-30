import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import '../../../contacts/feature_level_providers.dart'
    show manualHandleLinkServiceProvider;
import '../../../handles/feature_level_providers.dart'
    show handleReviewActionsProvider;

part 'handle_lens_actions_provider.g.dart';

@riverpod
class HandleLensActions extends _$HandleLensActions {
  @override
  FutureOr<void> build() {}

  Future<String?> linkToExistingContact({
    required int handleId,
    required int participantId,
  }) async {
    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );

    return result.fold((failure) {
      ref
          .read(appLoggerProvider.notifier)
          .warn('Link failed: ${failure.message}', source: 'HandleLens');
      return failure.message;
    }, (_) => null);
  }

  Future<void> dismissHandle({required int handleId}) async {
    await ref
        .read(handleReviewActionsProvider.notifier)
        .markReviewed(handleId: handleId);
  }

  Future<String?> createContactAndLinkHandle({
    required int handleId,
    required String displayName,
  }) async {
    final createResult = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .createVirtualParticipant(displayName: displayName);

    return await createResult.fold(
      (failure) async {
        return failure.message;
      },
      (virtualParticipantId) async {
        final linkResult = await ref
            .read(manualHandleLinkServiceProvider.notifier)
            .linkHandleToVirtualParticipant(
              handleId: handleId,
              virtualParticipantId: virtualParticipantId,
            );

        return linkResult.fold((failure) {
          ref
              .read(appLoggerProvider.notifier)
              .warn(
                'Link to virtual failed: ${failure.message}',
                source: 'HandleLens',
              );
          return failure.message;
        }, (_) => null);
      },
    );
  }
}
