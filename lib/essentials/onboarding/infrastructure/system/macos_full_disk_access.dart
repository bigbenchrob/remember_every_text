import 'dart:io';

import '../../application/full_disk_access.dart';

class MacosFullDiskAccess implements FullDiskAccess {
  const MacosFullDiskAccess();

  @override
  String get messagesDatabasePath {
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
    } catch (_) {
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
