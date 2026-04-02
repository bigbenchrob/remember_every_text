part of '../../cassette_spec.dart';

CassetteSpec sidebarUtilityChildContactsInfoCard() {
  return const CassetteSpec.contactsInfo(
    ContactsInfoCassetteSpec.infoCard(
      key: ContactsInfoKey.pickerContentSources,
    ),
  );
}

/// Cascade from "From unfamiliar sources" menu to stray handles type switcher.
CassetteSpec sidebarUtilityChildStrayHandlesTypeSwitcher() {
  return const CassetteSpec.handles(
    HandlesCassetteSpec.strayHandlesTypeSwitcher(),
  );
}

CassetteSpec sidebarUtilityChildSearchAllMessagesInfoCard() {
  return const CassetteSpec.messagesInfo(
    MessagesInfoCassetteSpec.infoCard(key: MessagesInfoKey.searchAllMessages),
  );
}

CassetteSpec sidebarUtilityChildRecoveredUnlinkedNavigator() {
  return const CassetteSpec.messagesInfo(
    MessagesInfoCassetteSpec.infoCard(
      key: MessagesInfoKey.recoveredDeletedMessages,
    ),
  );
}

CassetteSpec sidebarUtilityChildRecoveredNoHandleFromMeNavigator() {
  return const CassetteSpec.messagesInfo(
    MessagesInfoCassetteSpec.infoCard(
      key: MessagesInfoKey.recoveredNoHandleMessages,
    ),
  );
}

CassetteSpec sidebarUtilitySettingsChildActionsMenu() {
  return const CassetteSpec.contactsSettings(
    ContactsSettingsSpec.actionsMenu(),
  );
}

CassetteSpec sidebarUtilitySettingsChildAttachmentArchive() {
  return const CassetteSpec.contactsSettings(
    ContactsSettingsSpec.attachmentArchive(),
  );
}
