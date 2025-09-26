import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../../import/application/debug_settings_provider.dart';
import '../../../../../import/domain/ports/import_database_port.dart';

/// Centralized import database schema (prefixed with import_* tables).
class ImportDatabase implements ImportDatabasePort {
  static const int _databaseVersion = 1;
  static const String _databaseDirectory =
      '/Users/rob/sqlite_rmc/remember_every_text/';

  final String _databaseName;
  final ImportDebugSettingsState _debugSettings;
  Database? _database;

  /// Creates an ImportDatabase instance with the specified database name.
  ImportDatabase({
    required String databaseName,
    required ImportDebugSettingsState debugSettings,
  }) : _databaseName = databaseName,
       _debugSettings = debugSettings;

  Future<Database> get database async {
    if (_database != null) {
      _debugSettings.logDatabase(
        'ImportDatabase.database: Returning existing database instance for $_databaseName',
      );
      return _database!;
    }
    _debugSettings.logDatabase(
      'ImportDatabase.database: Creating new database instance for $_databaseName',
    );
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(_databaseDirectory, _databaseName);
    _debugSettings.logDatabase(
      'ImportDatabase._initDatabase: Attempting to open import database at: $path',
    );

    final dataDir = Directory(_databaseDirectory);
    if (!dataDir.existsSync()) {
      _debugSettings.logDatabase(
        'ImportDatabase._initDatabase: Creating directory: $_databaseDirectory',
      );
      await dataDir.create(recursive: true);
    }

    try {
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      _debugSettings.logDatabase(
        'ImportDatabase._initDatabase: Successfully opened import database at: $path',
      );
      return db;
    } catch (e) {
      _debugSettings.logError(
        'ImportDatabase._initDatabase: ERROR opening import database at: $path',
      );
      _debugSettings.logError('Error: $e');
      _debugSettings.logError('Error type: ${e.runtimeType}');
      if (e.toString().contains('authorization denied')) {
        _debugSettings.logError(
          'This is the authorization denied error for Import database!',
        );
      }
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createChatTables(db);
    await _createContactTables(db);
    await _createMetadataTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  static Future<void> _createChatTables(Database db) async {
    await db.execute('''
			CREATE TABLE import_handles (
				id INTEGER PRIMARY KEY,
				contact_id TEXT,
				service TEXT
			)
		''');

    await db.execute('''
			CREATE TABLE import_chats (
				id INTEGER PRIMARY KEY,
				guid TEXT,
				chat_identifier TEXT,
				service_name TEXT,
				display_name TEXT
			)
		''');

    await db.execute('''
			CREATE TABLE import_chat_handle_join (
				chat_id INTEGER,
				handle_id INTEGER,
				PRIMARY KEY (chat_id, handle_id),
				FOREIGN KEY (chat_id) REFERENCES import_chats(id),
				FOREIGN KEY (handle_id) REFERENCES import_handles(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_messages (
				id INTEGER PRIMARY KEY,
				handle_id INTEGER,
				text TEXT,
				date INTEGER,
				is_from_me INTEGER,
				service TEXT,
				subject TEXT,
				cache_roomnames TEXT,
				error INTEGER,
				date_read INTEGER,
				date_delivered INTEGER,
				FOREIGN KEY (handle_id) REFERENCES import_handles(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_chat_message_join (
				chat_id INTEGER,
				message_id INTEGER,
				PRIMARY KEY (chat_id, message_id),
				FOREIGN KEY (chat_id) REFERENCES import_chats(id),
				FOREIGN KEY (message_id) REFERENCES import_messages(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_attachments (
				id INTEGER PRIMARY KEY,
				guid TEXT,
				filename TEXT,
				mime_type TEXT,
				total_bytes INTEGER,
				is_sticker INTEGER,
				transfer_state INTEGER
			)
		''');

    await db.execute('''
			CREATE TABLE import_message_attachment_join (
				message_id INTEGER,
				attachment_id INTEGER,
				PRIMARY KEY (message_id, attachment_id),
				FOREIGN KEY (message_id) REFERENCES import_messages(id),
				FOREIGN KEY (attachment_id) REFERENCES import_attachments(id)
			)
		''');
  }

  static Future<void> _createContactTables(Database db) async {
    await db.execute('''
			CREATE TABLE import_contacts (
				id INTEGER PRIMARY KEY,
				first TEXT,
				last TEXT,
				company TEXT,
				nickname TEXT
			)
		''');

    await db.execute('''
			CREATE TABLE import_contact_emails (
				id INTEGER PRIMARY KEY,
				contact_id INTEGER,
				email TEXT,
				label TEXT,
				FOREIGN KEY (contact_id) REFERENCES import_contacts(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_contact_phones (
				id INTEGER PRIMARY KEY,
				contact_id INTEGER,
				phone TEXT,
				label TEXT,
				FOREIGN KEY (contact_id) REFERENCES import_contacts(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_contact_images (
				contact_id INTEGER PRIMARY KEY,
				image_data BLOB,
				FOREIGN KEY (contact_id) REFERENCES import_contacts(id)
			)
		''');

    await db.execute('''
			CREATE TABLE import_contact_handles (
				handle_id INTEGER PRIMARY KEY,
				contact_id INTEGER,
				contact_method TEXT,
				FOREIGN KEY (handle_id) REFERENCES import_handles(id),
				FOREIGN KEY (contact_id) REFERENCES import_contacts(id)
			)
		''');
  }

  static Future<void> _createMetadataTables(Database db) async {
    await db.execute('''
			CREATE TABLE import_metadata (
				key TEXT PRIMARY KEY,
				value TEXT
			)
		''');
  }

  @override
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('import_message_attachment_join');
      await txn.delete('import_chat_message_join');
      await txn.delete('import_contact_handles');
      await txn.delete('import_attachments');
      await txn.delete('import_messages');
      await txn.delete('import_chats');
      await txn.delete('import_handles');
      await txn.delete('import_contact_images');
      await txn.delete('import_contact_phones');
      await txn.delete('import_contact_emails');
      await txn.delete('import_contacts');
      await txn.delete('import_metadata');
    });
  }

  @override
  Future<int> insertHandle({
    required int id,
    String? contactId,
    String? service,
  }) async {
    final db = await database;
    return db.insert('import_handles', {
      'id': id,
      'contact_id': contactId,
      'service': service,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertChat({
    required int id,
    String? guid,
    String? chatIdentifier,
    String? serviceName,
    String? displayName,
  }) async {
    final db = await database;
    return db.insert('import_chats', {
      'id': id,
      'guid': guid,
      'chat_identifier': chatIdentifier,
      'service_name': serviceName,
      'display_name': displayName,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertChatHandleJoin({
    required int chatId,
    required int handleId,
  }) async {
    final db = await database;
    return db.insert('import_chat_handle_join', {
      'chat_id': chatId,
      'handle_id': handleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertMessage({
    required int id,
    int? handleId,
    String? text,
    int? date,
    int? isFromMe,
    String? service,
    String? subject,
    String? cacheRoomnames,
    int? error,
    int? dateRead,
    int? dateDelivered,
  }) async {
    final db = await database;
    return db.insert('import_messages', {
      'id': id,
      'handle_id': handleId,
      'text': text,
      'date': date,
      'is_from_me': isFromMe,
      'service': service,
      'subject': subject,
      'cache_roomnames': cacheRoomnames,
      'error': error,
      'date_read': dateRead,
      'date_delivered': dateDelivered,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateMessageText(int messageId, String text) async {
    final db = await database;
    await db.update(
      'import_messages',
      {'text': text},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  @override
  Future<int> insertContact({
    required int id,
    String? first,
    String? last,
    String? company,
    String? nickname,
  }) async {
    final db = await database;
    return db.insert('import_contacts', {
      'id': id,
      'first': first,
      'last': last,
      'company': company,
      'nickname': nickname,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertContactEmail({
    required int id,
    required int contactId,
    required String email,
    String? label,
  }) async {
    final db = await database;
    return db.insert('import_contact_emails', {
      'id': id,
      'contact_id': contactId,
      'email': email,
      'label': label,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertContactPhone({
    required int id,
    required int contactId,
    required String phone,
    String? label,
  }) async {
    final db = await database;
    return db.insert('import_contact_phones', {
      'id': id,
      'contact_id': contactId,
      'phone': phone,
      'label': label,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertAttachment({
    required int id,
    String? guid,
    String? filename,
    String? mimeType,
    int? totalBytes,
    int? isSticker,
    int? transferState,
  }) async {
    final db = await database;
    return db.insert('import_attachments', {
      'id': id,
      'guid': guid,
      'filename': filename,
      'mime_type': mimeType,
      'total_bytes': totalBytes,
      'is_sticker': isSticker,
      'transfer_state': transferState,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertChatMessageJoin({
    required int chatId,
    required int messageId,
  }) async {
    final db = await database;
    return db.insert('import_chat_message_join', {
      'chat_id': chatId,
      'message_id': messageId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> insertMessageAttachmentJoin({
    required int messageId,
    required int attachmentId,
  }) async {
    final db = await database;
    return db.insert(
      'import_message_attachment_join',
      {'message_id': messageId, 'attachment_id': attachmentId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> insertContactHandle({
    required int handleId,
    required int contactId,
    required String contactMethod,
  }) async {
    final db = await database;
    return db.insert('import_contact_handles', {
      'handle_id': handleId,
      'contact_id': contactId,
      'contact_method': contactMethod,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> setMetadata({required String key, required String value}) async {
    final db = await database;
    return db.insert('import_metadata', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> getMetadata(String key) async {
    final db = await database;
    final result = await db.query(
      'import_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllHandles() async =>
      (await database).query('import_handles');
  Future<List<Map<String, dynamic>>> getAllChats() async =>
      (await database).query('import_chats');
  Future<List<Map<String, dynamic>>> getAllMessages() async =>
      (await database).query('import_messages');
  Future<List<Map<String, dynamic>>> getAllContacts() async =>
      (await database).query('import_contacts');

  Future<List<Map<String, dynamic>>> getMessagesForChat(int chatId) async {
    final db = await database;
    return db.rawQuery(
      '''
			SELECT m.* FROM import_messages m
			INNER JOIN import_chat_message_join cmj ON m.id = cmj.message_id
			WHERE cmj.chat_id = ?
			ORDER BY m.date ASC
		''',

      [chatId],
    );
  }

  Future<List<Map<String, dynamic>>> getAttachmentsForMessage(
    int messageId,
  ) async {
    final db = await database;
    return db.rawQuery(
      '''
			SELECT a.* FROM import_attachments a
			INNER JOIN import_message_attachment_join maj ON a.id = maj.attachment_id
			WHERE maj.message_id = ?
		''',
      [messageId],
    );
  }

  Future<Map<String, dynamic>?> getContactWithDetails(int contactId) async {
    final db = await database;
    final contactResult = await db.query(
      'import_contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
    if (contactResult.isEmpty) {
      return null;
    }
    final contact = Map<String, dynamic>.from(contactResult.first);
    final emails = await db.query(
      'import_contact_emails',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    final phones = await db.query(
      'import_contact_phones',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    contact['emails'] = emails;
    contact['phones'] = phones;
    return contact;
  }

  @override
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    final stats = <String, int>{};
    const tables = [
      'import_handles',
      'import_chats',
      'import_messages',
      'import_contacts',
      'import_contact_emails',
      'import_contact_phones',
      'import_attachments',
      'import_chat_message_join',
      'import_message_attachment_join',
      'import_contact_handles',
      'import_metadata',
    ];
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = result.first['count'] as int? ?? 0;
    }
    return stats;
  }

  @override
  Future<int> insertContactImage({
    required int contactId,
    required Uint8List imageData,
  }) async {
    final db = await database;
    return db.insert('import_contact_images', {
      'contact_id': contactId,
      'image_data': imageData,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int?> findContactIdByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'import_contact_emails',
      columns: ['contact_id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['contact_id'] as int?;
  }

  @override
  Future<int?> findContactIdByNormalizedPhone(String normalized10) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
			SELECT contact_id FROM import_contact_phones 
			WHERE REPLACE(REPLACE(REPLACE(REPLACE(phone, '+1', ''), '(', ''), ')', ''), '-', '') = ?
			LIMIT 1
			''',
      [normalized10],
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['contact_id'] as int?;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  String get databasePath => join(_databaseDirectory, _databaseName);

  Future<void> deleteDatabase() async {
    final path = join(_databaseDirectory, _databaseName);
    await close();
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
