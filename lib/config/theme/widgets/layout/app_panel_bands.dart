import 'package:flutter/widgets.dart';

/// Shared vertical rhythm for peer application panels.
///
/// A panel should read in bands:
/// title -> primary object/context -> secondary controls/metadata -> content.
///
/// These constants intentionally describe layout rhythm, not business meaning.
/// Individual features still own the data and wording in each band.
abstract final class AppPanelBands {
  static const EdgeInsets centerPanelPadding = EdgeInsets.fromLTRB(
    32,
    24,
    32,
    28,
  );

  static const EdgeInsets sidePanelPadding = EdgeInsets.fromLTRB(16, 24, 16, 0);

  static const double titleToPrimaryGap = 14;
  static const double primaryToSecondaryGap = 12;
  static const double secondaryToContentGap = 14;
}
