import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'read-only recovery matcher has no mutation or presentation dependency',
    () {
      final matcher = File(
        'lib/features/attachments/application/'
        'message_lens_attachment_recovery_matcher.dart',
      ).readAsStringSync();
      final inspector = File(
        'lib/features/attachments/infrastructure/repositories/'
        'message_lens_attachment_payload_inspector.dart',
      ).readAsStringSync();
      final evidenceFactory = File(
        'lib/features/attachments/infrastructure/repositories/'
        'message_lens_attachment_identity_evidence_factory.dart',
      ).readAsStringSync();

      expect(matcher, contains('SameMessagesLineageAdmission'));
      expect(matcher, isNot(contains('SourceScopedRowKey')));
      expect(evidenceFactory, contains('SourceScopedRowKey.unpackSourceRowId'));
      expect(evidenceFactory, isNot(contains('SourceScopedRowKey.pack(')));
      expect(matcher, isNot(contains('AttachmentArchiveWriteStore')));
      expect(matcher, isNot(contains('RecoveredAttachmentArchiveWriter')));
      expect(matcher, isNot(contains('features/settings')));
      expect(matcher, isNot(contains('presentation/')));
      expect(inspector, isNot(contains('.copy(')));
      expect(inspector, isNot(contains('.writeAsBytes(')));
      expect(inspector, isNot(contains('.create(')));
      expect(inspector, isNot(contains('OverlayDatabase')));
    },
  );

  test(
    'recovery installation stays inside attachment ownership boundaries',
    () {
      final batchExecutor = File(
        'lib/features/attachments/application/'
        'message_lens_attachment_recovery_batch_executor.dart',
      ).readAsStringSync();
      final installer = File(
        'lib/features/attachments/application/'
        'message_lens_attachment_recovery_installer.dart',
      ).readAsStringSync();
      final currentAdapter = File(
        'lib/features/attachments/infrastructure/repositories/'
        'import_ledger_message_lens_attachment_evidence_reader.dart',
      ).readAsStringSync();
      final donorAdapter = File(
        'lib/features/attachments/infrastructure/repositories/'
        'sqlite_message_lens_attachment_donor_evidence_reader.dart',
      ).readAsStringSync();
      final historicalArchivesFiles = Directory(
        'lib/features/settings',
      ).listSync(recursive: true).whereType<File>();

      expect(installer, contains('AttachmentArchiveFileStore'));
      expect(installer, contains('AttachmentArchiveWriteStore'));
      expect(installer, contains('ArchiveMutationCapability'));
      expect(
        installer,
        contains('ArchiveMutationOperation.attachmentReconciliation'),
      );
      expect(installer, contains('mutationCapability.requireOperation'));
      expect(batchExecutor, contains('MessageLensAttachmentRecoveryInstaller'));
      expect(batchExecutor, contains('ArchiveMutationCapability'));
      expect(
        batchExecutor,
        contains('ArchiveMutationOperation.attachmentReconciliation'),
      );
      expect(batchExecutor, contains('_requireExactApprovedSet'));
      expect(batchExecutor, isNot(contains('installVerifiedArchiveEntry')));
      expect(
        batchExecutor,
        isNot(contains('SourceScopedArchiveImportService')),
      );
      expect(batchExecutor, isNot(contains('ConversationGraphDatabase')));
      expect(installer, isNot(contains('ImportLedger')));
      expect(installer, isNot(contains('ConversationGraphDatabase')));
      expect(installer, isNot(contains('HistoricalArchives')));
      expect(currentAdapter, contains('ImportLedger'));
      expect(currentAdapter, contains('AttachmentArchiveReadStore'));
      expect(currentAdapter, isNot(contains('sqlite3.open')));
      expect(currentAdapter, isNot(contains('OverlayDatabase')));
      expect(donorAdapter, contains('OpenMode.readOnly'));
      expect(donorAdapter, contains('PRAGMA query_only = ON'));
      expect(donorAdapter, isNot(contains('INSERT')));
      expect(donorAdapter, isNot(contains('UPDATE')));
      expect(donorAdapter, isNot(contains('DELETE')));
      for (final file in historicalArchivesFiles) {
        final source = file.readAsStringSync();
        expect(
          source,
          isNot(contains('installVerifiedArchiveEntry')),
          reason: '${file.path} must not enable attachment recovery',
        );
      }
    },
  );

  test(
    'Historical Archives delegates recovery without importing donor content',
    () {
      final service = File(
        'lib/features/settings/infrastructure/repositories/'
        'message_lens_historical_archive_preflight_service.dart',
      ).readAsStringSync();
      final workflow = File(
        'lib/features/settings/application/'
        'historical_archives_workflow_panel_model_provider.dart',
      ).readAsStringSync();
      final identity = File(
        'lib/essentials/source_scoped_import/domain/'
        'historical_archive_source_identity.dart',
      ).readAsStringSync();
      final trackOccupants = File(
        'lib/features/settings/presentation/layout/'
        'historical_archives_track_occupants.dart',
      ).readAsStringSync();
      final qualifier = File(
        'lib/features/attachments/infrastructure/repositories/'
        'sqlite_message_lens_attachment_recovery_donor_qualifier.dart',
      ).readAsStringSync();
      final panel = File(
        'lib/features/settings/presentation/view/'
        'historical_archives_panel.dart',
      ).readAsStringSync();

      expect(service, contains('verifyMessageLensCandidate'));
      expect(service, contains('MessageLensAttachmentRecoveryMatcher'));
      expect(
        service.indexOf('verifyMessageLensCandidate'),
        lessThan(service.indexOf('_inspectAttachments(')),
      );
      expect(service, isNot(contains('SourceScopedArchiveImportService')));
      expect(service, isNot(contains('ConversationGraphDatabase')));
      expect(service, isNot(contains('overlayDatabaseProvider')));
      expect(service, isNot(contains('AttachmentArchiveWriteStore')));
      expect(service, contains('donorQualifier.qualify'));
      expect(service, isNot(contains('HistoricalArchiveSourceIdentity')));
      expect(
        service,
        isNot(contains('HistoricalMessagesArchiveSourceRegistrar')),
      );
      expect(workflow, contains('HistoricalArchivesMessageLensReadyState'));
      expect(
        workflow,
        contains('messageLensAttachmentRecoveryBatchExecutorProvider'),
      );
      expect(
        workflow,
        contains('ArchiveMutationOperation.attachmentReconciliation'),
      );
      expect(
        workflow,
        isNot(contains('MessageLensAttachmentRecoveryInstaller')),
      );
      expect(workflow, isNot(contains('installVerifiedArchiveEntry')));
      expect(workflow, isNot(contains('SourceScopedArchiveImportService')));
      expect(workflow, isNot(contains('ConversationGraphDatabase')));
      expect(panel, contains('Recover Attachments'));
      expect(panel, isNot(contains('installVerifiedArchiveEntry')));
      expect(identity, isNot(contains('messageLensFromArchiveInstanceId')));
      expect(identity, isNot(contains('message-lens-recovery-archive:')));
      expect(qualifier, contains('OpenMode.readOnly'));
      expect(qualifier, contains('(8, 5, 1)'));
      expect(qualifier, contains('(9, 5, 1)'));
      expect(qualifier, contains('(10, 1, 2)'));
      expect(qualifier, isNot(contains('buildSourceKey')));
      expect(qualifier, isNot(contains('SourceRegistrar')));
      expect(qualifier, isNot(contains('ArchiveInstanceId(')));
      expect(qualifier, isNot(contains('.write')));
      expect(qualifier, isNot(contains('INSERT')));
      expect(qualifier, isNot(contains('UPDATE')));
      expect(qualifier, isNot(contains('DELETE')));
      expect(trackOccupants, contains('HistoricalArchivesSourceTypeControl'));
      expect(trackOccupants, contains('messageLensDataFolders'));
    },
  );

  test('MessageLens preflight is batched, observable, and hash-free', () {
    final service = File(
      'lib/features/settings/infrastructure/repositories/'
      'message_lens_historical_archive_preflight_service.dart',
    ).readAsStringSync();
    final currentAdapter = File(
      'lib/features/attachments/infrastructure/repositories/'
      'import_ledger_message_lens_attachment_evidence_reader.dart',
    ).readAsStringSync();
    final payloadInspector = File(
      'lib/features/attachments/infrastructure/repositories/'
      'message_lens_attachment_payload_inspector.dart',
    ).readAsStringSync();
    final donorAdapter = File(
      'lib/features/attachments/infrastructure/repositories/'
      'sqlite_message_lens_attachment_donor_evidence_reader.dart',
    ).readAsStringSync();
    final qualifier = File(
      'lib/features/attachments/infrastructure/repositories/'
      'sqlite_message_lens_attachment_recovery_donor_qualifier.dart',
    ).readAsStringSync();
    final workflow = File(
      'lib/features/settings/application/'
      'historical_archives_workflow_panel_model_provider.dart',
    ).readAsStringSync();
    final preflightInspection = payloadInspector.substring(
      payloadInspector.indexOf('Future<AttachmentPayloadInspection> inspect('),
      payloadInspector.indexOf(
        'Future<VerifiedDonorAttachmentPayloadResult> inspectVerified(',
      ),
    );

    expect(service, contains('.readPayloadStatuses('));
    expect(service, isNot(contains('.readPayloadStatus(')));
    expect(service, isNot(contains('Timer(')));
    expect(currentAdapter, contains('readAllArchiveMetadata'));
    expect(currentAdapter, contains('inspectClaims'));
    expect(payloadInspector, contains('list(recursive: true'));
    expect(payloadInspector, contains('const batchSize = 250'));
    expect(
      currentAdapter,
      contains("columns: const <String>['source_rowid', 'guid']"),
    );
    expect(preflightInspection, isNot(contains('sha256.bind')));
    expect(preflightInspection, isNot(contains('openRead()')));
    expect(payloadInspector, contains('inspectVerified'));
    expect(payloadInspector, contains('sha256.startChunkedConversion'));
    expect(payloadInspector, contains('file.openRead()'));
    expect(donorAdapter, contains('validateExecutionIntegrity'));
    expect(donorAdapter, contains('PRAGMA integrity_check'));
    expect(qualifier, isNot(contains('validateExecutionIntegrity')));
    expect(
      workflow.indexOf('await waitForInspectionPresentation()'),
      lessThan(
        workflow.indexOf(
          'messageLensHistoricalArchivePreflightProvider.future',
        ),
      ),
    );
  });

  test('controlled-loss manifest helper is read-only and external', () {
    final helper = File(
      'tool/generate_message_lens_attachment_recovery_controlled_loss_manifest.dart',
    ).readAsStringSync();

    expect(helper, contains('OpenMode.readOnly'));
    expect(helper, contains("environment.serializedName != 'development'"));
    expect(helper, contains('outside both archives'));
    expect(helper, isNot(contains('.delete(')));
    expect(helper, isNot(contains('DELETE FROM')));
    expect(helper, isNot(contains('UPDATE ')));
    expect(helper, isNot(contains('INSERT INTO')));
    expect(helper, isNot(contains('ArchiveMutationCoordinator')));
  });
}
