import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/attachment_info.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import 'message_link_preview_card.dart';

enum MessageCardLayout { bubble, analysis }

/// Shared message card widget used in both contact messages and global timeline views.
/// Handles all message types: text, images, videos, and link previews.
/// Uses bubble-style layout with metadata underneath.
class MessageCard extends ConsumerWidget {
  const MessageCard({
    required this.message,
    this.layout = MessageCardLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
    this.inlineTextAction,
    super.key,
  });

  final MessageListItem message;
  final MessageCardLayout layout;
  final MessageGroupingStyle grouping;
  final Widget? inlineTextAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildMessageContent(context);
  }

  Widget _buildMessageContent(BuildContext context) {
    final messageText = _meaningfulMessageText(message.text);
    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    final urlPreviewAttachment = message.attachments
        .cast<AttachmentInfo?>()
        .firstWhere((attachment) {
          return attachment != null && attachment.isUrlPreview;
        }, orElse: () => null);

    final imageAttachments = message.attachments.where(
      (attachment) => attachment.isImage,
    );
    final videoAttachments = message.attachments.where(
      (attachment) => attachment.isVideo,
    );

    // Link preview (has priority if present)
    if (urlPreviewAttachment != null || isPureUrlMessage) {
      return MessageLinkPreviewCard(
        message: message,
        layout: layout,
        grouping: grouping,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    // Image attachment
    if (imageAttachments.isNotEmpty) {
      final attachment = imageAttachments.first;
      return ImageMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        captionText: messageText,
        sender: message.senderName,
        senderHandleLabel: message.senderHandleLabel,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
        layout: layout == MessageCardLayout.analysis
            ? MessageLayout.fullWidth
            : MessageLayout.bubble,
        grouping: grouping,
      );
    }

    // Video attachment
    if (videoAttachments.isNotEmpty) {
      final attachment = videoAttachments.first;
      return VideoMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        captionText: messageText,
        sender: message.senderName,
        senderHandleLabel: message.senderHandleLabel,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
        layout: layout == MessageCardLayout.analysis
            ? MessageLayout.fullWidth
            : MessageLayout.bubble,
        grouping: grouping,
      );
    }

    // Plain text message
    return TextMessageTile(
      isMe: message.isFromMe,
      text: message.text,
      sender: message.senderName,
      senderHandleLabel: message.senderHandleLabel,
      sentAt: message.sentAt ?? DateTime.now(),
      messageId: message.id,
      layout: layout == MessageCardLayout.analysis
          ? MessageLayout.fullWidth
          : MessageLayout.bubble,
      grouping: grouping,
      inlineTrailingAction: inlineTextAction,
    );
  }

  List<String> _extractUrls(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  String? _meaningfulMessageText(String text) {
    final sanitized = text
        .replaceAll('\uFFFC', '')
        .replaceAll('\u200B', '')
        .replaceAll('\u2060', '');
    final trimmed = sanitized.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    switch (trimmed) {
      case '[No text content]':
      case '(No text content)':
      case '(No plain text content)':
      case '(No plain text content; summary metadata preserved)':
      case '(No plain text content; app or balloon payload preserved)':
      case '(No preserved content)':
      case '(Associated message carrier without plain text)':
        return null;
    }

    return trimmed;
  }
}
