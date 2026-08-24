import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_import_anomaly_counts.dart';

void main() {
  test('round-trips exact domain totals without source payload', () {
    const counts = SourceImportAnomalyCounts(
      preservedUnnormalizedHandleCount: 1,
      messageTimestampUnavailableCount: 2,
      recoveredUnlinkedMessageCount: 3,
      richTextDecodeUnavailableCount: 4,
      attachmentMetadataDegradedCount: 5,
      unresolvedReactionTargetCount: 6,
      omittedContactRecordCount: 7,
      contactEnrichmentUnavailableCount: 8,
      omittedContactChannelCount: 9,
      omittedChatMessageRelationshipCount: 10,
      omittedChatHandleRelationshipCount: 11,
      omittedMessageAttachmentRelationshipCount: 12,
    );

    final restored = SourceImportAnomalyCounts.fromJson(counts.toJson());

    expect(restored, counts);
    expect(restored.totalCount, 78);
    expect(restored.toJson().toString(), isNot(contains('message text')));
  });

  test('mergeMaximum coalesces repeated progress without double counting', () {
    const earlier = SourceImportAnomalyCounts(
      recoveredUnlinkedMessageCount: 2,
      omittedContactChannelCount: 4,
    );
    const later = SourceImportAnomalyCounts(
      recoveredUnlinkedMessageCount: 5,
      omittedContactChannelCount: 3,
    );

    final merged = earlier.mergeMaximum(later);

    expect(merged.recoveredUnlinkedMessageCount, 5);
    expect(merged.omittedContactChannelCount, 4);
  });
}
