import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

import '../../domain/ports/window_manager_port.dart';

class MacosWindowManager implements WindowManagerPort {
  @override
  Future<void> setWindowFrame({
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      await WindowManipulator.setWindowFrame(
        Rect.fromLTWH(x, y, width, height),
      );
    } catch (e, stackTrace) {
      _debugWindowFailure('set window frame', e, stackTrace);
    }
  }

  @override
  Future<Map<String, double>> getWindowFrame() async {
    if (!Platform.isMacOS) {
      return {'x': 100, 'y': 100, 'width': 1200, 'height': 800};
    }

    try {
      final frame = await WindowManipulator.getWindowFrame();
      return {
        'x': frame.left,
        'y': frame.top,
        'width': frame.width,
        'height': frame.height,
      };
    } catch (e, stackTrace) {
      _debugWindowFailure('read window frame', e, stackTrace);
      return {'x': 100, 'y': 100, 'width': 1200, 'height': 800};
    }
  }

  @override
  Future<void> maximize() async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      await WindowManipulator.zoomWindow();
    } catch (e, stackTrace) {
      _debugWindowFailure('maximize window', e, stackTrace);
    }
  }

  @override
  Future<void> minimize() async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      await WindowManipulator.miniaturizeWindow();
    } catch (e, stackTrace) {
      _debugWindowFailure('minimize window', e, stackTrace);
    }
  }

  @override
  Future<void> restore() async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      // macOS doesn't have a direct restore method, but we can use setWindowFrame
      // with the last known normal size
    } catch (e, stackTrace) {
      _debugWindowFailure('restore window', e, stackTrace);
    }
  }

  @override
  Future<bool> isMaximized() async {
    if (!Platform.isMacOS) {
      return false;
    }

    try {
      return await WindowManipulator.isWindowZoomed();
    } catch (e, stackTrace) {
      _debugWindowFailure('read zoomed state', e, stackTrace);
      return false;
    }
  }

  @override
  Future<bool> isMinimized() async {
    if (!Platform.isMacOS) {
      return false;
    }

    // For now, always return false as we don't have a reliable way to check
    // minimized state in macos_window_utils
    return false;
  }

  @override
  Future<void> setWindowMinSize({
    required double width,
    required double height,
  }) async {
    if (!Platform.isMacOS) {
      return;
    }

    try {
      await _setMinSize(Size(width, height));
    } catch (e, stackTrace) {
      _debugWindowFailure('set window minimum size', e, stackTrace);
    }
  }

  Future<void> _setMinSize(Size size) async {
    try {
      await WindowManipulator.setWindowMinSize(size);
    } catch (e, stackTrace) {
      _debugWindowFailure('apply native minimum size', e, stackTrace);
    }
  }

  void _debugWindowFailure(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('Window manager could not $operation: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
