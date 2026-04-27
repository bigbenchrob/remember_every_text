import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
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

  group('sidebarCassetteSemanticStyleForPayload', () {
    test('derives grouped-controls semantics from filter role by default', () {
      expect(
        sidebarCassetteSemanticStyleForPayload(
          const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'filter',
            role: SidebarCassetteRole.filter,
          ),
        ),
        SidebarCassetteSemanticStyle.groupedControls,
      );
    });

    test('keeps explicit semantic styles when provided', () {
      expect(
        sidebarCassetteSemanticStyleForPayload(
          const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
            semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
          ),
        ),
        SidebarCassetteSemanticStyle.primaryContextGroup,
      );
      expect(
        sidebarCassetteSemanticStyleForPayload(
          const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'info',
            semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
          ),
        ),
        SidebarCassetteSemanticStyle.supportingContext,
      );
      expect(
        sidebarCassetteSemanticStyleForPayload(
          const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'viz'),
            semanticStyle: SidebarCassetteSemanticStyle.visualization,
          ),
        ),
        SidebarCassetteSemanticStyle.visualization,
      );
    });
  });

  group('sidebarCassetteSectionSurfaceStyleForPayload', () {
    test(
      'maps shared semantic styles to the correct shared section surface',
      () {
        expect(
          sidebarCassetteSectionSurfaceStyleForPayload(
            const SharedBodyModelSidebarCassettePayload(
              bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
              semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
            ),
          ),
          SidebarCassetteSectionSurfaceStyle.primaryContextGroup,
        );
        expect(
          sidebarCassetteSectionSurfaceStyleForPayload(
            const StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'filter',
              role: SidebarCassetteRole.filter,
            ),
          ),
          SidebarCassetteSectionSurfaceStyle.groupedControls,
        );
        expect(
          sidebarCassetteSectionSurfaceStyleForPayload(
            const StaticFeatureInfoSidebarCassettePayload(bodyText: 'info'),
          ),
          SidebarCassetteSectionSurfaceStyle.none,
        );
      },
    );

    test('does not join supporting context into a primary context group', () {
      expect(
        sidebarCassettePayloadJoinsSectionSurface(
          leadPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
            semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
          ),
          candidatePayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'info',
            semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
          ),
        ),
        isFalse,
      );
      expect(
        sidebarCassettePayloadJoinsSectionSurface(
          leadPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
            semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
          ),
          candidatePayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'scope',
            role: SidebarCassetteRole.filter,
          ),
        ),
        isFalse,
      );
    });
  });

  group('sidebarCassetteContentGapForSemanticStyle', () {
    test('uses tighter internal rhythm for visualization groups', () {
      expect(
        sidebarCassetteContentGapForSemanticStyle(
          SidebarCassetteSemanticStyle.visualization,
        ),
        sidebarCassetteVisualizationContentSpacing,
      );
      expect(
        sidebarCassetteContentGapForSemanticStyle(
          SidebarCassetteSemanticStyle.plain,
        ),
        AppSpacing.cassetteContentGap,
      );
    });
  });

  group('sidebarCassetteTopSpacing', () {
    test('returns no extra spacing for the first cassette only', () {
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: null,
          currentPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'context',
          ),
        ),
        0,
      );
    });

    test(
      'uses moderate spacing for supporting context after a primary group',
      () {
        expect(
          sidebarCassetteTopSpacing(
            previousPayload: const SharedBodyModelSidebarCassettePayload(
              bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
              semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
            ),
            currentPayload: const StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'info',
              semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
            ),
          ),
          sidebarCassetteSupportingSectionSpacing,
        );
      },
    );

    test(
      'uses a tighter gap from app controls into a primary context group',
      () {
        expect(
          sidebarCassetteTopSpacing(
            previousPayload: const StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'change',
              role: SidebarCassetteRole.appControl,
            ),
            currentPayload: const SharedBodyModelSidebarCassettePayload(
              bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
              semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
            ),
          ),
          sidebarCassetteMicroSpacing,
        );
      },
    );

    test('uses internal section spacing for grouped controls', () {
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'scope',
            role: SidebarCassetteRole.filter,
          ),
          currentPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'filter',
            role: SidebarCassetteRole.filter,
          ),
        ),
        sidebarCassetteInternalSectionSpacing,
      );
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'selector',
            role: SidebarCassetteRole.appControl,
          ),
          currentPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'change',
            role: SidebarCassetteRole.appControl,
          ),
        ),
        sidebarCassetteInternalSectionSpacing,
      );
    });

    test('uses a moderate gap from app controls into context', () {
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'change',
            role: SidebarCassetteRole.appControl,
          ),
          currentPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
          ),
        ),
        sidebarCassetteAppControlsToContextSpacing,
      );
    });

    test('uses inter-section spacing for distinct conceptual groups', () {
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'info',
            semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
          ),
          currentPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'scope',
            role: SidebarCassetteRole.filter,
          ),
        ),
        sidebarCassetteSupportingToControlsSpacing,
      );
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const StaticFeatureInfoSidebarCassettePayload(
            bodyText: 'scope',
            role: SidebarCassetteRole.filter,
          ),
          currentPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'heatmap'),
            semanticStyle: SidebarCassetteSemanticStyle.visualization,
          ),
        ),
        sidebarCassetteInterSectionSpacing,
      );
      expect(
        sidebarCassetteTopSpacing(
          previousPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'hero'),
          ),
          currentPayload: const SharedBodyModelSidebarCassettePayload(
            bodyModel: SidebarInfoBodyModel(bodyText: 'heatmap'),
            semanticStyle: SidebarCassetteSemanticStyle.visualization,
          ),
        ),
        sidebarCassetteInterSectionSpacing,
      );
    });
  });

  group('sidebar menu section header rhythm', () {
    test(
      'adds a modest inset above the first header and separates later headers',
      () {
        expect(
          sidebarMenuSectionHeaderTopSpacing(isFirstInMenu: true),
          AppSpacing.panelHeaderToControlsGap,
        );
        expect(
          sidebarMenuSectionHeaderTopSpacing(isFirstInMenu: false),
          AppSpacing.lg,
        );
      },
    );

    test('uses the canonical horizontal inset and bottom gap', () {
      expect(
        sidebarMenuSectionHeaderHorizontalInset,
        AppSpacing.sm + AppSpacing.xs,
      );
      expect(
        sidebarMenuItemHorizontalInset,
        sidebarMenuSectionHeaderHorizontalInset + AppSpacing.xs,
      );
      expect(sidebarMenuSectionHeaderBottomSpacing(), AppSpacing.sm - 2);
    });
  });
}
