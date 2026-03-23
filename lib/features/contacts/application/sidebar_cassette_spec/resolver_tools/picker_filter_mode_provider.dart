import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';

part 'picker_filter_mode_provider.g.dart';

/// Controls which contacts the picker displays.
enum PickerFilterMode {
  /// Show all contacts (A–Z).
  all,

  /// Show only user-designated favourites.
  favouritesOnly;

  static PickerFilterMode fromStorage(String? rawValue) {
    return switch (rawValue) {
      'favourites_only' => PickerFilterMode.favouritesOnly,
      _ => PickerFilterMode.all,
    };
  }

  String get storageValue {
    return switch (this) {
      PickerFilterMode.all => 'all',
      PickerFilterMode.favouritesOnly => 'favourites_only',
    };
  }
}

@Riverpod(keepAlive: true)
class PickerFilter extends _$PickerFilter {
  static const String _settingKey = 'contact_picker_filter_mode';

  bool _restoreScheduled = false;

  @override
  PickerFilterMode build() {
    if (!_restoreScheduled) {
      _restoreScheduled = true;
      unawaited(_restorePersistedMode());
    }

    return PickerFilterMode.all;
  }

  Future<void> setMode(PickerFilterMode mode) async {
    state = mode;

    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.writeOverlaySetting(
      settingKey: _settingKey,
      settingValue: mode.storageValue,
    );
  }

  Future<void> _restorePersistedMode() async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    final rawValue = await overlayDb.readOverlaySetting(_settingKey);
    state = PickerFilterMode.fromStorage(rawValue);
  }
}
