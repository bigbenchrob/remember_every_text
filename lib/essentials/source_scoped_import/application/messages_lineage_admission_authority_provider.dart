import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../paths/feature_level_providers.dart' show pathsHelperProvider;
import '../infrastructure/source_database_messages_lineage_anchor_repository.dart';
import 'messages_lineage_admission_authority.dart';
import 'messages_lineage_admission_service.dart';
import 'source_database_opener_provider.dart';

part 'messages_lineage_admission_authority_provider.g.dart';

@riverpod
Future<MessagesLineageAdmissionAuthority> messagesLineageAdmissionAuthority(
  Ref ref,
) async {
  final pathsHelper = await ref.watch(pathsHelperProvider.future);
  return MessagesLineageAdmissionService(
    anchorRepository: SourceDatabaseMessagesLineageAnchorRepository(
      sourceDatabaseOpener: ref.watch(sourceDatabaseOpenerProvider),
    ),
    authoritativeCurrentMessagesDatabasePath: pathsHelper.chatDBPath,
  );
}
