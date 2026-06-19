import 'dart:convert';

import '../entities/message_history_coverage_report.dart';

class MessageHistoryCoverageReportExportResult {
  const MessageHistoryCoverageReportExportResult({
    required this.exportPath,
    required this.revealedInFinder,
    this.errorMessage,
  });

  final String? exportPath;
  final bool revealedInFinder;
  final String? errorMessage;
}

abstract interface class MessageHistoryCoverageReportExporter {
  Future<MessageHistoryCoverageReportExportResult> export({
    required MessageHistoryCoverageReport report,
    required String exportDirectoryPath,
    DateTime? now,
  });
}

String messageHistoryCoverageReportExportFileName(DateTime now) {
  return 'message_history_coverage_'
      '${now.year}-${_pad(now.month)}-${_pad(now.day)}_'
      '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.json';
}

String messageHistoryCoverageReportExportJson({
  required MessageHistoryCoverageReport report,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  const encoder = JsonEncoder.withIndent('  ');
  final payload = <String, Object?>{
    'generatedAt':
        report.generatedAt?.toUtc().toIso8601String() ??
        effectiveNow.toUtc().toIso8601String(),
    ...report.toJson(),
  };
  return '${encoder.convert(payload)}\n';
}

String _pad(int value) => value.toString().padLeft(2, '0');
