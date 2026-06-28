import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/application/conversation_graph_readiness.dart';
import 'package:remember_this_text/essentials/onboarding/application/database_existence_checker.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  group('DatabaseExistenceChecker', () {
    const databaseDirectory = '/tmp/database_existence_checker';

    test('requires graph import database and ready graph database', () {
      final checker = DatabaseExistenceChecker(
        _FakeDatabaseProbeReader(
          probes: {
            path.join(
              databaseDirectory,
              appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
            ): const OnboardingDatabaseProbe(
              path: 'import',
              exists: true,
              readable: true,
              sizeBytes: 1,
            ),
          },
          graphReadiness: const ConversationGraphReadiness(
            isReady: true,
            reason: 'ready',
            messageCount: 1,
            chatCount: 1,
            chatToMessageEdgeCount: 1,
          ),
        ),
      );

      expect(checker.hasPopulatedDatabases(databaseDirectory), isTrue);
    });

    test('does not treat retired cleanup files as sufficient', () {
      final checker = DatabaseExistenceChecker(
        _FakeDatabaseProbeReader(
          probes: {
            path.join(
              databaseDirectory,
              appDatabaseFileName(AppDatabaseFile.retiredMacosImport),
            ): const OnboardingDatabaseProbe(
              path: 'retired macos import',
              exists: true,
              readable: true,
              sizeBytes: 1,
            ),
            path.join(
              databaseDirectory,
              appDatabaseFileName(AppDatabaseFile.retiredWorking),
            ): const OnboardingDatabaseProbe(
              path: 'retired working',
              exists: true,
              readable: true,
              sizeBytes: 1,
            ),
          },
        ),
      );

      expect(checker.hasPopulatedDatabases(databaseDirectory), isFalse);
    });
  });
}

class _FakeDatabaseProbeReader implements OnboardingDatabaseProbeReader {
  const _FakeDatabaseProbeReader({
    required this.probes,
    this.graphReadiness = const ConversationGraphReadiness(
      isReady: false,
      reason: 'not ready',
      messageCount: 0,
      chatCount: 0,
      chatToMessageEdgeCount: 0,
    ),
  });

  final Map<String, OnboardingDatabaseProbe> probes;
  final ConversationGraphReadiness graphReadiness;

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    return probes[filePath] ??
        OnboardingDatabaseProbe(
          path: filePath,
          exists: false,
          readable: false,
          rowCount: rowCount,
        );
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    return graphReadiness;
  }

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    return null;
  }
}
