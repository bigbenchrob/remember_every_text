import 'package:freezed_annotation/freezed_annotation.dart';

part 'messages_spec.freezed.dart';

@freezed
class MessagesSpec with _$MessagesSpec {
  const factory MessagesSpec.forChat({required int chatId}) = _MessagesForChat;

  const factory MessagesSpec.forContact({required String contactId}) =
      _MessagesForContact;

  const factory MessagesSpec.recent({required int limit}) = _RecentMessages;
}
