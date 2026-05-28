class MessageEvidenceSkeletonEntry {
  const MessageEvidenceSkeletonEntry({
    required this.messageId,
    required this.dateUtc,
    required this.monthKey,
  });

  final int messageId;
  final String? dateUtc;
  final String? monthKey;
}

class MessageEvidenceTimelineSkeleton {
  const MessageEvidenceTimelineSkeleton({
    required this.entries,
    this.initialAnchorMessageId,
  });

  final List<MessageEvidenceSkeletonEntry> entries;
  final int? initialAnchorMessageId;

  int get totalCount => entries.length;

  bool get isEmpty => entries.isEmpty;

  int latestIndex() {
    if (entries.isEmpty) {
      return 0;
    }
    return entries.length - 1;
  }

  int indexForMonth(DateTime monthAnchor) {
    final targetMonthKey = _monthKey(monthAnchor);
    final index = entries.indexWhere((entry) {
      return entry.monthKey == targetMonthKey;
    });
    if (index >= 0) {
      return index;
    }
    return latestIndex();
  }

  int? indexForMessageId(int messageId) {
    final index = entries.indexWhere((entry) {
      return entry.messageId == messageId;
    });
    if (index < 0) {
      return null;
    }
    return index;
  }

  MessageEvidenceTimelineSkeleton filteredByMessageIds(List<int> messageIds) {
    final messageIdSet = messageIds.toSet();
    return MessageEvidenceTimelineSkeleton(
      entries: [
        for (final entry in entries)
          if (messageIdSet.contains(entry.messageId)) entry,
      ],
      initialAnchorMessageId: initialAnchorMessageId,
    );
  }
}

String _monthKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
}
