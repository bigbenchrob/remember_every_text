import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

part 'messages_for_chat_provider.g.dart';

/// Lightweight view model representing a message row rendered in the UI.
class ChatMessageListItem {
  const ChatMessageListItem({
    required this.id,
    required this.guid,
    required this.isFromMe,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.hasAttachments,
  });

  final int id;
  final String guid;
  final bool isFromMe;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool hasAttachments;
}

@riverpod
Stream<List<ChatMessageListItem>> messagesForChat(
  MessagesForChatRef ref, {
  required int chatId,
}) async* {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String resolveSenderName({
    WorkingIdentity? identity,
    required bool isFromMe,
  }) {
    if (isFromMe) {
      return 'You';
    }
    if (identity == null) {
      return 'Unknown sender';
    }
    return identity.displayName ?? identity.normalizedAddress ?? 'Unknown';
  }

  final query =
      db.select(db.workingMessages).join([
          drift.leftOuterJoin(
            db.workingIdentities,
            db.workingIdentities.id.equalsExp(
              db.workingMessages.senderIdentityId,
            ),
          ),
        ])
        ..where(db.workingMessages.chatId.equals(chatId))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.desc,
          ),
        ]);

  yield* query.watch().map((rows) {
    return rows.map((row) {
      final message = row.readTable(db.workingMessages);
      final identity = row.readTableOrNull(db.workingIdentities);

      return ChatMessageListItem(
        id: message.id,
        guid: message.guid,
        isFromMe: message.isFromMe,
        senderName: resolveSenderName(
          identity: identity,
          isFromMe: message.isFromMe,
        ),
        text: message.textContent ?? '[No text content]',
        sentAt: parseUtc(message.sentAtUtc),
        hasAttachments: message.hasAttachments,
      );
    }).toList();
  });
}
