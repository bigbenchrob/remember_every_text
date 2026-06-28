import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers/persistent_database_providers.dart'
    show overlayDatabaseProvider;
import '../infrastructure/pipeline_audit_incident_log_writer.dart';
import '../infrastructure/pipeline_incident_storage.dart';
import 'pipeline_incident_log_writer.dart';
import 'pipeline_incident_store.dart';

part 'pipeline_incident_storage_provider.g.dart';

@riverpod
PipelineIncidentStore pipelineIncidentStore(Ref ref) {
  return PipelineIncidentStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  );
}

@riverpod
PipelineIncidentLogWriter pipelineIncidentLogWriter(Ref ref) {
  return const PipelineAuditIncidentLogWriter();
}
