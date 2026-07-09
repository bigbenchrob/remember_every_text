import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show effectiveRightPanelSpecProvider;
import '../../../conversations/feature_level_providers.dart'
    show conversationExcerptNavigationActionsProvider;
import '../../application/message_evidence/current_visible_month_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class GlobalMessagesEvidenceView extends ConsumerStatefulWidget {
  const GlobalMessagesEvidenceView({this.monthAnchor, super.key});

  final DateTime? monthAnchor;

  @override
  ConsumerState<GlobalMessagesEvidenceView> createState() =>
      _GlobalMessagesEvidenceViewState();
}

class _GlobalMessagesEvidenceViewState
    extends ConsumerState<GlobalMessagesEvidenceView> {
  late final TextEditingController _searchController = TextEditingController();
  String _query = '';
  MessageEvidenceSearchMode _searchMode = MessageEvidenceSearchMode.allTerms;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    const allMessagesScope = GlobalMessagesEvidenceScope();
    final activeContextMessageId = _activeContextMessageId(ref);
    final normalizedQuery = _query.trim();
    final evidenceScope = normalizedQuery.isEmpty
        ? allMessagesScope
        : MessageSearchEvidenceScope(query: normalizedQuery, mode: _searchMode);
    final allMessagesSkeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: allMessagesScope),
    );
    final visibleSkeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );

    return allMessagesSkeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (allMessagesSkeleton) {
        final hasMatchesLoaded =
            normalizedQuery.isEmpty || visibleSkeletonAsync.hasValue;
        final visibleSkeleton = normalizedQuery.isEmpty
            ? allMessagesSkeleton
            : visibleSkeletonAsync.valueOrNull ??
                  const MessageEvidenceTimelineSkeleton(entries: []);

        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: visibleSkeleton,
          headerData: MessageEvidenceHeaderModel(
            title: 'All messages',
            dateRangeLabel: _dateRangeLabel(
              skeleton: allMessagesSkeleton,
              visibleSkeleton: visibleSkeleton,
              query: normalizedQuery,
            ),
            countLabel: _countLabel(
              skeleton: allMessagesSkeleton,
              visibleSkeleton: visibleSkeleton,
              query: normalizedQuery,
              hasMatchesLoaded: hasMatchesLoaded,
            ),
            activeScopeLabel: _activeScopeLabel(normalizedQuery),
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: _searchController,
              placeholder: 'Search these messages',
              mode: _searchMode,
              onModeChanged: (mode) {
                setState(() {
                  _searchMode = mode;
                });
              },
            ),
          ),
          emptyMessage: _emptyMessage(
            query: normalizedQuery,
            hasMatchesLoaded: hasMatchesLoaded,
            error: visibleSkeletonAsync.error,
          ),
          monthAnchor: widget.monthAnchor,
          anchorMessageId: activeContextMessageId,
          highlightQuery: normalizedQuery,
          useFixedPanelFrame: true,
          resolveRowAction: _resolveConversationContextAction,
          onVisibleMonthChanged: (monthKey) {
            ref
                .read(
                  currentVisibleMonthForScopeProvider(
                    scope: allMessagesScope,
                  ).notifier,
                )
                .setVisibleMonthKey(monthKey);
          },
        );
      },
      loading: () => const Center(child: Text('Loading message timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Evidence timeline failed: $error')),
    );
  }

  int? _activeContextMessageId(WidgetRef ref) {
    final rightSpec = ref.watch(
      effectiveRightPanelSpecProvider(SidebarMode.messages),
    );
    return rightSpec?.when(
      messages: (_) => null,
      conversations: (conversationsSpec) {
        return conversationsSpec.anchorMessageId;
      },
      settings: (_) => null,
      environmentReadiness: (_) => null,
      onboarding: (_) => null,
    );
  }

  String _dateRangeLabel({
    required MessageEvidenceTimelineSkeleton skeleton,
    required MessageEvidenceTimelineSkeleton visibleSkeleton,
    required String query,
  }) {
    if (query.isNotEmpty) {
      return _dateSpan(visibleSkeleton.entries);
    }

    final monthLabel = _monthLabel(widget.monthAnchor);
    if (monthLabel != null) {
      return monthLabel;
    }

    return _dateSpan(skeleton.entries);
  }

  String _countLabel({
    required MessageEvidenceTimelineSkeleton skeleton,
    required MessageEvidenceTimelineSkeleton visibleSkeleton,
    required String query,
    required bool hasMatchesLoaded,
  }) {
    if (query.isNotEmpty) {
      if (hasMatchesLoaded) {
        return '${_formatCount(visibleSkeleton.totalCount)} of '
            '${CountLabelFormatter.messages(skeleton.totalCount)} match "$query"';
      }
      return 'matching messages...';
    }

    final monthLabel = _monthLabel(widget.monthAnchor);
    if (monthLabel != null) {
      final monthKey = _monthKey(widget.monthAnchor!);
      final count = skeleton.entries.where((entry) {
        return entry.monthKey == monthKey;
      }).length;
      return '${CountLabelFormatter.messages(count)} this month';
    }

    return CountLabelFormatter.messages(skeleton.totalCount);
  }

  String? _activeScopeLabel(String query) {
    if (query.isNotEmpty) {
      return 'Message text contains "$query"';
    }
    if (widget.monthAnchor != null) {
      return 'Selected month';
    }
    return null;
  }

  VoidCallback? _resolveConversationContextAction(
    MessageEvidenceScope evidenceScope,
    MessageEvidenceRowData message,
    String highlightQuery,
  ) {
    final query = highlightQuery.trim();
    if (query.isEmpty) {
      return null;
    }

    if (evidenceScope is! MessageSearchEvidenceScope) {
      return null;
    }

    final conversationId = message.sourceConversationId;
    if (conversationId == null) {
      return null;
    }

    final actions = ref.read(
      conversationExcerptNavigationActionsProvider.notifier,
    );
    if (actions.isActive(
      conversationId: conversationId,
      anchorMessageId: message.messageId,
    )) {
      return null;
    }

    return () {
      actions.open(
        conversationId: conversationId,
        anchorMessageId: message.messageId,
      );
    };
  }
}

String _emptyMessage({
  required String query,
  required bool hasMatchesLoaded,
  required Object? error,
}) {
  if (query.isEmpty) {
    return 'No messages found.';
  }
  if (error != null) {
    return 'Message search failed: $error';
  }
  if (!hasMatchesLoaded) {
    return 'Matching messages...';
  }
  return 'No messages match "$query".';
}

String _dateSpan(List<MessageEvidenceSkeletonEntry> entries) {
  final dates = [
    for (final entry in entries)
      if (_parseDate(entry.dateUtc) case final DateTime date) date,
  ];
  if (dates.isEmpty) {
    return 'No dated messages';
  }
  dates.sort();
  return DateRangeFormatter.formatMessageEvidenceRange(
    start: dates.first,
    end: dates.last,
    itemCount: entries.length,
    emptyLabel: 'No dated messages',
  );
}

DateTime? _parseDate(String? value) {
  return DateLabelFormatter.parseIso(value);
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateLabelFormatter.longMonthYear(value);
}

String _monthKey(DateTime value) {
  return DateLabelFormatter.monthKey(value);
}

String _formatCount(int count) {
  return CountLabelFormatter.formatCount(count);
}
