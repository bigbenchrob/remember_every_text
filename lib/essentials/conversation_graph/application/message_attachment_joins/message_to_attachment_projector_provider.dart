import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'message_to_attachment_projector.dart';

part 'message_to_attachment_projector_provider.g.dart';

@riverpod
Future<MessageToAttachmentProjector> messageToAttachmentProjector(
  Ref ref,
) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return MessageToAttachmentProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
