import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';

import '../domain/entities/window_state_entity.dart';
import '../domain/ports/window_manager_port.dart';
import '../domain/ports/window_storage_port.dart';

/// Service to manage window state persistence and restoration
class WindowStateService {
  final WindowStoragePort _storage;
  final WindowManagerPort _windowManager;
  WindowStateEntity? _cachedState;

  static const double _shrinkRatioThreshold = 0.75;
  static const double _minWidth = 900.0;
  static const double _minHeight = 720.0;
  static const double _fallbackMinWidth = 900.0;
  static const double _fallbackMinHeight = 720.0;
  static const Duration _endSidebarResizeDuration = Duration(milliseconds: 220);
  static const int _endSidebarResizeSteps = 10;
  static const double _screenChangeTolerance = 12.0;
  static const int _screenChangeReconcileAttempts = 4;
  static const Duration _screenChangeReconcileDelay = Duration(
    milliseconds: 140,
  );

  double? _baseWindowWidthBeforeEndSidebar;
  bool _isEndSidebarExpanded = false;

  WindowStateService({
    required WindowStoragePort storage,
    required WindowManagerPort windowManager,
  }) : _storage = storage,
       _windowManager = windowManager;

  /// Load the saved window state or return default state
  Future<WindowStateEntity> loadWindowState() async {
    try {
      final persistedState = await _storage.loadWindowState();
      final state = persistedState ?? WindowStateEntity.defaultState();
      _cachedState = _normalizeLoadedState(state);
      _baseWindowWidthBeforeEndSidebar = _cachedState!.width;
      _isEndSidebarExpanded = false;

      if (persistedState == null) {
        await _storage.saveWindowState(_cachedState!);
      }

      return _cachedState!;
    } catch (e) {
      _cachedState = _normalizeLoadedState(WindowStateEntity.defaultState());
      _baseWindowWidthBeforeEndSidebar = _cachedState!.width;
      _isEndSidebarExpanded = false;
      return _cachedState!;
    }
  }

  /// Save the current window state
  Future<void> saveWindowState(WindowStateEntity state) async {
    try {
      await _storage.saveWindowState(state);
      _cachedState = state;
      if (!_isEndSidebarExpanded) {
        _baseWindowWidthBeforeEndSidebar = state.width;
      }
    } catch (e) {
      // Silently fail - window state is not critical
    }
  }

  /// Apply window state to the actual window
  Future<void> applyWindowState(WindowStateEntity state) async {
    try {
      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      await _windowManager.setWindowFrame(
        x: state.x,
        y: state.y,
        width: state.width,
        height: state.height,
      );

      if (state.isMinimized) {
        await _windowManager.minimize();
      }
    } catch (e) {
      // Silently fail - window positioning is not critical
    }
  }

  /// Get current window state from the window manager
  Future<WindowStateEntity> getCurrentWindowState({
    double? sidebarWidth,
  }) async {
    try {
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      return WindowStateEntity(
        width: frame['width'] ?? 1200.0,
        height: frame['height'] ?? 800.0,
        x: frame['x'] ?? 100.0,
        y: frame['y'] ?? 100.0,
        isMinimized: isMinimized,
        sidebarWidth: sidebarWidth ?? 320.0,
      );
    } catch (e) {
      return WindowStateEntity.defaultState();
    }
  }

  /// Save current window state - convenience method for main.dart
  Future<void> saveCurrentWindowState({bool includeSize = true}) async {
    try {
      final existingState = _cachedState ?? await loadWindowState();

      // Get current window dimensions
      final frame = await _windowManager.getWindowFrame();
      final isMinimized = await _windowManager.isMinimized();

      final persistedWidth = includeSize
          ? _persistedWindowWidth(
              actualWidth: frame['width'] ?? existingState.width,
              fallbackWidth: existingState.width,
            )
          : existingState.width;
      final persistedHeight = includeSize
          ? (frame['height'] ?? existingState.height)
          : existingState.height;

      // Create new state preserving sidebar widths from existing state
      final currentState = WindowStateEntity(
        width: persistedWidth,
        height: persistedHeight,
        x: frame['x'] ?? existingState.x,
        y: frame['y'] ?? existingState.y,
        isMinimized: isMinimized,
        sidebarWidth:
            existingState.sidebarWidth, // Preserve existing sidebar width
      );

      final previousState = existingState;
      final widthShrankUnexpectedly =
          includeSize &&
          currentState.width < previousState.width &&
          currentState.width < previousState.width * _shrinkRatioThreshold;
      final heightShrankUnexpectedly =
          includeSize &&
          currentState.height < previousState.height &&
          currentState.height < previousState.height * _shrinkRatioThreshold;

      if (widthShrankUnexpectedly || heightShrankUnexpectedly) {
        return;
      }

      await saveWindowState(currentState);
    } catch (e) {
      // If anything fails, fall back to the old method
      final currentState = await getCurrentWindowState();
      await saveWindowState(currentState);
    }
  }

  /// Restore window state and apply it - convenience method for main.dart
  Future<void> restoreWindowState() async {
    final state = await loadWindowState();
    await applyWindowState(state);
  }

  /// Reconcile window size after display transitions to avoid unintended shrinking
  Future<void> reconcileAfterScreenChange() async {
    try {
      final savedState = _cachedState ?? await loadWindowState();

      // Give macOS a moment to finish its automatic adjustments before reading frame data.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final frame = await _windowManager.getWindowFrame();
      final currentWidth = frame['width'] ?? savedState.width;
      final currentHeight = frame['height'] ?? savedState.height;

      final widthChanged =
          (currentWidth - savedState.width).abs() > _screenChangeTolerance;
      final heightChanged =
          (currentHeight - savedState.height).abs() > _screenChangeTolerance;

      if (!widthChanged && !heightChanged) {
        return;
      }

      var latestFrame = frame;
      final targetX = frame['x'] ?? savedState.x;
      final targetY = frame['y'] ?? savedState.y;

      final minWidth = savedState.width > _fallbackMinWidth
          ? savedState.width
          : _minWidth;
      final minHeight = savedState.height > _fallbackMinHeight
          ? savedState.height
          : _minHeight;

      await _windowManager.setWindowMinSize(width: minWidth, height: minHeight);

      for (
        var attempt = 0;
        attempt < _screenChangeReconcileAttempts;
        attempt++
      ) {
        await Future<void>.delayed(
          attempt == 0
              ? const Duration(milliseconds: 32)
              : _screenChangeReconcileDelay,
        );

        await _windowManager.setWindowFrame(
          x: targetX,
          y: targetY,
          width: savedState.width,
          height: savedState.height,
        );

        await Future<void>.delayed(_screenChangeReconcileDelay);
        latestFrame = await _windowManager.getWindowFrame();

        final reconciledWidth = latestFrame['width'] ?? savedState.width;
        final reconciledHeight = latestFrame['height'] ?? savedState.height;
        final widthSettled =
            (reconciledWidth - savedState.width).abs() <=
            _screenChangeTolerance;
        final heightSettled =
            (reconciledHeight - savedState.height).abs() <=
            _screenChangeTolerance;

        if (widthSettled && heightSettled) {
          break;
        }
      }

      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      final updatedState = savedState.copyWith(
        x: latestFrame['x'] ?? targetX,
        y: latestFrame['y'] ?? targetY,
      );

      await saveWindowState(updatedState);
    } catch (e) {
      // Silently ignore reconciliation failures.
    }
  }

  /// Ensure the runtime window cannot shrink below the configured minimum.
  /// If the current frame is already below the threshold, bump it up.
  Future<void> enforceMinSize() async {
    try {
      await _windowManager.setWindowMinSize(
        width: _minWidth,
        height: _minHeight,
      );

      final frame = await _windowManager.getWindowFrame();
      final width = frame['width'] ?? _minWidth;
      final height = frame['height'] ?? _minHeight;
      final x = frame['x'] ?? 0.0;
      final y = frame['y'] ?? 0.0;

      final targetWidth = width < _minWidth ? _minWidth : width;
      final targetHeight = height < _minHeight ? _minHeight : height;

      if (targetWidth != width || targetHeight != height) {
        await _windowManager.setWindowFrame(
          x: x,
          y: y,
          width: targetWidth,
          height: targetHeight,
        );
      }
    } catch (_) {
      // Silently ignore; sizing not critical.
    }
  }

  Future<void> animateEndSidebarWindowWidth({
    required bool showing,
    required double sidebarWidth,
  }) async {
    try {
      final frame = await _windowManager.getWindowFrame();
      final x = frame['x'] ?? 0.0;
      final y = frame['y'] ?? 0.0;
      final height = frame['height'] ?? _minHeight;
      final currentWidth =
          frame['width'] ?? WindowStateEntity.defaultWindowWidth;

      if (showing) {
        if (_isEndSidebarExpanded) {
          return;
        }

        _baseWindowWidthBeforeEndSidebar = currentWidth;
        _isEndSidebarExpanded = true;

        await _animateWindowWidth(
          x: x,
          y: y,
          height: height,
          startWidth: currentWidth,
          endWidth: currentWidth + sidebarWidth,
        );
        await saveCurrentWindowState();
        return;
      }

      if (!_isEndSidebarExpanded && _baseWindowWidthBeforeEndSidebar == null) {
        return;
      }

      final targetWidth = math.max(
        _minWidth,
        _baseWindowWidthBeforeEndSidebar ?? (currentWidth - sidebarWidth),
      );

      _baseWindowWidthBeforeEndSidebar = targetWidth;
      _isEndSidebarExpanded = false;

      await _animateWindowWidth(
        x: x,
        y: y,
        height: height,
        startWidth: currentWidth,
        endWidth: targetWidth,
      );
      await saveCurrentWindowState();
    } catch (_) {
      // Silently ignore animation failures.
    }
  }

  double _persistedWindowWidth({
    required double actualWidth,
    required double fallbackWidth,
  }) {
    if (_isEndSidebarExpanded) {
      return _baseWindowWidthBeforeEndSidebar ?? fallbackWidth;
    }

    return actualWidth;
  }

  Future<void> _animateWindowWidth({
    required double x,
    required double y,
    required double height,
    required double startWidth,
    required double endWidth,
  }) async {
    if ((startWidth - endWidth).abs() < 1) {
      return;
    }

    const curve = Curves.easeInOutCubic;

    for (var step = 1; step <= _endSidebarResizeSteps; step++) {
      final progress = step / _endSidebarResizeSteps;
      final curvedProgress = curve.transform(progress);
      final width =
          lerpDouble(startWidth, endWidth, curvedProgress) ?? endWidth;

      await _windowManager.setWindowFrame(
        x: x,
        y: y,
        width: width,
        height: height,
      );

      if (step < _endSidebarResizeSteps) {
        await Future<void>.delayed(
          _endSidebarResizeDuration ~/ _endSidebarResizeSteps,
        );
      }
    }
  }

  WindowStateEntity _normalizeLoadedState(WindowStateEntity state) {
    final normalizedWidth = state.width.clamp(_minWidth, double.infinity);
    final normalizedHeight = state.height.clamp(_minHeight, double.infinity);
    final normalizedSidebarWidth = state.sidebarWidth <= 0
        ? WindowStateEntity.defaultSidebarWidth
        : state.sidebarWidth;

    return state.copyWith(
      width: normalizedWidth,
      height: normalizedHeight,
      sidebarWidth: normalizedSidebarWidth,
    );
  }
}
