import 'package:freezed_annotation/freezed_annotation.dart';

import '../essentials/contacts/domain/value_objects/contact_id.dart';
import '../features/messages/domain/value_objects/message_id.dart';

class MessageIdConverter implements JsonConverter<MessageId, String> {
  const MessageIdConverter();

  @override
  MessageId fromJson(String json) {
    return MessageId.fromRaw(json);
  }

  @override
  String toJson(MessageId object) {
    return object.asString;
  }
}

class ContactIdConverter implements JsonConverter<ContactId, String> {
  const ContactIdConverter();

  @override
  ContactId fromJson(String json) {
    return ContactId.fromRaw(json);
  }

  @override
  String toJson(ContactId object) {
    return object.asString;
  }
}
