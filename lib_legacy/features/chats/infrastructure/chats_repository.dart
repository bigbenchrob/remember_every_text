import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../lib/essentials/databases/feature_level_providers.dart';
import '../domain/entities/chat_with_latest_message.dart';

part 'chats_repository.g.dart';

/// Repository for all chat-related database operations
/// Infrastructure layer - handles data access and database queries
@riverpod
ChatsRepository chatsRepository(ChatsRepositoryRef ref) {
  return ChatsRepository._(ref);
}

class ChatsRepository {
  const ChatsRepository._(this._ref);

  final ChatsRepositoryRef _ref;

  /// Get chats ordered by latest message timestamp
  Future<List<ChatWithLatestMessage>> getChatsByLatestMessage({
    int? limit,
    int? offset,
  }) async {
    final db = await _ref.read(workingDatabaseProvider.future);

    // Let's try without the message_count restriction to see if there are any chats at all
    const query = '''
      SELECT 
        ch.id as chat_id,
        ch.guid as chat_guid,
        ch.display_name as chat_display_name,
        ch.contact_id,
        ch.message_count,
        c.display_name as contact_display_name,
        m.id as latest_message_id,
        m.content as latest_message_content,
        COALESCE(m.timestamp, strftime('%s', 'now')) as latest_message_timestamp,
        COALESCE(m.is_from_me, 0) as latest_message_is_from_me,
        COALESCE(m.has_attachments, 0) as latest_message_has_attachments,
        '' as participant_names,
        0 as is_group_chat
      FROM chats ch
      LEFT JOIN contacts c ON ch.contact_id = c.id
      LEFT JOIN messages m ON ch.id = m.chat_id
      GROUP BY ch.id
      HAVING m.timestamp = (
        SELECT MAX(m2.timestamp) 
        FROM messages m2 
        WHERE m2.chat_id = ch.id
      ) OR m.timestamp IS NULL
      ORDER BY COALESCE(m.timestamp, 0) DESC
    ''';

    final limitClause = limit != null ? ' LIMIT $limit' : '';
    final offsetClause = offset != null ? ' OFFSET $offset' : '';
    final finalQuery = query + limitClause + offsetClause;

    final result = await db.customSelect(finalQuery).get();

    return result.map(_mapRowToChatWithLatestMessage).toList();
  }

  /// Get a single chat by ID with latest message info
  Future<ChatWithLatestMessage?> getChatById(int chatId) async {
    final chats = await getChatsByLatestMessage();
    try {
      return chats.firstWhere((chat) => chat.chatId == chatId);
    } catch (e) {
      return null;
    }
  }

  /// Get chats for a specific contact
  Future<List<ChatWithLatestMessage>> getChatsForContact(int contactId) async {
    final db = await _ref.read(workingDatabaseProvider.future);

    final query =
        '''
      WITH latest_messages AS (
        SELECT 
          m.chat_id,
          m.id as message_id,
          m.content,
          m.timestamp,
          m.is_from_me,
          m.has_attachments,
          ROW_NUMBER() OVER (PARTITION BY m.chat_id ORDER BY m.timestamp DESC) as rn
        FROM messages m
      ),
      chat_participants AS (
        SELECT 
          cp.chat_id,
          GROUP_CONCAT(COALESCE(participant_contact.display_name, h.address)) as participant_names,
          COUNT(*) as participant_count
        FROM chat_participants cp
        LEFT JOIN handles h ON cp.handle_id = h.id
        LEFT JOIN contacts participant_contact ON h.contact_id = participant_contact.id
        GROUP BY cp.chat_id
      )
      SELECT 
        ch.id as chat_id,
        ch.guid as chat_guid,
        ch.display_name as chat_display_name,
        ch.contact_id,
        chat_contact.display_name as contact_display_name,
        ch.message_count,
        lm.message_id as latest_message_id,
        lm.content as latest_message_content,
        COALESCE(lm.timestamp, 0) as latest_message_timestamp,
        lm.is_from_me as latest_message_is_from_me,
        lm.has_attachments as latest_message_has_attachments,
        COALESCE(cp.participant_names, chat_contact.display_name, '') as participant_names,
        CASE WHEN cp.participant_count > 2 THEN 1 ELSE 0 END as is_group_chat
      FROM chats ch
      LEFT JOIN latest_messages lm ON ch.id = lm.chat_id AND lm.rn = 1
      LEFT JOIN contacts chat_contact ON ch.contact_id = chat_contact.id
      LEFT JOIN chat_participants cp ON ch.id = cp.chat_id
      WHERE ch.message_count > 0 AND ch.contact_id = $contactId
      ORDER BY COALESCE(lm.timestamp, 0) DESC
    ''';

    final result = await db.customSelect(query).get();

    return result.map(_mapRowToChatWithLatestMessage).toList();
  }

  /// Helper method to map database row to ChatWithLatestMessage
  ChatWithLatestMessage _mapRowToChatWithLatestMessage(QueryRow row) {
    final participantNamesStr = row.data['participant_names'] as String? ?? '';
    final participantNames = participantNamesStr.isEmpty
        ? <String>[]
        : participantNamesStr
              .split(',')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toList();

    return ChatWithLatestMessage(
      chatId: row.data['chat_id'] as int,
      chatGuid: row.data['chat_guid'] as String,
      chatDisplayName: row.data['chat_display_name'] as String?,
      contactId: row.data['contact_id'] as int?,
      contactDisplayName: row.data['contact_display_name'] as String?,
      messageCount: row.data['message_count'] as int,
      latestMessageId: row.data['latest_message_id'] as int?,
      latestMessageContent: row.data['latest_message_content'] as String?,
      latestMessageTimestamp: row.data['latest_message_timestamp'] as int,
      latestMessageIsFromMe: _intToBool(row.data['latest_message_is_from_me']),
      latestMessageHasAttachments: _intToBool(
        row.data['latest_message_has_attachments'],
      ),
      participantNames: participantNames,
      isGroupChat: (row.data['is_group_chat'] as int) > 0,
    );
  }

  /// Helper method to convert SQLite integer (0/1) to nullable bool
  bool? _intToBool(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value != 0;
    }
    if (value is bool) {
      return value;
    }
    return null;
  }
}
