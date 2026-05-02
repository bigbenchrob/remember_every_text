import 'package:intl/intl.dart';

// dumbass competition varying apple date formats:
//  apple: nanoseconds since 2001-01-01
//  appleSeconds: seconds since 2001=01-01 (e.g. Apple contacts db)
//  unix: seconds since 1970-01-01
//  dart: milliseconds since 1970-01-01

// for any A to B conversion, convert A to Unix, then Unix to B

class DateConverter {
  DateConverter._();

  static int Function()? _nowUnixSecondsOverride;

  static void overrideNowUnixSecondsForTesting(int Function()? provider) {
    _nowUnixSecondsOverride = provider;
  }

  /// Turn a date string, e.g. '2019-01-31' to an int based on the Apple date specification
  static int dateString2Apple(String dateString) {
    // e.g. '2019-01-31'
    // (unix date in seconds -  978307200) * 1000000000 == apple chat db date

    final dt = DateTime.parse(dateString);

    final ms = dt.millisecondsSinceEpoch;
    final s = (ms / 1000).round();
    final appleDate = (s - 978307200) * 1000000000;

    return appleDate;
  }

  // convert weird apple seconds format to standard apple format
  static int coreTS2Apple(double coreTimeStamp) {
    return coreTimeStamp.round() * 1000000000;
  }

  static double apple2CoreTS(int appleTimeStamp) {
    return appleTimeStamp / 1000000000;
  }

  /// Turn a unix TimeStamp to an int based on the Apple date specification
  /// (nanoseconds since 2001-01-01)
  static int unix2Apple(int unixTimeStamp) {
    return (unixTimeStamp - 978307200) * 1000000000;
  }

  static int apple2Unix(int appleTimeStamp) {
    return ((appleTimeStamp / 1000000000) + 978307200).round();
  }

  static int unix2Dart(int unixTimeStamp) {
    return unixTimeStamp * 1000;
  }

  static int dart2Unix(int dartTimeStamp) {
    return (dartTimeStamp / 1000).round();
  }

  static int dart2Apple(int dartTimeStamp) {
    return unix2Apple(dart2Unix(dartTimeStamp));
  }

  static int dartDateTime2Apple(DateTime dateTime) {
    return dart2Apple(dartDateTime2timeStamp(dateTime));
  }

  static int apple2Dart(int appleTimeStamp) {
    return unix2Dart(apple2Unix(appleTimeStamp));
  }

  static DateTime dartTimeStamp2DateTime(int dartTimeStamp) {
    return DateTime.fromMillisecondsSinceEpoch(dartTimeStamp);
  }

  static int dartDateTime2timeStamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  static int nowUnixSeconds() {
    final override = _nowUnixSecondsOverride;
    if (override != null) {
      return override();
    }

    return dart2Unix(dartDateTime2timeStamp(DateTime.now().toUtc()));
  }

  static Duration durationBetweenUnixSeconds(
    int startUnixSeconds,
    int endUnixSeconds,
  ) {
    final clampedSeconds = endUnixSeconds >= startUnixSeconds
        ? endUnixSeconds - startUnixSeconds
        : 0;
    return Duration(seconds: clampedSeconds);
  }

  static Duration durationSinceUnixSeconds(int startUnixSeconds) {
    return durationBetweenUnixSeconds(startUnixSeconds, nowUnixSeconds());
  }

  static String formatDurationCompact(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    if (minutes <= 0) {
      return '${seconds}s';
    }

    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  static String formatDartDateTime(int dartTimeStamp, String? formatterString) {
    formatterString ??= 'yyyy-MM-dd HH:mm';
    final formatter = DateFormat(formatterString);
    return formatter.format(dartTimeStamp2DateTime(dartTimeStamp));
  }

  /// Safely convert SQLite numeric values (int or double) to int for date processing
  /// SQLite can return dates as either int or double, this handles both cases
  static int? toIntSafe(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }

  /// Convert Apple timestamp (nanoseconds since 2001-01-01) to ISO 8601 UTC string
  /// Handles both int and double values from SQLite databases
  /// Returns null for null or zero values
  static String? appleToIsoString(dynamic raw) {
    final intValue = toIntSafe(raw);
    if (intValue == null || intValue == 0) {
      return null;
    }

    // Apple's chat.db has stored message dates in two formats over the years:
    //   * older databases: seconds since 2001-01-01 (~1e8–1e9 magnitude)
    //   * newer databases: nanoseconds since 2001-01-01 (~1e17 magnitude)
    // Misclassifying seconds as nanoseconds collapses every value to roughly
    // 2001-01-01 (the "Jan 2001" symptom). Detect the format by magnitude
    // and convert through the existing nanosecond pathway.
    final unixSeconds = _appleAnyToUnixSeconds(intValue);
    if (unixSeconds == null) {
      return null;
    }

    final dartTimestamp = unix2Dart(unixSeconds);
    final dateTime = dartTimeStamp2DateTime(dartTimestamp);
    return dateTime.toUtc().toIso8601String();
  }

  /// Convert an Apple-epoch raw value that may be either nanoseconds or
  /// seconds since 2001-01-01 to Unix epoch seconds.
  ///
  /// Returns `null` for null, zero, or values that cannot be safely parsed.
  /// Never silently coerces to epoch zero.
  static int? appleAnyToUnixSeconds(dynamic raw) {
    final intValue = toIntSafe(raw);
    if (intValue == null || intValue == 0) {
      return null;
    }
    return _appleAnyToUnixSeconds(intValue);
  }

  static int? _appleAnyToUnixSeconds(int intValue) {
    // Threshold matches the historical preflight heuristic: any value with
    // magnitude >= 1e12 must be in nanoseconds (one day past Apple epoch in
    // nanoseconds is already ~8.6e13). Values below this threshold are
    // treated as seconds since the Apple epoch.
    const nanosecondMagnitudeThreshold = 1000000000000; // 1e12
    if (intValue.abs() >= nanosecondMagnitudeThreshold) {
      return apple2Unix(intValue);
    }
    return intValue + 978307200;
  }

  /// Convert an ISO 8601 timestamp string to Unix epoch seconds.
  /// Returns null for null, blank, or invalid values.
  static int? isoStringToUnixSeconds(String? raw) {
    if (raw == null) {
      return null;
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final dateTime = DateTime.tryParse(trimmed);
    if (dateTime == null) {
      return null;
    }

    return dart2Unix(dateTime.toUtc().millisecondsSinceEpoch);
  }

  /// Convert Apple timestamp to DateTime object
  /// Handles both int and double values from SQLite databases
  static DateTime? appleToDateTime(dynamic raw) {
    final intValue = toIntSafe(raw);
    if (intValue == null || intValue == 0) {
      return null;
    }

    final unixSeconds = _appleAnyToUnixSeconds(intValue);
    if (unixSeconds == null) {
      return null;
    }
    return dartTimeStamp2DateTime(unix2Dart(unixSeconds));
  }

  // ───────────────────────────────────────────────────────────────────────
  // Canonical SQL expression builders
  //
  // These are the ONLY sanctioned SQL fragments for converting between the
  // ledger's INTEGER unix-seconds storage and the working projection's
  // ISO 8601 TEXT storage. Importers and migrators must use them instead
  // of inlining `strftime(...)` calls so that conversion semantics stay
  // aligned with the Dart-side helpers above.
  // ───────────────────────────────────────────────────────────────────────

  /// SQL fragment that converts a column holding ISO 8601 TEXT (or already
  /// numeric) values into Unix epoch seconds (INTEGER). Returns NULL when
  /// the column is NULL, blank, or otherwise unparseable; never coerces
  /// invalid values to 0.
  static String isoTextToUnixSecondsSqlExpression(String columnName) {
    return 'CASE '
        'WHEN $columnName IS NULL THEN NULL '
        "WHEN typeof($columnName) IN ('integer','real') THEN CAST($columnName AS INTEGER) "
        "WHEN TRIM(CAST($columnName AS TEXT)) = '' THEN NULL "
        "ELSE CAST(strftime('%s', $columnName) AS INTEGER) "
        'END';
  }

  /// SQL fragment that converts a column holding Unix epoch seconds
  /// (INTEGER) into the ISO 8601 UTC TEXT format used by working.db.
  /// Returns NULL when the column is NULL or zero; never silently emits
  /// `'1970-01-01T00:00:00Z'` for zero / sentinel values.
  static String unixSecondsToIsoTextSqlExpression(String columnName) {
    return 'CASE '
        'WHEN $columnName IS NULL THEN NULL '
        'WHEN $columnName = 0 THEN NULL '
        "ELSE strftime('%Y-%m-%dT%H:%M:%SZ', $columnName, 'unixepoch') "
        'END';
  }
}
