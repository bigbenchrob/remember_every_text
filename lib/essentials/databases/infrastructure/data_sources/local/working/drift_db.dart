import 'package:drift/drift.dart';

part 'drift_db.g.dart';

@DriftDatabase(
  tables: [
    Contacts,
    Handles,
    Chats,
    ChatParticipants,
    Messages,
    Attachments,
    SupabaseSyncState,
    SupabaseSyncLogs,
  ],
)
class DriftDb extends _$DriftDb {
  DriftDb(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // Simple migration strategy: drop and recreate all tables on upgrade
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      await m.deleteTable('chat_participants');
      await m.deleteTable('attachments');
      await m.deleteTable('messages');
      await m.deleteTable('chats');
      await m.deleteTable('handles');
      await m.deleteTable('contacts');

      await m.createAll();
    },
    onCreate: (m) => m.createAll(),
  );
}

// ========== CONTACTS ==========
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text()();
  TextColumn get avatarPath => text().nullable()();
  IntColumn get firstSeen => integer().nullable()();
  IntColumn get lastSeen => integer().nullable()();
  IntColumn get totalMessages => integer().withDefault(const Constant(0))();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  IntColumn get importSourceId => integer().nullable()();
  IntColumn get importLastSyncedAt => integer().nullable()();
}

// ========== HANDLES ==========
class Handles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer().nullable().references(Contacts, #id)();
  TextColumn get address => text()();
  TextColumn get service => text()();
  IntColumn get importSourceId => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {address, service},
  ];
}

// ========== CHATS ==========
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer().nullable().references(Contacts, #id)();
  TextColumn get guid => text()();
  TextColumn get displayName => text().nullable()();
  IntColumn get startDate => integer().nullable()();
  IntColumn get endDate => integer().nullable()();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  IntColumn get importSourceId => integer().nullable()();
  IntColumn get importLastSyncedAt => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

// ========== CHAT PARTICIPANTS ==========
class ChatParticipants extends Table {
  IntColumn get chatId => integer().references(Chats, #id)();
  IntColumn get handleId => integer().references(Handles, #id)();

  @override
  Set<Column> get primaryKey => {chatId, handleId};
}

// ========== MESSAGES ==========
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer().references(Chats, #id)();
  IntColumn get senderHandleId =>
      integer().nullable().references(Handles, #id)();
  IntColumn get timestamp => integer()();
  TextColumn get content => text().nullable()();
  BoolColumn get isFromMe => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAttachments =>
      boolean().withDefault(const Constant(false))();
  IntColumn get quotedMessageId =>
      integer().nullable().references(Messages, #id)();
  IntColumn get importSourceId => integer().nullable()();
  IntColumn get importLastSyncedAt => integer().nullable()();
}

// ========== ATTACHMENTS ==========
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer().references(Messages, #id)();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get importSourceId => integer().nullable()();
  IntColumn get importLastSyncedAt => integer().nullable()();
}

// ========== SUPABASE SYNC STATE ==========
class SupabaseSyncState extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  IntColumn get lastBatchId => integer().nullable()();
  IntColumn get lastSyncedRowId => integer().nullable()();
  TextColumn get lastSyncedGuid => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {targetTable},
  ];
}

// ========== SUPABASE SYNC LOGS ==========
class SupabaseSyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get batchId => integer().nullable()();
  TextColumn get targetTable => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get attempt => integer().withDefault(const Constant(1))();
  TextColumn get requestId => text().nullable()();
  TextColumn get message => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
