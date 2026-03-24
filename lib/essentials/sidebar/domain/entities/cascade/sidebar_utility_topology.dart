part of '../cassette_spec.dart';

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
    settingsMenu: (selectedChoice) {
      switch (selectedChoice) {
        case SettingsMenuChoice.actions:
          return sidebarUtilitySettingsChildActionsMenu();
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
