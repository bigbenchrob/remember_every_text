import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../providers/recent_chats_provider.dart';

/// A card widget displaying recent chat information
class RecentChatCard extends StatelessWidget {
  const RecentChatCard({required this.chatInfo, this.onTap, super.key});

  final RecentChatInfo chatInfo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final dateFormat = DateFormat('MMM d, y');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.dividerColor, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact name and message count row
            Row(
              children: [
                Expanded(
                  child: Text(
                    chatInfo.contactDisplayName,
                    style: theme.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${chatInfo.messageCount}',
                    style: theme.typography.caption1.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date range information
            if (chatInfo.firstMessageDate != null &&
                chatInfo.lastMessageDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.typography.caption1.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'First: ${dateFormat.format(chatInfo.firstMessageDate!)}',
                      style: theme.typography.caption1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 14,
                    color: theme.typography.caption1.color,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Last: ${dateFormat.format(chatInfo.lastMessageDate!)}',
                      style: theme.typography.caption1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text('No date information', style: theme.typography.caption1),
            ],

            const SizedBox(height: 8),

            // Contact ID (for debugging/reference)
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: theme.typography.caption1.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Contact ID: ${chatInfo.contactId ?? 'Unknown'}',
                  style: theme.typography.caption1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
