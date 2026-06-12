import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/monitor/chat_db_monitor_runtime_environment.dart';
import 'local_chat_db_monitor_runtime_environment.dart';

part 'chat_db_monitor_runtime_environment_provider.g.dart';

@riverpod
ChatDbMonitorRuntimeEnvironment chatDbMonitorRuntimeEnvironment(
  ChatDbMonitorRuntimeEnvironmentRef ref,
) {
  return const LocalChatDbMonitorRuntimeEnvironment();
}
