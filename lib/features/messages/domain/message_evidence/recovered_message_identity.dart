import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';

/// Source-scoped identity for a recovered message occurrence.
///
/// A recovered message is still a source `chat.db.message` occurrence. Its
/// identity is therefore the same deterministic source-scoped row key that
/// ordinary graph messages use. Recovery status describes missing or unsafe
/// topology; it must not become a separate identity scheme.
class RecoveredMessageIdentity {
  const RecoveredMessageIdentity({
    required this.sourceId,
    required this.sourceMessageRowId,
    required this.guid,
    required this.hasConversationTopology,
  });

  final int sourceId;
  final int sourceMessageRowId;

  /// Apple message GUID, preserved as source metadata and bridge data.
  ///
  /// This is not canonical identity. Duplicate GUIDs across sources remain
  /// distinct source occurrences.
  final String guid;

  /// Whether source topology can safely project this occurrence into normal
  /// conversation graph edges.
  final bool hasConversationTopology;

  int get messageSsId {
    return SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceMessageRowId,
    );
  }

  bool get isRecoveredEvidenceOnly => !hasConversationTopology;

  bool get canProjectToConversationGraph => hasConversationTopology;

  String get stableEvidenceKey => 'recovered-message:$messageSsId';
}
