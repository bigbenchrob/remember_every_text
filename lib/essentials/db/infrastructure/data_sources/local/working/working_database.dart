import 'package:drift/drift.dart';

part 'working_database.g.dart';

/// Drift projection database used by the application UI (working.db).
@DriftDatabase(
  tables: [
    WorkingSchemaMigrations,
    ProjectionState,
    AppSettings,
    WorkingIdentities,
    IdentityHandleLinks,
    WorkingChats,
    ChatParticipantsProj,
    WorkingMessages,
    WorkingAttachments,
    WorkingReactions,
    ReactionCounts,
    ReadState,
    MessageReadMarks,
    SupabaseSyncState,
    SupabaseSyncLogs,
  ],
)
class WorkingDatabase extends _$WorkingDatabase {
  WorkingDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
      await _createVirtualTablesAndTriggers();
      await _seedProjectionState();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await _ensureMessageReadMarksTable(m);
      }
      if (from < 3) {
        await m.addColumn(
          projectionState,
          projectionState.lastProjectedMessageId as GeneratedColumn,
        );
        await m.addColumn(
          projectionState,
          projectionState.lastProjectedAttachmentId as GeneratedColumn,
        );
      }
      if (from < 4) {
        await _removeChatNameColumns(m);
      }
      await _createIndexes();
      await _createVirtualTablesAndTriggers();
      await _seedProjectionState();
    },
  );

  Future<void> _createIndexes() async {
    for (final statement in _workingIndexStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _createVirtualTablesAndTriggers() async {
    for (final statement in _workingVirtualAndTriggerStatements) {
      await customStatement(statement);
    }
  }

  Future<void> _seedProjectionState() async {
    await customStatement('''
      INSERT OR IGNORE INTO projection_state (
        id, last_import_batch_id, last_projected_at_utc,
        last_projected_message_id, last_projected_attachment_id
      ) VALUES (1, NULL, NULL, NULL, NULL)
      ''');
  }

  Future<void> _ensureMessageReadMarksTable(Migrator migrator) async {
    final existing = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'message_read_marks'",
    ).getSingleOrNull();

    if (existing == null) {
      await migrator.createTable(messageReadMarks);
    }
  }

  Future<void> _removeChatNameColumns(Migrator migrator) async {
    await customStatement('DROP TABLE IF EXISTS chats_old');
    await customStatement('ALTER TABLE chats RENAME TO chats_old');
    await migrator.createTable(workingChats);
    await customStatement('''
      INSERT INTO chats (
        id,
        guid,
        service,
        is_group,
        last_message_at_utc,
        last_sender_identity_id,
        last_message_preview,
        unread_count,
        pinned,
        archived,
        muted_until_utc,
        favourite,
        created_at_utc,
        updated_at_utc
      )
      SELECT
        id,
        guid,
        service,
        is_group,
        last_message_at_utc,
        last_sender_identity_id,
        last_message_preview,
        unread_count,
        pinned,
        archived,
        muted_until_utc,
        favourite,
        created_at_utc,
        updated_at_utc
      FROM chats_old
    ''');
    await customStatement('DROP TABLE chats_old');
  }
}

const List<String> _workingIndexStatements = [
  'CREATE INDEX IF NOT EXISTS idx_chats_sort ON chats(pinned DESC, last_message_at_utc DESC)',
  'CREATE INDEX IF NOT EXISTS idx_chat_participants_proj_order ON chat_participants_proj(chat_id, sort_key)',
  'CREATE INDEX IF NOT EXISTS idx_messages_chat_time ON messages(chat_id, sent_at_utc)',
  'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_identity_id)',
  'CREATE INDEX IF NOT EXISTS idx_messages_reply ON messages(reply_to_guid)',
  'CREATE INDEX IF NOT EXISTS idx_attachments_msg ON attachments(message_guid)',
  'CREATE INDEX IF NOT EXISTS idx_reactions_target ON reactions(message_guid)',
];

const List<String> _workingVirtualAndTriggerStatements = [
  // FTS table
  '''
  CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
    guid UNINDEXED,
    chat_id UNINDEXED,
    text,
    tokenize='unicode61 remove_diacritics 2'
  )
  ''',
  // FTS triggers
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_insert
  AFTER INSERT ON messages BEGIN
    INSERT INTO messages_fts (rowid, guid, chat_id, text)
    VALUES (new.id, new.guid, new.chat_id, COALESCE(new.text,''));
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_update
  AFTER UPDATE OF text ON messages BEGIN
    UPDATE messages_fts SET text = COALESCE(new.text,'') WHERE rowid = new.id;
  END;
  ''',
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_fts_delete
  AFTER DELETE ON messages BEGIN
    DELETE FROM messages_fts WHERE rowid = old.id;
  END;
  ''',
  // Projection helper views
  '''
  CREATE VIEW IF NOT EXISTS v_chat_latest AS
  SELECT
    c.id           AS chat_id,
    c.guid         AS chat_guid,
    c.last_message_at_utc,
    c.unread_count,
    m.guid         AS last_message_guid,
    m.text         AS last_message_text,
    m.sender_identity_id
  FROM chats c
  LEFT JOIN messages m
    ON m.chat_id = c.id
   AND m.sent_at_utc = c.last_message_at_utc;
  ''',
  '''
  CREATE VIEW IF NOT EXISTS v_message_expanded AS
  SELECT
    m.guid,
    m.chat_id,
    m.sent_at_utc,
    m.text,
    m.is_from_me,
    i.display_name AS sender_name,
    rc.love, rc.like, rc.dislike, rc.laugh, rc.emphasize, rc.question
  FROM messages m
  LEFT JOIN identities i ON i.id = m.sender_identity_id
  LEFT JOIN reaction_counts rc ON rc.message_guid = m.guid;
  ''',
  // Reaction maintenance triggers
  '''
  CREATE TRIGGER IF NOT EXISTS trg_reactions_after_change
  AFTER INSERT ON reactions
  BEGIN
    INSERT INTO reaction_counts(message_guid, love, like, dislike, laugh, emphasize, question)
    VALUES (new.message_guid, 0,0,0,0,0,0)
    ON CONFLICT(message_guid) DO NOTHING;

    UPDATE reaction_counts
       SET
         love      = love      + CASE WHEN new.kind='love'      AND new.action='add' THEN 1 WHEN new.kind='love'      AND new.action='remove' THEN -1 ELSE 0 END,
         like      = like      + CASE WHEN new.kind='like'      AND new.action='add' THEN 1 WHEN new.kind='like'      AND new.action='remove' THEN -1 ELSE 0 END,
         dislike   = dislike   + CASE WHEN new.kind='dislike'   AND new.action='add' THEN 1 WHEN new.kind='dislike'   AND new.action='remove' THEN -1 ELSE 0 END,
         laugh     = laugh     + CASE WHEN new.kind='laugh'     AND new.action='add' THEN 1 WHEN new.kind='laugh'     AND new.action='remove' THEN -1 ELSE 0 END,
         emphasize = emphasize + CASE WHEN new.kind='emphasize' AND new.action='add' THEN 1 WHEN new.kind='emphasize' AND new.action='remove' THEN -1 ELSE 0 END,
         question  = question  + CASE WHEN new.kind='question'  AND new.action='add' THEN 1 WHEN new.kind='question'  AND new.action='remove' THEN -1 ELSE 0 END;

    UPDATE messages
       SET reaction_summary_json = (
         SELECT json_object(
           'love',      love,
           'like',      like,
           'dislike',   dislike,
           'laugh',     laugh,
           'emphasize', emphasize,
           'question',  question
         )
         FROM reaction_counts WHERE message_guid = NEW.message_guid
       ),
           updated_at_utc = strftime('%Y-%m-%dT%H:%M:%fZ','now')
     WHERE guid = NEW.message_guid;
  END;
  ''',
  // Message insert trigger for chat metadata and unread counts
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_after_insert
  AFTER INSERT ON messages
  BEGIN
    UPDATE chats
       SET last_message_at_utc = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc > last_message_at_utc
             THEN new.sent_at_utc ELSE last_message_at_utc END,
           last_sender_identity_id = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
             THEN new.sender_identity_id ELSE last_sender_identity_id END,
           last_message_preview = CASE
             WHEN last_message_at_utc IS NULL OR new.sent_at_utc >= last_message_at_utc
             THEN substr(COALESCE(new.text,''), 1, 120) ELSE last_message_preview END
     WHERE id = new.chat_id;

    UPDATE chats
       SET unread_count = unread_count + CASE
           WHEN new.is_from_me = 0 AND (new.read_at_utc IS NULL) THEN 1 ELSE 0 END
     WHERE id = new.chat_id;
  END;
  ''',
  // Message read trigger for unread decrement
  '''
  CREATE TRIGGER IF NOT EXISTS trg_messages_mark_read
  AFTER UPDATE OF read_at_utc ON messages
  WHEN new.read_at_utc IS NOT NULL AND old.read_at_utc IS NULL
  BEGIN
    UPDATE chats
       SET unread_count = MAX(unread_count - 1, 0)
     WHERE id = new.chat_id;
  END;
  ''',
];

class WorkingSchemaMigrations extends Table {
  @override
  String get tableName => 'schema_migrations';

  IntColumn get version => integer().named('version')();
  TextColumn get appliedAtUtc => text().named('applied_at_utc')();

  @override
  Set<Column> get primaryKey => {version};
}

/// Singleton table to track projection state. (Ensured to have only one row with id=1 by constraint)
class ProjectionState extends Table {
  @override
  String get tableName => 'projection_state';

  IntColumn get id => integer()
      .named('id')
      .clientDefault(() => 1)
      .customConstraint('NOT NULL CHECK(id=1)')(); // removed PRIMARY KEY here
  IntColumn get lastImportBatchId =>
      integer().named('last_import_batch_id').nullable()();
  TextColumn get lastProjectedAtUtc =>
      text().named('last_projected_at_utc').nullable()();
  IntColumn get lastProjectedMessageId =>
      integer().named('last_projected_message_id').nullable()();
  IntColumn get lastProjectedAttachmentId =>
      integer().named('last_projected_attachment_id').nullable()();

  @override
  Set<Column> get primaryKey => {id}; // single source of truth for PK
}

class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text().named('key')();
  TextColumn get value => text().named('value')();

  @override
  Set<Column> get primaryKey => {key};
}

class WorkingIdentities extends Table {
  @override
  String get tableName => 'identities';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get normalizedAddress =>
      text().named('normalized_address').nullable()();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
      )();
  TextColumn get displayName => text().named('display_name').nullable()();
  TextColumn get contactRef => text().named('contact_ref').nullable()();
  TextColumn get avatarRef => text().named('avatar_ref').nullable()();
  BoolColumn get isSystem =>
      boolean().named('is_system').withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {service, normalizedAddress},
  ];
}

class IdentityHandleLinks extends Table {
  @override
  String get tableName => 'identity_handle_links';

  IntColumn get identityId => integer()
      .named('identity_id')
      .references(WorkingIdentities, #id, onDelete: KeyAction.cascade)();
  IntColumn get importHandleId => integer().named('import_handle_id')();

  @override
  Set<Column> get primaryKey => {identityId, importHandleId};
}

class WorkingChats extends Table {
  @override
  String get tableName => 'chats';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get guid => text().named('guid')();
  TextColumn get service => text()
      .named('service')
      .customConstraint(
        "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))",
      )();
  BoolColumn get isGroup =>
      boolean().named('is_group').withDefault(const Constant(false))();
  TextColumn get lastMessageAtUtc =>
      text().named('last_message_at_utc').nullable()();
  IntColumn get lastSenderIdentityId => integer()
      .named('last_sender_identity_id')
      .nullable()
      .references(WorkingIdentities, #id, onDelete: KeyAction.setNull)();
  TextColumn get lastMessagePreview =>
      text().named('last_message_preview').nullable()();
  IntColumn get unreadCount =>
      integer().named('unread_count').withDefault(const Constant(0))();
  BoolColumn get pinned =>
      boolean().named('pinned').withDefault(const Constant(false))();
  BoolColumn get archived =>
      boolean().named('archived').withDefault(const Constant(false))();
  TextColumn get mutedUntilUtc => text().named('muted_until_utc').nullable()();
  BoolColumn get favourite =>
      boolean().named('favourite').withDefault(const Constant(false))();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

class ChatParticipantsProj extends Table {
  @override
  String get tableName => 'chat_participants_proj';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get identityId => integer()
      .named('identity_id')
      .references(WorkingIdentities, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()
      .named('role')
      .customConstraint(
        "NOT NULL DEFAULT 'member' CHECK(role IN ('member','owner','unknown'))",
      )();
  IntColumn get sortKey =>
      integer().named('sort_key').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {chatId, identityId};
}

class WorkingMessages extends Table {
  @override
  String get tableName => 'messages';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get guid => text().named('guid')();
  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  IntColumn get senderIdentityId => integer()
      .named('sender_identity_id')
      .nullable()
      .references(WorkingIdentities, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isFromMe =>
      boolean().named('is_from_me').withDefault(const Constant(false))();
  TextColumn get sentAtUtc => text().named('sent_at_utc').nullable()();
  TextColumn get deliveredAtUtc =>
      text().named('delivered_at_utc').nullable()();
  TextColumn get readAtUtc => text().named('read_at_utc').nullable()();
  TextColumn get status => text()
      .named('status')
      .customConstraint(
        "NOT NULL DEFAULT 'unknown' CHECK(status IN ('unknown','sent','delivered','read','failed'))",
      )();
  TextColumn get textContent => text().named('text').nullable()();
  BoolColumn get hasAttachments =>
      boolean().named('has_attachments').withDefault(const Constant(false))();
  TextColumn get replyToGuid => text().named('reply_to_guid').nullable()();
  TextColumn get systemType => text().named('system_type').nullable()();
  BoolColumn get reactionCarrier =>
      boolean().named('reaction_carrier').withDefault(const Constant(false))();
  TextColumn get balloonBundleId =>
      text().named('balloon_bundle_id').nullable()();
  TextColumn get reactionSummaryJson =>
      text().named('reaction_summary_json').nullable()();
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();
  BoolColumn get isDeletedLocal =>
      boolean().named('is_deleted_local').withDefault(const Constant(false))();
  TextColumn get updatedAtUtc => text().named('updated_at_utc').nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {guid},
  ];
}

class WorkingAttachments extends Table {
  @override
  String get tableName => 'attachments';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get messageGuid => text().named('message_guid')();
  IntColumn get importAttachmentId =>
      integer().named('import_attachment_id').nullable()();
  TextColumn get localPath => text().named('local_path').nullable()();
  TextColumn get mimeType => text().named('mime_type').nullable()();
  TextColumn get uti => text().named('uti').nullable()();
  TextColumn get transferName => text().named('transfer_name').nullable()();
  IntColumn get sizeBytes => integer().named('size_bytes').nullable()();
  BoolColumn get isSticker =>
      boolean().named('is_sticker').withDefault(const Constant(false))();
  TextColumn get thumbPath => text().named('thumb_path').nullable()();
  TextColumn get createdAtUtc => text().named('created_at_utc').nullable()();
}

class WorkingReactions extends Table {
  @override
  String get tableName => 'reactions';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get messageGuid => text().named('message_guid')();
  TextColumn get kind => text()
      .named('kind')
      .customConstraint(
        "NOT NULL CHECK(kind IN ('love','like','dislike','laugh','emphasize','question','unknown'))",
      )();
  IntColumn get reactorIdentityId => integer()
      .named('reactor_identity_id')
      .nullable()
      .references(WorkingIdentities, #id, onDelete: KeyAction.setNull)();
  TextColumn get action => text()
      .named('action')
      .customConstraint("NOT NULL CHECK(\"action\" IN ('add','remove'))")();
  TextColumn get reactedAtUtc => text().named('reacted_at_utc').nullable()();
}

class ReactionCounts extends Table {
  @override
  String get tableName => 'reaction_counts';

  TextColumn get messageGuid => text().named('message_guid')();
  IntColumn get love =>
      integer().named('love').withDefault(const Constant(0))();
  IntColumn get like =>
      integer().named('like').withDefault(const Constant(0))();
  IntColumn get dislike =>
      integer().named('dislike').withDefault(const Constant(0))();
  IntColumn get laugh =>
      integer().named('laugh').withDefault(const Constant(0))();
  IntColumn get emphasize =>
      integer().named('emphasize').withDefault(const Constant(0))();
  IntColumn get question =>
      integer().named('question').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {messageGuid};
}

class ReadState extends Table {
  @override
  String get tableName => 'read_state';

  IntColumn get chatId => integer()
      .named('chat_id')
      .references(WorkingChats, #id, onDelete: KeyAction.cascade)();
  TextColumn get lastReadAtUtc => text().named('last_read_at_utc').nullable()();

  @override
  Set<Column> get primaryKey => {chatId};
}

class MessageReadMarks extends Table {
  @override
  String get tableName => 'message_read_marks';

  TextColumn get messageGuid => text().named('message_guid')();
  TextColumn get markedAtUtc => text().named('marked_at_utc')();

  @override
  Set<Column> get primaryKey => {messageGuid};
}

class SupabaseSyncState extends Table {
  @override
  String get tableName => 'supabase_sync_state';

  IntColumn get id => integer().named('id').autoIncrement()();
  TextColumn get targetTable => text().named('target_table')();
  IntColumn get lastBatchId => integer().named('last_batch_id').nullable()();
  IntColumn get lastSyncedRowId =>
      integer().named('last_synced_row_id').nullable()();
  TextColumn get lastSyncedGuid =>
      text().named('last_synced_guid').nullable()();
  DateTimeColumn get lastSyncedAt =>
      dateTime().named('last_synced_at').nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {targetTable},
  ];
}

class SupabaseSyncLogs extends Table {
  @override
  String get tableName => 'supabase_sync_logs';

  IntColumn get id => integer().named('id').autoIncrement()();
  IntColumn get batchId => integer().named('batch_id').nullable()();
  TextColumn get targetTable => text().named('target_table').nullable()();
  TextColumn get status => text().named('status').nullable()();
  IntColumn get attempt =>
      integer().named('attempt').withDefault(const Constant(1))();
  TextColumn get requestId => text().named('request_id').nullable()();
  TextColumn get message => text().named('message').nullable()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
}
