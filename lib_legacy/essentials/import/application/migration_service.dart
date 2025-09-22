import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/util/date_converter.dart';
import '../../databases/feature_level_providers.dart';
import '../../databases/infrastructure/data_sources/local/working/drift_db.dart';
import 'debug_settings_provider.dart';

part 'migration_service.g.dart';

/// Progress callback for migration operations
typedef MigrationProgressCallback =
    void Function(
      String stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    });

/// Migration service that moves data from import database to working database
/// This properly uses the existing contact linking from import_contact_handles
@riverpod
DataMigrationService dataMigrationService(DataMigrationServiceRef ref) {
  return DataMigrationService._(ref);
}

class DataMigrationService {
  const DataMigrationService._(this._ref);

  final DataMigrationServiceRef _ref;

  /// Migrate all data from import database to working database
  Future<MigrationResult> migrateAllData({
    MigrationProgressCallback? onProgress,
  }) async {
    final result = MigrationResult();
    final debugSettings = _ref.read(importDebugSettingsProvider);

    void reportProgress(
      String stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    }) {
      onProgress?.call(
        stage,
        progress,
        message,
        stageProgress: stageProgress,
        stageCurrent: stageCurrent,
        stageTotal: stageTotal,
      );
    }

    try {
      reportProgress('preparingMigration', 0.0, 'Preparing migration...');

      // Get database instances
      final workingDb = await _ref.read(workingDatabaseProvider.future);
      final importDb = _ref.read(importDatabaseProvider);
      final importDatabase = await importDb.database;

      // Get current timestamp for import tracking
      final now = DateTime.now().millisecondsSinceEpoch;

      debugSettings.logDatabase('Starting data migration process...');

      // Clear existing data from working database
      reportProgress('clearingData', 0.05, 'Clearing existing data...');
      await _clearWorkingDatabase(workingDb);
      debugSettings.logDatabase('Cleared existing working database data');

      // Step 1: Migrate contacts (maps import contact ID -> working contact ID)
      reportProgress('migratingContacts', 0.1, 'Migrating contacts...');
      final contactIdMap = await _migrateContacts(
        importDatabase,
        workingDb,
        now,
        result,
        reportProgress,
      );

      // Step 2: Migrate handles (maps import handle ID -> working handle ID)
      reportProgress('migratingHandles', 0.2, 'Migrating handles...');
      final handleIdMap = await _migrateHandles(
        importDatabase,
        workingDb,
        contactIdMap,
        now,
        result,
        reportProgress,
      );

      // Step 3: Migrate chats with proper contact linking
      reportProgress('migratingChats', 0.4, 'Migrating chats...');
      final chatIdMap = await _migrateChats(
        importDatabase,
        workingDb,
        contactIdMap,
        now,
        result,
        reportProgress,
      );

      // Step 4: Migrate messages with proper timestamp conversion
      reportProgress('migratingMessages', 0.6, 'Migrating messages...');
      await _migrateMessages(
        importDatabase,
        workingDb,
        chatIdMap,
        handleIdMap,
        now,
        result,
        reportProgress,
      );

      // Step 5: Update chat message counts and dates
      reportProgress('updatingChatCounts', 0.9, 'Updating chat counts...');
      await _updateChatMessageCounts(workingDb);

      reportProgress('completed', 1.0, 'Migration completed successfully!');
      result.success = true;
      debugSettings.logDatabase('Data migration completed successfully');
    } catch (e, stackTrace) {
      debugSettings.logError('Migration failed: $e');
      debugSettings.logError('Stack trace: $stackTrace');
      result.error = e.toString();
      result.success = false;
    }

    return result;
  }

  /// Clear all data from working database
  Future<void> _clearWorkingDatabase(DriftDb workingDb) async {
    await workingDb.transaction(() async {
      await workingDb.delete(workingDb.attachments).go();
      await workingDb.delete(workingDb.messages).go();
      await workingDb.delete(workingDb.chatParticipants).go();
      await workingDb.delete(workingDb.chats).go();
      await workingDb.delete(workingDb.handles).go();
      await workingDb.delete(workingDb.contacts).go();
    });
  }

  /// Migrate contacts - straightforward ID mapping
  Future<Map<int, int>> _migrateContacts(
    Database importDb,
    DriftDb workingDb,
    int now,
    MigrationResult result,
    MigrationProgressCallback reportProgress,
  ) async {
    final contactIdMap = <int, int>{};

    final importContacts = await importDb.query('import_contacts');
    if (importContacts.isEmpty) {
      return contactIdMap;
    }

    for (var i = 0; i < importContacts.length; i++) {
      final contact = importContacts[i];
      final importId = contact['id'] as int;

      // Create display name from available fields
      final firstName = contact['first'] as String? ?? '';
      final lastName = contact['last'] as String? ?? '';
      final company = contact['company'] as String? ?? '';
      final nickname = contact['nickname'] as String? ?? '';

      String displayName = '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        displayName = '$firstName $lastName'.trim();
      } else if (company.isNotEmpty) {
        displayName = company;
      } else if (nickname.isNotEmpty) {
        displayName = nickname;
      } else {
        displayName = 'Contact $importId';
      }

      final newId = await workingDb
          .into(workingDb.contacts)
          .insert(
            ContactsCompanion.insert(
              displayName: displayName,
              firstSeen: Value(now),
              lastSeen: Value(now),
              importSourceId: Value(importId),
              importLastSyncedAt: Value(now),
            ),
          );

      contactIdMap[importId] = newId;

      if ((i + 1) % 10 == 0 || i == importContacts.length - 1) {
        final progress = (i + 1) / importContacts.length;
        reportProgress(
          'migratingContacts',
          0.1,
          'Migrating contacts... (${i + 1}/${importContacts.length})',
          stageProgress: progress,
          stageCurrent: i + 1,
          stageTotal: importContacts.length,
        );
      }
    }

    result.contactsImported = importContacts.length;
    return contactIdMap;
  }

  /// Migrate handles and link them to contacts using import_contact_handles
  Future<Map<int, int>> _migrateHandles(
    Database importDb,
    DriftDb workingDb,
    Map<int, int> contactIdMap,
    int now,
    MigrationResult result,
    MigrationProgressCallback reportProgress,
  ) async {
    final handleIdMap = <int, int>{};

    final importHandles = await importDb.query('import_handles');
    if (importHandles.isEmpty) {
      return handleIdMap;
    }

    for (var i = 0; i < importHandles.length; i++) {
      final handle = importHandles[i];
      final importId = handle['id'] as int;
      final contactIdStr = handle['contact_id'] as String? ?? '';
      final service = handle['service'] as String? ?? 'unknown';

      // Look for contact linkage using import_contact_handles table
      int? workingContactId;
      final contactLinks = await importDb.query(
        'import_contact_handles',
        where: 'handle_id = ?',
        whereArgs: [importId],
      );

      if (contactLinks.isNotEmpty) {
        final importContactId = contactLinks.first['contact_id'] as int?;
        if (importContactId != null &&
            contactIdMap.containsKey(importContactId)) {
          workingContactId = contactIdMap[importContactId];
        }
      }

      // Use contactIdStr as the address (phone number or email)
      final address = contactIdStr.isNotEmpty
          ? contactIdStr
          : 'handle_$importId';

      try {
        final newId = await workingDb
            .into(workingDb.handles)
            .insert(
              HandlesCompanion.insert(
                contactId: Value(workingContactId),
                address: address,
                service: service,
                importSourceId: Value(importId),
              ),
            );

        handleIdMap[importId] = newId;
      } catch (e) {
        result.warnings.add('Failed to migrate handle $importId: $e');
      }

      if ((i + 1) % 50 == 0 || i == importHandles.length - 1) {
        final progress = (i + 1) / importHandles.length;
        reportProgress(
          'migratingHandles',
          0.2,
          'Migrating handles... (${i + 1}/${importHandles.length})',
          stageProgress: progress,
          stageCurrent: i + 1,
          stageTotal: importHandles.length,
        );
      }
    }

    result.handlesImported = importHandles.length;
    return handleIdMap;
  }

  /// Migrate chats and set display names using contact information
  Future<Map<int, int>> _migrateChats(
    Database importDb,
    DriftDb workingDb,
    Map<int, int> contactIdMap,
    int now,
    MigrationResult result,
    MigrationProgressCallback reportProgress,
  ) async {
    final chatIdMap = <int, int>{};

    final importChats = await importDb.query('import_chats');
    if (importChats.isEmpty) {
      return chatIdMap;
    }

    for (var i = 0; i < importChats.length; i++) {
      final chat = importChats[i];
      final importId = chat['id'] as int;
      final guid = chat['guid'] as String? ?? 'chat_$importId';
      final displayName = chat['display_name'] as String?;

      // Find the best contact and display name for this chat
      int? contactId;
      String? bestDisplayName = displayName;

      try {
        // Get handles for this chat
        final chatHandleJoins = await importDb.query(
          'import_chat_handle_join',
          where: 'chat_id = ?',
          whereArgs: [importId],
        );

        if (chatHandleJoins.isNotEmpty) {
          // Look for the first handle that has a contact link
          for (final join in chatHandleJoins) {
            final handleId = join['handle_id'] as int?;
            if (handleId != null) {
              // Check import_contact_handles for this handle
              final contactLinks = await importDb.query(
                'import_contact_handles',
                where: 'handle_id = ?',
                whereArgs: [handleId],
              );

              if (contactLinks.isNotEmpty) {
                final importContactId =
                    contactLinks.first['contact_id'] as int?;
                if (importContactId != null &&
                    contactIdMap.containsKey(importContactId)) {
                  contactId = contactIdMap[importContactId];

                  // Get the contact's display name
                  final contactInfo = await importDb.query(
                    'import_contacts',
                    where: 'id = ?',
                    whereArgs: [importContactId],
                  );

                  if (contactInfo.isNotEmpty) {
                    final contact = contactInfo.first;
                    final firstName = contact['first'] as String? ?? '';
                    final lastName = contact['last'] as String? ?? '';
                    final company = contact['company'] as String? ?? '';
                    final nickname = contact['nickname'] as String? ?? '';

                    if (firstName.isNotEmpty || lastName.isNotEmpty) {
                      bestDisplayName = '$firstName $lastName'.trim();
                    } else if (company.isNotEmpty) {
                      bestDisplayName = company;
                    } else if (nickname.isNotEmpty) {
                      bestDisplayName = nickname;
                    }
                  }
                  break; // Use the first contact found
                }
              }
            }
          }

          // If no contact found, use handle address as fallback
          if (bestDisplayName == null || bestDisplayName.isEmpty) {
            final handleId = chatHandleJoins.first['handle_id'] as int?;
            if (handleId != null) {
              final handleInfo = await importDb.query(
                'import_handles',
                where: 'id = ?',
                whereArgs: [handleId],
              );
              if (handleInfo.isNotEmpty) {
                final contactIdStr =
                    handleInfo.first['contact_id'] as String? ?? '';
                bestDisplayName = contactIdStr.isNotEmpty
                    ? contactIdStr
                    : 'Chat $importId';
              }
            }
          }
        }
      } catch (e) {
        // Ignore errors finding contact
      }

      // Final fallback
      if (bestDisplayName == null || bestDisplayName.isEmpty) {
        bestDisplayName = 'Chat $importId';
      }

      try {
        final newId = await workingDb
            .into(workingDb.chats)
            .insert(
              ChatsCompanion.insert(
                contactId: Value(contactId),
                guid: guid,
                displayName: Value(bestDisplayName),
                startDate: Value(now),
                importSourceId: Value(importId),
                importLastSyncedAt: Value(now),
              ),
            );

        chatIdMap[importId] = newId;
      } catch (e) {
        result.warnings.add('Failed to migrate chat $importId: $e');
      }

      if ((i + 1) % 50 == 0 || i == importChats.length - 1) {
        final progress = (i + 1) / importChats.length;
        reportProgress(
          'migratingChats',
          0.4,
          'Migrating chats... (${i + 1}/${importChats.length})',
          stageProgress: progress,
          stageCurrent: i + 1,
          stageTotal: importChats.length,
        );
      }
    }

    result.chatsImported = importChats.length;
    return chatIdMap;
  }

  /// Migrate messages with proper Apple timestamp conversion
  Future<void> _migrateMessages(
    Database importDb,
    DriftDb workingDb,
    Map<int, int> chatIdMap,
    Map<int, int> handleIdMap,
    int now,
    MigrationResult result,
    MigrationProgressCallback reportProgress,
  ) async {
    final importMessages = await importDb.query('import_messages');
    if (importMessages.isEmpty) {
      return;
    }

    // Get chat message join data to link messages to chats
    final chatMessageJoins = await importDb.query('import_chat_message_join');
    final messageToChatMap = <int, int>{};
    for (final join in chatMessageJoins) {
      final messageId = join['message_id'] as int;
      final chatId = join['chat_id'] as int;
      messageToChatMap[messageId] = chatId;
    }

    var migratedCount = 0;
    for (var i = 0; i < importMessages.length; i++) {
      final message = importMessages[i];
      final importId = message['id'] as int;
      final importChatId = messageToChatMap[importId];

      if (importChatId == null || !chatIdMap.containsKey(importChatId)) {
        // Skip messages without valid chat mapping
        continue;
      }

      final workingChatId = chatIdMap[importChatId]!;
      final handleId = message['handle_id'] as int?;
      final workingHandleId = handleId != null ? handleIdMap[handleId] : null;
      final text = message['text'] as String? ?? '';
      final date = message['date'] as int? ?? 0;
      final isFromMe = (message['is_from_me'] as int? ?? 0) == 1;

      // Convert Apple nanoseconds to Unix seconds using DateConverter
      int timestamp;
      if (date > 0) {
        timestamp = DateConverter.apple2Unix(date);
      } else {
        timestamp = (now / 1000).round();
      }

      try {
        await workingDb
            .into(workingDb.messages)
            .insert(
              MessagesCompanion.insert(
                chatId: workingChatId,
                senderHandleId: Value(workingHandleId),
                timestamp: timestamp,
                content: Value(text.isEmpty ? null : text),
                isFromMe: Value(isFromMe),
                importSourceId: Value(importId),
                importLastSyncedAt: Value(now),
              ),
            );

        migratedCount++;
      } catch (e) {
        result.warnings.add('Failed to migrate message $importId: $e');
      }

      if ((i + 1) % 1000 == 0 || i == importMessages.length - 1) {
        final progress = (i + 1) / importMessages.length;
        reportProgress(
          'migratingMessages',
          0.6,
          'Migrating messages... ($migratedCount/${importMessages.length})',
          stageProgress: progress,
          stageCurrent: i + 1,
          stageTotal: importMessages.length,
        );
      }
    }

    result.messagesImported = migratedCount;
  }

  /// Update message counts and end dates for all chats
  Future<void> _updateChatMessageCounts(DriftDb workingDb) async {
    await workingDb.customStatement('''
      UPDATE chats 
      SET message_count = (
        SELECT COUNT(*) 
        FROM messages 
        WHERE messages.chat_id = chats.id
      ),
      end_date = (
        SELECT MAX(timestamp) 
        FROM messages 
        WHERE messages.chat_id = chats.id
      )
    ''');
  }
}

/// Result of migration operation
class MigrationResult {
  bool success = false;
  String? error;
  List<String> warnings = [];

  int contactsImported = 0;
  int handlesImported = 0;
  int chatsImported = 0;
  int messagesImported = 0;

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'error': error,
      'warnings': warnings,
      'contactsImported': contactsImported,
      'handlesImported': handlesImported,
      'chatsImported': chatsImported,
      'messagesImported': messagesImported,
    };
  }
}
