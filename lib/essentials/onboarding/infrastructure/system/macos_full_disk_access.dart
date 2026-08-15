import 'dart:io';

import '../../../conversation_graph/application/monitor/chat_db_source_probe_reader.dart';
import '../../application/full_disk_access.dart';

class MacosFullDiskAccess implements FullDiskAccess {
  const MacosFullDiskAccess({
    required MessagesDatabaseReadProbe messagesDatabaseReadProbe,
    String? messagesDatabasePath,
    void Function(Object error, StackTrace stackTrace)? onReadFailure,
  }) : _messagesDatabaseReadProbe = messagesDatabaseReadProbe,
       _messagesDatabasePath = messagesDatabasePath,
       _onReadFailure = onReadFailure;

  final MessagesDatabaseReadProbe _messagesDatabaseReadProbe;
  final String? _messagesDatabasePath;
  final void Function(Object error, StackTrace stackTrace)? _onReadFailure;

  @override
  String get messagesDatabasePath {
    final configuredPath = _messagesDatabasePath;
    if (configuredPath != null) {
      return configuredPath;
    }

    final home = Platform.environment['HOME'] ?? '/Users/unknown';
    return '$home/Library/Messages/chat.db';
  }

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() {
    try {
      _messagesDatabaseReadProbe(messagesDatabasePath);
      return MessagesSourceAccessResult.readable;
    } catch (error, stackTrace) {
      _onReadFailure?.call(error, stackTrace);
      if (error is ChatDbSourceProbeException &&
          error.kind == ChatDbSourceProbeFailureKind.accessDenied) {
        return MessagesSourceAccessResult.accessDenied;
      }
      return MessagesSourceAccessResult.unavailable;
    }
  }

  @override
  bool canReadMessagesDatabase() {
    return inspectMessagesSourceAccess() == MessagesSourceAccessResult.readable;
  }

  @override
  Future<void> openSettings() async {
    await Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    ]);
  }
}
