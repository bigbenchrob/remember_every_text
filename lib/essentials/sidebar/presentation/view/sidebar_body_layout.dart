import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../view_model/sidebar_cassette_card_view_model.dart';

class SidebarConstrainedContent extends StatelessWidget {
  const SidebarConstrainedContent({
    required this.child,
    required this.geometry,
    required this.contentAlignment,
    super.key,
  }) : _shouldClip = false;

  const SidebarConstrainedContent.placementGoverned({
    required this.child,
    required this.geometry,
    required this.contentAlignment,
    super.key,
  }) : _shouldClip = true;

  final Widget child;
  final SidebarGeometryConstraints geometry;
  final SidebarBodyContentAlignment contentAlignment;
  final bool _shouldClip;

  @override
  Widget build(BuildContext context) {
    final alignedChild = switch (contentAlignment) {
      SidebarBodyContentAlignment.fill => SizedBox(
        width: geometry.maxContentWidth,
        child: child,
      ),
      SidebarBodyContentAlignment.insetControl => SizedBox(
        width: geometry.maxContentWidth,
        child: child,
      ),
      SidebarBodyContentAlignment.leftAnchored => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: geometry.maxContentWidth),
        child: child,
      ),
      SidebarBodyContentAlignment.loose => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: geometry.maxContentWidth),
        child: child,
      ),
    };

    final positionedChild = switch (geometry.placementMode) {
      SidebarBodyPlacementMode.fullWidth => Align(
        alignment: Alignment.topLeft,
        child: alignedChild,
      ),
      SidebarBodyPlacementMode.inset => Align(
        alignment: Alignment.topLeft,
        child: alignedChild,
      ),
      SidebarBodyPlacementMode.insetWithTrailingGutter => Padding(
        padding: EdgeInsets.only(
          right:
              geometry.trailingGutterWidth +
              _sidebarInteriorGapForTrailingGutter,
        ),
        child: Align(alignment: Alignment.topLeft, child: alignedChild),
      ),
    };

    if (_shouldClip) {
      return ClipRect(child: positionedChild);
    }

    return positionedChild;
  }
}

Widget buildSidebarBodyContent({
  required Widget child,
  required SidebarGeometryConstraints geometry,
  required SidebarBodyContentAlignment contentAlignment,
}) {
  return SidebarConstrainedContent(
    geometry: geometry,
    contentAlignment: contentAlignment,
    child: child,
  );
}

Widget buildPlacementGovernedSidebarBodyContent({
  required Widget child,
  required SidebarGeometryConstraints geometry,
  required SidebarBodyContentAlignment contentAlignment,
}) {
  return SidebarConstrainedContent.placementGoverned(
    geometry: geometry,
    contentAlignment: contentAlignment,
    child: child,
  );
}

const double _sidebarInteriorGapForTrailingGutter = AppSpacing.sm;
