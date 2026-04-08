import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../../../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import '../../../../application/timeline/ordinal/message_timeline_scope_ordinal_extensions.dart';
import '../../../debug/contact_timeline_scroll_probe.dart';

part 'message_grouping_metadata_by_ordinal_provider.g.dart';

class MessageGroupingMetadata {
  const MessageGroupingMetadata({
    required this.chatId,
    required this.isFromMe,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.hasAttachments,
  });

  final int chatId;
  final bool isFromMe;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool hasAttachments;
}

@riverpod
Future<MessageGroupingMetadata?> messageGroupingMetadataByTimelineOrdinal(
  MessageGroupingMetadataByTimelineOrdinalRef ref, {
  required MessageTimelineScope scope,
  required int ordinal,
}) async {
  ContactTimelineScrollProbe.count(
    'provider.grouping_metadata_by_ordinal.recompute',
  );

  return ContactTimelineScrollProbe.traceAsync(
    'provider.grouping_metadata_by_ordinal',
    () async {
      final strategy = await scope.resolveOrdinalStrategy(ref);

      ContactTimelineScrollProbe.count('ordinal_lookup.grouping_metadata');
      final messageId = await ContactTimelineScrollProbe.traceAsync(
        'ordinal_lookup.grouping_metadata',
        () => strategy.getMessageIdByOrdinal(ordinal),
      );
      if (messageId == null) {
        return null;
      }

      if (scope case RecoveredTimelineScope()) {
        return _loadRecoveredGroupingMetadata(
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
        'provider.grouping_metadata_by_ordinal.query',
        query.getSingleOrNull,
      );
      if (row == null) {
        return null;
      }

      final message = row.readTable(db.workingMessages);
      final participant = row.readTableOrNull(db.workingParticipants);

      return MessageGroupingMetadata(
        chatId: message.chatId,
        isFromMe: message.isFromMe,
        senderName: _senderNameForMessage(
          isFromMe: message.isFromMe,
          participant: participant,
          nameOverrides: nameOverrides,
        ),
        text: message.textContent ?? '',
        sentAt: _parseUtc(message.sentAtUtc),
        hasAttachments: message.hasAttachments,
      );
    },
  );
}

Future<MessageGroupingMetadata?> _loadRecoveredGroupingMetadata({
  required MessageGroupingMetadataByTimelineOrdinalRef ref,
  required MessageTimelineScope scope,
  required int messageId,
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
  final filteredMessages = filterRecoveredTimelineMessages(
    messages: recoveredMessages,
    onlyNoHandleFromMe: recoveredScope.onlyNoHandleFromMe,
  );
  final recoveredMessage = filteredMessages.where((message) {
    return message.id == messageId;
  }).firstOrNull;
  if (recoveredMessage == null) {
    return null;
  }

  return MessageGroupingMetadata(
    chatId: -recoveredMessage.id,
    isFromMe: recoveredMessage.isFromMe,
    senderName: _recoveredSenderName(recoveredMessage),
    text: recoveredMessage.text,
    sentAt: recoveredMessage.sentAt,
    hasAttachments: recoveredMessage.hasAttachments,
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

DateTime? _parseUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value)?.toLocal();
}

String _senderNameForMessage({
  required bool isFromMe,
  required WorkingParticipant? participant,
  required Map<int, String> nameOverrides,
}) {
  if (isFromMe) {
    return 'You';
  }

  if (participant == null) {
    return 'Unknown sender';
  }

  final override = nameOverrides[participant.id];
  if (override != null) {
    return override;
  }

  return participant.displayName;
}
