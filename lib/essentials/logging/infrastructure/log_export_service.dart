import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/feature_level_providers.dart' show databaseDirectoryPath;
import '../infrastructure/log_file_writer.dart';

const _defaultDiagnosticRecipientEmail = 'bigbenchrob@gmail.com';
const _defaultEmailBodyLines = <String>[
  'Please attach the diagnostic report that was just revealed in Finder.',
  '',
  'Describe the issue here:',
];

class DiagnosticReportPresentationResult {
  const DiagnosticReportPresentationResult({
    required this.exportPath,
    required this.attachedToMailDraft,
  });

  final String? exportPath;
  final bool attachedToMailDraft;
}

/// Collects log files, prepends a system info header, and presents the
/// exported log to the user via email (mailto:) and Finder reveal.
class LogExportService {
  final LogFileWriter _writer;

  LogExportService(this._writer);

  /// Export logs, open email client, and reveal file in Finder.
  ///
  /// Returns the exported report path and whether it was attached to an Apple
  /// Mail draft automatically.
  Future<DiagnosticReportPresentationResult> exportAndPresent({
    String recipientEmail = _defaultDiagnosticRecipientEmail,
    String subjectPrefix = 'MessageLens Diagnostic Report',
    List<String> emailBodyLines = _defaultEmailBodyLines,
    List<String> headerLines = const <String>[],
  }) async {
    try {
      // Flush in-memory buffer to disk before reading.
      await _writer.flush();

      final logDir = _writer.logDir;
      if (!logDir.existsSync()) {
        return const DiagnosticReportPresentationResult(
          exportPath: null,
          attachedToMailDraft: false,
        );
      }

      final now = DateTime.now();
      final stamp =
          '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
      final exportFile = File('${logDir.path}/diagnostic_$stamp.log');

      // Build the header.
      final header = _buildHeader(now, headerLines: headerLines);

      // Concatenate current + previous app logs and pipeline audit logs.
      final sink = exportFile.openWrite();
      sink.write(header);

      final currentLog = _writer.logFile;
      await _appendFileIfPresent(
        sink,
        file: currentLog,
        title: 'Application Log (Current Session)',
      );

      final prevLog = _writer.prevLogFile;
      await _appendFileIfPresent(
        sink,
        file: prevLog,
        title: 'Application Log (Previous Session)',
      );

      for (final auditLog in _pipelineAuditLogFiles()) {
        await _appendFileIfPresent(sink, file: auditLog.$2, title: auditLog.$1);
      }

      await sink.flush();
      await sink.close();

      final subject = '$subjectPrefix - $stamp';
      final attachedToMailDraft = await _tryComposeAppleMailDraft(
        exportFile: exportFile,
        recipientEmail: recipientEmail,
        subject: subject,
        emailBodyLines: emailBodyLines,
      );

      if (attachedToMailDraft) {
        return DiagnosticReportPresentationResult(
          exportPath: exportFile.path,
          attachedToMailDraft: true,
        );
      }

      // Fallback: open the default email client and reveal the report in Finder
      // so it can be attached manually.
      final mailto = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        queryParameters: {
          'subject': subject,
          'body': emailBodyLines.join('\n'),
        },
      );
      await launchUrl(mailto);

      // Reveal the exported file in Finder.
      await Process.run('open', ['-R', exportFile.path]);

      return DiagnosticReportPresentationResult(
        exportPath: exportFile.path,
        attachedToMailDraft: false,
      );
    } catch (e) {
      debugPrint('LogExportService: export failed: $e');
      return const DiagnosticReportPresentationResult(
        exportPath: null,
        attachedToMailDraft: false,
      );
    }
  }

  String _buildHeader(DateTime now, {List<String> headerLines = const []}) {
    final macosVersion = Platform.operatingSystemVersion;
    final buf = StringBuffer()
      ..writeln('=== MessageLens — Diagnostic Log ===')
      ..writeln('macOS: $macosVersion')
      ..writeln('Exported: ${now.toUtc().toIso8601String()}')
      ..writeln('====================================');

    headerLines.forEach(buf.writeln);

    buf.writeln();
    return buf.toString();
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

  List<(String, File)> _pipelineAuditLogFiles() {
    try {
      return [
        (
          'Import Pipeline Audit Log',
          File('$databaseDirectoryPath/import_log'),
        ),
        (
          'Migration Pipeline Audit Log',
          File('$databaseDirectoryPath/migrate_log'),
        ),
      ];
    } catch (_) {
      return const <(String, File)>[];
    }
  }

  Future<bool> _tryComposeAppleMailDraft({
    required File exportFile,
    required String recipientEmail,
    required String subject,
    required List<String> emailBodyLines,
  }) async {
    if (!Platform.isMacOS) {
      return false;
    }

    try {
      final result = await Process.run(
        'osascript',
        buildAppleMailComposeScriptArgs(
          exportFilePath: exportFile.path,
          recipientEmail: recipientEmail,
          subject: subject,
          bodyText: emailBodyLines.join(' '),
        ),
      );

      if (result.exitCode == 0) {
        return true;
      }

      debugPrint(
        'LogExportService: Apple Mail compose failed: ${result.stderr}',
      );
      return false;
    } catch (e) {
      debugPrint('LogExportService: Apple Mail compose threw: $e');
      return false;
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

List<String> buildAppleMailComposeScriptArgs({
  required String exportFilePath,
  required String recipientEmail,
  required String subject,
  required String bodyText,
}) {
  final reportFile = _toAppleScriptString(exportFilePath);
  final recipient = _toAppleScriptString(recipientEmail);
  final escapedSubject = _toAppleScriptString(subject);
  final escapedBody = _toAppleScriptString(bodyText);

  return [
    '-e',
    'set reportFile to POSIX file "$reportFile"',
    '-e',
    'tell application "Mail"',
    '-e',
    'set newMessage to make new outgoing message with properties {subject:"$escapedSubject", content:"$escapedBody", visible:true}',
    '-e',
    'tell newMessage',
    '-e',
    'make new to recipient at end of to recipients with properties {address:"$recipient"}',
    '-e',
    'make new attachment with properties {file name:reportFile} at after the last paragraph',
    '-e',
    'end tell',
    '-e',
    'activate',
    '-e',
    'end tell',
  ];
}

String _toAppleScriptString(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
}
