import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/application/attachment_resolver_provider.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_provenance.dart';
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
        archiveCompatibilityKey: ArchiveCompatibilityKey(
          messageGuid: 'guid-3',
          importAttachmentId: 88,
        ),
        localPath: '~/Library/Messages/Attachments/missing/missing.jpg',
        mimeType: 'image/jpeg',
        transferName: 'missing.jpg',
      );

      await pumpSidebar(
        tester,
        attachment: attachment,
        overrides: <Override>[
          attachmentResolverProvider(attachment).overrideWith((ref) async {
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

    testWidgets('shows a Backup source badge for historical recovered files', (
      tester,
    ) async {
      final tempDir = Directory.systemTemp.createTempSync(
        'recovered_attachment_sidebar_backup_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });
      final recoveredFile = File('${tempDir.path}/historical.jpg')
        ..writeAsBytesSync(<int>[0, 1, 2, 3], flush: true);

      const attachment = AttachmentInfo(
        id: 4,
        archiveCompatibilityKey: ArchiveCompatibilityKey(
          messageGuid: 'guid-4',
          importAttachmentId: 99,
        ),
        localPath: '~/Library/Messages/Attachments/historical/original.jpg',
        mimeType: 'image/jpeg',
        transferName: 'historical.jpg',
      );

      await pumpSidebar(
        tester,
        attachment: attachment,
        overrides: <Override>[
          attachmentResolverProvider(attachment).overrideWith((ref) async {
            return ResolvedAttachment(
              attachmentInfo: attachment,
              availability: ResolvedAttachmentAvailability.available,
              provenance: AttachmentProvenance.importedHistorical,
              resolvedFilePath: recoveredFile.path,
            );
          }),
        ],
      );

      expect(
        find.byKey(
          const ValueKey<String>('recovered-attachment-source-badge-Backup'),
        ),
        findsOneWidget,
      );
      expect(find.text('Backup'), findsOneWidget);
      expect(find.text('Recovered backup path'), findsOneWidget);
    });
  });
}
