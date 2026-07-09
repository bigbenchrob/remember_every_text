import 'package:intl/intl.dart';

class DateRangeFormatter {
  DateRangeFormatter._();

  static String formatMessageEvidenceRangeFromIsoStrings({
    required String? startIso,
    required String? endIso,
    int? itemCount,
    String emptyLabel = 'No date range',
  }) {
    return formatMessageEvidenceRange(
      start: _parseIsoDate(startIso),
      end: _parseIsoDate(endIso),
      itemCount: itemCount,
      emptyLabel: emptyLabel,
    );
  }

  static String formatMessageEvidenceRange({
    required DateTime? start,
    required DateTime? end,
    int? itemCount,
    String emptyLabel = 'No date range',
  }) {
    final localStart = start?.toLocal();
    final localEnd = end?.toLocal();

    if (localStart == null && localEnd == null) {
      return emptyLabel;
    }
    if (localStart == null) {
      return 'through ${_formatFullDate(localEnd!)}';
    }
    if (localEnd == null) {
      return 'from ${_formatFullDate(localStart)}';
    }

    final orderedStart = localEnd.isBefore(localStart) ? localEnd : localStart;
    final orderedEnd = localEnd.isBefore(localStart) ? localStart : localEnd;

    if (_isSameDay(orderedStart, orderedEnd) && itemCount == 1) {
      return _formatFullDate(orderedStart);
    }
    if (_isSameMonth(orderedStart, orderedEnd)) {
      return _formatMonthYear(orderedStart);
    }
    if (orderedStart.year == orderedEnd.year) {
      return '${_formatMonthDay(orderedStart)} to '
          '${_formatMonthDay(orderedEnd)}, ${orderedEnd.year}';
    }
    return '${_formatFullDate(orderedStart)} to ${_formatFullDate(orderedEnd)}';
  }

  static DateTime? _parseIsoDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  static bool _isSameDay(DateTime left, DateTime right) {
    return _isSameMonth(left, right) && left.day == right.day;
  }

  static String _formatFullDate(DateTime value) {
    return DateFormat.yMMMd().format(value);
  }

  static String _formatMonthDay(DateTime value) {
    return DateFormat.MMMd().format(value);
  }

  static String _formatMonthYear(DateTime value) {
    return DateFormat('MMM y').format(value);
  }
}
