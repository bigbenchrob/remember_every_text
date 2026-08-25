import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_gate_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/advanced_start_fresh_overlay.dart';

void main() {
  testWidgets('preparing surface blocks the previous Settings presentation', (
    tester,
  ) async {
    var oldSettingsActionCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(
                  child: FilledButton(
                    onPressed: () {
                      oldSettingsActionCount += 1;
                    },
                    child: const Text('Old Settings action'),
                  ),
                ),
                const Positioned.fill(
                  child: AdvancedStartFreshOverlay(
                    presentation: AdvancedStartFreshPresentation(
                      occurrence: 1,
                      phase: AdvancedStartFreshPresentationPhase.preparing,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);
    expect(find.text('Preparing a fresh start'), findsOneWidget);
    await tester.tap(find.text('Old Settings action'), warnIfMissed: false);
    expect(oldSettingsActionCount, 0);
  });

  testWidgets('typed retryable failure exposes recovery actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AdvancedStartFreshOverlay(
              presentation: AdvancedStartFreshPresentation(
                occurrence: 3,
                phase: AdvancedStartFreshPresentationPhase.failed,
                failure: AdvancedStartFreshFailure(
                  kind: AdvancedStartFreshFailureKind.mutationUnavailable,
                  summary: 'Another data operation is active.',
                  canRetry: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text("MessageLens couldn't start fresh"), findsOneWidget);
    expect(find.text('Another data operation is active.'), findsOneWidget);
    expect(
      find.byKey(AdvancedStartFreshOverlay.retryButtonKey),
      findsOneWidget,
    );
    expect(
      find.byKey(AdvancedStartFreshOverlay.dismissButtonKey),
      findsOneWidget,
    );
  });

  testWidgets('verified virgin state yields to Onboarding presentation', (
    tester,
  ) async {
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingGateProvider.overrideWith(_TestOnboardingGate.new),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(
                body: Stack(children: [AdvancedStartFreshOverlayHost()]),
              ),
            );
          },
        ),
      ),
    );

    final presentation = container.read(
      advancedStartFreshPresentationControllerProvider.notifier,
    );
    final occurrence = presentation.beginPreparing();
    presentation.showVerifiedVirgin(expectedOccurrence: occurrence);
    await tester.pump();
    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsOneWidget);

    (container.read(onboardingGateProvider.notifier) as _TestOnboardingGate)
        .setTestStatus(OnboardingStatus.awaitingUserAction);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(AdvancedStartFreshOverlay.surfaceKey), findsNothing);
    expect(
      container.read(advancedStartFreshPresentationControllerProvider).phase,
      AdvancedStartFreshPresentationPhase.idle,
    );
  });
}

final class _TestOnboardingGate extends OnboardingGate {
  @override
  OnboardingStatus build() => OnboardingStatus.notNeeded;

  void setTestStatus(OnboardingStatus status) {
    state = status;
  }
}
