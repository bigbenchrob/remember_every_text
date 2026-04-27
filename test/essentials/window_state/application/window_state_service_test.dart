import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/window_state/application/window_state_service.dart';
import 'package:remember_this_text/essentials/window_state/domain/entities/window_state_entity.dart';
import 'package:remember_this_text/essentials/window_state/domain/ports/window_manager_port.dart';
import 'package:remember_this_text/essentials/window_state/domain/ports/window_storage_port.dart';

void main() {
  group('WindowStateService', () {
    test(
      'persists an intentional large shrink outside screen-change recovery',
      () async {
        const initialState = WindowStateEntity(
          width: 1600,
          height: 1200,
          x: 40,
          y: 30,
          isMinimized: false,
          sidebarWidth: WindowStateEntity.defaultSidebarWidth,
        );
        final storage = _FakeWindowStorage(initialState: initialState);
        final windowManager = _FakeWindowManager(
          frame: {'x': 180, 'y': 40, 'width': 900, 'height': 720},
        );
        final service = WindowStateService(
          storage: storage,
          windowManager: windowManager,
        );

        await service.loadWindowState();
        await service.saveCurrentWindowState(includeSize: true);

        expect(storage.saveCount, 1);
        expect(storage.lastSavedState?.width, 900);
        expect(storage.lastSavedState?.height, 720);
        expect(storage.lastSavedState?.x, 180);
        expect(storage.lastSavedState?.y, 40);
      },
    );

    test(
      'ignores a transient large shrink during screen-change reconciliation',
      () async {
        const initialState = WindowStateEntity(
          width: 1600,
          height: 1200,
          x: 40,
          y: 30,
          isMinimized: false,
          sidebarWidth: WindowStateEntity.defaultSidebarWidth,
        );
        final storage = _FakeWindowStorage(initialState: initialState);
        final windowManager = _FakeWindowManager(
          frame: {'x': 180, 'y': 40, 'width': 900, 'height': 720},
        );
        final service = WindowStateService(
          storage: storage,
          windowManager: windowManager,
        );

        await service.loadWindowState();
        await service.reconcileAfterScreenChange();
        storage.resetSaveTracking();
        windowManager.setFrameForTest(
          frame: {'x': 180, 'y': 40, 'width': 900, 'height': 720},
        );

        await service.saveCurrentWindowState(includeSize: true);

        expect(storage.saveCount, 0);
        expect(storage.lastSavedState, isNull);
      },
    );
  });
}

final class _FakeWindowStorage implements WindowStoragePort {
  _FakeWindowStorage({this.initialState});

  final WindowStateEntity? initialState;
  WindowStateEntity? lastSavedState;
  int saveCount = 0;

  @override
  Future<void> clearWindowState() async {
    lastSavedState = null;
    saveCount = 0;
  }

  @override
  Future<WindowStateEntity?> loadWindowState() async {
    return initialState;
  }

  @override
  Future<void> saveWindowState(WindowStateEntity state) async {
    lastSavedState = state;
    saveCount += 1;
  }

  void resetSaveTracking() {
    lastSavedState = null;
    saveCount = 0;
  }
}

final class _FakeWindowManager implements WindowManagerPort {
  _FakeWindowManager({required Map<String, double> frame})
    : _frame = Map<String, double>.from(frame);

  Map<String, double> _frame;
  bool _isMinimized = false;

  @override
  Future<Map<String, double>> getWindowFrame() async {
    return Map<String, double>.from(_frame);
  }

  @override
  Future<bool> isMaximized() async {
    return false;
  }

  @override
  Future<bool> isMinimized() async {
    return _isMinimized;
  }

  @override
  Future<void> maximize() async {}

  @override
  Future<void> minimize() async {
    _isMinimized = true;
  }

  @override
  Future<void> restore() async {
    _isMinimized = false;
  }

  @override
  Future<void> setWindowFrame({
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    _frame = {'x': x, 'y': y, 'width': width, 'height': height};
  }

  @override
  Future<void> setWindowMinSize({
    required double width,
    required double height,
  }) async {}

  void setFrameForTest({required Map<String, double> frame}) {
    _frame = Map<String, double>.from(frame);
  }
}
