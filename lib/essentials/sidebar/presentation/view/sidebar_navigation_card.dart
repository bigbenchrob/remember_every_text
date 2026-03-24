import 'package:flutter/material.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../view_model/sidebar_cassette_card_view_model.dart';
import 'sidebar_body_layout.dart';

/// A full-bleed card for "back to previous state" navigation controls.
///
/// ## UI Sweep Changes
///
/// Per the design contract, this widget now provides **no visual chrome**:
/// - No distinct background (inherits from SidebarPlane)
/// - Child widget owns all internal layout and interaction
///
/// Unlike [SidebarCassetteCard] (content with rhythm) or [SidebarInfoCard]
/// (explanatory text), this card type is designed for lightweight navigation
/// affordances that need to span the full width of the sidebar.
///
/// The child widget owns all internal padding, typography, and interaction
/// (hover states, tap targets, etc.). The card provides only consistent
/// vertical margins to occupy the cassette flow.
///
/// ## Intended use cases
/// - "Change contact…" back-link after a contact is selected
/// - Future "back to …" navigation controls in other cascades
class SidebarNavigationCard extends StatelessWidget {
  const SidebarNavigationCard({
    super.key,
    required this.child,
    this.placementMode = SidebarBodyPlacementMode.fullWidth,
    this.contentAlignment = SidebarBodyContentAlignment.leftAnchored,
  });

  /// The navigation control widget. Owns all internal layout and styling.
  final Widget child;
  final SidebarBodyPlacementMode placementMode;
  final SidebarBodyContentAlignment contentAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = _navigationPaddingForPlacement(placementMode);
        final contentEnvelopeWidth = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - padding.horizontal).clamp(
                0.0,
                double.infinity,
              )
            : 0.0;
        final geometry = SidebarGeometryConstraints.fromTokens(
          placementMode: placementMode,
          tokens: SidebarGeometryTokens(
            contentEnvelopeWidth: contentEnvelopeWidth,
            bodyInset: 0,
            trailingGutterWidth: AppSpacing.xl,
            interiorGap: AppSpacing.sm,
          ),
        );

        return Padding(
          padding: padding,
          child: buildSidebarBodyContent(
            child: child,
            geometry: geometry,
            contentAlignment: contentAlignment,
          ),
        );
      },
    );
  }
}

EdgeInsets _navigationPaddingForPlacement(
  SidebarBodyPlacementMode placementMode,
) {
  return switch (placementMode) {
    SidebarBodyPlacementMode.fullWidth => const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    SidebarBodyPlacementMode.inset => const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    SidebarBodyPlacementMode.insetWithTrailingGutter => const EdgeInsets.only(
      left: AppSpacing.md,
      right: AppSpacing.md + AppSpacing.xl,
    ),
  };
}
