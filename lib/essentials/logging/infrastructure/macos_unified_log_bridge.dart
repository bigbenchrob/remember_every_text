import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/log_entry.dart';

class MacosUnifiedLogBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.remember_this_text/unified_log',
  );

  bool _pluginUnavailable = false;

  Future<void> log(LogEntry entry) async {
    if (_pluginUnavailable) {
      return;
    }

    try {
      await _channel.invokeMethod<void>('log', <String, Object?>{
        'level': entry.level.name,
        'source': entry.source,
        'message': entry.message,
      });
    } on MissingPluginException {
      _pluginUnavailable = true;
    } on PlatformException {
      // Best-effort bridge. Keep file logging as the source of truth.
    }
  }
}
