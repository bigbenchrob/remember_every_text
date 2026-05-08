class LiveChatDbMessageSnapshot {
  const LiveChatDbMessageSnapshot({
    required this.maxRowId,
    required this.importableMessageCount,
  });

  final int maxRowId;
  final int importableMessageCount;

  @override
  String toString() {
    return 'LiveChatDbMessageSnapshot('
        'maxRowId: $maxRowId, '
        'importableMessageCount: $importableMessageCount'
        ')';
  }
}
