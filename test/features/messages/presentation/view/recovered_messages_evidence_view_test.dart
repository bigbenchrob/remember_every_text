import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/contacts/feature_level_providers.dart'
    show DisplayIdentityResolver, displayIdentityResolverProvider;
import 'package:remember_this_text/features/messages/application/message_evidence/recovered_message_evidence_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_evidence.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_messages_evidence_view.dart';

void main() {
  group('RecoveredMessagesEvidenceView', () {
    testWidgets('renders recovered messages through evidence spine', (
      tester,
    ) async {
      final messages = _buildRecoveredMessages();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayIdentityResolverProvider.overrideWith((ref) async {
              return const DisplayIdentityResolver(identitiesByHandleKey: {});
            }),
            recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
              (ref) =>
                  Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
            ),
          ],
          child: const MacosApp(
            home: MacosWindow(
              child: SizedBox(
                width: 960,
                height: 720,
                child: RecoveredMessagesEvidenceView(contactId: 7),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recovered deleted messages'), findsOneWidget);
      expect(find.text('alpha note'), findsOneWidget);
      expect(find.text('beta archive'), findsOneWidget);
      expect(find.text('receipt.png'), findsOneWidget);
    });

    testWidgets('filters recovered messages through evidence match ids', (
      tester,
    ) async {
      final messages = _buildRecoveredMessages();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            displayIdentityResolverProvider.overrideWith((ref) async {
              return const DisplayIdentityResolver(identitiesByHandleKey: {});
            }),
            recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
              (ref) =>
                  Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
            ),
          ],
          child: const MacosApp(
            home: MacosWindow(
              child: SizedBox(
                width: 960,
                height: 720,
                child: RecoveredMessagesEvidenceView(contactId: 7),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(MacosTextField), 'receipt');
      await tester.pumpAndSettle();

      expect(find.text('alpha note'), findsNothing);
      expect(find.text('beta archive'), findsOneWidget);
      expect(
        find.text('1 of 2 recovered messages match "receipt"'),
        findsOneWidget,
      );
    });
  });
}

List<RecoveredUnlinkedMessageItem> _buildRecoveredMessages() {
  return <RecoveredUnlinkedMessageItem>[
    RecoveredUnlinkedMessageItem(
      id: 10,
      guid: 'recovered-10',
      senderHandleId: null,
      contactName: null,
      rawItemType: null,
      rawAssociatedMessageType: null,
      semanticKind: 'plain-text',
      isSparseArtifact: false,
      isFromMe: false,
      isInferred: false,
      senderLabel: 'Alice',
      service: 'iMessage',
      text: 'alpha note',
      sentAt: DateTime(2024, 1, 10),
      itemType: 'text',
      hasAttachments: false,
      attachmentCount: 0,
      attachments: const <AttachmentInfo>[],
    ),
    RecoveredUnlinkedMessageItem(
      id: 20,
      guid: 'recovered-20',
      senderHandleId: null,
      contactName: null,
      rawItemType: null,
      rawAssociatedMessageType: null,
      semanticKind: 'plain-text',
      isSparseArtifact: false,
      isFromMe: false,
      isInferred: false,
      senderLabel: 'Bob',
      service: 'SMS',
      text: 'beta archive',
      sentAt: DateTime(2024, 2, 20),
      itemType: 'text',
      hasAttachments: true,
      attachmentCount: 1,
      attachments: const <AttachmentInfo>[
        AttachmentInfo(
          id: 501,
          localPath: null,
          mimeType: 'image/png',
          transferName: 'receipt.png',
        ),
      ],
    ),
  ];
}
