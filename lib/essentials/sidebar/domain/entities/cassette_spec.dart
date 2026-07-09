import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import '../../../../features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import '../../../../features/conversations/domain/spec_classes/conversations_cassette_spec.dart';
import '../../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../../features/handles/domain/spec_classes/handles_info_cassette_spec.dart';
import '../../../../features/messages/domain/spec_classes/messages_cassette_spec.dart';
import '../../../../features/messages/domain/spec_classes/messages_info_cassette_spec.dart';
import '../../../../features/settings/domain/spec_classes/settings_cassette_spec.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

part 'cassette_spec.freezed.dart';
part 'cascade/cassette_child_resolver.dart';
part 'cascade/sidebar_utility_topology.dart';
part 'cascade/contacts_cassette_topology.dart';
part 'cascade/contacts_info_topology.dart';
part 'cascade/conversations_cassette_topology.dart';
part 'cascade/handles_cassette_topology.dart';
part 'cascade/handles_info_topology.dart';
part 'cascade/messages_cassette_topology.dart';
part 'cascade/messages_info_topology.dart';
part 'cascade/settings_cassette_topology.dart';
part 'cascade/links/contacts_children.dart';
part 'cascade/links/sidebar_utility_children.dart';

@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) =
      _CassetteSidebarWidget;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) =
      _CassetteContacts;
  const factory CassetteSpec.contactsInfo(ContactsInfoCassetteSpec spec) =
      _CassetteContactsInfo;
  const factory CassetteSpec.conversations(ConversationsCassetteSpec spec) =
      _CassetteConversations;
  const factory CassetteSpec.handles(HandlesCassetteSpec spec) =
      _CassetteHandles;
  const factory CassetteSpec.handlesInfo(HandlesInfoCassetteSpec spec) =
      _CassetteHandlesInfo;
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) =
      _CassetteMessages;
  const factory CassetteSpec.messagesInfo(MessagesInfoCassetteSpec spec) =
      _CassetteMessagesInfo;
  const factory CassetteSpec.settings(SettingsCassetteSpec spec) =
      _CassetteSettings;
}

extension CassetteSpecX on CassetteSpec {
  /// Resolve the child cassette spec for this cassette, if any.
  CassetteSpec? childSpec() {
    return resolveCassetteChild(this);
  }
}
