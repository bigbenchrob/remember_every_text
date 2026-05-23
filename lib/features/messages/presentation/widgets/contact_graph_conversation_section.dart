import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../domain/spec_classes/messages_view_spec.dart';

class ContactGraphConversationSection extends ConsumerWidget {
  const ContactGraphConversationSection({
    required this.contactId,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 12),
    this.maxHeight = 220,
    super.key,
  });

  final int contactId;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(
      contactPageGraphSnapshotProvider(contactId: contactId),
    );

    return snapshotAsync.when(
      data: (snapshot) {
        if (snapshot.conversations.isEmpty) {
          return _ContactGraphConversationNotice(
            padding: padding,
            title: 'No conversations found',
            message:
                'The graph has no conversation edges for this contact yet.',
          );
        }

        return _ContactGraphConversationContent(
          snapshot: snapshot,
          padding: padding,
          maxHeight: maxHeight,
        );
      },
      loading: () => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Loading conversations',
        message: 'Reading the source-scoped conversation graph.',
      ),
      error: (error, _) => _ContactGraphConversationNotice(
        padding: padding,
        title: 'Unable to load conversations',
        message: '$error',
      ),
    );
  }
}

class _ContactGraphConversationNotice extends ConsumerWidget {
  const _ContactGraphConversationNotice({
    required this.padding,
    required this.title,
    required this.message,
  });

  final EdgeInsetsGeometry padding;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.messagePanels.supportSurface,
          border: Border.all(color: colors.messagePanels.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typography.headline),
              const SizedBox(height: 4),
              Text(message, style: typography.caption1),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactGraphConversationContent extends ConsumerStatefulWidget {
  const _ContactGraphConversationContent({
    required this.snapshot,
    required this.padding,
    required this.maxHeight,
  });

  final ContactGraphSnapshot snapshot;
  final EdgeInsetsGeometry padding;
  final double maxHeight;

  @override
  ConsumerState<_ContactGraphConversationContent> createState() =>
      _ContactGraphConversationContentState();
}

class _ContactGraphConversationContentState
    extends ConsumerState<_ContactGraphConversationContent> {
  var _showInfo = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final conversations = widget.snapshot.conversations;
    final totalMessages = conversations.fold<int>(
      0,
      (total, conversation) => total + conversation.messageCount,
    );
    final totalAttachments = conversations.fold<int>(
      0,
      (total, conversation) => total + conversation.attachmentCount,
    );
    final activity = widget.snapshot.messageActivity;

    return Padding(
      padding: widget.padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.messagePanels.supportSurface,
          border: Border.all(color: colors.messagePanels.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Conversations', style: typography.title3),
                  ),
                  CupertinoButton(
                    minimumSize: const Size.square(22),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _showInfo = !_showInfo;
                      });
                    },
                    child: Icon(
                      _showInfo
                          ? CupertinoIcons.info_circle_fill
                          : CupertinoIcons.info_circle,
                      size: 16,
                      color: colors.content.textSecondary,
                    ),
                  ),
                ],
              ),
              if (_showInfo) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${_formatCount(conversations.length)} conversations',
                      style: typography.caption1,
                    ),
                    Text(
                      '${_formatCount(totalMessages)} messages',
                      style: typography.caption1,
                    ),
                    if (totalAttachments > 0)
                      Text(
                        '${_formatCount(totalAttachments)} attachments',
                        style: typography.caption1,
                      ),
                    if (activity != null)
                      Text(
                        _formatDateRange(activity),
                        style: typography.caption1,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _ContactConversationRow(
                      conversation: conversation,
                      onPressed: () {
                        ref
                            .read(
                              panelsViewStateProvider(
                                SidebarMode.messages,
                              ).notifier,
                            )
                            .show(
                              panel: WindowPanel.center,
                              spec: ViewSpec.messages(
                                MessagesSpec.forConversation(
                                  conversationId: conversation.conversationId,
                                ),
                              ),
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactConversationRow extends ConsumerWidget {
  const _ContactConversationRow({
    required this.conversation,
    required this.onPressed,
  });

  final ConversationOverview conversation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final participants = conversation.participantHandles.isEmpty
        ? 'Unknown participants'
        : conversation.participantHandles.join(' | ');
    final latest = _formatDate(conversation.lastMessageAtUtc);
    final preview = _previewText(conversation.lastMessageText);

    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.messagePanels.card,
          border: Border.all(color: colors.messagePanels.cardBorder),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participants,
                style: typography.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 3,
                children: [
                  Text(
                    conversation.isGroup ? 'group' : 'single',
                    style: typography.caption2,
                  ),
                  Text(
                    '${conversation.participantCount} participants',
                    style: typography.caption2,
                  ),
                  Text(
                    '${_formatCount(conversation.messageCount)} messages',
                    style: typography.caption2,
                  ),
                  if (conversation.attachmentCount > 0)
                    Text(
                      '${_formatCount(conversation.attachmentCount)} attachments',
                      style: typography.caption2,
                    ),
                  Text('latest: $latest', style: typography.caption2),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                preview,
                style: typography.caption1,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}

String _formatDateRange(ContactMessageActivity activity) {
  final first = _formatDate(activity.firstMessageAtUtc);
  final last = _formatDate(activity.lastMessageAtUtc);
  return '$first to $last';
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'no date';
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String _previewText(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return 'preview: no text';
  }
  return 'preview: $trimmed';
}
