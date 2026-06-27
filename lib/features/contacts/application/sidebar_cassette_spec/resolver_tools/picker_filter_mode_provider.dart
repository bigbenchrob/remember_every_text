import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/logging/feature_level_providers.dart'
    show appLoggerProvider;
import 'picker_filter_mode_store_provider.dart';

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
  bool _hasLocalMutation = false;

  @override
  PickerFilterMode build() {
    if (!_restoreScheduled) {
      _restoreScheduled = true;
      unawaited(_restorePersistedMode());
    }

    return PickerFilterMode.all;
  }

  Future<void> setMode(PickerFilterMode mode) async {
    _hasLocalMutation = true;
    state = mode;

    await _persistMode(mode);
  }

  Future<void> _persistMode(PickerFilterMode mode) async {
    try {
      final store = await ref.read(pickerFilterModeStoreProvider.future);
      await store.writeMode(mode.storageValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Contact picker filter mode persist failed',
            source: 'PickerFilter',
            context: <String, Object?>{
              'mode': mode.storageValue,
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }

  Future<void> _restorePersistedMode() async {
    try {
      final store = await ref.read(pickerFilterModeStoreProvider.future);
      final rawValue = await store.readMode();
      if (_hasLocalMutation) {
        return;
      }
      state = PickerFilterMode.fromStorage(rawValue);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Contact picker filter mode restore failed',
            source: 'PickerFilter',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
    }
  }
}
