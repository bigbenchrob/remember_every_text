import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/system/local_chat_db_monitor_runtime_environment.dart';
import 'chat_db_monitor_runtime_environment.dart';

part 'chat_db_monitor_runtime_environment_provider.g.dart';

@riverpod
ChatDbMonitorRuntimeEnvironment chatDbMonitorRuntimeEnvironment(Ref ref) {
  return const LocalChatDbMonitorRuntimeEnvironment();
}
