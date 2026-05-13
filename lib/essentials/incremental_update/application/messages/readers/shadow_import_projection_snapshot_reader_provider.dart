import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/shadow_import_message_projection_repository_provider.dart';
import 'shadow_import_projection_snapshot_reader.dart';

part 'shadow_import_projection_snapshot_reader_provider.g.dart';

@riverpod
Future<ShadowImportProjectionSnapshotReader>
shadowImportProjectionSnapshotReader(Ref ref) async {
  final repository = await ref.watch(
    shadowImportMessageProjectionRepositoryProvider.future,
  );

  return ShadowImportProjectionSnapshotReader(repository: repository);
}
