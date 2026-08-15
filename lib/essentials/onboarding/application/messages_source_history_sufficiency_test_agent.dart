import '../../presence/domain/services/test_agent.dart';
import 'messages_source_history_count_reader.dart';
import 'messages_source_history_sufficiency_policy.dart';

/// Establishes whether the local Messages history is sufficiently populated.
final class MessagesSourceHistorySufficiencyTestAgent implements TestAgent {
  const MessagesSourceHistorySufficiencyTestAgent({
    required MessagesSourceHistoryCountReader countReader,
  }) : _countReader = countReader;

  final MessagesSourceHistoryCountReader _countReader;

  @override
  Future<bool> evaluate() async {
    final rowCount = _countReader.readCount();
    return isMessagesSourceHistorySufficient(rowCount);
  }
}
