import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_user_metadata_widgets.dart';

void main() {
  late OverlayDatabase overlayDb;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await overlayDb.close();
  });

  testWidgets('renders saved state and matched tags for search results', (
    tester,
  ) async {
    await overlayDb.setMessageSaved(
      messageGuid: 'guid-search-metadata',
      isSaved: true,
    );
    await overlayDb.addMessageUserTags(
      messageGuid: 'guid-search-metadata',
      tags: const <String>['Miłosz', 'Preparation'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MessageSearchMatchMetadata(
              message: MessageListItem(
                id: 1,
                chatId: 1,
                guid: 'guid-search-metadata',
                isFromMe: false,
                senderName: 'Alex',
                text: 'Body text unrelated to the tag match.',
                sentAt: null,
                hasAttachments: false,
              ),
              query: 'milosz',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Matched tags'), findsOneWidget);
    expect(find.text('Miłosz'), findsOneWidget);
    expect(find.text('Preparation'), findsNothing);
  });

  testWidgets('matched-tag metadata keeps more space below than above', (
    tester,
  ) async {
    await overlayDb.addMessageUserTags(
      messageGuid: 'guid-spacing-metadata',
      tags: const <String>['zippy'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(key: Key('above-marker')),
                MessageSearchMatchMetadata(
                  message: MessageListItem(
                    id: 2,
                    chatId: 1,
                    guid: 'guid-spacing-metadata',
                    isFromMe: false,
                    senderName: 'Alex',
                    text: 'Not the search term.',
                    sentAt: null,
                    hasAttachments: false,
                  ),
                  query: 'zippy',
                ),
                SizedBox(key: Key('below-marker')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final wrapFinder = find.descendant(
      of: find.byType(MessageSearchMatchMetadata),
      matching: find.byType(Wrap),
    );
    final wrapRect = tester.getRect(wrapFinder);
    final aboveDy = tester.getTopLeft(find.byKey(const Key('above-marker'))).dy;
    final belowDy = tester.getTopLeft(find.byKey(const Key('below-marker'))).dy;

    final topGap = wrapRect.top - aboveDy;
    final bottomGap = belowDy - wrapRect.bottom;

    expect(bottomGap, greaterThan(topGap));
  });
}
