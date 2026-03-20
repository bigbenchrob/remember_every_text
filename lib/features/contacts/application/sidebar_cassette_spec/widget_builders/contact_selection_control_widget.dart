import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';

/// Minimal text-link control that navigates back to the contact picker.
///
/// The selection control is **navigation, not content and not identity**.
/// It feels like a lightweight "back / change" affordance attached to the
/// top menu — no card chrome, no shadow, no contact name repeated.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
class ContactSelectionControlWidget extends ConsumerStatefulWidget {
  const ContactSelectionControlWidget({
    super.key,
    required this.contactId,
    required this.cassetteIndex,
  });

  /// The ID of the selected contact (carried through for cascade routing).
  final int contactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  ConsumerState<ContactSelectionControlWidget> createState() =>
      _ContactSelectionControlWidgetState();
}

class _ContactSelectionControlWidgetState
    extends ConsumerState<ContactSelectionControlWidget> {
  bool _isHovered = false;

  void _handleTap() {
    final heroCassetteIndex = widget.cassetteIndex - 1;

    ref
        .read(sidebarFlowProvider.notifier)
        .chooseAnotherContact(infoCardIndex: heroCassetteIndex);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    // Subtle accent tint at rest so the control reads as interactive
    // without competing with the hero card above.
    // Hover: full accent strength for confident feedback.
    final accent = colors.accents.primary;
    final textColor = _isHovered ? accent : accent.withValues(alpha: 0.80);
    final iconColor = _isHovered ? accent : accent.withValues(alpha: 0.60);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        // No extra horizontal padding — inherits info card's padding.
        // Small vertical padding for hit target.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chevron: directional cue — "this goes somewhere"
              Icon(CupertinoIcons.chevron_back, size: 11, color: iconColor),
              const SizedBox(width: 4),

              // Same size as info body, lighter weight — reads as
              // embedded affordance, not primary message.
              Text(
                'Change contact\u2026',
                style: typography.infoCardBody.copyWith(
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
