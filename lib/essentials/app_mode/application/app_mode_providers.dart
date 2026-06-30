import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_mode_providers.g.dart';

@riverpod
Brightness platformBrightness(Ref ref) {
  return Brightness.light;
}

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
