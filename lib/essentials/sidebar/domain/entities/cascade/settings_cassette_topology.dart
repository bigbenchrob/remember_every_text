part of '../cassette_spec.dart';

CassetteSpec? resolveSettingsChild(SettingsCassetteSpec spec) {
  return spec.when(
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
