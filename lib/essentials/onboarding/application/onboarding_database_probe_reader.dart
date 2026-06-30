import '../../db/application/conversation_graph_readiness.dart';
import '../domain/onboarding_environment_report.dart';

abstract interface class OnboardingDatabaseProbeReader {
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount});

  OnboardingDatabaseProbe probeDirectory(String directoryPath);

  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  });

  ConversationGraphReadiness readConversationGraphReadiness(String dbPath);
}
