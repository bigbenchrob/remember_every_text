import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db_importers/application/services/legacy_compatibility_maintenance_service.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';

void main() {
  group('LegacyCompatibilityMaintenanceService', () {
    test('runs incremental legacy migration after successful import', () async {
      final log = _LegacyCompatibilityLog();
      String? observedOwner;
      bool? observedForceFullReimport;
      bool? observedIncrementalMode;

      final service = LegacyCompatibilityMaintenanceService(
        runImport:
            ({required executionOwner, required forceFullReimport}) async {
              observedOwner = executionOwner;
              observedForceFullReimport = forceFullReimport;
              return const DbImportResult(
                batchId: 42,
                success: true,
                messagesImported: 3,
                attachmentsImported: 2,
                messageAttachmentsImported: 1,
              );
            },
        runMigration: ({required incrementalMode}) async {
          observedIncrementalMode = incrementalMode;
          return const DbMigrationResult(
            batchId: 42,
            success: true,
            messagesProjected: 3,
            attachmentsProjected: 2,
          );
        },
        logInfo: log.info,
        logWarn: log.warn,
      );

      await service.runAfterGraphUpdate(
        executionOwner: 'chat-db-monitor',
        forceFullReimport: true,
        updateStartedAt: DateTime.utc(2026, 6, 2, 12),
        newMessageCount: 3,
      );

      expect(observedOwner, 'chat-db-monitor');
      expect(observedForceFullReimport, isTrue);
      expect(observedIncrementalMode, isTrue);
      expect(log.warnMessages, isEmpty);
      expect(log.infoMessages, hasLength(3));
      expect(log.infoMessages[0], contains('3 new source row(s)'));
      expect(log.infoMessages[2], contains('3 working message row(s)'));
    });

    test('failed import is logged as warning and does not migrate', () async {
      final log = _LegacyCompatibilityLog();
      var migrationRan = false;
      final service = LegacyCompatibilityMaintenanceService(
        runImport:
            ({required executionOwner, required forceFullReimport}) async {
              return const DbImportResult(
                batchId: 7,
                success: false,
                error: 'import failed',
              );
            },
        runMigration: ({required incrementalMode}) async {
          migrationRan = true;
          return const DbMigrationResult(batchId: 7, success: true);
        },
        logInfo: log.info,
        logWarn: log.warn,
      );

      await service.runAfterGraphUpdate(
        executionOwner: 'chat-db-monitor',
        forceFullReimport: false,
        updateStartedAt: DateTime.utc(2026, 6, 2, 12),
        newMessageCount: 1,
      );

      expect(migrationRan, isFalse);
      expect(log.infoMessages, isEmpty);
      expect(log.warnMessages.single, contains('import failed'));
    });

    test('thrown import is logged as warning and swallowed', () async {
      final log = _LegacyCompatibilityLog();
      var migrationRan = false;
      final service = LegacyCompatibilityMaintenanceService(
        runImport:
            ({required executionOwner, required forceFullReimport}) async {
              throw StateError('import exploded');
            },
        runMigration: ({required incrementalMode}) async {
          migrationRan = true;
          return const DbMigrationResult(batchId: 7, success: true);
        },
        logInfo: log.info,
        logWarn: log.warn,
      );

      await service.runAfterGraphUpdate(
        executionOwner: 'chat-db-monitor',
        forceFullReimport: false,
        updateStartedAt: DateTime.utc(2026, 6, 2, 12),
        newMessageCount: 1,
      );

      expect(migrationRan, isFalse);
      expect(log.warnMessages.single, contains('import exploded'));
      expect(log.warnContexts.single['stackTrace'], isNotEmpty);
    });

    test('failed migration is logged as warning and swallowed', () async {
      final log = _LegacyCompatibilityLog();
      final service = LegacyCompatibilityMaintenanceService(
        runImport:
            ({required executionOwner, required forceFullReimport}) async {
              return const DbImportResult(batchId: 9, success: true);
            },
        runMigration: ({required incrementalMode}) async {
          return const DbMigrationResult(
            batchId: 9,
            success: false,
            error: 'migration failed',
          );
        },
        logInfo: log.info,
        logWarn: log.warn,
      );

      await service.runAfterGraphUpdate(
        executionOwner: 'chat-db-monitor',
        forceFullReimport: false,
        updateStartedAt: DateTime.utc(2026, 6, 2, 12),
        newMessageCount: 1,
      );

      expect(log.warnMessages.single, contains('migration failed'));
      expect(log.infoMessages, hasLength(2));
    });

    test('thrown migration is logged as warning and swallowed', () async {
      final log = _LegacyCompatibilityLog();
      final service = LegacyCompatibilityMaintenanceService(
        runImport:
            ({required executionOwner, required forceFullReimport}) async {
              return const DbImportResult(batchId: 9, success: true);
            },
        runMigration: ({required incrementalMode}) async {
          throw StateError('migration exploded');
        },
        logInfo: log.info,
        logWarn: log.warn,
      );

      await service.runAfterGraphUpdate(
        executionOwner: 'chat-db-monitor',
        forceFullReimport: false,
        updateStartedAt: DateTime.utc(2026, 6, 2, 12),
        newMessageCount: 1,
      );

      expect(log.warnMessages.single, contains('migration exploded'));
      expect(log.warnContexts.single['stackTrace'], isNotEmpty);
    });
  });
}

class _LegacyCompatibilityLog {
  final infoMessages = <String>[];
  final warnMessages = <String>[];
  final warnContexts = <Map<String, dynamic>>[];

  void info(String message, {String? source, Map<String, dynamic>? context}) {
    infoMessages.add(message);
  }

  void warn(String message, {String? source, Map<String, dynamic>? context}) {
    warnMessages.add(message);
    warnContexts.add(context ?? <String, dynamic>{});
  }
}
