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
    HandlesCassetteSpec.strayHandlesInvestigationSwitcher(),
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

CassetteSpec sidebarUtilitySettingsChildSendLogsPanel() {
  return const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel());
}

CassetteSpec sidebarUtilitySettingsChildResetMessageDataPanel() {
  return const CassetteSpec.settings(
    SettingsCassetteSpec.resetMessageDataPanel(),
  );
}

CassetteSpec sidebarUtilitySettingsChildMessageHistoryCoveragePanel() {
  return const CassetteSpec.settings(
    SettingsCassetteSpec.messageHistoryCoverageOverview(),
  );
}

CassetteSpec sidebarUtilitySettingsChildTextSizeInfo() {
  return const CassetteSpec.settings(
    SettingsCassetteSpec.textSizeInfo(),
  );
}

CassetteSpec sidebarUtilitySettingsChildImageSizeInfo() {
  return const CassetteSpec.settings(
    SettingsCassetteSpec.imageSizeInfo(),
  );
}
