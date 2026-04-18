part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveSidebarUtilityChild(SidebarUtilityCassetteSpec spec) {
  return spec.when(
    topChatMenu: (selectedChoice) {
      switch (selectedChoice) {
        case TopChatMenuChoice.contacts:
          return sidebarUtilityChildContactsInfoCard();

        case TopChatMenuChoice.strayHandles:
          return sidebarUtilityChildStrayHandlesTypeSwitcher();

        case TopChatMenuChoice.recoveredUnlinkedMessages:
          return sidebarUtilityChildRecoveredUnlinkedNavigator();

        case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
          return null;

        case TopChatMenuChoice.searchAllMessages:
          return sidebarUtilityChildSearchAllMessagesInfoCard();
      }
    },
    settingsMenu: (expandedActionId) {
      switch (expandedActionId) {
        case SettingsMenuActionId.sendLogs:
          return sidebarUtilitySettingsChildSendLogsPanel();
        case SettingsMenuActionId.resetMessageData:
          return sidebarUtilitySettingsChildResetMessageDataPanel();
        case SettingsMenuActionId.textSize:
          return sidebarUtilitySettingsChildTextSizeInfo();
        case SettingsMenuActionId.imageSize:
          return sidebarUtilitySettingsChildImageSizeInfo();
        case null:
          return null;
      }
    },
  );
}

extension SidebarUtilityCassetteSpecX on SidebarUtilityCassetteSpec {
  /// Determine the next cassette to show beneath this sidebar utility.
  CassetteSpec? childSpec() {
    return resolveSidebarUtilityChild(this);
  }
}
