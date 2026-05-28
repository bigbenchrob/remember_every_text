import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class ContactGraphMessagesView extends ConsumerStatefulWidget {
  const ContactGraphMessagesView({
    required this.contactId,
    this.monthAnchor,
    this.filterHandleId,
    super.key,
  });

  final int contactId;
  final DateTime? monthAnchor;
  final int? filterHandleId;

  @override
  ConsumerState<ContactGraphMessagesView> createState() =>
      _ContactGraphMessagesViewState();
}

class _ContactGraphMessagesViewState
    extends ConsumerState<ContactGraphMessagesView> {
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
    final evidenceScope = widget.filterHandleId == null
        ? ContactAllMessagesEvidenceScope(contactId: widget.contactId)
        : ContactHandleMessagesEvidenceScope(
            contactId: widget.contactId,
            handleId: widget.filterHandleId!,
          );
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final snapshotAsync = ref.watch(
      contactPageGraphSnapshotProvider(contactId: widget.contactId),
    );
    final profileAsync = ref.watch(
      contactProfileProvider(contactId: widget.contactId),
    );
    final normalizedQuery = _query.trim();
    final matchingIdsAsync = normalizedQuery.isEmpty
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              query: normalizedQuery,
            ),
          );

    return skeletonAsync.when(
      data: (skeleton) {
        return _ContactGraphMessagesTimeline(
          contactId: widget.contactId,
          contactName: profileAsync.valueOrNull?.shortName,
          evidenceScope: evidenceScope,
          snapshot: snapshotAsync.valueOrNull,
          skeleton: skeleton,
          monthAnchor: widget.monthAnchor,
          filterHandleId: widget.filterHandleId,
          searchQuery: normalizedQuery,
          matchingMessageIds: matchingIdsAsync?.valueOrNull,
          isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
          searchController: _searchController,
        );
      },
      loading: () => const Center(child: Text('Loading contact timeline...')),
      error: (error, stackTrace) =>
          Center(child: Text('Contact graph timeline failed: $error')),
    );
  }
}

class _ContactGraphMessagesTimeline extends ConsumerWidget {
  const _ContactGraphMessagesTimeline({
    required this.contactId,
    required this.contactName,
    required this.evidenceScope,
    required this.snapshot,
    required this.skeleton,
    required this.monthAnchor,
    required this.filterHandleId,
    required this.searchQuery,
    required this.matchingMessageIds,
    required this.isMatchingLoaded,
    required this.searchController,
  });

  final int contactId;
  final String? contactName;
  final MessageEvidenceScope evidenceScope;
  final ContactGraphSnapshot? snapshot;
  final MessageEvidenceTimelineSkeleton skeleton;
  final DateTime? monthAnchor;
  final int? filterHandleId;
  final String searchQuery;
  final List<int>? matchingMessageIds;
  final bool isMatchingLoaded;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MessageEvidenceTimelineView(
      evidenceScope: evidenceScope,
      skeleton: skeleton,
      headerData: MessageEvidenceHeaderModel(
        title: 'All messages from ${_contactLabel()}',
        dateRangeLabel: _dateRangeLabel(),
        countLabel: _countLabel(),
        activeScopeLabel: _activeScopeLabel(),
        statusLine: _statusLine(),
        controls: _ContactSearchField(controller: searchController),
      ),
      emptyMessage: _emptyMessage(),
      monthAnchor: monthAnchor,
      highlightQuery: searchQuery,
      onVisibleMonthChanged: (monthKey) {
        ref
            .read(
              currentVisibleMonthForScopeProvider(
                scope: MessageTimelineScope.contact(
                  contactId: contactId,
                  filterHandleId: filterHandleId,
                ),
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
    if (filterHandleId != null) {
      return 'Selected handle';
    }
    return null;
  }

  String _statusLine() {
    if (searchQuery.isNotEmpty) {
      return 'graph skeleton • contact text match overlay • hydrate visible rows';
    }
    if (monthAnchor != null) {
      return 'selected month • graph skeleton • hydrate visible rows';
    }
    if (filterHandleId != null) {
      return 'selected handle • graph skeleton • latest position • hydrate visible rows';
    }
    return 'graph skeleton • latest position • hydrate visible rows';
  }

  String _emptyMessage() {
    if (monthAnchor != null) {
      return 'No graph messages found for this contact in the selected month.';
    }
    if (filterHandleId != null) {
      return 'No graph messages found for this contact and handle.';
    }
    return 'No graph messages found for this contact.';
  }

  String _contactLabel() {
    final label = contactName?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return 'contact $contactId';
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

class _ContactSearchField extends StatelessWidget {
  const _ContactSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: MacosTextField(
        controller: controller,
        placeholder: 'Find messages with this contact',
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
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
