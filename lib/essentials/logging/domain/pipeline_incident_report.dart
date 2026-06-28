enum PipelineIncidentSeverity { context, warning, blocking }

/// Persisted pipeline-stage names.
///
/// Do not rename [PipelineIncidentStage.migration]. Older overlay incident
/// rows may still store that enum name even though the user-facing label now
/// describes it as retired projection compatibility.
enum PipelineIncidentStage { import, graphProjection, migration }

extension PipelineIncidentStageDisplay on PipelineIncidentStage {
  String get displayLabel {
    return switch (this) {
      PipelineIncidentStage.import => 'Import',
      PipelineIncidentStage.graphProjection => 'Graph projection',
      PipelineIncidentStage.migration => 'Retired projection compatibility',
    };
  }
}

class PipelineIncidentEntry {
  const PipelineIncidentEntry({
    required this.severity,
    required this.stage,
    required this.summary,
    required this.recordedAtUtc,
    this.code,
    this.detail,
  });

  final PipelineIncidentSeverity severity;
  final PipelineIncidentStage stage;
  final String summary;
  final DateTime recordedAtUtc;
  final String? code;
  final String? detail;

  bool get isBlocking {
    return severity == PipelineIncidentSeverity.blocking;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'severity': severity.name,
      'stage': stage.name,
      'summary': summary,
      'recorded_at_utc': recordedAtUtc.toUtc().toIso8601String(),
      'code': code,
      'detail': detail,
    };
  }

  static PipelineIncidentEntry? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final severityName = value['severity'] as String?;
    final stageName = value['stage'] as String?;
    final summary = value['summary'] as String?;
    final recordedAtRaw = value['recorded_at_utc'] as String?;
    if (severityName == null ||
        stageName == null ||
        summary == null ||
        recordedAtRaw == null) {
      return null;
    }

    final severity = PipelineIncidentSeverity.values.where(
      (candidate) => candidate.name == severityName,
    );
    final stage = _pipelineIncidentStageFromName(stageName);
    final recordedAtUtc = DateTime.tryParse(recordedAtRaw)?.toUtc();
    if (severity.isEmpty || stage == null || recordedAtUtc == null) {
      return null;
    }

    return PipelineIncidentEntry(
      severity: severity.first,
      stage: stage,
      summary: summary,
      recordedAtUtc: recordedAtUtc,
      code: value['code'] as String?,
      detail: value['detail'] as String?,
    );
  }
}

class PipelineIncidentReport {
  const PipelineIncidentReport({
    required this.reportId,
    required this.stage,
    required this.headline,
    required this.summary,
    required this.recordedAtUtc,
    required this.entries,
    this.batchId = 0,
    this.dismissed = false,
  });

  final String reportId;
  final PipelineIncidentStage stage;
  final String headline;
  final String summary;
  final DateTime recordedAtUtc;
  final List<PipelineIncidentEntry> entries;
  final int batchId;
  final bool dismissed;

  bool get hasBlockingIncident {
    return entries.any((entry) => entry.isBlocking);
  }

  PipelineIncidentReport copyWith({
    String? reportId,
    PipelineIncidentStage? stage,
    String? headline,
    String? summary,
    DateTime? recordedAtUtc,
    List<PipelineIncidentEntry>? entries,
    int? batchId,
    bool? dismissed,
  }) {
    return PipelineIncidentReport(
      reportId: reportId ?? this.reportId,
      stage: stage ?? this.stage,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      recordedAtUtc: recordedAtUtc ?? this.recordedAtUtc,
      entries: entries ?? this.entries,
      batchId: batchId ?? this.batchId,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'report_id': reportId,
      'stage': stage.name,
      'headline': headline,
      'summary': summary,
      'recorded_at_utc': recordedAtUtc.toUtc().toIso8601String(),
      'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
      'batch_id': batchId,
      'dismissed': dismissed,
    };
  }

  static PipelineIncidentReport? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final reportId = value['report_id'] as String?;
    final stageName = value['stage'] as String?;
    final headline = value['headline'] as String?;
    final summary = value['summary'] as String?;
    final recordedAtRaw = value['recorded_at_utc'] as String?;
    if (reportId == null ||
        stageName == null ||
        headline == null ||
        summary == null ||
        recordedAtRaw == null) {
      return null;
    }

    final stage = _pipelineIncidentStageFromName(stageName);
    final recordedAtUtc = DateTime.tryParse(recordedAtRaw)?.toUtc();
    if (stage == null || recordedAtUtc == null) {
      return null;
    }

    final rawEntries = value['entries'];
    final entries = rawEntries is List
        ? rawEntries
              .map(PipelineIncidentEntry.fromJson)
              .whereType<PipelineIncidentEntry>()
              .toList(growable: false)
        : const <PipelineIncidentEntry>[];

    final batchIdRaw = value['batch_id'];
    final batchId = batchIdRaw is int
        ? batchIdRaw
        : batchIdRaw is num
        ? batchIdRaw.toInt()
        : int.tryParse('$batchIdRaw') ?? 0;

    return PipelineIncidentReport(
      reportId: reportId,
      stage: stage,
      headline: headline,
      summary: summary,
      recordedAtUtc: recordedAtUtc,
      entries: entries,
      batchId: batchId,
      dismissed: value['dismissed'] as bool? ?? false,
    );
  }
}

PipelineIncidentStage? _pipelineIncidentStageFromName(String stageName) {
  for (final candidate in PipelineIncidentStage.values) {
    if (candidate.name == stageName) {
      return candidate;
    }
  }
  return null;
}
