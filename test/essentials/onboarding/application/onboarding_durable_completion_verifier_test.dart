import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/conversation_graph_readiness.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_durable_completion_verifier_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';

void main() {
  test(
    'completion proof uses positive canonical messages row counts',
    () async {
      final reader = _FakeProbeReader(importRows: 120, graphRows: 118);
      final verifier = ProbeOnboardingDurableCompletionVerifier(
        databaseProbeReader: reader,
        archiveRootPath: '/archive',
      );

      final proof = await verifier.verifyInstallationReady();

      expect(proof.sourceScopedImportRows, 120);
      expect(proof.conversationGraphRows, 118);
      expect(reader.tableNames, <String>['messages', 'messages']);
      expect(reader.probedRowCounts, <int?>[120, 118]);
    },
  );

  test('missing durable rows cannot produce completion proof', () async {
    final verifier = ProbeOnboardingDurableCompletionVerifier(
      databaseProbeReader: _FakeProbeReader(importRows: 120, graphRows: 0),
      archiveRootPath: '/archive',
    );

    await expectLater(verifier.verifyInstallationReady(), throwsStateError);
  });
}

final class _FakeProbeReader implements OnboardingDatabaseProbeReader {
  _FakeProbeReader({required this.importRows, required this.graphRows});

  final int? importRows;
  final int? graphRows;
  final List<String> tableNames = <String>[];
  final List<int?> probedRowCounts = <int?>[];

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    probedRowCounts.add(rowCount);
    return OnboardingDatabaseProbe(
      path: filePath,
      exists: true,
      readable: true,
      rowCount: rowCount,
    );
  }

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    tableNames.add(tableName);
    return dbPath.endsWith('macos_import_ss.db') ? importRows : graphRows;
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
    throw UnimplementedError();
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    throw UnimplementedError();
  }
}
