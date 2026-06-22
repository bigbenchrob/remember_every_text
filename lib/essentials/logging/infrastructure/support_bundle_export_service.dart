import 'dart:convert';
import 'dart:io';

import '../../db/application/database_health_audit/database_health_audit_service.dart';
import '../../db/feature_level_providers.dart' show databaseDirectoryPath;
import 'log_file_writer.dart';

class SupportBundleExportResult {
  const SupportBundleExportResult({
    required this.bundleDirectory,
    required this.attachmentFiles,
    required this.databaseHealthIncluded,
  });

  final Directory bundleDirectory;
  final List<File> attachmentFiles;
  final bool databaseHealthIncluded;
}

/// Builds a privacy-safe support bundle from derived diagnostics only.
///
/// The bundle never includes raw database files or row-level sampling.
class SupportBundleExportService {
  SupportBundleExportService(this._writer, this._databaseHealthAuditService);

  final LogFileWriter _writer;
  final DatabaseHealthAuditService _databaseHealthAuditService;

  Future<SupportBundleExportResult> export({
    List<String> headerLines = const <String>[],
  }) async {
    await _writer.flush();

    final logDir = _writer.logDir;
    if (!logDir.existsSync()) {
      throw StateError('Log directory does not exist.');
    }

    final now = DateTime.now();
    final stamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final bundleDirectory = Directory('${logDir.path}/support_bundle_$stamp');
    await bundleDirectory.create(recursive: true);

    final attachmentFiles = <File>[];

    final diagnosticLogFile = File(
      '${bundleDirectory.path}/diagnostic_report.log',
    );
    final pipelineAuditLogFiles = _pipelineAuditLogFiles();
    await _writeDiagnosticLog(
      diagnosticLogFile,
      now: now,
      headerLines: headerLines,
      pipelineAuditLogFiles: pipelineAuditLogFiles,
    );
    attachmentFiles.add(diagnosticLogFile);

    for (final auditLog in pipelineAuditLogFiles.files) {
      final copied = await _copyIfPresent(
        source: auditLog.$2,
        destinationPath:
            '${bundleDirectory.path}/${auditLog.$2.uri.pathSegments.last}',
      );
      if (copied != null) {
        attachmentFiles.add(copied);
      }
    }

    var databaseHealthIncluded = false;
    try {
      final auditOutput = await _databaseHealthAuditService.writePhase1Report(
        outputDirectoryPath: bundleDirectory.path,
      );
      attachmentFiles.add(File(auditOutput.reportPath));
      databaseHealthIncluded = true;
    } catch (error, stackTrace) {
      final errorFile = File(
        '${bundleDirectory.path}/database_health_error.json',
      );
      await errorFile.writeAsString(
        '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{
          'generated_at': DateTime.now().toUtc().toIso8601String(),
          'artifact': 'database_health.json',
          'status': 'failed',
          'message': error.toString(),
          'stack_trace': stackTrace.toString(),
          'notes': <String>['Support bundle export continued after database health generation failed.', 'No raw database copies were exported.'],
        })}\n',
      );
      attachmentFiles.add(errorFile);
    }

    return SupportBundleExportResult(
      bundleDirectory: bundleDirectory,
      attachmentFiles: attachmentFiles
          .where((file) => file.existsSync())
          .toList(),
      databaseHealthIncluded: databaseHealthIncluded,
    );
  }

  Future<void> _writeDiagnosticLog(
    File exportFile, {
    required DateTime now,
    required List<String> headerLines,
    required _PipelineAuditLogFiles pipelineAuditLogFiles,
  }) async {
    final sink = exportFile.openWrite();
    sink.write(_buildHeader(now, headerLines: headerLines));

    await _appendFileIfPresent(
      sink,
      file: _writer.logFile,
      title: 'Application Log (Current Session)',
    );
    await _appendFileIfPresent(
      sink,
      file: _writer.prevLogFile,
      title: 'Application Log (Previous Session)',
    );
    if (pipelineAuditLogFiles.unavailableReason case final reason?) {
      sink.write('--- Pipeline Audit Logs ---\n');
      sink.write('$reason\n\n');
    }
    for (final auditLog in pipelineAuditLogFiles.files) {
      await _appendFileIfPresent(sink, file: auditLog.$2, title: auditLog.$1);
    }

    await sink.flush();
    await sink.close();
  }

  String _buildHeader(DateTime now, {required List<String> headerLines}) {
    final macosVersion = Platform.operatingSystemVersion;
    final buffer = StringBuffer()
      ..writeln('=== MessageLens — Support Bundle ===')
      ..writeln('macOS: $macosVersion')
      ..writeln('Exported: ${now.toUtc().toIso8601String()}')
      ..writeln(
        'Contains: diagnostic_report.log, active graph health, and retired cleanup inventory when available',
      )
      ..writeln('No raw database files are included.')
      ..writeln('====================================');

    headerLines.forEach(buffer.writeln);
    buffer.writeln();
    return buffer.toString();
  }

  Future<void> _appendFileIfPresent(
    IOSink sink, {
    required File file,
    required String title,
  }) async {
    if (!file.existsSync()) {
      return;
    }

    sink.write('--- $title ---\n');
    sink.write(await file.readAsString());
    sink.write('\n');
  }

  _PipelineAuditLogFiles _pipelineAuditLogFiles() {
    try {
      return _PipelineAuditLogFiles(
        files: [
          (
            'Retired Historical Import Audit Log',
            File('$databaseDirectoryPath/import_log'),
          ),
          (
            'Retired Historical Projection Audit Log',
            File('$databaseDirectoryPath/migrate_log'),
          ),
          (
            'Pipeline Incident Log',
            File('$databaseDirectoryPath/pipeline_incident_log'),
          ),
        ],
      );
    } catch (error) {
      return _PipelineAuditLogFiles(
        files: const <(String, File)>[],
        unavailableReason:
            'Pipeline audit log paths could not be resolved: $error',
      );
    }
  }

  Future<File?> _copyIfPresent({
    required File source,
    required String destinationPath,
  }) async {
    if (!source.existsSync()) {
      return null;
    }
    return source.copy(destinationPath);
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _PipelineAuditLogFiles {
  const _PipelineAuditLogFiles({required this.files, this.unavailableReason});

  final List<(String, File)> files;
  final String? unavailableReason;
}
