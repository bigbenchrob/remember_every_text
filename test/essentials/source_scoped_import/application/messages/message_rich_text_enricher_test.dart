import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db_importers/domain/ports/message_extractor_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ss_rich_text_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'enriches attributed-body rows without changing existing text',
    () async {
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 100,
        text: null,
        attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
      );
      await _insertImportMessage(
        importDatabase,
        sourceRowId: 101,
        text: 'already text',
        attributedBodyBlob: Uint8List.fromList(<int>[4, 5, 6]),
      );
      await _insertImportMessage(importDatabase, sourceRowId: 102, text: null);

      final result = await MessageRichTextEnricher(
        chatDbPath: '/fake/chat.db',
        importDatabase: importDatabase,
        extractor: const _FakeExtractor(<int, String>{100: ' decoded text '}),
      ).enrichMissingText();

      final rows = await importDatabase.database.query(
        'messages',
        columns: <String>['source_rowid', 'text'],
        orderBy: 'source_rowid ASC',
      );

      expect(result.candidateMessageCount, 1);
      expect(result.enrichedMessageCount, 1);
      expect(result.missingExtractionCount, 0);
      expect(rows.map((row) => row['text']), [
        'decoded text',
        'already text',
        null,
      ]);
    },
  );

  test('is idempotent after text has been enriched', () async {
    await _insertImportMessage(
      importDatabase,
      sourceRowId: 100,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final enricher = MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importDatabase: importDatabase,
      extractor: const _FakeExtractor(<int, String>{100: 'decoded text'}),
    );

    final first = await enricher.enrichMissingText();
    final second = await enricher.enrichMissingText();

    expect(first.enrichedMessageCount, 1);
    expect(second.candidateMessageCount, 0);
    expect(second.enrichedMessageCount, 0);
  });

  test('reports unavailable extractor without mutating rows', () async {
    await _insertImportMessage(
      importDatabase,
      sourceRowId: 100,
      text: null,
      attributedBodyBlob: Uint8List.fromList(<int>[1, 2, 3]),
    );

    final result = await MessageRichTextEnricher(
      chatDbPath: '/fake/chat.db',
      importDatabase: importDatabase,
      extractor: const _FakeExtractor(<int, String>{
        100: 'decoded',
      }, available: false),
    ).enrichMissingText();
    final rows = await importDatabase.database.query('messages');

    expect(result.extractorAvailable, isFalse);
    expect(result.candidateMessageCount, 1);
    expect(result.enrichedMessageCount, 0);
    expect(rows.single['text'], isNull);
  });
}

class _FakeExtractor implements MessageExtractorPort {
  const _FakeExtractor(this.extracted, {this.available = true});

  final Map<int, String> extracted;
  final bool available;

  @override
  Future<Map<int, String>> extractAllMessageTexts({
    int? limit,
    String? dbPath,
  }) async {
    return extracted;
  }

  @override
  Future<bool> isAvailable() async {
    return available;
  }
}

Future<void> _insertImportMessage(
  ImportDatabase importDatabase, {
  required int sourceRowId,
  required String? text,
  Uint8List? attributedBodyBlob,
}) async {
  final batchId = await importDatabase.insertImportBatch(
    sourceId: liveChatDbSourceId,
    startedAtUtc: DateTime.now().toUtc().toIso8601String(),
  );
  await importDatabase.database.insert('messages', <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': 'message-$sourceRowId',
    'is_from_me': 0,
    'text': text,
    'attributed_body_blob': attributedBodyBlob,
    'batch_id': batchId,
  });
}
