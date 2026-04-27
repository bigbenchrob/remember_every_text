import '../../../config/theme/spacing/app_spacing.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';

const double sidebarMenuSectionHeaderHorizontalInset =
    AppSpacing.sm + AppSpacing.xs;
const double sidebarMenuItemHorizontalInset =
    sidebarMenuSectionHeaderHorizontalInset + AppSpacing.xs;

const double sidebarCassetteMicroSpacing = AppSpacing.sm;
const double sidebarCassetteTightGroupSpacing = AppSpacing.sm - 2;
const double sidebarCassetteSupportingSectionSpacing = AppSpacing.md;
const double sidebarCassetteSupportingToControlsSpacing =
    AppSpacing.md + AppSpacing.xs;
const double sidebarCassetteInternalSectionSpacing =
    AppSpacing.panelHeaderToControlsGap;
const double sidebarCassetteInterSectionSpacing = AppSpacing.lg;
const double sidebarCassetteAppControlsToContextSpacing = AppSpacing.md;
const double sidebarCassetteVisualizationContentSpacing = AppSpacing.sm;

double sidebarMenuSectionHeaderTopSpacing({required bool isFirstInMenu}) {
  if (isFirstInMenu) {
    return AppSpacing.panelHeaderToControlsGap;
  }

  return AppSpacing.lg;
}

double sidebarMenuSectionHeaderBottomSpacing() {
  return AppSpacing.sm - 2;
}

/// Essentials-owned semantic sections derived from cassette role.
enum SidebarCassetteSection { app, context, filter, action }

enum SidebarCassetteSectionSurfaceStyle {
  none,
  primaryContextGroup,
  groupedControls,
}

SidebarCassetteSection sidebarCassetteSectionForRole(SidebarCassetteRole role) {
  return switch (role) {
    SidebarCassetteRole.appControl => SidebarCassetteSection.app,
    SidebarCassetteRole.contextPrimary => SidebarCassetteSection.context,
    SidebarCassetteRole.contextSecondary => SidebarCassetteSection.context,
    SidebarCassetteRole.filter => SidebarCassetteSection.filter,
    SidebarCassetteRole.action => SidebarCassetteSection.action,
  };
}

SidebarCassetteSemanticStyle sidebarCassetteSemanticStyleForPayload(
  SidebarCassettePayload payload,
) {
  if (payload.semanticStyle != SidebarCassetteSemanticStyle.automatic) {
    return payload.semanticStyle;
  }

  return switch (payload.role) {
    SidebarCassetteRole.filter => SidebarCassetteSemanticStyle.groupedControls,
    _ => SidebarCassetteSemanticStyle.plain,
  };
}

SidebarCassetteSectionSurfaceStyle sidebarCassetteSectionSurfaceStyleForPayload(
  SidebarCassettePayload payload,
) {
  return switch (sidebarCassetteSemanticStyleForPayload(payload)) {
    SidebarCassetteSemanticStyle.primaryContextGroup =>
      SidebarCassetteSectionSurfaceStyle.primaryContextGroup,
    SidebarCassetteSemanticStyle.groupedControls =>
      SidebarCassetteSectionSurfaceStyle.groupedControls,
    _ => SidebarCassetteSectionSurfaceStyle.none,
  };
}

bool sidebarCassettePayloadJoinsSectionSurface({
  required SidebarCassettePayload leadPayload,
  required SidebarCassettePayload candidatePayload,
}) {
  final leadSurfaceStyle = sidebarCassetteSectionSurfaceStyleForPayload(
    leadPayload,
  );
  final candidateSurfaceStyle = sidebarCassetteSectionSurfaceStyleForPayload(
    candidatePayload,
  );

  return switch (leadSurfaceStyle) {
    SidebarCassetteSectionSurfaceStyle.none => false,
    SidebarCassetteSectionSurfaceStyle.groupedControls =>
      candidateSurfaceStyle ==
          SidebarCassetteSectionSurfaceStyle.groupedControls,
    SidebarCassetteSectionSurfaceStyle.primaryContextGroup => false,
  };
}

double sidebarCassetteContentGapForSemanticStyle(
  SidebarCassetteSemanticStyle semanticStyle,
) {
  return switch (semanticStyle) {
    SidebarCassetteSemanticStyle.visualization =>
      sidebarCassetteVisualizationContentSpacing,
    _ => AppSpacing.cassetteContentGap,
  };
}

double sidebarCassetteTopSpacing({
  required SidebarCassettePayload? previousPayload,
  required SidebarCassettePayload currentPayload,
}) {
  // This helper owns the shared sidebar stack rhythm.
  //
  // Guardrail:
  // - Micro spacing is used for tightly related cassettes in the same section.
  // - Internal section spacing is used for grouped controls within a section.
  // - Inter-section spacing is used between distinct semantic groups.
  // - Payload topSpacing remains additive for exceptional feature needs, but
  //   the default stack rhythm is owned centrally here.
  //
  if (previousPayload == null) {
    return 0;
  }

  final previousSection = sidebarCassetteSectionForRole(previousPayload.role);
  final currentSection = sidebarCassetteSectionForRole(currentPayload.role);
  final previousStyle = sidebarCassetteSemanticStyleForPayload(previousPayload);
  final currentStyle = sidebarCassetteSemanticStyleForPayload(currentPayload);

  final isGroupedControlsRun =
      previousStyle == SidebarCassetteSemanticStyle.groupedControls &&
      currentStyle == SidebarCassetteSemanticStyle.groupedControls;
  if (isGroupedControlsRun) {
    return sidebarCassetteInternalSectionSpacing;
  }

  final entersPrimaryContextGroupFromAppControl =
      previousSection == SidebarCassetteSection.app &&
      currentStyle == SidebarCassetteSemanticStyle.primaryContextGroup;
  if (entersPrimaryContextGroupFromAppControl) {
    return sidebarCassetteMicroSpacing;
  }

  final isSupportingContextPair =
      currentStyle == SidebarCassetteSemanticStyle.supportingContext &&
      previousSection == SidebarCassetteSection.context &&
      currentSection == SidebarCassetteSection.context;
  if (isSupportingContextPair) {
    if (previousStyle == SidebarCassetteSemanticStyle.primaryContextGroup) {
      return sidebarCassetteSupportingSectionSpacing;
    }

    return sidebarCassetteMicroSpacing;
  }

  final isSupportingContextToGroupedControls =
      previousStyle == SidebarCassetteSemanticStyle.supportingContext &&
      currentStyle == SidebarCassetteSemanticStyle.groupedControls;
  if (isSupportingContextToGroupedControls) {
    return sidebarCassetteSupportingToControlsSpacing;
  }

  final crossesVisualizationBoundary =
      previousStyle == SidebarCassetteSemanticStyle.visualization ||
      currentStyle == SidebarCassetteSemanticStyle.visualization;
  if (crossesVisualizationBoundary && previousStyle != currentStyle) {
    return sidebarCassetteInterSectionSpacing;
  }

  if (previousSection == SidebarCassetteSection.app &&
      currentSection == SidebarCassetteSection.context) {
    return sidebarCassetteAppControlsToContextSpacing;
  }

  if (previousSection != currentSection) {
    return sidebarCassetteInterSectionSpacing;
  }

  return switch (currentSection) {
    SidebarCassetteSection.app => sidebarCassetteInternalSectionSpacing,
    SidebarCassetteSection.context => sidebarCassetteMicroSpacing,
    SidebarCassetteSection.filter => sidebarCassetteInternalSectionSpacing,
    SidebarCassetteSection.action => sidebarCassetteInternalSectionSpacing,
  };
}
