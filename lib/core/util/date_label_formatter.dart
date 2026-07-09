import 'package:intl/intl.dart';

class DateLabelFormatter {
  DateLabelFormatter._();

  static String fullDate(DateTime value) {
    return DateFormat.yMMMd().format(value.toLocal());
  }

  static String? fullDateFromIso(String? value, {String? fallback}) {
    final parsed = parseIso(value);
    if (parsed == null) {
      return fallback;
    }
    return fullDate(parsed);
  }

  static String longMonthYear(DateTime value) {
    return DateFormat.yMMMM().format(value.toLocal());
  }

  static String compactMonthYear(DateTime value) {
    return DateFormat('MMM yyyy').format(value.toLocal());
  }

  static String localTime(DateTime value) {
    return DateFormat('h:mm a').format(value.toLocal());
  }

  static String? localTimeIfTodayFromIso(String? value, {DateTime? now}) {
    final parsed = parseIso(value);
    if (parsed == null) {
      return null;
    }
    final local = parsed.toLocal();
    final localNow = (now ?? DateTime.now()).toLocal();
    if (!_isSameDay(local, localNow)) {
      return null;
    }
    return localTime(local);
  }

  static String sortableDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static String? sortableDateFromIso(String? value, {String? fallback}) {
    final parsed = parseIso(value);
    if (parsed == null) {
      return fallback;
    }
    return sortableDate(parsed);
  }

  static String monthKey(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}';
  }

  static String? monthKeyOrNull(DateTime? value) {
    if (value == null) {
      return null;
    }
    return monthKey(value);
  }

  static DateTime? parseIso(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  static bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
