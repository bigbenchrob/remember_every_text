import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('source anomaly policy remains explicit and domain owned', () {
    final counts = File(
      'lib/essentials/source_scoped_import/domain/'
      'source_import_anomaly_counts.dart',
    ).readAsStringSync();
    final snapshot = File(
      'lib/essentials/onboarding/domain/onboarding_operation_snapshot.dart',
    ).readAsStringSync();

    expect(counts, contains('final class SourceImportAnomalyCounts'));
    expect(counts, contains('recoveredUnlinkedMessageCount'));
    expect(counts, contains('richTextDecodeUnavailableCount'));
    expect(counts, contains('omittedContactChannelCount'));
    expect(counts, isNot(contains('Map<String, Object?> anomalies')));
    expect(snapshot, contains("'source_anomaly_counts'"));
  });

  test(
    'structural identity and DateConverter remain fail-closed boundaries',
    () {
      final chatImporter = File(
        'lib/essentials/source_scoped_import/application/chats/'
        'chat_importer.dart',
      ).readAsStringSync();
      final messageImporter = File(
        'lib/essentials/source_scoped_import/application/messages/'
        'message_importer.dart',
      ).readAsStringSync();

      expect(chatImporter, contains("_requiredString(row, 'guid')"));
      expect(messageImporter, contains("_requiredString(row, 'guid')"));
      expect(messageImporter, contains('DateConverter.appleToIsoString'));
      expect(messageImporter, isNot(contains('DateTime(2001')));
    },
  );

  test('child relationship omission validates real source endpoints', () {
    final chatMessage = File(
      'lib/essentials/source_scoped_import/application/chat_message_joins/'
      'chat_message_join_importer.dart',
    ).readAsStringSync();
    final chatHandle = File(
      'lib/essentials/source_scoped_import/application/chat_handle_joins/'
      'chat_handle_join_importer.dart',
    ).readAsStringSync();
    final messageAttachment = File(
      'lib/essentials/source_scoped_import/application/'
      'message_attachment_joins/message_attachment_join_importer.dart',
    ).readAsStringSync();

    expect(chatMessage, contains('existing_chat_rowid'));
    expect(chatMessage, contains('existing_message_rowid'));
    expect(chatHandle, contains('existing_handle_rowid'));
    expect(messageAttachment, contains('existing_attachment_rowid'));
    expect(chatMessage, isNot(contains('catch (_)')));
    expect(chatHandle, isNot(contains('catch (_)')));
    expect(messageAttachment, isNot(contains('catch (_)')));
  });

  test('systemic rich-text capability failure remains fatal', () {
    final enricher = File(
      'lib/essentials/source_scoped_import/application/messages/'
      'message_rich_text_enricher.dart',
    ).readAsStringSync();

    expect(enricher, contains('SourceImportSystemicException'));
    expect(enricher, contains('typedstream_decoder_unavailable'));
  });
}
