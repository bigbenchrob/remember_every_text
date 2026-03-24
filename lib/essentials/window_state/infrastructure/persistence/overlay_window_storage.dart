import 'dart:convert';

import '../../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/entities/window_state_entity.dart';
import '../../domain/ports/window_storage_port.dart';

/// Overlay database implementation of window state storage.
class OverlayWindowStorage implements WindowStoragePort {
  OverlayWindowStorage({required Future<OverlayDatabase> overlayDb})
    : _overlayDb = overlayDb;

  static const double _minWidth = 900.0;
  static const double _minHeight = 720.0;
  static const double _maxWidth = 5000.0;
  static const double _maxHeight = 3000.0;
  static const String _settingKey = 'window_state';

  final Future<OverlayDatabase> _overlayDb;

  @override
  Future<WindowStateEntity?> loadWindowState() async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(_settingKey);
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final width = (decoded['width'] as num?)?.toDouble();
      final height = (decoded['height'] as num?)?.toDouble();
      final x = (decoded['x'] as num?)?.toDouble();
      final y = (decoded['y'] as num?)?.toDouble();
      final isMinimized = decoded['isMinimized'] as bool?;
      final sidebarWidth = (decoded['sidebarWidth'] as num?)?.toDouble();

      if (width == null || height == null || x == null || y == null) {
        return null;
      }

      return WindowStateEntity(
        width: width.clamp(_minWidth, _maxWidth),
        height: height.clamp(_minHeight, _maxHeight),
        x: x,
        y: y,
        isMinimized: isMinimized ?? false,
        sidebarWidth: sidebarWidth ?? WindowStateEntity.defaultSidebarWidth,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveWindowState(WindowStateEntity state) async {
    try {
      final overlayDb = await _overlayDb;
      await overlayDb.writeOverlaySetting(
        settingKey: _settingKey,
        settingValue: jsonEncode({
          'width': state.width,
          'height': state.height,
          'x': state.x,
          'y': state.y,
          'isMinimized': state.isMinimized,
          'sidebarWidth': state.sidebarWidth,
        }),
      );
    } catch (_) {
      // Fail silently - window state persistence is non-critical.
    }
  }

  @override
  Future<void> clearWindowState() async {
    try {
      final overlayDb = await _overlayDb;
      await overlayDb.writeOverlaySetting(
        settingKey: _settingKey,
        settingValue: '',
      );
    } catch (_) {
      // Fail silently - window state persistence is non-critical.
    }
  }
}
