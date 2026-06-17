import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../handles/feature_level_providers.dart';
import '../../feature_level_providers.dart';

part 'manual_handle_link_service.g.dart';

/// Simple failure wrapper for service-level errors
class Failure {
  const Failure(this.message, {this.stackTrace});

  final String message;
  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure: $message';
}

/// Action boundary for managing manual handle-to-contact links.
///
/// All writes target the manual-link store, whose production implementation is
/// overlay-only. The graph database is never modified here; providers merge
/// graph facts with overlay intent at read time with overlay winning on conflict.
@riverpod
class ManualHandleLinkService extends _$ManualHandleLinkService {
  @override
  void build() {
    // Stateless service, no initialization needed
  }

  /// Creates a virtual participant stored solely in the overlay database.
  ///
  /// Returns the new overlay-scoped participant ID on success, or
  /// `Failure` when validation fails or persistence encounters an error.
  Future<Either<Failure, int>> createVirtualParticipant({
    required String displayName,
    String? notes,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      return const Left(
        Failure('Display name cannot be empty when creating a contact.'),
      );
    }

    try {
      final store = await ref.read(manualHandleLinkStoreProvider.future);
      final existing = await store.readVirtualParticipants();
      final normalizedLower = normalizedName.toLowerCase();

      final hasDuplicate = existing.any(
        (participant) =>
            participant.displayName.toLowerCase() == normalizedLower,
      );

      if (hasDuplicate) {
        return Left(
          Failure('A contact named "$normalizedName" already exists.'),
        );
      }

      final created = await store.createVirtualParticipant(
        displayName: normalizedName,
        notes: notes,
      );

      ref.invalidate(virtualParticipantsProvider);

      return Right(created.id);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to create virtual contact: $e', stackTrace: stackTrace),
      );
    }
  }

  /// Links a handle to a graph contact/participant identity.
  ///
  /// Writes only to the overlay database. Providers merge at read time.
  ///
  /// Returns:
  /// - Right(unit) on success
  /// - Left(Failure) if handle already manually linked to a different participant
  Future<Either<Failure, Unit>> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    try {
      final store = await ref.read(manualHandleLinkStoreProvider.future);

      // Check if manual link already exists to a different participant
      final existingOverride = await store.readHandleOverride(handleId);

      if (existingOverride != null &&
          existingOverride.participantId != null &&
          existingOverride.participantId != participantId) {
        return const Left(
          Failure(
            'Handle is already manually linked to a different contact. '
            'Delete the existing link first.',
          ),
        );
      }

      // Write overlay-only link
      await store.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);
      ref.invalidate(handleDisplayNameProvider(handleId: handleId));

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to link handle to contact: $e', stackTrace: stackTrace),
      );
    }
  }

  /// Links a handle to a virtual participant (overlay-DB).
  ///
  /// Typically called after creating a virtual participant, to associate
  /// the stray handle with the newly-named contact.
  Future<Either<Failure, Unit>> linkHandleToVirtualParticipant({
    required int handleId,
    required int virtualParticipantId,
  }) async {
    try {
      final store = await ref.read(manualHandleLinkStoreProvider.future);

      await store.linkHandleToVirtualParticipant(
        handleId: handleId,
        virtualParticipantId: virtualParticipantId,
      );

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);
      ref.invalidate(handleDisplayNameProvider(handleId: handleId));
      ref.invalidate(virtualParticipantsProvider);

      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(
        Failure(
          'Failed to link handle to virtual contact: $e',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Removes a manual link between handle and participant.
  ///
  /// Deletes the overlay override only. The graph database is not touched.
  /// The handle reverts to its automatic link (if any) or unlinked status.
  ///
  /// If the handle was linked to a virtual participant and that participant
  /// has no remaining handles, the virtual participant is also deleted.
  ///
  /// Returns `true` in the Right payload when the virtual participant was
  /// deleted (i.e. the contact no longer exists), `false` otherwise.
  Future<Either<Failure, bool>> unlinkHandle({required int handleId}) async {
    try {
      final store = await ref.read(manualHandleLinkStoreProvider.future);

      // Check if manual link exists
      final existingOverride = await store.readHandleOverride(handleId);

      if (existingOverride == null) {
        return const Left(Failure('No manual link found for this handle.'));
      }

      final virtualParticipantId = existingOverride.virtualParticipantId;

      // Remove overlay link only
      await store.deleteHandleOverride(handleId);

      // If this handle was linked to a virtual participant, check whether
      // the virtual participant still has any remaining handles.
      var contactDeleted = false;
      if (virtualParticipantId != null) {
        final remaining = await store.readOverridesForVirtualParticipant(
          virtualParticipantId,
        );
        if (remaining.isEmpty) {
          await store.deleteVirtualParticipant(virtualParticipantId);
          contactDeleted = true;
          ref.invalidate(virtualParticipantsProvider);
        }
      }

      // Invalidate cached providers
      ref.invalidate(strayHandlesProvider);
      ref.invalidate(handleDisplayNameProvider(handleId: handleId));

      return Right(contactDeleted);
    } catch (e, stackTrace) {
      return Left(
        Failure('Failed to unlink handle: $e', stackTrace: stackTrace),
      );
    }
  }
}
