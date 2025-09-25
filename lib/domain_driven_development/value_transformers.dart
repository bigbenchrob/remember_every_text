import 'package:freezed_annotation/freezed_annotation.dart';

import '../features/attachments/domain/value_objects/attachment_id.dart';
import '../features/contacts/domain/value_objects/contact_id.dart';
import '../features/messages/domain/value_objects/message_id.dart';
import '../features/reactions/domain/value_objects/reaction_id.dart';

class AttachmentIdConverter implements JsonConverter<AttachmentId, String> {
  const AttachmentIdConverter();

  @override
  AttachmentId fromJson(String json) {
    return AttachmentId.fromRaw(json);
  }

  @override
  String toJson(AttachmentId object) {
    return object.asString;
  }
}

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

class ReactionIdConverter implements JsonConverter<ReactionId, String> {
  const ReactionIdConverter();

  @override
  ReactionId fromJson(String json) {
    return ReactionId.fromRaw(json);
  }

  @override
  String toJson(ReactionId object) {
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
