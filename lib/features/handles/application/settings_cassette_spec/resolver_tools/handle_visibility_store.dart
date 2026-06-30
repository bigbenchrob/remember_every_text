final class HandleVisibilityIntent {
  const HandleVisibilityIntent({
    required this.handleId,
    required this.isVisible,
    required this.isBlacklisted,
  });

  final int handleId;
  final bool isVisible;
  final bool isBlacklisted;
}

abstract interface class HandleVisibilityStore {
  Future<List<HandleVisibilityIntent>> readAll();

  Future<void> blockHandle(int handleId);

  Future<void> unblockHandle(int handleId);
}
