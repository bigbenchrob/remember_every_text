import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/filesystem_historical_messages_archive_source_folder_resolver.dart';
import 'historical_messages_archive_source_folder_resolver.dart';

part 'historical_messages_archive_source_folder_resolver_provider.g.dart';

@riverpod
HistoricalMessagesArchiveSourceFolderResolver
historicalMessagesArchiveSourceFolderResolver(Ref ref) {
  return const FilesystemHistoricalMessagesArchiveSourceFolderResolver();
}
