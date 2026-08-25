import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/feature_level_providers.dart'
    show messageLensInstallationStateProvider;
import 'package:remember_this_text/essentials/services/startup_flags_service.dart';
import 'package:remember_this_text/main.dart' show StartupApp;

void main() {
  testWidgets('abandoned installation naturally offers Start Fresh', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.abandoned,
              reason: 'test abandoned state',
            );
          }),
        ],
        child: const StartupApp(startupFlags: StartupFlags.disabled()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("This MessageLens setup wasn't completed"), findsOne);
    expect(find.text('Start Fresh'), findsOne);
    expect(find.text('Delete MessageLens App Data'), findsNothing);
  });

  testWidgets('completed installation option surface does not offer reset', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageLensInstallationStateProvider.overrideWith((ref) async {
            return const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.completed,
              reason: 'healthy',
            );
          }),
        ],
        child: const StartupApp(
          startupFlags: StartupFlags(optionLaunchResetRequested: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MessageLens setup is complete'), findsOne);
    expect(find.text('Continue'), findsOne);
    expect(find.text('Start Fresh'), findsNothing);
  });
}
