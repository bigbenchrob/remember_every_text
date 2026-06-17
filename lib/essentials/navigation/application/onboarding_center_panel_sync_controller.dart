import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';
import '../../logging/domain/pipeline_incident_report.dart';
import '../../logging/feature_level_providers.dart';
import '../../onboarding/domain/onboarding_status.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import 'panels_view_state_provider.dart';
import 'sidebar_mode_provider.dart';

part 'onboarding_center_panel_sync_controller.g.dart';

@riverpod
class OnboardingCenterPanelSyncController
    extends _$OnboardingCenterPanelSyncController {
  @override
  FutureOr<void> build() {}

  void synchronize({
    required OnboardingStatus onboardingStatus,
    required PipelineIncidentReport? incidentReport,
    required ViewSpec? centerSpec,
  }) {
    final shouldShowReadiness =
        onboardingStatus == OnboardingStatus.awaitingFda ||
        onboardingStatus == OnboardingStatus.awaitingUserAction;
    final isShowingReadiness = _isShowingReadiness(centerSpec);
    final isShowingIncident = _isShowingIncident(centerSpec);
    final shouldShowIncident =
        incidentReport != null &&
        onboardingStatus != OnboardingStatus.awaitingFda &&
        !_usesBlockingOverlay(onboardingStatus);

    final panelsNotifier = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );
    final logger = ref.read(appLoggerProvider.notifier);

    if (shouldShowIncident && !isShowingIncident) {
      logger.info(
        'Showing pipeline incident center panel from onboarding sync controller',
        source: 'OnboardingCenterPanelSyncController',
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
        'Showing readiness center panel from onboarding sync controller',
        source: 'OnboardingCenterPanelSyncController',
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
        'Clearing pipeline incident center panel from onboarding sync controller',
        source: 'OnboardingCenterPanelSyncController',
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
        'Clearing readiness center panel from onboarding sync controller',
        source: 'OnboardingCenterPanelSyncController',
        context: {
          'onboardingStatus': onboardingStatus.name,
          'currentCenterSpec': _describeCenterSpec(centerSpec),
        },
      );
      panelsNotifier.clear(panel: WindowPanel.center);
    }
  }
}

bool _isShowingReadiness(ViewSpec? spec) {
  return spec?.maybeWhen(
        environmentReadiness: (spec) =>
            spec.maybeWhen(readinessPanel: () => true, orElse: () => false),
        orElse: () => false,
      ) ??
      false;
}

bool _isShowingIncident(ViewSpec? spec) {
  return spec?.maybeWhen(
        environmentReadiness: (spec) => spec.maybeWhen(
          pipelineIncidentPanel: () => true,
          orElse: () => false,
        ),
        orElse: () => false,
      ) ??
      false;
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
      pipelineIncidentPanel: () => 'environmentReadiness.pipelineIncidentPanel',
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
