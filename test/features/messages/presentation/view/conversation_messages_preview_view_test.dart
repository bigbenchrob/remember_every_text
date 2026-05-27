import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/essentials/services/native_link_preview_service.dart';
import 'package:remember_this_text/features/messages/presentation/view/conversation_messages_preview_view.dart';

void main() {
  testWidgets('renders graph conversation timeline details', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [
              ConversationOverview(
                conversationId: 42,
                participantHandles: ['+15551', '+15552'],
                participantCount: 2,
                isGroup: true,
                messageCount: 3,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'newest',
              ),
            ];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest',
                associatedMessageId: 1,
                attachmentCount: 0,
                semanticKind: 'reaction',
              ),
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: false,
                text: null,
                associatedMessageId: null,
                attachmentCount: 0,
                senderDisplayHandle: '+15552',
                itemKind: 'system',
                isSparseArtifact: true,
                hasAttributedBodySource: true,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'oldest',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Conversation: +15551 and +15552'), findsOneWidget);
    expect(find.textContaining('3 messages'), findsOneWidget);
    expect(find.textContaining('oldest to newest'), findsOneWidget);
    expect(find.text('View options'), findsOneWidget);
    expect(find.text('conversationId: 42'), findsNothing);
    expect(find.text('participants: +15551 | +15552'), findsNothing);
    expect(find.text('visible messages: 3'), findsNothing);
    expect(find.textContaining('May 18, 2026 to May 20, 2026'), findsOneWidget);

    await tester.tap(find.text('View options'));
    await tester.pump();

    expect(
      find.textContaining('Showing 3 of 3 loaded messages'),
      findsOneWidget,
    );
    expect(find.text('2026-05-18'), findsOneWidget);
    expect(find.text('2026-05-19'), findsOneWidget);
    expect(find.text('2026-05-20'), findsOneWidget);
    expect(find.text('associated 1'), findsOneWidget);
    expect(find.text('reaction'), findsOneWidget);
    expect(find.textContaining('received | +15552'), findsOneWidget);
    expect(find.text('system'), findsOneWidget);
    expect(find.text('sparse'), findsOneWidget);
    expect(find.text('attributed body'), findsOneWidget);
    expect(find.text('no text'), findsOneWidget);

    final oldestTopLeft = tester.getTopLeft(find.text('oldest'));
    final newestTopLeft = tester.getTopLeft(find.text('newest'));
    expect(oldestTopLeft.dy, lessThan(newestTopLeft.dy));
  });

  testWidgets('can switch timeline order', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'oldest',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('View options'));
    await tester.pump();
    await tester.tap(find.text('Newest first'));
    await tester.pump();

    expect(find.textContaining('newest to oldest'), findsOneWidget);
    final newestTopLeft = tester.getTopLeft(find.text('newest'));
    final oldestTopLeft = tester.getTopLeft(find.text('oldest'));
    expect(newestTopLeft.dy, lessThan(oldestTopLeft.dy));
  });

  testWidgets('can increase message limit', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: 'limit 100 message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 500,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: true,
                text: 'limit 500 message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('limit 100 message'), findsOneWidget);

    await tester.tap(find.text('View options'));
    await tester.pump();
    await tester.tap(find.text('Latest 500'));
    await tester.pump();
    await tester.pump();

    expect(find.text('limit 500 message'), findsOneWidget);
    expect(find.text('limit 100 message'), findsNothing);
    expect(find.textContaining('latest 500'), findsOneWidget);
  });

  testWidgets('can filter visible messages', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-18T10:00:00.000Z',
                isFromMe: false,
                text: null,
                associatedMessageId: null,
                attachmentCount: 0,
              ),
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: true,
                text: 'text message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    expect(find.textContaining('All'), findsOneWidget);

    await tester.tap(find.text('View options'));
    await tester.pump();
    await tester.tap(find.text('No text'));
    await tester.pump();

    expect(find.textContaining('No text'), findsWidgets);
    expect(
      find.textContaining('Showing 1 of 2 loaded messages'),
      findsOneWidget,
    );
    expect(find.text('no text'), findsOneWidget);
    expect(find.text('text message'), findsNothing);
  });

  testWidgets('renders archive-aware graph message attachments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 7,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'has attachment',
                associatedMessageId: null,
                attachmentCount: 1,
              ),
            ];
          }),
          messageAttachmentsProvider(7).overrideWith((ref) async {
            return const [
              MessageAttachment(
                attachmentSsId: 99,
                guid: 'attachment-guid',
                filename: '/source/photo.jpg',
                transferName: 'photo.jpg',
                uti: 'public.jpeg',
                mimeType: 'image/png',
                totalBytes: 1200,
                createdAtUtc: '2026-05-20T10:00:00.000Z',
                localFileExists: false,
                archiveRelativePath: 'ab/photo.jpg',
                archiveAbsolutePath: '/archive/ab/photo.jpg',
                archiveFileExists: true,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('unavailable-media-card-Image')),
      findsOneWidget,
    );
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('photo.jpg | archived'), findsNothing);
  });

  testWidgets('renders graph video attachments through shared video evidence', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 8,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'has video',
                associatedMessageId: null,
                attachmentCount: 1,
              ),
            ];
          }),
          messageAttachmentsProvider(8).overrideWith((ref) async {
            return const [
              MessageAttachment(
                attachmentSsId: 100,
                guid: 'video-guid',
                filename: '/source/clip.mov',
                transferName: 'clip.mov',
                uti: 'public.movie',
                mimeType: 'video/quicktime',
                totalBytes: 1200,
                createdAtUtc: '2026-05-20T10:00:00.000Z',
                localFileExists: false,
                archiveRelativePath: 'ab/clip.mov',
                archiveAbsolutePath: '/archive/ab/clip.mov',
                archiveFileExists: true,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('unavailable-media-card-Video')),
      findsOneWidget,
    );
    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('renders unavailable graph image attachments visibly', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 9,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'missing image',
                associatedMessageId: null,
                attachmentCount: 1,
              ),
            ];
          }),
          messageAttachmentsProvider(9).overrideWith((ref) async {
            return const [
              MessageAttachment(
                attachmentSsId: 101,
                guid: 'missing-image-guid',
                filename: '/missing/photo.jpg',
                transferName: 'missing-photo.jpg',
                uti: 'public.jpeg',
                mimeType: 'image/jpeg',
                totalBytes: 1200,
                createdAtUtc: '2026-05-20T10:00:00.000Z',
                localFileExists: false,
                archiveRelativePath: 'ab/missing-photo.jpg',
                archiveAbsolutePath: '/missing/archive/photo.jpg',
                archiveFileExists: false,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('unavailable-media-card-Image')),
      findsOneWidget,
    );
    expect(find.text('Image in iCloud'), findsOneWidget);
  });

  testWidgets(
    'renders graph URL preview attachments without raw payload name',
    (tester) async {
      const channel = MethodChannel('com.remember_this_text/link_preview');
      NativeLinkPreviewService.clearCache();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return <Object?, Object?>{
              'title': 'Example Link Preview',
              'url': 'https://example.com/story',
            };
          });
      addTearDown(() {
        NativeLinkPreviewService.clearCache();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationOverviewsProvider(limit: 1000).overrideWith((
              ref,
            ) async {
              return const [];
            }),
            conversationMessagesProvider(
              conversationId: 42,
              limit: 100,
            ).overrideWith((ref) async {
              return const [
                ConversationMessage(
                  messageId: 10,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  isFromMe: false,
                  text: 'Read this https://example.com/story',
                  associatedMessageId: null,
                  attachmentCount: 1,
                ),
              ];
            }),
            messageAttachmentsProvider(10).overrideWith((ref) async {
              return const [
                MessageAttachment(
                  attachmentSsId: 102,
                  guid: 'url-preview-guid',
                  filename: '/source/GUID.pluginPayloadAttachment',
                  transferName: 'GUID.pluginPayloadAttachment',
                  uti: null,
                  mimeType: null,
                  totalBytes: 1200,
                  createdAtUtc: '2026-05-20T10:00:00.000Z',
                  localFileExists: false,
                  archiveRelativePath: 'ab/GUID.pluginPayloadAttachment',
                  archiveAbsolutePath: '/archive/GUID.pluginPayloadAttachment',
                  archiveFileExists: true,
                ),
                MessageAttachment(
                  attachmentSsId: 104,
                  guid: 'url-preview-guid-2',
                  filename: '/source/GUID-2.pluginPayloadAttachment',
                  transferName: 'GUID-2.pluginPayloadAttachment',
                  uti: null,
                  mimeType: null,
                  totalBytes: 900,
                  createdAtUtc: '2026-05-20T10:00:00.000Z',
                  localFileExists: false,
                  archiveRelativePath: 'ab/GUID-2.pluginPayloadAttachment',
                  archiveAbsolutePath:
                      '/archive/GUID-2.pluginPayloadAttachment',
                  archiveFileExists: true,
                ),
              ];
            }),
          ],
          child: const CupertinoApp(
            home: ConversationMessagesPreviewView(conversationId: 42),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Example Link Preview'), findsOneWidget);
      expect(find.text('GUID.pluginPayloadAttachment'), findsNothing);
      expect(find.text('GUID-2.pluginPayloadAttachment'), findsNothing);
    },
  );

  testWidgets('renders URL preview fallback when message text has no URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 11,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'Link preview carrier',
                associatedMessageId: null,
                attachmentCount: 1,
              ),
            ];
          }),
          messageAttachmentsProvider(11).overrideWith((ref) async {
            return const [
              MessageAttachment(
                attachmentSsId: 103,
                guid: 'url-preview-guid',
                filename: '/source/GUID.pluginPayloadAttachment',
                transferName: 'GUID.pluginPayloadAttachment',
                uti: null,
                mimeType: null,
                totalBytes: 1200,
                createdAtUtc: '2026-05-20T10:00:00.000Z',
                localFileExists: false,
                archiveRelativePath: null,
                archiveAbsolutePath: null,
                archiveFileExists: false,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Link preview attachment'), findsOneWidget);
    expect(find.text('GUID.pluginPayloadAttachment'), findsNothing);
  });

  testWidgets('renders text-only graph messages without attachment evidence', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 10,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'plain text only',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const CupertinoApp(
          home: ConversationMessagesPreviewView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('plain text only'), findsOneWidget);
    expect(find.textContaining('attachments:'), findsNothing);
  });

  testWidgets('renders graph search context and anchor message', (
    tester,
  ) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewsProvider(limit: 1000).overrideWith((ref) async {
            return const [];
          }),
          conversationMessagesProvider(
            conversationId: 42,
            limit: 100,
          ).overrideWith((ref) async {
            return const [
              ConversationMessage(
                messageId: 102,
                dateUtc: '2026-05-21T10:00:00.000Z',
                isFromMe: false,
                text: 'Unrelated context.',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
              ConversationMessage(
                messageId: 101,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: false,
                text: 'The settlement term appears here.',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ];
          }),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: ConversationMessagesPreviewView(
            conversationId: 42,
            anchorMessageId: 101,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('1 matches for "settlement"'), findsOneWidget);
    expect(find.text('Match 1 of 1'), findsOneWidget);
    expect(
      find.text('The settlement term appears here.', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Previous'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Matching only'), findsOneWidget);
    expect(find.text('Unrelated context.'), findsOneWidget);

    await tester.tap(find.text('Matching only'));
    await tester.pump();

    expect(find.text('Unrelated context.'), findsNothing);
    expect(
      find.text('The settlement term appears here.', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('Copy evidence summary'));
    await tester.pump();

    expect(find.text('Copied evidence summary'), findsOneWidget);
    expect(copiedText, contains('Conversation: Unknown participants'));
    expect(copiedText, contains('Search: "settlement"'));
    expect(copiedText, contains('Selected match: 1 of 1'));
    expect(copiedText, contains('Anchored message id: 101'));
    expect(
      copiedText,
      contains('Anchored message text: The settlement term appears here.'),
    );
  });
}
