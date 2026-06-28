import '../../db/feature_level_providers/conversation_graph_readiness_provider.dart'
    show ConversationGraphReadiness;
import '../domain/onboarding_environment_report.dart';

abstract interface class OnboardingDatabaseProbeReader {
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount});

  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  });

  ConversationGraphReadiness readConversationGraphReadiness(String dbPath);
}
