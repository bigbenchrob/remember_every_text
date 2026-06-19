import '../../../../essentials/source_scoped_import/domain/known_sources.dart';
import '../../../../essentials/source_scoped_import/domain/source_scoped_row_key.dart';

/// Overlay compatibility bridge for handle identity.
///
/// Ordinary handle identity is the graph `ss_id`. These helpers exist so
/// retained overlay rows keyed by older handle ids can still resolve to graph
/// handles while the app continues to write and present canonical graph ids.
Set<int> handleIdentityKeyVariants(int handleId) {
  final ids = <int>{handleId};
  final graphHandleId = _graphHandleIdForRetainedHandleId(handleId);
  if (graphHandleId != null) {
    ids.add(graphHandleId);
  }
  final retainedHandleId = _retainedHandleIdForGraphHandleId(handleId);
  if (retainedHandleId != null) {
    ids.add(retainedHandleId);
  }
  return ids;
}

int canonicalHandleIdentityKey(int handleId) {
  return _graphHandleIdForRetainedHandleId(handleId) ?? handleId;
}

T? overlayValueForHandleIdentity<T>(
  Map<int, T> valuesByHandleId,
  int handleId,
) {
  for (final key in handleIdentityKeyVariants(handleId)) {
    final value = valuesByHandleId[key];
    if (value != null) {
      return value;
    }
  }
  return null;
}

int? _graphHandleIdForRetainedHandleId(int handleId) {
  if (handleId <= 0 || handleId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: handleId,
  );
}

int? _retainedHandleIdForGraphHandleId(int handleId) {
  if (SourceScopedRowKey.unpackSourceId(handleId) != liveChatDbSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(handleId);
}
