import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/infrastructure/repositories/filesystem_database_health_audit_report_writer.dart';

void main() {
  test(
    'writes database health report JSON to the requested directory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'database_health_report_writer_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      const writer = FilesystemDatabaseHealthAuditReportWriter();
      final reportPath = await writer.writeReport(
        outputDirectoryPath: tempDirectory.path,
        report: _testReport(),
      );

      final reportFile = File(reportPath);
      expect(reportFile.existsSync(), isTrue);
      expect(
        reportFile.readAsStringSync(),
        contains('"schema_version": "test"'),
      );
    },
  );

  test('rejects symlinked database health report directories', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'database_health_report_writer_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final outsideDirectory = Directory('${tempDirectory.path}/outside')
      ..createSync();
    final link = Link('${tempDirectory.path}/linked_output');
    await link.create(outsideDirectory.path);

    const writer = FilesystemDatabaseHealthAuditReportWriter();

    await expectLater(
      writer.writeReport(outputDirectoryPath: link.path, report: _testReport()),
      throwsStateError,
    );
  });

  test('rejects symlinked database health report targets', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'database_health_report_writer_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final outsideFile = File('${tempDirectory.path}/outside.json')
      ..writeAsStringSync('outside');
    final outputDirectory = Directory('${tempDirectory.path}/output')
      ..createSync();
    final link = Link('${outputDirectory.path}/database_health.json');
    await link.create(outsideFile.path);

    const writer = FilesystemDatabaseHealthAuditReportWriter();

    await expectLater(
      writer.writeReport(
        outputDirectoryPath: outputDirectory.path,
        report: _testReport(),
      ),
      throwsStateError,
    );
    expect(outsideFile.readAsStringSync(), 'outside');
  });
}

DatabaseHealthReport _testReport() {
  return const DatabaseHealthReport(
    schemaVersion: 'test',
    generatedAt: '2026-01-01T00:00:00.000',
    auditVersion: 'test',
    app: DatabaseHealthAppInfo(
      name: 'MessageLens',
      bundleId: 'com.bigbenchsoftware.MessageLens',
      version: 'test',
    ),
    environment: DatabaseHealthEnvironmentInfo(platform: 'test'),
    databases: <AuditedDatabaseInfo>[],
    tableInventory: <TableInventoryEntry>[],
    relationshipChecks: <RelationshipCheckResult>[],
    invariantChecks: <InvariantCheckResult>[],
    summary: HealthReportSummary(
      overallStatus: DatabaseHealthStatus.pass,
      tableCount: 0,
      relationshipCheckCount: 0,
      invariantCheckCount: 0,
      passCount: 0,
      warningCount: 0,
      failCount: 0,
      errorCount: 0,
    ),
  );
}
