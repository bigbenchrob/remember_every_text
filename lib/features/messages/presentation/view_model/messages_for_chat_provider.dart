import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

part 'messages_for_chat_provider.g.dart';

/// Attachment information for display
class AttachmentInfo {
  const AttachmentInfo({
    required this.id,
    required this.localPath,
    required this.mimeType,
    required this.transferName,
  });

  final int id;
  final String? localPath;
  final String? mimeType;
  final String? transferName;

  bool get isImage {
    if (mimeType != null) {
      return mimeType!.startsWith('image/');
    }
    if (localPath != null) {
      final path = localPath!.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.heic') ||
          path.endsWith('.heif') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp');
    }
    return false;
  }

  bool get isVideo {
    if (mimeType != null) {
      return mimeType!.startsWith('video/');
    }
    if (localPath != null) {
      final path = localPath!.toLowerCase();
      return path.endsWith('.mov') ||
          path.endsWith('.mp4') ||
          path.endsWith('.m4v') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv');
    }
    return false;
  }

  bool get isUrlPreview {
    if (localPath != null) {
      return localPath!.toLowerCase().endsWith('.pluginpayloadattachment');
    }
    return false;
  }
}

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
    this.attachments = const [],
  });

  final int id;
  final String guid;
  final bool isFromMe;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool hasAttachments;
  final List<AttachmentInfo> attachments;
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
    WorkingParticipant? participant,
    required bool isFromMe,
  }) {
    if (isFromMe) {
      return 'You';
    }
    if (participant == null) {
      return 'Unknown sender';
    }
    return participant.displayName ??
        participant.normalizedAddress ??
        'Unknown';
  }

  final query =
      db.select(db.workingMessages).join([
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.workingMessages.senderParticipantId,
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

  yield* query.watch().asyncMap((rows) async {
    final items = <ChatMessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(db.workingMessages);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Fetch attachments for this message if it has any
      final attachments = message.hasAttachments
          ? await (db.select(db.workingAttachments)
                  ..where((a) => a.messageGuid.equals(message.guid)))
                .get()
                .then((attachmentRows) {
                  return attachmentRows
                      .map(
                        (a) => AttachmentInfo(
                          id: a.id,
                          localPath: a.localPath,
                          mimeType: a.mimeType,
                          transferName: a.transferName,
                        ),
                      )
                      .toList();
                })
          : <AttachmentInfo>[];

      items.add(
        ChatMessageListItem(
          id: message.id,
          guid: message.guid,
          isFromMe: message.isFromMe,
          senderName: resolveSenderName(
            participant: participant,
            isFromMe: message.isFromMe,
          ),
          text: message.textContent ?? '[No text content]',
          sentAt: parseUtc(message.sentAtUtc),
          hasAttachments: message.hasAttachments,
          attachments: attachments,
        ),
      );
    }

    return items;
  });
}
