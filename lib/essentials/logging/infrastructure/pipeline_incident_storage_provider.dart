import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart';
import 'pipeline_incident_storage.dart';

part 'pipeline_incident_storage_provider.g.dart';

@riverpod
PipelineIncidentStorage pipelineIncidentStorage(
  PipelineIncidentStorageRef ref,
) {
  return PipelineIncidentStorage(
    overlayDb: ref.watch(overlayDatabaseProvider.future),
  );
}
