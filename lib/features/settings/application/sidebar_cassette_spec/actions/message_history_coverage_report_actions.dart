import 'dart:convert';
import 'dart:io';

import '../entities/message_history_coverage_report.dart';

typedef CoverageReportProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class MessageHistoryCoverageReportExportResult {
  const MessageHistoryCoverageReportExportResult({
    required this.exportPath,
    required this.revealedInFinder,
  });

  final String? exportPath;
  final bool revealedInFinder;
}

Future<MessageHistoryCoverageReportExportResult>
exportMessageHistoryCoverageReport({
  required MessageHistoryCoverageReport report,
  required Directory exportDirectory,
  DateTime? now,
  CoverageReportProcessRunner processRunner = Process.run,
}) async {
  try {
    await exportDirectory.create(recursive: true);

    final effectiveNow = now ?? DateTime.now();
    final stamp =
        '${effectiveNow.year}-${_pad(effectiveNow.month)}-${_pad(effectiveNow.day)}_${_pad(effectiveNow.hour)}${_pad(effectiveNow.minute)}${_pad(effectiveNow.second)}';
    final exportFile = File(
      '${exportDirectory.path}/message_history_coverage_$stamp.json',
    );
    const encoder = JsonEncoder.withIndent('  ');
    final payload = <String, Object?>{
      'generatedAt':
          report.generatedAt?.toUtc().toIso8601String() ??
          effectiveNow.toUtc().toIso8601String(),
      ...report.toJson(),
    };

    await exportFile.writeAsString('${encoder.convert(payload)}\n');

    var revealedInFinder = false;
    if (Platform.isMacOS) {
      final result = await processRunner('open', ['-R', exportFile.path]);
      revealedInFinder = result.exitCode == 0;
    }

    return MessageHistoryCoverageReportExportResult(
      exportPath: exportFile.path,
      revealedInFinder: revealedInFinder,
    );
  } catch (_) {
    return const MessageHistoryCoverageReportExportResult(
      exportPath: null,
      revealedInFinder: false,
    );
  }
}

String _pad(int value) => value.toString().padLeft(2, '0');
