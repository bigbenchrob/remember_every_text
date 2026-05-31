import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

/// Graph topology lookup used by recovered-message parity diagnostics.
///
/// This repository answers only whether candidate graph message ids are already
/// projectable into ordinary conversation topology. It does not decide recovered
/// semantics or cutover policy.
class GraphRecoveredMessageProjectabilityRepository {
  const GraphRecoveredMessageProjectabilityRepository({required this.graphDb});

  final ConversationGraphDatabase graphDb;

  Future<Set<int>> readProjectableMessageIds(Iterable<int> messageIds) async {
    final candidateIds = messageIds.toList(growable: false);
    final result = <int>{};
    const chunkSize = 800;

    for (var offset = 0; offset < candidateIds.length; offset += chunkSize) {
      final end = (offset + chunkSize).clamp(0, candidateIds.length);
      final chunk = candidateIds.sublist(offset, end);
      if (chunk.isEmpty) {
        continue;
      }

      final rows = await graphDb.selectRows('''
        SELECT DISTINCT message_ss_id
        FROM chat_to_message
        WHERE message_ss_id IN (${_placeholders(chunk.length)})
        ''', chunk);
      for (final row in rows) {
        result.add(_readInt(row['message_ss_id']));
      }
    }

    return result;
  }
}

String _placeholders(int count) {
  return List.filled(count, '?').join(', ');
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}
