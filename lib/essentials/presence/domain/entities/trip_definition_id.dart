import 'package:meta/meta.dart';

/// Canonical identity of one reusable Trip definition.
@immutable
final class TripDefinitionId {
  const TripDefinitionId(this.value);

  final int value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TripDefinitionId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TripDefinitionId($value)';
}
