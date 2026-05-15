import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/incremental_update/application/messages/status/shadow_polling_endurance_log_writer.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/message_migration_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/models/snapshot_delta.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/comparison_outcome.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/import_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/message_migration_state.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/migration_decision.dart';
import 'package:remember_this_text/essentials/incremental_update/domain/sealed_unions/sync_state.dart';

void main() {
  group('ShadowPollingEnduranceLogWriter', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'shadow_polling_endurance_log_writer_test_',
      );
    });

    tearDown(() {
      if (tempDirectory.existsSync()) {
        tempDirectory.deleteSync(recursive: true);
      }
    });

    test('renders tick events before end-of-tick summary', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(),
        tickEvents: const <String>[
          'tick started',
          'import delta observed: rowIdDelta=2, messageCountDelta=2',
        ],
      );

      final content = await _readActiveLog(writer);

      expect(content, contains('## Tick Events'));
      expect(content, contains('### Behavioral assessment'));
      expect(
        content.indexOf('## Tick Events'),
        lessThan(content.indexOf('### Behavioral assessment')),
      );
      expect(
        content.indexOf('### Behavioral assessment'),
        lessThan(content.indexOf('### Shadow import')),
      );
    });

    test('renders empty tick events explicitly', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(_snapshot());

      final content = await _readActiveLog(writer);

      expect(content, contains('## Tick Events'));
      expect(content, contains('- no tick events recorded'));
    });

    test('renders execution events clearly', () async {
      final writer = ShadowPollingEnduranceLogWriter(
        logsDirectory: tempDirectory,
      );
      writer.startSession();

      await writer.appendStatus(
        _snapshot(),
        tickEvents: const <String>[
          'shadow import executed: insertedMessageCount=2, lastImportedSourceRowId=136001',
          'shadow migration executed: insertedMessageCount=2',
        ],
      );

      final content = await _readActiveLog(writer);

      expect(
        content,
        contains(
          '- shadow import executed: insertedMessageCount=2, '
          'lastImportedSourceRowId=136001',
        ),
      );
      expect(
        content,
        contains('- shadow migration executed: insertedMessageCount=2'),
      );
    });
  });
}

Future<String> _readActiveLog(ShadowPollingEnduranceLogWriter writer) async {
  final path = writer.activeLogPath;
  expect(path, isNotNull);
  return File(path!).readAsString();
}

ShadowPollingEnduranceSnapshot _snapshot() {
  return ShadowPollingEnduranceSnapshot(
    pollingActive: true,
    lastRefreshTime: DateTime(2026, 5, 15, 9),
    lastTransitionTime: DateTime(2026, 5, 15, 9, 0, 1),
    importDecision: const ImportDecision.doNothing(),
    messageSyncState: const MessageSyncState.sourceAndLedgerCursorsMatch(),
    snapshotDelta: const MessageSnapshotDelta(
      rowIdDelta: 0,
      messageCountDelta: 0,
    ),
    migrationDecision: const MigrationDecision.doNothing(),
    messageMigrationState: const MessageMigrationState.projectionCaughtUp(),
    migrationDelta: const MessageMigrationDelta(
      messageIdDelta: 0,
      messageCountDelta: 0,
    ),
    importComparisonOutcome: const ComparisonOutcome.match(
      legacy: 'incremental import not required',
      shadow: 'incremental import not required',
    ),
    migrationComparisonOutcome: const ComparisonOutcome.match(
      legacy: 'projection current',
      shadow: 'projection current',
    ),
  );
}
