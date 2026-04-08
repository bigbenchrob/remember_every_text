import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/attachments/application/attachment_resolver_provider.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/attachments/domain/entities/resolved_attachment.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_attachment_sidebar_view.dart';

void main() {
  group('RecoveredAttachmentSidebarView', () {
    Future<void> pumpSidebar(
      WidgetTester tester, {
      required AttachmentInfo attachment,
      List<Override> overrides = const <Override>[],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MacosApp(
            home: MacosWindow(
              child: RecoveredAttachmentSidebarView(
                messageId: 42,
                attachment: attachment,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('renders metadata-only placeholder as a compact card', (
      tester,
    ) async {
      await pumpSidebar(
        tester,
        attachment: const AttachmentInfo(
          id: 1,
          localPath: null,
          mimeType: 'image/jpeg',
          transferName: 'missing.jpg',
        ),
      );

      expect(find.text('Attachment metadata only'), findsOneWidget);
      expect(
        tester
            .getRect(
              find.byKey(
                const ValueKey<String>('recovered-placeholder-metadata-only'),
              ),
            )
            .width,
        lessThan(300),
      );
    });

    testWidgets('renders recovered video placeholder as a compact card', (
      tester,
    ) async {
      await pumpSidebar(
        tester,
        attachment: const AttachmentInfo(
          id: 2,
          localPath: '/tmp/recovered.mov',
          mimeType: 'video/quicktime',
          transferName: 'recovered.mov',
        ),
      );

      expect(find.text('Video no longer present'), findsOneWidget);
      expect(
        tester
            .getRect(
              find.byKey(
                const ValueKey<String>('recovered-placeholder-video-metadata'),
              ),
            )
            .width,
        lessThan(300),
      );
    });

    testWidgets('shows explicit missing-image copy for unavailable images', (
      tester,
    ) async {
      const attachment = AttachmentInfo(
        id: 3,
        importAttachmentId: 88,
        localPath: '~/Library/Messages/Attachments/missing/missing.jpg',
        messageGuid: 'guid-3',
        mimeType: 'image/jpeg',
        transferName: 'missing.jpg',
      );

      await pumpSidebar(
        tester,
        attachment: attachment,
        overrides: <Override>[
          attachmentResolverProvider(
            attachment,
            messageGuid: 'guid-3',
            importAttachmentId: 88,
          ).overrideWith((ref) async {
            return const ResolvedAttachment(
              attachmentInfo: attachment,
              availability:
                  ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
            );
          }),
        ],
      );

      expect(find.text('Image no longer present'), findsOneWidget);
      expect(find.text('Recorded source path'), findsOneWidget);
      expect(
        find.textContaining('recorded Messages attachment path on this Mac'),
        findsOneWidget,
      );
    });
  });
}
