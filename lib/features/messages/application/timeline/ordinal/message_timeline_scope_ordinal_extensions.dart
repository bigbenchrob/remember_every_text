import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../domain/message_timeline_scope_extensions.dart';
import '../../../domain/value_objects/message_timeline_scope.dart';
import '../../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import '../../strategies/ordinal_strategy.dart';
import '../../strategies/recovered_list_ordinal_strategy.dart';
import '../contact_timeline_display_version_provider.dart';

extension MessageTimelineScopeOrdinalResolution on MessageTimelineScope {
  Future<OrdinalStrategy> resolveOrdinalStrategy(Ref ref) async {
    switch (this) {
      case ContactTimelineScope():
        ref.watch(contactTimelineDisplayVersionProvider(scope: this));
      case GlobalTimelineScope() || ChatTimelineScope():
        ref.watch(messageDataVersionProvider);
      case RecoveredTimelineScope(:final contactId):
        ref.watch(recoveredUnlinkedMessagesProvider(contactId: contactId));
    }

    if (this case RecoveredTimelineScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    )) {
      final recoveredAsync = ref.watch(
        recoveredUnlinkedMessagesProvider(contactId: contactId),
      );
      final recoveredMessages =
          recoveredAsync.valueOrNull ??
          await ref.watch(
            recoveredUnlinkedMessagesProvider(contactId: contactId).future,
          ) ??
          const <RecoveredUnlinkedMessageItem>[];
      final filteredMessages = filterRecoveredTimelineMessages(
        messages: recoveredMessages,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      );

      return RecoveredListOrdinalStrategy(filteredMessages);
    }

    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    return toOrdinalStrategy(db);
  }
}
