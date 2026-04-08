import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/debug/application/developer_mode_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/features/messages/application/strategies/recovered_list_ordinal_strategy.dart';
import 'package:remember_this_text/features/messages/application/timeline/ordinal/message_timeline_ordinal_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/messages/domain/value_objects/message_timeline_scope.dart';
import 'package:remember_this_text/features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_unlinked_messages_placeholder_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/timeline/message_timeline_view_model_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  group('RecoveredUnlinkedMessagesPlaceholderView', () {
    testWidgets('filters recovered rows through shared search state', (
      tester,
    ) async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final messages = _buildRecoveredMessages();
      final container = _createContainer(scope: scope, messages: messages);
      addTearDown(container.dispose);

      await _pumpPlaceholder(tester: tester, container: container);
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await tester.pump();

      expect(find.text('alpha note'), findsOneWidget);
      expect(find.text('beta archive'), findsOneWidget);
      expect(
        find.text('2 of 2 recovered deleted-message candidates'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(MacosTextField), 'receipt');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final viewModel = container.read(
        messageTimelineViewModelProvider(scope: scope),
      );
      expect(viewModel.debouncedQuery, 'receipt');
      expect(viewModel.searchResultIds.valueOrNull, <int>[20]);

      expect(find.text('alpha note'), findsNothing);
      expect(find.text('beta archive'), findsOneWidget);
      expect(
        find.text('1 of 2 recovered deleted-message candidates'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty state when shared search returns no matches', (
      tester,
    ) async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final messages = _buildRecoveredMessages();
      final container = _createContainer(scope: scope, messages: messages);
      addTearDown(container.dispose);

      await _pumpPlaceholder(tester: tester, container: container);
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await tester.pump();

      await tester.enterText(find.byType(MacosTextField), 'missing');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final viewModel = container.read(
        messageTimelineViewModelProvider(scope: scope),
      );
      expect(viewModel.debouncedQuery, 'missing');
      expect(viewModel.searchResultIds.valueOrNull, isEmpty);

      expect(
        find.text('No recovered deleted messages match the current filter.'),
        findsOneWidget,
      );
      expect(find.text('alpha note'), findsNothing);
      expect(find.text('beta archive'), findsNothing);
    });

    testWidgets('tapping a recovered attachment chip opens the right panel', (
      tester,
    ) async {
      const scope = MessageTimelineScope.recovered(contactId: 7);
      final messages = _buildRecoveredMessages();
      final selectedAttachment = messages[1].attachments.single;
      final container = _createContainer(scope: scope, messages: messages);
      addTearDown(container.dispose);

      await _pumpPlaceholder(tester: tester, container: container);
      await container.read(messageTimelineOrdinalProvider(scope: scope).future);
      await tester.pump();

      await tester.tap(find.text('receipt.png'));
      await tester.pump();

      expect(
        container
            .read(
              panelsViewStateProvider(SidebarMode.messages),
            )[WindowPanel.right]
            ?.activePage
            ?.spec,
        ViewSpec.messages(
          MessagesSpec.recoveredAttachmentViewer(
            messageId: messages[1].id,
            attachment: selectedAttachment,
          ),
        ),
      );
    });
  });
}

Future<void> _pumpPlaceholder({
  required WidgetTester tester,
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MacosApp(
        home: MacosWindow(
          child: SizedBox(
            width: 960,
            height: 720,
            child: const RecoveredUnlinkedMessagesPlaceholderView(contactId: 7),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

ProviderContainer _createContainer({
  required MessageTimelineScope scope,
  required List<RecoveredUnlinkedMessageItem> messages,
}) {
  _FakeMessageTimelineOrdinal.currentState = MessageTimelineOrdinalState(
    scope: scope,
    totalCount: messages.length,
    itemScrollController: ItemScrollController(),
    itemPositionsListener: ItemPositionsListener.create(),
    strategy: RecoveredListOrdinalStrategy(messages),
  );

  return ProviderContainer(
    overrides: [
      developerModeProvider.overrideWith(_FakeDeveloperMode.new),
      messageTimelineOrdinalProvider(
        scope: scope,
      ).overrideWith(_FakeMessageTimelineOrdinal.new),
      recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith(
        (ref) => Stream<List<RecoveredUnlinkedMessageItem>>.value(messages),
      ),
    ],
  );
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
      attachments: <AttachmentInfo>[
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

class _FakeDeveloperMode extends DeveloperMode {
  @override
  Future<DeveloperModeValue> build() async {
    return DeveloperModeValue.user;
  }
}

class _FakeMessageTimelineOrdinal extends MessageTimelineOrdinal {
  static late MessageTimelineOrdinalState currentState;

  @override
  Future<MessageTimelineOrdinalState> build({
    required MessageTimelineScope scope,
  }) async {
    return currentState;
  }
}
