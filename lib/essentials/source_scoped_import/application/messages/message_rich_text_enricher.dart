import '../../../db_importers/domain/ports/message_extractor_port.dart';
import '../../infrastructure/import_database_provider.dart';

class MessageRichTextEnrichmentResult {
  const MessageRichTextEnrichmentResult({
    required this.candidateMessageCount,
    required this.enrichedMessageCount,
    required this.missingExtractionCount,
    required this.extractorAvailable,
  });

  final int candidateMessageCount;
  final int enrichedMessageCount;
  final int missingExtractionCount;
  final bool extractorAvailable;
}

class MessageRichTextEnricher {
  const MessageRichTextEnricher({
    required this.chatDbPath,
    required this.importDatabase,
    required this.extractor,
    this.extractionLimit = 200000,
  });

  final String chatDbPath;
  final ImportDatabase importDatabase;
  final MessageExtractorPort extractor;
  final int extractionLimit;

  Future<MessageRichTextEnrichmentResult> enrichMissingText() async {
    return _enrichMissingTextWhere(
      whereClause: 'text IS NULL AND attributed_body_blob IS NOT NULL',
      whereArgs: const <Object?>[],
    );
  }

  Future<MessageRichTextEnrichmentResult> enrichMissingTextAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return _enrichMissingTextWhere(
      whereClause:
          'source_id = ? AND source_rowid > ? '
          'AND text IS NULL AND attributed_body_blob IS NOT NULL',
      whereArgs: <Object?>[sourceId, startedAfterSourceRowId],
    );
  }

  Future<MessageRichTextEnrichmentResult> _enrichMissingTextWhere({
    required String whereClause,
    required List<Object?> whereArgs,
  }) async {
    final candidates = await importDatabase.database.query(
      'messages',
      columns: <String>['ss_id', 'source_rowid'],
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'source_rowid ASC',
    );

    if (candidates.isEmpty) {
      return const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      );
    }

    final extractorAvailable = await extractor.isAvailable();
    if (!extractorAvailable) {
      return MessageRichTextEnrichmentResult(
        candidateMessageCount: candidates.length,
        enrichedMessageCount: 0,
        missingExtractionCount: candidates.length,
        extractorAvailable: false,
      );
    }

    final extracted = await extractor.extractAllMessageTexts(
      limit: extractionLimit,
      dbPath: chatDbPath,
    );

    var enrichedMessageCount = 0;
    var missingExtractionCount = 0;
    await importDatabase.database.transaction((txn) async {
      for (final candidate in candidates) {
        final sourceRowId = _readRequiredInt(candidate, 'source_rowid');
        final ssId = _readRequiredInt(candidate, 'ss_id');
        final normalized = extracted[sourceRowId]?.trim();
        if (normalized == null || normalized.isEmpty) {
          missingExtractionCount += 1;
          continue;
        }
        final updated = await txn.update(
          'messages',
          <String, Object?>{'text': normalized},
          where: 'ss_id = ? AND text IS NULL',
          whereArgs: <Object?>[ssId],
        );
        if (updated > 0) {
          enrichedMessageCount += 1;
        }
      }
    });

    return MessageRichTextEnrichmentResult(
      candidateMessageCount: candidates.length,
      enrichedMessageCount: enrichedMessageCount,
      missingExtractionCount: missingExtractionCount,
      extractorAvailable: true,
    );
  }

  static int _readRequiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw StateError('messages.$field is required');
  }
}
