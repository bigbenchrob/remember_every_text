import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../domain/ports/import_database_port.dart';
import '../domain/ports/message_extractor_port.dart';
import 'debug_settings_provider.dart';

/// Progress callback type for reporting import stages
/// - stage: The current import stage name
/// - progress: Overall progress (0.0 to 1.0)
/// - message: Status message for the user
/// - stageProgress: Optional sub-progress within the current stage (0.0 to 1.0)
/// - stageCurrent: Optional current item being processed (e.g., message 1500)
/// - stageTotal: Optional total items to process (e.g., 5000 messages)
typedef ProgressCallback =
    void Function(
      String stage,
      double progress,
      String message, {
      double? stageProgress,
      int? stageCurrent,
      int? stageTotal,
    });

/// Instrumentation callback for fine-grained timing of subtasks inside stages
/// - stage: parent stage key (matches ImportStage.name)
/// - subtask: descriptive subtask label
/// - event: 'start' | 'end'
/// - itemCount: optional count processed (reported on 'end')
typedef InstrumentCallback =
    void Function(String stage, String subtask, String event, {int? itemCount});

/// Service to import data from macOS Messages (chat.db) and AddressBook databases
class ImportService {
  static const String _messagesDbPath = '/Users/rob/Library/Messages/chat.db';
  // Allow test/builds to reduce extractor workload: flutter test --dart-define=RUST_EXTRACT_LIMIT=10000
  static const int _rustExtractLimit = int.fromEnvironment(
    'RUST_EXTRACT_LIMIT',
    defaultValue: 200000,
  );

  final ImportDatabasePort _importDb;
  final MessageExtractorPort _extractor;
  final ImportDebugSettingsState _debugSettings;

  ImportService({
    required ImportDatabasePort importDb,
    required MessageExtractorPort extractor,
    required ImportDebugSettingsState debugSettings,
  }) : _importDb = importDb,
       _extractor = extractor,
       _debugSettings = debugSettings;

  /// Whether the configured extractor adapter is available in this environment.
  /// This allows callers (including tests) to probe capabilities without
  /// importing concrete infrastructure classes.
  Future<bool> isExtractorAvailable() => _extractor.isAvailable();

  /// Get the correct AddressBook database path
  Future<String?> _getAddressBookDbPath() async {
    try {
      // Use the correct active AddressBook database path (contains 109 contacts)
      // Based on CRITICAL_ADDRESSBOOK_PATH_RESOLUTION.md - this is the active database
      const directPath =
          '/Users/rob/Library/Application Support/AddressBook/Sources/9A4E34C0-AB9D-4BB4-A1E2-53FF53475A40/AddressBook-v22.abcddb';
      final file = File(directPath);
      if (file.existsSync()) {
        return directPath;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Import all data from both Messages and AddressBook databases
  Future<ImportResult> importAllData({
    ProgressCallback? onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    final result = ImportResult();

    // Helper to report progress
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
      reportProgress('clearingData', 0.0, 'Clearing previous import data...');
      onInstrument?.call('clearingData', 'clearExistingData', 'start');

      // Record import start time
      _debugSettings.logDatabase(
        'ImportService: About to access import database for setMetadata',
      );
      await _importDb.setMetadata(
        key: 'import_started_at',
        value: DateTime.now().toIso8601String(),
      );
      _debugSettings.logDatabase(
        'ImportService: Successfully set metadata in import database',
      );

      // Clear existing data first
      _debugSettings.logDatabase(
        'ImportService: About to clear all data from import database',
      );
      await _importDb.clearAllData();
      _debugSettings.logDatabase(
        'ImportService: Successfully cleared import database',
      );
      onInstrument?.call('clearingData', 'clearExistingData', 'end');

      reportProgress(
        'importingHandles',
        0.1,
        'Starting Messages database import...',
      );

      // Import Messages data
      if (await _messagesDbExists()) {
        await _importMessagesData(
          result,
          onProgress: reportProgress,
          onInstrument: onInstrument,
        );
      } else {
        result.warnings.add('Messages database not found at $_messagesDbPath');
      }

      reportProgress(
        'importingAddressBook',
        0.8,
        'Starting AddressBook import...',
      );

      // Import AddressBook data
      if (await _addressBookDbExists()) {
        await _importAddressBookData(
          result,
          onProgress: reportProgress,
          onInstrument: onInstrument,
        );
      } else {
        result.warnings.add('AddressBook database not found');
      }

      reportProgress(
        'linkingContacts',
        0.95,
        'Linking contacts with handles...',
        stageProgress: 0.0,
      );

      // Link contacts with handles with granular progress
      await _linkContactsWithHandles(
        result,
        onProgress: reportProgress,
        onInstrument: onInstrument,
      );

      // Completion event for linking stage now emitted inside method (ensures last incremental update flushes first)

      reportProgress(
        'completed',
        1.0,
        'Import completed successfully',
        stageProgress: 1.0,
      );

      // Record completion time
      await _importDb.setMetadata(
        key: 'import_completed_at',
        value: DateTime.now().toIso8601String(),
      );

      result.success = true;
    } catch (e) {
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  Future<bool> _messagesDbExists() async => File(_messagesDbPath).existsSync();

  Future<bool> _addressBookDbExists() async {
    final path = await _getAddressBookDbPath();
    if (path == null) {
      return false;
    }
    return File(path).existsSync();
  }

  Future<void> _importMessagesData(
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    _debugSettings.logDatabase(
      'Attempting to open Messages database at: $_messagesDbPath',
    );

    try {
      final messagesDb = await openDatabase(_messagesDbPath, readOnly: true);
      _debugSettings.logDatabase('Successfully opened Messages database');

      try {
        onProgress('importingHandles', 0.1, 'Importing message handles...');
        onInstrument?.call('importingHandles', 'handles', 'start');
        await _importHandles(messagesDb, result);
        onInstrument?.call(
          'importingHandles',
          'handles',
          'end',
          itemCount: result.handlesImported,
        );

        onProgress('importingChats', 0.25, 'Importing chat conversations...');
        onInstrument?.call('importingChats', 'chats', 'start');
        await _importChats(messagesDb, result);
        onInstrument?.call(
          'importingChats',
          'chats',
          'end',
          itemCount: result.chatsImported,
        );

        onProgress(
          'importingChatHandleJoins',
          0.35,
          'Linking chats to participants...',
        );
        onInstrument?.call(
          'importingChatHandleJoins',
          'chatHandleJoins',
          'start',
        );
        await _importChatHandleJoins(messagesDb, result);
        onInstrument?.call(
          'importingChatHandleJoins',
          'chatHandleJoins',
          'end',
          itemCount: result.chatHandleJoinsImported,
        );

        onProgress('analyzingMessages', 0.42, 'Analyzing message rows...');
        await _importMessages(
          messagesDb,
          result,
          onProgress: onProgress,
          onInstrument: onInstrument,
        );

        onProgress(
          'importingAttachments',
          0.7,
          'Importing message attachments...',
        );
        await _importAttachments(
          messagesDb,
          result,
          onProgress: onProgress,
          onInstrument: onInstrument,
        );
        await _importChatMessageJoins(
          messagesDb,
          result,
          onProgress: onProgress,
          onInstrument: onInstrument,
        );
        await _importMessageAttachmentJoins(
          messagesDb,
          result,
          onProgress: onProgress,
          onInstrument: onInstrument,
        );
      } finally {
        _debugSettings.logDatabase('Closing Messages database');
        await messagesDb.close();
        _debugSettings.logDatabase('Messages database closed successfully');
      }
    } catch (e) {
      _debugSettings.logError('ERROR opening Messages database: $e');
      _debugSettings.logError('Error type: ${e.runtimeType}');
      if (e.toString().contains('authorization denied')) {
        _debugSettings.logError(
          'This is the authorization denied error for Messages database!',
        );
      }
      rethrow;
    }
  }

  Future<void> _importHandles(Database messagesDb, ImportResult result) async {
    try {
      final handles = await messagesDb.query('handle');
      for (final handle in handles) {
        await _importDb.insertHandle(
          id: handle['ROWID'] as int? ?? -1,
          contactId: handle['id'] as String?,
          service: handle['service'] as String?,
        );
      }
      result.handlesImported = handles.length;
    } catch (e) {
      result.warnings.add('Failed to import handles: $e');
    }
  }

  Future<void> _importChats(Database messagesDb, ImportResult result) async {
    try {
      final chats = await messagesDb.query('chat');
      for (final chat in chats) {
        await _importDb.insertChat(
          id: chat['ROWID'] as int? ?? -1,
          guid: chat['guid'] as String?,
          chatIdentifier: chat['chat_identifier'] as String?,
          serviceName: chat['service_name'] as String?,
          displayName: chat['display_name'] as String?,
        );
      }
      result.chatsImported = chats.length;
    } catch (e) {
      result.warnings.add('Failed to import chats: $e');
    }
  }

  Future<void> _importChatHandleJoins(
    Database messagesDb,
    ImportResult result,
  ) async {
    try {
      final joins = await messagesDb.query('chat_handle_join');
      for (final join in joins) {
        await _importDb.insertChatHandleJoin(
          chatId: join['chat_id'] as int? ?? -1,
          handleId: join['handle_id'] as int? ?? -1,
        );
      }
      result.chatHandleJoinsImported = joins.length;
    } catch (e) {
      result.warnings.add('Failed to import chat-handle joins: $e');
    }
  }

  Future<void> _importMessages(
    Database messagesDb,
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    try {
      final messages = await messagesDb.query('message');
      final totalMessages = messages.length;

      onProgress(
        'analyzingMessages',
        0.42,
        'Analyzing $totalMessages messages...',
        stageProgress: 0.0,
        stageCurrent: 0,
        stageTotal: totalMessages,
      );

      final blobMessages = <String, Map<String, dynamic>>{};
      final blobData = <String, List<int>>{};
      final directTextMessages = <Map<String, dynamic>>[];

      // Analyze messages and categorize them
      onInstrument?.call('analyzingMessages', 'analysis', 'start');
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        final messageId = message['ROWID']!.toString();
        final messageText = message['text'] as String?;
        if ((messageText == null || messageText.isEmpty) &&
            message['attributedBody'] != null) {
          blobMessages[messageId] = message;
          blobData[messageId] =
              message['attributedBody'] as List<int>? ?? <int>[];
        } else {
          directTextMessages.add(message);
        }

        // Report analysis progress
        if (i % 1000 == 0 || i == messages.length - 1) {
          onProgress(
            'analyzingMessages',
            0.42,
            'Analyzing messages... (${i + 1}/$totalMessages)',
            stageProgress: (i + 1) / totalMessages, // 0->1 for analysis
            stageCurrent: i + 1,
            stageTotal: totalMessages,
          );
        }
      }
      onInstrument?.call(
        'analyzingMessages',
        'analysis',
        'end',
        itemCount: totalMessages,
      );

      final blobResults = <String, String?>{};
      if (blobData.isNotEmpty) {
        final extractorAvailable = await _extractor.isAvailable();
        if (!extractorAvailable) {
          _debugSettings.logError(
            'Rust extractor unavailable; skipping rich text extraction for ${blobData.length} messages.',
          );
          result.warnings.add(
            'Rust extractor unavailable; ${blobData.length} rich messages will be imported without extracted text.',
          );
          onProgress(
            'extractingRichContent',
            0.44,
            'Skipping rich text extraction; extractor unavailable.',
            stageProgress: 1.0,
            stageCurrent: 0,
            stageTotal: blobData.length,
          );
        } else {
          var rustExtractionStarted = false;
          var processResultsStarted = false;
          onInstrument?.call(
            'extractingRichContent',
            'rustExtraction',
            'start',
          );
          rustExtractionStarted = true;
          try {
            onProgress(
              'extractingRichContent',
              0.44,
              'Extracting ${blobData.length} rich messages using Rust...',
              stageProgress: 0.0,
              stageCurrent: 0,
              stageTotal: blobData.length,
            );

            final rustTextMap = await _extractor.extractAllMessageTexts(
              limit: _rustExtractLimit,
              dbPath: _messagesDbPath,
            );

            onInstrument?.call(
              'extractingRichContent',
              'processResults',
              'start',
            );
            processResultsStarted = true;
            onProgress(
              'extractingRichContent',
              0.45,
              'Processing extraction results...',
              stageProgress: 0.3,
              stageCurrent: 0,
              stageTotal: blobMessages.length,
            );

            var processedCount = 0;
            for (final entry in blobMessages.entries) {
              final messageId = entry.key;
              final messageRowId = int.parse(messageId);
              final extractedText = rustTextMap[messageRowId];
              blobResults[messageId] = extractedText;

              processedCount++;
              if (processedCount % 100 == 0 ||
                  processedCount == blobMessages.length) {
                onProgress(
                  'extractingRichContent',
                  0.45,
                  'Processing extraction results... ($processedCount/${blobMessages.length})',
                  stageProgress:
                      0.3 + (processedCount / blobMessages.length * 0.5),
                  stageCurrent: processedCount,
                  stageTotal: blobMessages.length,
                );
              }
            }
          } catch (e) {
            _debugSettings.logError(
              'Rust extractor failed: $e. Falling back to raw message bodies.',
            );
            result.warnings.add(
              'Rich text extraction failed; continuing without extracted text: $e',
            );
            onProgress(
              'extractingRichContent',
              0.45,
              'Rich text extraction failed; continuing without extracted text.',
              stageProgress: 1.0,
              stageCurrent: 0,
              stageTotal: blobData.length,
            );
          } finally {
            if (processResultsStarted) {
              onInstrument?.call(
                'extractingRichContent',
                'processResults',
                'end',
                itemCount: blobMessages.length,
              );
            }
            if (rustExtractionStarted) {
              onInstrument?.call(
                'extractingRichContent',
                'rustExtraction',
                'end',
                itemCount: blobData.length,
              );
            }
          }
        }
      }

      // Import direct text messages
      onProgress(
        'importingMessages',
        0.46,
        'Importing ${directTextMessages.length} text messages...',
        stageProgress: 0.0,
        stageCurrent: 0,
        stageTotal: directTextMessages.length,
      );
      onInstrument?.call('importingMessages', 'importTextMessages', 'start');

      for (var i = 0; i < directTextMessages.length; i++) {
        final message = directTextMessages[i];
        final messageText = message['text'] as String?;
        await _insertSingleMessage(message, messageText);

        if (i % 200 == 0 || i == directTextMessages.length - 1) {
          onProgress(
            'importingMessages',
            0.46,
            'Importing text messages... (${i + 1}/${directTextMessages.length})',
            stageProgress: (i + 1) / directTextMessages.length * 0.3,
            stageCurrent: i + 1,
            stageTotal: directTextMessages.length,
          );
        }
      }
      onInstrument?.call(
        'importingMessages',
        'importTextMessages',
        'end',
        itemCount: directTextMessages.length,
      );

      // Import blob messages with extracted content
      onProgress(
        'importingMessages',
        0.5,
        'Importing ${blobMessages.length} rich messages...',
        stageProgress: 0.3,
        stageCurrent: 0,
        stageTotal: blobMessages.length,
      );
      onInstrument?.call('importingMessages', 'importRichMessages', 'start');

      var importedBlobCount = 0;
      for (final entry in blobMessages.entries) {
        final messageId = entry.key;
        final message = entry.value;
        final extractedText = blobResults[messageId];
        await _insertSingleMessage(message, extractedText);

        importedBlobCount++;
        if (importedBlobCount % 200 == 0 ||
            importedBlobCount == blobMessages.length) {
          onProgress(
            'importingMessages',
            0.5,
            'Importing rich messages... ($importedBlobCount/${blobMessages.length})',
            stageProgress:
                0.3 + (importedBlobCount / blobMessages.length * 0.6),
            stageCurrent: importedBlobCount,
            stageTotal: blobMessages.length,
          );
        }
      }
      onInstrument?.call(
        'importingMessages',
        'importRichMessages',
        'end',
        itemCount: blobMessages.length,
      );

      result.messagesImported = messages.length;

      onProgress(
        'importingMessages',
        0.55,
        'Completed message import',
        stageProgress: 1.0,
        stageCurrent: totalMessages,
        stageTotal: totalMessages,
      );
      onInstrument?.call('importingMessages', 'finalizeImport', 'start');
      onInstrument?.call('importingMessages', 'finalizeImport', 'end');

      if (blobData.isNotEmpty) {
        result.warnings.add(
          'Processed ${blobData.length} BLOB messages: ${blobResults.values.where((v) => v != null && v.isNotEmpty).length} successful, ${blobResults.values.where((v) => v == null || v.isEmpty).length} failed',
        );
      }
    } catch (e) {
      result.warnings.add('Failed to import messages: $e');
    }
  }

  Future<void> _insertSingleMessage(
    Map<String, dynamic> message,
    String? messageText,
  ) async {
    await _importDb.insertMessage(
      id: message['ROWID'] as int? ?? -1,
      handleId: message['handle_id'] as int?,
      text: messageText,
      date: message['date'] as int?,
      isFromMe: message['is_from_me'] as int?,
      service: message['service'] as String?,
      subject: message['subject'] as String?,
      cacheRoomnames: message['cache_roomnames'] as String?,
      error: message['error'] as int?,
      dateRead: message['date_read'] as int?,
      dateDelivered: message['date_delivered'] as int?,
    );
  }

  Future<void> _importAttachments(
    Database messagesDb,
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    try {
      final attachments = await messagesDb.query('attachment');
      final totalAttachments = attachments.length;

      onProgress(
        'importingAttachments',
        0.7,
        'Found $totalAttachments attachments to import...',
        stageProgress: 0.0, // 0.0 -> 0.8 reserved for raw attachment inserts
        stageCurrent: 0,
        stageTotal: totalAttachments,
      );

      onInstrument?.call('importingAttachments', 'rawAttachments', 'start');
      for (var i = 0; i < attachments.length; i++) {
        final attachment = attachments[i];
        await _importDb.insertAttachment(
          id: attachment['ROWID'] as int? ?? -1,
          guid: attachment['guid'] as String?,
          filename: attachment['filename'] as String?,
          mimeType: attachment['mime_type'] as String?,
          totalBytes: attachment['total_bytes'] as int?,
          isSticker: attachment['is_sticker'] as int?,
          transferState: attachment['transfer_state'] as int?,
        );

        // Report progress every 50 attachments or on the last one
        if (i % 50 == 0 || i == attachments.length - 1) {
          final fraction = (i + 1) / totalAttachments; // 0..1
          final stageProg = fraction * 0.8; // map to 0.0 -> 0.8
          onProgress(
            'importingAttachments',
            0.7,
            'Importing attachments... (${i + 1}/$totalAttachments)',
            stageProgress: stageProg,
            stageCurrent: i + 1,
            stageTotal: totalAttachments,
          );
        }
      }
      onInstrument?.call(
        'importingAttachments',
        'rawAttachments',
        'end',
        itemCount: attachments.length,
      );

      result.attachmentsImported = attachments.length;
      // Do not mark complete yet; progress now 0.8 (raw attachments done). Linking joins advances to 1.0
      onProgress(
        'importingAttachments',
        0.7,
        'Imported $totalAttachments attachments; linking to chats...',
        stageProgress: 0.8,
        stageCurrent: totalAttachments,
        stageTotal: totalAttachments,
      );
    } catch (e) {
      result.warnings.add('Failed to import attachments: $e');
    }
  }

  Future<void> _importChatMessageJoins(
    Database messagesDb,
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    try {
      final joins = await messagesDb.query('chat_message_join');
      final total = joins.length;
      if (total == 0) {
        onProgress(
          'importingAttachments',
          0.72,
          'No chat-message joins to process',
          stageProgress: 0.85,
        );
      }
      var processed = 0;
      onInstrument?.call('importingAttachments', 'chatMessageJoins', 'start');
      for (final join in joins) {
        await _importDb.insertChatMessageJoin(
          chatId: join['chat_id'] as int? ?? -1,
          messageId: join['message_id'] as int? ?? -1,
        );
        processed++;
        if (processed % 500 == 0 || processed == total) {
          final stageProg = 0.8 + (processed / total) * 0.1; // 0.8 -> 0.9
          onProgress(
            'importingAttachments',
            0.72,
            'Linking chat-message joins... ($processed/$total)',
            stageProgress: stageProg,
            stageCurrent: processed,
            stageTotal: total,
          );
          await Future(() {});
        }
      }
      result.chatMessageJoinsImported = total;
      onInstrument?.call(
        'importingAttachments',
        'chatMessageJoins',
        'end',
        itemCount: total,
      );
    } catch (e) {
      result.warnings.add('Failed to import chat-message joins: $e');
    }
  }

  Future<void> _importMessageAttachmentJoins(
    Database messagesDb,
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    try {
      final joins = await messagesDb.query('message_attachment_join');
      final total = joins.length;
      if (total == 0) {
        onProgress(
          'importingAttachments',
          0.74,
          'No message-attachment joins to process',
          stageProgress: 0.9,
        );
      }
      var processed = 0;
      onInstrument?.call(
        'importingAttachments',
        'messageAttachmentJoins',
        'start',
      );
      for (final join in joins) {
        await _importDb.insertMessageAttachmentJoin(
          messageId: join['message_id'] as int? ?? -1,
          attachmentId: join['attachment_id'] as int? ?? -1,
        );
        processed++;
        if (processed % 500 == 0 || processed == total) {
          final stageProg = 0.9 + (processed / total) * 0.1; // 0.9 -> 1.0
          onProgress(
            'importingAttachments',
            0.74,
            'Linking message-attachment joins... ($processed/$total)',
            stageProgress: stageProg,
            stageCurrent: processed,
            stageTotal: total,
          );
          await Future(() {});
        }
      }
      result.messageAttachmentJoinsImported = total;
      onInstrument?.call(
        'importingAttachments',
        'messageAttachmentJoins',
        'end',
        itemCount: total,
      );
      // Final completion of attachments stage
      onProgress(
        'importingAttachments',
        0.78,
        'Completed attachments & join linking',
        stageProgress: 1.0,
      );
      onInstrument?.call(
        'importingAttachments',
        'finalizeAttachments',
        'start',
      );
      onInstrument?.call('importingAttachments', 'finalizeAttachments', 'end');
    } catch (e) {
      result.warnings.add('Failed to import message-attachment joins: $e');
    }
  }

  Future<void> _importAddressBookData(
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    onProgress(
      'importingAddressBook',
      0.8,
      'Locating AddressBook database...',
      stageProgress: 0.0,
    );
    final addressBookPath = await _getAddressBookDbPath();
    if (addressBookPath == null) {
      result.warnings.add('AddressBook database path not found');
      return;
    }

    final addressBookDb = await openDatabase(addressBookPath, readOnly: true);
    try {
      onProgress(
        'importingAddressBook',
        0.82,
        'Validating AddressBook database...',
        stageProgress: 0.2,
      );
      // Validate that this AddressBook database has a reasonable number of contacts
      onInstrument?.call('importingAddressBook', 'validateDb', 'start');
      await _validateAddressBookDatabase(addressBookDb, addressBookPath);
      onInstrument?.call('importingAddressBook', 'validateDb', 'end');

      // We'll treat AddressBook import as composed of four sub-phases (contacts, emails, phones, images)
      // and advance stageProgress accordingly while overall progress moves toward 0.93 (reserving space for linking).
      const overallStart = 0.85; // after validation
      const overallEnd = 0.93; // before linkingContacts begins at 0.95
      double phaseFraction(int phaseIndex, int totalPhases) =>
          phaseIndex / totalPhases;
      const totalPhases = 4;

      // Phase 1: Contacts
      onProgress(
        'importingAddressBook',
        overallStart,
        'Importing contacts...',
        stageProgress: 0.55,
      );
      onInstrument?.call('importingAddressBook', 'contacts', 'start');
      await _importContacts(addressBookDb, result);
      onInstrument?.call(
        'importingAddressBook',
        'contacts',
        'end',
        itemCount: result.contactsImported,
      );
      onProgress(
        'importingAddressBook',
        overallStart +
            (overallEnd - overallStart) * phaseFraction(1, totalPhases),
        'Imported contacts; importing emails...',
        stageProgress: 0.65,
      );

      // Phase 2: Emails
      onInstrument?.call('importingAddressBook', 'emails', 'start');
      await _importContactEmails(addressBookDb, result);
      onInstrument?.call(
        'importingAddressBook',
        'emails',
        'end',
        itemCount: result.contactEmailsImported,
      );
      onProgress(
        'importingAddressBook',
        overallStart +
            (overallEnd - overallStart) * phaseFraction(2, totalPhases),
        'Imported emails; importing phone numbers...',
        stageProgress: 0.75,
      );

      // Phase 3: Phones
      onInstrument?.call('importingAddressBook', 'phones', 'start');
      await _importContactPhones(addressBookDb, result);
      onInstrument?.call(
        'importingAddressBook',
        'phones',
        'end',
        itemCount: result.contactPhonesImported,
      );
      onProgress(
        'importingAddressBook',
        overallStart +
            (overallEnd - overallStart) * phaseFraction(3, totalPhases),
        'Imported phone numbers; importing images...',
        stageProgress: 0.85,
      );

      // Phase 4: Images
      onInstrument?.call('importingAddressBook', 'images', 'start');
      await _importContactImages(addressBookDb, result);
      onInstrument?.call(
        'importingAddressBook',
        'images',
        'end',
        itemCount: result.contactImagesImported,
      );
      onProgress(
        'importingAddressBook',
        overallEnd,
        'AddressBook data import completed',
        stageProgress: 1.0,
      );
      onInstrument?.call(
        'importingAddressBook',
        'finalizeAddressBook',
        'start',
      );
      onInstrument?.call('importingAddressBook', 'finalizeAddressBook', 'end');
    } finally {
      await addressBookDb.close();
    }
  }

  /// Validate that the AddressBook database contains a reasonable number of contacts
  Future<int> _validateAddressBookDatabase(Database db, String path) async {
    final result = await db.query('ZABCDRECORD');
    final contactCount = result.length;

    if (contactCount < 1) {
      throw Exception(
        'AddressBook database validation failed: Found only $contactCount contacts. '
        'This appears to be an inactive/dummy database. Expected at least 1 contacts. '
        'Path: $path',
      );
    }

    return contactCount;
  }

  Future<void> _importContacts(
    Database addressBookDb,
    ImportResult result,
  ) async {
    try {
      final contacts = await addressBookDb.query('ZABCDRECORD');
      for (final contact in contacts) {
        await _importDb.insertContact(
          id: contact['Z_PK'] as int? ?? -1,
          first: contact['ZFIRSTNAME'] as String?,
          last: contact['ZLASTNAME'] as String?,
          company: contact['ZORGANIZATION'] as String?,
          nickname: contact['ZNICKNAME'] as String?,
        );
      }
      result.contactsImported = contacts.length;
    } catch (e) {
      result.warnings.add('Failed to import contacts: $e');
    }
  }

  Future<void> _importContactEmails(
    Database addressBookDb,
    ImportResult result,
  ) async {
    try {
      final emails = await addressBookDb.query('ZABCDEMAILADDRESS');
      for (final email in emails) {
        await _importDb.insertContactEmail(
          id: email['Z_PK'] as int? ?? -1,
          contactId: email['ZOWNER'] as int? ?? -1,
          email: email['ZADDRESS'] as String? ?? 'Unknown',
          label: email['ZLABEL'] as String?,
        );
      }
      result.contactEmailsImported = emails.length;
    } catch (e) {
      result.warnings.add('Failed to import contact emails: $e');
    }
  }

  Future<void> _importContactPhones(
    Database addressBookDb,
    ImportResult result,
  ) async {
    try {
      final phones = await addressBookDb.query('ZABCDPHONENUMBER');
      for (final phone in phones) {
        await _importDb.insertContactPhone(
          id: phone['Z_PK'] as int? ?? -1,
          contactId: phone['ZOWNER'] as int? ?? -1,
          phone: phone['ZFULLNUMBER'] as String? ?? 'Unknown',
          label: phone['ZLABEL'] as String?,
        );
      }
      result.contactPhonesImported = phones.length;
    } catch (e) {
      result.warnings.add('Failed to import contact phones: $e');
    }
  }

  Future<void> _importContactImages(
    Database addressBookDb,
    ImportResult result,
  ) async {
    try {
      final images = await addressBookDb.query(
        'ZABCDRECORD',
        where: 'ZIMAGEDATA IS NOT NULL',
      );
      for (final image in images) {
        final contactId = image['Z_PK'] as int? ?? -1;
        final imageData = image['ZIMAGEDATA'] as Uint8List?;
        if (imageData != null) {
          await _importDb.insertContactImage(
            contactId: contactId,
            imageData: imageData,
          );
        }
      }
      result.contactImagesImported = images.length;
    } catch (e) {
      result.warnings.add('Failed to import contact images: $e');
    }
  }

  Future<void> _linkContactsWithHandles(
    ImportResult result, {
    required ProgressCallback onProgress,
    InstrumentCallback? onInstrument,
  }) async {
    try {
      final handles = await _importDb.getAllHandles();
      final total = handles.length;
      var processed = 0;
      var linksCreated = 0;

      // Early exit if no handles
      if (total == 0) {
        onProgress(
          'linkingContacts',
          0.97,
          'No handles to link',
          stageProgress: 1.0,
          stageCurrent: 0,
          stageTotal: 0,
        );
        return;
      }

      // Determine emission interval (aim for ~30-60 updates)
      final interval = (total / 50).clamp(10, 50).toInt(); // dynamic interval
      onInstrument?.call('linkingContacts', 'linkingScan', 'start');
      for (final handle in handles) {
        processed++;
        final contactId = handle['contact_id'] as String?;
        if (contactId != null) {
          final matchingContact = await _findMatchingContact(contactId);
          if (matchingContact != null) {
            await _importDb.insertContactHandle(
              handleId: handle['id'] as int,
              contactId: matchingContact,
              contactMethod: contactId,
            );
            linksCreated++;
          }
        }

        // Emit progress every 'interval' items or on last item
        if (processed % interval == 0 || processed == total) {
          final stageProg = processed / total;
          // Overall progress: move from 0.95 toward 0.99 gradually
          final overall = 0.95 + (stageProg * 0.04); // 0.95 -> 0.99
          onProgress(
            'linkingContacts',
            overall.clamp(0.0, 0.999),
            'Linking contacts with handles... ($processed/$total)',
            stageProgress: stageProg,
            stageCurrent: processed,
            stageTotal: total,
          );
          // Yield to event loop to allow UI rebuild (micro-delay only in debug scenarios)
          await Future(() {});
        }
      }

      result.contactHandleLinksCreated = linksCreated;
      onInstrument?.call(
        'linkingContacts',
        'linkingScan',
        'end',
        itemCount: processed,
      );

      // Final completion event (overall progress remains <1.0 until completed stage fired)
      onProgress(
        'linkingContacts',
        0.995,
        'Contact linking completed ($linksCreated links)',
        stageProgress: 1.0,
        stageCurrent: total,
        stageTotal: total,
      );
      onInstrument?.call('linkingContacts', 'finalizeLinking', 'start');
      onInstrument?.call('linkingContacts', 'finalizeLinking', 'end');

      // Now emit completed stage separately to smooth transition
      onProgress(
        'completed',
        1.0,
        'Import completed successfully',
        stageProgress: 1.0,
      );
    } catch (e) {
      result.warnings.add('Failed to link contacts with handles: $e');
    }
  }

  Future<int?> _findMatchingContact(String contactIdentifier) async {
    // Try email match first
    final byEmail = await _importDb.findContactIdByEmail(contactIdentifier);
    if (byEmail != null) {
      return byEmail;
    }

    // Then try normalized US phone match (strip +1 and punctuation)
    final normalizedIdentifier = _normalizePhoneNumber(contactIdentifier);
    if (normalizedIdentifier != null) {
      return _importDb.findContactIdByNormalizedPhone(normalizedIdentifier);
    }
    return null;
  }

  String? _normalizePhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('1') && digits.length == 11) {
      return digits.substring(1);
    }
    return digits.isNotEmpty ? digits : null;
  }

  Future<Map<String, dynamic>> getImportStats() async {
    final stats = await _importDb.getDatabaseStats();
    final metadata = <String, String?>{};
    final metadataKeys = ['import_started_at', 'import_completed_at'];
    for (final key in metadataKeys) {
      metadata[key] = await _importDb.getMetadata(key);
    }
    return {'table_counts': stats, 'metadata': metadata};
  }
}

class ImportResult {
  bool success = false;
  String? error;
  List<String> warnings = [];

  int handlesImported = 0;
  int chatsImported = 0;
  int chatHandleJoinsImported = 0;
  int messagesImported = 0;
  int attachmentsImported = 0;
  int chatMessageJoinsImported = 0;
  int messageAttachmentJoinsImported = 0;
  int contactsImported = 0;
  int contactEmailsImported = 0;
  int contactPhonesImported = 0;
  int contactImagesImported = 0;
  int contactHandleLinksCreated = 0;

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'error': error,
      'warnings': warnings,
      'handles_imported': handlesImported,
      'chats_imported': chatsImported,
      'chat_handle_joins_imported': chatHandleJoinsImported,
      'messages_imported': messagesImported,
      'attachments_imported': attachmentsImported,
      'chat_message_joins_imported': chatMessageJoinsImported,
      'message_attachment_joins_imported': messageAttachmentJoinsImported,
      'contacts_imported': contactsImported,
      'contact_emails_imported': contactEmailsImported,
      'contact_phones_imported': contactPhonesImported,
      'contact_images_imported': contactImagesImported,
      'contact_handle_links_created': contactHandleLinksCreated,
    };
  }
}
