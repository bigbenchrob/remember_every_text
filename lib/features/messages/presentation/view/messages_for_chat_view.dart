import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../view_model/messages_for_chat_provider.dart';

class MessagesForChatView extends HookConsumerWidget {
  const MessagesForChatView({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final asyncMessages =
        ref.watch(messagesForChatProvider(chatId: chatId));
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');

    return asyncMessages.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.chat_bubble_text, size: 48),
                SizedBox(height: 12),
                Text(
                  'No messages in this chat yet.',
                  style: TextStyle(color: Color(0xFF7A7A7F)),
                ),
              ],
            ),
          );
        }

        return ColoredBox(
          color: const Color(0xFFF9FAFB),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MacosScrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: scrollController,
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _MessageBubble(
                    message: message,
                    dateFormatter: dateFormatter,
                  );
                },
              ),
            ),
          ),
        );
      },
  loading: () => const Center(child: ProgressCircle(radius: 12)),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to load messages. $error',
            style: const TextStyle(color: Color(0xFFD14343)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.dateFormatter});

  final ChatMessageListItem message;
  final DateFormat dateFormatter;

  @override
  Widget build(BuildContext context) {
    final isDark = MacosTheme.of(context).brightness == Brightness.dark;
    final bubbleColor = message.isFromMe
        ? const Color(0xFF007AFF)
        : (isDark ? const Color(0xFF2C2C33) : Colors.white);
    final textColor = message.isFromMe
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1C1C1E));
    final metadataColor = message.isFromMe
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF6B6B70);

    String formatTimestamp(DateTime? timestamp) {
      if (timestamp == null) {
        return 'Unknown time';
      }
      return dateFormatter.format(timestamp);
    }

    return Align(
      alignment:
          message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: message.isFromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isFromMe)
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: metadataColor,
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.hasAttachments)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          CupertinoIcons.paperclip,
                          size: 14,
                          color: metadataColor,
                        ),
                      ),
                    Text(
                      formatTimestamp(message.sentAt),
                      style: TextStyle(fontSize: 11, color: metadataColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
