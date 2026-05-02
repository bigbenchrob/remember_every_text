import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkingDatabase projection_state completion marker', () {
    late WorkingDatabase db;

    setUp(() async {
      db = WorkingDatabase(NativeDatabase.memory());
      // Force the database to open + run onCreate so the seed row exists.
      await db.customStatement('SELECT 1');
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'fresh database seeds projection_state with completion_status = incomplete',
      () async {
        final completion = await db.readProjectionCompletion();
        expect(completion, isNotNull);
        expect(completion!.status, 'incomplete');
        expect(completion.isComplete, isFalse);
        expect(completion.lastCompletedBatchId, isNull);
        expect(completion.completedAtUtc, isNull);
      },
    );

    test('markProjectionMigrationStarted then markProjectionMigrationCompleted '
        'flips the row to complete with batch id and timestamp', () async {
      await db.markProjectionMigrationStarted();
      var completion = await db.readProjectionCompletion();
      expect(completion!.status, 'incomplete');

      const completedAt = '2026-04-30T12:34:56.000Z';
      await db.markProjectionMigrationCompleted(
        batchId: 42,
        completedAtUtc: completedAt,
      );

      completion = await db.readProjectionCompletion();
      expect(completion!.status, 'complete');
      expect(completion.isComplete, isTrue);
      expect(completion.lastCompletedBatchId, 42);
      expect(completion.completedAtUtc, completedAt);
    });

    test(
      'markProjectionMigrationStarted after a previous completion reverts '
      'completion_status to incomplete (simulating a crash mid-migration)',
      () async {
        await db.markProjectionMigrationCompleted(
          batchId: 7,
          completedAtUtc: '2026-04-29T00:00:00.000Z',
        );
        expect((await db.readProjectionCompletion())!.isComplete, isTrue);

        // Next migration starts, then the process is force-quit before
        // the completion marker is written.
        await db.markProjectionMigrationStarted();

        final completion = await db.readProjectionCompletion();
        expect(completion!.status, 'incomplete');
        expect(completion.isComplete, isFalse);
        // Last successful completion details are intentionally retained
        // so callers can reason about how stale the projection is.
        expect(completion.lastCompletedBatchId, 7);
      },
    );

    test(
      'completion_status is constrained to complete or incomplete',
      () async {
        await expectLater(
          () => db.customStatement(
            "UPDATE projection_state SET completion_status = 'bogus' "
            'WHERE id = 1',
          ),
          throwsA(anything),
        );
      },
    );
  });
}
