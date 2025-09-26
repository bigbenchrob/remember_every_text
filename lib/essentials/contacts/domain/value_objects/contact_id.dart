import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_id.freezed.dart';

@freezed
abstract class ContactId with _$ContactId {
  /// Main constructor: enforces having a non-empty value
  const factory ContactId(String value) = _ContactId;

  /// Example: basic validation
  factory ContactId.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(raw, 'ContactId', 'ContactId cannot be empty');
    }
    return ContactId(raw);
  }

  const ContactId._(); // added constructor for custom methods

  /// Custom helper method
  String get asString => value;
}
