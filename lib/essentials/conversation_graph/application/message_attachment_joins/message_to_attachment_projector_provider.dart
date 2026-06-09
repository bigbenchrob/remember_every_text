import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/repositories/message_to_attachment_projection_repository.dart';
import 'message_to_attachment_projector.dart';

part 'message_to_attachment_projector_provider.g.dart';

@riverpod
Future<MessageToAttachmentProjector> messageToAttachmentProjector(
  Ref ref,
) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final graphDatabase = await ref.watch(
    driftConversationGraphDatabaseProvider.future,
  );

  return MessageToAttachmentProjector(
    repository: SqliteMessageToAttachmentProjectionRepository(
      importDatabase: importDatabase,
      graphDatabase: graphDatabase,
    ),
  );
}
