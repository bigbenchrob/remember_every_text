import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../domain/entities/chat_with_latest_message.dart';
import '../view_model/chats_view_model_provider.dart';

/// Individual chat card component for displaying chat preview information
class ChatCard extends ConsumerWidget {
  const ChatCard({required this.chat, super.key});

  final ChatWithLatestMessage chat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: GestureDetector(
        onTap: () =>
            ref.read(chatsViewModelProvider.notifier).selectChat(chat.chatId),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: MacosColors.separatorColor, width: 0.5),
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 2),
                    _buildSubtitle(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the chat avatar/icon
  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: chat.isGroupChat ? Colors.blue : Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        chat.isGroupChat ? CupertinoIcons.group : CupertinoIcons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// Build the chat title
  Widget _buildTitle() {
    return Text(
      chat.displayTitle,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build the subtitle with latest message preview
  Widget _buildSubtitle() {
    var messagePrefix = '';
    if (chat.latestMessageIsFromMe == true) {
      messagePrefix = 'You: ';
    } else if (chat.isGroupChat && chat.participantNames.isNotEmpty) {
      // For group chats, we could show the sender's name if we had that info
      messagePrefix = '';
    }

    return Text(
      messagePrefix + chat.latestMessagePreview,
      style: TextStyle(
        fontSize: 11,
        color: const Color(0xFF666666).withValues(alpha: 0.8),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build the trailing section with time and message count
  Widget _buildTrailing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          chat.timeDisplay,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF999999).withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        if (chat.messageCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${chat.messageCount}',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
