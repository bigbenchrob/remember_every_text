import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/services/manual_handle_link_store.dart';
import 'participant_merge_utils.dart';

class OverlayManualHandleLinkStore implements ManualHandleLinkStore {
  const OverlayManualHandleLinkStore({required OverlayDatabase overlayDatabase})
    : _overlayDatabase = overlayDatabase;

  final OverlayDatabase _overlayDatabase;

  @override
  Future<List<ManualHandleVirtualParticipant>> readVirtualParticipants() async {
    final rows = await _overlayDatabase.getVirtualParticipants();
    return rows
        .map(
          (row) => ManualHandleVirtualParticipant(
            id: row.id,
            displayName: row.displayName,
          ),
        )
        .toList();
  }

  @override
  Future<ManualHandleVirtualParticipant> createVirtualParticipant({
    required String displayName,
    String? notes,
  }) async {
    final row = await _overlayDatabase.createVirtualParticipant(
      displayName: displayName,
      notes: notes,
    );
    return ManualHandleVirtualParticipant(
      id: row.id,
      displayName: row.displayName,
    );
  }

  @override
  Future<ManualHandleOverride?> readHandleOverride(int handleId) async {
    HandleToParticipantOverride? row;
    for (final candidateId in handleIdentityKeyVariantsForGraphLookup(
      handleId,
    )) {
      row = await _overlayDatabase.getHandleOverride(candidateId);
      if (row != null) {
        break;
      }
    }
    if (row == null) {
      return null;
    }

    return ManualHandleOverride(
      handleId: canonicalHandleIdentityKeyForOverlay(row.handleId),
      participantId: row.participantId == null
          ? null
          : canonicalContactIdentityKeyForOverlay(row.participantId!),
      virtualParticipantId: row.virtualParticipantId,
    );
  }

  @override
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    final canonicalHandleId = canonicalHandleIdentityKeyForOverlay(handleId);
    final canonicalParticipantId = canonicalContactIdentityKeyForOverlay(
      participantId,
    );
    await _deleteHandleOverrideVariants(handleId);
    await _overlayDatabase.setHandleOverride(
      canonicalHandleId,
      canonicalParticipantId,
    );
  }

  @override
  Future<void> linkHandleToVirtualParticipant({
    required int handleId,
    required int virtualParticipantId,
  }) async {
    final canonicalHandleId = canonicalHandleIdentityKeyForOverlay(handleId);
    await _deleteHandleOverrideVariants(handleId);
    await _overlayDatabase.setHandleVirtualParticipantOverride(
      canonicalHandleId,
      virtualParticipantId,
    );
  }

  @override
  Future<void> deleteHandleOverride(int handleId) async {
    await _deleteHandleOverrideVariants(handleId);
  }

  @override
  Future<List<ManualHandleOverride>> readOverridesForVirtualParticipant(
    int virtualParticipantId,
  ) async {
    final rows = await _overlayDatabase.getOverridesForVirtualParticipant(
      virtualParticipantId,
    );
    final overridesByCanonicalHandleId = <int, ManualHandleOverride>{};
    for (final row in rows) {
      final canonicalHandleId = canonicalHandleIdentityKeyForOverlay(
        row.handleId,
      );
      overridesByCanonicalHandleId[canonicalHandleId] = ManualHandleOverride(
        handleId: canonicalHandleId,
        participantId: row.participantId == null
            ? null
            : canonicalContactIdentityKeyForOverlay(row.participantId!),
        virtualParticipantId: row.virtualParticipantId,
      );
    }
    return overridesByCanonicalHandleId.values.toList(growable: false);
  }

  @override
  Future<void> deleteVirtualParticipant(int virtualParticipantId) async {
    await _overlayDatabase.deleteVirtualParticipant(virtualParticipantId);
  }

  Future<void> _deleteHandleOverrideVariants(int handleId) async {
    for (final candidateId in handleIdentityKeyVariantsForGraphLookup(
      handleId,
    )) {
      await _overlayDatabase.deleteHandleOverride(candidateId);
    }
  }
}
