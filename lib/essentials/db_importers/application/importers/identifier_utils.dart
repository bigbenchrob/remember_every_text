/// Shared identifier-normalization logic used by multiple importers.

import '../../../db/shared/handle_identifier_utils.dart';

/// Normalizes a phone number or email to a canonical form for matching.
///
/// - Emails are lower-cased.
/// - Phone numbers are stripped to digits (plus leading '+' removed),
///   and US-style 11-digit numbers starting with '1' are trimmed to 10 digits.
String? normalizeIdentifier(String? value) {
  return normalizeHandleIdentifier(value);
}
