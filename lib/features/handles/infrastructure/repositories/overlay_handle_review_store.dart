import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../contacts/application/read_models/contact_summary_identity.dart';
import '../../application/read_models/handle_identity.dart';
import '../../application/review/handle_review_store.dart';

class OverlayHandleReviewStore implements HandleReviewStore {
  const OverlayHandleReviewStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<void> markReviewed({required int handleId}) async {
    final canonicalHandleId = canonicalHandleIdentityKey(handleId);
    final existing = await _readPreferredOverrideVariant(handleId);
    await _deleteHandleOverrideVariants(handleId);

    final participantId = existing?.participantId;
    if (participantId != null) {
      await _overlayDatabase.setHandleOverride(
        canonicalHandleId,
        canonicalContactIdentityKey(participantId),
      );
      return;
    }

    final virtualParticipantId = existing?.virtualParticipantId;
    if (virtualParticipantId != null) {
      await _overlayDatabase.setHandleVirtualParticipantOverride(
        canonicalHandleId,
        virtualParticipantId,
      );
      return;
    }

    await _overlayDatabase.setHandleReviewed(canonicalHandleId);
  }

  @override
  Future<void> dismissHandle(String normalizedHandle) {
    return _overlayDatabase.dismissHandle(normalizedHandle);
  }

  @override
  Future<void> restoreHandle(String normalizedHandle) {
    return _overlayDatabase.restoreHandle(normalizedHandle);
  }

  Future<HandleToParticipantOverride?> _readPreferredOverrideVariant(
    int handleId,
  ) async {
    HandleToParticipantOverride? fallback;
    for (final candidateId in handleIdentityKeyVariants(handleId)) {
      final row = await _overlayDatabase.getHandleOverride(candidateId);
      if (row == null) {
        continue;
      }
      if (row.handleId == canonicalHandleIdentityKey(handleId)) {
        return row;
      }
      fallback ??= row;
    }
    return fallback;
  }

  Future<void> _deleteHandleOverrideVariants(int handleId) async {
    for (final candidateId in handleIdentityKeyVariants(handleId)) {
      await _overlayDatabase.deleteHandleOverride(candidateId);
    }
  }
}
