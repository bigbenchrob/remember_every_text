/// Calendar heatmap timeline data structures
///
/// Represents message activity as a compact calendar grid where each month is a
/// fixed-size rectangle colored by message intensity. This approach:
/// - Handles 1 to 10,000+ messages with equal visual clarity
/// - Uses minimal vertical space (no tall bars)
/// - Wraps long timespans across multiple rows
/// - Shows sparse data with dots, dense data with color intensity

/// Intensity level for a month's message activity
enum MonthIntensity {
  /// Month before chat started (show nothing - empty space)
  notYetStarted,

  /// Chat active but no messages this month (show empty square with grey border)
  empty,

  /// 1-3 messages (show as 1-3 dots)
  fewDots,

  /// 4-10 messages (light neutral gray)
  sparse4To10,

  /// 11-30 messages (medium gray)
  sparse11To30,

  /// 31-50 messages (dark gray)
  sparse31To50,

  /// 51-100 messages (yellow; sustained activity begins)
  active51To100,

  /// 101-300 messages (yellow-green)
  active101To300,

  /// 301-1000 messages (green)
  active301To1000,

  /// 1001-3000 messages (teal)
  active1001To3000,

  /// 3001-10000 messages (blue)
  active3001To10000,

  /// 10001+ messages (deep purple; open-ended maximum intensity)
  active10001Plus;

  /// Convert message count to intensity level
  static MonthIntensity fromMessageCount(int count) {
    if (count == 0) {
      return MonthIntensity.empty;
    } else if (count <= 3) {
      return MonthIntensity.fewDots;
    } else if (count <= 10) {
      return MonthIntensity.sparse4To10;
    } else if (count <= 30) {
      return MonthIntensity.sparse11To30;
    } else if (count <= 50) {
      return MonthIntensity.sparse31To50;
    } else if (count <= 100) {
      return MonthIntensity.active51To100;
    } else if (count <= 300) {
      return MonthIntensity.active101To300;
    } else if (count <= 1000) {
      return MonthIntensity.active301To1000;
    } else if (count <= 3000) {
      return MonthIntensity.active1001To3000;
    } else if (count <= 10000) {
      return MonthIntensity.active3001To10000;
    } else {
      return MonthIntensity.active10001Plus;
    }
  }

  /// Whether this intensity should render as individual dots (1-3 messages)
  bool get shouldRenderAsDots => this == MonthIntensity.fewDots;

  /// Whether this month is empty (chat active but no messages)
  bool get isEmpty => this == MonthIntensity.empty;

  /// Whether this month is before chat started (show nothing)
  bool get isNotYetStarted => this == MonthIntensity.notYetStarted;
}

/// A single month's data in the calendar heatmap
class MonthData {
  const MonthData({
    required this.year,
    required this.month,
    required this.messageCount,
    required this.intensity,
    required this.chatId,
  });

  final int year;
  final int month;
  final int messageCount;
  final MonthIntensity intensity;
  final int chatId; // For navigation context
}

/// A single year row: year label + 12 months
class YearRow {
  const YearRow({
    required this.year,
    required this.months,
    required this.hasMessages,
  });

  final int year;
  final List<MonthData> months; // Always 12 months
  final bool hasMessages; // Whether any month has messages
}

/// Complete calendar heatmap timeline data
class CalendarHeatmapTimelineData {
  const CalendarHeatmapTimelineData({
    required this.yearRows,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.totalMessages,
    required this.maxMonthCount,
  });

  final List<YearRow> yearRows;
  final DateTime firstMessageDate;
  final DateTime lastMessageDate;
  final int totalMessages;
  final int maxMonthCount; // For legend/tooltip

  /// Group years into wrapped display rows
  /// Rules:
  /// - First row: up to 8 years
  /// - Subsequent rows: up to 12 years each
  List<List<YearRow>> get wrappedYearRows {
    if (yearRows.isEmpty) {
      return [];
    }

    final groups = <List<YearRow>>[];
    final firstGroup = yearRows.take(8).toList();
    groups.add(firstGroup);

    if (yearRows.length > 8) {
      final remaining = yearRows.skip(8).toList();
      for (var i = 0; i < remaining.length; i += 12) {
        final end = (i + 12 > remaining.length) ? remaining.length : i + 12;
        groups.add(remaining.sublist(i, end));
      }
    }

    return groups;
  }
}
