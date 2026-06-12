import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/services/manual_handle_link_store.dart';

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
    final row = await _overlayDatabase.getHandleOverride(handleId);
    if (row == null) {
      return null;
    }

    return ManualHandleOverride(
      handleId: row.handleId,
      participantId: row.participantId,
      virtualParticipantId: row.virtualParticipantId,
    );
  }

  @override
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) {
    return _overlayDatabase.setHandleOverride(handleId, participantId);
  }

  @override
  Future<void> linkHandleToVirtualParticipant({
    required int handleId,
    required int virtualParticipantId,
  }) {
    return _overlayDatabase.setHandleVirtualParticipantOverride(
      handleId,
      virtualParticipantId,
    );
  }

  @override
  Future<void> deleteHandleOverride(int handleId) {
    return _overlayDatabase.deleteHandleOverride(handleId);
  }

  @override
  Future<List<ManualHandleOverride>> readOverridesForVirtualParticipant(
    int virtualParticipantId,
  ) async {
    final rows = await _overlayDatabase.getOverridesForVirtualParticipant(
      virtualParticipantId,
    );
    return rows
        .map(
          (row) => ManualHandleOverride(
            handleId: row.handleId,
            participantId: row.participantId,
            virtualParticipantId: row.virtualParticipantId,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteVirtualParticipant(int virtualParticipantId) async {
    await _overlayDatabase.deleteVirtualParticipant(virtualParticipantId);
  }
}
