import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/shadow_working_message_projection_repository_provider.dart';
import 'shadow_working_projection_snapshot_reader.dart';

part 'shadow_working_projection_snapshot_reader_provider.g.dart';

@riverpod
Future<ShadowWorkingProjectionSnapshotReader>
shadowWorkingProjectionSnapshotReader(Ref ref) async {
  final repository = await ref.watch(
    shadowWorkingMessageProjectionRepositoryProvider.future,
  );

  return ShadowWorkingProjectionSnapshotReader(repository: repository);
}
