import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/status/conversation_graph_status_log_writer_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/domain/status/conversation_graph_status.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_provider.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_storage_provider.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/pipeline_audit_incident_log_writer.dart';
import 'package:remember_this_text/essentials/onboarding/application/derived_message_data_file_store_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('persistent providers fail before archive admission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(attachmentArchiveDirectoryProvider),
      throwsStateError,
    );
    await expectLater(
      container.read(overlayDatabaseProvider.future),
      throwsStateError,
    );
    expect(
      () => container.read(derivedMessageDataFileStoreProvider),
      throwsStateError,
    );
  });

  test(
    'persistent providers remain inside one admitted test archive',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'messagelens_persistent_provider_test_',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        await fixture.dispose();
      });

      final importDatabase = await container.read(
        sourceScopedImportDatabaseProvider.future,
      );
      final graphDatabase = await container.read(
        driftConversationGraphDatabaseProvider.future,
      );
      final overlayDatabase = await container.read(
        overlayDatabaseProvider.future,
      );

      expect(importDatabase, isNotNull);
      expect(graphDatabase, isNotNull);
      expect(overlayDatabase, isNotNull);

      final attachmentPath = container.read(attachmentArchiveDirectoryProvider);
      expect(path.isWithin(fixture.root.path, attachmentPath), isTrue);

      final diagnosticLogPath = container.read(
        diagnosticLogDirectoryPathProvider,
      );
      expect(path.isWithin(fixture.root.path, diagnosticLogPath), isTrue);

      final incidentWriter = container.read(pipelineIncidentLogWriterProvider);
      expect(incidentWriter, isA<PipelineAuditIncidentLogWriter>());
      final incidentDirectory =
          (incidentWriter as PipelineAuditIncidentLogWriter).directoryPath;
      expect(
        path.equals(fixture.root.path, incidentDirectory) ||
            path.isWithin(fixture.root.path, incidentDirectory),
        isTrue,
      );

      final resetStore = container.read(derivedMessageDataFileStoreProvider);
      final resetProbe = File(path.join(fixture.root.path, 'reset_probe.db'))
        ..writeAsStringSync('test');
      expect(resetStore.databaseBaseFileExists('reset_probe.db'), isTrue);
      await resetStore.deleteDatabaseBaseFiles(['reset_probe.db']);
      expect(resetProbe.existsSync(), isFalse);

      final graphStatusWriter = container.read(
        conversationGraphStatusLogWriterProvider,
      );
      final graphStatusLogPath = await graphStatusWriter.writeRun(
        before: _status(),
      );
      expect(path.isWithin(fixture.root.path, graphStatusLogPath), isTrue);

      final rootFiles = fixture.root
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => path.relative(file.path, from: fixture.root.path))
          .toSet();
      expect(
        rootFiles,
        containsAll(<String>{
          '.messagelens-archive.json',
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          appDatabaseFileName(AppDatabaseFile.conversationGraph),
          appDatabaseFileName(AppDatabaseFile.overlay),
        }),
      );
      expect(
        rootFiles.every(
          (relativePath) =>
              !path.isAbsolute(relativePath) && !relativePath.startsWith('../'),
        ),
        isTrue,
      );
    },
  );
}

ConversationGraphStatus _status() {
  return const ConversationGraphStatus(
    chatDbPath: '/tmp/synthetic-chat.db',
    importLedgerDatabaseLabel: 'import',
    graphDatabaseLabel: 'graph',
    sourceId: 1,
    sourceMessageCount: 1,
    sourceMaxRowId: 1,
    ledgerMessageCount: 1,
    ledgerMaxSourceRowId: 1,
    ledgerMessagesNeedingEnrichment: 0,
    ledgerMessagesStillWithoutText: 0,
    graphMessageCount: 1,
    associatedMessageEdgeCount: 0,
    sourceChatCount: 0,
    importChatCount: 0,
    graphChatCount: 0,
    sourceHandleCount: 0,
    importHandleCount: 0,
    graphHandleCount: 0,
    importTopologyEdgeCount: 0,
    graphTopologyEdgeCount: 0,
    duplicateGraphTopologyEdgeCount: 0,
    importChatToHandleEdgeCount: 0,
    graphChatToHandleEdgeCount: 0,
    duplicateGraphChatToHandleEdgeCount: 0,
    sourceAttachmentCount: 0,
    importAttachmentCount: 0,
    graphAttachmentCount: 0,
    importMessageToAttachmentEdgeCount: 0,
    graphMessageToAttachmentEdgeCount: 0,
    duplicateGraphMessageToAttachmentEdgeCount: 0,
  );
}
