import 'package:flutter/foundation.dart';

typedef FlutterFrameworkErrorLogSink =
    void Function(
      String message, {
      String? source,
      Map<String, dynamic>? context,
    });

/// Defers Riverpod-backed logging until Flutter has left the failing stack.
///
/// Framework errors can occur during widget build or layout, when synchronously
/// mutating provider state is prohibited. Immediate console reporting remains
/// the responsibility of the caller.
Future<void> deferFlutterFrameworkErrorLog(
  FlutterErrorDetails details, {
  required FlutterFrameworkErrorLogSink logError,
}) async {
  await Future<void>.delayed(Duration.zero);

  logError(
    details.exceptionAsString(),
    source: 'FlutterError',
    context: {
      'library': details.library ?? 'unknown',
      'stack': details.stack?.toString().split('\n').take(10).join('\n') ?? '',
    },
  );
}
