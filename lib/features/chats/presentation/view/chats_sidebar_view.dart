import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/chats_spec.dart';
import '../view_model/chats_view_model_provider.dart';
import '../view_model/recent_chats_provider.dart';

class ChatsSidebarView extends HookConsumerWidget {
  const ChatsSidebarView({required this.spec, super.key});

  final ChatsSpec spec;

  int _resolveLimit() {
    return spec.when(
      list: () => 5,
      forContact: (_) => 5,
      recent: (limit) => limit,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limit = _resolveLimit();
    final scrollController = useScrollController();
    final asyncChats = ref.watch(recentChatsProvider(limit: limit));
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');

    return ColoredBox(
      color: const Color(0xFFF4F5F8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchPlaceholder(),
            const SizedBox(height: 16),
            const _FilterPlaceholder(),
            const SizedBox(height: 24),
            Text(
              'Recent Chats',
              style: MacosTheme.of(
                context,
              ).typography.headline.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: asyncChats.when(
                data: (List<RecentChatSummary> chats) {
                  if (chats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats found. Start an import to populate your data.',
                        style: TextStyle(color: Color(0xFF7A7A7F)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return MacosScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _ChatSummaryCard(
                          summary: chat,
                          dateFormatter: dateFormatter,
                          onTap: () async {
                            await ref
                                .read(chatsViewModelProvider.notifier)
                                .selectChat(chat.chatId);
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: ProgressCircle(radius: 12),
                  ),
                ),
                error: (Object error, StackTrace stackTrace) =>
                    _ErrorState(error: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatSummaryCard extends StatelessWidget {
  const _ChatSummaryCard({
    required this.summary,
    required this.dateFormatter,
    required this.onTap,
  });

  final RecentChatSummary summary;
  final DateFormat dateFormatter;
  final VoidCallback onTap;

  String _format(DateTime? value) {
    if (value == null) {
      return '—';
    }
    return dateFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final captionStyle = MacosTheme.of(
      context,
    ).typography.caption1.copyWith(color: const Color(0xFF6B6B70));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MacosTheme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C33)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E2EA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.title,
                        style: MacosTheme.of(
                          context,
                        ).typography.title2.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (summary.isGroup)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: MacosIcon(
                          CupertinoIcons.person_2_fill,
                          size: 16,
                          color: Color(0xFF58585F),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Messages: ${summary.messageCount}', style: captionStyle),
                const SizedBox(height: 6),
                Text(
                  'First message: ${_format(summary.firstMessageDate)}',
                  style: captionStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Last message: ${_format(summary.lastMessageDate)}',
                  style: captionStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const MacosTextField(
      enabled: false,
      placeholder: 'Search chats (coming soon)',
      prefix: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: MacosIcon(CupertinoIcons.search, size: 16),
      ),
    );
  }
}

class _FilterPlaceholder extends StatelessWidget {
  const _FilterPlaceholder();

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C33)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters (coming soon)',
              style: typography.title3.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PlaceholderTag(label: 'Date range'),
                _PlaceholderTag(label: 'Sender'),
                _PlaceholderTag(label: 'Has attachments'),
                _PlaceholderTag(label: 'Labels'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTag extends StatelessWidget {
  const _PlaceholderTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: MacosTheme.of(
            context,
          ).typography.caption1.copyWith(color: const Color(0xFF6B6B70)),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load chats. $error',
        style: const TextStyle(color: Color(0xFFD14343)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
