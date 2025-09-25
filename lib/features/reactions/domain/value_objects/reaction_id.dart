import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_id.freezed.dart';

@freezed
abstract class ReactionId with _$ReactionId {
  /// Main constructor: enforces having a non-empty value
  const factory ReactionId(String value) = _ReactionId;

  const ReactionId._(); // added constructor for custom methods

  /// Example: basic validation
  factory ReactionId.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(
        raw,
        'ReactionId',
        'ReactionId cannot be empty',
      );
    }
    return ReactionId(raw);
  }

  /// Custom helper method
  String get asString => value;
}
