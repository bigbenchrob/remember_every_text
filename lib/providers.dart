import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core/util/paths_helper.dart';

part 'providers.g.dart';

/// Root providers shared by multiple features or initialized asynchronously.

// Platform brightness provider for initializing dark mode
@riverpod
Brightness platformBrightness(Ref ref) {
  // This will be overridden in main.dart with the actual platform brightness
  return Brightness.light;
}

/// The asynchronous provider of [PathsHelper].
@riverpod
Future<PathsHelper> pathsHelper(Ref ref) async {
  return PathsHelper.asyncInstance;
}

/// App theme-mode override.
///
/// Defaults to `ThemeMode.system` and can be cycled from the toolbar.
@riverpod
class SwitchableDarkMode extends _$SwitchableDarkMode {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }

  void cycle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}
