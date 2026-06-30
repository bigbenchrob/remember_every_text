import '../../../../essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';

/// Overlay compatibility bridge for handle identity.
///
/// Ordinary handle identity is the graph `ss_id`. These helpers exist so
/// older rowid-keyed overlay rows can still resolve to graph
/// handles while the app continues to write and present canonical graph ids.
Set<int> handleIdentityKeyVariants(int handleId) {
  final ids = <int>{handleId};
  final graphHandleId = _graphHandleIdForRowidKeyedHandleId(handleId);
  if (graphHandleId != null) {
    ids.add(graphHandleId);
  }
  final rowidKeyedHandleId = _rowidKeyedHandleIdForGraphHandleId(handleId);
  if (rowidKeyedHandleId != null) {
    ids.add(rowidKeyedHandleId);
  }
  return ids;
}

int canonicalHandleIdentityKey(int handleId) {
  return _graphHandleIdForRowidKeyedHandleId(handleId) ?? handleId;
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

int? _graphHandleIdForRowidKeyedHandleId(int handleId) {
  final graphHandleId = canonicalLiveChatGraphId(handleId);
  return graphHandleId == handleId ? null : graphHandleId;
}

int? _rowidKeyedHandleIdForGraphHandleId(int handleId) {
  return liveChatSourceRowIdForGraphId(handleId);
}
