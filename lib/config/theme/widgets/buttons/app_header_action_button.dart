import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../colors/theme_colors.dart';
import '../../theme_typography.dart';

/// Compact header/action-strip button for secondary evidence and navigation
/// actions.
class AppHeaderActionButton extends ConsumerStatefulWidget {
  const AppHeaderActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  ConsumerState<AppHeaderActionButton> createState() =>
      _AppHeaderActionButtonState();
}

class _AppHeaderActionButtonState extends ConsumerState<AppHeaderActionButton> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final isInteractive = widget.isEnabled;
    final backgroundColor = !isInteractive
        ? colors.surfaces.control
        : _isHovered
        ? colors.surfaces.selected
        : colors.surfaces.surface;
    final borderColor = !isInteractive
        ? colors.lines.borderSubtle
        : _isHovered
        ? colors.accents.primary
        : colors.lines.borderSubtle;
    final contentColor = !isInteractive
        ? colors.content.textSecondary
        : colors.content.textPrimary;

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!isInteractive) {
          return;
        }
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        if (!_isHovered) {
          return;
        }
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: isInteractive ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 13, color: contentColor),
                const SizedBox(width: 4),
                Text(
                  widget.label,
                  style: typography.caption.copyWith(
                    color: contentColor,
                    fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w600,
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
