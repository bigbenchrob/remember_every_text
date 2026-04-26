import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart'
    show MacosTextField, MacosTooltip, ProgressCircle;
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../../../essentials/navigation/application/panel_widget_providers.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../application/view_spec/resolver_tools/message_context_anchor_provider.dart';
import '../../domain/entities/attachment_info.dart' as message_domain;
import '../../domain/value_objects/message_timeline_scope.dart';
import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import '../debug/contact_timeline_scroll_probe.dart';
import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import '../view_model/timeline/contact_timeline_display_version_provider.dart';
import '../view_model/timeline/hydration/message_by_id_provider.dart';
import '../view_model/timeline/hydration/message_by_ordinal_provider.dart';
import '../view_model/timeline/hydration/message_grouping_metadata_by_ordinal_provider.dart';
import '../view_model/timeline/message_timeline_view_model_provider.dart';
import '../view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../view_model/timeline/ordinal/message_timeline_index_coordinator_provider.dart';
import '../view_model/timeline/timeline_metadata_provider.dart';
import '../widgets/message_card.dart';
import '../widgets/message_context_anchor_chrome.dart';
import '../widgets/message_user_metadata_widgets.dart';

const Duration _contactMessageGroupingThreshold = Duration(minutes: 5);
const double _contactPendingIndicatorLaneHeight = 28;

String _formatRecoveredSemanticKind(String semanticKind) {
  return switch (semanticKind) {
    'plain-text' => 'text',
    'rich-text' => 'rich text',
    'edited-or-unsent' => 'edited / unsent',
    'associated' => 'associated',
    'balloon-or-app' => 'balloon / app',
    'attachment-only' => 'attachment only',
    'system' => 'system',
    'sparse-artifact' => 'sparse artifact',
    _ => 'unknown variant',
  };
}

bool _isRecoveredFallbackText(String text) {
  return switch (text) {
    '(Sparse artifact: no preserved text or payload)' => true,
    '(No plain text content; summary metadata preserved)' => true,
    '(No plain text content; app or balloon payload preserved)' => true,
    '(Associated message carrier without plain text)' => true,
    '(No text content)' => true,
    '(No plain text content)' => true,
    '(No preserved content)' => true,
    _ => false,
  };
}

bool _hasMeaningfulRecoveredText(RecoveredUnlinkedMessageItem message) {
  final trimmed = message.text.trim();
  if (trimmed.isEmpty) {
    return false;
  }

  return !_isRecoveredFallbackText(trimmed);
}

String _buildRecoveredStatusLine(RecoveredUnlinkedMessageItem message) {
  final hasMeaningfulText = _hasMeaningfulRecoveredText(message);
  final hasAttachments = message.hasAttachments;
  final service = message.service;

  if (message.semanticKind == 'attachment-only' && hasAttachments) {
    return '$service associated with recovered attachments';
  }

  if (hasMeaningfulText && hasAttachments) {
    return '$service with recovered text and attachments';
  }

  if (hasMeaningfulText) {
    return '$service with recovered text';
  }

  if (hasAttachments) {
    return '$service associated with recovered attachments';
  }

  return '$service with no recoverable text or attachments';
}

List<RecoveredUnlinkedMessageItem> _filterRecoveredMessagesById({
  required List<RecoveredUnlinkedMessageItem> messages,
  required List<int> matchingIds,
}) {
  final matchingIdSet = matchingIds.toSet();

  return messages
      .where((message) {
        return matchingIdSet.contains(message.id);
      })
      .toList(growable: false);
}

List<RecoveredUnlinkedMessageItem> _filterRecoveredMessagesForScope({
  required List<RecoveredUnlinkedMessageItem> messages,
  required RecoveredTimelineScope scope,
}) {
  return filterRecoveredTimelineMessages(
    messages: messages,
    onlyNoHandleFromMe: scope.onlyNoHandleFromMe,
  );
}

String _searchPlaceholder(MessageTimelineScope scope) {
  return switch (scope) {
    GlobalTimelineScope() => 'Search all messages',
    ContactTimelineScope() => 'Search messages with this contact',
    ChatTimelineScope() => 'Search this conversation',
    RecoveredTimelineScope() =>
      'Filter by text, sender, service, or attachment name',
  };
}

String _emptyTimelineMessage(MessageTimelineScope scope) {
  return switch (scope) {
    GlobalTimelineScope() => 'No messages indexed yet.',
    ContactTimelineScope() => 'No messages with this contact yet.',
    ChatTimelineScope() => 'No messages in this chat yet.',
    RecoveredTimelineScope() => 'No recovered messages in this scope yet.',
  };
}

double _messageColumnHorizontalPadding(MessageTimelineScope scope) {
  return switch (scope) {
    ContactTimelineScope() => 32,
    GlobalTimelineScope() => 32,
    ChatTimelineScope() => 16,
    RecoveredTimelineScope() => 32,
  };
}

MessageCardLayout _messageCardLayout(MessageTimelineScope scope) {
  return switch (scope) {
    ContactTimelineScope() => MessageCardLayout.analysis,
    GlobalTimelineScope() => MessageCardLayout.analysis,
    ChatTimelineScope() => MessageCardLayout.bubble,
    RecoveredTimelineScope() => MessageCardLayout.analysis,
  };
}

class _RecoveredTimelinePresentation {
  const _RecoveredTimelinePresentation._({
    required this.isNoHandleFromMe,
    required this.showLegend,
    required this.title,
    required this.description,
    required this.emptyStateMessage,
    required this.filteredEmptyMessage,
  });

  factory _RecoveredTimelinePresentation.fromScope(
    RecoveredTimelineScope scope,
  ) {
    final isContactScoped = scope.contactId != null;
    final isNoHandleFromMe = scope.onlyNoHandleFromMe;

    return _RecoveredTimelinePresentation._(
      isNoHandleFromMe: isNoHandleFromMe,
      showLegend: isContactScoped && !isNoHandleFromMe,
      title: isNoHandleFromMe
          ? 'Recovered no-handle messages'
          : 'Recovered deleted messages',
      description: isNoHandleFromMe
          ? 'Recovered orphaned records that still look like outgoing messages but no longer retain handle linkage. This is an experimental slice of the recovered dataset.'
          : isContactScoped
          ? "Showing recovered deleted-message candidates that appear to match this contact's linked handles. These records remain separate from the normal chat flow."
          : 'Source records recovered from `chat.db` without a normal chat link. Many may reflect conversations deleted on iPhone or iPad, but they remain separate from the normal chat flow.',
      emptyStateMessage: isNoHandleFromMe
          ? 'No recovered no-handle outgoing messages were found.'
          : isContactScoped
          ? "No recovered deleted messages matched this contact's linked handles."
          : 'No recovered deleted messages have been projected yet.',
      filteredEmptyMessage:
          'No recovered deleted messages match the current filter.',
    );
  }

  final bool isNoHandleFromMe;
  final bool showLegend;
  final String title;
  final String description;
  final String emptyStateMessage;
  final String filteredEmptyMessage;

  String countSummary({required int visibleCount, required int totalCount}) {
    if (isNoHandleFromMe) {
      return '$visibleCount of $totalCount recovered no-handle outgoing messages';
    }

    return '$visibleCount of $totalCount recovered deleted-message candidates';
  }
}

class _RecoveredTimelineContentPresentation {
  const _RecoveredTimelineContentPresentation({
    required this.countSummary,
    required this.legendCounts,
  });

  factory _RecoveredTimelineContentPresentation.fromMessages({
    required _RecoveredTimelinePresentation timelinePresentation,
    required List<RecoveredUnlinkedMessageItem> visibleMessages,
    required int totalCount,
  }) {
    final directCount = visibleMessages.where((message) {
      return !message.isInferred;
    }).length;
    final inferredCount = visibleMessages.where((message) {
      return message.isInferred;
    }).length;

    return _RecoveredTimelineContentPresentation(
      countSummary: timelinePresentation.countSummary(
        visibleCount: visibleMessages.length,
        totalCount: totalCount,
      ),
      legendCounts: timelinePresentation.showLegend
          ? _RecoveredLegendCounts(
              directCount: directCount,
              inferredCount: inferredCount,
            )
          : null,
    );
  }

  final String countSummary;
  final _RecoveredLegendCounts? legendCounts;
}

class _RecoveredLegendCounts {
  const _RecoveredLegendCounts({
    required this.directCount,
    required this.inferredCount,
  });

  final int directCount;
  final int inferredCount;
}

class _RecoveredTimelineSection extends ConsumerWidget {
  const _RecoveredTimelineSection({
    required this.scope,
    required this.timelinePresentation,
    required this.vm,
    required this.buildTimelineChild,
    required this.buildSearchChild,
  });

  final RecoveredTimelineScope scope;
  final _RecoveredTimelinePresentation timelinePresentation;
  final MessageTimelineViewModelState vm;
  final Widget Function() buildTimelineChild;
  final Widget Function() buildSearchChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMessages = ref.watch(
      recoveredUnlinkedMessagesProvider(contactId: scope.contactId),
    );

    return asyncMessages.when(
      data: (messages) {
        final bucketed = _filterRecoveredMessagesForScope(
          messages: messages,
          scope: scope,
        );

        if (bucketed.isEmpty) {
          return _EmptyRecoveredMessagesState(
            message: timelinePresentation.emptyStateMessage,
          );
        }

        if (vm.isSearching) {
          return vm.searchResultIds.when(
            data: (matchingIds) {
              final filtered = _filterRecoveredMessagesById(
                messages: bucketed,
                matchingIds: matchingIds,
              );

              if (filtered.isEmpty) {
                return _EmptyRecoveredMessagesState(
                  message: timelinePresentation.filteredEmptyMessage,
                );
              }

              return _RecoveredTimelineContent(
                presentation:
                    _RecoveredTimelineContentPresentation.fromMessages(
                      timelinePresentation: timelinePresentation,
                      visibleMessages: filtered,
                      totalCount: bucketed.length,
                    ),
                child: buildSearchChild(),
              );
            },
            loading: () => const Center(child: ProgressCircle()),
            error: (error, _) => _EmptyRecoveredMessagesState(
              message: 'Unable to filter recovered deleted messages: $error',
            ),
          );
        }

        return _RecoveredTimelineContent(
          presentation: _RecoveredTimelineContentPresentation.fromMessages(
            timelinePresentation: timelinePresentation,
            visibleMessages: bucketed,
            totalCount: bucketed.length,
          ),
          child: buildTimelineChild(),
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => _EmptyRecoveredMessagesState(
        message: 'Unable to load recovered deleted messages: $error',
      ),
    );
  }
}

/// Unified view for message timelines across all scopes.
///
/// Works with global, contact, and chat scopes using the same
/// virtual-scrolling infrastructure with scope-specific headers.
class MessagesTimelineView extends HookConsumerWidget {
  const MessagesTimelineView({
    required this.scope,
    this.scrollToDate,
    super.key,
  });

  /// The scope determining which messages to show.
  final MessageTimelineScope scope;

  /// Optional date to scroll to on initial load.
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final vm = ref.watch(messageTimelineViewModelProvider(scope: scope));
    final indexCoordinatorState = ref.watch(
      messageTimelineIndexCoordinatorProvider(scope: scope),
    );
    final AsyncValue<List<int>> pendingContactMessageIdsAsync;
    if (scope is ContactTimelineScope) {
      pendingContactMessageIdsAsync = ref.watch(
        pendingContactTimelineMessageIdsProvider(scope: scope),
      );
    } else {
      pendingContactMessageIdsAsync = const AsyncValue<List<int>>.data(<int>[]);
    }
    final pendingContactMessages =
        pendingContactMessageIdsAsync.valueOrNull ?? const <int>[];
    final hasPendingContactMessages = pendingContactMessages.isNotEmpty;
    final pendingIndicatorDismissed = useState(false);
    final previousPendingMessageCount = useRef<int>(0);

    useEffect(() {
      final previousCount = previousPendingMessageCount.value;
      final currentCount = pendingContactMessages.length;
      previousPendingMessageCount.value = currentCount;

      if (currentCount > previousCount) {
        pendingIndicatorDismissed.value = false;
      }

      if (currentCount == 0) {
        pendingIndicatorDismissed.value = false;
      }

      return null;
    }, [pendingContactMessages.length]);

    useEffect(
      () {
        if (!indexCoordinatorState.hasOrdinalState) {
          return null;
        }

        ref
            .read(
              messageTimelineIndexCoordinatorProvider(scope: scope).notifier,
            )
            .syncViewport(scrollToDate: scrollToDate);

        return null;
      },
      [
        indexCoordinatorState.hasOrdinalState,
        indexCoordinatorState.totalCount,
        ref,
        scope,
        scrollToDate,
      ],
    );

    final timelineSurfaceColor = switch (scope) {
      ContactTimelineScope() => colors.messagePanels.coolPanelSurface,
      GlobalTimelineScope() => colors.messagePanels.coolPanelSurface,
      ChatTimelineScope() => colors.messagePanels.surface,
      RecoveredTimelineScope() => colors.messagePanels.coolPanelSurface,
    };

    // Build scope-specific scaffold
    return switch (scope) {
      GlobalTimelineScope() => _buildGlobalScaffold(
        context,
        ref,
        vm,
        timelineSurfaceColor,
        timelineSurfaceColor,
      ),
      ContactTimelineScope(:final contactId) => _buildContactScaffold(
        context,
        ref,
        vm,
        contactId,
        hasPendingContactMessages,
        pendingContactMessages,
        hasPendingContactMessages && !pendingIndicatorDismissed.value,
        () {
          pendingIndicatorDismissed.value = true;
        },
        timelineSurfaceColor,
        timelineSurfaceColor,
      ),
      ChatTimelineScope(:final chatId) => _buildChatScaffold(
        context,
        ref,
        vm,
        chatId,
        timelineSurfaceColor,
        timelineSurfaceColor,
      ),
      RecoveredTimelineScope() => _buildRecoveredScaffold(
        context,
        ref,
        vm,
        scope as RecoveredTimelineScope,
        timelineSurfaceColor,
        timelineSurfaceColor,
      ),
    };
  }

  Widget _buildRecoveredScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    RecoveredTimelineScope recoveredScope,
    Color chromeBg,
    Color messageListBg,
  ) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final presentation = _RecoveredTimelinePresentation.fromScope(
      recoveredScope,
    );

    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tray_arrow_down_fill,
                      size: 24,
                      color: colors.content.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(presentation.title, style: typography.title1),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(presentation.description, style: typography.callout),
              ],
            ),
          ),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _RecoveredTimelineSection(
                scope: recoveredScope,
                timelinePresentation: presentation,
                vm: vm,
                buildTimelineChild: () {
                  return _buildMessageList(context, ref, vm);
                },
                buildSearchChild: () {
                  return _SearchResultsList(vm: vm, scope: scope);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GlobalHeader(scope: scope, scrollToDate: scrollToDate),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _buildMessageList(context, ref, vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    int contactId,
    bool hasPendingContactMessages,
    List<int> pendingContactMessageIds,
    bool showPendingGlowBar,
    VoidCallback dismissPendingGlowBar,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContactHeader(
            contactId: contactId,
            scope: scope,
            scrollToDate: scrollToDate,
          ),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) {
                dismissPendingGlowBar();
              },
              child: _FadeOverlayList(
                backgroundColor: messageListBg,
                child: _buildMessageList(
                  context,
                  ref,
                  vm,
                  hasPendingContactMessages: hasPendingContactMessages,
                  pendingContactMessageIds: pendingContactMessageIds,
                  onUserInteraction: dismissPendingGlowBar,
                ),
              ),
            ),
          ),
          ColoredBox(
            color: messageListBg,
            child: IgnorePointer(
              child: _PendingMessagesGlowBar(isActive: showPendingGlowBar),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    int chatId,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChatHeader(chatId: chatId, scope: scope, scrollToDate: scrollToDate),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _buildMessageList(context, ref, vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm, {
    bool hasPendingContactMessages = false,
    List<int> pendingContactMessageIds = const <int>[],
    VoidCallback? onUserInteraction,
  }) {
    if (vm.isSearching) {
      return _SearchResultsList(vm: vm, scope: scope);
    }

    final typography = ref.watch(themeTypographyProvider);
    final resolvedOrdinalState = vm.ordinal.valueOrNull;

    if (resolvedOrdinalState == null) {
      return vm.ordinal.when(
        data: (_) => const SizedBox.shrink(),
        loading: () => const Center(child: ProgressCircle()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load timeline: $error'),
          ),
        ),
      );
    }

    if (resolvedOrdinalState.totalCount == 0) {
      return Center(
        child: Text(_emptyTimelineMessage(scope), style: typography.title3),
      );
    }

    final showPendingMessages =
        scope is ContactTimelineScope && hasPendingContactMessages;
    final itemCount =
        resolvedOrdinalState.totalCount + pendingContactMessageIds.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final shouldProbe =
            scope is ContactTimelineScope &&
            ContactTimelineScrollProbe.shouldEnable(ref);

        if (shouldProbe) {
          if (notification is ScrollStartNotification) {
            ContactTimelineScrollProbe.startSession(
              scope: scope,
              trigger: 'scroll_start',
            );
            ContactTimelineScrollProbe.count('viewport.notification.start');
          } else if (notification is ScrollUpdateNotification) {
            ContactTimelineScrollProbe.count('viewport.notification.update');
          } else if (notification is UserScrollNotification) {
            ContactTimelineScrollProbe.count(
              'viewport.notification.user_${notification.direction.name}',
            );
          } else if (notification is ScrollEndNotification) {
            ContactTimelineScrollProbe.count('viewport.notification.end');
            ContactTimelineScrollProbe.scheduleFlush(reason: 'scroll_end');
          }
        }

        if (notification is ScrollStartNotification ||
            notification is ScrollUpdateNotification ||
            notification is UserScrollNotification) {
          onUserInteraction?.call();
        }

        return false;
      },
      child: ScrollablePositionedList.builder(
        itemScrollController: resolvedOrdinalState.itemScrollController,
        itemPositionsListener: resolvedOrdinalState.itemPositionsListener,
        itemCount: itemCount,
        padding: EdgeInsets.symmetric(
          horizontal: _messageColumnHorizontalPadding(scope),
        ),
        itemBuilder: (context, index) {
          if (showPendingMessages && index >= resolvedOrdinalState.totalCount) {
            final pendingIndex = index - resolvedOrdinalState.totalCount;
            final messageId = pendingContactMessageIds[pendingIndex];
            final previousPendingMessageId = pendingIndex > 0
                ? pendingContactMessageIds[pendingIndex - 1]
                : null;
            final nextPendingMessageId =
                pendingIndex + 1 < pendingContactMessageIds.length
                ? pendingContactMessageIds[pendingIndex + 1]
                : null;
            final previousDisplayedOrdinal =
                pendingIndex == 0 && resolvedOrdinalState.totalCount > 0
                ? resolvedOrdinalState.totalCount - 1
                : null;

            return _PendingMessageRow(
              scope: scope,
              messageId: messageId,
              previousPendingMessageId: previousPendingMessageId,
              nextPendingMessageId: nextPendingMessageId,
              previousDisplayedOrdinal: previousDisplayedOrdinal,
            );
          }

          return _MessageRow(scope: scope, ordinal: index);
        },
      ),
    );
  }
}

class _PendingMessageRow extends ConsumerWidget {
  const _PendingMessageRow({
    required this.scope,
    required this.messageId,
    required this.previousPendingMessageId,
    required this.nextPendingMessageId,
    required this.previousDisplayedOrdinal,
  });

  final MessageTimelineScope scope;
  final int messageId;
  final int? previousPendingMessageId;
  final int? nextPendingMessageId;
  final int? previousDisplayedOrdinal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(messageByIdProvider(messageId: messageId));
    final previousItemAsync = previousPendingMessageId != null
        ? ref.watch(messageByIdProvider(messageId: previousPendingMessageId!))
        : previousDisplayedOrdinal != null
        ? ref.watch(
            messageByTimelineOrdinalProvider(
              scope: scope,
              ordinal: previousDisplayedOrdinal!,
            ),
          )
        : const AsyncValue<MessageListItem?>.data(null);
    final nextItemAsync = nextPendingMessageId != null
        ? ref.watch(messageByIdProvider(messageId: nextPendingMessageId!))
        : const AsyncValue<MessageListItem?>.data(null);

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const _SkeletonRow();
        }

        final grouping = _groupingStyleFor(
          current: _groupingMetadataForItem(item),
          previous: previousItemAsync.valueOrNull == null
              ? null
              : _groupingMetadataForItem(previousItemAsync.valueOrNull!),
          next: nextItemAsync.valueOrNull == null
              ? null
              : _groupingMetadataForItem(nextItemAsync.valueOrNull!),
          scope: scope,
        );

        return MessageUserMetadataCardDecorator(
          message: item,
          child: MessageCard(
            message: item,
            layout: MessageCardLayout.analysis,
            grouping: grouping,
          ),
        );
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Pending message failed: $error'),
      ),
    );
  }
}

class _PendingMessagesGlowBar extends ConsumerStatefulWidget {
  const _PendingMessagesGlowBar({required this.isActive});

  final bool isActive;

  @override
  ConsumerState<_PendingMessagesGlowBar> createState() =>
      _PendingMessagesGlowBarState();
}

class _PendingMessagesGlowBarState
    extends ConsumerState<_PendingMessagesGlowBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.52,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scale = Tween<double>(
      begin: 0.975,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final accentColor = colors.accents.focusRing;
    final trackColor = accentColor.withValues(alpha: 0.22);

    return Center(
      child: SizedBox(
        width: 132,
        height: _contactPendingIndicatorLaneHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const SizedBox(width: 104, height: 3),
            ),
            if (widget.isActive)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scaleX: _scale.value,
                    child: Opacity(
                      opacity: _opacity.value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              accentColor.withValues(alpha: 0),
                              accentColor.withValues(alpha: 0.92),
                              accentColor.withValues(alpha: 0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.34),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const SizedBox(width: 126, height: 5),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Wraps the message list with a scroll-driven gradient fade overlay at top.
///
/// The overlay is invisible at rest and only appears during scroll motion,
/// providing a soft collision boundary without becoming a visible surface.
///
/// ## Design Contract
///
/// Top-of-list blur is interaction-driven, not layout-driven.
/// It must be invisible at rest, engage only during scrolling, and fade out
/// immediately when motion stops. Height ≤ 24pt and strength must not be
/// perceptible as a visual element.
class _FadeOverlayList extends StatefulWidget {
  const _FadeOverlayList({required this.backgroundColor, required this.child});

  final Color backgroundColor;
  final Widget child;

  @override
  State<_FadeOverlayList> createState() => _FadeOverlayListState();
}

class _FadeOverlayListState extends State<_FadeOverlayList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Fast fade in
      reverseDuration: const Duration(milliseconds: 300), // Slower fade out
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      // User started scrolling — show overlay
      _controller.forward();
    } else if (notification is ScrollEndNotification) {
      // User stopped scrolling — hide overlay
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification);
          return false; // Don't consume the notification
        },
        child: Stack(
          children: [
            widget.child,
            // Scroll-driven gradient fade overlay at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20, // Shallow: just enough to soften collision
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.6),
                          widget.backgroundColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Unified search bar with mode toggle for all timeline scopes.
class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.scope, required this.vm});

  final MessageTimelineScope scope;
  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final decoration = BoxDecoration(
      color: colors.surfaces.control,
      border: Border.all(color: colors.lines.borderSubtle),
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    );
    final focusedDecoration = BoxDecoration(
      color: colors.surfaces.control,
      border: Border.all(color: colors.accents.focusRing, width: 2),
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    );

    return Padding(
      // Top: tight gap from header; bottom: looser gap to content
      padding: const EdgeInsets.fromLTRB(
        16,
        AppSpacing
            .xs, // Completes panelHeaderToControlsGap (header: 8 + search: 4 = 12)
        16,
        AppSpacing.panelControlsToContentGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: MacosTextField(
              controller: vm.searchController,
              placeholder: _searchPlaceholder(scope),
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
              decoration: decoration,
              focusedDecoration: focusedDecoration,
            ),
          ),
          const SizedBox(width: 12),
          _SearchModeToggle(scope: scope, mode: vm.searchMode),
        ],
      ),
    );
  }
}

/// Search mode toggle buttons.
class _SearchModeToggle extends ConsumerWidget {
  const _SearchModeToggle({required this.scope, required this.mode});

  final MessageTimelineScope scope;
  final MessageSearchMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isDark = colors.isDark;
    final activeColor = CupertinoColors.systemBlue.resolveFrom(context);
    final inactiveColor = isDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MacosTooltip(
          message: 'All terms must match',
          child: GestureDetector(
            onTap: () => ref
                .read(messageTimelineViewModelProvider(scope: scope).notifier)
                .setSearchMode(MessageSearchMode.allTerms),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mode == MessageSearchMode.allTerms
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: mode == MessageSearchMode.allTerms
                      ? activeColor.withValues(alpha: 0.4)
                      : inactiveColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'AND',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mode == MessageSearchMode.allTerms
                      ? activeColor
                      : inactiveColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        MacosTooltip(
          message: 'Any term can match',
          child: GestureDetector(
            onTap: () => ref
                .read(messageTimelineViewModelProvider(scope: scope).notifier)
                .setSearchMode(MessageSearchMode.anyTerm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mode == MessageSearchMode.anyTerm
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: mode == MessageSearchMode.anyTerm
                      ? activeColor.withValues(alpha: 0.4)
                      : inactiveColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mode == MessageSearchMode.anyTerm
                      ? activeColor
                      : inactiveColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Header for global (all messages) view.
class _GlobalHeader extends ConsumerWidget {
  const _GlobalHeader({required this.scope, this.scrollToDate});

  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Shows current scroll position when viewing a portion of the timeline.
class _ScrollPositionIndicator extends StatelessWidget {
  const _ScrollPositionIndicator({this.scrollToDate, this.visibleMonthKey});

  /// The date explicitly requested via navigation (e.g., from heatmap click).
  final DateTime? scrollToDate;

  /// The month key of the currently visible top message (e.g., '2023-06').
  final String? visibleMonthKey;

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText();
    if (displayText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 12,
            color: CupertinoColors.systemBlue.resolveFrom(context),
          ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  String? _getDisplayText() {
    // Prefer explicit scroll-to date when navigating from heatmap
    if (scrollToDate != null) {
      return 'SCROLLED TO ${DateFormat('MMMM yyyy').format(scrollToDate!)}';
    }

    // Fall back to currently visible month from scroll position
    if (visibleMonthKey != null && visibleMonthKey!.isNotEmpty) {
      final parts = visibleMonthKey!.split('-');
      if (parts.length == 2) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (year != null && month != null) {
          final date = DateTime(year, month);
          return 'VIEWING ${DateFormat('MMMM yyyy').format(date).toUpperCase()}';
        }
      }
    }

    return null;
  }
}

/// Header for contact message view.
class _ContactHeader extends ConsumerWidget {
  const _ContactHeader({
    required this.contactId,
    required this.scope,
    this.scrollToDate,
  });

  final int contactId;
  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

    // Get contact profile for display name
    final profileAsync = ref.watch(
      contactProfileProvider(contactId: contactId),
    );
    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final displayName = profileAsync.valueOrNull?.displayName ?? 'Contact';
    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All messages from $displayName',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Header for chat message view.
class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({
    required this.chatId,
    required this.scope,
    this.scrollToDate,
  });

  final int chatId;
  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Single message row with hydration.
class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.scope, required this.ordinal});

  final MessageTimelineScope scope;
  final int ordinal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scope case final RecoveredTimelineScope recoveredScope) {
      return _RecoveredResolvedRow(
        scope: recoveredScope,
        locator: _RecoveredRowLocator.forOrdinal(ordinal),
      );
    }

    final itemAsync = ref.watch(
      messageByTimelineOrdinalProvider(scope: scope, ordinal: ordinal),
    );
    final previousMetadataAsync = ordinal > 0 && scope is ContactTimelineScope
        ? ref.watch(
            messageGroupingMetadataByTimelineOrdinalProvider(
              scope: scope,
              ordinal: ordinal - 1,
            ),
          )
        : const AsyncValue<MessageGroupingMetadata?>.data(null);
    final nextMetadataAsync = scope is ContactTimelineScope
        ? ref.watch(
            messageGroupingMetadataByTimelineOrdinalProvider(
              scope: scope,
              ordinal: ordinal + 1,
            ),
          )
        : const AsyncValue<MessageGroupingMetadata?>.data(null);

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const _SkeletonRow();
        }
        final grouping = _groupingStyleFor(
          current: _groupingMetadataForItem(item),
          previous: previousMetadataAsync.valueOrNull,
          next: nextMetadataAsync.valueOrNull,
          scope: scope,
        );
        return MessageUserMetadataCardDecorator(
          message: item,
          child: MessageCard(
            message: item,
            layout: _messageCardLayout(scope),
            grouping: grouping,
          ),
        );
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Row $ordinal failed: $error'),
      ),
    );
  }
}

MessageGroupingMetadata _groupingMetadataForItem(MessageListItem item) {
  return MessageGroupingMetadata(
    chatId: item.chatId,
    isFromMe: item.isFromMe,
    senderName: item.senderName,
    text: item.text,
    sentAt: item.sentAt,
    hasAttachments: item.hasAttachments,
  );
}

MessageGroupingStyle _groupingStyleFor({
  required MessageGroupingMetadata current,
  required MessageGroupingMetadata? previous,
  required MessageGroupingMetadata? next,
  required MessageTimelineScope scope,
}) {
  if ((scope is! ContactTimelineScope && scope is! GlobalTimelineScope) ||
      previous == null) {
    final nextContinues = next != null && _messagesCanCluster(current, next);
    if (!nextContinues) {
      return MessageGroupingStyle.standalone;
    }

    return const MessageGroupingStyle(
      role: MessageClusterRole.first,
      showSenderHeader: true,
      compactTopSpacing: false,
      compactBottomSpacing: true,
      softenContinuationChrome: false,
    );
  }

  final continuesFromPrevious = _messagesCanCluster(previous, current);
  final continuesToNext = next != null && _messagesCanCluster(current, next);

  if (!continuesFromPrevious && !continuesToNext) {
    return MessageGroupingStyle.standalone;
  }

  if (!continuesFromPrevious && continuesToNext) {
    return const MessageGroupingStyle(
      role: MessageClusterRole.first,
      showSenderHeader: true,
      compactTopSpacing: false,
      compactBottomSpacing: true,
      softenContinuationChrome: false,
    );
  }

  if (continuesFromPrevious && continuesToNext) {
    return const MessageGroupingStyle(
      role: MessageClusterRole.middle,
      showSenderHeader: false,
      compactTopSpacing: true,
      compactBottomSpacing: true,
      softenContinuationChrome: true,
    );
  }

  return const MessageGroupingStyle(
    role: MessageClusterRole.last,
    showSenderHeader: false,
    compactTopSpacing: true,
    compactBottomSpacing: false,
    softenContinuationChrome: true,
  );
}

bool _messagesCanCluster(
  MessageGroupingMetadata previous,
  MessageGroupingMetadata current,
) {
  if (_isMediaBoundaryMessage(previous) || _isMediaBoundaryMessage(current)) {
    return false;
  }

  if (previous.chatId != current.chatId) {
    return false;
  }

  final currentSentAt = current.sentAt;
  final previousSentAt = previous.sentAt;
  if (currentSentAt == null || previousSentAt == null) {
    return false;
  }

  final sameSender =
      current.isFromMe == previous.isFromMe &&
      current.senderName == previous.senderName;
  final timeDelta = currentSentAt.difference(previousSentAt);

  return sameSender &&
      !timeDelta.isNegative &&
      timeDelta <= _contactMessageGroupingThreshold;
}

bool _isMediaBoundaryMessage(MessageGroupingMetadata item) {
  if (item.hasAttachments) {
    return true;
  }

  final trimmedText = item.text.trim();
  if (trimmedText.isEmpty) {
    return false;
  }

  final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
  final matches = urlRegex.allMatches(trimmedText).toList();
  return matches.length == 1 && matches.first.group(0) == trimmedText;
}

/// Skeleton placeholder while message is loading.
class _SkeletonRow extends ConsumerWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: colors.surfaces.canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.divider.withValues(alpha: 0.35)),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Search results list with virtual scrolling.
///
/// Uses on-demand hydration like the main timeline for fast initial display.
class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList({required this.vm, required this.scope});

  final MessageTimelineViewModelState vm;
  final MessageTimelineScope scope;

  double get _horizontalPadding {
    return _messageColumnHorizontalPadding(scope);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return vm.searchResultIds.when(
      data: (resultIds) {
        if (resultIds.isEmpty) {
          return Center(
            child: Text('No matches found for "${vm.debouncedQuery}"'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                _horizontalPadding,
                8,
                _horizontalPadding,
                8,
              ),
              child: Text(
                '${resultIds.length} results',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.content.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                itemCount: resultIds.length,
                itemBuilder: (context, index) {
                  return _SearchResultRow(
                    messageId: resultIds[index],
                    scope: scope,
                    query: vm.debouncedQuery,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(child: Text('Search failed: $error')),
    );
  }
}

/// Single search result row with on-demand hydration.
class _SearchResultRow extends ConsumerWidget {
  const _SearchResultRow({
    required this.messageId,
    required this.scope,
    required this.query,
  });

  final int messageId;
  final MessageTimelineScope scope;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scope case final RecoveredTimelineScope recoveredScope) {
      return _RecoveredResolvedRow(
        scope: recoveredScope,
        locator: _RecoveredRowLocator.forMessage(messageId),
      );
    }

    final itemAsync = ref.watch(messageByIdProvider(messageId: messageId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const _SkeletonRow();
        }
        if (scope is GlobalTimelineScope) {
          return _SearchResultMessageCard(
            item: item,
            debugIdPrefix: 'global-search',
            query: query,
          );
        }

        if (scope is ContactTimelineScope) {
          return _SearchResultMessageCard(
            item: item,
            debugIdPrefix: 'contact-search',
            query: query,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageUserMetadataCardDecorator(
              message: item,
              child: MessageCard(
                message: item,
                layout: _messageCardLayout(scope),
              ),
            ),
            MessageSearchMatchMetadata(message: item, query: query),
          ],
        );
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Message $messageId failed: $error'),
      ),
    );
  }
}

class _SearchResultMessageCard extends HookConsumerWidget {
  const _SearchResultMessageCard({
    required this.item,
    required this.debugIdPrefix,
    required this.query,
  });

  final MessageListItem item;
  final String debugIdPrefix;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeContextAnchor = ref.watch(messageContextAnchorProvider);
    final canShowContextAction =
        item.text.trim().isNotEmpty &&
        !_isMediaBoundaryMessage(_groupingMetadataForItem(item));
    final isContextAnchor =
        activeContextAnchor?.matches(messageId: item.id, chatId: item.chatId) ??
        false;

    final secondaryAction = canShowContextAction && !isContextAnchor
        ? _ContextSidebarIconAction(item: item, isRowHovered: true)
        : null;

    return MessageContextAnchorChrome(
      isContextAnchor: isContextAnchor,
      activationKey: activeContextAnchor?.activationKey,
      debugId: '$debugIdPrefix-${item.id}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessageUserMetadataCardDecorator(
            message: item,
            secondaryAction: secondaryAction,
            child: MessageCard(
              message: item,
              layout: MessageCardLayout.analysis,
            ),
          ),
          MessageSearchMatchMetadata(message: item, query: query),
        ],
      ),
    );
  }
}

class _RecoveredTimelineContent extends ConsumerWidget {
  const _RecoveredTimelineContent({
    required this.presentation,
    required this.child,
  });

  final _RecoveredTimelineContentPresentation presentation;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (presentation.legendCounts case final legendCounts?)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: _RecoveredLegend(
              directCount: legendCounts.directCount,
              inferredCount: legendCounts.inferredCount,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(presentation.countSummary, style: typography.caption1),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

class _RecoveredResolvedRow extends ConsumerWidget {
  const _RecoveredResolvedRow({required this.scope, required this.locator});

  final RecoveredTimelineScope scope;
  final _RecoveredRowLocator locator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(
      recoveredUnlinkedMessagesProvider(contactId: scope.contactId),
    );

    return messagesAsync.when(
      data: (messages) {
        final filtered = _filterRecoveredMessagesForScope(
          messages: messages,
          scope: scope,
        );
        final resolvedMessage = locator.resolve(filtered);
        if (resolvedMessage == null) {
          return const _SkeletonRow();
        }

        return _RecoveredMessageRowChrome(message: resolvedMessage);
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('${locator.errorPrefix} failed: $error'),
      ),
    );
  }
}

class _RecoveredRowLocator {
  const _RecoveredRowLocator.forOrdinal(this.ordinal) : messageId = null;

  const _RecoveredRowLocator.forMessage(this.messageId) : ordinal = null;

  final int? ordinal;
  final int? messageId;

  String get errorPrefix {
    if (ordinal case final int resolvedOrdinal) {
      return 'Recovered row $resolvedOrdinal';
    }

    return 'Recovered message $messageId';
  }

  RecoveredUnlinkedMessageItem? resolve(
    List<RecoveredUnlinkedMessageItem> messages,
  ) {
    if (ordinal case final int resolvedOrdinal) {
      if (resolvedOrdinal < 0 || resolvedOrdinal >= messages.length) {
        return null;
      }

      return messages[resolvedOrdinal];
    }

    return messages.where((item) {
      return item.id == messageId;
    }).firstOrNull;
  }
}

_SelectedRecoveredAttachment? _selectedRecoveredAttachment(WidgetRef ref) {
  final rightSpec = ref.watch(
    effectiveRightPanelSpecProvider(SidebarMode.messages),
  );

  return rightSpec?.when(
    messages: (messagesSpec) => messagesSpec.mapOrNull(
      recoveredAttachmentViewer: (selectedSpec) => _SelectedRecoveredAttachment(
        messageId: selectedSpec.messageId,
        attachmentId: selectedSpec.attachment.id,
      ),
    ),
    settings: (_) => null,
    import: (_) => null,
    onboarding: (_) => null,
    environmentReadiness: (_) => null,
  );
}

List<message_domain.AttachmentInfo> _visibleRecoveredAttachments(
  RecoveredUnlinkedMessageItem message,
) {
  return message.attachments.take(6).toList(growable: false);
}

String _recoveredAttachmentLabel(
  message_domain.AttachmentInfo attachment,
  int index,
) {
  final transferName = attachment.transferName?.trim();
  if (transferName != null && transferName.isNotEmpty) {
    return transferName;
  }

  final resolvedPath = attachment.resolvedLocalPath()?.trim();
  if (resolvedPath != null && resolvedPath.isNotEmpty) {
    final segments = resolvedPath.split('/');
    final lastSegment = segments.isEmpty ? resolvedPath : segments.last.trim();
    if (lastSegment.isNotEmpty) {
      return lastSegment;
    }
  }

  return 'Attachment ${index + 1}';
}

String _buildRecoveredHeaderTitle(RecoveredUnlinkedMessageItem message) {
  if (message.isFromMe) {
    return 'You';
  }

  final contactName = message.contactName?.trim();
  final senderLabel = message.senderLabel.trim();
  final hasContactName = contactName != null && contactName.isNotEmpty;
  final hasConcreteSenderLabel =
      senderLabel.isNotEmpty && senderLabel != 'Unknown Sender';

  if (hasContactName && hasConcreteSenderLabel) {
    return '$contactName • $senderLabel';
  }

  if (hasContactName) {
    return 'Contact: $contactName';
  }

  return 'Unknown Sender';
}

List<String> _recoveredDeveloperFacts(RecoveredUnlinkedMessageItem message) {
  return [
    'Message ID: ${message.id}',
    'Semantic: ${_formatRecoveredSemanticKind(message.semanticKind)}',
    if (message.isSparseArtifact) 'Sparse artifact',
    if (message.rawItemType != null) 'Raw item_type: ${message.rawItemType}',
    if (message.rawAssociatedMessageType != null)
      'Raw associated_message_type: ${message.rawAssociatedMessageType}',
  ];
}

class _RecoveredAttachmentPresentation {
  const _RecoveredAttachmentPresentation({
    required this.attachment,
    required this.label,
    required this.isSelected,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final message_domain.AttachmentInfo attachment;
  final String label;
  final bool isSelected;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}

class _RecoveredLegendChipPresentation {
  const _RecoveredLegendChipPresentation({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
}

class _RecoveredLegendPresentation {
  const _RecoveredLegendPresentation({
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.description,
    required this.chips,
  });

  factory _RecoveredLegendPresentation.from({
    required ThemeColors colors,
    required int directCount,
    required int inferredCount,
  }) {
    return _RecoveredLegendPresentation(
      backgroundColor: colors.messagePanels.supportSurface,
      borderColor: colors.messagePanels.cardBorder,
      titleColor: colors.content.textSecondary,
      description:
          'Attributed matches are linked by surviving sender identity. Best-guess rows are nearby outgoing no-handle records shown as a conservative heuristic for deleted-conversation context.',
      chips: <_RecoveredLegendChipPresentation>[
        _RecoveredLegendChipPresentation(
          label: '$directCount attributed',
          backgroundColor: colors.surfaces.surface,
          borderColor: colors.lines.borderSubtle,
        ),
        _RecoveredLegendChipPresentation(
          label: '$inferredCount best guess',
          backgroundColor: colors.accents.primary.withValues(alpha: 0.10),
          borderColor: colors.accents.primary.withValues(alpha: 0.28),
        ),
      ],
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final String description;
  final List<_RecoveredLegendChipPresentation> chips;
}

class _RecoveredMessagePresentation {
  const _RecoveredMessagePresentation({
    required this.headerTitle,
    required this.timestampLabel,
    required this.statusLine,
    required this.cardColor,
    required this.borderColor,
    required this.showInferredHint,
    required this.text,
    required this.attachments,
    required this.developerFacts,
  });

  factory _RecoveredMessagePresentation.from({
    required RecoveredUnlinkedMessageItem message,
    required ThemeColors colors,
    required DateFormat dateFormatter,
    required bool isDeveloperMode,
    required _SelectedRecoveredAttachment? selectedAttachment,
  }) {
    final isSparseArtifact = message.isSparseArtifact;
    final isFromMe = message.isFromMe;
    final isSelectedMessage = selectedAttachment?.messageId == message.id;
    final backgroundColor = message.isInferred
        ? colors.messagePanels.accentTint
        : isFromMe
        ? colors.messagePanels.accentTintSoft
        : isSparseArtifact
        ? colors.messagePanels.mutedTint
        : colors.messagePanels.card;
    final baseBorderColor = message.isInferred
        ? colors.messagePanels.accentBorder
        : isFromMe
        ? colors.messagePanels.accentBorderSoft
        : isSparseArtifact
        ? colors.messagePanels.mutedBorder
        : colors.messagePanels.cardBorder;
    final visibleAttachments = _visibleRecoveredAttachments(message);
    final attachments = <_RecoveredAttachmentPresentation>[
      for (var index = 0; index < visibleAttachments.length; index += 1)
        _RecoveredAttachmentPresentation(
          backgroundColor:
              selectedAttachment?.messageId == message.id &&
                  selectedAttachment?.attachmentId ==
                      visibleAttachments[index].id
              ? colors.messagePanels.chipSelectionTint
              : colors.messagePanels.supportSurface,
          attachment: visibleAttachments[index],
          borderColor:
              selectedAttachment?.messageId == message.id &&
                  selectedAttachment?.attachmentId ==
                      visibleAttachments[index].id
              ? colors.messagePanels.selectionBorder
              : colors.messagePanels.chipBorder,
          label: _recoveredAttachmentLabel(visibleAttachments[index], index),
          isSelected:
              selectedAttachment?.messageId == message.id &&
              selectedAttachment?.attachmentId == visibleAttachments[index].id,
          textColor:
              selectedAttachment?.messageId == message.id &&
                  selectedAttachment?.attachmentId ==
                      visibleAttachments[index].id
              ? colors.accents.primary
              : colors.content.textPrimary,
        ),
    ];

    return _RecoveredMessagePresentation(
      headerTitle: _buildRecoveredHeaderTitle(message),
      timestampLabel: message.sentAt == null
          ? 'Unknown date'
          : dateFormatter.format(message.sentAt!),
      statusLine: _buildRecoveredStatusLine(message),
      cardColor: isSelectedMessage
          ? colors.messagePanels.selectionTint
          : backgroundColor,
      borderColor: isSelectedMessage
          ? colors.messagePanels.selectionBorder
          : baseBorderColor,
      showInferredHint: message.isInferred,
      text: _hasMeaningfulRecoveredText(message) ? message.text : null,
      attachments: attachments,
      developerFacts: isDeveloperMode
          ? _recoveredDeveloperFacts(message)
          : const <String>[],
    );
  }

  final String headerTitle;
  final String timestampLabel;
  final String statusLine;
  final Color cardColor;
  final Color borderColor;
  final bool showInferredHint;
  final String? text;
  final List<_RecoveredAttachmentPresentation> attachments;
  final List<String> developerFacts;
}

class _EmptyRecoveredMessagesState extends ConsumerWidget {
  const _EmptyRecoveredMessagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.tray,
              size: 36,
              color: colors.content.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: typography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecoveredMessageRowChrome extends ConsumerWidget {
  const _RecoveredMessageRowChrome({required this.message});

  final RecoveredUnlinkedMessageItem message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');
    final presentation = _RecoveredMessagePresentation.from(
      message: message,
      colors: colors,
      dateFormatter: dateFormatter,
      isDeveloperMode: isDeveloperMode,
      selectedAttachment: _selectedRecoveredAttachment(ref),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: presentation.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: presentation.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  presentation.headerTitle,
                  style: typography.headline,
                ),
              ),
              Text(presentation.timestampLabel, style: typography.caption1),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            presentation.statusLine,
            style: typography.caption1.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          if (presentation.showInferredHint) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Best guess: inferred from nearby recovered messages for this contact.',
              style: typography.caption1.copyWith(
                color: colors.accents.primary.withValues(alpha: 0.92),
              ),
            ),
          ],
          if (presentation.text case final recoveredText?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(recoveredText, style: typography.body),
          ],
          if (presentation.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final attachment in presentation.attachments)
                  _RecoveredAttachmentChip(
                    attachment: attachment.attachment,
                    messageId: message.id,
                    presentation: attachment,
                  ),
              ],
            ),
          ],
          if (presentation.developerFacts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              presentation.developerFacts.join(' • '),
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveredAttachmentChip extends ConsumerWidget {
  const _RecoveredAttachmentChip({
    required this.attachment,
    required this.messageId,
    required this.presentation,
  });

  final message_domain.AttachmentInfo attachment;
  final int messageId;
  final _RecoveredAttachmentPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ref
              .read(panelsViewStateProvider(SidebarMode.messages).notifier)
              .show(
                panel: WindowPanel.right,
                spec: ViewSpec.messages(
                  MessagesSpec.recoveredAttachmentViewer(
                    messageId: messageId,
                    attachment: attachment,
                  ),
                ),
              );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: presentation.backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: presentation.borderColor, width: 1),
          ),
          child: Text(
            presentation.label,
            style: typography.caption1.copyWith(color: presentation.textColor),
          ),
        ),
      ),
    );
  }
}

class _SelectedRecoveredAttachment {
  const _SelectedRecoveredAttachment({
    required this.messageId,
    required this.attachmentId,
  });

  final int messageId;
  final int attachmentId;
}

class _RecoveredLegend extends ConsumerWidget {
  const _RecoveredLegend({
    required this.directCount,
    required this.inferredCount,
  });

  final int directCount;
  final int inferredCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final presentation = _RecoveredLegendPresentation.from(
      colors: colors,
      directCount: directCount,
      inferredCount: inferredCount,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: presentation.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: presentation.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: typography.caption.copyWith(color: presentation.titleColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(presentation.description, style: typography.caption1),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final chip in presentation.chips)
                _RecoveredLegendChip(presentation: chip),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveredLegendChip extends ConsumerWidget {
  const _RecoveredLegendChip({required this.presentation});

  final _RecoveredLegendChipPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: presentation.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: presentation.borderColor, width: 1),
      ),
      child: Text(presentation.label, style: typography.caption1),
    );
  }
}

class _ContextSidebarIconAction extends HookConsumerWidget {
  const _ContextSidebarIconAction({
    required this.item,
    required this.isRowHovered,
  });

  final MessageListItem item;
  final bool isRowHovered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isHovered = useState(false);

    Future<void> openContext() async {
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: ViewSpec.messages(
              MessagesSpec.searchResultContext(
                messageId: item.id,
                chatId: item.chatId,
              ),
            ),
          );
    }

    return MacosTooltip(
      message: 'View in timeline',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          isHovered.value = true;
        },
        onExit: (_) {
          isHovered.value = false;
        },
        child: GestureDetector(
          onTap: openContext,
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: isHovered.value ? 1.05 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isHovered.value
                        ? 1
                        : isRowHovered
                        ? 0.72
                        : 0.4,
                    child: Icon(
                      Icons.view_timeline_outlined,
                      size: 18,
                      color: isHovered.value
                          ? colors.accents.primary
                          : colors.content.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
