import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../../presentation/view_model/shared/hydration/messages_for_handle_provider.dart';
import '../../../presentation/view_model/shared/message_row_mapper.dart';

part 'search_result_context_provider.g.dart';

class SearchResultContextState {
  const SearchResultContextState({
    required this.selectedMessage,
    required this.beforeMessages,
    required this.afterMessages,
    required this.hasMoreBefore,
    required this.hasMoreAfter,
  });

  const SearchResultContextState.missing()
    : selectedMessage = null,
      beforeMessages = const [],
      afterMessages = const [],
      hasMoreBefore = false,
      hasMoreAfter = false;

  final MessageListItem? selectedMessage;
  final List<MessageListItem> beforeMessages;
  final List<MessageListItem> afterMessages;
  final bool hasMoreBefore;
  final bool hasMoreAfter;
}

@riverpod
Future<SearchResultContextState> searchResultContext(
  SearchResultContextRef ref, {
  required int messageId,
  required int chatId,
  required int beforeCount,
  required int afterCount,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);
  final mapper = MessageRowMapper(db, nameOverrides);

  final selectedQuery =
      db.select(db.workingMessages).join([
          drift.leftOuterJoin(
            db.handlesCanonical,
            db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
          ),
          drift.leftOuterJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
          ),
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(
          db.workingMessages.id.equals(messageId) &
              db.workingMessages.chatId.equals(chatId),
        )
        ..limit(1);

  final selectedRow = await selectedQuery.getSingleOrNull();
  if (selectedRow == null) {
    return const SearchResultContextState.missing();
  }

  final beforeQuery =
      db.select(db.workingMessages).join([
          drift.leftOuterJoin(
            db.handlesCanonical,
            db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
          ),
          drift.leftOuterJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
          ),
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(
          db.workingMessages.chatId.equals(chatId) &
              db.workingMessages.id.isSmallerThanValue(messageId),
        )
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.desc,
          ),
        ])
        ..limit(beforeCount + 1);

  final afterQuery =
      db.select(db.workingMessages).join([
          drift.leftOuterJoin(
            db.handlesCanonical,
            db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
          ),
          drift.leftOuterJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
          ),
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(
          db.workingMessages.chatId.equals(chatId) &
              db.workingMessages.id.isBiggerThanValue(messageId),
        )
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.asc,
          ),
        ])
        ..limit(afterCount + 1);

  final beforeRows = await beforeQuery.get();
  final afterRows = await afterQuery.get();

  final hasMoreBefore = beforeRows.length > beforeCount;
  final hasMoreAfter = afterRows.length > afterCount;

  final boundedBeforeRows = beforeRows
      .take(beforeCount)
      .toList(growable: false);
  final boundedAfterRows = afterRows.take(afterCount).toList(growable: false);

  final beforeMessagesDescending = await mapper.mapRows(boundedBeforeRows);
  final selectedMessages = await mapper.mapRows([selectedRow]);
  final afterMessages = await mapper.mapRows(boundedAfterRows);

  return SearchResultContextState(
    selectedMessage: selectedMessages.isEmpty ? null : selectedMessages.first,
    beforeMessages: beforeMessagesDescending.reversed.toList(growable: false),
    afterMessages: afterMessages,
    hasMoreBefore: hasMoreBefore,
    hasMoreAfter: hasMoreAfter,
  );
}
