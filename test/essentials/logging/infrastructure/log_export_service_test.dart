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
