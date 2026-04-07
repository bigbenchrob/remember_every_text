import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_attachment_sidebar_view.dart';

void main() {
  group('RecoveredAttachmentSidebarView', () {
    Future<void> pumpSidebar(
      WidgetTester tester, {
      required AttachmentInfo attachment,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
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
      await tester.pumpAndSettle();
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

      expect(find.text('Recovered video'), findsOneWidget);
      expect(
        tester
            .getRect(
              find.byKey(const ValueKey<String>('recovered-placeholder-video')),
            )
            .width,
        lessThan(300),
      );
    });
  });
}
