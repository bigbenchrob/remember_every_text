import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/logging/infrastructure/log_export_service.dart';

void main() {
  test('createSupportBundleMailArchive creates zip on macOS', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_mail_archive_test_',
    );
    final bundleDirectory = Directory(
      '${tempDirectory.path}/support_bundle_2026-04-16_111443',
    );
    await bundleDirectory.create();
    await File(
      '${bundleDirectory.path}/diagnostic_report.log',
    ).writeAsString('diagnostic log');

    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final archive = await createSupportBundleMailArchive(bundleDirectory);

    if (!Platform.isMacOS) {
      expect(archive, isNull);
      return;
    }

    expect(archive, isNotNull);
    expect(archive!.existsSync(), isTrue);
    expect(archive.path, endsWith('support_bundle_2026-04-16_111443.zip'));
    expect(archive.lengthSync(), greaterThan(0));
  });

  test(
    'createSupportBundleMailArchive rejects raw database contents',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_mail_archive_test_',
      );
      final bundleDirectory = Directory(
        '${tempDirectory.path}/support_bundle_2026-04-16_111443',
      );
      await bundleDirectory.create();
      await File('${bundleDirectory.path}/working.db').writeAsString('db');

      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final archive = await createSupportBundleMailArchive(bundleDirectory);

      expect(archive, isNull);
      expect(
        File(
          '${tempDirectory.path}/support_bundle_2026-04-16_111443.zip',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'createSupportBundleMailArchive rejects non-support directories',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_mail_archive_test_',
      );
      final bundleDirectory = Directory('${tempDirectory.path}/not_a_bundle');
      await bundleDirectory.create();
      await File(
        '${bundleDirectory.path}/diagnostic_report.log',
      ).writeAsString('diagnostic log');

      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final archive = await createSupportBundleMailArchive(bundleDirectory);

      expect(archive, isNull);
      expect(
        File('${tempDirectory.path}/not_a_bundle.zip').existsSync(),
        isFalse,
      );
    },
  );

  test(
    'createSupportBundleMailArchive rejects symlink bundle directory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_mail_archive_test_',
      );
      final realBundleDirectory = Directory(
        '${tempDirectory.path}/real_support_bundle',
      );
      await realBundleDirectory.create();
      await File(
        '${realBundleDirectory.path}/diagnostic_report.log',
      ).writeAsString('diagnostic log');
      final bundleLink = Link(
        '${tempDirectory.path}/support_bundle_2026-04-16_111443',
      );
      await bundleLink.create(realBundleDirectory.path);

      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final archive = await createSupportBundleMailArchive(
        Directory(bundleLink.path),
      );

      expect(archive, isNull);
      expect(
        File(
          '${tempDirectory.path}/support_bundle_2026-04-16_111443.zip',
        ).existsSync(),
        isFalse,
      );
    },
  );

  test(
    'createSupportBundleMailArchive rejects symlink archive target',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_mail_archive_test_',
      );
      final bundleDirectory = Directory(
        '${tempDirectory.path}/support_bundle_2026-04-16_111443',
      );
      await bundleDirectory.create();
      await File(
        '${bundleDirectory.path}/diagnostic_report.log',
      ).writeAsString('diagnostic log');

      final protectedTarget = File('${tempDirectory.path}/protected.txt');
      await protectedTarget.writeAsString('do not replace');
      final archiveLink = Link(
        '${tempDirectory.path}/support_bundle_2026-04-16_111443.zip',
      );
      await archiveLink.create(protectedTarget.path);

      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final archive = await createSupportBundleMailArchive(bundleDirectory);

      expect(archive, isNull);
      expect(archiveLink.existsSync(), isTrue);
      expect(protectedTarget.readAsStringSync(), 'do not replace');
    },
  );

  test('buildAppleMailComposeScriptArgs escapes attachments subject and recipient', () {
    final args = buildAppleMailComposeScriptArgs(
      attachmentFilePaths: [
        '/Users/test/Logs/diagnostic "final".log',
        '/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log',
        '/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log',
      ],
      recipientEmail: 'messagelens@gmail.com',
      subject: 'MessageLens "Report"',
      bodyText: 'Please review the attached report.',
    );

    expect(args, contains('-e'));
    expect(
      args,
      contains(
        r'set attachmentFile1 to POSIX file "/Users/test/Logs/diagnostic \"final\".log"',
      ),
    );
    expect(
      args,
      contains(
        'set attachmentFile2 to POSIX file "/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log"',
      ),
    );
    expect(
      args,
      contains(
        'set attachmentFile3 to POSIX file "/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log"',
      ),
    );
    expect(
      args,
      contains(
        r'set newMessage to make new outgoing message with properties {subject:"MessageLens \"Report\"", content:"Please review the attached report.", visible:true}',
      ),
    );
    expect(
      args,
      contains(
        'make new to recipient at end of to recipients with properties {address:"messagelens@gmail.com"}',
      ),
    );
    expect(
      args,
      contains(
        'make new attachment with properties {file name:attachmentFile1} at after the last paragraph',
      ),
    );
    expect(
      args,
      contains(
        'make new attachment with properties {file name:attachmentFile2} at after the last paragraph',
      ),
    );
    expect(
      args,
      contains(
        'make new attachment with properties {file name:attachmentFile3} at after the last paragraph',
      ),
    );
  });
}
