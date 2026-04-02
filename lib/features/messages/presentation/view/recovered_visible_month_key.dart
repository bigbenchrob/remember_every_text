import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';

String? recoveredVisibleMonthKeyForVisiblePositions({
  required Iterable<ItemPosition> positions,
  required List<RecoveredUnlinkedMessageItem> messages,
}) {
  final visiblePositions =
      positions
          .where((position) {
            return position.itemTrailingEdge > 0 &&
                position.itemLeadingEdge < 1;
          })
          .toList(growable: false)
        ..sort((left, right) {
          return left.itemLeadingEdge.compareTo(right.itemLeadingEdge);
        });

  for (final position in visiblePositions) {
    final index = position.index;
    if (index < 0 || index >= messages.length) {
      continue;
    }

    final monthKey = _monthKeyForDate(messages[index].sentAt);
    if (monthKey != null) {
      return monthKey;
    }
  }

  return null;
}

String? _monthKeyForDate(DateTime? date) {
  if (date == null) {
    return null;
  }

  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}
