import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_row.dart';

void main() {
  testWidgets('hides raw handle metadata for normal conversation evidence', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(),
    );

    expect(find.textContaining('received | Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsNothing);
  });

  testWidgets('shows raw handle metadata for explicit handle evidence', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.user,
      scope: const HandleMessagesEvidenceScope(handleId: 7),
      message: _message(),
    );

    expect(find.textContaining('received | Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsOneWidget);
  });

  testWidgets('shows raw handle metadata for developer diagnostics', (
    tester,
  ) async {
    await _pumpRow(
      tester,
      developerMode: DeveloperModeValue.developer,
      scope: const ConversationEvidenceScope(conversationId: 42),
      message: _message(),
    );

    expect(find.textContaining('received | Claire'), findsOneWidget);
    expect(find.textContaining('handle: 1 (778) 990-8506'), findsOneWidget);
  });
}

Future<void> _pumpRow(
  WidgetTester tester, {
  required DeveloperModeValue developerMode,
  required MessageEvidenceScope scope,
  required MessageEvidenceRowData message,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        developerModeProvider.overrideWith(
          () => _FakeDeveloperMode(developerMode),
        ),
      ],
      child: MacosApp(
        home: MessageEvidenceRow(message: message, evidenceScope: scope),
      ),
    ),
  );
  await tester.pump();
}

MessageEvidenceRowData _message() {
  return const MessageEvidenceRowData(
    messageId: 8796093170832,
    dateUtc: '2026-05-20T18:58:00Z',
    isFromMe: false,
    text: 'hello',
    associatedMessageId: null,
    attachmentCount: 0,
    senderDisplayHandle: 'Claire',
    senderRawHandleLabel: '1 (778) 990-8506',
  );
}

class _FakeDeveloperMode extends DeveloperMode {
  _FakeDeveloperMode(this._value);

  final DeveloperModeValue _value;

  @override
  Future<DeveloperModeValue> build() async => _value;
}
