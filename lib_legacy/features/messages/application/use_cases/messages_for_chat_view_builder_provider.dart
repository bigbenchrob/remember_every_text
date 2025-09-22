import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_for_chat_view_builder_provider.g.dart';

/// Widget builder for displaying messages belonging to a specific chat
@riverpod
Widget messagesForChatViewBuilder(Ref ref, int chatId) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Messages for Chat ID: $chatId',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('📱 Message 1: Hey, how are you?'),
        const Text('📱 Message 2: Are we still on for lunch?'),
        const Text('📱 Message 3: Let me know when you see this'),
        const SizedBox(height: 16),
        Text(
          'Total messages: 3 (placeholder)',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF666666).withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );
}
