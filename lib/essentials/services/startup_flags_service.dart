import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class StartupFlags {
  const StartupFlags({required this.optionLaunchResetRequested});

  const StartupFlags.disabled() : optionLaunchResetRequested = false;

  final bool optionLaunchResetRequested;

  factory StartupFlags.fromChannelPayload(Map<Object?, Object?> payload) {
    return StartupFlags(
      optionLaunchResetRequested:
          payload['optionLaunchResetRequested'] as bool? ?? false,
    );
  }
}

class StartupFlagsService {
  StartupFlagsService._();

  static const MethodChannel _channel = MethodChannel(
    'com.bigbenchsoftware.messagelens/startup',
  );

  static final StartupFlagsService instance = StartupFlagsService._();

  StartupFlags _cachedFlags = const StartupFlags.disabled();

  StartupFlags get cachedFlags => _cachedFlags;

  Future<StartupFlags> initialize() async {
    final flags = await _fetchStartupFlags();
    _cachedFlags = flags;
    return flags;
  }

  Future<StartupFlags> _fetchStartupFlags() async {
    try {
      final payload = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getStartupFlags',
      );
      if (payload == null) {
        return const StartupFlags.disabled();
      }

      return StartupFlags.fromChannelPayload(payload);
    } on MissingPluginException {
      return const StartupFlags.disabled();
    } on PlatformException {
      return const StartupFlags.disabled();
    }
  }
}
