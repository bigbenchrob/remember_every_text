import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_id.freezed.dart';

@freezed
abstract class ChatId with _$ChatId {
  /// Main constructor: enforces having a non-empty value
  const factory ChatId(String value) = _ChatId;

  const ChatId._(); // added constructor for custom methods

  /// Example: basic validation
  factory ChatId.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(raw, 'ChatId', 'ChatId cannot be empty');
    }
    return ChatId(raw);
  }

  /// Custom helper method
  String get asString => value;
}
