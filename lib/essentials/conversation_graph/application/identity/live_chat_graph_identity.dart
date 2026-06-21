import '../../../source_scoped_import/domain/known_sources.dart';
import '../../../source_scoped_import/domain/source_scoped_row_key.dart';

/// Normalizes live `chat.db` row identifiers into conversation-graph identity.
///
/// This boundary exists for graph context lookups that can still receive a live
/// source ROWID from compatibility/navigation inputs. Ordinary graph evidence
/// remains keyed by source-scoped ids.
int canonicalLiveChatGraphId(int value) {
  if (value <= 0 || value > SourceScopedRowKey.maxSourceRowId) {
    return value;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: value,
  );
}

/// Returns the live `chat.db` ROWID for a graph id.
int? liveChatSourceRowIdForGraphId(int value) {
  if (SourceScopedRowKey.unpackSourceId(value) != liveChatDbSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(value);
}
