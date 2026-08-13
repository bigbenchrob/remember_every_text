import 'dart:io';

enum DevelopmentContactsSourceMode {
  realSource('real'),
  disposableUnavailableSource('disposable_unavailable');

  const DevelopmentContactsSourceMode(this.storageValue);

  final String storageValue;

  static DevelopmentContactsSourceMode parse(String value) {
    return DevelopmentContactsSourceMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () {
        throw FormatException('Unknown development Contacts source: $value');
      },
    );
  }
}

/// Machine-local configuration for the disposable Contacts-source experiment.
///
/// This is laboratory configuration, not user intent and not Presence state.
final class DevelopmentContactsSourceModeStore {
  const DevelopmentContactsSourceModeStore({required File configurationFile})
    : _configurationFile = configurationFile;

  final File _configurationFile;

  Future<DevelopmentContactsSourceMode> read() async {
    if (!_configurationFile.existsSync()) {
      return DevelopmentContactsSourceMode.realSource;
    }
    final value = (await _configurationFile.readAsString()).trim();
    return DevelopmentContactsSourceMode.parse(value);
  }

  Future<void> write(DevelopmentContactsSourceMode mode) async {
    await _configurationFile.parent.create(recursive: true);
    await _configurationFile.writeAsString(
      '${mode.storageValue}\n',
      flush: true,
    );
  }
}
