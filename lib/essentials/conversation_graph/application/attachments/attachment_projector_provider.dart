import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'attachment_projector.dart';

part 'attachment_projector_provider.g.dart';

@riverpod
Future<AttachmentProjector> attachmentProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return AttachmentProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
