import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/db/feature_level_providers/message_data_version_provider.dart';
import '../../../domain/message_timeline_scope_extensions.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import 'ordinal/message_timeline_ordinal_provider.dart';

part 'contact_timeline_display_version_provider.g.dart';

@riverpod
class ContactTimelineDisplayVersion extends _$ContactTimelineDisplayVersion {
  @override
  int build({required MessageTimelineScope scope}) {
    return ref.read(messageDataVersionProvider);
  }

  void syncToLatest() {
    state = ref.read(messageDataVersionProvider);
  }
}

@riverpod
bool contactTimelineHasPendingMessages(
  Ref ref, {
  required MessageTimelineScope scope,
}) {
  final liveVersion = ref.watch(messageDataVersionProvider);
  final displayedVersion = ref.watch(
    contactTimelineDisplayVersionProvider(scope: scope),
  );

  return liveVersion > displayedVersion;
}

@riverpod
Future<List<int>> pendingContactTimelineMessageIds(
  Ref ref, {
  required MessageTimelineScope scope,
}) async {
  if (scope is! ContactTimelineScope) {
    return const <int>[];
  }

  final liveVersion = ref.watch(messageDataVersionProvider);
  final displayedVersion = ref.watch(
    contactTimelineDisplayVersionProvider(scope: scope),
  );

  if (liveVersion <= displayedVersion) {
    return const <int>[];
  }

  final displayedOrdinalState = await ref.watch(
    messageTimelineOrdinalProvider(scope: scope).future,
  );
  final displayedCount = displayedOrdinalState.totalCount;

  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final strategy = scope.toOrdinalStrategy(db);
  final liveCount = await strategy.getTotalCount();

  if (liveCount <= displayedCount) {
    return const <int>[];
  }

  final pendingMessageIds = <int>[];
  for (var ordinal = displayedCount; ordinal < liveCount; ordinal++) {
    final messageId = await strategy.getMessageIdByOrdinal(ordinal);
    if (messageId != null) {
      pendingMessageIds.add(messageId);
    }
  }

  return pendingMessageIds;
}
