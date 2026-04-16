import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/logging/infrastructure/log_export_service.dart';

void main() {
  test('buildAppleMailComposeScriptArgs escapes attachments subject and recipient', () {
    final args = buildAppleMailComposeScriptArgs(
      attachmentFilePaths: [
        '/Users/test/Logs/diagnostic "final".log',
        '/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log',
        '/Users/test/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log',
      ],
      recipientEmail: 'bigbenchrob@gmail.com',
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
        'make new to recipient at end of to recipients with properties {address:"bigbenchrob@gmail.com"}',
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
