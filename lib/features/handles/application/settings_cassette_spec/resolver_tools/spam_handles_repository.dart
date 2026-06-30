abstract interface class SpamHandlesRepository {
  Future<List<SpamHandleInfo>> readSpamHandles();
}

class SpamHandleInfo {
  const SpamHandleInfo({
    required this.id,
    required this.handleId,
    required this.service,
    required this.isBlacklisted,
    required this.isVisible,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final bool isBlacklisted;
  final bool isVisible;
  final int chatCount;
}
