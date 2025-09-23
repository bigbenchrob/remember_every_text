import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/use_cases/recent_chats_use_case.dart';
import 'chat_card.dart';

/// Widget that displays a list of the most recent chats
/// Designed for the left sidebar when the chats button is pressed
class RecentChatsList extends ConsumerWidget {
  const RecentChatsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentChatsAsync = ref.watch(recentChatsProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.chat_bubble_2,
                size: 16,
                color: Color(0xFF007AFF),
              ),
              SizedBox(width: 8),
              Text(
                'Recent Chats',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),

        // Chat list
        Expanded(
          child: recentChatsAsync.when(
            data: (chats) {
              if (chats.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble,
                        size: 48,
                        color: Color(0xFFCCCCCC),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recent chats',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Import messages to see chats',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatCard(chat: chat);
                },
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading recent chats...',
                    style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  ),
                ],
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 48,
                    color: Color(0xFFFF3B30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading chats',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stack trace: ${stack.toString().split('\n').take(3).join('\n')}',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
