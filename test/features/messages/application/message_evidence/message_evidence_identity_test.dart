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
}
