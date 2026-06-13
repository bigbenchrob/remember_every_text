import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/repositories/archive_source_inspection_repository.dart';
import 'archive_source_inspection.dart';

part 'archive_source_inspector_provider.g.dart';

@riverpod
Future<ArchiveSourceInspector> archiveSourceInspector(Ref ref) {
  return ref.watch(archiveSourceInspectionRepositoryProvider.future);
}
