import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../onboarding/domain/onboarding_status.dart';

/// Whether first-run Onboarding temporarily owns the normal sidebar.
///
/// Reimport is a completed-installation maintenance workflow, so it does not
/// take ownership of normal application navigation.
bool onboardingOwnsNormalSidebar(OnboardingStatus status) {
  return switch (status) {
    OnboardingStatus.recoveringFailedAttempt ||
    OnboardingStatus.preparationFailed ||
    OnboardingStatus.awaitingFda ||
    OnboardingStatus.awaitingUserAction ||
    OnboardingStatus.importing ||
    OnboardingStatus.buildingGraph ||
    OnboardingStatus.complete => true,
    OnboardingStatus.notNeeded ||
    OnboardingStatus.reimporting ||
    OnboardingStatus.reimportBuildingGraph ||
    OnboardingStatus.reimportComplete => false,
  };
}

/// Reconciles only transitions between Onboarding and normal-app ownership.
///
/// The [Sidebar.shownByDefault] value establishes initial visibility. This
/// widget handles later ownership transitions without persisting or repeatedly
/// overriding a user's normal sidebar choice.
class OnboardingSidebarVisibilityOwner extends StatefulWidget {
  const OnboardingSidebarVisibilityOwner({
    required this.status,
    this.onNormalApplicationRevealed,
    super.key,
  });

  final OnboardingStatus status;
  final VoidCallback? onNormalApplicationRevealed;

  @override
  State<OnboardingSidebarVisibilityOwner> createState() =>
      _OnboardingSidebarVisibilityOwnerState();
}

class _OnboardingSidebarVisibilityOwnerState
    extends State<OnboardingSidebarVisibilityOwner> {
  @override
  void didUpdateWidget(OnboardingSidebarVisibilityOwner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previouslyOwned = onboardingOwnsNormalSidebar(oldWidget.status);
    final currentlyOwned = onboardingOwnsNormalSidebar(widget.status);
    if (previouslyOwned == currentlyOwned) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          onboardingOwnsNormalSidebar(widget.status) != currentlyOwned) {
        return;
      }
      final scope = MacosWindowScope.of(context);
      final shouldShow = !currentlyOwned;
      if (scope.isSidebarShown != shouldShow) {
        scope.toggleSidebar();
      }
      if (shouldShow) {
        widget.onNormalApplicationRevealed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
