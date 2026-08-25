import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/application/app_navigator_key.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart';

void main() {
  testWidgets(
    'accepted authorization still invokes service after dialog frames elapse',
    (tester) async {
      final service = _RecordingStartFreshService();
      late ProviderContainer container;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            messageLensInstallationStateProvider.overrideWith((ref) async {
              return _completedState;
            }),
            startFreshServiceProvider.overrideWith((ref) async => service),
            onboardingGateProvider.overrideWith(_TestOnboardingGate.new),
          ],
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                navigatorKey: appNavigatorKey,
                home: const Scaffold(
                  body: Stack(
                    children: [
                      Center(child: Text('Settings remains below')),
                      AdvancedStartFreshOverlayHost(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      final request = container
          .read(advancedStartFreshActionProvider)
          .request();
      await tester.pumpAndSettle();
      expect(
        find.text('Start with a clean MessageLens setup?'),
        findsOneWidget,
      );

      // The former auto-disposed provider lost its Ref during these frames.
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(find.widgetWithText(FilledButton, 'Start Fresh'));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);
      expect(find.text('Preparing a fresh start'), findsOneWidget);
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      ]);

      service.completion.complete(
        const StartFreshResult(
          verifiedState: MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.virgin,
            reason: 'verified virgin test installation',
          ),
        ),
      );
      await tester.pump();

      expect(await request, AdvancedStartFreshActionResult.startedFresh);
    },
  );
}

const _completedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.completed,
  reason: 'healthy completed test installation',
);

final class _RecordingStartFreshService implements StartFreshService {
  final entryPoints = <StartFreshEntryPoint>[];
  final completion = Completer<StartFreshResult>();

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    entryPoints.add(entryPoint);
    return completion.future;
  }
}

final class _TestOnboardingGate extends OnboardingGate {
  @override
  OnboardingStatus build() => OnboardingStatus.notNeeded;
}
