import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
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
      await storage.saveImportFailure(
        batchId: 11,
        message: 'Import failed badly',
        warnings: ['warning-a'],
        recordedAt: recordedAt,
      );

      final loaded = await storage.loadImportResultEntry();

      expect(loaded, isNotNull);
      expect(loaded!.failure.batchId, 11);
      expect(loaded.failure.message, 'Import failed badly');
      expect(loaded.recordedAt, recordedAt);
    });

    test('round-trips graph projection failure summaries', () async {
      final recordedAt = DateTime.utc(2026, 03, 24, 10, 30);
      await storage.saveGraphProjectionFailure(
        batchId: 22,
        message: 'Graph projection failed badly',
        recordedAt: recordedAt,
      );

      final loaded = await storage.loadGraphProjectionResultEntry();

      expect(loaded, isNotNull);
      expect(loaded!.failure.batchId, 22);
      expect(loaded.failure.message, 'Graph projection failed badly');
      expect(loaded.recordedAt, recordedAt);
    });

    test(
      'uses historical graph projection failure key for compatibility',
      () async {
        await storage.saveGraphProjectionFailure(
          batchId: 22,
          message: 'Graph projection failed badly',
          recordedAt: DateTime.utc(2026, 03, 24, 10, 30),
        );

        expect(
          await overlayDb.readOverlaySetting(
            'onboarding_last_migration_result',
          ),
          isNotNull,
        );
      },
    );

    test('clear removes persisted results', () async {
      await storage.saveImportFailure(batchId: 1, message: 'fail');
      await storage.saveGraphProjectionFailure(batchId: 2, message: 'fail');

      await storage.clearImportResult();
      await storage.clearGraphProjectionResult();

      expect(await storage.loadImportResult(), isNull);
      expect(await storage.loadGraphProjectionResult(), isNull);
    });
  });
}
