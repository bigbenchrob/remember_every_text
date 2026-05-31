import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../view_model/timeline/current_visible_month_provider.dart';
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
            statusLine: _statusLine(normalizedQuery),
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
          highlightQuery: normalizedQuery,
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
            '${_formatCount(skeleton.totalCount)} messages match "$query"';
      }
      return 'matching messages...';
    }

    final monthLabel = _monthLabel(widget.monthAnchor);
    if (monthLabel != null) {
      final monthKey = _monthKey(widget.monthAnchor!);
      final count = skeleton.entries.where((entry) {
        return entry.monthKey == monthKey;
      }).length;
      return '${_formatCount(count)} messages this month';
    }

    return '${_formatCount(skeleton.totalCount)} messages';
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

  String _statusLine(String query) {
    if (query.isNotEmpty) {
      return 'evidence skeleton • text match overlay • hydrate visible rows';
    }
    if (widget.monthAnchor != null) {
      return 'selected month • evidence skeleton • hydrate visible rows';
    }
    return 'evidence skeleton • latest position • hydrate visible rows';
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
  final first = _formatDateLabel(dates.first);
  final last = _formatDateLabel(dates.last);
  if (first == last) {
    return first;
  }
  return '$first to $last';
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat.yMMMM().format(value);
}

String _monthKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
}

String _formatDateLabel(DateTime value) {
  return DateFormat.yMMMd().format(value.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
