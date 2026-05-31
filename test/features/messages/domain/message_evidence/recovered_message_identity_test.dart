import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_identity.dart';

void main() {
  group('RecoveredMessageIdentity', () {
    test('uses source-scoped message occurrence identity', () {
      const identity = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'message-guid',
        hasConversationTopology: false,
      );

      expect(
        identity.messageSsId,
        SourceScopedRowKey.pack(sourceId: liveChatDbSourceId, sourceRowId: 42),
      );
      expect(identity.isRecoveredEvidenceOnly, isTrue);
      expect(identity.canProjectToConversationGraph, isFalse);
    });

    test('same ROWID in different sources remains distinct', () {
      const archiveSourceId = 101;
      const live = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'same-guid',
        hasConversationTopology: false,
      );
      const archive = RecoveredMessageIdentity(
        sourceId: archiveSourceId,
        sourceMessageRowId: 42,
        guid: 'same-guid',
        hasConversationTopology: false,
      );

      expect(live.messageSsId, isNot(archive.messageSsId));
      expect(SourceScopedRowKey.unpackSourceRowId(live.messageSsId), 42);
      expect(SourceScopedRowKey.unpackSourceRowId(archive.messageSsId), 42);
      expect(
        SourceScopedRowKey.unpackSourceId(archive.messageSsId),
        archiveSourceId,
      );
    });

    test('guid does not participate in canonical identity', () {
      const first = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'first-guid',
        hasConversationTopology: false,
      );
      const second = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'second-guid',
        hasConversationTopology: false,
      );

      expect(first.messageSsId, second.messageSsId);
    });

    test('topology controls projection surface, not identity', () {
      const recoveredOnly = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'message-guid',
        hasConversationTopology: false,
      );
      const graphProjectable = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'message-guid',
        hasConversationTopology: true,
      );

      expect(recoveredOnly.messageSsId, graphProjectable.messageSsId);
      expect(recoveredOnly.isRecoveredEvidenceOnly, isTrue);
      expect(graphProjectable.canProjectToConversationGraph, isTrue);
    });

    test('stable evidence key is based on source-scoped identity', () {
      const identity = RecoveredMessageIdentity(
        sourceId: liveChatDbSourceId,
        sourceMessageRowId: 42,
        guid: 'message-guid',
        hasConversationTopology: false,
      );

      expect(
        identity.stableEvidenceKey,
        'recovered-message:${identity.messageSsId}',
      );
    });
  });
}
