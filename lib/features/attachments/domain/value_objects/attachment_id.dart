import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_id.freezed.dart';

@freezed
abstract class AttachmentId with _$AttachmentId {
  /// Main constructor: enforces having a non-empty value
  const factory AttachmentId(String value) = _AttachmentId;

  const AttachmentId._(); // added constructor for custom methods

  /// Example: basic validation
  factory AttachmentId.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(
        raw,
        'AttachmentId',
        'AttachmentId cannot be empty',
      );
    }
    return AttachmentId(raw);
  }

  /// Custom helper method
  String get asString => value;
}
