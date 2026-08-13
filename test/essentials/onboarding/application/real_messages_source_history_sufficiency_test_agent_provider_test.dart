import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/application/conversation_graph_readiness.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/real_messages_source_history_sufficiency_test_agent_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  test(
    'provider delegates fresh counts through the Onboarding probe',
    () async {
      final probe = _RecordingDatabaseProbeReader(rowCount: 10);
      final container = ProviderContainer(
        overrides: <Override>[
          fullDiskAccessProvider.overrideWithValue(
            const _MessagesPathFullDiskAccess(),
          ),
          onboardingDatabaseProbeReaderProvider.overrideWithValue(probe),
        ],
      );
      addTearDown(container.dispose);

      final agent = container.read(
        realMessagesSourceHistorySufficiencyTestAgentProvider,
      );

      expect(await agent.evaluate(), isFalse);
      probe.rowCount = 11;
      expect(await agent.evaluate(), isTrue);
      expect(probe.invocationCount, 2);
      expect(probe.lastDatabasePath, '/test/Library/Messages/chat.db');
      expect(probe.lastTableName, 'message');
      expect(probe.lastQueryOnly, isTrue);
    },
  );
}

final class _MessagesPathFullDiskAccess implements FullDiskAccess {
  const _MessagesPathFullDiskAccess();

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() => true;

  @override
  Future<void> openSettings() async {}
}

final class _RecordingDatabaseProbeReader
    implements OnboardingDatabaseProbeReader {
  _RecordingDatabaseProbeReader({required this.rowCount});

  int? rowCount;
  int invocationCount = 0;
  String? lastDatabasePath;
  String? lastTableName;
  bool? lastQueryOnly;

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    invocationCount += 1;
    lastDatabasePath = dbPath;
    lastTableName = tableName;
    lastQueryOnly = queryOnly;
    return rowCount;
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
    throw UnimplementedError();
  }

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    throw UnimplementedError();
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    throw UnimplementedError();
  }
}
