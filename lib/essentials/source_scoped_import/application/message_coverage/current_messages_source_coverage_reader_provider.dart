import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/source_database_current_messages_coverage_reader.dart';
import '../source_database_opener_provider.dart';
import 'current_messages_source_coverage_reader.dart';

part 'current_messages_source_coverage_reader_provider.g.dart';

@riverpod
CurrentMessagesSourceCoverageReader currentMessagesSourceCoverageReader(
  Ref ref,
) {
  return SourceDatabaseCurrentMessagesCoverageReader(
    sourceDatabaseOpener: ref.watch(sourceDatabaseOpenerProvider),
  );
}
