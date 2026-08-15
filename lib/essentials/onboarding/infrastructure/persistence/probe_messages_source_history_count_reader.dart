import '../../application/messages_source_history_count_reader.dart';
import '../../application/onboarding_database_probe_reader.dart';

/// Narrows the generic Onboarding database probe to the production Messages
/// history count fact without exposing paths or table mechanics to the Agent.
final class ProbeMessagesSourceHistoryCountReader
    implements MessagesSourceHistoryCountReader {
  const ProbeMessagesSourceHistoryCountReader({
    required OnboardingDatabaseProbeReader databaseProbeReader,
    required String messagesDatabasePath,
  }) : _databaseProbeReader = databaseProbeReader,
       _messagesDatabasePath = messagesDatabasePath;

  final OnboardingDatabaseProbeReader _databaseProbeReader;
  final String _messagesDatabasePath;

  @override
  int readCount() {
    final rowCount = _databaseProbeReader.readTableCount(
      dbPath: _messagesDatabasePath,
      tableName: 'message',
      queryOnly: true,
    );
    if (rowCount == null) {
      throw const MessagesSourceHistoryCountUnavailableException();
    }
    return rowCount;
  }
}
