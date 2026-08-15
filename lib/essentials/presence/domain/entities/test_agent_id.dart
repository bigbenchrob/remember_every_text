import 'package:meta/meta.dart';

/// Durable opaque identity of one Boolean Test Agent.
@immutable
final class TestAgentId {
  TestAgentId(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'Must not be empty.');
    }
    return value;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TestAgentId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TestAgentId($value)';
}
