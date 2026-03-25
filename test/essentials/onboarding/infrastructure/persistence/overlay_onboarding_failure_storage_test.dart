import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db_importers/domain/entities/db_import_result.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/entities/db_migration_result.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/overlay_onboarding_failure_storage.dart';

void main() {
  group('OverlayOnboardingFailureStorage', () {
    late OverlayDatabase overlayDb;
    late OverlayOnboardingFailureStorage storage;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      storage = OverlayOnboardingFailureStorage(
        overlayDb: Future<OverlayDatabase>.value(overlayDb),
      );
    });

    tearDown(() async {
      await overlayDb.close();
    });

    test('round-trips import failure summaries', () async {
      final recordedAt = DateTime.utc(2026, 03, 24, 9, 15);
      await storage.saveImportResult(
        const DbImportResult(
          batchId: 11,
          success: false,
          error: 'Import failed badly',
          messagesImported: 12,
          warnings: ['warning-a'],
        ),
        recordedAt: recordedAt,
      );

      final loaded = await storage.loadImportResultEntry();

      expect(loaded, isNotNull);
      expect(loaded!.result.batchId, 11);
      expect(loaded.result.success, isFalse);
      expect(loaded.result.error, 'Import failed badly');
      expect(loaded.result.messagesImported, 12);
      expect(loaded.result.warnings, ['warning-a']);
      expect(loaded.recordedAt, recordedAt);
    });

    test('round-trips migration failure summaries', () async {
      final recordedAt = DateTime.utc(2026, 03, 24, 10, 30);
      await storage.saveMigrationResult(
        const DbMigrationResult(
          batchId: 22,
          success: false,
          error: 'Migration failed badly',
          messagesProjected: 34,
          warnings: ['warning-b'],
        ),
        recordedAt: recordedAt,
      );

      final loaded = await storage.loadMigrationResultEntry();

      expect(loaded, isNotNull);
      expect(loaded!.result.batchId, 22);
      expect(loaded.result.success, isFalse);
      expect(loaded.result.error, 'Migration failed badly');
      expect(loaded.result.messagesProjected, 34);
      expect(loaded.result.warnings, ['warning-b']);
      expect(loaded.recordedAt, recordedAt);
    });

    test('clear removes persisted results', () async {
      await storage.saveImportResult(
        const DbImportResult(batchId: 1, success: false, error: 'fail'),
      );
      await storage.saveMigrationResult(
        const DbMigrationResult(batchId: 2, success: false, error: 'fail'),
      );

      await storage.clearImportResult();
      await storage.clearMigrationResult();

      expect(await storage.loadImportResult(), isNull);
      expect(await storage.loadMigrationResult(), isNull);
    });
  });
}
