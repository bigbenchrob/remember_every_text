import 'package:flutter/widgets.dart';

/// Shared vertical rhythm for peer application panels.
///
/// The strict frame model owns two fixed-height regions above content:
/// top identity -> middle context/controls -> content.
///
/// These constants intentionally describe layout rhythm, not business meaning.
/// Individual features still own the data and wording inside each band.
abstract final class AppPanelBands {
  static const EdgeInsets centerPanelPadding = EdgeInsets.fromLTRB(
    32,
    24,
    32,
    28,
  );

  static const EdgeInsets sidePanelPadding = EdgeInsets.fromLTRB(16, 16, 16, 0);
  static const EdgeInsets endPanelPadding = EdgeInsets.fromLTRB(16, 24, 16, 28);

  static const double topBandHeight = 72;
  static const double middleBandHeight = 166;

  static const EdgeInsets sidebarTopBandPadding = EdgeInsets.fromLTRB(
    16,
    10,
    16,
    0,
  );
  static const EdgeInsets sidebarMiddleBandPadding = EdgeInsets.fromLTRB(
    16,
    0,
    16,
    0,
  );
  static const EdgeInsets centerTopBandPadding = EdgeInsets.fromLTRB(
    32,
    24,
    32,
    0,
  );
  static const EdgeInsets centerMiddleBandPadding = EdgeInsets.fromLTRB(
    32,
    0,
    32,
    0,
  );
  static const EdgeInsets endTopBandPadding = EdgeInsets.fromLTRB(
    32,
    24,
    32,
    0,
  );
  static const EdgeInsets endMiddleBandPadding = EdgeInsets.fromLTRB(
    32,
    0,
    32,
    0,
  );

  static const double titleBandHeight = 34;
  static const double primaryBandHeight = 82;
  static const double secondaryBandHeight = 58;

  static const double titleToPrimaryGap = 14;
  static const double primaryToSecondaryGap = 12;
  static const double secondaryToContentGap = 14;
}

/// Fixed-height frame for page columns that need cross-column alignment.
///
/// The frame does not infer meaning. It only guarantees that content begins
/// after the same top and middle vertical envelopes in participating columns.
class AppPanelColumnFrame extends StatelessWidget {
  const AppPanelColumnFrame({
    required this.top,
    required this.middle,
    required this.content,
    this.topPadding = AppPanelBands.centerTopBandPadding,
    this.middlePadding = AppPanelBands.centerMiddleBandPadding,
    this.topBandHeight = AppPanelBands.topBandHeight,
    this.middleBandHeight = AppPanelBands.middleBandHeight,
    super.key,
  });

  final Widget top;
  final Widget middle;
  final Widget content;
  final EdgeInsets topPadding;
  final EdgeInsets middlePadding;
  final double topBandHeight;
  final double middleBandHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPanelFixedBand(
          height: topBandHeight,
          padding: topPadding,
          child: top,
        ),
        AppPanelFixedBand(
          height: middleBandHeight,
          padding: middlePadding,
          child: middle,
        ),
        Expanded(child: content),
      ],
    );
  }
}

/// Fixed-height header for panels whose content list is owned elsewhere.
class AppPanelFrameHeader extends StatelessWidget {
  const AppPanelFrameHeader({
    required this.top,
    required this.middle,
    this.topPadding = AppPanelBands.centerTopBandPadding,
    this.middlePadding = AppPanelBands.centerMiddleBandPadding,
    this.topBandHeight = AppPanelBands.topBandHeight,
    this.middleBandHeight = AppPanelBands.middleBandHeight,
    super.key,
  });

  final Widget top;
  final Widget middle;
  final EdgeInsets topPadding;
  final EdgeInsets middlePadding;
  final double topBandHeight;
  final double middleBandHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPanelFixedBand(
          height: topBandHeight,
          padding: topPadding,
          child: top,
        ),
        AppPanelFixedBand(
          height: middleBandHeight,
          padding: middlePadding,
          child: middle,
        ),
      ],
    );
  }
}

/// A fixed-height envelope. Children may arrange themselves inside this space,
/// but they may not move the following band downward.
class AppPanelFixedBand extends StatelessWidget {
  const AppPanelFixedBand({
    required this.height,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topLeft,
    super.key,
  });

  final double height;
  final Widget child;
  final EdgeInsets padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: padding,
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}

/// Shared header skeleton for peer page panels.
///
/// This renders the invisible bands without adding chrome. The visual grammar
/// comes from fixed ownership of vertical space, not from boxes or dividers.
class AppPanelBandHeader extends StatelessWidget {
  const AppPanelBandHeader({
    required this.title,
    required this.primary,
    required this.secondary,
    this.padding = AppPanelBands.sidePanelPadding,
    this.titleBandHeight = AppPanelBands.titleBandHeight,
    this.primaryBandHeight = AppPanelBands.primaryBandHeight,
    this.secondaryBandHeight = AppPanelBands.secondaryBandHeight,
    super.key,
  });

  final Widget title;
  final Widget primary;
  final Widget secondary;
  final EdgeInsets padding;
  final double titleBandHeight;
  final double primaryBandHeight;
  final double secondaryBandHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: padding.left,
        top: padding.top,
        right: padding.right,
        bottom: padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: titleBandHeight,
            child: Align(alignment: Alignment.topLeft, child: title),
          ),
          SizedBox(
            height: primaryBandHeight,
            child: Align(alignment: Alignment.topLeft, child: primary),
          ),
          SizedBox(
            height: secondaryBandHeight,
            child: Align(alignment: Alignment.topLeft, child: secondary),
          ),
        ],
      ),
    );
  }
}
