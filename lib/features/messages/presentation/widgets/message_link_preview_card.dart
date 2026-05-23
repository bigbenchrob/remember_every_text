import 'package:flutter/material.dart';

import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import 'message_card.dart';
import 'url_preview_widget.dart';

class MessageLinkPreviewCard extends StatelessWidget {
  const MessageLinkPreviewCard({
    super.key,
    required this.message,
    this.layout = MessageCardLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
    this.maxWidth = 420,
  });

  final MessageListItem message;
  final MessageCardLayout layout;
  final MessageGroupingStyle grouping;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return _LinkPreviewContent(
      message: message,
      layout: layout,
      grouping: grouping,
      maxWidth: maxWidth,
    );
  }
}

class _LinkPreviewContent extends StatelessWidget {
  const _LinkPreviewContent({
    required this.message,
    required this.layout,
    required this.grouping,
    required this.maxWidth,
  });

  final MessageListItem message;
  final MessageCardLayout layout;
  final MessageGroupingStyle grouping;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final urls = _extractUrls(message.text);
    if (urls.isEmpty) {
      return _LinkPreviewError(
        messageId: message.id,
        error: 'Message does not contain a URL.',
      );
    }

    final firstUrl = urls.first;
    final sender = message.isFromMe ? 'You' : message.senderName;
    final messageLayout = layout == MessageCardLayout.analysis
        ? MessageLayout.fullWidth
        : MessageLayout.bubble;

    return MessageShell(
      isMe: message.isFromMe,
      layout: messageLayout,
      grouping: grouping,
      metadata: _alignForLayout(
        layout: messageLayout,
        isMe: message.isFromMe,
        maxWidth: maxWidth,
        child: MetadataLine(
          sender: sender,
          senderHandleLabel: message.senderHandleLabel,
          sentAt: message.sentAt ?? DateTime.now(),
          messageId: message.id,
          layout: messageLayout,
        ),
      ),
      child: _alignForLayout(
        layout: messageLayout,
        isMe: message.isFromMe,
        maxWidth: maxWidth,
        child: UrlPreviewWidget(
          url: firstUrl,
          isFromMe: message.isFromMe,
          maxWidth: maxWidth,
        ),
      ),
    );
  }

  Widget _alignForLayout({
    required MessageLayout layout,
    required bool isMe,
    required double maxWidth,
    required Widget child,
  }) {
    if (layout == MessageLayout.bubble) {
      return child;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  List<String> _extractUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }
}

class _LinkPreviewError extends StatelessWidget {
  const _LinkPreviewError({required this.messageId, required this.error});

  final int messageId;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF5C2C7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 16, color: Color(0xFFD14343)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load link preview for message $messageId: $error',
                style: const TextStyle(color: Color(0xFFD14343), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
