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

      final loaded = await storage.loadSourceImportFailureEntry();

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

      final loaded = await storage.loadGraphProjectionFailureEntry();

      expect(loaded, isNotNull);
      expect(loaded!.failure.batchId, 22);
      expect(loaded.failure.message, 'Graph projection failed badly');
      expect(loaded.recordedAt, recordedAt);
    });

    test(
      'writes graph projection failure summaries to graph-named key',
      () async {
        await storage.saveGraphProjectionFailure(
          batchId: 22,
          message: 'Graph projection failed badly',
          recordedAt: DateTime.utc(2026, 03, 24, 10, 30),
        );

        expect(
          await overlayDb.readOverlaySetting(
            'onboarding_last_graph_projection_result',
          ),
          isNotNull,
        );
        expect(
          await overlayDb.readOverlaySetting(
            'onboarding_last_migration_result',
          ),
          isNull,
        );
      },
    );

    test(
      'loads historical graph projection failure key as compatibility fallback',
      () async {
        await overlayDb.writeOverlaySetting(
          settingKey: 'onboarding_last_migration_result',
          settingValue:
              '{"batch_id":22,"success":false,"error":"Old graph projection failure"}',
        );

        final loaded = await storage.loadGraphProjectionFailureEntry();

        expect(loaded, isNotNull);
        expect(loaded!.failure.batchId, 22);
        expect(loaded.failure.message, 'Old graph projection failure');
      },
    );

    test('clear removes persisted results', () async {
      await storage.saveImportFailure(batchId: 1, message: 'fail');
      await storage.saveGraphProjectionFailure(batchId: 2, message: 'fail');

      await storage.clearSourceImportFailure();
      await storage.clearGraphProjectionFailure();

      expect(await storage.loadSourceImportFailure(), isNull);
      expect(await storage.loadGraphProjectionFailure(), isNull);
      expect(
        await overlayDb.readOverlaySetting(
          'onboarding_last_graph_projection_result',
        ),
        isEmpty,
      );
      expect(
        await overlayDb.readOverlaySetting('onboarding_last_migration_result'),
        isEmpty,
      );
    });

    test(
      'reports unreadable import failure state and degrades to null',
      () async {
        final readFailures = <String>[];
        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
          onReadFailure: (settingKey, _, _) => readFailures.add(settingKey),
        );
        await overlayDb.writeOverlaySetting(
          settingKey: 'onboarding_last_import_result',
          settingValue: '{',
        );

        final loaded = await storage.loadSourceImportFailureEntry();

        expect(loaded, isNull);
        expect(readFailures, ['onboarding_last_import_result']);
      },
    );

    test(
      'reports unreadable graph projection failure state and degrades to null',
      () async {
        final readFailures = <String>[];
        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
          onReadFailure: (settingKey, _, _) => readFailures.add(settingKey),
        );
        await overlayDb.writeOverlaySetting(
          settingKey: 'onboarding_last_graph_projection_result',
          settingValue: '{',
        );

        final loaded = await storage.loadGraphProjectionFailureEntry();

        expect(loaded, isNull);
        expect(readFailures, ['onboarding_last_graph_projection_result']);
      },
    );
  });
}
