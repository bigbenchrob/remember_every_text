final class MessageHistoryCoverageReport {
  MessageHistoryCoverageReport._({
    required this.status,
    required this.totalCurrentMessages,
    required this.accountedInConversations,
    required this.recoveredUnlinked,
    required this.unaccounted,
    required this.earliestMessageDate,
    required this.latestMessageDate,
    required this.generatedAt,
    required this.detail,
  });

  factory MessageHistoryCoverageReport.reconciled({
    required int totalCurrentMessages,
    required int accountedInConversations,
    required int recoveredUnlinked,
    required int unaccounted,
    required DateTime? earliestMessageDate,
    required DateTime? latestMessageDate,
    required DateTime generatedAt,
  }) {
    final counts = <int>[
      totalCurrentMessages,
      accountedInConversations,
      recoveredUnlinked,
      unaccounted,
    ];
    if (counts.any((count) => count < 0)) {
      throw StateError('Message History Coverage counts cannot be negative.');
    }
    if (accountedInConversations > totalCurrentMessages ||
        recoveredUnlinked > totalCurrentMessages ||
        unaccounted > totalCurrentMessages) {
      throw StateError(
        'No Message History Coverage category may exceed the denominator.',
      );
    }
    if (accountedInConversations + recoveredUnlinked + unaccounted !=
        totalCurrentMessages) {
      throw StateError(
        'Message History Coverage categories must partition the denominator.',
      );
    }

    return MessageHistoryCoverageReport._(
      status: unaccounted == 0
          ? MessageHistoryCoverageStatus.complete
          : MessageHistoryCoverageStatus.incomplete,
      totalCurrentMessages: totalCurrentMessages,
      accountedInConversations: accountedInConversations,
      recoveredUnlinked: recoveredUnlinked,
      unaccounted: unaccounted,
      earliestMessageDate: earliestMessageDate,
      latestMessageDate: latestMessageDate,
      generatedAt: generatedAt,
      detail: null,
    );
  }

  factory MessageHistoryCoverageReport.temporarilyUnavailable({
    required DateTime generatedAt,
    required String detail,
  }) {
    return MessageHistoryCoverageReport._(
      status: MessageHistoryCoverageStatus.temporarilyUnavailable,
      totalCurrentMessages: null,
      accountedInConversations: null,
      recoveredUnlinked: null,
      unaccounted: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail: detail,
    );
  }

  factory MessageHistoryCoverageReport.failed({
    required DateTime generatedAt,
    required String detail,
  }) {
    return MessageHistoryCoverageReport._(
      status: MessageHistoryCoverageStatus.failed,
      totalCurrentMessages: null,
      accountedInConversations: null,
      recoveredUnlinked: null,
      unaccounted: null,
      earliestMessageDate: null,
      latestMessageDate: null,
      generatedAt: generatedAt,
      detail: detail,
    );
  }

  final MessageHistoryCoverageStatus status;
  final int? totalCurrentMessages;
  final int? accountedInConversations;
  final int? recoveredUnlinked;
  final int? unaccounted;
  final DateTime? earliestMessageDate;
  final DateTime? latestMessageDate;
  final DateTime generatedAt;
  final String? detail;

  int? get totalAccounted {
    final conversationCount = accountedInConversations;
    final recoveredCount = recoveredUnlinked;
    if (conversationCount == null || recoveredCount == null) {
      return null;
    }
    return conversationCount + recoveredCount;
  }

  Map<String, Object?> toJson() {
    return {
      'totalCurrentMessages': totalCurrentMessages,
      'accountedInConversations': accountedInConversations,
      'recoveredUnlinked': recoveredUnlinked,
      'unaccounted': unaccounted,
      'accounted': totalAccounted,
      'earliest': earliestMessageDate?.toUtc().toIso8601String(),
      'latest': latestMessageDate?.toUtc().toIso8601String(),
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'status': status.jsonValue,
      'detail': detail,
    };
  }
}

enum MessageHistoryCoverageStatus {
  complete('complete'),
  incomplete('incomplete'),
  temporarilyUnavailable('temporarily_unavailable'),
  failed('failed');

  const MessageHistoryCoverageStatus(this.jsonValue);

  final String jsonValue;
}
