import 'package:flutter/widgets.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../view_model/sidebar_cassette_card_view_model.dart';

Widget buildSidebarBodyContent({
  required Widget child,
  required SidebarGeometryConstraints geometry,
  required SidebarBodyContentAlignment contentAlignment,
}) {
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

  return switch (geometry.placementMode) {
    SidebarBodyPlacementMode.fullWidth => Align(
      alignment: Alignment.centerLeft,
      child: alignedChild,
    ),
    SidebarBodyPlacementMode.inset => Align(
      alignment: Alignment.centerLeft,
      child: alignedChild,
    ),
    SidebarBodyPlacementMode.insetWithTrailingGutter => Padding(
      padding: EdgeInsets.only(
        right:
            geometry.trailingGutterWidth + _sidebarInteriorGapForTrailingGutter,
      ),
      child: Align(alignment: Alignment.centerLeft, child: alignedChild),
    ),
  };
}

const double _sidebarInteriorGapForTrailingGutter = AppSpacing.sm;
