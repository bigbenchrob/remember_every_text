import 'package:flutter/foundation.dart';

@immutable
class AttachmentRecoveryMetadata {
  const AttachmentRecoveryMetadata({
    this.lastRecoveryAttemptAt,
    this.nextRecoveryAttemptAt,
    this.recoveryAttemptCount = 0,
    this.recoveryPriority = 0,
    this.userInterestRaisedAt,
    this.lastRecoveryErrorSummary,
    this.isNonRecoverable = false,
  });

  final DateTime? lastRecoveryAttemptAt;
  final DateTime? nextRecoveryAttemptAt;
  final int recoveryAttemptCount;
  final int recoveryPriority;
  final DateTime? userInterestRaisedAt;
  final String? lastRecoveryErrorSummary;
  final bool isNonRecoverable;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AttachmentRecoveryMetadata &&
        other.lastRecoveryAttemptAt == lastRecoveryAttemptAt &&
        other.nextRecoveryAttemptAt == nextRecoveryAttemptAt &&
        other.recoveryAttemptCount == recoveryAttemptCount &&
        other.recoveryPriority == recoveryPriority &&
        other.userInterestRaisedAt == userInterestRaisedAt &&
        other.lastRecoveryErrorSummary == lastRecoveryErrorSummary &&
        other.isNonRecoverable == isNonRecoverable;
  }

  @override
  int get hashCode {
    return Object.hash(
      lastRecoveryAttemptAt,
      nextRecoveryAttemptAt,
      recoveryAttemptCount,
      recoveryPriority,
      userInterestRaisedAt,
      lastRecoveryErrorSummary,
      isNonRecoverable,
    );
  }
}
