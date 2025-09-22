import 'package:freezed_annotation/freezed_annotation.dart';

part 'chats_spec.freezed.dart';

@freezed
class ChatsSpec with _$ChatsSpec {
  const factory ChatsSpec.list() = _ChatsList;

  const factory ChatsSpec.forContact({required String contactId}) =
      _ChatsForContact;

  const factory ChatsSpec.recent({required int limit}) = _RecentChats;
}
