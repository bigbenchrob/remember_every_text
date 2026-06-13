import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../feature_level_providers.dart';

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

    final store = await ref.read(pickerFilterModeStoreProvider.future);
    await store.writeMode(mode.storageValue);
  }

  Future<void> _restorePersistedMode() async {
    final store = await ref.read(pickerFilterModeStoreProvider.future);
    final rawValue = await store.readMode();
    state = PickerFilterMode.fromStorage(rawValue);
  }
}
