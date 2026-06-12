final class ManualHandleVirtualParticipant {
  const ManualHandleVirtualParticipant({
    required this.id,
    required this.displayName,
  });

  final int id;
  final String displayName;
}

final class ManualHandleOverride {
  const ManualHandleOverride({
    required this.handleId,
    this.participantId,
    this.virtualParticipantId,
  });

  final int handleId;
  final int? participantId;
  final int? virtualParticipantId;
}

/// Persistence boundary for manual handle-to-contact user intent.
abstract interface class ManualHandleLinkStore {
  Future<List<ManualHandleVirtualParticipant>> readVirtualParticipants();

  Future<ManualHandleVirtualParticipant> createVirtualParticipant({
    required String displayName,
    String? notes,
  });

  Future<ManualHandleOverride?> readHandleOverride(int handleId);

  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  });

  Future<void> linkHandleToVirtualParticipant({
    required int handleId,
    required int virtualParticipantId,
  });

  Future<void> deleteHandleOverride(int handleId);

  Future<List<ManualHandleOverride>> readOverridesForVirtualParticipant(
    int virtualParticipantId,
  );

  Future<void> deleteVirtualParticipant(int virtualParticipantId);
}
