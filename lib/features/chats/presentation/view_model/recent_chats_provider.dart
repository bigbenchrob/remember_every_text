import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../application/calendar_heatmap_timeline_calculator.dart';
import '../../application/chat_read_model_source_provider.dart';
import '../../application/conversation_browser/contact_handle_label_provider.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';
import '../../domain/chat_timeline_data.dart';

part 'recent_chats_provider.g.dart';

/// Lightweight view model describing the data needed for the recent chats list.
class RecentChatSummary {
  const RecentChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.attachmentCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.isGroup,
    required this.participants,
    required this.handles,
    required this.recency,
    required this.timelineData,
    required this.calendarHeatmapTimelineData,
    this.lastMessagePreview,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final int attachmentCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final List<String> participants;
  final List<String> handles;
  final ChatRecency? recency;
  final ChatTimelineData? timelineData;
  final CalendarHeatmapTimelineData? calendarHeatmapTimelineData;
  final String? lastMessagePreview;
}

@riverpod
Future<List<RecentChatSummary>> recentChats(Ref ref, {int? limit}) async {
  final readModelSource = ref.watch(chatReadModelSourceProvider);
  if (readModelSource == ChatReadModelSourceMode.conversationGraph) {
    return readGraphRecentChats(ref, limit: limit);
  }

  return readLegacyRecentChats(ref, limit: limit);
}

Future<List<RecentChatSummary>> readGraphRecentChats(
  Ref ref, {
  int? limit,
}) async {
  final overviews = await ref.watch(
    conversationOverviewsProvider(limit: limit ?? 100).future,
  );
  final contactLabels = await ref.watch(contactHandleLabelsProvider.future);
  return _mapGraphOverviews(overviews, contactLabels);
}

Future<List<RecentChatSummary>> readLegacyRecentChats(
  Ref ref, {
  int? limit,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);

  List<WorkingChat> chatRows;
  final chatsQuery = db.select(db.workingChats)
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.lastMessageAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(
        expression: tbl.updatedAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ]);

  if (limit != null) {
    chatsQuery.limit(limit);
  }

  chatRows = await chatsQuery.get();

  final messageCountExpression = db.workingMessages.id.count();
  final firstSentExpression = db.workingMessages.sentAtUtc.min();
  final lastSentExpression = db.workingMessages.sentAtUtc.max();

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String deriveTitle(WorkingChat chat, List<String> participants) {
    if (participants.isEmpty) {
      return 'Unnamed Conversation';
    }

    if (!chat.isGroup && participants.isNotEmpty) {
      return participants.first;
    }

    if (participants.length == 1) {
      return participants.first;
    }

    if (participants.length == 2) {
      return '${participants[0]} and ${participants[1]}';
    }

    final remainingCount = participants.length - 2;
    return '${participants[0]}, ${participants[1]} + $remainingCount more';
  }

  final results = <RecentChatSummary>[];

  for (final chat in chatRows) {
    final stats =
        await (db.selectOnly(db.workingMessages)
              ..where(db.workingMessages.chatId.equals(chat.id))
              ..addColumns([
                messageCountExpression,
                firstSentExpression,
                lastSentExpression,
              ]))
            .getSingleOrNull();

    final messageCount = stats?.read(messageCountExpression) ?? 0;
    final firstSentUtc = stats?.read(firstSentExpression);
    final lastSentUtc = stats?.read(lastSentExpression);

    final lastMessageDate = parseUtc(lastSentUtc ?? chat.lastMessageAtUtc);

    // Query participants for this chat:
    // chats.handle_id → handle_to_participant → participants
    final participantsQuery = db.select(db.chatToHandle).join([
      // Join chat_to_handle → handles
      drift.innerJoin(
        db.handlesCanonical,
        db.handlesCanonical.id.equalsExp(db.chatToHandle.handleId),
      ),
      // Left join handles → handle_to_participant (some handles may be unmatched)
      drift.leftOuterJoin(
        db.handleToParticipant,
        db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
      ),
      // Left join participants for resolved contacts (optional)
      drift.leftOuterJoin(
        db.workingParticipants,
        db.workingParticipants.id.equalsExp(
          db.handleToParticipant.participantId,
        ),
      ),
    ])..where(db.chatToHandle.chatId.equals(chat.id));

    // Display name: overlay override wins, then working DB
    String resolveParticipantName(WorkingParticipant participant) =>
        nameOverrides[participant.id] ?? participant.displayName;

    final participantRows = await participantsQuery.get();
    final participantNames = <String>[];
    final handleIdentifiers = <String>[];
    final seenNames = <String>{};

    for (final row in participantRows) {
      final handle = row.readTable(db.handlesCanonical);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Store the display name (formatted phone number or email)
      handleIdentifiers.add(handle.displayName);

      String resolvedName;
      if (participant != null) {
        // We have a matched participant (contact) - use their display name
        resolvedName = resolveParticipantName(participant);
      } else {
        // No matched participant - fall back to handle identifier
        final displayName = handle.displayName.trim();
        final rawIdentifier = handle.rawIdentifier.trim();
        final compoundIdentifier = handle.compoundIdentifier.trim();

        // Prefer display_name populated during migration for human readable output
        resolvedName = displayName.isNotEmpty
            ? displayName
            : rawIdentifier.isNotEmpty
            ? rawIdentifier
            : compoundIdentifier.isNotEmpty
            ? compoundIdentifier
            : 'Unknown Contact';
      }

      final normalized = resolvedName.toLowerCase();
      final isSelfAlias = normalized == 'me';
      if (!isSelfAlias || chat.isGroup) {
        if (!seenNames.add(normalized)) {
          continue;
        }
      }

      participantNames.add(resolvedName);
    }
    if (participantNames.isEmpty) {
      participantNames.add('Unknown Contact');
    }

    // Calculate recency from last message date
    final recency = lastMessageDate != null
        ? ChatRecency.fromDateTime(lastMessageDate)
        : null;

    // Calculate calendar heatmap timeline data
    final firstMsgDate = parseUtc(firstSentUtc ?? chat.createdAtUtc);
    const ChatTimelineData? timelineData = null; // Old algorithms disabled

    final calendarHeatmapTimelineData = await calculateCalendarHeatmapTimeline(
      db,
      chat.id,
      firstMsgDate,
      lastMessageDate,
    );
    final attachmentCountRows = await db
        .customSelect(
          '''
      SELECT COUNT(DISTINCT a.id) AS attachment_count
      FROM messages m
      JOIN attachments a ON a.message_guid = m.guid
      WHERE m.chat_id = ?
      ''',
          variables: [drift.Variable<int>(chat.id)],
        )
        .get();
    final attachmentCount =
        attachmentCountRows.single.data['attachment_count'] as int? ?? 0;

    results.add(
      RecentChatSummary(
        chatId: chat.id,
        title: deriveTitle(chat, participantNames),
        messageCount: messageCount,
        attachmentCount: attachmentCount,
        firstMessageDate: firstMsgDate,
        lastMessageDate: lastMessageDate,
        isGroup: chat.isGroup,
        participants: participantNames,
        handles: handleIdentifiers,
        recency: recency,
        timelineData: timelineData,
        calendarHeatmapTimelineData: calendarHeatmapTimelineData,
      ),
    );
  }

  return results;
}

List<RecentChatSummary> _mapGraphOverviews(
  List<ConversationOverview> overviews,
  Map<String, ContactHandleLabel> contactLabels,
) {
  return [
    for (final overview in overviews)
      _mapGraphOverview(overview, contactLabels),
  ];
}

RecentChatSummary _mapGraphOverview(
  ConversationOverview overview,
  Map<String, ContactHandleLabel> contactLabels,
) {
  final lastMessageDate = _parseGraphUtc(overview.lastMessageAtUtc);
  final firstMessageDate = _parseGraphUtc(overview.firstMessageAtUtc);
  final participantLabels = _resolveGraphParticipantLabels(
    overview.participantHandles,
    contactLabels,
  );
  return RecentChatSummary(
    chatId: overview.conversationId,
    title: _deriveGraphTitle(
      isGroup: overview.isGroup,
      participants: participantLabels,
    ),
    messageCount: overview.messageCount,
    attachmentCount: overview.attachmentCount,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
    isGroup: overview.isGroup,
    participants: participantLabels.isEmpty
        ? const ['Unknown Contact']
        : participantLabels,
    handles: overview.participantHandles,
    recency: lastMessageDate == null
        ? null
        : ChatRecency.fromDateTime(lastMessageDate),
    timelineData: null,
    calendarHeatmapTimelineData: null,
    lastMessagePreview: overview.lastMessageText,
  );
}

List<String> _resolveGraphParticipantLabels(
  List<String> handles,
  Map<String, ContactHandleLabel> contactLabels,
) => resolveContactHandleDisplayNames(handles, contactLabels);

String _deriveGraphTitle({
  required bool isGroup,
  required List<String> participants,
}) {
  if (participants.isEmpty) {
    return 'Unnamed Conversation';
  }
  if (!isGroup || participants.length == 1) {
    return participants.first;
  }
  if (participants.length == 2) {
    return '${participants[0]} and ${participants[1]}';
  }
  return '${participants[0]}, ${participants[1]} + ${participants.length - 2} more';
}

DateTime? _parseGraphUtc(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
