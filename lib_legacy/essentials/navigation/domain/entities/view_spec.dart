import 'package:freezed_annotation/freezed_annotation.dart';

import 'features/chats_spec.dart';
import 'features/contacts_spec.dart';
import 'features/import_spec.dart';
import 'features/messages_spec.dart';

part 'view_spec.freezed.dart';

@freezed
abstract class ViewSpec with _$ViewSpec {
  const factory ViewSpec.messages(MessagesSpec spec) = _ViewMessages;
  const factory ViewSpec.chats(ChatsSpec spec) = _ViewChats;
  const factory ViewSpec.contacts(ContactsSpec spec) = _ViewContacts;
  const factory ViewSpec.import(ImportSpec spec) = _ViewImport;
}
