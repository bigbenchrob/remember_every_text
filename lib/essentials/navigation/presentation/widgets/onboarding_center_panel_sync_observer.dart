import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';
import '../../../onboarding/application/onboarding_gate_provider.dart';
import '../../../onboarding/domain/onboarding_status.dart';
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
    final centerSpec = ref.watch(
      panelsViewStateProvider(
        SidebarMode.messages,
      ).select((stacks) => stacks[WindowPanel.center]?.activePage?.spec),
    );

    final shouldShowReadiness =
        onboardingStatus == OnboardingStatus.awaitingFda ||
        onboardingStatus == OnboardingStatus.awaitingUserAction;
    final isShowingReadiness =
        centerSpec?.maybeWhen(
          environmentReadiness: (_) => true,
          orElse: () => false,
        ) ??
        false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panelsNotifier = ref.read(
        panelsViewStateProvider(SidebarMode.messages).notifier,
      );

      if (shouldShowReadiness && !isShowingReadiness) {
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

      if (!shouldShowReadiness && isShowingReadiness) {
        panelsNotifier.clear(panel: WindowPanel.center);
      }
    });

    return const SizedBox.shrink();
  }
}
