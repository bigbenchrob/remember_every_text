import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../../../application/timeline/ordinal/message_timeline_scope_ordinal_extensions.dart';
import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../../../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import '../../../debug/contact_timeline_scroll_probe.dart';
import '../../shared/hydration/attachment_info.dart' as hydrated;
import '../../shared/hydration/messages_for_handle_provider.dart';
import '../../shared/message_row_mapper.dart';

part 'message_by_ordinal_provider.g.dart';

/// Unified provider to load a message by its ordinal position within a scope.
///
/// Works for all scopes (global, contact, chat) using the strategy pattern.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
@riverpod
Future<MessageListItem?> messageByTimelineOrdinal(
  MessageByTimelineOrdinalRef ref, {
  required MessageTimelineScope scope,
  required int ordinal,
}) async {
  ContactTimelineScrollProbe.count('provider.message_by_ordinal.recompute');

  return ContactTimelineScrollProbe.traceAsync(
    'provider.message_by_ordinal',
    () async {
      final strategy = await scope.resolveOrdinalStrategy(ref);

      ContactTimelineScrollProbe.count('ordinal_lookup.message_by_ordinal');
      final messageId = await ContactTimelineScrollProbe.traceAsync(
        'ordinal_lookup.message_by_ordinal',
        () => strategy.getMessageIdByOrdinal(ordinal),
      );
      if (messageId == null) {
        return null;
      }

      if (scope case RecoveredTimelineScope()) {
        return _loadRecoveredMessageById(
          ref: ref,
          scope: scope,
          messageId: messageId,
        );
      }

      final db = await ref.watch(driftWorkingDatabaseProvider.future);
      final overlayDb = await ref.watch(overlayDatabaseProvider.future);
      final nameOverrides = await displayNameOverridesMap(overlayDb);

      final query =
          db.select(db.workingMessages).join([
              drift.leftOuterJoin(
                db.handlesCanonical,
                db.handlesCanonical.id.equalsExp(
                  db.workingMessages.senderHandleId,
                ),
              ),
              drift.leftOuterJoin(
                db.handleToParticipant,
                db.handleToParticipant.handleId.equalsExp(
                  db.handlesCanonical.id,
                ),
              ),
              drift.leftOuterJoin(
                db.workingParticipants,
                db.workingParticipants.id.equalsExp(
                  db.handleToParticipant.participantId,
                ),
              ),
            ])
            ..where(db.workingMessages.id.equals(messageId))
            ..limit(1);

      final row = await ContactTimelineScrollProbe.traceAsync(
        'provider.message_by_ordinal.query',
        query.getSingleOrNull,
      );
      if (row == null) {
        return null;
      }

      final mapper = MessageRowMapper(db, overlayDb, nameOverrides, ref: ref);
      final messages = await ContactTimelineScrollProbe.traceAsync(
        'provider.message_by_ordinal.map_rows',
        () => mapper.mapRows([row]),
      );

      return messages.isEmpty ? null : messages.first;
    },
  );
}

Future<MessageListItem?> _loadRecoveredMessageById({
  required MessageByTimelineOrdinalRef ref,
  required MessageTimelineScope scope,
  required int messageId,
}) async {
  final recoveredMessages = await _loadRecoveredMessages(
    ref: ref,
    scope: scope,
  );
  final recoveredMessage = recoveredMessages.where((message) {
    return message.id == messageId;
  }).firstOrNull;
  if (recoveredMessage == null) {
    return null;
  }

  return MessageListItem(
    id: recoveredMessage.id,
    chatId: -recoveredMessage.id,
    guid: recoveredMessage.guid,
    isFromMe: recoveredMessage.isFromMe,
    senderName: _recoveredSenderName(recoveredMessage),
    text: recoveredMessage.text,
    sentAt: recoveredMessage.sentAt,
    hasAttachments: recoveredMessage.hasAttachments,
    isSaved: false,
    tags: const <String>[],
    attachments: recoveredMessage.attachments
        .map((attachment) {
          return hydrated.AttachmentInfo(
            id: attachment.id,
            localPath: attachment.localPath,
            mimeType: attachment.mimeType,
            transferName: attachment.transferName,
            mediaWidth: attachment.mediaWidth,
            mediaHeight: attachment.mediaHeight,
          );
        })
        .toList(growable: false),
  );
}

Future<List<RecoveredUnlinkedMessageItem>> _loadRecoveredMessages({
  required MessageByTimelineOrdinalRef ref,
  required MessageTimelineScope scope,
}) async {
  final recoveredScope = scope as RecoveredTimelineScope;
  final recoveredAsync = ref.watch(
    recoveredUnlinkedMessagesProvider(contactId: recoveredScope.contactId),
  );
  final recoveredMessages =
      recoveredAsync.valueOrNull ??
      await ref.watch(
        recoveredUnlinkedMessagesProvider(
          contactId: recoveredScope.contactId,
        ).future,
      ) ??
      const <RecoveredUnlinkedMessageItem>[];

  return filterRecoveredTimelineMessages(
    messages: recoveredMessages,
    onlyNoHandleFromMe: recoveredScope.onlyNoHandleFromMe,
  );
}

String _recoveredSenderName(RecoveredUnlinkedMessageItem message) {
  if (message.isFromMe) {
    return 'You';
  }

  final contactName = message.contactName?.trim();
  if (contactName != null && contactName.isNotEmpty) {
    return contactName;
  }

  final senderLabel = message.senderLabel.trim();
  if (senderLabel.isNotEmpty) {
    return senderLabel;
  }

  return 'Unknown sender';
}
