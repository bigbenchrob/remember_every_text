import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_with_latest_message.freezed.dart';

/// Entity representing a chat with its latest message information
/// Used for displaying recent chats with preview information
@freezed
abstract class ChatWithLatestMessage with _$ChatWithLatestMessage {
  const factory ChatWithLatestMessage({
    required int chatId,
    required String chatGuid,
    String? chatDisplayName,
    int? contactId,
    String? contactDisplayName,
    required int messageCount,
    // Latest message info
    int? latestMessageId,
    String? latestMessageContent,
    required int latestMessageTimestamp,
    bool? latestMessageIsFromMe,
    bool? latestMessageHasAttachments,
    // Participant info for group chats
    required List<String> participantNames,
    required bool isGroupChat,
  }) = _ChatWithLatestMessage;

  const ChatWithLatestMessage._();

  /// Get display title for the chat
  String get displayTitle {
    if (chatDisplayName?.isNotEmpty == true) {
      return chatDisplayName!;
    }

    if (isGroupChat && participantNames.isNotEmpty) {
      if (participantNames.length <= 3) {
        return participantNames.join(', ');
      } else {
        return '${participantNames.take(2).join(', ')} +${participantNames.length - 2} others';
      }
    }

    if (contactDisplayName?.isNotEmpty == true) {
      return contactDisplayName!;
    }

    return 'Unknown Chat';
  }

  /// Get preview text for the latest message
  String get latestMessagePreview {
    if (latestMessageContent?.isNotEmpty == true) {
      // Clean up the content and truncate if needed
      final content = latestMessageContent!.trim();
      if (content.length > 60) {
        return '${content.substring(0, 57)}...';
      }
      return content;
    }

    if (latestMessageHasAttachments == true) {
      return '📎 Attachment';
    }

    return 'No messages';
  }

  /// Get time display string for the latest message
  String get timeDisplay {
    final now = DateTime.now();

    // Validate timestamp before converting to DateTime
    if (latestMessageTimestamp <= 0) {
      return 'Unknown';
    }

    // Convert Unix seconds to milliseconds, with bounds checking
    int timestampMs;
    if (latestMessageTimestamp > 1000000000000) {
      // Already in milliseconds
      timestampMs = latestMessageTimestamp;
    } else {
      // Convert seconds to milliseconds
      timestampMs = latestMessageTimestamp * 1000;
    }

    // Additional bounds check for DateTime validity
    if (timestampMs < -8640000000000000 || timestampMs > 8640000000000000) {
      return 'Invalid date';
    }

    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);

    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      // More than a week ago - show date
      return '${messageTime.month}/${messageTime.day}/${messageTime.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Just now
      return 'now';
    }
  }
}
