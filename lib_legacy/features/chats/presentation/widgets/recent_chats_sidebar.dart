import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/recent_chats_provider.dart';
import 'recent_chat_card.dart';

/// Sidebar widget displaying the most recent chats with header
class RecentChatsSidebar extends ConsumerWidget {
  const RecentChatsSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentChatsAsync = ref.watch(recentChatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section for future controls
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: MacosTheme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Recent Chats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // Placeholder for future controls (search, filter, etc.)
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  // TODO: Add controls menu
                },
                tooltip: 'More options',
              ),
            ],
          ),
        ),

        // Chat list
        Expanded(
          child: recentChatsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load recent chats'),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PushButton(
                    controlSize: ControlSize.small,
                    onPressed: () => ref.invalidate(recentChatsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (chats) {
              if (chats.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No recent chats found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Import your messages to see recent chats here',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return RecentChatCard(
                    chatInfo: chat,
                    onTap: () {
                      // TODO: Navigate to chat detail view
                      debugPrint('Tapped chat: ${chat.chatId}');
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
