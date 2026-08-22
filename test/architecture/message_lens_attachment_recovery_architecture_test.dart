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
    'Historical Archives MessageLens arm remains read-only through ready',
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
      expect(workflow, contains('HistoricalArchivesMessageLensReadyState'));
      expect(workflow, isNot(contains('Recover Attachments')));
      expect(identity, contains('messageLensFromArchiveInstanceId'));
      expect(trackOccupants, contains('HistoricalArchivesSourceTypeControl'));
      expect(trackOccupants, contains('messageLensDataFolders'));
    },
  );
}
