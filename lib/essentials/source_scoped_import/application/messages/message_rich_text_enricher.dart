import 'dart:typed_data';

import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/message_extractor_port.dart';

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
    required this.importLedger,
    required this.extractor,
    this.extractionLimit = 200000,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final MessageExtractorPort extractor;
  final int extractionLimit;

  Future<MessageRichTextEnrichmentResult> enrichMissingText() async {
    return _enrichMissingText(sourceId: null, startedAfterSourceRowId: null);
  }

  Future<MessageRichTextEnrichmentResult> enrichMissingTextAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
  }) {
    return _enrichMissingText(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
  }

  Future<MessageRichTextEnrichmentResult> enrichMissingTextForSource({
    required int sourceId,
  }) {
    return _enrichMissingText(
      sourceId: sourceId,
      startedAfterSourceRowId: null,
    );
  }

  Future<MessageRichTextEnrichmentResult> _enrichMissingText({
    required int? sourceId,
    required int? startedAfterSourceRowId,
  }) async {
    final candidates = await importLedger.findMessagesNeedingTextEnrichment(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );

    if (candidates.isEmpty) {
      return const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      );
    }

    final extractorAvailable = await extractor.isBlobExtractionAvailable();
    if (!extractorAvailable) {
      return MessageRichTextEnrichmentResult(
        candidateMessageCount: candidates.length,
        enrichedMessageCount: 0,
        missingExtractionCount: candidates.length,
        extractorAvailable: false,
      );
    }

    final blobsBySourceRowId = <int, Uint8List>{};
    for (final candidate in candidates) {
      blobsBySourceRowId[candidate.sourceRowId] = candidate.attributedBodyBlob;
    }

    final extracted = await extractor.extractMessageTextsFromBlobs(
      blobsBySourceRowId,
    );

    var enrichedMessageCount = 0;
    var missingExtractionCount = 0;
    await importLedger.writeTransaction((txn) async {
      for (final candidate in candidates) {
        final normalized = extracted[candidate.sourceRowId]?.trim();
        if (normalized == null || normalized.isEmpty) {
          missingExtractionCount += 1;
          continue;
        }
        final updated = await txn.update(
          'messages',
          <String, Object?>{'text': normalized},
          where: 'ss_id = ? AND text IS NULL',
          whereArgs: <Object?>[candidate.ssId],
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
}
