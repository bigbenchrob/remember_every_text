import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/message_history_coverage_repository.dart';

void main() {
  group('MessageHistoryCoverageRepository', () {
    late ConversationGraphDatabase graphDb;

    setUp(() {
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await graphDb.close();
    });

    test(
      'reports source summary read failures through diagnostic callback',
      () {
        final tempDirectory = Directory.systemTemp.createTempSync(
          'message-history-coverage-invalid-',
        );
        addTearDown(() {
          if (tempDirectory.existsSync()) {
            tempDirectory.deleteSync(recursive: true);
          }
        });

        final invalidChatDb = File('${tempDirectory.path}/chat.db')
          ..writeAsStringSync('not sqlite');
        Object? reportedError;
        StackTrace? reportedStackTrace;
        final repository = MessageHistoryCoverageRepository(
          graphDb: graphDb,
          onSourceReadFailure: (error, stackTrace) {
            reportedError = error;
            reportedStackTrace = stackTrace;
          },
        );

        final summary = repository.readChatDbSummary(invalidChatDb.path);

        expect(summary, isNull);
        expect(reportedError, isNotNull);
        expect(reportedStackTrace, isNotNull);
      },
    );
  });
}
