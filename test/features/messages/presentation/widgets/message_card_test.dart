import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/attachment_info.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_card.dart';

void main() {
  group('MessageCard', () {
    testWidgets(
      'renders message text below image attachments wider than the media in analysis layout',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  layout: MessageCardLayout.analysis,
                  message: MessageListItem(
                    id: 132292,
                    chatId: 42,
                    guid: 'guid-132292',
                    isFromMe: true,
                    senderName: 'You',
                    text:
                        'Here is the picture from the hike yesterday. The attachment text should render as its own normal message bubble, not as a narrow caption.',
                    sentAt: DateTime(2026, 3, 22, 10, 30),
                    hasAttachments: true,
                    attachments: const [
                      AttachmentInfo(
                        id: 1,
                        localPath: '/tmp/mixed-message.jpg',
                        mimeType: 'image/jpeg',
                        transferName: 'mixed-message.jpg',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.text(
            'Here is the picture from the hike yesterday. The attachment text should render as its own normal message bubble, not as a narrow caption.',
          ),
          findsOneWidget,
        );
        expect(find.text('Image unavailable'), findsOneWidget);

        final imageTop = tester.getTopLeft(find.text('Image unavailable')).dy;
        final textFinder = find.text(
          'Here is the picture from the hike yesterday. The attachment text should render as its own normal message bubble, not as a narrow caption.',
        );
        final textTop = tester.getTopLeft(textFinder).dy;
        final mediaWidth = tester.getRect(find.byType(AspectRatio).first).width;
        final bubbleContainer = find
            .ancestor(of: textFinder, matching: find.byType(Container))
            .first;
        final bubbleWidth = tester.getRect(bubbleContainer).width;

        expect(textTop, greaterThan(imageTop));
        expect(bubbleWidth, greaterThan(mediaWidth + 80));
      },
    );

    testWidgets(
      'does not render placeholder text above attachment-only messages',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132291,
                    chatId: 42,
                    guid: 'guid-132291',
                    isFromMe: true,
                    senderName: 'You',
                    text: '[No text content]',
                    sentAt: DateTime(2026, 3, 22, 10, 29),
                    hasAttachments: true,
                    attachments: const [
                      AttachmentInfo(
                        id: 2,
                        localPath: '/tmp/attachment-only.jpg',
                        mimeType: 'image/jpeg',
                        transferName: 'attachment-only.jpg',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('[No text content]'), findsNothing);
        expect(find.text('Image unavailable'), findsOneWidget);
      },
    );

    testWidgets(
      'does not render an empty caption bubble for attachment carrier text',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132293,
                    chatId: 42,
                    guid: 'guid-132293',
                    isFromMe: true,
                    senderName: 'You',
                    text: '\uFFFC',
                    sentAt: DateTime(2026, 3, 22, 10, 31),
                    hasAttachments: true,
                    attachments: const [
                      AttachmentInfo(
                        id: 3,
                        localPath: '/tmp/carrier-only.jpg',
                        mimeType: 'image/jpeg',
                        transferName: 'carrier-only.jpg',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('\uFFFC'), findsNothing);
        expect(find.text('Image unavailable'), findsOneWidget);
      },
    );
  });
}
