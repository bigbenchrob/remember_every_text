import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/services/native_link_preview_service.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/url_preview_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.remember_this_text/link_preview');

  setUp(() {
    NativeLinkPreviewService.clearCache();
  });

  tearDown(() async {
    NativeLinkPreviewService.clearCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('UrlPreviewWidget', () {
    testWidgets('renders a compact loading placeholder while metadata loads', (
      tester,
    ) async {
      final completer = Completer<Map<Object?, Object?>?>();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) {
            return completer.future;
          });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UrlPreviewWidget(
                url: 'https://example.com/articles/compact-placeholder',
                isFromMe: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey<String>('loading')), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
      expect(find.text('Loading preview'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey<String>('loading'))).width,
        lessThan(300),
      );

      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('renders a compact preview when metadata has no image', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return <Object?, Object?>{
              'title': 'Compact Preview Title',
              'url': 'https://example.com/story',
            };
          });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UrlPreviewWidget(
                url: 'https://example.com/story',
                isFromMe: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('native-compact')),
        findsOneWidget,
      );
      expect(find.byType(AspectRatio), findsNothing);
      expect(find.text('Compact Preview Title'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('keeps the media frame when metadata includes preview bytes', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            return <Object?, Object?>{
              'title': 'Image Preview Title',
              'url': 'https://example.com/image-story',
              'imageData': 'AAEC',
            };
          });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: UrlPreviewWidget(
                url: 'https://example.com/image-story',
                isFromMe: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('native')), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
      expect(find.text('Image Preview Title'), findsOneWidget);
    });
  });

  group('NativeLinkPreviewService', () {
    test('logs metadata failures while preserving null fallback', () async {
      Object? loggedError;
      StackTrace? loggedStackTrace;
      String? loggedUrl;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            throw PlatformException(code: 'link-preview-failed');
          });

      final service = NativeLinkPreviewService(
        logFailure: (url, error, stackTrace) {
          loggedUrl = url;
          loggedError = error;
          loggedStackTrace = stackTrace;
        },
      );

      final result = await service.fetchMetadata('https://example.com/fails');

      expect(result, isNull);
      expect(loggedUrl, 'https://example.com/fails');
      expect(loggedError, isA<PlatformException>());
      expect(loggedStackTrace, isNotNull);
    });
  });
}
