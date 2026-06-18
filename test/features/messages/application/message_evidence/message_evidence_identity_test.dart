import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_identity.dart';

void main() {
  test('canonicalMessageEvidenceId resolves retained rowid to graph id', () {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    expect(canonicalMessageEvidenceId(42), messageSsId);
  });

  test('canonicalMessageEvidenceId preserves existing graph id', () {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: 42,
    );

    expect(canonicalMessageEvidenceId(messageSsId), messageSsId);
  });

  test('canonicalMessageEvidenceId preserves non-live graph ids', () {
    final archiveMessageSsId = SourceScopedRowKey.pack(
      sourceId: 99,
      sourceRowId: 42,
    );

    expect(canonicalMessageEvidenceId(archiveMessageSsId), archiveMessageSsId);
  });

  test('canonicalMessageEvidenceId preserves invalid retained rowids', () {
    const invalidRetainedRowId = SourceScopedRowKey.maxSourceRowId + 1;

    expect(
      canonicalMessageEvidenceId(invalidRetainedRowId),
      invalidRetainedRowId,
    );
  });
}
