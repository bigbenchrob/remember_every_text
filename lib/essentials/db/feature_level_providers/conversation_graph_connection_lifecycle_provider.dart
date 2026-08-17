import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

part 'conversation_graph_connection_lifecycle_provider.g.dart';

/// Tracks only a graph connection that has already been constructed.
///
/// Maintenance callers can close an existing connection through this boundary
/// without reading the graph provider and accidentally constructing a new one.
final class ConversationGraphConnectionLifecycle {
  ConversationGraphDatabase? _activeConnection;

  void register(ConversationGraphDatabase database) {
    final activeConnection = _activeConnection;
    if (activeConnection != null && !identical(activeConnection, database)) {
      throw StateError('A Conversation Graph connection is already active.');
    }
    _activeConnection = database;
  }

  Future<bool> closeIfActive() async {
    final activeConnection = _activeConnection;
    if (activeConnection == null) {
      return false;
    }
    _activeConnection = null;
    await activeConnection.close();
    return true;
  }

  Future<void> release(ConversationGraphDatabase database) async {
    if (!identical(_activeConnection, database)) {
      return;
    }
    await closeIfActive();
  }
}

@Riverpod(keepAlive: true)
ConversationGraphConnectionLifecycle conversationGraphConnectionLifecycle(
  ConversationGraphConnectionLifecycleRef ref,
) {
  return ConversationGraphConnectionLifecycle();
}
