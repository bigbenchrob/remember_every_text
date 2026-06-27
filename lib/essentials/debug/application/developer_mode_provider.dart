import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'developer_mode_store_provider.dart';

part 'developer_mode_provider.g.dart';

enum DeveloperModeValue {
  user,
  developer;

  static DeveloperModeValue fromStorage(String? rawValue) {
    return switch (rawValue) {
      'developer' => DeveloperModeValue.developer,
      _ => DeveloperModeValue.user,
    };
  }

  String get storageValue {
    return switch (this) {
      DeveloperModeValue.user => 'user',
      DeveloperModeValue.developer => 'developer',
    };
  }
}

@riverpod
class DeveloperMode extends _$DeveloperMode {
  @override
  Future<DeveloperModeValue> build() async {
    if (kReleaseMode) {
      return DeveloperModeValue.user;
    }

    final store = await ref.watch(developerModeStoreProvider.future);
    final rawValue = await store.readMode();
    if (rawValue == null) {
      return DeveloperModeValue.developer;
    }

    return DeveloperModeValue.fromStorage(rawValue);
  }

  Future<void> setMode(DeveloperModeValue mode) async {
    if (kReleaseMode) {
      state = const AsyncData(DeveloperModeValue.user);
      return;
    }

    state = await AsyncValue.guard(() async {
      final store = await ref.read(developerModeStoreProvider.future);
      await store.writeMode(mode.storageValue);
      return mode;
    });
  }

  Future<void> setDeveloperModeEnabled({required bool enabled}) async {
    await setMode(
      enabled ? DeveloperModeValue.developer : DeveloperModeValue.user,
    );
  }

  Future<void> toggleMode() async {
    final nextMode = state.valueOrNull == DeveloperModeValue.developer
        ? DeveloperModeValue.user
        : DeveloperModeValue.developer;
    await setMode(nextMode);
  }
}
