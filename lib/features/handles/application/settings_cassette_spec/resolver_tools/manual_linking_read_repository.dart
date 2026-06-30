class UnlinkedHandle {
  const UnlinkedHandle({
    required this.id,
    required this.handleId,
    required this.service,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final int chatCount;
}

class AvailableParticipant {
  const AvailableParticipant({
    required this.id,
    required this.displayName,
    required this.handleCount,
  });

  final int id;
  final String displayName;
  final int handleCount;
}

class HandleLinkInfo {
  const HandleLinkInfo({
    required this.participantId,
    required this.participantName,
    required this.confidence,
    required this.source,
  });

  final int participantId;
  final String participantName;
  final double confidence;
  final String source;

  bool get isManualLink => source == 'user_manual' || source == 'user_created';
}

abstract interface class ManualLinkingReadRepository {
  Future<List<UnlinkedHandle>> readUnlinkedHandles();

  Future<List<AvailableParticipant>> readAvailableParticipants();

  Future<HandleLinkInfo?> readHandleLinkInfo(int handleId);
}
