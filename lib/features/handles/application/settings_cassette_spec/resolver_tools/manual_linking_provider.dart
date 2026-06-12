import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../contacts/feature_level_providers.dart';
import '../../../../contacts/infrastructure/repositories/virtual_participants_provider.dart';
import '../../../infrastructure/repositories/manual_linking_read_repository_provider.dart';
import 'manual_linking_read_repository.dart';

export 'manual_linking_read_repository.dart';

part 'manual_linking_provider.g.dart';

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a graph contact link OR an overlay
/// manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also applied by the read repository.
@riverpod
Future<List<UnlinkedHandle>> unlinkedHandles(Ref ref) async {
  final repository = await ref.watch(
    manualLinkingReadRepositoryProvider.future,
  );
  return repository.readUnlinkedHandles();
}

/// Provider that gets all available participants for linking.
///
/// Handle counts merge graph contact links with overlay manual links.
@riverpod
Future<List<AvailableParticipant>> availableParticipants(Ref ref) async {
  final repository = await ref.watch(
    manualLinkingReadRepositoryProvider.future,
  );
  return repository.readAvailableParticipants();
}

/// Provider for manual linking operations
@riverpod
class ManualLinking extends _$ManualLinking {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Link a handle to a participant manually.
  ///
  /// Writes only to the overlay DB. Read providers combine overlay links with
  /// graph AddressBook topology at read time.
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );
    result.fold((failure) => throw StateError(failure.message), (_) {});

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Unlink a handle from a participant.
  ///
  /// Removes the overlay override so the handle reverts to its graph-projected
  /// AddressBook default (linked or unlinked).
  Future<void> unlinkHandle(int handleId) async {
    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .unlinkHandle(handleId: handleId);
    result.fold((failure) => throw StateError(failure.message), (_) {});

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Create a new participant for a handle (when no existing participant matches).
  ///
  /// The participant and handle link are both stored in overlay so user-created
  /// contact intent survives graph rebuilds.
  Future<void> createParticipantForHandle({
    required int handleId,
    required String displayName,
  }) async {
    final service = ref.read(manualHandleLinkServiceProvider.notifier);
    final createResult = await service.createVirtualParticipant(
      displayName: displayName,
    );
    final virtualParticipantId = createResult.fold(
      (failure) => throw StateError(failure.message),
      (id) => id,
    );
    final linkResult = await service.linkHandleToVirtualParticipant(
      handleId: handleId,
      virtualParticipantId: virtualParticipantId,
    );
    linkResult.fold((failure) => throw StateError(failure.message), (_) {});

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
    ref.invalidate(virtualParticipantsProvider);
  }

  /// Get link information for a specific handle.
  ///
  /// Checks overlay first because manual links win, then graph topology.
  Future<HandleLinkInfo?> getHandleLinkInfo(int handleId) async {
    final repository = await ref.watch(
      manualLinkingReadRepositoryProvider.future,
    );
    return repository.readHandleLinkInfo(handleId);
  }
}
