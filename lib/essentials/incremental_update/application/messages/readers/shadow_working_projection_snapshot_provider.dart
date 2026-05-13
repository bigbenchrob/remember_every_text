import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/message_projection_snapshot.dart';
import 'shadow_working_projection_snapshot_reader_provider.dart';

part 'shadow_working_projection_snapshot_provider.g.dart';

@riverpod
Future<MessageProjectionSnapshot> shadowWorkingProjectionSnapshot(
  Ref ref,
) async {
  final reader = await ref.watch(
    shadowWorkingProjectionSnapshotReaderProvider.future,
  );

  return reader.read();
}
