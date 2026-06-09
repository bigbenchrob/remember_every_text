import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../view_model/sidebar_cassette_card_view_model.dart';
import 'sidebar_body_layout.dart';

/// A content container for sidebar cassette widgets.
///
/// ## UI Sweep Changes
///
/// This widget now provides **content layout only**, not visual chrome.
/// Per the design contract:
/// - No card borders or shadows
/// - No distinct background (inherits from SidebarPlane)
/// - Styling comes from tokens and structural wrapper context
///
/// The cassette "card" is now a rhythm/spacing container that handles:
/// - Title and subtitle layout
/// - Section headers and footers
/// - Consistent padding using AppSpacing tokens
/// - Expansion behavior for variable-height content
///
/// Visual hierarchy comes from typography tokens, not card boundaries.
abstract class SidebarCassetteCard extends ConsumerWidget {
  final Widget child;

  final String title;
  final String? subtitle;

  /// Optional section label rendered by the card (not the feature).
  final String? sectionTitle;

  /// Optional footer/helper text rendered by the card (not the feature).
  final String? footerText;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isNaked;
  final bool shouldExpand;
  final SidebarCassetteRole role;
  final SidebarBodyPlacementMode placementMode;
  final SidebarBodyContentAlignment contentAlignment;

  /// Layout style controlling horizontal rails.
  /// When non-null, overrides [padding] and [margin] with style-derived values.
  final SidebarCardLayoutStyle? layoutStyle;

  factory SidebarCassetteCard({
    Key? key,
    required Widget child,
    required String title,
    String? subtitle,
    String? sectionTitle,
    String? footerText,
    EdgeInsetsGeometry padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    bool isNaked = false,
    bool shouldExpand = false,
    SidebarCassetteRole role = SidebarCassetteRole.contextPrimary,
    SidebarBodyPlacementMode placementMode = SidebarBodyPlacementMode.inset,
    SidebarBodyContentAlignment contentAlignment =
        SidebarBodyContentAlignment.fill,
    SidebarCardLayoutStyle? layoutStyle,
  }) {
    return _StandardSidebarCassetteCard(
      key: key,
      title: title,
      subtitle: subtitle,
      sectionTitle: sectionTitle,
      footerText: footerText,
      padding: padding,
      margin: margin,
      isNaked: isNaked,
      shouldExpand: shouldExpand,
      role: role,
      placementMode: placementMode,
      contentAlignment: contentAlignment,
      layoutStyle: layoutStyle,
      child: child,
    );
  }

  factory SidebarCassetteCard.placementGoverned({
    Key? key,
    required Widget child,
    required String title,
    String? subtitle,
    String? sectionTitle,
    String? footerText,
    EdgeInsetsGeometry padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    bool isNaked = false,
    bool shouldExpand = false,
    SidebarCassetteRole role = SidebarCassetteRole.contextPrimary,
    SidebarBodyPlacementMode placementMode = SidebarBodyPlacementMode.inset,
    SidebarBodyContentAlignment contentAlignment =
        SidebarBodyContentAlignment.fill,
    SidebarCardLayoutStyle? layoutStyle,
  }) {
    return _PlacementGovernedSidebarCassetteCard(
      key: key,
      title: title,
      subtitle: subtitle,
      sectionTitle: sectionTitle,
      footerText: footerText,
      padding: padding,
      margin: margin,
      isNaked: isNaked,
      shouldExpand: shouldExpand,
      role: role,
      placementMode: placementMode,
      contentAlignment: contentAlignment,
      layoutStyle: layoutStyle,
      child: child,
    );
  }

  const SidebarCassetteCard._({
    super.key,
    required this.child,
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.isNaked = false,
    this.shouldExpand = false,
    this.role = SidebarCassetteRole.contextPrimary,
    this.placementMode = SidebarBodyPlacementMode.inset,
    this.contentAlignment = SidebarBodyContentAlignment.fill,
    this.layoutStyle,
  });

  bool get _usesPlacementLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Naked mode: minimal wrapper with only horizontal margin for edge alignment
    if (isNaked) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final nakedPadding = _nakedPaddingForPlacement(placementMode);
          final contentEnvelopeWidth = constraints.maxWidth.isFinite
              ? (constraints.maxWidth - nakedPadding.horizontal).clamp(
                  0.0,
                  double.infinity,
                )
              : 0.0;
          final geometry = SidebarGeometryConstraints.fromTokens(
            placementMode: placementMode,
            tokens: SidebarGeometryTokens(
              contentEnvelopeWidth: contentEnvelopeWidth,
              bodyInset: 0,
              trailingGutterWidth: _sidebarTrailingGutterWidth,
              interiorGap: _sidebarInteriorGapForGutter,
            ),
          );

          return Padding(
            padding: nakedPadding,
            child: _usesPlacementLayout
                ? buildPlacementGovernedSidebarBodyContent(
                    child: child,
                    geometry: geometry,
                    contentAlignment: contentAlignment,
                  )
                : buildSidebarBodyContent(
                    child: child,
                    geometry: geometry,
                    contentAlignment: contentAlignment,
                  ),
          );
        },
      );
    }

    final typography = ref.watch(themeTypographyProvider);

    final hasTitle = title.trim().isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final hasSectionTitle =
        sectionTitle != null && sectionTitle!.trim().isNotEmpty;
    final hasFooter = footerText != null && footerText!.trim().isNotEmpty;

    final showHeader = hasTitle || hasSubtitle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        // Compute effective margin/padding from layoutStyle or placement mode.
        // If no explicit override is active, placementMode owns the horizontal
        // body geometry and derives concrete constraints from the live sidebar
        // width.
        final (effectiveMargin, effectivePadding, sectionTitleGap, geometry) =
            _computeLayout(maxWidth: constraints.maxWidth);

        final body = _buildBodyWithGeometry(geometry);

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (showHeader) ...[
              if (hasTitle) Text(title, style: typography.cassetteCardTitle),
              if (hasSubtitle) ...[
                if (hasTitle) const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: typography.cassetteCardSubtitle),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],

            if (hasSectionTitle) ...[
              Text(sectionTitle!, style: typography.cassetteCardSectionHeader),
              SizedBox(height: sectionTitleGap),
            ],

            if (hasBoundedHeight && shouldExpand)
              Expanded(child: body)
            else
              body,

            if (hasFooter) ...[
              const SizedBox(height: AppSpacing.md),
              Text(footerText!, style: typography.cassetteCardFooter),
            ],
          ],
        );

        // No visual chrome: transparent background, no border, no shadow.
        // The SidebarPlane provides the background; this widget provides rhythm.
        return Padding(
          padding: effectiveMargin,
          child: Padding(padding: effectivePadding, child: content),
        );
      },
    );
  }

  Widget _buildBodyWithGeometry(SidebarGeometryConstraints? geometry) {
    if (geometry == null) {
      return child;
    }

    return _usesPlacementLayout
        ? buildPlacementGovernedSidebarBodyContent(
            child: child,
            geometry: geometry,
            contentAlignment: contentAlignment,
          )
        : buildSidebarBodyContent(
            child: child,
            geometry: geometry,
            contentAlignment: contentAlignment,
          );
  }

  /// Computes (margin, padding, sectionTitleGap, geometry) based on any
  /// remaining layoutStyle override first, then placementMode.
  (EdgeInsets, EdgeInsets, double, SidebarGeometryConstraints?) _computeLayout({
    required double maxWidth,
  }) {
    if (layoutStyle != null && !_usesPlacementLayout) {
      return switch (layoutStyle!) {
        SidebarCardLayoutStyle.standard => (
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          const EdgeInsets.all(AppSpacing.md),
          AppSpacing.sm,
          null,
        ),
        SidebarCardLayoutStyle.listDense => (
          EdgeInsets.zero,
          const EdgeInsets.symmetric(horizontal: 12, vertical: AppSpacing.sm),
          AppSpacing.xs,
          null,
        ),
        SidebarCardLayoutStyle.controlAligned => (
          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          EdgeInsets.zero,
          0.0,
          null,
        ),
      };
    }

    final (
      effectiveMargin,
      effectivePadding,
      sectionTitleGap,
    ) = layoutStyle == null
        ? (margin as EdgeInsets, padding as EdgeInsets, AppSpacing.sm)
        : switch (layoutStyle!) {
            SidebarCardLayoutStyle.standard => (
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              const EdgeInsets.all(AppSpacing.md),
              AppSpacing.sm,
            ),
            SidebarCardLayoutStyle.listDense => (
              EdgeInsets.zero,
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: AppSpacing.sm,
              ),
              AppSpacing.xs,
            ),
            SidebarCardLayoutStyle.controlAligned => (
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              EdgeInsets.zero,
              0.0,
            ),
          };

    final contentEnvelopeWidth = maxWidth.isFinite
        ? (maxWidth - effectiveMargin.horizontal).clamp(0.0, double.infinity)
        : 0.0;
    final geometry = SidebarGeometryConstraints.fromTokens(
      placementMode: placementMode,
      tokens: SidebarGeometryTokens(
        contentEnvelopeWidth: contentEnvelopeWidth,
        bodyInset: effectivePadding.horizontal / 2,
        trailingGutterWidth: _sidebarTrailingGutterWidth,
        interiorGap: _sidebarInteriorGapForGutter,
      ),
    );

    final placementPadding = _paddingForPlacement(
      placementMode: placementMode,
      currentPadding: effectivePadding,
    );

    return (effectiveMargin, placementPadding, sectionTitleGap, geometry);
  }
}

final class _StandardSidebarCassetteCard extends SidebarCassetteCard {
  const _StandardSidebarCassetteCard({
    super.key,
    required super.child,
    required super.title,
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    super.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    super.isNaked = false,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.contextPrimary,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle,
  }) : super._();

  @override
  bool get _usesPlacementLayout {
    return false;
  }
}

final class _PlacementGovernedSidebarCassetteCard extends SidebarCassetteCard {
  const _PlacementGovernedSidebarCassetteCard({
    super.key,
    required super.child,
    required super.title,
    super.subtitle,
    super.sectionTitle,
    super.footerText,
    super.padding = const EdgeInsets.only(
      left: AppSpacing.md,
      top: AppSpacing.md,
      right: AppSpacing.md,
      bottom: AppSpacing.md,
    ),
    super.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    super.isNaked = false,
    super.shouldExpand = false,
    super.role = SidebarCassetteRole.contextPrimary,
    super.placementMode = SidebarBodyPlacementMode.inset,
    super.contentAlignment = SidebarBodyContentAlignment.fill,
    super.layoutStyle,
  }) : super._();

  @override
  bool get _usesPlacementLayout {
    return true;
  }
}

EdgeInsets _nakedPaddingForPlacement(SidebarBodyPlacementMode placementMode) {
  return switch (placementMode) {
    SidebarBodyPlacementMode.fullWidth => const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    SidebarBodyPlacementMode.inset => const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
    ),
    SidebarBodyPlacementMode.insetWithTrailingGutter => const EdgeInsets.only(
      left: AppSpacing.md,
      right: AppSpacing.md + _sidebarTrailingGutterWidth,
    ),
  };
}

EdgeInsets _paddingForPlacement({
  required SidebarBodyPlacementMode placementMode,
  required EdgeInsets currentPadding,
}) {
  return switch (placementMode) {
    SidebarBodyPlacementMode.fullWidth => EdgeInsets.only(
      left: 0,
      top: currentPadding.top,
      right: 0,
      bottom: currentPadding.bottom,
    ),
    SidebarBodyPlacementMode.inset => currentPadding,
    SidebarBodyPlacementMode.insetWithTrailingGutter => EdgeInsets.only(
      left: currentPadding.left,
      top: currentPadding.top,
      right: currentPadding.right,
      bottom: currentPadding.bottom,
    ),
  };
}

const double _sidebarTrailingGutterWidth = AppSpacing.xl;
const double _sidebarInteriorGapForGutter = AppSpacing.sm;
