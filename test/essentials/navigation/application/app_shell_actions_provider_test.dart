import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_mode/application/app_mode_providers.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_store.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_store_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/app_shell_actions_provider.dart';
import 'package:remember_this_text/essentials/window_state/domain/entities/window_state_entity.dart';
import 'package:remember_this_text/essentials/window_state/domain/ports/window_manager_port.dart';
import 'package:remember_this_text/essentials/window_state/domain/ports/window_storage_port.dart';
import 'package:remember_this_text/essentials/window_state/infrastructure/persistence/window_state_infrastructure_providers.dart';

void main() {
  test('toggleDeveloperMode delegates to developer mode boundary', () async {
    final store = _FakeDeveloperModeStore(initialMode: 'developer');
    final container = ProviderContainer(
      overrides: [
        developerModeStoreProvider.overrideWith((ref) async => store),
      ],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(developerModeProvider.future),
      DeveloperModeValue.developer,
    );

    await container
        .read(appShellActionsProvider.notifier)
        .toggleDeveloperMode();

    expect(store.mode, 'user');
    expect(
      container.read(developerModeProvider).valueOrNull,
      DeveloperModeValue.user,
    );
  });

  test('cycleThemeMode delegates to switchable theme boundary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(switchableDarkModeProvider), ThemeMode.system);

    container.read(appShellActionsProvider.notifier).cycleThemeMode();

    expect(container.read(switchableDarkModeProvider), ThemeMode.light);

    container.read(appShellActionsProvider.notifier).cycleThemeMode();

    expect(container.read(switchableDarkModeProvider), ThemeMode.dark);
  });

  test('saveCurrentWindowState delegates to window state boundary', () async {
    final storage = _FakeWindowStorage();
    final windowManager = _FakeWindowManager(
      frame: const {'x': 10, 'y': 20, 'width': 1200, 'height': 800},
    );
    final container = ProviderContainer(
      overrides: [
        windowStoragePortProvider.overrideWithValue(storage),
        windowManagerPortProvider.overrideWithValue(windowManager),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(appShellActionsProvider.notifier)
        .saveCurrentWindowState(includeSize: true);

    expect(storage.savedStates, isNotEmpty);
    expect(storage.savedStates.last.x, 10);
    expect(storage.savedStates.last.y, 20);
    expect(storage.savedStates.last.width, 1200);
    expect(storage.savedStates.last.height, 800);
  });

  test(
    'animateEndSidebarWindowWidth delegates to window state boundary',
    () async {
      final storage = _FakeWindowStorage(
        initialState: const WindowStateEntity(
          width: 1000,
          height: 800,
          x: 20,
          y: 30,
          isMinimized: false,
          sidebarWidth: 320,
        ),
      );
      final windowManager = _FakeWindowManager(
        frame: const {'x': 20, 'y': 30, 'width': 1000, 'height': 800},
      );
      final container = ProviderContainer(
        overrides: [
          windowStoragePortProvider.overrideWithValue(storage),
          windowManagerPortProvider.overrideWithValue(windowManager),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(appShellActionsProvider.notifier)
          .animateEndSidebarWindowWidth(showing: true, sidebarWidth: 360);

      expect(windowManager.setFrameCalls, isNotEmpty);
      expect(windowManager.setFrameCalls.last['width'], greaterThan(1000));
    },
  );
}

final class _FakeDeveloperModeStore implements DeveloperModeStore {
  _FakeDeveloperModeStore({String? initialMode}) : mode = initialMode;

  String? mode;

  @override
  Future<String?> readMode() async {
    return mode;
  }

  @override
  Future<void> writeMode(String mode) async {
    this.mode = mode;
  }
}

final class _FakeWindowStorage implements WindowStoragePort {
  _FakeWindowStorage({WindowStateEntity? initialState}) : _state = initialState;

  WindowStateEntity? _state;
  final savedStates = <WindowStateEntity>[];

  @override
  Future<void> clearWindowState() async {
    _state = null;
  }

  @override
  Future<WindowStateEntity?> loadWindowState() async {
    return _state;
  }

  @override
  Future<void> saveWindowState(WindowStateEntity state) async {
    _state = state;
    savedStates.add(state);
  }
}

final class _FakeWindowManager implements WindowManagerPort {
  _FakeWindowManager({required Map<String, double> frame})
    : _frame = Map<String, double>.of(frame);

  Map<String, double> _frame;
  final setFrameCalls = <Map<String, double>>[];
  var minimized = false;
  var maximized = false;

  @override
  Future<Map<String, double>> getWindowFrame() async {
    return _frame;
  }

  @override
  Future<bool> isMaximized() async {
    return maximized;
  }

  @override
  Future<bool> isMinimized() async {
    return minimized;
  }

  @override
  Future<void> maximize() async {
    maximized = true;
  }

  @override
  Future<void> minimize() async {
    minimized = true;
  }

  @override
  Future<void> restore() async {
    minimized = false;
    maximized = false;
  }

  @override
  Future<void> setWindowFrame({
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    _frame = {'x': x, 'y': y, 'width': width, 'height': height};
    setFrameCalls.add(_frame);
  }

  @override
  Future<void> setWindowMinSize({
    required double width,
    required double height,
  }) async {}
}
