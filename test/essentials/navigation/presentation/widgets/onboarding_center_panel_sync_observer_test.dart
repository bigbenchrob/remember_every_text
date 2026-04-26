import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_tracker_provider.dart';
import 'package:remember_this_text/essentials/logging/domain/pipeline_incident_report.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/sidebar_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/import_spec.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';

void main() {
  group('OnboardingCenterPanelSyncObserver', () {
    testWidgets('shows readiness panel when onboarding blocks progress', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [onboardingGateProvider.overrideWith(_AwaitingFdaGate.new)],
      );
      final panelsSubscription = container.listen(
        panelsViewStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: OnboardingCenterPanelSyncObserver(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
      final panelState = panelsSubscription.read();
      expect(
        panelState[WindowPanel.center]?.activePage?.spec,
        const ViewSpec.environmentReadiness(
          EnvironmentReadinessSpec.readinessPanel(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
    });

    testWidgets('shows readiness panel for awaiting user action state', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          onboardingGateProvider.overrideWith(_AwaitingUserActionGate.new),
        ],
      );
      final panelsSubscription = container.listen(
        panelsViewStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: OnboardingCenterPanelSyncObserver(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(container.read(activeSidebarModeProvider), SidebarMode.messages);
      final panelState = panelsSubscription.read();
      expect(
        panelState[WindowPanel.center]?.activePage?.spec,
        const ViewSpec.environmentReadiness(
          EnvironmentReadinessSpec.readinessPanel(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
    });

    testWidgets('clears readiness panel when onboarding is no longer needed', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [onboardingGateProvider.overrideWith(_ReadyGate.new)],
      );
      final panelsSubscription = container.listen(
        panelsViewStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.environmentReadiness(
              EnvironmentReadinessSpec.readinessPanel(),
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: OnboardingCenterPanelSyncObserver(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final panelState = panelsSubscription.read();

      expect(panelState[WindowPanel.center]?.isEmpty, isTrue);
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
    });

    testWidgets('keeps import panel visible during awaiting user action', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          onboardingGateProvider.overrideWith(_AwaitingUserActionGate.new),
        ],
      );
      final panelsSubscription = container.listen(
        panelsViewStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );

      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.import(ImportSpec.forImport()),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: OnboardingCenterPanelSyncObserver(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(
        panelsSubscription.read()[WindowPanel.center]?.activePage?.spec,
        const ViewSpec.import(ImportSpec.forImport()),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
    });

    testWidgets(
      'shows pipeline incident panel when a blocking incident exists',
      (tester) async {
        final report = PipelineIncidentReport(
          reportId: 'report-1',
          stage: PipelineIncidentStage.import,
          headline: 'Import failed',
          summary: 'The import pipeline stopped.',
          recordedAtUtc: DateTime.utc(2026, 4, 25, 12),
          entries: <PipelineIncidentEntry>[
            PipelineIncidentEntry(
              severity: PipelineIncidentSeverity.blocking,
              stage: PipelineIncidentStage.import,
              summary: 'Import failed: database is locked',
              recordedAtUtc: DateTime.utc(2026, 4, 25, 12),
            ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            onboardingGateProvider.overrideWith(_ReadyGate.new),
            activeBlockingPipelineIncidentProvider.overrideWith(
              (ref) async => report,
            ),
          ],
        );
        final panelsSubscription = container.listen(
          panelsViewStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: OnboardingCenterPanelSyncObserver(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(
          panelsSubscription.read()[WindowPanel.center]?.activePage?.spec,
          const ViewSpec.environmentReadiness(
            EnvironmentReadinessSpec.pipelineIncidentPanel(),
          ),
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        container.dispose();
      },
    );

    testWidgets(
      'clears pipeline incident panel when no blocking incident remains',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            onboardingGateProvider.overrideWith(_ReadyGate.new),
            activeBlockingPipelineIncidentProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );
        final panelsSubscription = container.listen(
          panelsViewStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.environmentReadiness(
                EnvironmentReadinessSpec.pipelineIncidentPanel(),
              ),
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: OnboardingCenterPanelSyncObserver(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(panelsSubscription.read()[WindowPanel.center]?.isEmpty, isTrue);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        container.dispose();
      },
    );
  });
}

class _AwaitingFdaGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.awaitingFda;
  }
}

class _ReadyGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.notNeeded;
  }
}

class _AwaitingUserActionGate extends OnboardingGate {
  @override
  OnboardingStatus build() {
    return OnboardingStatus.awaitingUserAction;
  }
}
