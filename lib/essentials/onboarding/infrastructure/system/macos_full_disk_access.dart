import 'dart:io';

import '../../application/full_disk_access.dart';

class MacosFullDiskAccess implements FullDiskAccess {
  const MacosFullDiskAccess({
    String? messagesDatabasePath,
    void Function(Object error, StackTrace stackTrace)? onReadFailure,
  }) : _messagesDatabasePath = messagesDatabasePath,
       _onReadFailure = onReadFailure;

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
  bool canReadMessagesDatabase() {
    try {
      final file = File(messagesDatabasePath);
      if (!file.existsSync()) {
        return false;
      }

      final raf = file.openSync(mode: FileMode.read);
      raf.closeSync();
      return true;
    } catch (error, stackTrace) {
      _onReadFailure?.call(error, stackTrace);
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    await Process.run('open', [
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    ]);
  }
}
