import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db_migrate/infrastructure/repositories/drift_legacy_projection_status_repository.dart';

void main() {
  late WorkingDatabase workingDb;
  late DriftLegacyProjectionStatusRepository repository;

  setUp(() {
    workingDb = WorkingDatabase(NativeDatabase.memory());
    repository = DriftLegacyProjectionStatusRepository(
      openWorkingDatabase: () async => workingDb,
    );
  });

  tearDown(() async {
    await workingDb.close();
  });

  group('DriftLegacyProjectionStatusRepository', () {
    test(
      'reports no existing messages when legacy projection is empty',
      () async {
        expect(await repository.hasExistingMessages(), isFalse);
      },
    );

    test('reports existing messages after one projected row exists', () async {
      final chatId = await workingDb
          .into(workingDb.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat-1'));
      await workingDb
          .into(workingDb.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'message-1',
              chatId: chatId,
              sentAtUtc: const Value('2026-06-02T12:00:00.000Z'),
            ),
          );

      expect(await repository.hasExistingMessages(), isTrue);
    });
  });
}
