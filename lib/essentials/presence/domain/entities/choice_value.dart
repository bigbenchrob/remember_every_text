import 'package:meta/meta.dart';

/// Durable opaque value emitted by one human choice.
@immutable
final class ChoiceValue {
  ChoiceValue(String value) : value = _validate(value);

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
        other is ChoiceValue && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ChoiceValue($value)';
}
