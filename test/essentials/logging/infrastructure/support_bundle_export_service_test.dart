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
