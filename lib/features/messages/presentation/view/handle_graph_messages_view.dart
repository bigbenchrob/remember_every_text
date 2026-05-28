import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

class HandleGraphMessagesView extends ConsumerWidget {
  const HandleGraphMessagesView({required this.handleId, super.key});

  final int handleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceScope = HandleMessagesEvidenceScope(handleId: handleId);
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );

    return skeletonAsync.when(
      data: (skeleton) {
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderData(
            title: 'Handle messages',
            subtitleParts: [
              _dateSpan(skeleton.entries),
              '${_formatCount(skeleton.totalCount)} messages',
            ],
            statusLine: 'graph skeleton • handle scope • hydrate visible rows',
          ),
          emptyMessage: 'No graph messages found for this handle.',
        );
      },
      loading: () => const Center(child: Text('Loading handle messages...')),
      error: (error, stackTrace) =>
          Center(child: Text('Handle messages failed: $error')),
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

String _formatDateLabel(DateTime value) {
  return DateFormat.yMMMd().format(value.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
