import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/working_database_provider.dart';
import 'chat_summary.dart';
import 'chat_summary_reader.dart';

part 'chat_summary_provider.g.dart';

@riverpod
Future<List<ChatSummary>> chatSummaries(Ref ref) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(workingDatabase: workingDatabase).readSummaries();
}

@riverpod
Future<ChatSummarySanityCounts> chatSummarySanityCounts(Ref ref) async {
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);
  return ChatSummaryReader(workingDatabase: workingDatabase).readSanityCounts();
}
