import '../../domain/entities/cassette_spec.dart';
import '../../domain/sidebar_body_model.dart';

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

/// Shared semantic styling hints for sidebar composition.
///
/// Unlike [SidebarCassetteRole], which still drives behavioral composition
/// decisions such as pinned app controls, this style channel exists purely so
/// essentials can apply shared visual hierarchy rules across features.
enum SidebarCassetteSemanticStyle {
  automatic,
  plain,
  primaryContextGroup,
  supportingContext,
  groupedControls,
  visualization,
}

/// Optional semantic anchor for page-level sidebar alignment.
///
/// This does not change how an individual cassette renders. It lets the
/// sidebar stack expose a stable content-start seam to page layouts that align
/// peer columns.
enum SidebarCassetteLayoutAnchor { none, preferredContentStart }

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

/// Explicit render families owned by the sidebar render router.
///
/// Rendering must be selected by this render contract plus concrete payload
/// subtype where needed. Payloads must not carry builder callbacks or prebuilt
/// render-selection logic.
enum SidebarCassetteRenderKind {
  placementGovernedFeature,
  featureInfo,
  sharedBodyModel,
}

/// Sidebar cassette payload transport base for the shared sidebar shell.
///
/// LAW: Meaning may cross this boundary as payload data. Execution may not.
abstract base class SidebarCassettePayload {
  const SidebarCassettePayload({
    required this.role,
    this.topSpacing = 0,
    this.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    this.layoutAnchor = SidebarCassetteLayoutAnchor.none,
  });

  /// Semantic role used by essentials-owned sidebar composition.
  final SidebarCassetteRole role;

  /// Extra vertical space to insert above this cassette in the sidebar stack.
  final double topSpacing;

  /// Shared semantic hint used by essentials-owned sidebar hierarchy.
  final SidebarCassetteSemanticStyle semanticStyle;

  /// Optional semantic seam used by page-level sidebar layout.
  final SidebarCassetteLayoutAnchor layoutAnchor;

  /// Explicit render contract consumed by the sidebar render router.
  SidebarCassetteRenderKind get renderKind;
}

/// Inert cassette payload branch.
///
/// Payloads in this branch may carry semantic data, layout descriptors, and
/// typed intents, but they must not transport widgets, builders, refs,
/// contexts, controllers, or executable behavior.
///
/// LAW: Any field here must remain inert in spirit, even if never serialized.
abstract base class InertSidebarCassettePayload extends SidebarCassettePayload {
  const InertSidebarCassettePayload({
    required super.role,
    super.topSpacing = 0,
    super.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    super.layoutAnchor = SidebarCassetteLayoutAnchor.none,
  });
}

/// Shared inert payload contract for feature-owned cassettes that still render
/// inside the essentials-owned placement-governed card shell.
abstract base class PlacementGovernedSidebarCassettePayload
    extends InertSidebarCassettePayload {
  const PlacementGovernedSidebarCassettePayload({
    required super.role,
    super.topSpacing = 0,
    super.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    super.layoutAnchor = SidebarCassetteLayoutAnchor.none,
    this.title = '',
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    this.placementMode = SidebarBodyPlacementMode.inset,
    this.contentAlignment = SidebarBodyContentAlignment.fill,
    this.layoutStyle = SidebarCardLayoutStyle.standard,
    this.isNaked = false,
    this.shouldExpand = false,
  });

  final String title;
  final String? subtitle;
  final String? sectionTitle;
  final String? footerText;
  final SidebarBodyPlacementMode placementMode;
  final SidebarBodyContentAlignment contentAlignment;
  final SidebarCardLayoutStyle layoutStyle;
  final bool isNaked;
  final bool shouldExpand;

  @override
  SidebarCassetteRenderKind get renderKind =>
      SidebarCassetteRenderKind.placementGovernedFeature;
}

/// Shared inert payload contract for feature-owned info cassettes that render
/// through the shared [SidebarInfoCard] chrome.
abstract base class FeatureInfoSidebarCassettePayload
    extends InertSidebarCassettePayload {
  const FeatureInfoSidebarCassettePayload({
    required this.bodyText,
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    super.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    this.title,
    this.footnote,
  });

  final String? title;
  final String bodyText;
  final String? footnote;

  @override
  SidebarCassetteRenderKind get renderKind =>
      SidebarCassetteRenderKind.featureInfo;
}

/// Concrete inert payload for static text-only info cassettes.
final class StaticFeatureInfoSidebarCassettePayload
    extends FeatureInfoSidebarCassettePayload {
  const StaticFeatureInfoSidebarCassettePayload({
    required super.bodyText,
    super.role = SidebarCassetteRole.contextSecondary,
    super.topSpacing = 0,
    super.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    super.title,
    super.footnote,
  });
}

/// Shared inert payload contract for essentials-owned body-model cassettes.
final class SharedBodyModelSidebarCassettePayload
    extends InertSidebarCassettePayload {
  const SharedBodyModelSidebarCassettePayload({
    required this.bodyModel,
    super.role = SidebarCassetteRole.contextPrimary,
    super.topSpacing = 0,
    super.semanticStyle = SidebarCassetteSemanticStyle.automatic,
    this.placementMode = SidebarBodyPlacementMode.inset,
    this.contentAlignment = SidebarBodyContentAlignment.fill,
    this.title = '',
    this.subtitle,
    this.sectionTitle,
    this.footerText,
    this.layoutStyle = SidebarCardLayoutStyle.standard,
    this.isNaked = false,
    this.shouldExpand = false,
  });

  final SidebarBodyModel bodyModel;
  final SidebarBodyPlacementMode placementMode;
  final SidebarBodyContentAlignment contentAlignment;
  final String title;
  final String? subtitle;
  final String? sectionTitle;
  final String? footerText;
  final SidebarCardLayoutStyle layoutStyle;
  final bool isNaked;
  final bool shouldExpand;

  @override
  SidebarCassetteRenderKind get renderKind =>
      SidebarCassetteRenderKind.sharedBodyModel;
}

class ResolvedSidebarCassette {
  const ResolvedSidebarCassette({
    required this.spec,
    required this.cassetteIndex,
    required this.payload,
    this.topSpacing = 0,
  });

  final CassetteSpec spec;
  final int cassetteIndex;

  /// Current inert transport object for this cassette.
  final SidebarCassettePayload payload;
  final double topSpacing;
}
