import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import '../../../../essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../../essentials/search/presentation/widgets/search_highlighted_text.dart';
import '../../../chats/application/conversation_browser/contact_handle_label_provider.dart';
import '../../application/conversation_timeline/conversation_timeline_integrator.dart';

class ConversationMessagesPreviewView extends ConsumerStatefulWidget {
  const ConversationMessagesPreviewView({
    required this.conversationId,
    this.anchorMessageId,
    this.searchQuery,
    super.key,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;

  @override
  ConsumerState<ConversationMessagesPreviewView> createState() =>
      _ConversationMessagesPreviewViewState();
}

class _ConversationMessagesPreviewViewState
    extends ConsumerState<ConversationMessagesPreviewView> {
  var _messageLimit = 100;
  var _timelineOrder = ConversationTimelineOrder.oldestFirst;
  var _timelineFilter = ConversationTimelineFilter.all;
  var _searchMatchesOnly = false;
  int? _activeAnchorMessageId;
  int? _lastScrolledAnchorMessageId;
  final _messageRowKeys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _activeAnchorMessageId = widget.anchorMessageId;
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      conversationMessagesProvider(
        conversationId: widget.conversationId,
        limit: _messageLimit,
      ),
    );
    final overviewsAsync = ref.watch(
      conversationOverviewsProvider(limit: 1000),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: messagesAsync.when(
        data: (messages) {
          _scheduleAnchorScroll(_activeAnchorMessageId);
          return _ConversationMessagesTimeline(
            conversationId: widget.conversationId,
            anchorMessageId: _activeAnchorMessageId,
            searchQuery: widget.searchQuery,
            overview: _overviewForConversation(
              overviewsAsync.valueOrNull,
              widget.conversationId,
            ),
            messages: messages,
            messageLimit: _messageLimit,
            timelineOrder: _timelineOrder,
            timelineFilter: _timelineFilter,
            searchMatchesOnly: _searchMatchesOnly,
            messageRowKeyFor: _messageRowKeyFor,
            onMessageLimitChanged: (value) {
              setState(() {
                _messageLimit = value;
              });
            },
            onTimelineOrderChanged: (value) {
              setState(() {
                _timelineOrder = value;
              });
            },
            onTimelineFilterChanged: (value) {
              setState(() {
                _timelineFilter = value;
              });
            },
            onSearchMatchesOnlyChanged: (value) {
              setState(() {
                _searchMatchesOnly = value;
              });
              _scheduleAnchorScroll(_activeAnchorMessageId, force: true);
            },
            onAnchorMessageChanged: _setActiveAnchorMessage,
          );
        },
        loading: () =>
            const Center(child: Text('Loading conversation graph messages...')),
        error: (error, stackTrace) =>
            Center(child: Text('Conversation graph timeline failed: $error')),
      ),
    );
  }

  ConversationOverview? _overviewForConversation(
    List<ConversationOverview>? overviews,
    int conversationId,
  ) {
    if (overviews == null) {
      return null;
    }
    for (final overview in overviews) {
      if (overview.conversationId == conversationId) {
        return overview;
      }
    }
    return null;
  }

  GlobalKey _messageRowKeyFor(int messageId) {
    return _messageRowKeys.putIfAbsent(messageId, GlobalKey.new);
  }

  void _setActiveAnchorMessage(int? messageId) {
    setState(() {
      _activeAnchorMessageId = messageId;
    });
    _scheduleAnchorScroll(messageId, force: true);
  }

  void _scheduleAnchorScroll(int? messageId, {bool force = false}) {
    if (messageId == null) {
      return;
    }
    if (!force && _lastScrolledAnchorMessageId == messageId) {
      return;
    }
    _lastScrolledAnchorMessageId = messageId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final context = _messageRowKeys[messageId]?.currentContext;
      if (context == null) {
        return;
      }
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    });
  }
}

class _ConversationMessagesTimeline extends StatelessWidget {
  const _ConversationMessagesTimeline({
    required this.conversationId,
    required this.anchorMessageId,
    required this.searchQuery,
    required this.overview,
    required this.messages,
    required this.messageLimit,
    required this.timelineOrder,
    required this.timelineFilter,
    required this.searchMatchesOnly,
    required this.messageRowKeyFor,
    required this.onMessageLimitChanged,
    required this.onTimelineOrderChanged,
    required this.onTimelineFilterChanged,
    required this.onSearchMatchesOnlyChanged,
    required this.onAnchorMessageChanged,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;
  final ConversationOverview? overview;
  final List<ConversationMessage> messages;
  final int messageLimit;
  final ConversationTimelineOrder timelineOrder;
  final ConversationTimelineFilter timelineFilter;
  final bool searchMatchesOnly;
  final GlobalKey Function(int messageId) messageRowKeyFor;
  final ValueChanged<int> onMessageLimitChanged;
  final ValueChanged<ConversationTimelineOrder> onTimelineOrderChanged;
  final ValueChanged<ConversationTimelineFilter> onTimelineFilterChanged;
  final ValueChanged<bool> onSearchMatchesOnlyChanged;
  final ValueChanged<int?> onAnchorMessageChanged;

  @override
  Widget build(BuildContext context) {
    final timeline = const ConversationTimelineIntegrator().build(
      overview: overview,
      messages: messages,
      filter: timelineFilter,
      order: timelineOrder,
      searchQuery: searchQuery ?? '',
      searchMatchesOnly: searchMatchesOnly,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineHeader(
          conversationId: conversationId,
          anchorMessageId: anchorMessageId,
          searchQuery: searchQuery,
          timeline: timeline,
          messageLimit: messageLimit,
          timelineOrder: timelineOrder,
          timelineFilter: timelineFilter,
          searchMatchesOnly: searchMatchesOnly,
          messages: messages,
          onMessageLimitChanged: onMessageLimitChanged,
          onTimelineOrderChanged: onTimelineOrderChanged,
          onTimelineFilterChanged: onTimelineFilterChanged,
          onSearchMatchesOnlyChanged: onSearchMatchesOnlyChanged,
          onAnchorMessageChanged: onAnchorMessageChanged,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: timeline.visibleMessageCount == 0
              ? const Center(
                  child: Text('No messages match this conversation filter.'),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildGroupedRows(timeline.groups),
                  ),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedRows(List<ConversationTimelineDayGroup> groups) {
    final rows = <Widget>[];
    for (final group in groups) {
      rows.add(_DayDivider(label: group.dayLabel));
      for (final message in group.messages) {
        rows.add(
          _ConversationMessageRow(
            message: message,
            key: messageRowKeyFor(message.messageId),
            isAnchorMessage: message.messageId == anchorMessageId,
            searchQuery: searchQuery ?? '',
          ),
        );
      }
    }
    return rows;
  }
}

class _TimelineHeader extends ConsumerStatefulWidget {
  const _TimelineHeader({
    required this.conversationId,
    required this.anchorMessageId,
    required this.searchQuery,
    required this.timeline,
    required this.messageLimit,
    required this.timelineOrder,
    required this.timelineFilter,
    required this.searchMatchesOnly,
    required this.messages,
    required this.onMessageLimitChanged,
    required this.onTimelineOrderChanged,
    required this.onTimelineFilterChanged,
    required this.onSearchMatchesOnlyChanged,
    required this.onAnchorMessageChanged,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;
  final ConversationTimelineModel timeline;
  final int messageLimit;
  final ConversationTimelineOrder timelineOrder;
  final ConversationTimelineFilter timelineFilter;
  final bool searchMatchesOnly;
  final List<ConversationMessage> messages;
  final ValueChanged<int> onMessageLimitChanged;
  final ValueChanged<ConversationTimelineOrder> onTimelineOrderChanged;
  final ValueChanged<ConversationTimelineFilter> onTimelineFilterChanged;
  final ValueChanged<bool> onSearchMatchesOnlyChanged;
  final ValueChanged<int?> onAnchorMessageChanged;

  @override
  ConsumerState<_TimelineHeader> createState() => _TimelineHeaderState();
}

class _TimelineHeaderState extends ConsumerState<_TimelineHeader> {
  var _showOptions = false;
  var _copiedEvidenceSummary = false;

  Future<void> _copyEvidenceSummary({
    required String title,
    required String dateSpan,
    required int messageCount,
    required String? searchQuery,
    required int? matchPosition,
    required int matchCount,
    required int? anchorMessageId,
    required ConversationMessage? anchorMessage,
  }) async {
    final summary = _buildEvidenceSummary(
      title: title,
      dateSpan: dateSpan,
      messageCount: messageCount,
      searchQuery: searchQuery,
      matchPosition: matchPosition,
      matchCount: matchCount,
      anchorMessageId: anchorMessageId,
      anchorMessage: anchorMessage,
    );
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) {
      return;
    }
    setState(() {
      _copiedEvidenceSummary = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final labels = ref.watch(contactHandleLabelsProvider).valueOrNull;
    final overview = widget.timeline.overview;
    final title = _conversationTitle(overview, labels);
    final dateSpan = _conversationDateSpan(overview);
    final messageCount =
        overview?.messageCount ?? widget.timeline.visibleMessageCount;
    final subtitleParts = <String>[
      if (dateSpan.isNotEmpty) dateSpan,
      '${_formatCount(messageCount)} messages',
    ];
    final statusParts = <String>[
      conversationTimelineOrderLabel(widget.timelineOrder),
      conversationTimelineFilterLabel(widget.timelineFilter),
      'latest ${widget.messageLimit}',
    ];
    final searchQuery = widget.searchQuery?.trim();
    final hasSearchQuery = searchQuery != null && searchQuery.isNotEmpty;
    final matchPosition = _matchPosition(
      widget.timeline.matchingMessageIds,
      widget.anchorMessageId,
    );
    final anchorMessage = _findMessage(widget.messages, widget.anchorMessageId);

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
            Text('Conversation: $title', style: typography.title2),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final part in subtitleParts)
                  Text(part, style: typography.callout),
              ],
            ),
            const SizedBox(height: 4),
            Text(statusParts.join(' • '), style: typography.caption),
            if (hasSearchQuery) ...[
              const SizedBox(height: 6),
              _SearchReviewStrip(
                query: searchQuery,
                matchCount: widget.timeline.loadedSearchMatchCount,
                matchPosition: matchPosition,
                isMatchingOnly: widget.searchMatchesOnly,
                hasMatches: widget.timeline.matchingMessageIds.isNotEmpty,
                onPrevious: () => widget.onAnchorMessageChanged(
                  _previousMatchId(
                    widget.timeline.matchingMessageIds,
                    widget.anchorMessageId,
                  ),
                ),
                onNext: () => widget.onAnchorMessageChanged(
                  _nextMatchId(
                    widget.timeline.matchingMessageIds,
                    widget.anchorMessageId,
                  ),
                ),
                onMatchingOnlyChanged: () => widget.onSearchMatchesOnlyChanged(
                  !widget.searchMatchesOnly,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showOptions = !_showOptions;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showOptions
                            ? CupertinoIcons.chevron_down
                            : CupertinoIcons.chevron_right,
                        size: 13,
                        color: colors.content.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text('View options', style: typography.caption),
                    ],
                  ),
                ),
                AppHeaderActionButton(
                  icon: CupertinoIcons.doc_on_doc,
                  label: _copiedEvidenceSummary
                      ? 'Copied evidence summary'
                      : 'Copy evidence summary',
                  isEnabled: true,
                  onPressed: () async {
                    await _copyEvidenceSummary(
                      title: title,
                      dateSpan: dateSpan,
                      messageCount: messageCount,
                      searchQuery: searchQuery,
                      matchPosition: matchPosition,
                      matchCount: widget.timeline.loadedSearchMatchCount,
                      anchorMessageId: widget.anchorMessageId,
                      anchorMessage: anchorMessage,
                    );
                  },
                ),
              ],
            ),
            if (_showOptions) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceButton(
                    label: 'Latest 100',
                    isSelected: widget.messageLimit == 100,
                    onPressed: () => widget.onMessageLimitChanged(100),
                  ),
                  _ChoiceButton(
                    label: 'Latest 500',
                    isSelected: widget.messageLimit == 500,
                    onPressed: () => widget.onMessageLimitChanged(500),
                  ),
                  _ChoiceButton(
                    label: 'Oldest first',
                    isSelected:
                        widget.timelineOrder ==
                        ConversationTimelineOrder.oldestFirst,
                    onPressed: () => widget.onTimelineOrderChanged(
                      ConversationTimelineOrder.oldestFirst,
                    ),
                  ),
                  _ChoiceButton(
                    label: 'Newest first',
                    isSelected:
                        widget.timelineOrder ==
                        ConversationTimelineOrder.newestFirst,
                    onPressed: () => widget.onTimelineOrderChanged(
                      ConversationTimelineOrder.newestFirst,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in ConversationTimelineFilter.values)
                    _ChoiceButton(
                      label: conversationTimelineFilterLabel(filter),
                      isSelected: widget.timelineFilter == filter,
                      onPressed: () => widget.onTimelineFilterChanged(filter),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Showing ${_formatCount(widget.timeline.visibleMessageCount)} '
                'of ${_formatCount(widget.timeline.totalLoadedMessageCount)} '
                'loaded messages • text ${_formatCount(widget.timeline.textMessageCount)} '
                '• no text ${_formatCount(widget.timeline.noTextMessageCount)} '
                '• from me ${_formatCount(widget.timeline.fromMeMessageCount)} '
                '• received ${_formatCount(widget.timeline.receivedMessageCount)} '
                '• associated ${_formatCount(widget.timeline.associatedMessageCount)}',
                style: typography.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

ConversationMessage? _findMessage(
  List<ConversationMessage> messages,
  int? messageId,
) {
  if (messageId == null) {
    return null;
  }
  for (final message in messages) {
    if (message.messageId == messageId) {
      return message;
    }
  }
  return null;
}

String _buildEvidenceSummary({
  required String title,
  required String dateSpan,
  required int messageCount,
  required String? searchQuery,
  required int? matchPosition,
  required int matchCount,
  required int? anchorMessageId,
  required ConversationMessage? anchorMessage,
}) {
  final lines = <String>[
    'MessageLens conversation evidence summary',
    'Conversation: $title',
    if (dateSpan.isNotEmpty) 'Date span: $dateSpan',
    'Messages: ${_formatCount(messageCount)}',
  ];
  final normalizedSearchQuery = searchQuery?.trim();
  if (normalizedSearchQuery != null && normalizedSearchQuery.isNotEmpty) {
    lines.add('Search: "$normalizedSearchQuery"');
    lines.add('Loaded matches: ${_formatCount(matchCount)}');
    if (matchPosition != null) {
      lines.add('Selected match: ${matchPosition + 1} of $matchCount');
    }
  }
  if (anchorMessageId != null) {
    lines.add('Anchored message id: $anchorMessageId');
  }
  if (anchorMessage != null) {
    lines
      ..add('Anchored message date: ${anchorMessage.dateUtc ?? 'no date'}')
      ..add(
        'Anchored message direction: ${anchorMessage.isFromMe ? 'from me' : 'received'}',
      )
      ..add('Anchored message text: ${_summaryMessageText(anchorMessage)}');
  }
  return lines.join('\n');
}

String _summaryMessageText(ConversationMessage message) {
  final text = message.text?.trim();
  if (text == null || text.isEmpty) {
    return 'no text';
  }
  return text;
}

String _conversationTitle(
  ConversationOverview? overview,
  Map<String, ContactHandleLabel>? labels,
) {
  final participants = _conversationParticipants(overview, labels);
  if (participants.isEmpty) {
    return 'Unknown participants';
  }
  if (participants.length == 1) {
    return participants.first;
  }
  if (participants.length == 2) {
    return '${participants[0]} and ${participants[1]}';
  }
  return '${participants[0]}, ${participants[1]} + ${participants.length - 2} more';
}

List<String> _conversationParticipants(
  ConversationOverview? overview,
  Map<String, ContactHandleLabel>? labels,
) {
  final handles = overview?.participantHandles ?? const <String>[];
  final participants = <String>[];
  final seen = <String>{};
  for (final handle in handles) {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final label =
        labels?[contactHandleLabelKeyForTesting(trimmed)]?.displayName;
    final participant = label ?? trimmed;
    if (seen.add(participant.toLowerCase())) {
      participants.add(participant);
    }
  }
  return participants;
}

String _conversationDateSpan(ConversationOverview? overview) {
  final first = _formatDateLabel(overview?.firstMessageAtUtc);
  final last = _formatDateLabel(overview?.lastMessageAtUtc);
  if (first == null && last == null) {
    return '';
  }
  if (first == null) {
    return 'through $last';
  }
  if (last == null || first == last) {
    return first;
  }
  return '$first to $last';
}

String? _formatDateLabel(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}

int? _matchPosition(List<int> matchingMessageIds, int? anchorMessageId) {
  if (anchorMessageId == null) {
    return null;
  }
  final index = matchingMessageIds.indexOf(anchorMessageId);
  if (index < 0) {
    return null;
  }
  return index;
}

int? _previousMatchId(List<int> matchingMessageIds, int? anchorMessageId) {
  if (matchingMessageIds.isEmpty) {
    return null;
  }
  final index = anchorMessageId == null
      ? 0
      : matchingMessageIds.indexOf(anchorMessageId);
  if (index <= 0) {
    return matchingMessageIds.last;
  }
  return matchingMessageIds[index - 1];
}

int? _nextMatchId(List<int> matchingMessageIds, int? anchorMessageId) {
  if (matchingMessageIds.isEmpty) {
    return null;
  }
  final index = anchorMessageId == null
      ? -1
      : matchingMessageIds.indexOf(anchorMessageId);
  if (index < 0 || index == matchingMessageIds.length - 1) {
    return matchingMessageIds.first;
  }
  return matchingMessageIds[index + 1];
}

class _SearchReviewStrip extends ConsumerWidget {
  const _SearchReviewStrip({
    required this.query,
    required this.matchCount,
    required this.matchPosition,
    required this.isMatchingOnly,
    required this.hasMatches,
    required this.onPrevious,
    required this.onNext,
    required this.onMatchingOnlyChanged,
  });

  final String query;
  final int matchCount;
  final int? matchPosition;
  final bool isMatchingOnly;
  final bool hasMatches;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onMatchingOnlyChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final matchPositionLabel = matchPosition == null
        ? 'No selected match'
        : 'Match ${matchPosition! + 1} of $matchCount';

    return AppHeaderActionStrip(
      children: [
        Text(
          '${_formatCount(matchCount)} matches for "$query"',
          style: typography.callout,
        ),
        Text(matchPositionLabel, style: typography.caption),
        AppHeaderActionButton(
          icon: CupertinoIcons.chevron_up,
          label: 'Previous',
          isEnabled: hasMatches,
          onPressed: onPrevious,
        ),
        AppHeaderActionButton(
          icon: CupertinoIcons.chevron_down,
          label: 'Next',
          isEnabled: hasMatches,
          onPressed: onNext,
        ),
        _ChoiceButton(
          label: 'Matching only',
          isSelected: isMatchingOnly,
          onPressed: onMatchingOnlyChanged,
        ),
      ],
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

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ConversationMessageRow extends ConsumerWidget {
  const _ConversationMessageRow({
    super.key,
    required this.message,
    required this.isAnchorMessage,
    required this.searchQuery,
  });

  final ConversationMessage message;
  final bool isAnchorMessage;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final text = message.text;
    final direction = message.isFromMe ? 'from me' : 'received';
    final senderLabel = _messageSenderLabel(message);
    final associatedMessageId = message.associatedMessageId;
    final semanticBadges = _messageSemanticBadges(message);

    return Align(
      alignment: message.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? colors.messagePanels.accentTintSoft
                  : colors.surfaces.surface,
              border: Border.all(
                color: isAnchorMessage
                    ? colors.accents.primary
                    : colors.lines.borderSubtle,
                width: isAnchorMessage ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${message.messageId} | ${message.dateUtc ?? 'no date'} | '
                    '$direction | $senderLabel',
                    style: typography.caption,
                  ),
                  if (associatedMessageId != null ||
                      semanticBadges.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (associatedMessageId != null)
                          _EvidenceBadge(
                            label: 'associated $associatedMessageId',
                          ),
                        for (final badge in semanticBadges)
                          _EvidenceBadge(label: badge),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  if (_hasText(text))
                    SearchHighlightedText(
                      text: text!,
                      query: searchQuery,
                      style: typography.body,
                    )
                  else
                    Text(
                      'no text',
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  if (message.attachmentCount > 0) ...[
                    const SizedBox(height: 8),
                    _ConversationMessageAttachments(
                      messageId: message.messageId,
                      expectedAttachmentCount: message.attachmentCount,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _messageSenderLabel(ConversationMessage message) {
  if (message.isFromMe) {
    return 'me';
  }
  final handle = message.senderDisplayHandle?.trim();
  if (handle != null && handle.isNotEmpty) {
    return handle;
  }
  if (message.senderCanonicalHandleId != null) {
    return 'canonical handle ${message.senderCanonicalHandleId}';
  }
  if (message.senderHandleId != null) {
    return 'handle ${message.senderHandleId}';
  }
  return 'unknown sender';
}

List<String> _messageSemanticBadges(ConversationMessage message) {
  final badges = <String>[];
  final semanticKind = message.semanticKind?.trim();
  if (semanticKind != null && semanticKind.isNotEmpty) {
    badges.add(semanticKind);
  }
  final itemKind = message.itemKind?.trim();
  if (itemKind != null && itemKind.isNotEmpty) {
    badges.add(itemKind);
  }
  if (message.isSystemMessage) {
    badges.add('system');
  }
  if (message.isSparseArtifact) {
    badges.add('sparse');
  }
  if (message.hasAttributedBodySource) {
    badges.add('attributed body');
  }
  if (message.hasMessageSummaryInfo) {
    badges.add('summary info');
  }
  if (message.hasPayloadDataSource) {
    badges.add('payload');
  }
  if (message.errorCode != null) {
    badges.add('error ${message.errorCode}');
  }
  return badges;
}

class _EvidenceBadge extends ConsumerWidget {
  const _EvidenceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(label, style: typography.caption),
      ),
    );
  }
}

class _ConversationMessageAttachments extends ConsumerWidget {
  const _ConversationMessageAttachments({
    required this.messageId,
    required this.expectedAttachmentCount,
  });

  final int messageId;
  final int expectedAttachmentCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(messageAttachmentsProvider(messageId));
    return attachmentsAsync.when(
      data: (attachments) {
        if (attachments.isEmpty) {
          return Text('attachments: $expectedAttachmentCount linked');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('attachments: ${attachments.length}'),
            const SizedBox(height: 4),
            for (final attachment in attachments)
              _ConversationAttachmentChip(attachment: attachment),
          ],
        );
      },
      loading: () => Text('attachments: $expectedAttachmentCount loading'),
      error: (error, stackTrace) => Text('attachments failed: $error'),
    );
  }
}

class _ConversationAttachmentChip extends ConsumerWidget {
  const _ConversationAttachmentChip({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final name =
        attachment.transferName ??
        attachment.filename?.split('/').last ??
        attachment.guid ??
        'attachment ${attachment.attachmentSsId}';
    final archivePath = attachment.archiveAbsolutePath;
    final canOpenArchive =
        attachment.archiveFileExists &&
        archivePath != null &&
        archivePath.isNotEmpty;
    final status = canOpenArchive
        ? 'archived'
        : attachment.hasArchiveRecord
        ? 'archive missing'
        : 'not archived';

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaces.control,
          border: Border.all(color: colors.lines.borderSubtle),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text('$name | $status')),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: canOpenArchive
                    ? () => _openArchivedFile(archivePath)
                    : null,
                child: Text(
                  canOpenArchive ? 'Open' : 'Unavailable',
                  style: TextStyle(
                    color: canOpenArchive
                        ? colors.accents.primary
                        : colors.grayFour,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openArchivedFile(String archivedFilePath) async {
    await launchUrl(
      Uri.file(archivedFilePath),
      mode: LaunchMode.externalApplication,
    );
  }
}

bool _hasText(String? value) {
  return value != null && value.isNotEmpty;
}
