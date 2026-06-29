import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_models.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_report_writer.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';
import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_runtime_environment.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/log_file_writer.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/support_bundle_export_service.dart';

void main() {
  test(
    'diagnostic header describes active health and retired cleanup inventory',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'support_bundle_export_service_test_',
      );
      addTearDown(() async {
        if (tempDirectory.existsSync()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final logDirectory = Directory('${tempDirectory.path}/logs')
        ..createSync(recursive: true);
      final service = SupportBundleExportService(
        _FakeLogFileWriter(logDirectory),
        DatabaseHealthAuditService(
          hasFullDiskAccess: true,
          queryLayers: const [],
          runtimeEnvironment: const _FakeRuntimeEnvironment(),
          reportWriter: const _FakeDatabaseHealthReportWriter(),
        ),
      );

      final result = await service.export();
      final diagnosticLog = File(
        '${result.bundleDirectory.path}/diagnostic_report.log',
      );

      expect(diagnosticLog.existsSync(), isTrue);
      final content = await diagnosticLog.readAsString();
      expect(content, contains('active graph health'));
      expect(content, contains('retired cleanup inventory'));
      expect(content, contains('No raw database files are included.'));
    },
  );

  test('rejects raw database files returned by health writer', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: const _RawDatabasePathHealthReportWriter(),
      ),
    );

    final result = await service.export();
    final attachmentNames = result.attachmentFiles
        .map((file) => file.uri.pathSegments.last)
        .toSet();

    expect(result.databaseHealthIncluded, isFalse);
    expect(attachmentNames, isNot(contains('working.db')));
    expect(attachmentNames, contains('database_health_error.json'));
  });

  test('rejects health report files outside the support bundle', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final outsideDirectory = Directory('${tempDirectory.path}/outside')
      ..createSync(recursive: true);
    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: _OutsideBundleHealthReportWriter(outsideDirectory),
      ),
    );

    final result = await service.export();
    final attachmentPaths = result.attachmentFiles
        .map((file) => file.path)
        .toSet();

    expect(result.databaseHealthIncluded, isFalse);
    expect(
      attachmentPaths.any((filePath) => filePath.contains('/outside/')),
      isFalse,
    );
    expect(
      attachmentPaths.any(
        (filePath) => filePath.endsWith('database_health_error.json'),
      ),
      isTrue,
    );
  });

  test('does not append symlinked diagnostic log sources', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'support_bundle_export_service_test_',
    );
    addTearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final logDirectory = Directory('${tempDirectory.path}/logs')
      ..createSync(recursive: true);
    final protectedFile = File('${tempDirectory.path}/protected.txt');
    await protectedFile.writeAsString('protected content');
    await Link('${logDirectory.path}/app.log').create(protectedFile.path);

    final service = SupportBundleExportService(
      _FakeLogFileWriter(logDirectory),
      DatabaseHealthAuditService(
        hasFullDiskAccess: true,
        queryLayers: const [],
        runtimeEnvironment: const _FakeRuntimeEnvironment(),
        reportWriter: const _FakeDatabaseHealthReportWriter(),
      ),
    );

    final result = await service.export();
    final diagnosticLog = File(
      '${result.bundleDirectory.path}/diagnostic_report.log',
    );
    final content = await diagnosticLog.readAsString();

    expect(content, contains('No raw database files are included.'));
    expect(content, isNot(contains('protected content')));
    expect(content, isNot(contains('Application Log (Current Session)')));
  });
}

class _FakeLogFileWriter extends LogFileWriter {
  _FakeLogFileWriter(this._logDir);

  final Directory _logDir;

  @override
  Directory get logDir => _logDir;

  @override
  File get logFile => File('${_logDir.path}/app.log');

  @override
  File get prevLogFile => File('${_logDir.path}/app.log.1');

  @override
  Future<void> flush() async {}
}

class _FakeRuntimeEnvironment implements DatabaseHealthRuntimeEnvironment {
  const _FakeRuntimeEnvironment();

  @override
  DatabaseHealthRuntimeEnvironmentSnapshot read() {
    return const DatabaseHealthRuntimeEnvironmentSnapshot(
      platform: 'test',
      platformVersion: 'test-version',
      timezone: 'test-zone',
    );
  }
}

class _FakeDatabaseHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _FakeDatabaseHealthReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('$outputDirectoryPath/database_health.json');
    await file.writeAsString('{}\n');
    return file.path;
  }
}

class _RawDatabasePathHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _RawDatabasePathHealthReportWriter();

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('$outputDirectoryPath/working.db');
    await file.writeAsString('not really sqlite\n');
    return file.path;
  }
}

class _OutsideBundleHealthReportWriter
    implements DatabaseHealthAuditReportWriter {
  const _OutsideBundleHealthReportWriter(this._outsideDirectory);

  final Directory _outsideDirectory;

  @override
  Future<String> writeReport({
    required String outputDirectoryPath,
    required DatabaseHealthReport report,
  }) async {
    final file = File('${_outsideDirectory.path}/database_health.json');
    await file.writeAsString('{}\n');
    return file.path;
  }
}
