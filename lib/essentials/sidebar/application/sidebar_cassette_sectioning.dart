import '../../../config/theme/spacing/app_spacing.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';

/// Essentials-owned semantic sections derived from cassette role.
enum SidebarCassetteSection { app, context, filter, action }

SidebarCassetteSection sidebarCassetteSectionForRole(SidebarCassetteRole role) {
  return switch (role) {
    SidebarCassetteRole.appControl => SidebarCassetteSection.app,
    SidebarCassetteRole.contextPrimary => SidebarCassetteSection.context,
    SidebarCassetteRole.contextSecondary => SidebarCassetteSection.context,
    SidebarCassetteRole.filter => SidebarCassetteSection.filter,
    SidebarCassetteRole.action => SidebarCassetteSection.action,
  };
}

double sidebarCassetteSectionTopSpacing({
  required SidebarCassetteSection? previousSection,
  required SidebarCassetteSection currentSection,
}) {
  // This helper intentionally owns only section-boundary spacing.
  //
  // Guardrail:
  // - Section changes are a sidebar-system concern owned centrally here.
  // - Intra-section rhythm is intentionally NOT owned here.
  // - Ordinary spacing within a section must come from the cassette payload's
  //   own topSpacing or from card/chrome internals.
  //
  // We must never reintroduce same-section spacing here. Doing so creates a
  // second vertical-rhythm author on top of payload.topSpacing, which causes
  // silent layout drift and breaks the role-driven section contract.
  if (previousSection == null) {
    return 0;
  }

  if (previousSection == currentSection) {
    return 0;
  }

  return switch ((previousSection, currentSection)) {
    (SidebarCassetteSection.app, SidebarCassetteSection.context) =>
      AppSpacing.xl,
    (_, SidebarCassetteSection.filter) => AppSpacing.lg,
    (SidebarCassetteSection.filter, SidebarCassetteSection.context) =>
      AppSpacing.xl,
    _ => AppSpacing.lg,
  };
}
