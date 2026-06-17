import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../logging/application/pipeline_incident_tracker_provider.dart';
import '../../../onboarding/application/onboarding_gate_provider.dart';
import '../../application/onboarding_center_panel_sync_controller.dart';
import '../../application/panel_widget_providers.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingCenterPanelSyncControllerProvider.notifier)
          .synchronize(
            onboardingStatus: onboardingStatus,
            incidentReport: incidentReport,
            centerSpec: centerSpec,
          );
    });

    return const SizedBox.shrink();
  }
}
