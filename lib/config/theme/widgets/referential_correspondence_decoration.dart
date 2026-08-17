import 'package:flutter/widgets.dart';

import '../colors/theme_colors.dart';

/// The established orange "this is the thing I am referring to" chrome.
///
/// This helper owns appearance only. Callers independently own correspondence
/// meaning, pulse occurrence, animation, and reduced-motion behavior.
BoxDecoration referentialCorrespondenceDecoration({
  required MessagePanels colors,
  required double pulse,
  required BorderRadius borderRadius,
}) {
  return BoxDecoration(
    color: colors.contextAnchorBackground.withValues(
      alpha: 0.10 + (0.12 * pulse),
    ),
    border: Border.all(
      color: colors.contextAnchorBorder.withValues(
        alpha: 0.55 + (0.35 * pulse),
      ),
      width: 1.25 + (1.15 * pulse),
    ),
    borderRadius: borderRadius,
    boxShadow: [
      BoxShadow(
        color: colors.contextAnchorGlow.withValues(
          alpha: 0.18 + (0.44 * pulse),
        ),
        blurRadius: 5 + (12 * pulse),
        spreadRadius: 0.5 + (1.8 * pulse),
      ),
    ],
  );
}
