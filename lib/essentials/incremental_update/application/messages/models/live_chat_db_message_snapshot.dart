class LiveChatDbMessageSnapshot {
  const LiveChatDbMessageSnapshot({
    required this.maxRowId,
    required this.totalMessageCount,
  });

  final int maxRowId;
  final int totalMessageCount;
}
