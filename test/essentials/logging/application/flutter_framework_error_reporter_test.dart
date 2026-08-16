import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/logging/application/flutter_framework_error_reporter.dart';

void main() {
  test('defers the log sink beyond the failing framework stack', () async {
    var wasCalled = false;
    String? recordedMessage;
    String? recordedSource;
    Map<String, dynamic>? recordedContext;
    final details = FlutterErrorDetails(
      exception: StateError('layout failed'),
      library: 'rendering library',
      stack: StackTrace.fromString('first\nsecond'),
    );

    final pendingLog = deferFlutterFrameworkErrorLog(
      details,
      logError: (message, {source, context}) {
        wasCalled = true;
        recordedMessage = message;
        recordedSource = source;
        recordedContext = context;
      },
    );

    expect(wasCalled, isFalse);

    await pendingLog;

    expect(wasCalled, isTrue);
    expect(recordedMessage, contains('layout failed'));
    expect(recordedSource, 'FlutterError');
    expect(recordedContext, {
      'library': 'rendering library',
      'stack': 'first\nsecond',
    });
  });
}
