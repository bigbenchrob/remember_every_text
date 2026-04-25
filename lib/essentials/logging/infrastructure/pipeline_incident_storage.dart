import 'dart:convert';

import '../../db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../domain/pipeline_incident_report.dart';

class PipelineIncidentStorage {
  PipelineIncidentStorage({required Future<OverlayDatabase> overlayDb})
    : _overlayDb = overlayDb;

  static const String _latestIncidentReportKey =
      'pipeline_latest_incident_report';

  final Future<OverlayDatabase> _overlayDb;

  Future<PipelineIncidentReport?> loadLatestReport() async {
    try {
      final overlayDb = await _overlayDb;
      final rawValue = await overlayDb.readOverlaySetting(
        _latestIncidentReportKey,
      );
      if (rawValue == null || rawValue.isEmpty) {
        return null;
      }

      return PipelineIncidentReport.fromJson(jsonDecode(rawValue));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLatestReport(PipelineIncidentReport report) async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: _latestIncidentReportKey,
      settingValue: jsonEncode(report.toJson()),
    );
  }

  Future<void> dismissLatestReport() async {
    final existing = await loadLatestReport();
    if (existing == null) {
      return;
    }

    await saveLatestReport(existing.copyWith(dismissed: true));
  }

  Future<void> clearLatestReport() async {
    final overlayDb = await _overlayDb;
    await overlayDb.writeOverlaySetting(
      settingKey: _latestIncidentReportKey,
      settingValue: '',
    );
  }
}
