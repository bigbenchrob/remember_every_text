import '../../../../core/util/count_label_formatter.dart';
import '../../../../core/util/date_range_formatter.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';

String handleLensCountLabel({
  required int totalCount,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isNotEmpty) {
    if (isMatchingLoaded) {
      return '${CountLabelFormatter.formatCount(matchingIds?.length ?? 0)} of '
          '${CountLabelFormatter.messages(totalCount)} match "$query"';
    }
    return 'matching messages...';
  }
  return CountLabelFormatter.messages(totalCount);
}

String handleLensDateSpan(List<MessageEvidenceSkeletonEntry> entries) {
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
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
