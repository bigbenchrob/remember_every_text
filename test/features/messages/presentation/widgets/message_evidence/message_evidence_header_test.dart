import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/debug/feature_level_providers.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart';

void main() {
  testWidgets('renders typed message evidence header data and slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.developer),
          ),
        ],
        child: const CupertinoApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'Conversation with Claire and Cathie',
              dateRangeLabel: 'Jan 2014 to May 2026',
              countLabel: '86,563 messages',
              statusLine: 'Selected conversation',
              actions: Text('Copy evidence summary'),
            ),
            details: Text('Showing 100 loaded messages'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Conversation with Claire and Cathie'), findsOneWidget);
    expect(find.text('Jan 2014 to May 2026'), findsOneWidget);
    expect(find.text('86,563 messages'), findsOneWidget);
    expect(find.text('Selected conversation'), findsOneWidget);
    expect(find.text('Copy evidence summary'), findsOneWidget);
    expect(find.text('Showing 100 loaded messages'), findsOneWidget);
  });

  testWidgets('hides diagnostic status line outside developer mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.user),
          ),
        ],
        child: const CupertinoApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'Conversation with Claire and Cathie',
              statusLine:
                  'evidence skeleton • handle scope • hydrate visible rows',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Conversation with Claire and Cathie'), findsOneWidget);
    expect(find.textContaining('evidence skeleton'), findsNothing);
  });

  testWidgets('renders standard search and action regions', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    MessageEvidenceSearchMode? selectedMode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          developerModeProvider.overrideWith(
            () => _FakeDeveloperMode(DeveloperModeValue.user),
          ),
        ],
        child: MacosApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'All messages from Claire',
              searchConfig: MessageEvidenceHeaderSearchConfig(
                controller: controller,
                placeholder: 'Search messages from Claire',
                mode: MessageEvidenceSearchMode.allTerms,
                onModeChanged: (mode) {
                  selectedMode = mode;
                },
              ),
              actions: const Text('Copy evidence summary'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    expect(find.text('Search messages from Claire'), findsOneWidget);
    expect(find.text('AND'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(find.text('Copy evidence summary'), findsOneWidget);

    await tester.tap(find.text('OR'));
    expect(selectedMode, MessageEvidenceSearchMode.anyTerm);
  });
}

class _FakeDeveloperMode extends DeveloperMode {
  _FakeDeveloperMode(this._value);

  final DeveloperModeValue _value;

  @override
  Future<DeveloperModeValue> build() async => _value;
}
