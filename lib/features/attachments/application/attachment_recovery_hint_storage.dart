import 'dart:convert';

import '../../../essentials/retained_archive/domain/archive_compatibility_key.dart';
import '../domain/entities/attachment_recovery_metadata.dart';

const _kAttachmentRecoveryHintSettingPrefix = 'attachment_recovery_hint';

/// Builds a recovery-hint key using the current archive compatibility key.
///
/// The pair mirrors retained archive storage and is not canonical graph
/// identity.
String attachmentRecoveryHintSettingKey({
  required ArchiveCompatibilityKey archiveKey,
}) {
  return '$_kAttachmentRecoveryHintSettingPrefix::${archiveKey.storageKeySegment}';
}

AttachmentRecoveryMetadata? decodeAttachmentRecoveryHint(String? rawValue) {
  if (rawValue == null || rawValue.trim().isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AttachmentRecoveryMetadata(
      lastRecoveryAttemptAt: _readDateTime(decoded, 'lastRecoveryAttemptAt'),
      nextRecoveryAttemptAt: _readDateTime(decoded, 'nextRecoveryAttemptAt'),
      recoveryAttemptCount: _readInt(decoded, 'recoveryAttemptCount') ?? 0,
      recoveryPriority: _readInt(decoded, 'recoveryPriority') ?? 0,
      userInterestRaisedAt: _readDateTime(decoded, 'userInterestRaisedAt'),
      lastRecoveryErrorSummary: decoded['lastRecoveryErrorSummary'] as String?,
      isNonRecoverable: decoded['isNonRecoverable'] as bool? ?? false,
    );
  } on FormatException {
    return null;
  }
}

String encodeAttachmentRecoveryHint(AttachmentRecoveryMetadata metadata) {
  return jsonEncode(<String, Object?>{
    'lastRecoveryAttemptAt': metadata.lastRecoveryAttemptAt
        ?.toUtc()
        .toIso8601String(),
    'nextRecoveryAttemptAt': metadata.nextRecoveryAttemptAt
        ?.toUtc()
        .toIso8601String(),
    'recoveryAttemptCount': metadata.recoveryAttemptCount,
    'recoveryPriority': metadata.recoveryPriority,
    'userInterestRaisedAt': metadata.userInterestRaisedAt
        ?.toUtc()
        .toIso8601String(),
    'lastRecoveryErrorSummary': metadata.lastRecoveryErrorSummary,
    'isNonRecoverable': metadata.isNonRecoverable,
  });
}

DateTime? _readDateTime(Map<String, dynamic> decoded, String key) {
  final rawValue = decoded[key];
  if (rawValue is! String || rawValue.isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(rawValue).toUtc();
  } on FormatException {
    return null;
  }
}

int? _readInt(Map<String, dynamic> decoded, String key) {
  final rawValue = decoded[key];
  if (rawValue is int) {
    return rawValue;
  }
  if (rawValue is num) {
    return rawValue.toInt();
  }
  return null;
}
