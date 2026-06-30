import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_graph_build_service_provider.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';

void main() {
  test(
    'uses full rich text enrichment when no messages were imported',
    () async {
      var fullCallCount = 0;
      var boundedCallCount = 0;

      final result = await runGraphBuildRichTextEnrichment(
        messageImportResult: const MessageImportResult(
          startedAfterSourceRowId: 100,
          insertedMessageCount: 0,
          lastImportedSourceRowId: 100,
        ),
        enrichAllMissingText: () async {
          fullCallCount += 1;
          return const MessageRichTextEnrichmentResult(
            candidateMessageCount: 3,
            enrichedMessageCount: 1,
            missingExtractionCount: 2,
            extractorAvailable: true,
          );
        },
        enrichMissingTextAfterSourceRowId:
            ({required sourceId, required startedAfterSourceRowId}) async {
              boundedCallCount += 1;
              return const MessageRichTextEnrichmentResult(
                candidateMessageCount: 0,
                enrichedMessageCount: 0,
                missingExtractionCount: 0,
                extractorAvailable: true,
              );
            },
      );

      expect(fullCallCount, 1);
      expect(boundedCallCount, 0);
      expect(result.enrichedMessageCount, 1);
    },
  );

  test(
    'uses bounded rich text enrichment for newly imported messages',
    () async {
      var fullCallCount = 0;
      var boundedCallCount = 0;
      int? capturedSourceId;
      int? capturedStartedAfterSourceRowId;

      final result = await runGraphBuildRichTextEnrichment(
        messageImportResult: const MessageImportResult(
          startedAfterSourceRowId: 100,
          insertedMessageCount: 1,
          lastImportedSourceRowId: 101,
        ),
        enrichAllMissingText: () async {
          fullCallCount += 1;
          return const MessageRichTextEnrichmentResult(
            candidateMessageCount: 0,
            enrichedMessageCount: 0,
            missingExtractionCount: 0,
            extractorAvailable: true,
          );
        },
        enrichMissingTextAfterSourceRowId:
            ({required sourceId, required startedAfterSourceRowId}) async {
              boundedCallCount += 1;
              capturedSourceId = sourceId;
              capturedStartedAfterSourceRowId = startedAfterSourceRowId;
              return const MessageRichTextEnrichmentResult(
                candidateMessageCount: 1,
                enrichedMessageCount: 1,
                missingExtractionCount: 0,
                extractorAvailable: true,
              );
            },
      );

      expect(fullCallCount, 0);
      expect(boundedCallCount, 1);
      expect(capturedSourceId, liveChatDbSourceId);
      expect(capturedStartedAfterSourceRowId, 100);
      expect(result.enrichedMessageCount, 1);
    },
  );
}
