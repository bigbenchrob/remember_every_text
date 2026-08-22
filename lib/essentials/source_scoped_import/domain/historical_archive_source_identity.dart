import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../../archive_environment/domain/archive_instance_id.dart';
import 'known_sources.dart';

enum HistoricalArchiveSourceKind { macMessages, messageLens }

/// Canonical identity for one historical archive.
///
/// Mac Messages identity uses the normalized absolute path to its `chat.db`.
/// MessageLens recovery identity uses the donor's archive instance ID; its path
/// remains locator evidence only. Validation requires no filesystem access, so
/// persisted identity remains usable while the source is offline.
@immutable
final class HistoricalArchiveSourceIdentity {
  const HistoricalArchiveSourceIdentity._({
    required this.kind,
    required this.canonicalSourcePath,
    required this.value,
  });

  factory HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
    String chatDbPath,
  ) {
    final canonicalSourcePath = _normalizeAbsolutePath(chatDbPath);
    return HistoricalArchiveSourceIdentity._(
      kind: HistoricalArchiveSourceKind.macMessages,
      canonicalSourcePath: canonicalSourcePath,
      value: '$historicalMessagesArchiveSourceKeyPrefix$canonicalSourcePath',
    );
  }

  factory HistoricalArchiveSourceIdentity.messageLensFromArchiveInstanceId(
    String archiveInstanceId,
  ) {
    final canonicalArchiveInstanceId = ArchiveInstanceId(
      archiveInstanceId,
    ).value;
    return HistoricalArchiveSourceIdentity._(
      kind: HistoricalArchiveSourceKind.messageLens,
      canonicalSourcePath: '',
      value:
          '$messageLensRecoveryArchiveSourceKeyPrefix$canonicalArchiveInstanceId',
    );
  }

  factory HistoricalArchiveSourceIdentity.fromPersistedValue(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith(messageLensRecoveryArchiveSourceKeyPrefix)) {
      final archiveInstanceId = trimmed.substring(
        messageLensRecoveryArchiveSourceKeyPrefix.length,
      );
      final identity =
          HistoricalArchiveSourceIdentity.messageLensFromArchiveInstanceId(
            archiveInstanceId,
          );
      if (identity.value != trimmed) {
        throw const FormatException(
          'Historical archive source key is not canonical.',
        );
      }
      return identity;
    }
    if (!trimmed.startsWith(historicalMessagesArchiveSourceKeyPrefix)) {
      throw const FormatException('Unsupported historical archive source key.');
    }
    final sourcePath = trimmed.substring(
      historicalMessagesArchiveSourceKeyPrefix.length,
    );
    final identity = HistoricalArchiveSourceIdentity.macMessagesFromChatDbPath(
      sourcePath,
    );
    if (identity.value != trimmed) {
      throw const FormatException(
        'Historical archive source key is not canonical.',
      );
    }
    return identity;
  }

  final HistoricalArchiveSourceKind kind;
  final String canonicalSourcePath;
  final String value;

  String get sourceKind => switch (kind) {
    HistoricalArchiveSourceKind.macMessages =>
      historicalMessagesArchiveSourceKind,
    HistoricalArchiveSourceKind.messageLens =>
      messageLensRecoveryArchiveSourceKind,
  };

  @override
  bool operator ==(Object other) {
    return other is HistoricalArchiveSourceIdentity && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  static String _normalizeAbsolutePath(String sourcePath) {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(sourcePath, 'sourcePath', 'must not be empty');
    }
    return path.normalize(path.absolute(trimmed));
  }
}
