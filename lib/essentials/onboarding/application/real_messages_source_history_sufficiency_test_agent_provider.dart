import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/persistence/probe_messages_source_history_count_reader.dart';
import 'full_disk_access_provider.dart';
import 'messages_source_history_sufficiency_test_agent.dart';
import 'onboarding_database_probe_reader_provider.dart';

part 'real_messages_source_history_sufficiency_test_agent_provider.g.dart';

@Riverpod(keepAlive: true)
MessagesSourceHistorySufficiencyTestAgent
realMessagesSourceHistorySufficiencyTestAgent(Ref ref) {
  return MessagesSourceHistorySufficiencyTestAgent(
    countReader: ProbeMessagesSourceHistoryCountReader(
      databaseProbeReader: ref.watch(onboardingDatabaseProbeReaderProvider),
      messagesDatabasePath: ref
          .watch(fullDiskAccessProvider)
          .messagesDatabasePath,
    ),
  );
}
