import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_participant.freezed.dart';

@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String handleId, // stable key from source (handle.ROWID or guid)
    required String service, // iMessage/SMS
    required String normalizedAddress, // E.164 or email
    String? displayName, // optional projection from Contacts
    String? contactId, // optional linkage
  }) = _ChatParticipant;

  const ChatParticipant._();

  bool get isPhone => normalizedAddress.startsWith('+');
}
