import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/essentials/navigation/presentation/widgets/onboarding_sidebar_visibility_owner.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';

void main() {
  test('first-run statuses own sidebar visibility and reimport does not', () {
    for (final status in <OnboardingStatus>[
      OnboardingStatus.recoveringFailedAttempt,
      OnboardingStatus.preparationFailed,
      OnboardingStatus.awaitingFda,
      OnboardingStatus.awaitingUserAction,
      OnboardingStatus.importing,
      OnboardingStatus.buildingGraph,
      OnboardingStatus.complete,
    ]) {
      expect(
        onboardingOwnsNormalSidebar(status),
        isTrue,
        reason: '$status should keep normal navigation closed',
      );
    }

    for (final status in <OnboardingStatus>[
      OnboardingStatus.notNeeded,
      OnboardingStatus.reimporting,
      OnboardingStatus.reimportBuildingGraph,
      OnboardingStatus.reimportComplete,
    ]) {
      expect(
        onboardingOwnsNormalSidebar(status),
        isFalse,
        reason: '$status belongs to the normal application',
      );
    }
  });

  testWidgets('terminal OK ownership release opens the canonical sidebar', (
    tester,
  ) async {
    final status = ValueNotifier<OnboardingStatus>(OnboardingStatus.complete);
    addTearDown(status.dispose);

    await tester.pumpWidget(_SidebarHarness(status: status));

    expect(find.text('sidebar hidden'), findsOneWidget);

    status.value = OnboardingStatus.notNeeded;
    await tester.pump();
    await tester.pump();

    expect(find.text('sidebar shown'), findsOneWidget);
    expect(find.text('reveal count 1'), findsOneWidget);

    await tester.tap(find.text('User closes sidebar'));
    await tester.pump();
    expect(find.text('sidebar hidden'), findsOneWidget);

    await tester.pump();
    expect(
      find.text('sidebar hidden'),
      findsOneWidget,
      reason: 'normal-app ownership must not override a user sidebar choice',
    );
  });
}

class _SidebarHarness extends StatefulWidget {
  const _SidebarHarness({required this.status});

  final ValueNotifier<OnboardingStatus> status;

  @override
  State<_SidebarHarness> createState() => _SidebarHarnessState();
}

class _SidebarHarnessState extends State<_SidebarHarness> {
  late bool _shown = !onboardingOwnsNormalSidebar(widget.status.value);
  var _revealCount = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ValueListenableBuilder<OnboardingStatus>(
        valueListenable: widget.status,
        builder: (context, currentStatus, child) {
          return MacosWindowScope(
            constraints: const BoxConstraints.tightFor(width: 900, height: 720),
            isSidebarShown: _shown,
            isEndSidebarShown: false,
            sidebarToggler: () {
              setState(() {
                _shown = !_shown;
              });
            },
            endSidebarToggler: () {},
            child: Builder(
              builder: (context) {
                final scope = MacosWindowScope.of(context);
                return Column(
                  children: <Widget>[
                    Text(
                      scope.isSidebarShown ? 'sidebar shown' : 'sidebar hidden',
                    ),
                    Text('reveal count $_revealCount'),
                    TextButton(
                      onPressed: scope.toggleSidebar,
                      child: const Text('User closes sidebar'),
                    ),
                    OnboardingSidebarVisibilityOwner(
                      status: currentStatus,
                      onNormalApplicationRevealed: () {
                        setState(() {
                          _revealCount++;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
