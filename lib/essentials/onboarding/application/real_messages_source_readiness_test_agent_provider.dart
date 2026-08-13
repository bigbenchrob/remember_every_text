import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'full_disk_access_provider.dart';
import 'messages_source_readiness_test_agent.dart';

part 'real_messages_source_readiness_test_agent_provider.g.dart';

@Riverpod(keepAlive: true)
MessagesSourceReadinessTestAgent realMessagesSourceReadinessTestAgent(Ref ref) {
  return MessagesSourceReadinessTestAgent(
    fullDiskAccess: ref.watch(fullDiskAccessProvider),
  );
}
