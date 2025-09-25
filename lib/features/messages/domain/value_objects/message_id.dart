import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_id.freezed.dart';

@freezed
abstract class MessageId with _$MessageId {
  const factory MessageId(String value) = _MessageId;

  factory MessageId.fromRaw(String raw) {
    if (raw.isEmpty) {
      throw ArgumentError.value(raw, 'MessageId', 'cannot be empty');
    }
    return MessageId(raw);
  }

  const MessageId._();

  String get asString => value;
}
