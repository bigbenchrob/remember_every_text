import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../debug/contact_timeline_scroll_probe.dart';
import '../shared/hydration/attachment_info.dart';
import '../shared/hydration/attachment_info_loader.dart';
import '../shared/hydration/messages_for_handle_provider.dart';

class MessageRowMapper {
  MessageRowMapper(this._db, this._displayNameOverrides, {required Ref ref})
    : _ref = ref;

  final WorkingDatabase _db;
  final Map<int, String> _displayNameOverrides;
  final Ref _ref;

  Future<List<MessageListItem>> mapRows(List<drift.TypedResult> rows) async {
    if (rows.isEmpty) {
      return const [];
    }

    ContactTimelineScrollProbe.count('message_row_mapper.calls');
    ContactTimelineScrollProbe.count(
      'message_row_mapper.rows',
      by: rows.length,
    );

    final results = <MessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(_db.workingMessages);
      final participant = row.readTableOrNull(_db.workingParticipants);

      final rawAttachments = message.hasAttachments
          ? await ContactTimelineScrollProbe.traceAsync(
              'message_row_mapper.attachments.load',
              () => loadAttachmentsForMessage(_db, message.guid),
            )
          : <AttachmentInfo>[];
      final attachments = rawAttachments.isEmpty
          ? rawAttachments
          : await ContactTimelineScrollProbe.traceAsync(
              'message_row_mapper.attachments.resolve',
              () => resolveAttachmentsForDisplay(
                ref: _ref,
                attachments: rawAttachments,
              ),
            );

      results.add(
        MessageListItem(
          id: message.id,
          chatId: message.chatId,
          guid: message.guid,
          isFromMe: message.isFromMe,
          senderName: _senderNameForMessage(
            isFromMe: message.isFromMe,
            participant: participant,
          ),
          text: message.textContent ?? '',
          sentAt: _parseUtc(message.sentAtUtc),
          hasAttachments: message.hasAttachments,
          attachments: attachments,
        ),
      );
    }

    return results;
  }

  DateTime? _parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toLocal();
  }

  String _senderNameForMessage({
    required bool isFromMe,
    required WorkingParticipant? participant,
  }) {
    if (isFromMe) {
      return 'You';
    }
    if (participant == null) {
      return 'Unknown sender';
    }
    final override = _displayNameOverrides[participant.id];
    if (override != null) {
      return override;
    }
    return participant.displayName;
  }
}
