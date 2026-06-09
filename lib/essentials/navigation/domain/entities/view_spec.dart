import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';
import '../../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../../features/settings/domain/spec_classes/settings_view_spec.dart';
import '../../../onboarding/domain/spec_classes/onboarding_view_spec.dart';

part 'view_spec.freezed.dart';

@freezed
abstract class ViewSpec with _$ViewSpec {
  const factory ViewSpec.messages(MessagesSpec spec) = _ViewMessages;
  const factory ViewSpec.settings(SettingsViewSpec spec) = _ViewSettings;
  const factory ViewSpec.environmentReadiness(EnvironmentReadinessSpec spec) =
      _ViewEnvironmentReadiness;
  const factory ViewSpec.onboarding(OnboardingSpec spec) = _ViewOnboarding;
}

/// Whether this ViewSpec represents content that operates independently of
/// the sidebar cassette rack (e.g. maintenance panels).
///
/// When true, the sidebar should be replaced with a contextual overlay
/// rather than showing stale cassette state.
extension ViewSpecSidebarAwareness on ViewSpec {
  bool get isSidebarIndependent => switch (this) {
    _ViewEnvironmentReadiness() => true,
    _ViewOnboarding() => true,
    _ViewSettings() => false,
    _ => false,
  };
}
