import 'package:meta/meta.dart';

/// Stable identity of one admitted archive instance.
@immutable
final class ArchiveInstanceId {
  ArchiveInstanceId(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    final normalized = value.trim().toLowerCase();
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-'
      r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (!uuidPattern.hasMatch(normalized)) {
      throw FormatException('Invalid archive instance identifier: $value');
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    return other is ArchiveInstanceId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
