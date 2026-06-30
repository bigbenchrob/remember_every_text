final class MessageHistoryCoverageReport {
  const MessageHistoryCoverageReport({
    required this.status,
    required this.chatDbTotalCount,
    required this.graphConversationLinkedCount,
    required this.graphRecoveredOrphanCount,
    required this.earliestMessageDate,
    required this.latestMessageDate,
    this.generatedAt,
    this.detail,
  });

  final MessageHistoryCoverageStatus status;
  final int? chatDbTotalCount;
  final int? graphConversationLinkedCount;
  final int? graphRecoveredOrphanCount;
  final DateTime? earliestMessageDate;
  final DateTime? latestMessageDate;
  final DateTime? generatedAt;
  final String? detail;

  int? get graphTotalAccountedCount {
    final visibleCount = graphConversationLinkedCount;
    final recoveredCount = graphRecoveredOrphanCount;
    if (visibleCount == null || recoveredCount == null) {
      return null;
    }
    return visibleCount + recoveredCount;
  }

  int? get missingCount {
    final sourceCount = chatDbTotalCount;
    final accountedCount = graphTotalAccountedCount;
    if (sourceCount == null || accountedCount == null) {
      return null;
    }
    final delta = sourceCount - accountedCount;
    if (delta > 0) {
      return delta;
    }
    return 0;
  }

  Map<String, Object?> toJson() {
    return {
      'chatDbTotal': chatDbTotalCount,
      'visible': graphConversationLinkedCount,
      'recovered': graphRecoveredOrphanCount,
      'accounted': graphTotalAccountedCount,
      'missing': missingCount,
      'earliest': earliestMessageDate?.toUtc().toIso8601String(),
      'latest': latestMessageDate?.toUtc().toIso8601String(),
      'status': status.jsonValue,
      'detail': detail,
    };
  }
}

enum MessageHistoryCoverageStatus {
  complete('complete'),
  incompleteImport('incomplete_import'),
  incompleteSourceHistory('incomplete_source_history'),
  unknown('unknown');

  const MessageHistoryCoverageStatus(this.jsonValue);

  final String jsonValue;
}
