import 'package:flutter/widgets.dart';

/// Semantic grouping for sidebar cassettes.
///
/// This lets essentials own section ordering and hierarchy without inferring
/// meaning from layout flags or widget shape.
enum SidebarCassetteRole {
  appControl,
  contextPrimary,
  contextSecondary,
  filter,
  action,
}

/// Approved content placement modes within the sidebar content envelope.
enum SidebarBodyPlacementMode { fullWidth, inset, insetWithTrailingGutter }

/// How cassette content behaves once it is inside the shared sidebar envelope.
enum SidebarBodyContentAlignment { fill, leftAnchored, insetControl, loose }

/// Centrally owned geometry constraints derived from sidebar tokens.
class SidebarGeometryConstraints {
  const SidebarGeometryConstraints({
    required this.placementMode,
    required this.contentEnvelopeWidth,
    required this.maxContentWidth,
    required this.hasTrailingGutter,
    required this.trailingGutterWidth,
    required this.trailingAffordanceMaxWidth,
  });

  factory SidebarGeometryConstraints.fromTokens({
    required SidebarBodyPlacementMode placementMode,
    required SidebarGeometryTokens tokens,
  }) {
    switch (placementMode) {
      case SidebarBodyPlacementMode.fullWidth:
        return SidebarGeometryConstraints(
          placementMode: placementMode,
          contentEnvelopeWidth: tokens.contentEnvelopeWidth,
          maxContentWidth: tokens.contentEnvelopeWidth,
          hasTrailingGutter: false,
          trailingGutterWidth: 0,
          trailingAffordanceMaxWidth: 0,
        );
      case SidebarBodyPlacementMode.inset:
        final insetWidth = tokens.contentEnvelopeWidth - (tokens.bodyInset * 2);

        return SidebarGeometryConstraints(
          placementMode: placementMode,
          contentEnvelopeWidth: tokens.contentEnvelopeWidth,
          maxContentWidth: insetWidth,
          hasTrailingGutter: false,
          trailingGutterWidth: 0,
          trailingAffordanceMaxWidth: 0,
        );
      case SidebarBodyPlacementMode.insetWithTrailingGutter:
        final mainWidth =
            tokens.contentEnvelopeWidth -
            tokens.bodyInset -
            tokens.trailingGutterWidth -
            tokens.interiorGap;

        return SidebarGeometryConstraints(
          placementMode: placementMode,
          contentEnvelopeWidth: tokens.contentEnvelopeWidth,
          maxContentWidth: mainWidth,
          hasTrailingGutter: true,
          trailingGutterWidth: tokens.trailingGutterWidth,
          trailingAffordanceMaxWidth: tokens.trailingGutterWidth,
        );
    }
  }

  final SidebarBodyPlacementMode placementMode;
  final double contentEnvelopeWidth;
  final double maxContentWidth;
  final bool hasTrailingGutter;
  final double trailingGutterWidth;
  final double trailingAffordanceMaxWidth;
}

/// Tunable geometry tokens for the sidebar cassette system.
class SidebarGeometryTokens {
  const SidebarGeometryTokens({
    required this.contentEnvelopeWidth,
    required this.bodyInset,
    required this.trailingGutterWidth,
    required this.interiorGap,
  });

  final double contentEnvelopeWidth;
  final double bodyInset;
  final double trailingGutterWidth;
  final double interiorGap;
}

/// Layout style for [SidebarCassetteCard] horizontal rails.
///
/// Controls margin, padding, and title gaps without changing card structure.
/// Use this when differences are mainly about horizontal insets and breathing
/// room, not structural/behavioral changes.
enum SidebarCardLayoutStyle {
  /// Standard layout with generous horizontal insets (32pt total).
  /// Suitable for most cassettes with moderate content density.
  standard,

  /// Dense layout for space-sensitive lists (12pt horizontal inset).
  /// Use when horizontal space is at a premium (e.g., scrollable lists
  /// with metadata, action overlays, or long text content).
  listDense,

  /// Width-aligned with naked/control items (16pt horizontal inset).
  /// Use when a non-naked card (needing shouldExpand or title slots)
  /// must match the horizontal width of naked cards above it.
  controlAligned,
}

/// Essentials-owned payload families for the sidebar cassette shell.
sealed class SidebarCassettePayload {
  const SidebarCassettePayload({required this.role, this.topSpacing = 0});

  /// Semantic role used by essentials-owned sidebar composition.
  final SidebarCassetteRole role;

  /// Extra vertical space to insert above this cassette in the sidebar stack.
  final double topSpacing;
}

/// Standard content cassette payload.
class SidebarCassetteCardViewModel extends SidebarCassettePayload {
  const SidebarCassetteCardViewModel({
    SidebarCassetteRole role = SidebarCassetteRole.contextPrimary,
    this.placementMode = SidebarBodyPlacementMode.inset,
    this.contentAlignment = SidebarBodyContentAlignment.fill,
    required this.title,
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    required this.child,
    this.layoutStyle = SidebarCardLayoutStyle.standard,
    this.isNaked = false,
    double topSpacing = 0,
    bool? shouldExpand,
  }) : shouldExpand = shouldExpand ?? false,
       super(role: role, topSpacing: topSpacing);

  /// Approved placement mode used by the sidebar geometry contract.
  final SidebarBodyPlacementMode placementMode;

  /// Approved content alignment used inside the shared sidebar envelope.
  final SidebarBodyContentAlignment contentAlignment;

  /// Display title shown in the sidebar card header.
  final String title;

  /// Optional descriptive text shown below the title.
  final String? subtitle;

  final String? sectionTitle;
  final String? footerText;

  /// The cassette content widget rendered inside the card.
  ///
  /// For [CassetteCardType.standard], this is the interactive body content.
  final Widget child;

  /// Layout style controlling horizontal rails (margin/padding/gaps).
  ///
  /// Defaults to [SidebarCardLayoutStyle.standard] with generous insets.
  /// Use [SidebarCardLayoutStyle.listDense] for space-sensitive lists.
  final SidebarCardLayoutStyle layoutStyle;

  /// Whether this cassette should render "naked" - with only horizontal margin
  /// to align edges with cards, but no padding, border, background, or shadow.
  /// Use for dropdown menus and other controls that should align flush with
  /// cassette card edges.
  final bool isNaked;

  /// Extra vertical space to insert above this cassette in the sidebar stack.
  ///
  /// Shared sidebar wrappers own the capability; features opt into it for
  /// layouts that need more breathing room than the default cassette rhythm.
  /// Whether this cassette should expand to fill available vertical space.
  ///
  /// Defaults to `false` — cards take their intrinsic height unless the
  /// resolver explicitly opts in with `shouldExpand: true` (e.g. scrollable
  /// lists that should fill the remaining sidebar space).
  final bool shouldExpand;
}

/// Canonical informational cassette payload.
class SidebarInfoCassetteViewModel extends SidebarCassettePayload {
  const SidebarInfoCassetteViewModel({
    SidebarCassetteRole role = SidebarCassetteRole.contextSecondary,
    double topSpacing = 0,
    this.title,
    required this.bodyText,
    this.footnote,
    this.content,
  }) : super(role: role, topSpacing: topSpacing);

  final String? title;
  final String bodyText;
  final String? footnote;
  final Widget? content;
}

/// Canonical navigation cassette payload.
class SidebarNavigationCassetteViewModel extends SidebarCassettePayload {
  const SidebarNavigationCassetteViewModel({
    SidebarCassetteRole role = SidebarCassetteRole.action,
    double topSpacing = 0,
    required this.child,
    this.placementMode = SidebarBodyPlacementMode.fullWidth,
    this.contentAlignment = SidebarBodyContentAlignment.leftAnchored,
  }) : super(role: role, topSpacing: topSpacing);

  final Widget child;
  final SidebarBodyPlacementMode placementMode;
  final SidebarBodyContentAlignment contentAlignment;
}
