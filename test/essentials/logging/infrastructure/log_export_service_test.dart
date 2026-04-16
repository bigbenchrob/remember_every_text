import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/logging/infrastructure/log_export_service.dart';

void main() {
  test('buildAppleMailComposeScriptArgs escapes subject path and recipient', () {
    final args = buildAppleMailComposeScriptArgs(
      exportFilePath: '/Users/test/Logs/diagnostic "final".log',
      recipientEmail: 'bigbenchrob@gmail.com',
      subject: 'MessageLens "Report"',
      bodyText: 'Please review the attached report.',
    );

    expect(args, contains('-e'));
    expect(
      args,
      contains(
        r'set reportFile to POSIX file "/Users/test/Logs/diagnostic \"final\".log"',
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
  });
}
