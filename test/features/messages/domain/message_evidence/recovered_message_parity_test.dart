import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_evidence.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_parity.dart';

void main() {
  group('compareRecoveredMessageEvidence', () {
    test(
      'classifies matched, projectable, legacy-only, and graph-only rows',
      () {
        final matchedGraphId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 10,
        );
        final projectableGraphId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 11,
        );
        final graphOnlyId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 12,
        );

        final report = compareRecoveredMessageEvidence(
          legacyRecoveredSourceId: liveChatDbSourceId,
          legacyMessages: [
            _message(id: 10, guid: 'matched', text: 'same', attachments: 1),
            _message(id: 11, guid: 'projectable', text: 'now linked'),
            _message(id: 13, guid: 'legacy-only', text: 'legacy retained'),
          ],
          graphRecoveredMessages: [
            _message(
              id: matchedGraphId,
              guid: 'matched',
              text: 'same',
              attachments: 1,
            ),
            _message(id: graphOnlyId, guid: 'graph-only', text: 'new orphan'),
          ],
          graphProjectableMessageIds: {projectableGraphId},
        );

        expect(report.legacyCount, 3);
        expect(report.graphRecoveredCount, 2);
        expect(report.matchedRecoveredCount, 1);
        expect(report.legacyNowProjectableCount, 1);
        expect(report.legacyOnlyCount, 1);
        expect(report.suppressedLegacyOnlyCount, 0);
        expect(report.unresolvedLegacyOnlyCount, 1);
        expect(report.graphOnlyCount, 1);
        expect(report.hasLegacyOnlyRows, isTrue);
        expect(report.hasUnresolvedLegacyOnlyRows, isTrue);
        expect(report.canCutOverWithoutEvidenceLoss, isFalse);
        expect(report.requiresCompatibilityRetention, isTrue);
        expect(report.hasEvidenceMismatches, isFalse);
        expect(report.legacyOnlySamples.single.guid, 'legacy-only');
        expect(report.graphOnlySamples.single.guid, 'graph-only');
        expect(report.nowProjectableSamples.single.guid, 'projectable');
      },
    );

    test('flags evidence mismatches for matched recovered rows', () {
      final matchedGraphId = SourceScopedRowKey.pack(
        sourceId: liveChatDbSourceId,
        sourceRowId: 10,
      );

      final report = compareRecoveredMessageEvidence(
        legacyRecoveredSourceId: liveChatDbSourceId,
        legacyMessages: [
          _message(id: 10, guid: 'legacy-guid', text: 'legacy', attachments: 2),
        ],
        graphRecoveredMessages: [
          _message(
            id: matchedGraphId,
            guid: 'graph-guid',
            text: 'graph',
            attachments: 1,
          ),
        ],
        graphProjectableMessageIds: const <int>{},
      );

      expect(report.matchedRecoveredCount, 1);
      expect(report.attachmentCountMismatchCount, 1);
      expect(report.guidMismatchCount, 1);
      expect(report.textMismatchCount, 1);
      expect(report.hasEvidenceMismatches, isTrue);
      expect(report.canCutOverWithoutEvidenceLoss, isFalse);
    });

    test(
      'does not treat known suppressed legacy-only rows as cutover blockers',
      () {
        final report = compareRecoveredMessageEvidence(
          legacyRecoveredSourceId: liveChatDbSourceId,
          legacyMessages: [
            _message(id: 13, guid: 'dismissed', text: 'user dismissed'),
          ],
          graphRecoveredMessages: const [],
          graphProjectableMessageIds: const <int>{},
          suppressedLegacyMessageIds: const {13},
        );

        expect(report.legacyOnlyCount, 1);
        expect(report.suppressedLegacyOnlyCount, 1);
        expect(report.unresolvedLegacyOnlyCount, 0);
        expect(report.hasLegacyOnlyRows, isTrue);
        expect(report.hasUnresolvedLegacyOnlyRows, isFalse);
        expect(report.canCutOverWithoutEvidenceLoss, isTrue);
        expect(report.requiresCompatibilityRetention, isFalse);
      },
    );

    test(
      'allows cutover only when there are no legacy-only rows or mismatches',
      () {
        final matchedGraphId = SourceScopedRowKey.pack(
          sourceId: liveChatDbSourceId,
          sourceRowId: 10,
        );

        final report = compareRecoveredMessageEvidence(
          legacyRecoveredSourceId: liveChatDbSourceId,
          legacyMessages: [_message(id: 10, guid: 'matched', text: 'same')],
          graphRecoveredMessages: [
            _message(id: matchedGraphId, guid: 'matched', text: 'same'),
          ],
          graphProjectableMessageIds: const <int>{},
        );

        expect(report.canCutOverWithoutEvidenceLoss, isTrue);
        expect(report.requiresCompatibilityRetention, isFalse);
      },
    );
  });
}

RecoveredUnlinkedMessageItem _message({
  required int id,
  required String guid,
  required String text,
  int attachments = 0,
}) {
  return RecoveredUnlinkedMessageItem(
    id: id,
    guid: guid,
    senderHandleId: null,
    semanticKind: 'plain-text',
    isSparseArtifact: false,
    isFromMe: false,
    isInferred: false,
    senderLabel: 'Unknown Sender',
    service: 'iMessage',
    text: text,
    sentAt: DateTime.utc(2026, 5, 31),
    itemType: 'text',
    hasAttachments: attachments > 0,
    attachmentCount: attachments,
    attachments: const [],
  );
}
