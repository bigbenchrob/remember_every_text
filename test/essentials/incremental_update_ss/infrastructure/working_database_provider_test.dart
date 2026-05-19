import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update_ss/infrastructure/working_database_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late WorkingDatabase workingDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('working_ss_db_test_');
    workingDatabase = await WorkingDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'working_ss_test.db',
    );
  });

  tearDown(() async {
    await workingDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('creates messages projection schema only', () async {
    final messageColumns = await workingDatabase.database.rawQuery(
      'PRAGMA table_info(messages)',
    );
    final columnNames = messageColumns.map((row) => row['name']).toSet();

    expect(columnNames, <String>{
      'ss_id',
      'guid',
      'sender_handle_ss_id',
      'is_from_me',
      'date_utc',
      'text',
      'associated_message_ss_id',
    });
    expect(columnNames, isNot(contains('source_id')));
    expect(columnNames, isNot(contains('source_rowid')));
    expect(columnNames, isNot(contains('attributed_body_blob')));
    expect(columnNames, isNot(contains('associated_message_guid')));
    expect(columnNames, isNot(contains('thread_originator_guid')));
    expect(columnNames, isNot(contains('reply_to_guid')));
  });
}
