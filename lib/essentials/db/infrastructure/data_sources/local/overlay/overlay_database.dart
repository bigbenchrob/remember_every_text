import 'package:drift/drift.dart';

part 'overlay_database.g.dart';

/// Overlay database for user preferences and customizations (user_overlays.db).
/// This database stores user-specific overrides that enhance the working database
/// without polluting it with UI-specific state.
@DriftDatabase(tables: [ParticipantOverrides, ChatOverrides])
class OverlayDatabase extends _$OverlayDatabase {
  OverlayDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );

  // Helper methods for participant overrides

  /// Get all short names as a map (contact key -> short name)
  Future<Map<String, String>> getAllShortNamesByKey() async {
    final overrides = await select(participantOverrides).get();
    return {
      for (final override in overrides)
        if (override.shortName != null)
          'participant:${override.participantId}': override.shortName!,
    };
  }

  /// Set short name for a participant
  Future<void> setParticipantShortName(
    int participantId,
    String? shortName,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(participantOverrides).insertOnConflictUpdate(
      ParticipantOverridesCompanion.insert(
        participantId: Value(participantId),
        shortName: Value(shortName),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete participant override
  Future<void> deleteParticipantOverride(int participantId) async {
    await (delete(
      participantOverrides,
    )..where((tbl) => tbl.participantId.equals(participantId))).go();
  }

  // Helper methods for chat overrides

  /// Get override for a specific chat
  Future<ChatOverride?> getChatOverride(int chatId) {
    return (select(
      chatOverrides,
    )..where((tbl) => tbl.chatId.equals(chatId))).getSingleOrNull();
  }

  /// Set custom name for a chat
  Future<void> setChatCustomName(int chatId, String? customName) async {
    final now = DateTime.now().toUtc().toIso8601String();

    await into(chatOverrides).insertOnConflictUpdate(
      ChatOverridesCompanion.insert(
        chatId: Value(chatId),
        customName: Value(customName),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
  }

  /// Delete chat override
  Future<void> deleteChatOverride(int chatId) async {
    await (delete(
      chatOverrides,
    )..where((tbl) => tbl.chatId.equals(chatId))).go();
  }
}

/// User-defined short names and preferences for participants
class ParticipantOverrides extends Table {
  @override
  String get tableName => 'participant_overrides';

  /// Matches working.participants.id
  IntColumn get participantId => integer().named('participant_id')();

  /// User's custom short name for this participant
  TextColumn get shortName => text().named('short_name').nullable()();

  /// Whether user has muted this participant
  BoolColumn get isMuted =>
      boolean().named('is_muted').withDefault(const Constant(false))();

  /// User's custom notes about this participant
  TextColumn get notes => text().named('notes').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {participantId};
}

/// User preferences for specific chats
class ChatOverrides extends Table {
  @override
  String get tableName => 'chat_overrides';

  /// Matches working.chats.id
  IntColumn get chatId => integer().named('chat_id')();

  /// User's custom name for this chat (overrides derived title)
  TextColumn get customName => text().named('custom_name').nullable()();

  /// User's custom color/theme for this chat
  TextColumn get customColor => text().named('custom_color').nullable()();

  /// User's notes about this chat
  TextColumn get notes => text().named('notes').nullable()();

  TextColumn get createdAtUtc => text().named('created_at_utc')();
  TextColumn get updatedAtUtc => text().named('updated_at_utc')();

  @override
  Set<Column> get primaryKey => {chatId};
}
