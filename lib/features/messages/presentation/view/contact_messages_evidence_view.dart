import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../contacts/feature_level_providers.dart';
import '../../application/message_evidence/current_visible_month_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class ContactMessagesEvidenceView extends ConsumerStatefulWidget {
  const ContactMessagesEvidenceView({
    required this.contactId,
    this.monthAnchor,
    this.filterHandleId,
    super.key,
  });

  final int contactId;
  final DateTime? monthAnchor;
  final int? filterHandleId;

  @override
  ConsumerState<ContactMessagesEvidenceView> createState() =>
      _ContactMessagesEvidenceViewState();
}

class _ContactMessagesEvidenceViewState
    extends ConsumerState<ContactMessagesEvidenceView> {
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
    final evidenceScope = widget.filterHandleId == null
        ? ContactAllMessagesEvidenceScope(contactId: widget.contactId)
        : ContactHandleMessagesEvidenceScope(
            contactId: widget.contactId,
            handleId: widget.filterHandleId!,
          );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final initialRowsAsync = ref.watch(
      messageEvidenceInitialRowsProvider(
        scope: evidenceScope,
        monthAnchor: widget.monthAnchor,
        limit: widget.monthAnchor == null ? 80 : 500,
      ),
    );
    final snapshotAsync = ref.watch(
      contactPageGraphSnapshotProvider(contactId: widget.contactId),
    );
    final identityResolverAsync = ref.watch(displayIdentityResolverProvider);
    final handlesAsync = widget.filterHandleId == null
        ? null
        : ref.watch(handlesForContactProvider(contactId: widget.contactId));
    final normalizedQuery = _query.trim();
    final matchingIdsAsync = normalizedQuery.isEmpty
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              query: normalizedQuery,
              mode: _searchMode,
            ),
          );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        if (identityResolverAsync.isLoading &&
            !identityResolverAsync.hasValue) {
          return MessageEvidenceTimelineView(
            evidenceScope: evidenceScope,
            skeleton: skeleton,
            isInitialRowsLoading: true,
            headerData: MessageEvidenceHeaderModel(
              title: 'Loading contact messages',
              countLabel: '${_formatCount(skeleton.totalCount)} messages',
            ),
            emptyMessage: 'No messages found for this contact.',
            monthAnchor: widget.monthAnchor,
          );
        }

        return _ContactMessagesEvidenceTimeline(
          contactId: widget.contactId,
          contactName: _contactLabelForId(
            identityResolverAsync.valueOrNull,
            widget.contactId,
          ),
          evidenceScope: evidenceScope,
          snapshot: snapshotAsync.valueOrNull,
          skeleton: skeleton,
          initialRows: initialRowsAsync.valueOrNull ?? const {},
          isInitialRowsLoading:
              initialRowsAsync.isLoading && !initialRowsAsync.hasValue,
          monthAnchor: widget.monthAnchor,
          filterHandleId: widget.filterHandleId,
          selectedHandleLabel: _selectedHandleLabel(
            handlesAsync?.valueOrNull,
            widget.filterHandleId,
          ),
          searchQuery: normalizedQuery,
          matchingMessageIds: matchingIdsAsync?.valueOrNull,
          isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
          searchController: _searchController,
          searchMode: _searchMode,
          onSearchModeChanged: (mode) {
            setState(() {
              _searchMode = mode;
            });
          },
        );
      },
      loading: () => const Center(child: Text('Loading contact timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Contact message timeline failed: $error')),
    );
  }
}

String? _contactLabelForId(
  DisplayIdentityResolver? identityResolver,
  int contactId,
) {
  return identityResolver?.resolveContact(contactId).primaryLabel;
}

class _ContactMessagesEvidenceTimeline extends ConsumerWidget {
  const _ContactMessagesEvidenceTimeline({
    required this.contactId,
    required this.contactName,
    required this.evidenceScope,
    required this.snapshot,
    required this.skeleton,
    required this.initialRows,
    required this.isInitialRowsLoading,
    required this.monthAnchor,
    required this.filterHandleId,
    required this.selectedHandleLabel,
    required this.searchQuery,
    required this.matchingMessageIds,
    required this.isMatchingLoaded,
    required this.searchController,
    required this.searchMode,
    required this.onSearchModeChanged,
  });

  final int contactId;
  final String? contactName;
  final MessageEvidenceScope evidenceScope;
  final ContactGraphSnapshot? snapshot;
  final MessageEvidenceTimelineSkeleton skeleton;
  final Map<int, MessageEvidenceRowData> initialRows;
  final bool isInitialRowsLoading;
  final DateTime? monthAnchor;
  final int? filterHandleId;
  final String? selectedHandleLabel;
  final String searchQuery;
  final List<int>? matchingMessageIds;
  final bool isMatchingLoaded;
  final TextEditingController searchController;
  final MessageEvidenceSearchMode searchMode;
  final ValueChanged<MessageEvidenceSearchMode> onSearchModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MessageEvidenceTimelineView(
      evidenceScope: evidenceScope,
      skeleton: skeleton,
      initialRows: initialRows,
      isInitialRowsLoading: isInitialRowsLoading,
      headerData: MessageEvidenceHeaderModel(
        title: _title(),
        identityContextLine: _selectedHandleContextLine(),
        dateRangeLabel: _dateRangeLabel(),
        countLabel: _countLabel(),
        activeScopeLabel: _activeScopeLabel(),
        statusLine: _statusLine(),
        searchConfig: MessageEvidenceHeaderSearchConfig(
          controller: searchController,
          placeholder: 'Search messages from ${_contactLabel()}',
          mode: searchMode,
          onModeChanged: onSearchModeChanged,
        ),
      ),
      emptyMessage: _emptyMessage(),
      monthAnchor: monthAnchor,
      highlightQuery: searchQuery,
      onVisibleMonthChanged: (monthKey) {
        ref
            .read(
              currentVisibleMonthForScopeProvider(
                scope: evidenceScope,
              ).notifier,
            )
            .setVisibleMonthKey(monthKey);
      },
    );
  }

  String? _dateRangeLabel() {
    if (searchQuery.isNotEmpty) {
      return _dateSpanForSkeleton();
    }

    final monthLabel = _monthLabel(monthAnchor);
    if (monthLabel != null) {
      return monthLabel;
    }

    if (filterHandleId != null) {
      return _dateSpanForSkeleton();
    }

    final activity = snapshot?.messageActivity;
    if (activity == null) {
      return null;
    }

    return _dateSpan(activity.firstMessageAtUtc, activity.lastMessageAtUtc);
  }

  String _countLabel() {
    if (searchQuery.isNotEmpty) {
      if (isMatchingLoaded) {
        return '${_formatCount(matchingMessageIds?.length ?? 0)} of '
            '${_formatCount(skeleton.totalCount)} messages match "$searchQuery"';
      }
      return 'matching messages...';
    }

    final monthLabel = _monthLabel(monthAnchor);
    if (monthLabel != null) {
      return '${_formatCount(_monthMessageCount(_monthKey(monthAnchor!)))} messages this month';
    }

    if (filterHandleId != null) {
      return '${_formatCount(skeleton.totalCount)} messages';
    }

    final activity = snapshot?.messageActivity;
    if (activity == null) {
      return '${_formatCount(skeleton.totalCount)} messages';
    }

    return '${_formatCount(activity.totalMessageCount)} messages';
  }

  String? _activeScopeLabel() {
    if (searchQuery.isNotEmpty) {
      return 'Message text contains "$searchQuery"';
    }
    if (monthAnchor != null) {
      return 'Selected month';
    }
    return null;
  }

  String _statusLine() {
    if (searchQuery.isNotEmpty) {
      return 'evidence skeleton • contact text match overlay • hydrate visible rows';
    }
    if (monthAnchor != null) {
      return 'selected month • evidence skeleton • hydrate visible rows';
    }
    if (filterHandleId != null) {
      return 'selected handle • evidence skeleton • latest position • hydrate visible rows';
    }
    return 'evidence skeleton • latest position • hydrate visible rows';
  }

  String _emptyMessage() {
    if (monthAnchor != null) {
      return 'No messages found for this contact in the selected month.';
    }
    if (filterHandleId != null) {
      return 'No messages found for this contact and handle.';
    }
    return 'No messages found for this contact.';
  }

  String _contactLabel() {
    final label = contactName?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return 'this contact';
  }

  String _title() {
    if (filterHandleId != null) {
      return 'Messages from ${_contactLabel()}';
    }
    return 'All messages from ${_contactLabel()}';
  }

  String? _selectedHandleContextLine() {
    if (filterHandleId == null) {
      return null;
    }
    return 'Selected handle: ${selectedHandleLabel ?? 'handle $filterHandleId'}';
  }

  int _monthMessageCount(String monthKey) {
    return skeleton.entries.where((entry) {
      return entry.monthKey == monthKey;
    }).length;
  }

  String _dateSpanForSkeleton() {
    if (skeleton.entries.isEmpty) {
      return 'No date range';
    }
    return _dateSpan(
      skeleton.entries.first.dateUtc,
      skeleton.entries.last.dateUtc,
    );
  }
}

String _monthKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat.yMMMM().format(value);
}

String _dateSpan(String? first, String? last) {
  final firstLabel = _dateLabel(first);
  final lastLabel = _dateLabel(last);
  if (firstLabel == null && lastLabel == null) {
    return 'No date range';
  }
  if (firstLabel == null) {
    return 'through $lastLabel';
  }
  if (lastLabel == null || firstLabel == lastLabel) {
    return firstLabel;
  }
  return '$firstLabel to $lastLabel';
}

String? _dateLabel(String? value) {
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

String? _selectedHandleLabel(List<LinkedHandle>? handles, int? handleId) {
  if (handleId == null || handles == null) {
    return null;
  }

  for (final handle in handles) {
    if (handle.handleId == handleId) {
      return '${handle.displayValue} (${handle.service})';
    }
  }
  return null;
}
