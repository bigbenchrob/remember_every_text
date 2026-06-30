import 'dart:io';

import '../../application/monitor/chat_db_monitor_runtime_environment.dart';

class LocalChatDbMonitorRuntimeEnvironment
    implements ChatDbMonitorRuntimeEnvironment {
  const LocalChatDbMonitorRuntimeEnvironment();

  @override
  bool get supportsChatDbMonitoring => Platform.isMacOS;
}
