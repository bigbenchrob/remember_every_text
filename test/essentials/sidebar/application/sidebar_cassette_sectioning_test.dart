import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

void main() {
  group('sidebarCassetteSectionForRole', () {
    test('maps app control role to app section', () {
      expect(
        sidebarCassetteSectionForRole(SidebarCassetteRole.appControl),
        SidebarCassetteSection.app,
      );
    });

    test('groups both context roles into context section', () {
      expect(
        sidebarCassetteSectionForRole(SidebarCassetteRole.contextPrimary),
        SidebarCassetteSection.context,
      );
      expect(
        sidebarCassetteSectionForRole(SidebarCassetteRole.contextSecondary),
        SidebarCassetteSection.context,
      );
    });

    test('maps filter and action roles to their own sections', () {
      expect(
        sidebarCassetteSectionForRole(SidebarCassetteRole.filter),
        SidebarCassetteSection.filter,
      );
      expect(
        sidebarCassetteSectionForRole(SidebarCassetteRole.action),
        SidebarCassetteSection.action,
      );
    });
  });

  group('sidebarCassetteSectionTopSpacing', () {
    test('returns no extra spacing for first cassette in a section run', () {
      expect(
        sidebarCassetteSectionTopSpacing(
          previousSection: null,
          currentSection: SidebarCassetteSection.context,
        ),
        0,
      );
      expect(
        sidebarCassetteSectionTopSpacing(
          previousSection: SidebarCassetteSection.context,
          currentSection: SidebarCassetteSection.context,
        ),
        0,
      );
    });

    test('gives stronger separation from app controls into context', () {
      expect(
        sidebarCassetteSectionTopSpacing(
          previousSection: SidebarCassetteSection.app,
          currentSection: SidebarCassetteSection.context,
        ),
        AppSpacing.xl,
      );
    });

    test('uses standard section spacing for other section changes', () {
      expect(
        sidebarCassetteSectionTopSpacing(
          previousSection: SidebarCassetteSection.context,
          currentSection: SidebarCassetteSection.filter,
        ),
        AppSpacing.lg,
      );
      expect(
        sidebarCassetteSectionTopSpacing(
          previousSection: SidebarCassetteSection.filter,
          currentSection: SidebarCassetteSection.action,
        ),
        AppSpacing.lg,
      );
    });
  });
}
