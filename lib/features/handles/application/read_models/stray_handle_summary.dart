final class StrayHandleSummary {
  const StrayHandleSummary({
    required this.handleId,
    required this.handleValue,
    required this.serviceType,
    required this.totalMessages,
    this.reviewedAt,
    this.lastMessageDate,
    this.junkScore = 0,
    this.isShortCode = false,
  });

  final int handleId;
  final String handleValue;
  final String serviceType;
  final int totalMessages;

  /// ISO 8601 timestamp of when the user last reviewed this handle, or null
  /// if never reviewed.
  final String? reviewedAt;
  final DateTime? lastMessageDate;

  /// Heuristic score indicating likelihood of junk/spam (higher = more likely).
  /// Used to filter candidates for Spam/One-off mode.
  final int junkScore;

  /// Whether this handle is a short code (3-8 digits, no country code).
  final bool isShortCode;

  StrayHandleSummary copyWith({
    int? handleId,
    String? handleValue,
    String? serviceType,
    int? totalMessages,
    Object? reviewedAt = _sentinel,
    Object? lastMessageDate = _sentinel,
    int? junkScore,
    bool? isShortCode,
  }) {
    return StrayHandleSummary(
      handleId: handleId ?? this.handleId,
      handleValue: handleValue ?? this.handleValue,
      serviceType: serviceType ?? this.serviceType,
      totalMessages: totalMessages ?? this.totalMessages,
      reviewedAt: identical(reviewedAt, _sentinel)
          ? this.reviewedAt
          : reviewedAt as String?,
      lastMessageDate: identical(lastMessageDate, _sentinel)
          ? this.lastMessageDate
          : lastMessageDate as DateTime?,
      junkScore: junkScore ?? this.junkScore,
      isShortCode: isShortCode ?? this.isShortCode,
    );
  }
}

const Object _sentinel = Object();
