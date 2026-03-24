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
  if (previousSection == null) {
    return 0;
  }

  if (previousSection == currentSection) {
    return AppSpacing.sm;
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
