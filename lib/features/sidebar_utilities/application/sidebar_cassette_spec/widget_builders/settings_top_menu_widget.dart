import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../domain/settings_top_menu_row.dart';
import '../../../domain/sidebar_utilities_constants.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';

class SettingsTopMenuWidget extends HookConsumerWidget {
  const SettingsTopMenuWidget({super.key, required this.payload});

  final SettingsTopMenuCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = useState(false);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final dispatcher = ref.read(sidebarActionDispatcherProvider.notifier);
    final borderRadius = BorderRadius.circular(8);
    final selectedLabel =
        payload.persistentContextActionId?.label ?? payload.promptLabel;
    final hasSelection = payload.persistentContextActionId != null;

    Future<void> handleActionSelected(SettingsTopMenuActionRow row) async {
      isOpen.value = false;
      final SidebarActionIntent intent;

      switch (row.semantic) {
        case SettingsTopMenuActionSemantic.persistentContext:
          intent = SettingsTopMenuActionChosen(
            actionId: row.actionId,
            semantic: row.semantic,
          );
        case SettingsTopMenuActionSemantic.transientAction:
          intent = switch (row.actionId) {
            SettingsMenuActionId.sendLogs => const ShowSendLogsFlow(),
            SettingsMenuActionId.resetMessageData =>
              const ShowResetMessageDataFlow(),
            SettingsMenuActionId.textSize ||
            SettingsMenuActionId.imageSize => throw StateError(
              'Persistent settings rows must not dispatch transient flow '
              'intents.',
            ),
          };
      }

      await dispatcher.dispatch(
        intent: intent,
        context: SidebarActionDispatchContext(
          sidebarMode: SidebarMode.settings,
          cassetteIndex: payload.cassetteIndex,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            isOpen.value = !isOpen.value;
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 16,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLabel,
                      style: typography.controlValue.copyWith(
                        color: hasSelection
                            ? colors.content.textPrimary
                            : colors.content.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accents.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        isOpen.value ? '▴' : '▾',
                        style: typography.caption.copyWith(
                          color: colors.accents.primary,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOpen.value) ...[
          const SizedBox(height: 8),
          _DropdownPanelDecoration(
            borderRadius: borderRadius,
            backgroundColor: colors.surfaces.surfaceRaised,
            borderLayers: colors.lines.dropdown,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final row in payload.rows)
                    switch (row) {
                      SettingsTopMenuGroupHeaderRow() => Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 8,
                          bottom: 4,
                        ),
                        child: Text(
                          row.label,
                          style: typography.caption.copyWith(
                            color: colors.content.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      SettingsTopMenuActionRow() =>
                        _SettingsTopMenuActionRowWidget(
                          row: row,
                          isSelected:
                              row.isPersistentContext &&
                              payload.persistentContextActionId == row.actionId,
                          onSelected: () {
                            return handleActionSelected(row);
                          },
                        ),
                    },
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsTopMenuActionRowWidget extends HookConsumerWidget {
  const _SettingsTopMenuActionRowWidget({
    required this.row,
    required this.isSelected,
    required this.onSelected,
  });

  final SettingsTopMenuActionRow row;
  final bool isSelected;
  final Future<void> Function() onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = useState(false);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final backgroundColor = isSelected
        ? colors.accents.primary.withValues(alpha: 0.12)
        : isHovered.value
        ? colors.content.textPrimary.withValues(alpha: 0.05)
        : const Color(0x00000000);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        isHovered.value = true;
      },
      onExit: (_) {
        isHovered.value = false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          await onSelected();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.label,
                    style: typography.controlValue.copyWith(
                      color: isSelected
                          ? colors.accents.primary
                          : colors.content.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Text(
                    '✓',
                    style: typography.controlValue.copyWith(
                      color: colors.accents.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownPanelDecoration extends StatelessWidget {
  const _DropdownPanelDecoration({
    required this.child,
    required this.borderRadius,
    required this.backgroundColor,
    required this.borderLayers,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final BorderLayers borderLayers;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _DropdownBorderPainter(
          borderRadius: borderRadius,
          colors: [borderLayers.outer, borderLayers.inner],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: backgroundColor),
          child: child,
        ),
      ),
    );
  }
}

class _DropdownBorderPainter extends CustomPainter {
  const _DropdownBorderPainter({
    required this.borderRadius,
    required this.colors,
  });

  final BorderRadius borderRadius;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) {
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var index = 0; index < colors.length; index++) {
      final inset = index.toDouble();
      final offset = inset + 0.5;
      if (size.width <= offset * 2 || size.height <= offset * 2) {
        break;
      }

      paint.color = colors[index];
      final rect =
          Offset(offset, offset) &
          Size(size.width - offset * 2, size.height - offset * 2);
      final rrect = _insetBorderRadius(borderRadius, offset).toRRect(rect);

      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DropdownBorderPainter oldDelegate) {
    if (oldDelegate.borderRadius != borderRadius) {
      return true;
    }

    if (oldDelegate.colors.length != colors.length) {
      return true;
    }

    for (var index = 0; index < colors.length; index++) {
      if (oldDelegate.colors[index] != colors[index]) {
        return true;
      }
    }

    return false;
  }
}

BorderRadius _insetBorderRadius(BorderRadius radius, double inset) {
  if (inset == 0) {
    return radius;
  }

  Radius shrink(Radius original) {
    if (original == Radius.zero) {
      return Radius.zero;
    }

    final x = math.max<double>(0.0, original.x - inset);
    final y = math.max<double>(0.0, original.y - inset);
    return Radius.elliptical(x, y);
  }

  return BorderRadius.only(
    topLeft: shrink(radius.topLeft),
    topRight: shrink(radius.topRight),
    bottomLeft: shrink(radius.bottomLeft),
    bottomRight: shrink(radius.bottomRight),
  );
}
