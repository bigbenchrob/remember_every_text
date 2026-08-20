import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../colors/theme_colors.dart';

/// Shared neutral action with explicit pointer hover and press feedback.
class AppSecondaryButton extends ConsumerStatefulWidget {
  const AppSecondaryButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  ConsumerState<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends ConsumerState<AppSecondaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final buttons = colors.buttons;
    final fillColor = !enabled
        ? buttons.secondaryBackgroundDisabled
        : _isPressed
        ? buttons.secondaryBackgroundPressed
        : _isHovered
        ? buttons.secondaryBackgroundHovered
        : buttons.secondaryBackground;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!enabled) {
          return;
        }
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _isPressed = false;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: enabled
            ? (_) {
                setState(() {
                  _isPressed = true;
                });
              }
            : null,
        onTapUp: enabled
            ? (_) {
                setState(() {
                  _isPressed = false;
                });
              }
            : null,
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          scale: _isPressed ? 0.98 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
