import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_evidence.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_identity.dart';

void main() {
  group('RecoveredMessageEvidenceRepository graph contract', () {
    test(
      'returns recovered-only rows and excludes graph-projectable rows',
      () async {
        final repository = _InMemoryGraphRecoveredMessageEvidenceRepository([
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 42,
              guid: 'recovered-guid',
              hasConversationTopology: false,
            ),
            text: 'orphan row',
            sentAt: DateTime.utc(2026, 5, 20, 10),
          ),
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 43,
              guid: 'ordinary-guid',
              hasConversationTopology: true,
            ),
            text: 'ordinary graph row',
            sentAt: DateTime.utc(2026, 5, 20, 11),
          ),
        ]);

        final messages = await repository.watchMessages().first;

        expect(messages.map((message) => message.id), [
          SourceScopedRowKey.pack(
            sourceId: liveChatDbSourceId,
            sourceRowId: 42,
          ),
        ]);
        expect(messages.single.text, 'orphan row');
      },
    );

    test('keeps overlapping live and archive ROWIDs distinct', () async {
      const archiveSourceId = 101;
      final repository = _InMemoryGraphRecoveredMessageEvidenceRepository([
        _RecoveredSourceRecord(
          identity: const RecoveredMessageIdentity(
            sourceId: liveChatDbSourceId,
            sourceMessageRowId: 42,
            guid: 'same-guid',
            hasConversationTopology: false,
          ),
          text: 'live occurrence',
          sentAt: DateTime.utc(2026, 5, 20, 10),
        ),
        _RecoveredSourceRecord(
          identity: const RecoveredMessageIdentity(
            sourceId: archiveSourceId,
            sourceMessageRowId: 42,
            guid: 'same-guid',
            hasConversationTopology: false,
          ),
          text: 'archive occurrence',
          sentAt: DateTime.utc(2012, 5, 20, 10),
        ),
      ]);

      final messages = await repository.watchMessages().first;

      expect(messages, hasLength(2));
      expect(messages.first.id, isNot(messages.last.id));
      expect(messages.map((message) => message.guid).toSet(), {'same-guid'});
      expect(
        messages.map(
          (message) => SourceScopedRowKey.unpackSourceRowId(message.id),
        ),
        [42, 42],
      );
    });

    test(
      'contact scope includes direct and nearby no-handle outgoing rows',
      () async {
        final repository = _InMemoryGraphRecoveredMessageEvidenceRepository([
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 10,
              guid: 'direct',
              hasConversationTopology: false,
            ),
            senderHandleId: 11,
            text: 'direct incoming',
            sentAt: DateTime.utc(2026, 5, 20, 10),
          ),
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 11,
              guid: 'inferred',
              hasConversationTopology: false,
            ),
            isFromMe: true,
            text: 'nearby outgoing',
            sentAt: DateTime.utc(2026, 5, 20, 10, 3),
          ),
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 12,
              guid: 'other',
              hasConversationTopology: false,
            ),
            senderHandleId: 12,
            text: 'other incoming',
            sentAt: DateTime.utc(2026, 5, 20, 10, 2),
          ),
        ]);

        final messages = await repository
            .watchMessages(contactId: 24, scopedHandleIds: const {11})
            .first;

        expect(messages.map((message) => message.guid), ['direct', 'inferred']);
        expect(messages.first.isInferred, isFalse);
        expect(messages.last.isInferred, isTrue);
      },
    );

    test(
      'does not suppress sparse or attachment-only recovered evidence',
      () async {
        final repository = _InMemoryGraphRecoveredMessageEvidenceRepository([
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 50,
              guid: 'sparse',
              hasConversationTopology: false,
            ),
            text: null,
            semanticKind: 'sparse-artifact',
            itemType: 'unknown',
            isSparseArtifact: true,
            sentAt: DateTime.utc(2026, 5, 20, 10),
          ),
          _RecoveredSourceRecord(
            identity: const RecoveredMessageIdentity(
              sourceId: liveChatDbSourceId,
              sourceMessageRowId: 51,
              guid: 'attachment-only',
              hasConversationTopology: false,
            ),
            text: null,
            semanticKind: 'attachment-only',
            itemType: 'attachment-only',
            attachments: const [
              AttachmentInfo(
                id: 1,
                localPath: null,
                mimeType: null,
                transferName: 'photo.jpg',
              ),
            ],
            sentAt: DateTime.utc(2026, 5, 20, 11),
          ),
        ]);

        final messages = await repository.watchMessages().first;

        expect(messages.map((message) => message.guid), [
          'sparse',
          'attachment-only',
        ]);
        expect(messages.first.text, '(Sparse artifact: no preserved text)');
        expect(messages.last.text, '(No text content)');
        expect(messages.last.attachmentCount, 1);
      },
    );
  });
}

class _InMemoryGraphRecoveredMessageEvidenceRepository
    implements RecoveredMessageEvidenceRepository {
  const _InMemoryGraphRecoveredMessageEvidenceRepository(this.records);

  final List<_RecoveredSourceRecord> records;

  @override
  Stream<List<RecoveredUnlinkedMessageItem>> watchMessages({
    int? contactId,
    Set<int>? scopedHandleIds,
  }) async* {
    final recoveredRecords =
        records
            .where((record) => record.identity.isRecoveredEvidenceOnly)
            .toList(growable: false)
          ..sort((a, b) {
            final aDate = a.sentAt;
            final bDate = b.sentAt;
            if (aDate == null && bDate == null) {
              return a.identity.messageSsId.compareTo(b.identity.messageSsId);
            }
            if (aDate == null) {
              return -1;
            }
            if (bDate == null) {
              return 1;
            }
            final dateCompare = aDate.compareTo(bDate);
            if (dateCompare != 0) {
              return dateCompare;
            }
            return a.identity.messageSsId.compareTo(b.identity.messageSsId);
          });

    final scopedRecords = _scopeRecords(
      records: recoveredRecords,
      contactId: contactId,
      scopedHandleIds: scopedHandleIds,
    );

    yield [
      for (final record in scopedRecords)
        record.toRecoveredItem(
          isInferred: record.senderHandleId == null && record.isFromMe,
        ),
    ];
  }

  List<_RecoveredSourceRecord> _scopeRecords({
    required List<_RecoveredSourceRecord> records,
    required int? contactId,
    required Set<int>? scopedHandleIds,
  }) {
    if (contactId == null) {
      return records;
    }
    final handleIds = scopedHandleIds ?? const <int>{};
    final directMatches = records
        .where((record) {
          final senderHandleId = record.senderHandleId;
          return senderHandleId != null && handleIds.contains(senderHandleId);
        })
        .toList(growable: false);
    final anchors = [
      for (final record in directMatches)
        if (record.sentAt != null) record.sentAt!,
    ];

    return [
      for (final record in records)
        if (directMatches.contains(record) ||
            _isNearbyNoHandleOutgoing(record: record, anchors: anchors))
          record,
    ];
  }

  bool _isNearbyNoHandleOutgoing({
    required _RecoveredSourceRecord record,
    required List<DateTime> anchors,
  }) {
    if (!record.isFromMe || record.senderHandleId != null) {
      return false;
    }
    final sentAt = record.sentAt;
    if (sentAt == null) {
      return false;
    }
    const inferenceWindow = Duration(minutes: 5);
    return anchors.any((anchor) {
      return sentAt.difference(anchor).abs() <= inferenceWindow;
    });
  }
}

class _RecoveredSourceRecord {
  const _RecoveredSourceRecord({
    required this.identity,
    required this.sentAt,
    this.senderHandleId,
    this.isFromMe = false,
    this.text,
    this.semanticKind = 'plain-text',
    this.itemType = 'text',
    this.isSparseArtifact = false,
    this.attachments = const <AttachmentInfo>[],
  });

  final RecoveredMessageIdentity identity;
  final int? senderHandleId;
  final bool isFromMe;
  final String? text;
  final DateTime? sentAt;
  final String semanticKind;
  final String itemType;
  final bool isSparseArtifact;
  final List<AttachmentInfo> attachments;

  RecoveredUnlinkedMessageItem toRecoveredItem({required bool isInferred}) {
    return RecoveredUnlinkedMessageItem(
      id: identity.messageSsId,
      guid: identity.guid,
      senderHandleId: senderHandleId,
      rawItemType: null,
      rawAssociatedMessageType: null,
      semanticKind: semanticKind,
      isSparseArtifact: isSparseArtifact,
      isFromMe: isFromMe,
      isInferred: isInferred,
      senderLabel: isFromMe ? 'You' : 'Unknown Sender',
      service: 'iMessage',
      text: _textOrFallback(),
      sentAt: sentAt,
      itemType: itemType,
      hasAttachments: attachments.isNotEmpty,
      attachmentCount: attachments.length,
      attachments: attachments,
    );
  }

  String _textOrFallback() {
    final normalized = text?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return switch (semanticKind) {
      'sparse-artifact' => '(Sparse artifact: no preserved text)',
      'attachment-only' => '(No text content)',
      _ => '(No preserved content)',
    };
  }
}
