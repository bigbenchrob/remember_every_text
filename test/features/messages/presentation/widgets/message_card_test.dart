import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/attachment_info.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_card.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

final _transparentThumbnailBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9WnKi4QAAAAASUVORK5CYII=',
);

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
        expect(find.text('Image in iCloud'), findsOneWidget);

        final imageTop = tester.getTopLeft(find.text('Image in iCloud')).dy;
        final textFinder = find.text(
          'Here is the picture from the hike yesterday. The attachment text should render as its own normal message bubble, not as a narrow caption.',
        );
        final textTop = tester.getTopLeft(textFinder).dy;
        final mediaWidth = tester
            .getRect(
              find.byKey(
                const ValueKey<String>('unavailable-media-card-Image'),
              ),
            )
            .width;
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
        expect(find.text('Image in iCloud'), findsOneWidget);
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
        expect(find.text('Image in iCloud'), findsOneWidget);
      },
    );

    testWidgets(
      'renders archive-pending placeholder for image attachments without a local path',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132294,
                    chatId: 42,
                    guid: 'guid-132294',
                    isFromMe: false,
                    senderName: 'Alex',
                    text: '[No text content]',
                    sentAt: DateTime(2026, 3, 22, 10, 32),
                    hasAttachments: true,
                    attachments: const [
                      AttachmentInfo(
                        id: 4,
                        localPath: null,
                        mimeType: 'image/jpeg',
                        transferName: 'archiving.jpg',
                        availability:
                            ResolvedAttachmentAvailability.pendingArchive,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Image being archived'), findsOneWidget);
        expect(
          tester
              .getRect(
                find.byKey(
                  const ValueKey<String>('unavailable-media-card-Image'),
                ),
              )
              .width,
          lessThan(300),
        );
      },
    );

    testWidgets(
      'renders prioritize recovery action for recoverable unavailable attachments',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132295,
                    chatId: 42,
                    guid: 'guid-132295',
                    isFromMe: false,
                    senderName: 'Alex',
                    text: '[No text content]',
                    sentAt: DateTime(2026, 3, 22, 10, 33),
                    hasAttachments: true,
                    attachments: const [
                      AttachmentInfo(
                        id: 5,
                        localPath: null,
                        mimeType: 'image/jpeg',
                        transferName: 'recover-me.jpg',
                        importAttachmentId: 77,
                        messageGuid: 'guid-132295',
                        availability: ResolvedAttachmentAvailability
                            .unavailableAwaitingRecovery,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Prioritize recovery'), findsOneWidget);
      },
    );

    testWidgets(
      'renders a lightweight video shell before explicit activation',
      (tester) async {
        final tempDir = Directory.systemTemp.createTempSync(
          'message_card_video_shell_',
        );
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });
        final videoFile = File('${tempDir.path}/sample.mov')
          ..writeAsBytesSync(<int>[0, 1, 2, 3]);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: MessageCard(
                  message: MessageListItem(
                    id: 132296,
                    chatId: 42,
                    guid: 'guid-132296',
                    isFromMe: false,
                    senderName: 'Alex',
                    text: '[No text content]',
                    sentAt: DateTime(2026, 3, 22, 10, 34),
                    hasAttachments: true,
                    attachments: [
                      AttachmentInfo(
                        id: 6,
                        localPath: videoFile.path,
                        mimeType: 'video/quicktime',
                        transferName: 'sample.mov',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey<String>('video-activation-shell-card')),
          findsOneWidget,
        );
        expect(find.text('Video'), findsOneWidget);
        expect(find.text('Play video'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('renders a thumbnail behind the video shell controls', (
      tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync(
        'message_card_video_thumbnail_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final thumbnailFile = File('${tempDir.path}/sample-thumb.jpg')
        ..writeAsBytesSync(_transparentThumbnailBytes, flush: true);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VideoActivationShell(
                aspectRatio: 16 / 9,
                isActivating: false,
                activationFailed: false,
                thumbnailFile: thumbnailFile,
                onActivate: null,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('video-activation-thumbnail')),
        findsOneWidget,
      );
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Play video'), findsOneWidget);
    });

    testWidgets('renders live playback controls after video activation', (
      tester,
    ) async {
      final originalPlatform = VideoPlayerPlatform.instance;
      final fakePlatform = _FakeVideoPlayerPlatform();
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() {
        VideoPlayerPlatform.instance = originalPlatform;
      });

      final tempDir = Directory.systemTemp.createTempSync(
        'message_card_video_activation_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final videoFile = File('${tempDir.path}/sample.mov')
        ..writeAsBytesSync(<int>[0, 1, 2, 3]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageCard(
                message: MessageListItem(
                  id: 132297,
                  chatId: 42,
                  guid: 'guid-132297',
                  isFromMe: false,
                  senderName: 'Alex',
                  text: '[No text content]',
                  sentAt: DateTime(2026, 3, 22, 10, 35),
                  hasAttachments: true,
                  attachments: [
                    AttachmentInfo(
                      id: 7,
                      localPath: videoFile.path,
                      mimeType: 'video/quicktime',
                      transferName: 'sample.mov',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('video-activation-shell-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byType(VideoProgressIndicator), findsOneWidget);
      expect(fakePlatform.calls, contains('play'));

      fakePlatform.emitCompleted(textureId: 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('pause button pauses an active video', (tester) async {
      final originalPlatform = VideoPlayerPlatform.instance;
      final fakePlatform = _FakeVideoPlayerPlatform();
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() {
        VideoPlayerPlatform.instance = originalPlatform;
      });

      final tempDir = Directory.systemTemp.createTempSync(
        'message_card_video_pause_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final videoFile = File('${tempDir.path}/sample.mov')
        ..writeAsBytesSync(<int>[0, 1, 2, 3]);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MessageCard(
                message: MessageListItem(
                  id: 132300,
                  chatId: 42,
                  guid: 'guid-132300',
                  isFromMe: false,
                  senderName: 'Alex',
                  text: '[No text content]',
                  sentAt: DateTime(2026, 3, 22, 10, 37),
                  hasAttachments: true,
                  attachments: [
                    AttachmentInfo(
                      id: 8,
                      localPath: videoFile.path,
                      mimeType: 'video/quicktime',
                      transferName: 'sample.mov',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('video-activation-shell-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(fakePlatform.calls, contains('play'));

      await tester.tap(
        find.byKey(const ValueKey<String>('active-video-toggle-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(fakePlatform.calls, contains('pause'));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('resets an active video tile when attachment changes', (
      tester,
    ) async {
      final originalPlatform = VideoPlayerPlatform.instance;
      final fakePlatform = _FakeVideoPlayerPlatform();
      VideoPlayerPlatform.instance = fakePlatform;
      addTearDown(() {
        VideoPlayerPlatform.instance = originalPlatform;
      });

      final tempDir = Directory.systemTemp.createTempSync(
        'message_card_video_rebind_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final firstVideoFile = File('${tempDir.path}/first.mov')
        ..writeAsBytesSync(<int>[0, 1, 2, 3]);
      final secondVideoFile = File('${tempDir.path}/second.mov')
        ..writeAsBytesSync(<int>[4, 5, 6, 7]);

      final currentPath = ValueNotifier<String>(firstVideoFile.path);
      addTearDown(currentPath.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<String>(
                valueListenable: currentPath,
                builder: (context, path, child) {
                  return MessageCard(
                    message: MessageListItem(
                      id: 132298,
                      chatId: 42,
                      guid: 'guid-132298',
                      isFromMe: false,
                      senderName: 'Alex',
                      text: '[No text content]',
                      sentAt: DateTime(2026, 3, 22, 10, 36),
                      hasAttachments: true,
                      attachments: [
                        AttachmentInfo(
                          id: 132298,
                          localPath: path,
                          mimeType: 'video/quicktime',
                          transferName: 'sample.mov',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('video-activation-shell-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byType(VideoProgressIndicator), findsOneWidget);

      currentPath.value = secondVideoFile.path;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(
        find.byKey(const ValueKey<String>('video-activation-shell-card')),
        findsOneWidget,
      );
      expect(find.byType(VideoProgressIndicator), findsNothing);
    });
  });
}

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final List<String> calls = <String>[];
  final Map<int, StreamController<VideoEvent>> streams =
      <int, StreamController<VideoEvent>>{};
  final Map<int, Duration> _positions = <int, Duration>{};
  int _nextTextureId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final textureId = _nextTextureId++;
    calls.add('create');
    streams[textureId] = StreamController<VideoEvent>()
      ..add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 2),
          size: const Size(1920, 1080),
        ),
      );
    return textureId;
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
    await streams.remove(textureId)?.close();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return streams[textureId]!.stream;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
    streams[textureId]?.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: true,
      ),
    );
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
    streams[textureId]?.add(
      VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: false,
      ),
    );
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
    _positions[textureId] = position;
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<Duration> getPosition(int textureId) async {
    return _positions[textureId] ?? Duration.zero;
  }

  @override
  Widget buildView(int textureId) {
    return const SizedBox.expand();
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> setWebOptions(
    int textureId,
    VideoPlayerWebOptions options,
  ) async {}

  void emitCompleted({required int textureId}) {
    _positions[textureId] = const Duration(seconds: 2);
    streams[textureId]?.add(VideoEvent(eventType: VideoEventType.completed));
  }
}
