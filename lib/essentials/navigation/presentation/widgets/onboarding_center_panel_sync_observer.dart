import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';
import '../../../logging/application/app_logger.dart';
import '../../../logging/application/pipeline_incident_tracker_provider.dart';
import '../../../onboarding/application/onboarding_gate_provider.dart';
import '../../../onboarding/domain/onboarding_status.dart';
import '../../application/panel_widget_providers.dart';
import '../../application/panels_view_state_provider.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../domain/sidebar_mode.dart';

class OnboardingCenterPanelSyncObserver extends ConsumerWidget {
  const OnboardingCenterPanelSyncObserver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingStatus = ref.watch(onboardingGateProvider);
    final incidentReport = ref
        .watch(activeBlockingPipelineIncidentProvider)
        .valueOrNull;
    final centerSpec = ref.watch(
      effectiveCenterPanelSpecProvider(SidebarMode.messages),
    );

    final shouldShowReadiness =
        onboardingStatus == OnboardingStatus.awaitingFda ||
        onboardingStatus == OnboardingStatus.awaitingUserAction;
    final isShowingReadiness =
        centerSpec?.maybeWhen(
          environmentReadiness: (spec) =>
              spec.maybeWhen(readinessPanel: () => true, orElse: () => false),
          orElse: () => false,
        ) ??
        false;
    final isShowingIncident =
        centerSpec?.maybeWhen(
          environmentReadiness: (spec) => spec.maybeWhen(
            pipelineIncidentPanel: () => true,
            orElse: () => false,
          ),
          orElse: () => false,
        ) ??
        false;
    final shouldShowIncident =
        incidentReport != null &&
        onboardingStatus != OnboardingStatus.awaitingFda &&
        !_usesBlockingOverlay(onboardingStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panelsNotifier = ref.read(
        panelsViewStateProvider(SidebarMode.messages).notifier,
      );
      final logger = ref.read(appLoggerProvider.notifier);

      if (shouldShowIncident && !isShowingIncident) {
        logger.info(
          'Showing pipeline incident center panel from onboarding observer',
          source: 'OnboardingCenterPanelSyncObserver',
          context: {
            'onboardingStatus': onboardingStatus.name,
            'currentCenterSpec': _describeCenterSpec(centerSpec),
            'reportId': incidentReport.reportId,
          },
        );
        ref
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);
        panelsNotifier.show(
          panel: WindowPanel.center,
          spec: const ViewSpec.environmentReadiness(
            EnvironmentReadinessSpec.pipelineIncidentPanel(),
          ),
        );
        return;
      }

      if (shouldShowReadiness && !shouldShowIncident && !isShowingReadiness) {
        logger.info(
          'Showing readiness center panel from onboarding observer',
          source: 'OnboardingCenterPanelSyncObserver',
          context: {
            'onboardingStatus': onboardingStatus.name,
            'currentCenterSpec': _describeCenterSpec(centerSpec),
          },
        );
        ref
            .read(activeSidebarModeProvider.notifier)
            .setMode(SidebarMode.messages);
        panelsNotifier.show(
          panel: WindowPanel.center,
          spec: const ViewSpec.environmentReadiness(
            EnvironmentReadinessSpec.readinessPanel(),
          ),
        );
        return;
      }

      if (!shouldShowIncident && isShowingIncident) {
        logger.info(
          'Clearing pipeline incident center panel from onboarding observer',
          source: 'OnboardingCenterPanelSyncObserver',
          context: {
            'onboardingStatus': onboardingStatus.name,
            'currentCenterSpec': _describeCenterSpec(centerSpec),
          },
        );
        if (shouldShowReadiness) {
          panelsNotifier.show(
            panel: WindowPanel.center,
            spec: const ViewSpec.environmentReadiness(
              EnvironmentReadinessSpec.readinessPanel(),
            ),
          );
          return;
        }
        panelsNotifier.clear(panel: WindowPanel.center);
        return;
      }

      if (!shouldShowReadiness && !shouldShowIncident && isShowingReadiness) {
        logger.info(
          'Clearing readiness center panel from onboarding observer',
          source: 'OnboardingCenterPanelSyncObserver',
          context: {
            'onboardingStatus': onboardingStatus.name,
            'currentCenterSpec': _describeCenterSpec(centerSpec),
          },
        );
        panelsNotifier.clear(panel: WindowPanel.center);
      }
    });

    return const SizedBox.shrink();
  }

  String _describeCenterSpec(ViewSpec? spec) {
    if (spec == null) {
      return 'none';
    }

    return spec.map(
      messages: (_) => 'messages',
      settings: (_) => 'settings',
      environmentReadiness: (value) => value.spec.maybeWhen(
        readinessPanel: () => 'environmentReadiness.readinessPanel',
        pipelineIncidentPanel: () =>
            'environmentReadiness.pipelineIncidentPanel',
        orElse: () => 'environmentReadiness.unknown',
      ),
      onboarding: (_) => 'onboarding',
    );
  }

  bool _usesBlockingOverlay(OnboardingStatus status) {
    return switch (status) {
      OnboardingStatus.recoveringFailedAttempt ||
      OnboardingStatus.importing ||
      OnboardingStatus.buildingGraph ||
      OnboardingStatus.complete ||
      OnboardingStatus.reimporting ||
      OnboardingStatus.reimportBuildingGraph ||
      OnboardingStatus.reimportComplete => true,
      _ => false,
    };
  }
}
