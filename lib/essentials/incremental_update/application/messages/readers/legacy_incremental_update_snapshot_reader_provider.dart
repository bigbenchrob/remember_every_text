import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/legacy_incremental_update_state_repository_provider.dart';
import 'legacy_incremental_update_snapshot_reader.dart';

part 'legacy_incremental_update_snapshot_reader_provider.g.dart';

@riverpod
Future<LegacyIncrementalUpdateSnapshotReader>
legacyIncrementalUpdateSnapshotReader(Ref ref) async {
  final repository = await ref.watch(
    legacyIncrementalUpdateStateRepositoryProvider.future,
  );

  return LegacyIncrementalUpdateSnapshotReader(repository: repository);
}
