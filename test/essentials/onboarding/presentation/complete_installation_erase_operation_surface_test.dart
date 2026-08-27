import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/application/app_navigator_key.dart';
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_action_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_service.dart';
import 'package:remember_this_text/essentials/onboarding/application/complete_installation_erase_service_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_lens_installation_state_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/complete_installation_erase_overlay.dart';

void main() {
  testWidgets(
    'confirmation closes into visible operation ownership before erase completes',
    (tester) async {
      final service = _BlockedEraseService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            messageLensInstallationStateProvider.overrideWith(
              (ref) async => const MessageLensInstallationState(
                kind: MessageLensInstallationStateKind.completed,
                reason: 'test completed installation',
              ),
            ),
            completeInstallationEraseServiceProvider.overrideWith(
              (ref) => service,
            ),
          ],
          child: MaterialApp(
            navigatorKey: appNavigatorKey,
            home: const _OperationHarness(),
          ),
        ),
      );

      await tester.tap(find.text('Request complete erase'));
      await tester.pumpAndSettle();
      expect(
        find.text('Erase this MessageLens setup and start over?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Erase and Start Over'));
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(CompleteInstallationEraseOverlayHost.surfaceKey),
        findsOneWidget,
      );
      expect(service.started, isTrue);

      service.completion.complete();
      await tester.pump();
    },
  );

  testWidgets('execution failure remains a typed visible outcome', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageLensInstallationStateProvider.overrideWith(
            (ref) async => const MessageLensInstallationState(
              kind: MessageLensInstallationStateKind.completed,
              reason: 'test completed installation',
            ),
          ),
          completeInstallationEraseServiceProvider.overrideWith(
            (ref) => const _FailingEraseService(),
          ),
        ],
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          home: const _OperationHarness(),
        ),
      ),
    );

    await tester.tap(find.text('Request complete erase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Erase and Start Over'));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text("MessageLens couldn't erase this setup"), findsOneWidget);
    expect(find.text('Return'), findsOneWidget);
  });
}

class _OperationHarness extends ConsumerWidget {
  const _OperationHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        TextButton(
          onPressed: () async {
            await ref
                .read(completeInstallationEraseActionProvider.notifier)
                .request();
          },
          child: const Text('Request complete erase'),
        ),
        const CompleteInstallationEraseOverlayHost(),
      ],
    );
  }
}

final class _BlockedEraseService implements CompleteInstallationEraseService {
  final completion = Completer<void>();
  bool started = false;

  @override
  Future<void> eraseAndRelaunch() {
    started = true;
    return completion.future;
  }
}

final class _FailingEraseService implements CompleteInstallationEraseService {
  const _FailingEraseService();

  @override
  Future<void> eraseAndRelaunch() {
    throw StateError('test failure');
  }
}
