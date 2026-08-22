import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'known_sources.dart';

enum HistoricalArchiveSourceKind { macMessages }

/// Canonical identity for one historical archive.
///
/// Mac Messages identity uses the normalized absolute path to its `chat.db`.
/// Validation requires no filesystem access, so persisted identity remains
/// usable while the source is offline.
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

  factory HistoricalArchiveSourceIdentity.fromPersistedValue(String value) {
    final trimmed = value.trim();
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
