import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import '../../../../../essentials/sidebar/presentation/view/sidebar_menu_section_header.dart';
import '../../../domain/settings_top_menu_row.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';

class SettingsTopMenuWidget extends HookConsumerWidget {
  const SettingsTopMenuWidget({super.key, required this.payload});

  final SettingsTopMenuCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = useState(payload.persistentContextActionId == null);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final dispatcher = ref.read(sidebarActionDispatcherProvider.notifier);
    final borderRadius = BorderRadius.circular(8);
    final selectedLabel =
        payload.persistentContextActionId?.label ?? payload.promptLabel;
    final hasSelection = payload.persistentContextActionId != null;

    useEffect(() {
      if (!hasSelection) {
        isOpen.value = true;
      }

      return null;
    }, [hasSelection]);

    Future<void> handleActionSelected(SettingsTopMenuActionRow row) async {
      isOpen.value = false;

      await dispatcher.dispatch(
        intent: row.intent,
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
                      color: colors.dropdownMenu(DropdownMenu.chevronBg),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isOpen.value
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.chevron_down,
                        size: 12,
                        color: colors.dropdownMenu(DropdownMenu.chevronIcon),
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
                  for (final entry in payload.rows.asMap().entries)
                    switch (entry.value) {
                      SettingsTopMenuGroupHeaderRow(:final label) =>
                        SidebarMenuSectionHeader(
                          label: label,
                          isFirstInMenu: entry.key == 0,
                        ),
                      SettingsTopMenuActionRow() => (() {
                        final row = entry.value as SettingsTopMenuActionRow;

                        return _SettingsTopMenuActionRowWidget(
                          row: row,
                          isSelected:
                              row.isPersistentContext &&
                              payload.persistentContextActionId == row.actionId,
                          onSelected: () {
                            return handleActionSelected(row);
                          },
                        );
                      })(),
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
        ? colors.dropdownMenu(DropdownMenu.selectedBg)
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
            padding: const EdgeInsets.symmetric(
              horizontal: sidebarMenuItemHorizontalInset,
              vertical: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row.label,
                    style: typography.controlValue.copyWith(
                      color: isSelected
                          ? colors.dropdownMenu(DropdownMenu.selectedText)
                          : colors.content.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Text(
                    '✓',
                    style: typography.controlValue.copyWith(
                      color: colors.dropdownMenu(DropdownMenu.checkmark),
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
