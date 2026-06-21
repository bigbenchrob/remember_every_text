import '../../../../essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import '../../../../essentials/db/shared/handle_identifier_utils.dart';
import '../../../contacts/feature_level_providers.dart'
    show DisplayIdentityResolver;
import '../../domain/entities/attachment_info.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';

/// Graph-backed recovered deleted-message evidence repository.
///
/// This is the production source-scoped replacement for retired recovered
/// message compatibility reads. Recovered evidence is defined as
/// imported graph messages that have no current `chat_to_message` conversation
/// edge.
class GraphRecoveredMessageEvidenceRepository
    implements RecoveredMessageEvidenceRepository {
  const GraphRecoveredMessageEvidenceRepository({
    required this.graphDb,
    required DisplayIdentityResolver displayIdentityResolver,
  }) : _displayIdentityResolver = displayIdentityResolver;

  final ConversationGraphDatabase graphDb;
  final DisplayIdentityResolver _displayIdentityResolver;

  @override
  Stream<List<RecoveredUnlinkedMessageItem>> watchMessages({
    int? contactId,
    Set<int>? scopedHandleIds,
  }) async* {
    final candidates = await _readRecoveredCandidates();
    final scopedCandidates = _scopeCandidates(
      candidates: candidates,
      contactId: contactId,
      scopedHandleIds: scopedHandleIds,
    );

    yield [
      for (final candidate in scopedCandidates)
        candidate.item.copyWithInferred(
          isInferred: candidate.isDirectMatch
              ? candidate.item.isInferred
              : candidate.item.isFromMe &&
                    candidate.item.senderHandleId == null,
        ),
    ];
  }

  Future<List<_RecoveredGraphCandidate>> _readRecoveredCandidates() async {
    final rows = await graphDb.selectRows('''
      SELECT
        m.ss_id AS message_id,
        m.guid,
        m.sender_handle_ss_id,
        m.sender_canonical_handle_ss_id,
        m.is_from_me,
        m.date_utc,
        m.text,
        m.semantic_kind,
        m.item_kind,
        m.is_sparse_artifact,
        m.error_code,
        COALESCE(sender_canonical.display_handle, sender_handle.id)
          AS sender_display_handle,
        COALESCE(sender_canonical.service, sender_handle.service, '')
          AS service,
        contact.contact_id AS contact_id,
        contact.display_name AS contact_name,
        (
          SELECT COUNT(*)
          FROM message_to_attachment mta
          WHERE mta.message_ss_id = m.ss_id
        ) AS attachment_count
      FROM messages m
      LEFT JOIN chat_to_message ctm ON ctm.message_ss_id = m.ss_id
      LEFT JOIN handles sender_handle ON sender_handle.ss_id =
        m.sender_handle_ss_id
      LEFT JOIN canonical_handles sender_canonical
        ON sender_canonical.canonical_handle_ss_id =
          m.sender_canonical_handle_ss_id
      LEFT JOIN contact_to_handle cth
        ON cth.handle_ss_id = COALESCE(
          m.sender_canonical_handle_ss_id,
          m.sender_handle_ss_id
        )
      LEFT JOIN contacts contact ON contact.contact_id = cth.contact_id
      WHERE ctm.message_ss_id IS NULL
      ORDER BY COALESCE(m.date_utc, '') ASC, m.ss_id ASC
      ''');

    final candidates = <_RecoveredGraphCandidate>[];
    for (final row in rows) {
      final messageId = _readInt(row['message_id']);
      final attachments = await _readAttachmentsForMessage(messageId);
      final semanticKindRaw = (row['semantic_kind'] as String?)?.trim();
      final semanticKind = semanticKindRaw != null && semanticKindRaw.isNotEmpty
          ? semanticKindRaw
          : 'unknown-variant';
      final itemKindRaw = (row['item_kind'] as String?)?.trim();
      final itemKind = itemKindRaw != null && itemKindRaw.isNotEmpty
          ? itemKindRaw
          : 'unknown';
      final senderHandleId = _readNullableInt(row['sender_handle_ss_id']);
      final senderCanonicalHandleId = _readNullableInt(
        row['sender_canonical_handle_ss_id'],
      );
      final rawSenderLabel =
          (row['sender_display_handle'] as String?)?.trim() ?? '';
      final isFromMe = _readBool(row['is_from_me']);
      final contactName = _contactDisplayName(row);

      candidates.add(
        _RecoveredGraphCandidate(
          item: RecoveredUnlinkedMessageItem(
            id: messageId,
            guid: (row['guid'] as String?)?.trim() ?? '',
            senderHandleId: senderHandleId,
            contactName: contactName == null || contactName.isEmpty
                ? null
                : contactName,
            rawItemType: null,
            rawAssociatedMessageType: null,
            semanticKind: semanticKind,
            isSparseArtifact: _readBool(row['is_sparse_artifact']),
            isFromMe: isFromMe,
            isInferred: false,
            senderLabel: isFromMe
                ? 'You'
                : rawSenderLabel.isNotEmpty
                ? formatPhoneNumberForDisplay(rawSenderLabel)
                : 'Unknown Sender',
            service: (row['service'] as String?)?.trim() ?? '',
            text: _textOrFallback(
              text: row['text'] as String?,
              semanticKind: semanticKind,
            ),
            sentAt: _parseUtc(row['date_utc'] as String?),
            itemType: itemKind,
            hasAttachments: attachments.isNotEmpty,
            attachmentCount: attachments.length,
            attachments: attachments,
          ),
          canonicalHandleId: senderCanonicalHandleId,
          isDirectMatch: false,
        ),
      );
    }

    return candidates;
  }

  Future<List<AttachmentInfo>> _readAttachmentsForMessage(int messageId) async {
    final rows = await graphDb.selectRows(
      '''
      SELECT
        a.ss_id,
        a.guid,
        a.filename,
        a.transfer_name,
        a.mime_type
      FROM message_to_attachment mta
      JOIN attachments a ON a.ss_id = mta.attachment_ss_id
      WHERE mta.message_ss_id = ?
      ORDER BY a.ss_id ASC
      ''',
      <Object?>[messageId],
    );

    return [
      for (final row in rows)
        AttachmentInfo(
          id: _readInt(row['ss_id']),
          localPath: row['filename'] as String?,
          mimeType: row['mime_type'] as String?,
          transferName: _attachmentDisplayName(row),
        ),
    ];
  }

  List<_RecoveredGraphCandidate> _scopeCandidates({
    required List<_RecoveredGraphCandidate> candidates,
    required int? contactId,
    required Set<int>? scopedHandleIds,
  }) {
    if (contactId == null) {
      return candidates;
    }

    final handleIds = scopedHandleIds ?? const <int>{};
    final directMatches = candidates
        .where((candidate) {
          final item = candidate.item;
          return _handleMatches(
            handleIds: handleIds,
            senderHandleId: item.senderHandleId,
            canonicalHandleId: candidate.canonicalHandleId,
          );
        })
        .toList(growable: false);
    final anchorTimes = [
      for (final candidate in directMatches)
        if (candidate.item.sentAt != null)
          candidate.item.sentAt!.millisecondsSinceEpoch,
    ]..sort();

    return [
      for (final candidate in candidates)
        if (directMatches.contains(candidate))
          candidate.copyWith(isDirectMatch: true)
        else if (_shouldInferForScopedContact(
          item: candidate.item,
          sortedAnchorMillis: anchorTimes,
        ))
          candidate,
    ];
  }

  String? _contactDisplayName(Map<String, Object?> row) {
    final contactId = _readNullableInt(row['contact_id']);
    if (contactId != null) {
      final identity = _displayIdentityResolver.resolveContact(contactId);
      if (identity.isKnownContact && identity.primaryLabel.trim().isNotEmpty) {
        return identity.primaryLabel.trim();
      }
    }

    final importedName = (row['contact_name'] as String?)?.trim();
    if (importedName == null || importedName.isEmpty) {
      return null;
    }
    return importedName;
  }
}

extension on RecoveredUnlinkedMessageItem {
  RecoveredUnlinkedMessageItem copyWithInferred({required bool isInferred}) {
    if (this.isInferred == isInferred) {
      return this;
    }
    return RecoveredUnlinkedMessageItem(
      id: id,
      guid: guid,
      senderHandleId: senderHandleId,
      contactName: contactName,
      rawItemType: rawItemType,
      rawAssociatedMessageType: rawAssociatedMessageType,
      semanticKind: semanticKind,
      isSparseArtifact: isSparseArtifact,
      isFromMe: isFromMe,
      isInferred: isInferred,
      senderLabel: senderLabel,
      service: service,
      text: text,
      sentAt: sentAt,
      itemType: itemType,
      hasAttachments: hasAttachments,
      attachmentCount: attachmentCount,
      attachments: attachments,
    );
  }
}

class _RecoveredGraphCandidate {
  const _RecoveredGraphCandidate({
    required this.item,
    required this.canonicalHandleId,
    required this.isDirectMatch,
  });

  final RecoveredUnlinkedMessageItem item;
  final int? canonicalHandleId;
  final bool isDirectMatch;

  _RecoveredGraphCandidate copyWith({required bool isDirectMatch}) {
    return _RecoveredGraphCandidate(
      item: item,
      canonicalHandleId: canonicalHandleId,
      isDirectMatch: isDirectMatch,
    );
  }
}

bool _handleMatches({
  required Set<int> handleIds,
  required int? senderHandleId,
  required int? canonicalHandleId,
}) {
  return (senderHandleId != null && handleIds.contains(senderHandleId)) ||
      (canonicalHandleId != null && handleIds.contains(canonicalHandleId));
}

bool _shouldInferForScopedContact({
  required RecoveredUnlinkedMessageItem item,
  required List<int> sortedAnchorMillis,
}) {
  if (!item.isFromMe || item.senderHandleId != null) {
    return false;
  }
  final sentAt = item.sentAt;
  if (sentAt == null || sortedAnchorMillis.isEmpty) {
    return false;
  }

  return _isWithinInferenceWindow(
    targetMillis: sentAt.millisecondsSinceEpoch,
    sortedAnchorMillis: sortedAnchorMillis,
  );
}

bool _isWithinInferenceWindow({
  required int targetMillis,
  required List<int> sortedAnchorMillis,
}) {
  const inferenceWindow = Duration(minutes: 5);
  final maxDeltaMillis = inferenceWindow.inMilliseconds;

  var low = 0;
  var high = sortedAnchorMillis.length;

  while (low < high) {
    final mid = low + ((high - low) ~/ 2);
    if (sortedAnchorMillis[mid] < targetMillis) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }

  if (low < sortedAnchorMillis.length &&
      (sortedAnchorMillis[low] - targetMillis).abs() <= maxDeltaMillis) {
    return true;
  }

  if (low > 0 &&
      (sortedAnchorMillis[low - 1] - targetMillis).abs() <= maxDeltaMillis) {
    return true;
  }

  return false;
}

String _textOrFallback({required String? text, required String semanticKind}) {
  final normalized = text?.trim();
  if (normalized != null && normalized.isNotEmpty) {
    return normalized;
  }
  return switch (semanticKind) {
    'sparse-artifact' => '(Sparse artifact: no preserved text or payload)',
    'edited-or-unsent' => '(No plain text content; summary metadata preserved)',
    'balloon-or-app' =>
      '(No plain text content; app or balloon payload preserved)',
    'associated' => '(Associated message carrier without plain text)',
    'attachment-only' => '(No text content)',
    'rich-text' => '(No plain text content)',
    _ => '(No preserved content)',
  };
}

String? _attachmentDisplayName(Map<String, Object?> row) {
  final transferName = (row['transfer_name'] as String?)?.trim();
  if (transferName != null && transferName.isNotEmpty) {
    return transferName;
  }
  final filename = (row['filename'] as String?)?.trim();
  if (filename == null || filename.isEmpty) {
    return null;
  }
  return filename.split('/').last;
}

DateTime? _parseUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  return value.toString() == '1';
}

int? _readNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  return _readInt(value);
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is BigInt) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  return int.parse(value.toString());
}
