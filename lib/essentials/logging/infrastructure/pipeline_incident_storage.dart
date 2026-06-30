import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../application/pipeline_incident_store.dart';
import '../domain/pipeline_incident_report.dart';

class PipelineIncidentStorage implements PipelineIncidentStore {
  PipelineIncidentStorage({required Future<OverlayDatabase> overlayDb})
    : _overlayDb = overlayDb;

  static const String _latestIncidentReportKey =
      'pipeline_latest_incident_report';

  final Future<OverlayDatabase> _overlayDb;

  @override
  Future<PipelineIncidentReport?> loadLatestReport() async {
    String? rawValue;
    try {
      final overlayDb = await _overlayDb;
      rawValue = await overlayDb.readOverlaySetting(_latestIncidentReportKey);
    } catch (error, stackTrace) {
      _debugStorageFailure(
        'read latest pipeline incident report',
        error,
        stackTrace,
      );
      return null;
    }

    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      return PipelineIncidentReport.fromJson(jsonDecode(rawValue));
    } catch (error, stackTrace) {
      _debugStorageFailure(
        'decode latest pipeline incident report',
        error,
        stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> saveLatestReport(PipelineIncidentReport report) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: _latestIncidentReportKey,
      settingValue: jsonEncode(report.toJson()),
    );
  }

  @override
  Future<void> dismissLatestReport() async {
    final existing = await loadLatestReport();
    if (existing == null) {
      return;
    }

    await saveLatestReport(existing.copyWith(dismissed: true));
  }

  @override
  Future<void> clearLatestReport() async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: _latestIncidentReportKey,
      settingValue: '',
    );
  }

  void _debugStorageFailure(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('Pipeline incident storage could not $operation: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
