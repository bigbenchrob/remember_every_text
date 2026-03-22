import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/attachment_info.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_card.dart';

void main() {
  group('MessageCard', () {
    testWidgets(
      'renders message text below image attachments when both are present',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132292,
                    chatId: 42,
                    guid: 'guid-132292',
                    isFromMe: true,
                    senderName: 'You',
                    text: 'Here is the picture',
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

        expect(find.text('Here is the picture'), findsOneWidget);
        expect(find.text('Image unavailable'), findsOneWidget);

        final imageTop = tester.getTopLeft(find.text('Image unavailable')).dy;
        final textTop = tester.getTopLeft(find.text('Here is the picture')).dy;

        expect(textTop, greaterThan(imageTop));
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
  });
}
