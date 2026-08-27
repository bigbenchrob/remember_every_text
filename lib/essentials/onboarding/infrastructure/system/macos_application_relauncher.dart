import 'package:flutter/services.dart';

import '../../application/application_relauncher.dart';

final class MacosApplicationRelauncher implements ApplicationRelauncher {
  const MacosApplicationRelauncher();

  static const _channel = MethodChannel(
    'com.bigbenchsoftware.MessageLens/archive_identity',
  );

  @override
  Future<void> relaunchAfterCompleteInstallationErase() async {
    await _channel.invokeMethod<void>('relaunchAfterCompleteInstallationErase');
  }
}
