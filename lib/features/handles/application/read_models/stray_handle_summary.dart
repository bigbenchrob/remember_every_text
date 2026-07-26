import '../../domain/entities/stray_handle_endpoint_kind.dart';

final class StrayHandleSummary {
  const StrayHandleSummary({
    required this.handleId,
    required this.handleValue,
    required this.serviceType,
    required this.totalMessages,
    required this.endpointKind,
    this.reviewedAt,
    this.lastMessageDate,
  });

  final int handleId;
  final String handleValue;
  final String serviceType;
  final int totalMessages;
  final StrayHandleEndpointKind endpointKind;

  /// ISO 8601 timestamp of when the user last reviewed this handle, or null
  /// if never reviewed.
  final String? reviewedAt;
  final DateTime? lastMessageDate;

  StrayHandleSummary copyWith({
    int? handleId,
    String? handleValue,
    String? serviceType,
    int? totalMessages,
    StrayHandleEndpointKind? endpointKind,
    Object? reviewedAt = _sentinel,
    Object? lastMessageDate = _sentinel,
  }) {
    return StrayHandleSummary(
      handleId: handleId ?? this.handleId,
      handleValue: handleValue ?? this.handleValue,
      serviceType: serviceType ?? this.serviceType,
      totalMessages: totalMessages ?? this.totalMessages,
      endpointKind: endpointKind ?? this.endpointKind,
      reviewedAt: identical(reviewedAt, _sentinel)
          ? this.reviewedAt
          : reviewedAt as String?,
      lastMessageDate: identical(lastMessageDate, _sentinel)
          ? this.lastMessageDate
          : lastMessageDate as DateTime?,
    );
  }
}

const Object _sentinel = Object();
