part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveSettingsChild(SettingsCassetteSpec spec) {
  return spec.when(
    messageHistoryCoverageOverview: () {
      return const CassetteSpec.settings(
        SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
      );
    },
    messageHistoryCoverageHowToRead: () {
      return const CassetteSpec.settings(
        SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
      );
    },
    messageHistoryCoverageOlderMessagesNote: () {
      return null;
    },
    importHistoricalArchivePanel: () {
      return null;
    },
    importHistoricalArchivePreflight: (_) {
      return null;
    },
    importHistoricalArchiveInProgress: (_) {
      return null;
    },
    importHistoricalArchiveResult: (_) {
      return null;
    },
    sendLogsPanel: () {
      return null;
    },
    resetMessageDataPanel: () {
      return null;
    },
    textSizePlaceholder: () {
      return null;
    },
    imageSizePlaceholder: () {
      return null;
    },
    attachmentArchive: () {
      return null;
    },
  );
}

extension SettingsCassetteSpecX on SettingsCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveSettingsChild(this);
  }
}
