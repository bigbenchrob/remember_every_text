import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class GlobalGraphMessagesView extends ConsumerStatefulWidget {
  const GlobalGraphMessagesView({this.monthAnchor, super.key});

  final DateTime? monthAnchor;

  @override
  ConsumerState<GlobalGraphMessagesView> createState() =>
      _GlobalGraphMessagesViewState();
}

class _GlobalGraphMessagesViewState
    extends ConsumerState<GlobalGraphMessagesView> {
  late final TextEditingController _searchController = TextEditingController();
  String _query = '';

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
        : MessageSearchEvidenceScope(query: normalizedQuery);
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
          headerData: MessageEvidenceHeaderData(
            title: 'All messages',
            subtitleParts: _subtitleParts(
              skeleton: allMessagesSkeleton,
              visibleSkeleton: visibleSkeleton,
              query: normalizedQuery,
              hasMatchesLoaded: hasMatchesLoaded,
            ),
            statusLine: _statusLine(normalizedQuery),
            controls: _GlobalSearchField(controller: _searchController),
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
                    scope: const MessageTimelineScope.global(),
                  ).notifier,
                )
                .setVisibleMonthKey(monthKey);
          },
        );
      },
      loading: () => const Center(child: Text('Loading graph timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Graph timeline failed: $error')),
    );
  }

  List<String> _subtitleParts({
    required MessageEvidenceTimelineSkeleton skeleton,
    required MessageEvidenceTimelineSkeleton visibleSkeleton,
    required String query,
    required bool hasMatchesLoaded,
  }) {
    if (query.isNotEmpty) {
      return [
        _dateSpan(visibleSkeleton.entries),
        if (hasMatchesLoaded)
          '${_formatCount(visibleSkeleton.totalCount)} of '
              '${_formatCount(skeleton.totalCount)} messages match "$query"'
        else
          'matching messages...',
      ];
    }

    final monthLabel = _monthLabel(widget.monthAnchor);
    if (monthLabel != null) {
      final monthKey = _monthKey(widget.monthAnchor!);
      final count = skeleton.entries.where((entry) {
        return entry.monthKey == monthKey;
      }).length;
      return [monthLabel, '${_formatCount(count)} messages this month'];
    }

    return [
      _dateSpan(skeleton.entries),
      '${_formatCount(skeleton.totalCount)} messages',
    ];
  }

  String _statusLine(String query) {
    if (query.isNotEmpty) {
      return 'graph skeleton • text match overlay • hydrate visible rows';
    }
    if (widget.monthAnchor != null) {
      return 'selected month • graph skeleton • hydrate visible rows';
    }
    return 'graph skeleton • latest position • hydrate visible rows';
  }
}

String _emptyMessage({
  required String query,
  required bool hasMatchesLoaded,
  required Object? error,
}) {
  if (query.isEmpty) {
    return 'No graph messages found.';
  }
  if (error != null) {
    return 'Message search failed: $error';
  }
  if (!hasMatchesLoaded) {
    return 'Matching messages...';
  }
  return 'No graph messages match "$query".';
}

class _GlobalSearchField extends StatelessWidget {
  const _GlobalSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: MacosTextField(
        controller: controller,
        placeholder: 'Filter all messages',
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }
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
