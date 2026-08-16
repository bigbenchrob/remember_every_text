import 'package:intl/intl.dart';

// Apple data sources use several timestamp encodings:
//  apple: nanoseconds since 2001-01-01
//  appleSeconds: seconds since 2001=01-01 (e.g. Apple contacts db)
//  unix: seconds since 1970-01-01
//  dart: milliseconds since 1970-01-01

// for any A to B conversion, convert A to Unix, then Unix to B

class DateConverter {
  DateConverter._();

  // Apple Messages databases in the field use both seconds and nanoseconds
  // since 2001-01-01. Values below this unambiguous magnitude are seconds;
  // modern nanosecond values are many orders of magnitude larger.
  static const int _appleNanosecondsMagnitudeFloor = 1000000000000;

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

  /// Normalizes an Apple-epoch timestamp to nanoseconds since 2001-01-01.
  ///
  /// Older Messages databases store seconds while modern databases store
  /// nanoseconds. All Apple timestamp consumers must use this utility rather
  /// than implementing epoch arithmetic or unit detection independently.
  static int? normalizeAppleTimestamp(dynamic raw) {
    final intValue = toIntSafe(raw);
    if (intValue == null || intValue == 0) {
      return null;
    }

    if (intValue.abs() < _appleNanosecondsMagnitudeFloor) {
      return coreTS2Apple(intValue.toDouble());
    }
    return intValue;
  }

  /// Convert an Apple timestamp to an ISO 8601 UTC string.
  /// Handles Apple-epoch seconds and nanoseconds from SQLite databases.
  /// Returns null for null or zero values
  static String? appleToIsoString(dynamic raw) {
    final appleNanoseconds = normalizeAppleTimestamp(raw);
    if (appleNanoseconds == null) {
      return null;
    }

    // Convert Apple nanoseconds to Dart milliseconds and create DateTime
    final dartTimestamp = apple2Dart(appleNanoseconds);
    final dateTime = dartTimeStamp2DateTime(dartTimestamp);
    return dateTime.toUtc().toIso8601String();
  }

  /// Convert an Apple timestamp to a DateTime object.
  /// Handles Apple-epoch seconds and nanoseconds from SQLite databases.
  static DateTime? appleToDateTime(dynamic raw) {
    final appleNanoseconds = normalizeAppleTimestamp(raw);
    if (appleNanoseconds == null) {
      return null;
    }

    final dartTimestamp = apple2Dart(appleNanoseconds);
    return dartTimeStamp2DateTime(dartTimestamp);
  }
}
