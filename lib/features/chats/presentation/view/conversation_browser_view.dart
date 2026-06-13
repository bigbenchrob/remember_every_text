import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../../essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
import '../../../../essentials/search/presentation/widgets/search_highlighted_text.dart';
import '../../application/conversation_browser/conversation_browser_integrator.dart';
import '../../application/read_models/recent_chat_summary.dart';
import '../view_model/chats_view_model_provider.dart';
import '../view_model/recent_chats_provider.dart';

class ConversationBrowserView extends ConsumerStatefulWidget {
  const ConversationBrowserView({super.key});

  @override
  ConsumerState<ConversationBrowserView> createState() =>
      _ConversationBrowserViewState();
}

class _ConversationBrowserViewState
    extends ConsumerState<ConversationBrowserView> {
  var _filter = ConversationBrowserFilter.all;
  var _sort = ConversationBrowserSort.mostRecent;
  final _includeParticipantsController = TextEditingController();
  final _excludeParticipantsController = TextEditingController();
  final _messageTextController = TextEditingController();
  final _includeParticipantsFocusNode = FocusNode();
  final _excludeParticipantsFocusNode = FocusNode();
  final _messageTextFocusNode = FocusNode();
  var _includeParticipantsQuery = '';
  var _excludeParticipantsQuery = '';
  var _messageTextQuery = '';

  @override
  void initState() {
    super.initState();
    _includeParticipantsController.addListener(_handleIncludeChanged);
    _excludeParticipantsController.addListener(_handleExcludeChanged);
    _messageTextController.addListener(_handleMessageTextChanged);
  }

  @override
  void dispose() {
    _includeParticipantsController.removeListener(_handleIncludeChanged);
    _excludeParticipantsController.removeListener(_handleExcludeChanged);
    _messageTextController.removeListener(_handleMessageTextChanged);
    _includeParticipantsController.dispose();
    _excludeParticipantsController.dispose();
    _messageTextController.dispose();
    _includeParticipantsFocusNode.dispose();
    _excludeParticipantsFocusNode.dispose();
    _messageTextFocusNode.dispose();
    super.dispose();
  }

  void _handleIncludeChanged() {
    setState(() {
      _includeParticipantsQuery = _includeParticipantsController.text;
    });
  }

  void _handleExcludeChanged() {
    setState(() {
      _excludeParticipantsQuery = _excludeParticipantsController.text;
    });
  }

  void _handleMessageTextChanged() {
    setState(() {
      _messageTextQuery = _messageTextController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(recentChatsProvider(limit: 500));
    final trimmedMessageTextQuery = _messageTextQuery.trim();
    final messageTextMatchesAsync = trimmedMessageTextQuery.isEmpty
        ? const AsyncValue<Map<int, ConversationMessageTextMatch>>.data(
            <int, ConversationMessageTextMatch>{},
          )
        : ref.watch(
            conversationMessageTextMatchesProvider(
              query: trimmedMessageTextQuery,
              limit: 500,
            ),
          );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: conversationsAsync.when(
        data: (conversations) {
          final messageTextMatches =
              messageTextMatchesAsync.valueOrNull ??
              <int, ConversationMessageTextMatch>{};
          final model = const ConversationBrowserIntegrator().build(
            conversations: conversations,
            filter: _filter,
            sort: _sort,
            includeParticipantsQuery: _includeParticipantsQuery,
            excludeParticipantsQuery: _excludeParticipantsQuery,
          );
          return _ConversationBrowserContent(
            model: model,
            filter: _filter,
            sort: _sort,
            includeParticipantsController: _includeParticipantsController,
            excludeParticipantsController: _excludeParticipantsController,
            messageTextController: _messageTextController,
            participantHighlightQuery: _includeParticipantsQuery,
            messageTextHighlightQuery: _messageTextQuery,
            includeParticipantsFocusNode: _includeParticipantsFocusNode,
            excludeParticipantsFocusNode: _excludeParticipantsFocusNode,
            messageTextFocusNode: _messageTextFocusNode,
            messageTextMatches: messageTextMatches,
            isMessageTextSearchActive: trimmedMessageTextQuery.isNotEmpty,
            isMessageTextSearchLoading: messageTextMatchesAsync.isLoading,
            messageTextSearchError: messageTextMatchesAsync.hasError
                ? messageTextMatchesAsync.error
                : null,
            onFilterChanged: (filter) {
              setState(() {
                _filter = filter;
              });
            },
            onSortChanged: (sort) {
              setState(() {
                _sort = sort;
              });
            },
            onConversationSelected: (conversationId) async {
              await ref
                  .read(chatsViewModelProvider.notifier)
                  .selectChat(conversationId);
            },
            onConversationSnippetSelected:
                (conversationId, snippetMessageId) async {
                  await ref
                      .read(chatsViewModelProvider.notifier)
                      .selectChat(
                        conversationId,
                        anchorMessageId: snippetMessageId,
                        searchQuery: trimmedMessageTextQuery,
                      );
                },
          );
        },
        loading: () => const Center(child: Text('Loading conversations...')),
        error: (error, stackTrace) =>
            Center(child: Text('Conversation browser failed: $error')),
      ),
    );
  }
}

class _ConversationBrowserContent extends ConsumerWidget {
  const _ConversationBrowserContent({
    required this.model,
    required this.filter,
    required this.sort,
    required this.includeParticipantsController,
    required this.excludeParticipantsController,
    required this.messageTextController,
    required this.participantHighlightQuery,
    required this.messageTextHighlightQuery,
    required this.includeParticipantsFocusNode,
    required this.excludeParticipantsFocusNode,
    required this.messageTextFocusNode,
    required this.messageTextMatches,
    required this.isMessageTextSearchActive,
    required this.isMessageTextSearchLoading,
    required this.messageTextSearchError,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onConversationSelected,
    required this.onConversationSnippetSelected,
  });

  final ConversationBrowserModel model;
  final ConversationBrowserFilter filter;
  final ConversationBrowserSort sort;
  final TextEditingController includeParticipantsController;
  final TextEditingController excludeParticipantsController;
  final TextEditingController messageTextController;
  final String participantHighlightQuery;
  final String messageTextHighlightQuery;
  final FocusNode includeParticipantsFocusNode;
  final FocusNode excludeParticipantsFocusNode;
  final FocusNode messageTextFocusNode;
  final Map<int, ConversationMessageTextMatch> messageTextMatches;
  final bool isMessageTextSearchActive;
  final bool isMessageTextSearchLoading;
  final Object? messageTextSearchError;
  final ValueChanged<ConversationBrowserFilter> onFilterChanged;
  final ValueChanged<ConversationBrowserSort> onSortChanged;
  final ValueChanged<int> onConversationSelected;
  final void Function(int conversationId, int snippetMessageId)
  onConversationSnippetSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(conversationFavouritesControllerProvider);
    final favouriteConversationIds = favourites.coreConversationIdSet;
    final favouriteConversations = [
      for (final conversation in model.conversations)
        if (favouriteConversationIds.contains(conversation.chatId))
          conversation,
    ];
    final regularConversations = [
      for (final conversation in model.conversations)
        if (!favouriteConversationIds.contains(conversation.chatId))
          conversation,
    ];

    Widget conversationRow(RecentChatSummary conversation) {
      return _ConversationRow(
        conversation: conversation,
        participantHighlightQuery: participantHighlightQuery,
        messageTextHighlightQuery: messageTextHighlightQuery,
        messageTextMatch: messageTextMatches[conversation.chatId],
        isMessageTextSearchActive: isMessageTextSearchActive,
        onPressed: () => onConversationSelected(conversation.chatId),
        onSnippetPressed: (snippetMessageId) => onConversationSnippetSelected(
          conversation.chatId,
          snippetMessageId,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConversationBrowserHeader(
          model: model,
          filter: filter,
          sort: sort,
          includeParticipantsController: includeParticipantsController,
          excludeParticipantsController: excludeParticipantsController,
          messageTextController: messageTextController,
          includeParticipantsFocusNode: includeParticipantsFocusNode,
          excludeParticipantsFocusNode: excludeParticipantsFocusNode,
          messageTextFocusNode: messageTextFocusNode,
          messageTextMatchCount: messageTextMatches.length,
          isMessageTextSearchLoading: isMessageTextSearchLoading,
          messageTextSearchError: messageTextSearchError,
          onFilterChanged: onFilterChanged,
          onSortChanged: onSortChanged,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: model.conversations.isEmpty
              ? const Center(child: Text('No conversations match this filter.'))
              : ListView(
                  children: [
                    if (favouriteConversations.isNotEmpty) ...[
                      const _ConversationBrowserSectionHeader(
                        title: 'Favourites',
                        subtitle: 'Core',
                      ),
                      for (
                        var index = 0;
                        index < favouriteConversations.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 8),
                        conversationRow(favouriteConversations[index]),
                      ],
                      if (regularConversations.isNotEmpty)
                        const SizedBox(height: 14),
                    ],
                    if (regularConversations.isNotEmpty) ...[
                      if (favouriteConversations.isNotEmpty)
                        const _ConversationBrowserSectionHeader(
                          title: 'Conversations',
                        ),
                      for (
                        var index = 0;
                        index < regularConversations.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 8),
                        conversationRow(regularConversations[index]),
                      ],
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ConversationBrowserSectionHeader extends ConsumerWidget {
  const _ConversationBrowserSectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: DefaultTextStyle.of(context).style.copyWith(
                color: colors.content.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: DefaultTextStyle.of(context).style.copyWith(
                color: colors.content.textTertiary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _ConversationBrowserHeader extends ConsumerWidget {
  const _ConversationBrowserHeader({
    required this.model,
    required this.filter,
    required this.sort,
    required this.includeParticipantsController,
    required this.excludeParticipantsController,
    required this.messageTextController,
    required this.includeParticipantsFocusNode,
    required this.excludeParticipantsFocusNode,
    required this.messageTextFocusNode,
    required this.messageTextMatchCount,
    required this.isMessageTextSearchLoading,
    required this.messageTextSearchError,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final ConversationBrowserModel model;
  final ConversationBrowserFilter filter;
  final ConversationBrowserSort sort;
  final TextEditingController includeParticipantsController;
  final TextEditingController excludeParticipantsController;
  final TextEditingController messageTextController;
  final FocusNode includeParticipantsFocusNode;
  final FocusNode excludeParticipantsFocusNode;
  final FocusNode messageTextFocusNode;
  final int messageTextMatchCount;
  final bool isMessageTextSearchLoading;
  final Object? messageTextSearchError;
  final ValueChanged<ConversationBrowserFilter> onFilterChanged;
  final ValueChanged<ConversationBrowserSort> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversations',
              style: DefaultTextStyle.of(
                context,
              ).style.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('total conversations: ${model.totalConversationCount}'),
            Text('visible conversations: ${model.visibleConversationCount}'),
            Text(
              'groups: ${model.groupConversationCount} | '
              'singles: ${model.singleConversationCount}',
            ),
            Text(
              'largest participants: ${model.largestParticipantCount} | '
              'largest messages: ${model.largestMessageCount}',
            ),
            Text(
              'zero participants: ${model.zeroParticipantConversationCount} | '
              'zero messages: ${model.zeroMessageConversationCount}',
            ),
            Text('with attachments: ${model.attachmentConversationCount}'),
            Text('filter: ${conversationBrowserFilterLabel(filter)}'),
            Text('sort: ${conversationBrowserSortLabel(sort)}'),
            Text(
              isMessageTextSearchLoading
                  ? 'message text matches: searching...'
                  : 'message text matches: $messageTextMatchCount',
            ),
            if (messageTextSearchError case final Object error)
              Text('message text search failed: $error'),
            const SizedBox(height: 12),
            _SearchField(
              key: const ValueKey<String>(
                'conversation-browser-search-include',
              ),
              label: 'Include participants',
              controller: includeParticipantsController,
              focusNode: includeParticipantsFocusNode,
              placeholder:
                  'Name, email, phone, or fragment; space/comma-separated',
            ),
            const SizedBox(height: 8),
            _SearchField(
              key: const ValueKey<String>(
                'conversation-browser-search-exclude',
              ),
              label: 'Exclude participants',
              controller: excludeParticipantsController,
              focusNode: excludeParticipantsFocusNode,
              placeholder: 'Hide matching fragments; space/comma-separated',
            ),
            const SizedBox(height: 8),
            _SearchField(
              key: const ValueKey<String>(
                'conversation-browser-search-message-text',
              ),
              label: 'Message text contains',
              controller: messageTextController,
              focusNode: messageTextFocusNode,
              placeholder: 'Search across all messages in conversations',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in ConversationBrowserFilter.values)
                  _ChoiceButton(
                    label: conversationBrowserFilterLabel(option),
                    isSelected: filter == option,
                    onPressed: () => onFilterChanged(option),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in ConversationBrowserSort.values)
                  _ChoiceButton(
                    label: conversationBrowserSortLabel(option),
                    isSelected: sort == option,
                    onPressed: () => onSortChanged(option),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  const _SearchField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaces.surface,
            border: Border.all(color: colors.lines.borderSubtle),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: CupertinoTextField.borderless(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConversationRow extends ConsumerWidget {
  const _ConversationRow({
    required this.conversation,
    required this.participantHighlightQuery,
    required this.messageTextHighlightQuery,
    required this.messageTextMatch,
    required this.isMessageTextSearchActive,
    required this.onPressed,
    required this.onSnippetPressed,
  });

  final RecentChatSummary conversation;
  final String participantHighlightQuery;
  final String messageTextHighlightQuery;
  final ConversationMessageTextMatch? messageTextMatch;
  final bool isMessageTextSearchActive;
  final VoidCallback onPressed;
  final ValueChanged<int> onSnippetPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final participants = conversation.participants.isEmpty
        ? 'Unknown Contact'
        : conversation.participants.join(' | ');
    final lastMessageDate = conversation.lastMessageDate?.toIso8601String();
    final textMatch = messageTextMatch;
    final hasMessageTextMatch = textMatch != null;

    return Opacity(
      opacity: isMessageTextSearchActive && !hasMessageTextMatch ? 0.42 : 1,
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: hasMessageTextMatch
                ? colors.messagePanels.accentTintSoft
                : colors.surfaces.surface,
            border: Border.all(
              color: hasMessageTextMatch
                  ? colors.messagePanels.accentBorder
                  : colors.lines.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SearchHighlightedText(
                        text: participants,
                        query: participantHighlightQuery,
                        style: DefaultTextStyle.of(
                          context,
                        ).style.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ConversationFavouriteButton(
                      conversationId: conversation.chatId,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'participant count: ${conversation.participants.length} | '
                  '${conversation.isGroup ? 'group' : 'single'}',
                ),
                Text('message count: ${conversation.messageCount}'),
                if (conversation.attachmentCount > 0)
                  Text('attachments: ${conversation.attachmentCount}'),
                if (_hasDistinctHandles(
                  participants: conversation.participants,
                  handles: conversation.handles,
                ))
                  Text('handles: ${conversation.handles.join(' | ')}'),
                Text('latest: ${lastMessageDate ?? 'no date'}'),
                SearchHighlightedText(
                  text:
                      'preview: ${_hasText(conversation.lastMessagePreview) ? conversation.lastMessagePreview! : 'no text'}',
                  query: messageTextHighlightQuery,
                ),
                if (textMatch != null) ...[
                  const SizedBox(height: 6),
                  Text('matching messages: ${textMatch.matchCount}'),
                  for (final snippet in textMatch.snippets)
                    _ConversationTextMatchSnippet(
                      snippet: snippet,
                      query: messageTextHighlightQuery,
                      onPressed: () => onSnippetPressed(snippet.messageId),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationTextMatchSnippet extends ConsumerWidget {
  const _ConversationTextMatchSnippet({
    required this.snippet,
    required this.query,
    required this.onPressed,
  });

  final ConversationMessageTextSnippet snippet;
  final String query;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final dateLabel = snippet.dateUtc ?? 'no date';

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: GestureDetector(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            border: Border.all(color: colors.lines.borderSubtle),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('message ${snippet.messageId} • $dateLabel'),
                SearchHighlightedText(
                  text: snippet.text,
                  query: query,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends ConsumerWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.surfaces.selected
              : colors.surfaces.surface,
          border: Border.all(
            color: isSelected
                ? colors.accents.primary
                : colors.lines.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(label),
        ),
      ),
    );
  }
}

bool _hasText(String? value) {
  return value != null && value.isNotEmpty;
}

bool _hasDistinctHandles({
  required List<String> participants,
  required List<String> handles,
}) {
  if (handles.isEmpty) {
    return false;
  }
  final participantKeys = {
    for (final participant in participants) participant.trim().toLowerCase(),
  };
  return handles.any(
    (handle) => !participantKeys.contains(handle.trim().toLowerCase()),
  );
}
