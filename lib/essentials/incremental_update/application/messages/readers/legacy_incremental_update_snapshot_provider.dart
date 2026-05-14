import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/legacy_incremental_update_snapshot.dart';
import 'legacy_incremental_update_snapshot_reader_provider.dart';

part 'legacy_incremental_update_snapshot_provider.g.dart';

@riverpod
Future<LegacyIncrementalUpdateSnapshot> legacyIncrementalUpdateSnapshot(
  Ref ref,
) async {
  final reader = await ref.watch(
    legacyIncrementalUpdateSnapshotReaderProvider.future,
  );

  return reader.read();
}
