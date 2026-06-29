import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/actions/message_history_coverage_report_actions.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/infrastructure/repositories/filesystem_message_history_coverage_report_exporter.dart';

void main() {
  group('exportMessageHistoryCoverageReport', () {
    test('writes a JSON export with the expected coverage fields', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'message_history_coverage_export_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final exporter = FilesystemMessageHistoryCoverageReportExporter(
        processRunner: (_, _) async => ProcessResult(0, 0, '', ''),
      );

      final result = await exporter.export(
        report: MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.complete,
          chatDbTotalCount: 120,
          graphConversationLinkedCount: 115,
          graphRecoveredOrphanCount: 5,
          earliestMessageDate: DateTime.utc(2020, 01, 01),
          latestMessageDate: DateTime.utc(2026, 04, 26),
        ),
        exportDirectoryPath: tempDirectory.path,
        now: DateTime.utc(2026, 04, 26, 17, 45, 12),
      );

      expect(result.exportPath, isNotNull);
      final exportFile = File(result.exportPath!);
      expect(exportFile.existsSync(), isTrue);
      expect(
        exportFile.path,
        endsWith('message_history_coverage_2026-04-26_174512.json'),
      );

      final decoded =
          jsonDecode(await exportFile.readAsString()) as Map<String, Object?>;
      expect(decoded['chatDbTotal'], 120);
      expect(decoded['visible'], 115);
      expect(decoded['recovered'], 5);
      expect(decoded['missing'], 0);
      expect(decoded['earliest'], '2020-01-01T00:00:00.000Z');
      expect(decoded['latest'], '2026-04-26T00:00:00.000Z');
      expect(decoded['status'], 'complete');
      expect(decoded['generatedAt'], '2026-04-26T17:45:12.000Z');
    });

    test('exports unknown reports without crashing', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'message_history_coverage_unknown_export_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final exporter = FilesystemMessageHistoryCoverageReportExporter(
        processRunner: (_, _) async => ProcessResult(0, 0, '', ''),
      );

      final result = await exporter.export(
        report: const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.unknown,
          chatDbTotalCount: null,
          graphConversationLinkedCount: null,
          graphRecoveredOrphanCount: null,
          earliestMessageDate: null,
          latestMessageDate: null,
          detail: 'chat.db is unavailable',
        ),
        exportDirectoryPath: tempDirectory.path,
        now: DateTime.utc(2026, 04, 26, 17, 46, 00),
      );

      expect(result.exportPath, isNotNull);
      final exportFile = File(result.exportPath!);
      final decoded =
          jsonDecode(await exportFile.readAsString()) as Map<String, Object?>;
      expect(decoded['status'], 'unknown');
      expect(decoded['chatDbTotal'], isNull);
      expect(decoded['detail'], 'chat.db is unavailable');
    });

    test('returns an error message when export cannot be written', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'message_history_coverage_failed_export_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });
      final filePath = '${tempDirectory.path}/not_a_directory';
      await File(filePath).writeAsString('already a file');

      final exporter = FilesystemMessageHistoryCoverageReportExporter(
        processRunner: (_, _) async => ProcessResult(0, 0, '', ''),
      );

      final result = await exporter.export(
        report: const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.unknown,
          chatDbTotalCount: null,
          graphConversationLinkedCount: null,
          graphRecoveredOrphanCount: null,
          earliestMessageDate: null,
          latestMessageDate: null,
        ),
        exportDirectoryPath: filePath,
        now: DateTime.utc(2026, 04, 26, 17, 47, 00),
      );

      expect(result.exportPath, isNull);
      expect(result.revealedInFinder, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('rejects a symlinked export directory', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'message_history_coverage_symlink_directory_export_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final outsideDirectory = Directory(
        path.join(tempDirectory.path, 'outside'),
      )..createSync();
      final exportLink = Link(path.join(tempDirectory.path, 'exports'));
      await exportLink.create(outsideDirectory.path);
      final exporter = FilesystemMessageHistoryCoverageReportExporter(
        processRunner: (_, _) async => ProcessResult(0, 0, '', ''),
      );

      final result = await exporter.export(
        report: const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.unknown,
          chatDbTotalCount: null,
          graphConversationLinkedCount: null,
          graphRecoveredOrphanCount: null,
          earliestMessageDate: null,
          latestMessageDate: null,
        ),
        exportDirectoryPath: exportLink.path,
        now: DateTime.utc(2026, 04, 26, 17, 48, 00),
      );

      expect(result.exportPath, isNull);
      expect(result.revealedInFinder, isFalse);
      expect(result.errorMessage, contains('must not be a symlink'));
      expect(outsideDirectory.listSync(), isEmpty);
    });

    test('rejects a symlinked export file target', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'message_history_coverage_symlink_file_export_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final exportDirectory = Directory(
        path.join(tempDirectory.path, 'exports'),
      )..createSync();
      final outsideFile = File(path.join(tempDirectory.path, 'outside.json'));
      await outsideFile.writeAsString('do not replace');
      final now = DateTime.utc(2026, 04, 26, 17, 49, 00);
      final exportLink = Link(
        path.join(
          exportDirectory.path,
          messageHistoryCoverageReportExportFileName(now),
        ),
      );
      await exportLink.create(outsideFile.path);
      final exporter = FilesystemMessageHistoryCoverageReportExporter(
        processRunner: (_, _) async => ProcessResult(0, 0, '', ''),
      );

      final result = await exporter.export(
        report: const MessageHistoryCoverageReport(
          status: MessageHistoryCoverageStatus.unknown,
          chatDbTotalCount: null,
          graphConversationLinkedCount: null,
          graphRecoveredOrphanCount: null,
          earliestMessageDate: null,
          latestMessageDate: null,
        ),
        exportDirectoryPath: exportDirectory.path,
        now: now,
      );

      expect(result.exportPath, isNull);
      expect(result.revealedInFinder, isFalse);
      expect(result.errorMessage, contains('must be a regular file'));
      expect(await outsideFile.readAsString(), 'do not replace');
    });
  });
}
