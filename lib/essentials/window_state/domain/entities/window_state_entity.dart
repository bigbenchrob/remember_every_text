import 'package:freezed_annotation/freezed_annotation.dart';

part 'window_state_entity.freezed.dart';

@freezed
abstract class WindowStateEntity with _$WindowStateEntity {
  static const double defaultSidebarWidth = 320.0;
  static const double defaultCenterWidth = defaultSidebarWidth * 2;
  static const double defaultWindowWidth =
      defaultSidebarWidth + defaultCenterWidth;

  const factory WindowStateEntity({
    required double width,
    required double height,
    required double x,
    required double y,
    required bool isMinimized,
    required double sidebarWidth,
  }) = _WindowStateEntity;

  factory WindowStateEntity.defaultState() => const WindowStateEntity(
    width: defaultWindowWidth,
    height: 800.0,
    x: 100.0,
    y: 100.0,
    isMinimized: false,
    sidebarWidth: defaultSidebarWidth,
  );
}
